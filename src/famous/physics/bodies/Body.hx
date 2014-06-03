package famous.physics.bodies;

import famous.core.Transform;
import famous.math.Matrix;
import famous.math.Quaternion;
import famous.math.Vector;
import famous.physics.bodies.Particle;

typedef BodyOptions = {
	> ParticleOptions,
	?orientation:Array<Float>,
	?angularVelocity:Array<Float>,
	?angularMomentum:Dynamic,
	?torque:Dynamic,
}

/**
 * A unit controlled by the physics engine which extends the zero-dimensional
 * Particle to include geometry. In addition to maintaining the state
 * of a Particle its state includes orientation, angular velocity
 * and angular momentum and responds to torque forces.
 */
class Body extends Particle {

    static public var DEFAULT_OPTIONS = {
        orientation : [0,0,0,1],
        angularVelocity : [0,0,0],
    };
	
	public var orientation:Quaternion;
	public var angularVelocity:Vector;
	public var angularMomentum:Vector;
	public var torque:Vector;
	
	var pWorld:Vector;
	var inertia:Matrix;
	var inverseInertia:Matrix;
	
	/**
     * @class Body
     * @extends Particle
     * @constructor
     */	
	public function new(?options:BodyOptions) {
		super(options);
		options = options != null? options : {};
		
        this.orientation     = new Quaternion();
        this.angularVelocity = new Vector();
        this.angularMomentum = new Vector();
        this.torque          = new Vector();

        if (options.orientation != null) {
			this.orientation.set(options.orientation);
		}
        if (options.angularVelocity != null) {
			this.angularVelocity.set(options.angularVelocity);
		}
        if (options.angularMomentum != null) {
			this.angularMomentum.set(options.angularMomentum);
		}
        if (options.torque != null) {
			this.torque.set(options.torque);
		}

        this.setMomentsOfInertia();

        //this.angularVelocity.w = 0;        //quaternify the angular velocity

        //registers
        this.pWorld = new Vector();        //placeholder for world space position
		
		this.isBody = true;
	}
	
    override public function setMass(mass:Float) {
        super.setMass(mass);
        this.setMomentsOfInertia();
    }

    /**
     * Setter for moment of inertia, which is necessary to give proper
     * angular inertia depending on the geometry of the body.
     *
     * @method setMomentsOfInertia
     */
    public function setMomentsOfInertia() {
        this.inertia = new Matrix();
        this.inverseInertia = new Matrix();
    }

    /**
     * Update the angular velocity from the angular momentum state.
     *
     * @method updateAngularVelocity
     */
    public function updateAngularVelocity() {
        this.angularVelocity.set(this.inverseInertia.vectorMultiply(this.angularMomentum));
    }

    /**
     * Determine world coordinates from the local coordinate system. Useful
     * if the Body has rotated in space.
     *
     * @method toWorldCoordinates
     * @param localPosition {Vector} local coordinate vector
     * @return global coordinate vector {Vector}
     */
    public function toWorldCoordinates(localPosition:Vector) {
        return this.pWorld.set(this.orientation.rotateVector(localPosition));
    }

    /**
     * Calculates the kinetic and intertial energy of a body.
     *
     * @method getEnergy
     * @return energy {Number}
     */
    override public function getEnergy():Float {
        return super.getEnergy()
            + 0.5 * this.inertia.vectorMultiply(this.angularVelocity).dot(this.angularVelocity);
    }

    /**
     * Extends Particle.reset to reset orientation, angular velocity
     * and angular momentum.
     *
     * @method reset
     * @param [p] {Array|Vector} position
     * @param [v] {Array|Vector} velocity
     * @param [q] {Array|Quaternion} orientation
     * @param [L] {Array|Vector} angular momentum
     */
    override public function reset(p:Dynamic, v:Dynamic, ?q:Dynamic, ?L:Dynamic) {
        super.reset(p, v);
        this.angularVelocity.clear();
        this.setOrientation(q != null? q : [1,0,0,0]);
        this.setAngularMomentum(L != null? L : [0,0,0]);
    }

    /**
     * Setter for orientation
     *
     * @method setOrientation
     * @param q {Array|Quaternion} orientation
     */
    public function setOrientation(q:Dynamic) {
        this.orientation.set(q);
    }

    /**
     * Setter for angular velocity
     *
     * @method setAngularVelocity
     * @param w {Array|Vector} angular velocity
     */
    public function setAngularVelocity(w:Dynamic) {
        this.wake();
        this.angularVelocity.set(w);
    }

    /**
     * Setter for angular momentum
     *
     * @method setAngularMomentum
     * @param L {Array|Vector} angular momentum
     */
    public function setAngularMomentum(L:Dynamic) {
        this.wake();
        this.angularMomentum.set(L);
    }

    /**
     * Extends Particle.applyForce with an optional argument
     * to apply the force at an off-centered location, resulting in a torque.
     *
     * @method applyForce
     * @param force {Vector} force
     * @param [location] {Vector} off-center location on the body
     */
	override public function applyForce(force:Vector, ?location:Vector) {
        super.applyForce(force);
        if (location != null) this.applyTorque(location.cross(force));
    }

    /**
     * Applied a torque force to a body, inducing a rotation.
     *
     * @method applyTorque
     * @param torque {Vector} torque
     */
    public function applyTorque(torque:Vector) {
        this.wake();
        this.torque.set(this.torque.add(torque));
    }

    /**
     * Extends Particle.getTransform to include a rotational component
     * derived from the particle's orientation.
     *
     * @method getTransform
     * @return transform {Transform}
     */
    override public function getTransform():Matrix4 {
        return Transform.thenMove(
            this.orientation.getTransform(),
            Transform.getTranslate(super.getTransform())
        );
    }

    /**
     * Extends Particle._integrate to also update the rotational states
     * of the body.
     *
     * @method getTransform
     * @protected
     * @param dt {Number} delta time
     */
	override public function _integrate(dt:Float) {
        super._integrate(dt);
        this.integrateAngularMomentum(dt);
        this.updateAngularVelocity();
        this.integrateOrientation(dt);
    }

    /**
     * Updates the angular momentum via the its integrator.
     *
     * @method integrateAngularMomentum
     * @param dt {Number} delta time
     */
    public function integrateAngularMomentum(dt:Float) {
        Particle.INTEGRATOR.integrateAngularMomentum(this, dt);
    }

    /**
     * Updates the orientation via the its integrator.
     *
     * @method integrateOrientation
     * @param dt {Number} delta time
     */
    public function integrateOrientation(dt:Float) {
        Particle.INTEGRATOR.integrateOrientation(this, dt);
    }	
}