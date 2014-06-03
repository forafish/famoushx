package famous.physics.forces;

import famous.math.Vector;
import famous.physics.bodies.Particle;
import famous.physics.bodies.Body;
import famous.physics.forces.Force;

typedef SpringOptions = {
	/**
	 * The amount of time in milliseconds taken for one complete oscillation
	 * when there is no damping
	 *    Range : [150, Infinity]
	 * @attribute period
	 * @type Number
	 * @default 300
	 */
	?period        : Float,

	/**
	 * The damping of the spring.
	 *    Range : [0, 1]
	 *    0 = no damping, and the spring will oscillate forever
	 *    1 = critically damped (the spring will never oscillate)
	 * @attribute dampingRatio
	 * @type Number
	 * @default 0.1
	 */
	?dampingRatio : Float,

	/**
	 * The rest length of the spring
	 *    Range : [0, Infinity]
	 * @attribute length
	 * @type Number
	 * @default 0
	 */
	?length : Float,

	/**
	 * The maximum length of the spring (for a FENE spring)
	 *    Range : [0, Infinity]
	 * @attribute length
	 * @type Number
	 * @default Infinity
	 */
	?maxLength : Float,

	/**
	 * The location of the spring's anchor, if not another physics body
	 *
	 * @attribute anchor
	 * @type Array
	 * @optional
	 */
	?anchor : Dynamic, // {position: Vector} or Vector or Array<Float>,

	/**
	 * The type of spring force
	 * @attribute forceFunction
	 * @type Function
	 */
	?forceFunction : Float -> ?Float -> Float,
};

/**
 *  A force that moves a physics body to a location with a spring motion.
 *    The body can be moved to another physics body, or an anchor point.
 */
class Spring extends Force {
    /** @const */ var pi = Math.PI;

    /**
     * @property Spring.FORCE_FUNCTIONS
     * @type Object
     * @protected
     * @static
     */
    static public var FORCE_FUNCTIONS = {

        /**
         * A FENE (Finitely Extensible Nonlinear Elastic) spring force
         *      see: http://en.wikipedia.org/wiki/FENE
         * @attribute FENE
         * @type Function
         * @param {Number} dist current distance target is from source body
         * @param {Number} rMax maximum range of influence
         * @return {Number} unscaled force
         */
        FENE : function(dist:Float, ?rMax:Float):Float {
            var rMaxSmall = rMax * .99;
            var r = Math.max(Math.min(dist, rMaxSmall), -rMaxSmall);
            return r / (1 - r * r/(rMax * rMax));
        },

        /**
         * A Hookean spring force, linear in the displacement
         *      see: http://en.wikipedia.org/wiki/FENE
         * @attribute FENE
         * @type Function
         * @param {Number} dist current distance target is from source body
         * @return {Number} unscaled force
         */
        HOOK : function(dist:Float, ?rMax:Float):Float {
            return dist;
        }
    };
	
    /**
     * @property Drag.DEFAULT_OPTIONS
     * @type Object
     * @protected
     * @static
     */
	static public var DEFAULT_OPTIONS:SpringOptions = {
        period : 300,
        dampingRatio : 0.1,
        length : 0,
        maxLength : Math.POSITIVE_INFINITY,
        anchor : null,
        forceFunction : Spring.FORCE_FUNCTIONS.HOOK
    };
	
	var disp:Vector;
	var forceFunction:Float -> ?Float -> Float;
	
    /**
     *  @constructor
     *  @param {Object} options options to set on drag
     */
	public function new(?options:SpringOptions) {
        this.options = Reflect.copy(Spring.DEFAULT_OPTIONS);
        if (options != null) this.setOptions(options);
		
		//registers
        this.disp  = new Vector(0, 0, 0);
		
        _init();
		
        super();
	}
	
    function _setForceFunction(fn) {
        this.forceFunction = fn;
    }

    function _calcStiffness() {
        var options = this.options;
        options.stiffness = Math.pow(2 * pi / options.period, 2);
    }

    function _calcDamping() {
        var options = this.options;
        options.damping = 4 * pi * options.dampingRatio / options.period;
    }

    function _calcEnergy(strength:Float, dist:Float):Float {
        return 0.5 * strength * dist * dist;
    }

    function _init() {
        _setForceFunction(this.options.forceFunction);
        _calcStiffness();
        _calcDamping();
    }

    /**
     * Basic options setter
     *
     * @method setOptions
     * @param options {Objects}
     */
    override public function setOptions(options:Dynamic) {
        if (options.anchor != null) {
            if (Std.is(options.anchor.position, Vector)) {
				this.options.anchor = options.anchor.position;
			}
            if (Std.is(options.anchor, Vector))  {
				this.options.anchor = options.anchor;
			}
            if (Std.is(options.anchor, Array))  {
				this.options.anchor = new Vector(options.anchor);
			}
        }
		if (this.options.anchor.y > 0) {
			var a = 1;
			var b = 2;
		}
        if (options.period != null) this.options.period = options.period;
        if (options.dampingRatio != null) this.options.dampingRatio = options.dampingRatio;
        if (options.length != null) this.options.length = options.length;
        if (options.forceFunction != null) this.options.forceFunction = options.forceFunction;
        if (options.maxLength != null) this.options.maxLength = options.maxLength;

        _init();
    }

    /**
     * Adds a drag force to a physics body's force accumulator.
     *
     * @method applyForce
     * @param targets {Array.Body}  Array of bodies to apply force to
     * @param source {Body}         The source of the force
     */
    override public function applyForce(targets:Array<Body>, ?source:Body) {
        var force        = this.force;
        var disp         = this.disp;
        var options      = this.options;

        var stiffness:Float = options.stiffness;
        var damping:Float	= options.damping;
        var restLength   	= options.length;
        var lMax         	= options.maxLength;
        var anchor       	= options.anchor != null? options.anchor : source.position;

        for (target in targets) {
            var p2 = target.position;
            var v2 = target.velocity;

            anchor.sub(p2).put(disp);
            var dist = disp.norm() - restLength;

            if (dist == 0) return;

            //if dampingRatio specified, then override strength and damping
            var m      = target.mass;
            stiffness *= m;
            damping   *= m;

            disp.normalize(stiffness * this.forceFunction(dist, lMax))
                .put(force);

            if (damping != 0) {
                if (source != null) force.add(v2.sub(source.velocity).mult(-damping)).put(force);
                else force.add(v2.mult(-damping)).put(force);
			}
			
            target.applyForce(force);
            if (source != null) source.applyForce(force.mult(-1));

            this.setEnergy(_calcEnergy(stiffness, dist));
        }
    }
	
    /**
     * Calculates the potential energy of the spring.
     *
     * @method getEnergy
     * @param target {Body}     The physics body attached to the spring
     * @return energy {Number}
     */
	override public function getEnergy(?target:Particle) {
        var options     = this.options;
        var restLength  = options.length;
        var anchor      = options.anchor;
        var strength    = options.stiffness;
		
		var c = Spring.DEFAULT_OPTIONS;
        var dist = anchor.sub(target.position).norm() - restLength;
        return 0.5 * strength * dist * dist;
    }

    /**
     * Sets the anchor to a new position
     *
     * @method setAnchor
     * @param anchor {Array}    New anchor of the spring
     */
    public function setAnchor(anchor:Array<Float>) {
        if (this.options.anchor == null) this.options.anchor = new Vector();
        this.options.anchor.set(anchor);
    }	
	
}