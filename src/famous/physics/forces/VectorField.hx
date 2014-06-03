package famous.physics.forces;

import famous.math.Vector;
import famous.physics.bodies.Body;
import famous.physics.forces.Force;

typedef VectorFieldOptions = {
	/**
	 * The strength of the force
	 *    Range : [0, 10]
	 * @attribute strength
	 * @type Number
	 * @default 1
	 */
	?strength : Float,

	/**
	 * Type of vectorfield
	 *    Range : [0, 100]
	 * @attribute field
	 * @type Function
	 */
	?field : Vector -> Dynamic -> Vector
};

/**
 *  A force that moves a physics body to a location with a spring motion.
 *    The body can be moved to another physics body, or an anchor point.
 */
class VectorField extends Force {

    /**
     * @property Spring.FORCE_FUNCTIONS
     * @type Object
     * @protected
     * @static
     */
    static public var FIELDS = {
        /**
         * Constant force, e.g., gravity
         * @attribute CONSTANT
         * @type Function
         * @param v {Vector}        Current position of physics body
         * @param options {Object}  The direction of the force
         *      Pass a {direction : Vector} into the VectorField options
         * @return {Number} unscaled force
         */
        CONSTANT : function(v:Vector, options:Dynamic):Vector {
            return v.set(options.direction);
        },

        /**
         * Linear force
         * @attribute LINEAR
         * @type Function
         * @param v {Vector} Current position of physics body
         * @return {Number} unscaled force
         */
        LINEAR : function(v:Vector, ?options:Dynamic):Vector {
            return v;
        },

        /**
         * Radial force, e.g., Hookean spring
         * @attribute RADIAL
         * @type Function
         * @param v {Vector} Current position of physics body
         * @return {Number} unscaled force
         */
        RADIAL : function(v:Vector, ?options:Dynamic):Vector {
            return v.set(v.mult(-1));
        },

        /**
         * Spherical force
         * @attribute SPHERE_ATTRACTOR
         * @type Function
         * @param v {Vector}        Current position of physics body
         * @param options {Object}  An object with the radius of the sphere
         *      Pass a {radius : Number} into the VectorField options
         * @return {Number} unscaled force
         */
        SPHERE_ATTRACTOR : function(v:Vector, ?options:Dynamic):Vector {
            return v.set(v.mult((options.radius - v.norm()) / v.norm()));
        },

        /**
         * Point attractor force, e.g., Hookean spring with an anchor
         * @attribute POINT_ATTRACTOR
         * @type Function
         * @param v {Vector}        Current position of physics body
         * @param options {Object}  And object with the position of the attractor
         *      Pass a {position : Vector} into the VectorField options
         * @return {Number} unscaled force
         */
        POINT_ATTRACTOR : function(v:Vector, ?options:Dynamic):Vector {
            return v.set(options.position.sub(v));
        }
    };
	
    /**
     * @property Drag.DEFAULT_OPTIONS
     * @type Object
     * @protected
     * @static
     */
	static public var DEFAULT_OPTIONS:VectorFieldOptions = {
        strength : 1,
        field : VectorField.FIELDS.CONSTANT
    };
	
	var evaluation:Vector;
		
	/**
	 *  @constructor
	 *  @param {Object} options options to set on drag
	 */
	public function new(?options:VectorFieldOptions) {
        this.options = Reflect.copy(VectorField.DEFAULT_OPTIONS);
        if (options != null) this.setOptions(options);
		
        _setFieldOptions(this.options.field);
        super();

        //registers
        this.evaluation = new Vector(0,0,0);
	}
	
    function _setFieldOptions(field) {
        var FIELDS = VectorField.FIELDS;

        if (field == FIELDS.CONSTANT) {
            if (this.options.direction == null) this.options.direction = new Vector(0, 1, 0);
		}
        else if (field == FIELDS.POINT_ATTRACTOR) {
            if (this.options.position == null) this.options.position = new Vector(0, 0, 0);
		}
		else if (field == FIELDS.SPHERE_ATTRACTOR) {
            if (this.options.radius == null) this.options.radius = 1;
        }
    }

    function _evaluate(v) {
        var evaluation = this.evaluation;
        var field = this.options.field;
        evaluation.set(v);
        return field(evaluation, this.options);
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