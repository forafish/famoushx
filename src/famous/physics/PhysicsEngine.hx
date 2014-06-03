package famous.physics;

import famous.core.EventEmitter.HandlerFunc;
import famous.core.EventHandler;
import famous.physics.bodies.Particle;
import famous.physics.bodies.Body;
import famous.physics.constraints.Constraint;
import famous.physics.forces.Force;

typedef PhysicsEngineOptions = {
	/**
	 * The number of iterations the engine takes to resolve constraints
	 * @attribute constraintSteps
	 * @type Number
	 */
	constraintSteps : Int,

	/**
	 * The energy threshold before the Engine stops updating
	 * @attribute sleepTolerance
	 * @type Number
	 */
	sleepTolerance  : Float
};

typedef Agent = {
	agent   : Dynamic, // Force or Constraint
	targets : Dynamic, // Particle or Body
	source  : Body
};

/**
 * The Physics Engine is responsible for mediating Bodies and their
 * interaction with forces and constraints. The Physics Engine handles the
 * logic of adding and removing bodies, updating their state of the over
 * time.
 */
class PhysicsEngine {
    static public var TIMESTEP = 17;
    static public var MIN_TIME_STEP = 17;
    static public var MAX_TIME_STEP = 1000 / 120;

    /**
     * @property PhysicsEngine.DEFAULT_OPTIONS
     * @type Object
     * @protected
     * @static
     */
    static public var DEFAULT_OPTIONS:PhysicsEngineOptions = {
        constraintSteps : 1,
        sleepTolerance  : 1e-7
    };

	var _particles:Array<Particle>; //list of managed particles
	var _bodies:Array<Body>;   		//list of managed bodies
	var _agents:Map<Int, Agent>;   	//hash of managed agents
	var _forces:Array<Int>;  		//list of IDs of agents that are forces
	var _constraints:Array<Int>; 	//list of IDs of agents that are constraints

	var _buffer:Float;
	var _prevTime:Float;
	var _isSleeping:Bool;
	var _eventHandler:EventHandler;
	var _currAgentId:Int;
	var _hasBodies:Bool;

	var options:Dynamic;
	
    // Cached timing function
    var now = (function() {
        return Date.now;
    })();
	
    /**
     * @constructor
     * @param options {Object} options
     */
	public function new(?options:PhysicsEngineOptions) {
        this.options = Reflect.copy(PhysicsEngine.DEFAULT_OPTIONS);
        if (options != null) this.setOptions(options);

        this._particles      = [];   //list of managed particles
        this._bodies         = [];   //list of managed bodies
        this._agents         = new Map();   //hash of managed agents
        this._forces         = [];   //list of IDs of agents that are forces
        this._constraints    = [];   //list of IDs of agents that are constraints
		
        this._buffer         = 0.0;
        this._prevTime       = now().getTime();
        this._isSleeping     = false;
        this._eventHandler   = null;
        this._currAgentId    = 0;
        this._hasBodies      = false;
	}
	
    /**
     * Options setter
     * @method setOptions
     * @param options {Object}
     */
    public function setOptions(options:Dynamic) {
        for (key in Reflect.fields(options)) {
			if (this.options[cast key] != null) {
				this.options[cast key] = options[cast key];
			}
		}
    }

    /**
     * Method to add a physics body to the engine. Necessary to update the
     * body over time.
     *
     * @method addBody
     * @param body {Body}
     * @return body {Body}
     */
    public function addBody(body:Particle):Particle {
        body._engine = this;
        if (body.isBody) {
            this._bodies.push(cast body);
            this._hasBodies = true;
        }
        else this._particles.push(body);
        return body;
    }

    /**
     * Remove a body from the engine. Detaches body from all forces and
     * constraints.
     *
     * @method removeBody
     * @param body {Body}
     */
    public function removeBody(body:Body) {
        var array:Array<Dynamic> = (body.isBody) ? this._bodies : this._particles;
        var index = array.indexOf(body);
        if (index > -1) {
            for (i in 0...Reflect.fields(this._agents).length) {
				this.detachFrom(i, body);
			}
            array.splice(index,1);
        }
        if (this.getBodies().length == 0) {
			this._hasBodies = false;
		}
    }

    function _mapAgentArray(agent:Dynamic):Array<Dynamic> {
        if (agent.applyForce != null) return this._forces;
        if (agent.applyConstraint != null) return this._constraints;
		return null;
    }

    function _attachOne(agent:Array<Dynamic>, ?targets:Dynamic, ?source:Body):Int {
        if (targets == null) targets = this.getParticlesAndBodies();
        if (!Std.is(targets, Array)) targets = [targets];

        this._agents[this._currAgentId] = {
            agent   : agent,
            targets : targets,
            source  : source
        };

        _mapAgentArray(agent).push(this._currAgentId);
        return this._currAgentId++;
    }

