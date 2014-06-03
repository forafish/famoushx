package famous.physics.constraints;

import famous.math.Vector;
import famous.physics.bodies.Body;
import famous.physics.bodies.Particle;
import famous.physics.constraints.Constraint;

typedef DistanceOptions = {
	?anchor : Dynamic,
	?length : Int,
	?minLength : Int,
	?period : Int,
	?dampingRatio : Float
};

/**
 *  A constraint that keeps a physics body a given distance away from a given
 *  anchor, or another attached body.
 */
 class Distance extends Constraint {

	static public var DEFAULT_OPTIONS:DistanceOptions = {
        anchor : null,
        length : 0,
        minLength : 0,
        period : 0,
        dampingRatio : 0
    };
	
    /** @const */ var pi = Math.PI;

	var impulse:Vector;
	var normal:Vector;
	var diffP:Vector;
	var diffV:Vector;
		
    /**
     *  @constructor
     *  @extends Constraint
     *  @param {Options} [options] An object of configurable options.
     *  @param {Array} [options.anchor] The location of the anchor
     *  @param {Number} [options.length] The amount of distance from the anchor the constraint should enforce
     *  @param {Number} [options.minLength] The minimum distance before the constraint is activated. Use this property for a "rope" effect.
     *  @param {Number} [options.period] The spring-like reaction when the constraint is broken.
     *  @param {Number} [options.dampingRatio] The damping-like reaction when the constraint is broken.
     *
     */
 	public function new(?option:DistanceOptions) {
        this.options = Reflect.copy(Distance.DEFAULT_OPTIONS);
        if (options != null) this.setOptions(options);

        //registers
        this.impulse  = new Vector();
        this.normal   = new Vector();
        this.diffP    = new Vector();
        this.diffV    = new Vector();

        super();
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
            if (Std.is(options.anchor, Vector)) {
				this.options.anchor = options.anchor;
			}
            if (Std.is(options.anchor, Array)) {
				this.options.anchor = new Vector(options.anchor);
			}
        }
        if (options.length != null) this.options.length = options.length;
        if (options.dampingRatio != null) this.options.dampingRatio = options.dampingRatio;
        if (options.period != null) this.options.period = options.period;
        if (options.minLength != null) this.options.minLength = options.minLength;
    }
	
    function _calcError(impulse:Vector, body:Particle) {
        return body.mass * impulse.norm();
    }

    /**
     * Set the anchor position
     *
     * @method setOptions
     * @param anchor {Array}
     */
    public function setAnchor(anchor:Dynamic) {
        if (this.options.anchor == null) this.options.anchor = new Vector();
        this.options.anchor.set(anchor);
    }

    /**
     * Adds an impulse to a physics body's velocity due to the constraint
     *
     * @method applyConstraint
     * @param targets {Array.Body}  Array of bodies to apply the constraint to
     * @param source {Body}         The source of the constraint
     * @param dt {Number}           Delta time
     */
    override public function applyConstraint(targets:Array<Dynamic>, source:Dynamic, dt:Float) {
        var n        = this.normal;
        var diffP    = this.diffP;
        var diffV    = this.diffV;
        var impulse  = this.impulse;
        var options  = this.options;

        var dampingRatio = options.dampingRatio;
        var period       = options.period;
        var minLength    = options.minLength;

        var v2;
		var p2;
        var w2;

        if (source != null) {
            v2 = source.velocity;
            p2 = source.position;
            w2 = source.inverseMass;
        }
        else {
            p2 = this.options.anchor;
            w2 = 0;
        }

        var length = this.options.length;

        for (body in targets) {
            var v1 = body.velocity;
            var p1 = body.position;
            var w1 = body.inverseMass;

            diffP.set(p1.sub(p2));
            n.set(diffP.normalize());

            var dist = diffP.norm() - length;

            //rope effect
            if (Math.abs(dist) < minLength) return;

            if (source != null) diffV.set(v1.sub(v2));
            else diffV.set(v1);

            var effMass = 1 / (w1 + w2);
            var gamma:Float;
            var beta:Float;

            if (period == 0) {
                gamma = 0;
                beta  = 1;
            }
            else {
                var c = 4 * effMass * pi * dampingRatio / period;
                var k = 4 * effMass * pi * pi / (period * period);

                gamma = 1 / (c + dt*k);
                beta  = dt*k / (c + dt*k);
            }

            var antiDrift = beta/dt * dist;
            var lambda    = -(n.dot(diffV) + antiDrift) / (gamma + dt/effMass);

            impulse.set(n.mult(dt*lambda));
            body.applyImpulse(impulse);

            if (source != null) {
				source.applyImpulse(impulse.mult(-1));
			}
        }
    }	
}