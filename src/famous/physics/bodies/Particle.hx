package famous.physics.bodies;

import famous.core.DynamicMap;
import famous.core.Engine;
import famous.math.Vector;
import famous.core.Transform;
import famous.core.EventHandler;
import famous.core.EventEmitter;
import famous.physics.integrators.SymplecticEuler;

typedef ParticleOptions = {
	?position : Array<Float>,
	?velocity : Array<Float>,
	?force: Array<Float>,
	?mass : Float,
	?axis : Dynamic
};

/**
 * A point body that is controlled by the Physics Engine. A particle has
 *   position and velocity states that are updated by the Physics Engine.
 *   Ultimately, a particle is a _special type of modifier, and can be added to
 *   the Famous render tree like any other modifier.
 *
 */
class Particle extends EventHandleable {

    static public var DEFAULT_OPTIONS = {
        position : [0,0,0],
        velocity : [0, 0, 0],
		force : [0,0,0],
        mass : 1,
        axis : null
    };

    /**
     * Kinetic energy threshold needed to update the body
     *
     * @property SLEEP_TOLERANCE
     * @type Number
     * @static
     * @default 1e-7
     */
    static public var SLEEP_TOLERANCE = 1e-7;

    /**
     * Axes by which a body can translate
     *
     * @property AXES
     * @type Hexadecimal
     * @static
     * @default 1e-7
     */
    static public var AXES = {
        X : 0x00, // hexadecimal for 0
        Y : 0x01, // hexadecimal for 1
        Z : 0x02  // hexadecimal for 2
    };

    // Integrator for updating the particle's state
    // TODO: make this a singleton
	static public var INTEGRATOR = new SymplecticEuler();

    //Catalogue of outputted events
    static var _events = {
        start  : 'start',
        update : 'update',
        end    : 'end'
    }
	
	public var position:Vector;
	public var velocity:Vector;
	public var force:Vector;
	public var mass:Float;
	public var axis:Dynamic;
	public var inverseMass:Float;

	public var _engine:Dynamic;

	// state variables
	var _isSleeping:Bool;
	var _eventOutput:EventHandler;
	var _positionGetter:Void -> Float;
	var _prevTime:Float;
	
	var transform:Matrix4;

	// cached _spec
	var _spec:Dynamic;
	
    // Cached timing function
    var now = (function() {
        return Date.now;
    })();
	
    /**
     * @attribute isBody
     * @type Boolean
     * @static
     */
	public var isBody = false;
	
    /**
     * @constructor
     * @class Particle
     * @uses EventHandler
     * @uses Modifier
     * @extensionfor Body
     * @param {Options} [options] An object of configurable options.
     * @param {Array} [options.position] The position of the particle.
     * @param {Array} [options.velocity] The velocity of the particle.
     * @param {Number} [options.mass] The mass of the particle.
     * @param {Hexadecimal} [options.axis] The axis a particle can move along. Can be bitwise ORed e.g., Particle.AXES.X, Particle.AXES.X | Particle.AXES.Y
     *
     */
	public function new(?options:ParticleOptions) {
        options = options != null? options : {};

        // registers
        this.position = new Vector();
        this.velocity = new Vector();
        this.force    = new Vector();
	
		var defaults  = Particle.DEFAULT_OPTIONS;
		
        // set vectors
        this.setPosition(options.position != null? options.position : defaults.position);
        this.setVelocity(options.velocity != null? options.velocity : defaults.velocity);
        this.force.set(options.force != null? options.force : defaults.force);

        // set scalars
        this.mass = (options.mass != null)
            ? options.mass
            : defaults.mass;

        this.axis = (options.axis != null)
            ? options.axis
            : defaults.axis;

        this.inverseMass = 1 / this.mass;

        // state variables
        this._isSleeping     = false;
        this._engine         = null;
        this._eventOutput    = null;
        this._positionGetter = null;

        this.transform = Transform.identity.slice(0);

        // cached _spec
        this._spec = {
            transform : this.transform,
            target    : null
        };		
		
        this._eventOutput = new EventHandler();
        EventHandler.setOutputHandler(this, this._eventOutput);
	}
	
    /**
     * Stops the particle from updating
     * @method sleep
     */
    public function sleep() {
        if (this._isSleeping) return;
        this.emit(_events.end, this);
        this._isSleeping = true;
    }

    /**
     * Starts the particle update
     * @method wake
     */
    public function wake() {
        if (!this._isSleeping) return;
        this.emit(_events.start, this);
        this._isSleeping = false;
        this._prevTime = now().getTime();
    }

    /**
     * Basic setter for position
     * @method getPosition
     * @param position {Array|Vector}
     */
    public function setPosition(position:Dynamic) {
        this.position.set(position);
    }

    /**
     * 1-dimensional setter for position
     * @method setPosition1D
     * @param value {Number}
     */
    public function setPosition1D(x:Float) {
        this.position.x = x;
    }