    /**
     * Attaches a force or constraint to a Body. Returns an AgentId of the
     * attached agent which can be used to detach the agent.
     *
     * @method attach
     * @param agent {Agent|Array.Agent} A force, constraint, or array of them.
     * @param [targets=All] {Body|Array.Body} The Body or Bodies affected by the agent
     * @param [source] {Body} The source of the agent
     * @return AgentId {Number}
     */
    public function attach(agents:Dynamic, ?targets:Dynamic, ?source:Body):Array<Int> {
        if (Std.is(agents, Array)) {
            var agentIDs = [];
            for (i in 0...agents.length) {
                agentIDs[i] = _attachOne(agents[i], targets, source);
			}
            return agentIDs;
        }
        else return [_attachOne(agents, targets, source)];
    }

    /**
     * Append a body to the targets of a previously defined physics agent.
     *
     * @method attachTo
     * @param agentID {AgentId} The agentId of a previously defined agent
     * @param target {Body} The Body affected by the agent
     */
    public function attachTo(agentID:Int, target:Dynamic) {
        _getBoundAgent(agentID).targets.push(target);
    }

    /**
     * Undoes PhysicsEngine.attach. Removes an agent and its associated
     * effect on its affected Bodies.
     *
     * @method detach
     * @param agentID {AgentId} The agentId of a previously defined agent
     */
    public function detach(id) {
        // detach from forces/constraints array
        var agent = this.getAgent(id);
        var agentArray = _mapAgentArray(agent);
        var index = agentArray.indexOf(id);
        agentArray.splice(index, 1);

        // detach agents array
        this._agents.remove(id);
    }

    /**
     * Remove a single Body from a previously defined agent.
     *
     * @method detach
     * @param agentID {AgentId} The agentId of a previously defined agent
     * @param target {Body} The body to remove from the agent
     */
    public function detachFrom(id:Int, target:Body) {
        var boundAgent = _getBoundAgent(id);
        if (boundAgent.source == target) this.detach(id);
        else {
            var targets = boundAgent.targets;
            var index = targets.indexOf(target);
            if (index > -1) targets.splice(index,1);
        }
    }

    /**
     * A convenience method to give the Physics Engine a clean slate of
     * agents. Preserves all added Body objects.
     *
     * @method detachAll
     */
    public function detachAll() {
        this._agents        = new Map();
        this._forces        = [];
        this._constraints   = [];
        this._currAgentId   = 0;
    }

    function _getBoundAgent(id:Int) {
        return this._agents[id];
    }

    /**
     * Returns the corresponding agent given its agentId.
     *
     * @method getAgent
     * @param id {AgentId}
     */
    public function getAgent(id:Int) {
        return _getBoundAgent(id).agent;
    }

    /**
     * Returns all particles that are currently managed by the Physics Engine.
     *
     * @method getParticles
     * @return particles {Array.Particles}
     */
    public function getParticles():Array<Particle> {
        return this._particles;
    }

    /**
     * Returns all bodies, except particles, that are currently managed by the Physics Engine.
     *
     * @method getBodies
     * @return bodies {Array.Bodies}
     */
    public function getBodies():Array<Body> {
        return this._bodies;
    }

    /**
     * Returns all bodies that are currently managed by the Physics Engine.
     *
     * @method getBodies
     * @return bodies {Array.Bodies}
     */
    public function getParticlesAndBodies():Array<Particle> {
        return this.getParticles().concat(cast this.getBodies());
    }

    /**
     * Iterates over every Particle and applies a function whose first
     * argument is the Particle
     *
     * @method forEachParticle
     * @param fn {Function} Function to iterate over
     * @param [dt] {Number} Delta time
     */
    public function forEachParticle(fn:Particle -> Float -> Void, dt:Float) {
        var particles = this.getParticles();
        for (particle in particles) {
            fn(particle, dt);
		}
    }

    /**
     * Iterates over every Body that isn't a Particle and applies
     * a function whose first argument is the Body
     *
     * @method forEachBody
     * @param fn {Function} Function to iterate over
     * @param [dt] {Number} Delta time
     */
    public function forEachBody(fn:Body -> Float -> Void, ?dt:Float) {
        if (this._hasBodies == null) return;
        var bodies = this.getBodies();
        for (body in bodies) {
            fn(body, dt);
		}
    }

    /**
     * Iterates over every Body and applies a function whose first
     * argument is the Body
     *
     * @method forEach
     * @param fn {Function} Function to iterate over
     * @param [dt] {Number} Delta time
     */
    public function forEach(fn:Particle -> Float -> Void, ?dt:Float) {
        this.forEachParticle(fn, dt);
        this.forEachBody(fn, dt);
    }

