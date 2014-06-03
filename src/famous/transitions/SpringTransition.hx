package famous.transitions;

import famous.math.Vector;
import famous.physics.PhysicsEngine;
import famous.physics.bodies.Particle;
import famous.physics.forces.Spring;

typedef SpringTransitionOptions = {
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
	velocity : Float
};

/**
 * SpringTransition is a method of transitioning between two values (numbers,
 * or arrays of numbers) with a bounce. The transition will overshoot the target
 * state depending on the parameters of the transition.
 */
class SpringTransition {
    static public var SUPPORTS_MULTIPLE = 3;

	static public var transitionId = 0;
	
    /**
     * @property SpringTransition.DEFAULT_OPTIONS
     * @type Object
     * @protected
     * @static
     */
    static public var DEFAULT_OPTIONS:SpringTransitionOptions = {
        period : 300,
        dampingRatio : 0.5,
        velocity : 0
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
        this._dimensions       = 1;
        this._restTolerance    = 1e-10;
        this._absRestTolerance = this._restTolerance;
        this._callback         = null;

        this.PE       = new PhysicsEngine();
        this.spring   = new Spring({anchor : this.endState});
        this.particle = new Particle();

        this.PE.addBody(this.particle);
        this.PE.attach(this.spring, this.particle);
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
        // TODO fix no-console error
        /* eslint no-console: 0 */
        var defaults = SpringTransition.DEFAULT_OPTIONS;
        if (definition.period == null) definition.period = defaults.period;
        if (definition.dampingRatio == null) definition.dampingRatio = defaults.dampingRatio;
        if (definition.velocity == null) definition.velocity = defaults.velocity;

        if (definition.period < 150) {
            definition.period = 150;
            haxe.Log.trace('The period of a SpringTransition is capped at 150 ms. Use a SnapTransition for faster transitions');
        }

        //setup spring
        this.spring.setOptions({
            period : definition.period,
            dampingRatio : definition.dampingRatio
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
        _setAbsoluteRestTolerance();
    }

    /**
     * Resets the state and velocity
     *
     * @method reset
     *
     * @param {Number|Array.Number} state positional state
     * @param {Number|Array} velocity velocity
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
     * @return {Number|Array} velocity
     */
    public function getVelocity() {
        return _getParticleVelocity();
    }

    /**
     * Setter for velocity
     *
     * @method setVelocity
     *
     * @return {Number|Array} velocity
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
     * Get the current position of the transition
     *
     * @method get
     *
     * @return {Number|Array} state
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
     * @param  {Number|Array} endState Final state
     * @param {Object}  definition  Transition definition
     * @param  {Function} callback Callback
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