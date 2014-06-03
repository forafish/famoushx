package famous.physics.constraints;

import famous.math.Vector;
import famous.physics.bodies.Body;
import famous.physics.bodies.Particle;
import famous.physics.constraints.Constraint;

typedef CollisionOptions = {
	?restitution : Float,
	?drift : Float,
	?slop : Float,
};

/**
 *  Allows for two circular bodies to collide and bounce off each other.
 */
class Collision extends Constraint {

	static public var DEFAULT_OPTIONS:CollisionOptions = {
        restitution : 0.5,
        drift : 0.5,
        slop : 0
    };
	
	public var normal:Vector;
	public var pDiff:Vector;
	public var vDiff:Vector;
	public var impulse1:Vector;
	public var impulse2:Vector;
	
    /**
     *  @constructor
     *  @extends Constraint
     *  @param {Options} [options] An object of configurable options.
     *  @param {Number} [options.restitution] The energy ratio lost in a collision (0 = stick, 1 = elastic) Range : [0, 1]
     *  @param {Number} [options.drift] Baumgarte stabilization parameter. Makes constraints "loosely" (0) or "tightly" (1) enforced. Range : [0, 1]
     *  @param {Number} [options.slop] Amount of penetration in pixels to ignore before collision event triggers
     *
     */
	public function new(options:CollisionOptions) {
		this.options = Reflect.copy(Collision.DEFAULT_OPTIONS);
        if (options != null) this.setOptions(options);
		
        //registers
        this.normal   = new Vector();
        this.pDiff    = new Vector();
        this.vDiff    = new Vector();
        this.impulse1 = new Vector();
        this.impulse2 = new Vector();

        super();
	}
	
    function _normalVelocity(particle1:Particle, particle2:Particle) {
        return particle1.velocity.dot(particle2.velocity);
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
        if (source == null) return;

        var v1 = source.velocity;
        var p1 = source.position;
        var w1 = source.inverseMass;
        var r1 = source.radius;

        var options = this.options;
        var drift = options.drift;
        var slop = -options.slop;
        var restitution = options.restitution;

        var n     = this.normal;
        var pDiff = this.pDiff;
        var vDiff = this.vDiff;
        var impulse1 = this.impulse1;
        var impulse2 = this.impulse2;

        for (target in targets) {
            if (target == source) continue;

            var v2 = target.velocity;
            var p2 = target.position;
            var w2 = target.inverseMass;
            var r2 = target.radius;

            pDiff.set(p2.sub(p1));
            vDiff.set(v2.sub(v1));

            var dist    = pDiff.norm();
            var overlap = dist - (r1 + r2);
            var effMass = 1/(w1 + w2);
            var gamma   = 0;

            if (overlap < 0) {

                n.set(pDiff.normalize());

				var collisionData = {
					target  : target,
					source  : source,
					overlap : overlap,
					normal  : n
				};

                if (this._eventOutput != null) {
                    this._eventOutput.emit('preCollision', collisionData);
                    this._eventOutput.emit('collision', collisionData);
                }

                var lambda = (overlap <= slop)
                    ? ((1 + restitution) * n.dot(vDiff) + drift/dt * (overlap - slop)) / (gamma + dt/effMass)
                    : ((1 + restitution) * n.dot(vDiff)) / (gamma + dt/effMass);

                n.mult(dt*lambda).put(impulse1);
                impulse1.mult(-1).put(impulse2);

                source.applyImpulse(impulse1);
                target.applyImpulse(impulse2);

                //source.setPosition(p1.add(n.mult(overlap/2)));
                //target.setPosition(p2.sub(n.mult(overlap/2)));

                if (this._eventOutput != null) {
					this._eventOutput.emit('postCollision', collisionData);
				}

            }
        }
    }
	
}