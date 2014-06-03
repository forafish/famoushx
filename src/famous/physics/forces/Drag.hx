package famous.physics.forces;

import famous.math.Vector;
import famous.physics.bodies.Body;
import famous.physics.forces.Force;

typedef DragOptions = {
	/**
	 * The strength of the force
	 *    Range : [0, 0.1]
	 * @attribute strength
	 * @type Number
	 * @default 0.01
	 */
	?strength : Float,

	/**
	 * The type of opposing force
	 * @attribute forceFunction
	 * @type Function
	 */
	?forceFunction : Vector -> Vector,
};

/**
 * Drag is a force that opposes velocity. Attach it to the physics engine
 * to slow down a physics body in motion.
 */
class Drag extends Force {

    /**
     * @property Drag.FORCE_FUNCTIONS
     * @type Object
     * @protected
     * @static
     */
    static public var FORCE_FUNCTIONS = {
        /**
         * A drag force proportional to the velocity
         * @attribute LINEAR
         * @type Function
         * @param {Vector} velocity
         * @return {Vector} drag force
         */
        LINEAR : function(velocity:Vector):Vector {
            return velocity;
        },

        /**
         * A drag force proportional to the square of the velocity
         * @attribute QUADRATIC
         * @type Function
         * @param {Vector} velocity
         * @return {Vector} drag force
         */
        QUADRATIC : function(velocity:Vector):Vector {
            return velocity.mult(velocity.norm());
        }
    };
	
    /**
     * @property Drag.DEFAULT_OPTIONS
     * @type Object
     * @protected
     * @static
     */
	static public var DEFAULT_OPTIONS:DragOptions = {
        strength : 0.01,
        forceFunction : Drag.FORCE_FUNCTIONS.LINEAR
    };
	
	
    /**
     * @constructor
     * @param {Object} options options to set on drag
     */
	public function new(?options:DragOptions) {
        this.options = Reflect.copy(Drag.DEFAULT_OPTIONS);
        if (options != null) this.setOptions(options);
		
        super();
	}
	
    /**
     * Adds a drag force to a physics body's force accumulator.
     *
     * @method applyForce
     * @param targets {Array.Body} Array of bodies to apply drag force to.
     */
    override public function applyForce(targets:Array<Body>, ?source:Body) {
        var strength        = this.options.strength;
        var forceFunction   = this.options.forceFunction;
        var force           = this.force;
        for (particle in targets) {
            forceFunction(particle.velocity).mult(-strength).put(force);
            particle.applyForce(force);
        }
    }	
	
}