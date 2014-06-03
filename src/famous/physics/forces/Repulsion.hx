package famous.physics.forces;

import famous.math.Vector;
import famous.physics.bodies.Body;
import famous.physics.forces.Force;

typedef RepulsionOptions = {
	/**
	 * The strength of the force
	 *    Range : [0, 100]
	 * @attribute strength
	 * @type Number
	 * @default 1
	 */
	?strength : Float,

	/**
	 * The location of the force, if not another physics body
	 *
	 * @attribute anchor
	 * @type Number
	 * @default 0.01
	 * @optional
	 */
	?anchor : Float,

	/**
	 * The range of the repulsive force
	 * @attribute radii
	 * @type Array
	 * @default [0, Infinity]
	 */
	?range : Array<Float>,

	/**
	 * A normalization for the force to avoid singularities at the origin
	 * @attribute cutoff
	 * @type Number
	 * @default 0
	 */
	?cutoff : Float,

	/**
	 * The maximum magnitude of the force
	 *    Range : [0, Infinity]
	 * @attribute cap
	 * @type Number
	 * @default Infinity
	 */
	?cap : Float,

	/**
	 * The type of decay the repulsive force should have
	 * @attribute decayFunction
	 * @type Function
	 */
	?decayFunction : Float -> Float -> Float,
};

/**
 *  Repulsion is a force that repels (attracts) bodies away (towards)
 *    each other. A repulsion of negative strength is attractive.
 */
class Repulsion extends Force {

    /**
     * @property Drag.FORCE_FUNCTIONS
     * @type Object
     * @protected
     * @static
     */
    static public var DECAY_FUNCTIONS = {
        /**
         * A linear decay function
         * @attribute LINEAR
         * @type Function
         * @param {Number} r distance from the source body
         * @param {Number} cutoff the effective radius of influence
         */
        LINEAR : function(r:Float, cutoff:Float):Float {
            return Math.max(1 - (1 / cutoff) * r, 0);
        },

        /**
         * A Morse potential decay function (http://en.wikipedia.org/wiki/Morse_potential)
         * @attribute MORSE
         * @type Function
         * @param {Number} r distance from the source body
         * @param {Number} cutoff the minimum radius of influence
         */
        MORSE : function(r:Float, cutoff:Float):Float {
            var r0 = (cutoff == 0) ? 100 : cutoff;
            var rShifted = r + r0 * (1 - Math.log(2)); //shift by x-intercept
            return Math.max(1 - Math.pow(1 - Math.exp(rShifted/r0 - 1), 2), 0);
        },

        /**
         * An inverse distance decay function
         * @attribute INVERSE
         * @type Function
         * @param {Number} r distance from the source body
         * @param {Number} cutoff a distance shift to avoid singularities
         */
        INVERSE : function(r:Float, cutoff:Float):Float {
            return 1 / (1 - cutoff + r);
        },

        /**
         * An inverse squared distance decay function
         * @attribute INVERSE
         * @type Function
         * @param {Number} r distance from the source body
         * @param {Number} cutoff a distance shift to avoid singularities
         */
        GRAVITY : function(r:Float, cutoff:Float) {
            return 1 / (1 - cutoff + r*r);
        }
    };
	
    /**
     * @property Drag.DEFAULT_OPTIONS
     * @type Object
     * @protected
     * @static
     */
	static public var DEFAULT_OPTIONS:RepulsionOptions = {
        strength : 1,
        anchor : null,
        range : [0, Math.POSITIVE_INFINITY],
        cutoff : 0,
        cap : Math.POSITIVE_INFINITY,
        decayFunction : Repulsion.DECAY_FUNCTIONS.GRAVITY
    };
	
	var disp:Vector;
	
    /**
     *  @constructor
     *  @param {Object} options overwrites default options
     */
	public function new(?options:RepulsionOptions) {
        this.options = Reflect.copy(Repulsion.DEFAULT_OPTIONS);
        if (options != null) this.setOptions(options);
		
		//registers
        this.disp  = new Vector();
		
        super();
	}
	
    /*
     * Setter for options.
     *
     * @method setOptions
     * @param {Objects} options
     */
    override public function setOptions(options:Dynamic) {
        if (options.anchor != null) {
            if (Std.is(options.anchor.position, Vector)) {
				this.options.anchor = options.anchor.position;
			}
            if (Std.is(options.anchor, Array)) {
				this.options.anchor = new Vector(options.anchor);
			}
            Reflect.deleteField(options, "anchor");
        }
        super.setOptions(options);
    }

    /**
     * Adds a drag force to a physics body's force accumulator.
     *
     * @method applyForce
     * @param targets {Array.Body}  Array of bodies to apply force to
     * @param source {Body}         The source of the force
     */
    override public function applyForce(targets:Array<Body>, ?source:Body) {
        var options     = this.options;
        var force       = this.force;
        var disp        = this.disp;

        var strength    = options.strength;
        var anchor      = options.anchor != null? options.anchor : source.position;
        var cap         = options.cap;
        var cutoff      = options.cutoff;
        var rMin        = options.range[0];
        var rMax        = options.range[1];
        var decayFn     = options.decayFunction;

        if (strength == 0) return;

        for (particle in targets) {
            if (particle == source) continue;

            var m1 = particle.mass;
            var p1 = particle.position;

            disp.set(p1.sub(anchor));
            var r = disp.norm();

            if (r < rMax && r > rMin) {
                force.set(disp.normalize(strength * m1 * decayFn(r, cutoff)).cap(cap));
                particle.applyForce(force);
            }
        }
    }
	
}