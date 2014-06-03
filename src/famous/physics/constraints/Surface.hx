package famous.physics.constraints;

import famous.math.Vector;
import famous.physics.bodies.Body;
import famous.physics.bodies.Particle;
import famous.physics.constraints.Constraint;

typedef SurfaceOptions = {
	?equation: Float -> Float -> Float -> Float,
	?period : Int,
	?dampingRatio : Float,
};

/**
 *  A constraint that keeps a physics body on a given implicit surface
 *    regardless of other physical forces are applied to it.
 */
class Surface extends Constraint {

	static public var DEFAULT_OPTIONS:SurfaceOptions = {
        equation  : null,
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
     *  @param {Function} [options.equation] An implicitly defined surface f(x,y,z) = 0 that body is constrained to e.g. function(x,y,z) { x*x + y*y + z*z - r*r } corresponds to a sphere of radius r pixels.
     *  @param {Number} [options.period] The spring-like reaction when the constraint is violated.
     *  @param {Number} [options.dampingRatio] The damping-like reaction when the constraint is violated.
     */
	public function new(?option:SurfaceOptions) {
        this.options = Reflect.copy(Surface.DEFAULT_OPTIONS);
        if (options != null) this.setOptions(options);

        //registers
        this.J = new Vector();
        this.impulse = new Vector();

        super();
	}
	
    /**
     * Adds a surface impulse to a physics body.
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
        var dampingRatio = options.dampingRatio;
        var period = options.period;

        for (particle in targets) {
            var v = particle.velocity;
            var p = particle.position;
            var m = particle.mass;

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

            var x = p.x;
            var y = p.y;
            var z = p.z;

            var f0  = f(x, y, z);
            var dfx = (f(x + epsilon, y, z) - f0) / epsilon;
            var dfy = (f(x, y + epsilon, z) - f0) / epsilon;
            var dfz = (f(x, y, z + epsilon) - f0) / epsilon;
            J.setXYZ(dfx, dfy, dfz);

            var antiDrift = beta/dt * f0;
            var lambda = -(J.dot(v) + antiDrift) / (gamma + dt * J.normSquared() / m);

            impulse.set(J.mult(dt*lambda));
            particle.applyImpulse(impulse);
        }
    }	
}