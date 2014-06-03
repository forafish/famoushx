package famous.physics.constraints;

import famous.math.Vector;
import famous.physics.bodies.Body;
import famous.physics.bodies.Particle;
import famous.physics.constraints.Constraint;

typedef SnapOptions = {
	?period : Int,
	?dampingRatio : Float,
	?length: Int,
	?anchor :Dynamic,
};

/**
 *  A spring constraint is like a spring force, except that it is always
 *    numerically stable (even for low periods), at the expense of introducing
 *    damping (even with dampingRatio set to 0).
 *
 *    Use this if you need fast spring-like behavior, e.g., snapping
 */
class Snap extends Constraint {

	static public var DEFAULT_OPTIONS:SnapOptions = {
        period        : 300,
        dampingRatio : 0.1,
        length : 0,
        anchor : null
    };
	
    /** const */ var pi = Math.PI;

	var pDiff:Vector;
	var vDiff:Vector;
	var impulse1:Vector;
	var impulse2:Vector;
		
    /**
     *  @constructor
     *  @extends Constraint
     *  @param {Options} [options] An object of configurable options.
     *  @param {Number} [options.period] The amount of time in milliseconds taken for one complete oscillation when there is no damping. Range : [150, Infinity]
     *  @param {Number} [options.dampingRatio] Additional damping of the spring. Range : [0, 1]. At 0 this spring will still be damped, at 1 the spring will be critically damped (the spring will never oscillate)
     *  @param {Number} [options.length] The rest length of the spring. Range: [0, Infinity].
     *  @param {Array} [options.anchor] The location of the spring's anchor, if not another physics body.
     *
     */
	public function new(?option:SnapOptions) {
        this.options = Reflect.copy(Snap.DEFAULT_OPTIONS);
        if (options != null) this.setOptions(options);

        //registers
        this.pDiff  = new Vector();
        this.vDiff  = new Vector();
        this.impulse1 = new Vector();
        this.impulse2 = new Vector();

        super();
	}
	
    function _calcEnergy(impulse:Vector, disp:Vector, dt:Float) {
        return Math.abs(impulse.dot(disp)/dt);
    }

    /**
     * Basic options setter
     *
     * @method setOptions
     * @param options {Objects} options
     */
    override public function setOptions(options:Dynamic) {
        if (options.anchor != null) {
            if (Std.is(options.anchor, Vector)) {
				this.options.anchor = options.anchor;
			}
            if (Std.is(options.anchor.position, Vector)) {
				this.options.anchor = options.anchor.position;
			}
            if (Std.is(options.anchor, Array)) {
				this.options.anchor = new Vector(options.anchor);
			}
        }
        if (options.length != null) this.options.length = options.length;
        if (options.dampingRatio != null) this.options.dampingRatio = options.dampingRatio;
        if (options.period != null) this.options.period = options.period;
    }

    /**
     * Set the anchor position
     *
     * @method setOptions
     * @param {Array} v TODO
     */
    public function setAnchor(v:Vector) {
        if (this.options.anchor != null) this.options.anchor = new Vector();
        this.options.anchor.set(v);
    }

    /**
     * Calculates energy of spring
     *
     * @method getEnergy
     * @param {Object} target TODO
     * @param {Object} source TODO
     * @return energy {Number}
     */
    override public function getEnergy(target:Dynamic, source:Dynamic) {
        var options     = this.options;
        var restLength  = options.length;
        var anchor      = options.anchor != null? options.anchor : source.position;
        var strength    = Math.pow(2 * pi / options.period, 2);

        var dist = anchor.sub(target.position).norm() - restLength;

        return 0.5 * strength * dist * dist;
    };

    /**
     * Adds a spring impulse to a physics body's velocity due to the constraint
     *
     * @method applyConstraint
     * @param targets {Array.Body}  Array of bodies to apply the constraint to
     * @param source {Body}         The source of the constraint
     * @param dt {Number}           Delta time
     */
    override public function applyConstraint(targets:Array<Dynamic>, source:Dynamic, dt:Float) {
        var options         = this.options;
        var pDiff        = this.pDiff;
        var vDiff        = this.vDiff;
        var impulse1     = this.impulse1;
        var impulse2     = this.impulse2;
        var length       = options.length;
        var anchor       = options.anchor || source.position;
        var period       = options.period;
        var dampingRatio = options.dampingRatio;

        for (target in targets) {
            var p1 = target.position;
            var v1 = target.velocity;
            var m1 = target.mass;
            var w1 = target.inverseMass;

            pDiff.set(p1.sub(anchor));
            var dist = pDiff.norm() - length;
            var effMass;

            if (source != null) {
                var w2 = source.inverseMass;
                var v2 = source.velocity;
                vDiff.set(v1.sub(v2));
                effMass = 1/(w1 + w2);
            }
            else {
                vDiff.set(v1);
                effMass = m1;
            }

            var gamma:Float;
            var beta:Float;

            if (this.options.period == 0) {
                gamma = 0;
                beta = 1;
            }
            else {
                var k = 4 * effMass * pi * pi / (period * period);
                var c = 4 * effMass * pi * dampingRatio / period;

                beta  = dt * k / (c + dt * k);
                gamma = 1 / (c + dt*k);
            }

            var antiDrift = beta/dt * dist;
            pDiff.normalize(-antiDrift)
                .sub(vDiff)
                .mult(dt / (gamma + dt/effMass))
                .put(impulse1);

            // var n = new Vector();
            // n.set(pDiff.normalize());
            // var lambda = -(n.dot(vDiff) + antiDrift) / (gamma + dt/effMass);
            // impulse2.set(n.mult(dt*lambda));

            target.applyImpulse(impulse1);

            if (source != null) {
                impulse1.mult(-1).put(impulse2);
                source.applyImpulse(impulse2);
            }

            this.setEnergy(_calcEnergy(impulse1, pDiff, dt));
        }
    }	
}