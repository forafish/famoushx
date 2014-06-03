package famous.physics.integrators;

import famous.core.OptionsManager;
import famous.physics.bodies.Particle;
import famous.physics.bodies.Body;

typedef SymplecticEulerOptions = {
	/**
	 * The maximum velocity of a physics body
	 *      Range : [0, Infinity]
	 * @attribute velocityCap
	 * @type Number
	 */
	velocityCap : Null<Float>,

	/**
	 * The maximum angular velocity of a physics body
	 *      Range : [0, Infinity]
	 * @attribute angularVelocityCap
	 * @type Number
	 */
	angularVelocityCap : Null<Float>	
};

/**
 * Ordinary Differential Equation (ODE) Integrator.
 * Manages updating a physics body's state over time.
 *
 *  p = position, v = velocity, m = mass, f = force, dt = change in time
 *
 *      v <- v + dt * f / m
 *      p <- p + dt * v
 *
 *  q = orientation, w = angular velocity, L = angular momentum
 *
 *      L <- L + dt * t
 *      q <- q + dt/2 * q * w
 */
class SymplecticEuler {
	
    static public var DEFAULT_OPTIONS = {
        velocityCap : null,
        angularVelocityCap : null
    };
	
	var options:Dynamic;
	var _optionsManager:OptionsManager;
	
    /**
     * @constructor
     * @param {Object} options Options to set
     */
	public function new(?options:SymplecticEulerOptions) {
        this.options = Reflect.copy(SymplecticEuler.DEFAULT_OPTIONS);
        this._optionsManager = new OptionsManager(this.options);

        if (options != null) {
			this.setOptions(options);
		}
	}
	
    /*
     * Setter for options
     *
     * @method setOptions
     * @param {Object} options
     */
    public function setOptions(?options:SymplecticEulerOptions) {
        this._optionsManager.setOptions(options);
    }

    /*
     * Getter for options
     *
     * @method getOptions
     * @return {Object} options
     */
    public function getOptions() {
        return this._optionsManager.value();
    }

    /*
     * Updates the velocity of a physics body from its accumulated force.
     *      v <- v + dt * f / m
     *
     * @method integrateVelocity
     * @param {Body} physics body
     * @param {Number} dt delta time
     */
    public function integrateVelocity(body:Particle, dt:Float) {
        var v = body.velocity;
        var w = body.inverseMass;
        var f = body.force;

        if (f.isZero()) return;

        v.add(f.mult(dt * w)).put(v);
        f.clear();
    }

    /*
     * Updates the position of a physics body from its velocity.
     *      p <- p + dt * v
     *
     * @method integratePosition
     * @param {Body} physics body
     * @param {Number} dt delta time
     */
    public function integratePosition(body:Particle, dt:Float) {
        var p = body.position;
        var v = body.velocity;

        if (this.options.velocityCap) v.cap(this.options.velocityCap).put(v);
        p.add(v.mult(dt)).put(p);
    }

    /*
     * Updates the angular momentum of a physics body from its accumuled torque.
     *      L <- L + dt * t
     *
     * @method integrateAngularMomentum
     * @param {Body} physics body (except a particle)
     * @param {Number} dt delta time
     */
    public function integrateAngularMomentum(body:Body, dt:Float) {
        var L = body.angularMomentum;
        var t = body.torque;

        if (t.isZero()) return;

        if (this.options.angularVelocityCap != null) {
			t.cap(this.options.angularVelocityCap).put(t);
		}
        L.add(t.mult(dt)).put(L);
        t.clear();
    }

    /*
     * Updates the orientation of a physics body from its angular velocity.
     *      q <- q + dt/2 * q * w
     *
     * @method integrateOrientation
     * @param {Body} physics body (except a particle)
     * @param {Number} dt delta time
     */
    public function integrateOrientation(body:Body, dt:Float) {
        var q = body.orientation;
        var w = body.angularVelocity;

        if (w.isZero()) return;
        q.add(q.multiply(w).scalarMultiply(0.5 * dt)).put(q);
		//q.normalize.put(q);
    }
}