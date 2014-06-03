package famous.physics.constraints;

import famous.math.Vector;
import famous.physics.bodies.Body;
import famous.physics.bodies.Particle;
import famous.physics.constraints.Constraint;

typedef CurveOptions = {
	?equation: Float -> Float -> Float -> Float,
	?plane : Float -> Float -> Float -> Float,
	?period : Int,
	?dampingRatio : Float,
};

/**
 *  A constraint that keeps a physics body on a given implicit curve
 *    regardless of other physical forces are applied to it.
 *
 *    A curve constraint is two surface constraints in disguise, as a curve is
 *    the intersection of two surfaces, and is essentially constrained to both
 */
class Curve extends Constraint {

	static public var DEFAULT_OPTIONS:CurveOptions = {
        equation  : function(x,y,z) {
            return 0;
        },
        plane : function(x,y,z) {
            return z;
        },
        period : 0,
        dampingRatio : 0
    };
	
    /** @const */ var epsilon = 1e-7;
    /** @const */ var pi = Math.PI;

	var J:Vector;
	var impulse:Vector;
		
    /**
     *  @constructor
     *  @extends Constraint
     *  @param {Options} [options] An object of configurable options.
     *  @param {Function} [options.equation] An implicitly defined surface f(x,y,z) = 0 that body is constrained to e.g. function(x,y,z) { x*x + y*y - r*r } corresponds to a circle of radius r pixels
     *  @param {Function} [options.plane] An implicitly defined second surface that the body is constrained to
     *  @param {Number} [options.period] The spring-like reaction when the constraint is violated
     *  @param {Number} [options.number] The damping-like reaction when the constraint is violated
     */
	public function new(?option:CurveOptions) {
        this.options = Reflect.copy(Curve.DEFAULT_OPTIONS);
        if (options != null) this.setOptions(options);

        //registers
        this.J = new Vector();
        this.impulse = new Vector();

        super();
	}
	
    /**
     * Adds a curve impulse to a physics body.
     *
     * @method applyConstraint
     * @param targets {Array.Body} Array of bodies to apply force to.
     * @param source {Body} Not applicable
     * @param dt {Number} Delta time
     */
    override public function applyConstraint(targets:Array<Dynamic>, source:Dynamic, dt:Float) {
        var options = this.options;
        var impulse = this.impulse;
        var J = this.J;

        var f = options.equation;
        var g = options.plane;
        var dampingRatio = options.dampingRatio;
        var period = options.period;

        for (body in targets) {
            var v = body.velocity;
            var p = body.position;
            var m = body.mass;

            var gamma:Float;
            var beta:Float;

            if (period == 0) {
                gamma = 0;
                beta = 1;
            }
            else {
                var c = 4 * m * pi * dampingRatio / period;
                var k = 4 * m * pi * pi / (period * period);

                gamma = 1 / (c + dt*k);
                beta  = dt*k / (c + dt*k);
            }

            var x:Float = p.x;
            var y:Float = p.y;
            var z:Float = p.z;

            var f0  = f(x, y, z);
            var dfx = (f(x + epsilon, y, z) - f0) / epsilon;
            var dfy = (f(x, y + epsilon, z) - f0) / epsilon;
            var dfz = (f(x, y, z + epsilon) - f0) / epsilon;

            var g0  = g(x, y, z);
            var dgx = (g(x + epsilon, y, z) - g0) / epsilon;
            var dgy = (g(x, y + epsilon, z) - g0) / epsilon;
            var dgz = (g(x, y, z + epsilon) - g0) / epsilon;

            J.setXYZ(dfx + dgx, dfy + dgy, dfz + dgz);

            var antiDrift = beta/dt * (f0 + g0);
            var lambda = -(J.dot(v) + antiDrift) / (gamma + dt * J.normSquared() / m);

            impulse.set(J.mult(dt*lambda));
            body.applyImpulse(impulse);
        }
    }	
}