    function _updateForce(index:Int) {
        var boundAgent = _getBoundAgent(this._forces[index]);
        boundAgent.agent.applyForce(boundAgent.targets, boundAgent.source);
    }

    function _updateForces() {
		var index = this._forces.length - 1;
        while (index > -1) {
            _updateForce(index);
			index--;
		}
    }

    function _updateConstraint(index:Int, dt:Float) {
        var boundAgent = this._agents[this._constraints[index]];
        return boundAgent.agent.applyConstraint(boundAgent.targets, boundAgent.source, dt);
    }

    function _updateConstraints(dt:Float) {
        var iteration = 0;
        while (iteration < this.options.constraintSteps) {
			var index = this._constraints.length - 1;
            while (index > -1) {
                _updateConstraint(index, dt);
				index--;
			}
            iteration++;
        }
    }

    function _updateVelocities(particle:Particle, dt:Float) {
        particle.integrateVelocity(dt);
    }

    function _updateAngularVelocities(body:Body, dt:Float) {
        body.integrateAngularMomentum(dt);
        body.updateAngularVelocity();
    }

    function _updateOrientations(body:Body, dt:Float) {
        body.integrateOrientation(dt);
    }

    function _updatePositions(particle:Particle, dt:Float) {
        particle.integratePosition(dt);
        particle.emit('update', particle);
    }

    function _integrate(dt:Float) {
        _updateForces();
        this.forEach(_updateVelocities, dt);
        this.forEachBody(_updateAngularVelocities, dt);
        _updateConstraints(dt);
        this.forEachBody(_updateOrientations, dt);
        this.forEach(_updatePositions, dt);
    }

    function _getEnergyParticles() {
        var energy = 0.0;
        var particleEnergy = 0.0;
        this.forEach(function(particle, dt) {
            particleEnergy = particle.getEnergy();
            energy += particleEnergy;
            if (particleEnergy < this.options.particle.sleepTolerance) particle.sleep();
        });
        return energy;
    }

    function _getEnergyForces() {
        var energy:Float = 0;
		var index = this._forces.length - 1;
        while (index > -1) {
			var agent = this._agents[index].agent;
            energy += agent.getEnergy != null? agent.getEnergy() : 0.0;
			index--;
		}
        return energy;
    }

    function _getEnergyConstraints() {
        var energy:Float = 0;
		var index = this._constraints.length - 1;
        while (index > -1) {
			var constraint = this._agents[index].agent;
            energy += constraint.getEnergy != null? constraint.getEnergy() : 0.0;
			index--;
		}
        return energy;
    }

    /**
     * Calculates the kinetic energy of all Body objects and potential energy
     * of all attached agents.
     *
     * TODO: implement.
     * @method getEnergy
     * @return energy {Number}
     */
    public function getEnergy():Dynamic {
        return _getEnergyParticles() + _getEnergyForces() + _getEnergyConstraints();
    }

    /**
     * Updates all Body objects managed by the physics engine over the
     * time duration since the last time step was called.
     *
     * @method step
     */
    public function step() {
//        if (this.getEnergy() < this.options.sleepTolerance) {
//            this.sleep();
//            return;
//        };

        //set current frame's time
        var currTime = now().getTime();

        //milliseconds elapsed since last frame
        var dtFrame = currTime - this._prevTime;

        this._prevTime = currTime;

        if (dtFrame < MIN_TIME_STEP) return;
        if (dtFrame > MAX_TIME_STEP) dtFrame = MAX_TIME_STEP;

        //robust integration
//        this._buffer += dtFrame;
//        while (this._buffer > this._timestep){
//            _integrate.call(this, this._timestep);
//            this._buffer -= this._timestep;
//        };
//        _integrate.call(this, this._buffer);
//        this._buffer = 0.0;
		_integrate(TIMESTEP);

//        this.emit('update', this);
    }

    /**
     * Tells whether the Physics Engine is sleeping or awake.
     * @method isSleeping
     * @return {Boolean}
     */
    public function isSleeping():Bool {
        return this._isSleeping;
    }

    /**
     * Stops the Physics Engine from updating. Emits an 'end' event.
     * @method sleep
     */
    public function sleep() {
        this.emit('end', this);
        this._isSleeping = true;
    }

    /**
     * Starts the Physics Engine from updating. Emits an 'start' event.
     * @method wake
     */
    public function wake() {
        this._prevTime = now().getTime();
        this.emit('start', this);
        this._isSleeping = false;
    }

    public function emit(type:String, ?data:Dynamic) {
        if (this._eventHandler == null) return;
        this._eventHandler.emit(type, data);
    }

    public function on(event:String, fn:HandlerFunc) {
        if (this._eventHandler == null) this._eventHandler = new EventHandler();
        this._eventHandler.on(event, fn);
    }
	
}