    /**
     * Basic getter function for position
     * @method getPosition
     * @return position {Array}
     */
    public function getPosition():Array<Float> {
        if (Reflect.isFunction(this._positionGetter)) {
            this.setPosition(this._positionGetter());
		}

        this._engine.step();

        return this.position.get();
    }

    /**
     * 1-dimensional getter for position
     * @method getPosition1D
     * @return value {Number}
     */
    public function getPosition1D():Float {
        this._engine.step();
        return this.position.x;
    }

    /**
     * Defines the position from outside the Physics Engine
     * @method positionFrom
     * @param positionGetter {Function}
     */
    public function positionFrom(positionGetter:Void -> Float) {
        this._positionGetter = positionGetter;
    }

    /**
     * Basic setter function for velocity Vector
     * @method setVelocity
     * @function
     */
    public function setVelocity(velocity:Dynamic) {
        this.velocity.set(velocity);
        this.wake();
    }

    /**
     * 1-dimensional setter for velocity
     * @method setVelocity1D
     * @param velocity {Number}
     */
    public function setVelocity1D(x:Float) {
        this.velocity.x = x;
        this.wake();
    }

    /**
     * Basic getter function for velocity Vector
     * @method getVelocity
     * @return velocity {Array}
     */
    public function getVelocity():Array<Float> {
        return this.velocity.get();
    }

    /**
     * 1-dimensional getter for velocity
     * @method getVelocity1D
     * @return velocity {Number}
     */
    public function getVelocity1D():Float {
        return this.velocity.x;
    }

    /**
     * Basic setter function for mass quantity
     * @method setMass
     * @param mass {Number} mass
     */
    public function setMass(mass:Float) {
        this.mass = mass;
        this.inverseMass = 1 / mass;
    }

    /**
     * Basic getter function for mass quantity
     * @method getMass
     * @return mass {Number}
     */
    public function getMass():Float {
        return this.mass;
    }

    /**
     * Reset position and velocity
     * @method reset
     * @param position {Array|Vector}
     * @param velocity {Array|Vector}
     */
    public function reset(position:Dynamic, velocity:Dynamic, ?q:Dynamic, ?L:Dynamic) {
        this.setPosition(position != null? position : [0,0,0]);
        this.setVelocity(velocity != null? velocity : [0,0,0]);
    }

    /**
     * Add force vector to existing internal force Vector
     * @method applyForce
     * @param force {Vector}
     */
    public function applyForce(force:Vector, ?location:Vector) {
        if (force.isZero()) return;
        this.force.add(force).put(this.force);
        this.wake();
    }

    /**
     * Add impulse (change in velocity) Vector to this Vector's velocity.
     * @method applyImpulse
     * @param impulse {Vector}
     */
    public function applyImpulse(impulse:Vector) {
        if (impulse.isZero()) return;
        var velocity = this.velocity;
        velocity.add(impulse.mult(this.inverseMass)).put(velocity);
    }

    /**
     * Update a particle's velocity from its force accumulator
     * @method integrateVelocity
     * @param dt {Number} Time differential
     */
    public function integrateVelocity(dt:Float) {
        INTEGRATOR.integrateVelocity(this, dt);
    }

    /**
     * Update a particle's position from its velocity
     * @method integratePosition
     * @param dt {Number} Time differential
     */
    public function integratePosition(dt:Float) {
        INTEGRATOR.integratePosition(this, dt);
    }

    /**
     * Update the position and velocity of the particle
     * @method _integrate
     * @protected
     * @param dt {Number} Time differential
     */
    public function _integrate(dt:Float) {
        this.integrateVelocity(dt);
        this.integratePosition(dt);
    }

    /**
     * Get kinetic energy of the particle.
     * @method getEnergy
     * @function
     */
    public function getEnergy():Float {
        return 0.5 * this.mass * this.velocity.normSquared();
    }

    /**
     * Generate transform from the current position state
     * @method getTransform
     * @return Transform {Transform}
     */
    public function getTransform():Matrix4 {
        this._engine.step();

        var position = this.position;
        var axis = this.axis;
        var transform = this.transform;

        if (axis != null) {
            if ((axis & ~Particle.AXES.X) != 0) {
                position.x = 0;
            }
            if ((axis & ~Particle.AXES.Y) != 0) {
                position.y = 0;
            }
            if ((axis & ~Particle.AXES.Z) != 0) {
                position.z = 0;
            }
        }

        transform[12] = position.x;
        transform[13] = position.y;
        transform[14] = position.z;

        return transform;
    }

    /**
     * The modify interface of a Modifier
     * @method modify
     * @param target {Spec}
     * @return Spec {Spec}
     */
    public function modify(target:Dynamic) {
        var _spec = this._spec;
        _spec.transform = this.getTransform();
        _spec.target = target;
        return _spec;
    }

    public function emit(type:String, data:Dynamic) {
        if (this._eventOutput == null) return;
        this._eventOutput.emit(type, data);
    }
	
}