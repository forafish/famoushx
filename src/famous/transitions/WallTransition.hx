package famous.transitions;

import famous.math.Vector;
import famous.physics.PhysicsEngine;
import famous.physics.bodies.Particle;
import famous.physics.forces.Spring;
import famous.physics.constraints.Wall;

typedef WallTransitionOptions = {
	/**
	 * The amount of time in milliseconds taken for one complete oscillation
	 * when there is no damping
	 *    Range : [0, Infinity]
	 *
	 * @attribute period
	 * @type Number
	 * @default 300
	 */
	period : Float,

	/**
	 * The damping of the snap.
	 *    Range : [0, 1]
	 *    0 = no damping, and the spring will oscillate forever
	 *    1 = critically damped (the spring will never oscillate)
	 *
	 * @attribute dampingRatio
	 * @type Number
	 * @default 0.5
	 */
	dampingRatio : Float,

	/**
	 * The initial velocity of the transition.
	 *
	 * @attribute velocity
	 * @type Number|Array
	 * @default 0
	 */
	velocity : Float,

	/**
	 * The percentage of momentum transferred to the wall
	 *
	 * @attribute restitution
	 * @type Number
	 * @default 0.5
	 */
	restitution : Float
};

/**
 * WallTransition is a method of transitioning between two values (numbers,
 *   or arrays of numbers) with a bounce. Unlike a SpringTransition
 *   The transition will not overshoot the target, but bounce back against it.
 *   The behavior of the bounce is specified by the transition options.
 */
class WallTransition {
    static public var SUPPORTS_MULTIPLE = 3;

	static public var transitionId = 0;
	
    /**
     * @property WallTransition.DEFAULT_OPTIONS
     * @type Object
     * @protected
     * @static
     */
    static public var DEFAULT_OPTIONS:WallTransitionOptions = {
        period : 300,
        dampingRatio : 0.5,
        velocity : 0,
        restitution : 0.5
    };
	
	var endState:Vector;
	var initState:Vector;

	var _id:Int; // for debug
	var _dimensions:Int;
	var _restTolerance:Float;
	var _absRestTolerance:Float;
	var _callback:Void -> Void;

	var PE:PhysicsEngine;
	var spring:Spring;
	var particle:Particle;
	var wall:Wall;
		
    /**
     * @constructor
     *
     * @param {Number|Array} [state=0] Initial state
     */
	public function new(state:Dynamic) {
        state = state != null? state : 0;

        this.endState  = new Vector(state);
        this.initState = new Vector();

		this._id = transitionId++;
        this._dimensions = 1;
        this._restTolerance = 1e-10;
        this._absRestTolerance = this._restTolerance;
        this._callback = null;

        this.PE = new PhysicsEngine();
        this.spring = new Spring({anchor : this.endState});
        this.wall   = new Wall();
        this.particle = new Particle();

        this.PE.addBody(this.particle);
        this.PE.attach([this.wall, this.spring], this.particle);		
	}
	
    function _getEnergy() {
        return this.particle.getEnergy() + this.spring.getEnergy(this.particle);
    }

    function _setParticlePosition(p:Dynamic) {
        this.particle.setPosition(p);
    }

    function _setParticleVelocity(v:Dynamic) {
        this.particle.setVelocity(v);
    }

    function _getParticlePosition():Dynamic {
        return (this._dimensions == 0)
            ? this.particle.getPosition1D()
            : this.particle.getPosition();
    }

    function _getParticleVelocity():Dynamic {
        return (this._dimensions == 0)
            ? this.particle.getVelocity1D()
            : this.particle.getVelocity();
    }

    function _setCallback(callback:Void -> Void) {
        this._callback = callback;
    }

    function _wake() {
        this.PE.wake();
    }

    function _sleep() {
        this.PE.sleep();
    }

    function _update() {
        if (this.PE.isSleeping()) {
            if (this._callback != null) {
                var cb = this._callback;
                this._callback = null;
                cb();
            }
            return;
        }
        if (_getEnergy() < this._absRestTolerance) {
            _setParticlePosition(this.endState);
            _setParticleVelocity([0,0,0]);
            _sleep();
        }
    }

    function _setupDefinition(definition:Dynamic) {
        var defaults = WallTransition.DEFAULT_OPTIONS;
        if (definition.period == null) definition.period = defaults.period;
        if (definition.dampingRatio == null) definition.dampingRatio = defaults.dampingRatio;
        if (definition.velocity == null) definition.velocity = defaults.velocity;
        if (definition.restitution == null) definition.restitution = defaults.restitution;

        //setup spring
        this.spring.setOptions({
            period : definition.period,
            dampingRatio : definition.dampingRatio
        });

        //setup wall
        this.wall.setOptions({
            restitution : definition.restitution
        });

        //setup particle
        _setParticleVelocity(definition.velocity);
    }

    function _setAbsoluteRestTolerance() {
        var distance = this.endState.sub(this.initState).normSquared();
        this._absRestTolerance = (distance == 0)
            ? this._restTolerance
            : this._restTolerance * distance;
    }


    function _setTarget(target:Dynamic) {
        this.endState.set(target);

        var dist = this.endState.sub(this.initState).norm();

        this.wall.setOptions({
            distance : this.endState.norm(),
            normal : (dist == 0)
                ? this.particle.velocity.normalize(-1)
                : this.endState.sub(this.initState).normalize(-1)
        });

        _setAbsoluteRestTolerance();
    }

    /**
     * Resets the state and velocity
     *
     * @method reset
     *
     * @param {Number|Array}  state     State
     * @param  {Number|Array} [velocity] Velocity
     */
    public function reset(state:Dynamic, ?velocity:Dynamic) {
        this._dimensions = Std.is(state, Array)
            ? state.length
            : 0;

        this.initState.set(state);
        _setParticlePosition(state);
        _setTarget(state);
        if (velocity != null) _setParticleVelocity(velocity);
       _setCallback(null);
    }

    /**
     * Getter for velocity
     *
     * @method getVelocity
     *
     * @return velocity {Number|Array}
     */
    public function getVelocity() {
        return _getParticleVelocity();
    }

    /**
     * Setter for velocity
     *
     * @method setVelocity
     *
     * @return velocity {Number|Array}
     */
    public function setVelocity(v:Dynamic) {
        _setParticleVelocity(v);
    }

    /**
     * Detects whether a transition is in progress
     *
     * @method isActive
     *
     * @return {Boolean}
     */
    public function isActive() {
        return !this.PE.isSleeping();
    }

    /**
     * Halt the transition
     *
     * @method halt
     */
    public function halt() {
        this.set(this.get());
    }

    /**
     * Getter
     *
     * @method get
     *
     * @return state {Number|Array}
     */
    public function get() {
        _update();
        return _getParticlePosition();
    }

    /**
     * Set the end position and transition, with optional callback on completion.
     *
     * @method set
     *
     * @param endState {Number|Array}      Final state
     * @param [definition] {Object}     Transition definition
     * @param [callback] {Function}     Callback
     */
    public function set(endState:Dynamic, ?definition:Dynamic, ?callback:Void -> Void) {
        if (definition == null) {
            this.reset(endState);
            if (callback != null) callback();
            return;
        }

        this._dimensions = Std.is(endState, Array)
            ? endState.length
            : 0;

        _wake();
        _setupDefinition(definition);
        _setTarget(endState);
        _setCallback(callback);
    }
	
}