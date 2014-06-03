package famous.physics.forces;

import famous.math.Vector;
import famous.physics.bodies.Body;
import famous.physics.forces.Force;
import famous.physics.forces.Drag;

/**
 * Rotational drag is a force that opposes angular velocity.
 *   Attach it to a physics body to slow down its rotation.
 */
class RotationalDrag extends Drag {
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
     * Adds a rotational drag force to a physics body's torque accumulator.
     *
     * @method applyForce
     * @param targets {Array.Body} Array of bodies to apply drag force to.
     */
    override public function applyForce(targets:Array<Body>, ?source:Body) {
        var strength       = this.options.strength;
        var forceFunction  = this.options.forceFunction;
        var force          = this.force;

        //TODO: rotational drag as function of inertia
        for (particle in targets) {
            forceFunction(particle.angularVelocity).mult(-100*strength).put(force);
            particle.applyTorque(force);
        }
    }	
	
}