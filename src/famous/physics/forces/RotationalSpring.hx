package famous.physics.forces;

import famous.math.Vector;
import famous.physics.bodies.Body;
import famous.physics.forces.Force;
import famous.physics.forces.Spring;

/**
 *  A force that rotates a physics body back to target Euler angles.
 *  Just as a spring translates a body to a particular X, Y, Z, location,
 *  a rotational spring rotates a body to a particular X, Y, Z Euler angle.
 *      Note: there is no physical agent that does this in the "real world"
 */
class RotationalSpring extends Spring {
	/**
	 *  @constructor
	 *  @param {Object} options options to set on drag
	 */
	public function new(?options:SpringOptions) {
        super();
	}
	
    /**
     * Adds a rotational drag force to a physics body's torque accumulator.
     *
     * @method applyForce
     * @param targets {Array.Body} Array of bodies to apply drag force to.
     */
    override public function applyForce(targets:Array<Body>, ?source:Body) {
        var force        = this.force;
        var options      = this.options;
        var disp         = this.disp;

        var stiffness:Float = options.stiffness;
        var damping:Float   = options.damping;
        var restLength   	= options.length;
        var anchor     		= options.anchor;

        for (target in targets) {
            disp.set(anchor.sub(target.orientation));
            var dist = disp.norm() - restLength;

            if (dist == 0) return;

            //if dampingRatio specified, then override strength and damping
            var m      = target.mass;
            stiffness *= m;
            damping   *= m;

            force.set(disp.normalize(stiffness * this.forceFunction(dist, this.options.lMax)));

            if (damping != 0) {
				force.set(force.add(target.angularVelocity.mult(-damping)));
			}

            target.applyTorque(force);
        }
	}	
	
    /**
     * Calculates the potential energy of the rotational spring.
     *
     * @method getEnergy
     * @param {Body} target The physics body attached to the spring
     */
    override public function getEnergy(?target:Body) {
        var options     = this.options;
        var restLength  = options.length;
        var anchor      = options.anchor;
        var strength    = options.stiffness;
		
        var dist = anchor.sub(target.orientation).norm() - restLength;
        return 0.5 * strength * dist * dist;
    };

}