package famous.physics.constraints;

import famous.math.Vector;
import famous.physics.bodies.Body;
import famous.physics.bodies.Particle;
import famous.physics.constraints.Constraint;


/**
 * @property Wall.ON_CONTACT
 * @type Object
 * @protected
 * @static
 */

 typedef WallOptions = {
	?restitution : Float,
	?drift : Float,
	?slop : Float,
	?normal : Dynamic, // Array<Float> or Vector
	?distance : Float,
	?onContact : Int,
};

/**
 *  A wall describes an infinite two-dimensional plane that physics bodies
 *    can collide with. To define a wall, you must give it a distance (from
 *    the center of the physics engine's origin, and a normal defining the plane
 *    of the wall.
 *
 *    (wall)
 *      |
 *      | (normal)     (origin)
 *      | --->            *
 *      |
 *      |    (distance)
 *      ...................
 *            (100px)
 *
 *      e.g., Wall({normal : [1,0,0], distance : 100})
 *      would be a wall 100 pixels to the left, whose normal points right
 */
class Wall extends Constraint {

    /**
     * @property Wall.ON_CONTACT
     * @type Object
     * @protected
     * @static
     */
    static public var ON_CONTACT = {

        /**
         * Physical bodies bounce off the wall
         * @attribute REFLECT
         */
        REFLECT : 0,

        /**
         * Physical bodies are unaffected. Usecase is to fire events on contact.
         * @attribute SILENT
         */
        SILENT : 1
    };
	
	static public var DEFAULT_OPTIONS:WallOptions = {
        restitution : 0.5,
        drift : 0.5,
        slop : 0,
        normal : [1, 0, 0],
        distance : 0,
        onContact : Wall.ON_CONTACT.REFLECT
    };
	
    /** @const */ var epsilon = 1e-7;
    /** @const */ var pi = Math.PI;

	var diff:Vector;
	var impulse:Vector;
		
    /**
     *  @constructor
     *  @extends Constraint
     *  @param {Options} [options] An object of configurable options.
     *  @param {Number} [options.restitution] The energy ratio lost in a collision (0 = stick, 1 = elastic). Range : [0, 1]
     *  @param {Number} [options.drift] Baumgarte stabilization parameter. Makes constraints "loosely" (0) or "tightly" (1) enforced. Range : [0, 1]
     *  @param {Number} [options.slop] Amount of penetration in pixels to ignore before collision event triggers.
     *  @param {Array} [options.normal] The normal direction to the wall.
     *  @param {Number} [options.distance] The distance from the origin that the wall is placed.
     *  @param {onContact} [options.onContact] How to handle collision against the wall.
     *
     */
	public function new(?option:WallOptions) {
        this.options = Reflect.copy(Wall.DEFAULT_OPTIONS);
        if (options != null) this.setOptions(options);

        //registers
        this.diff = new Vector();
        this.impulse = new Vector();

        super();
	}
	
    /*
     * Setter for options.
     *
     * @method setOptions
     * @param options {Objects}
     */
    override public function setOptions(options:Dynamic) {
        if (options.normal != null) {
            if (Std.is(options.normal, Vector)) {
				this.options.normal = options.normal.clone();
			}
            if (Std.is(options.normal, Array)) {
				this.options.normal = new Vector(options.normal);
			}
        }
        if (options.restitution != null) {
			this.options.restitution = options.restitution;
		}
        if (options.drift != null) {
			this.options.drift = options.drift;
		}
        if (options.slop != null) {
			this.options.slop = options.slop;
		}
        if (options.distance != null) {
			this.options.distance = options.distance;
		}
        if (options.onContact != null) {
			this.options.onContact = options.onContact;
		}
    }

    function _getNormalVelocity(n:Vector, v:Vector) {
        return v.dot(n);
    }

    function _getDistanceFromOrigin(p:Vector) {
        var n = this.options.normal;
        var d = this.options.distance;
        return p.dot(n) + d;
    }

    function _onEnter(particle:Particle, overlap:Float, dt:Float) {
        var p = particle.position;
        var v = particle.velocity;
        var m = particle.mass;
        var n = this.options.normal;
        var action = this.options.onContact;
        var restitution = this.options.restitution;
        var impulse = this.impulse;

        var drift = this.options.drift;
        var slop = -this.options.slop;
        var gamma = 0;

		var data = null;
        if (this._eventOutput != null) {
            data = {particle : particle, wall : this, overlap : overlap, normal : n};
            this._eventOutput.emit('preCollision', data);
            this._eventOutput.emit('collision', data);
        }

        if (action == Wall.ON_CONTACT.REFLECT) {
			var lambda = (overlap < slop)
				? -((1 + restitution) * n.dot(v) + drift / dt * (overlap - slop)) / (m * dt + gamma)
				: -((1 + restitution) * n.dot(v)) / (m * dt + gamma);

			impulse.set(n.mult(dt * lambda));
			particle.applyImpulse(impulse);
			particle.setPosition(p.add(n.mult(-overlap)));
        }

        if (this._eventOutput != null) {
			this._eventOutput.emit('postCollision', data);
		}
    }

    function _onExit(particle:Particle, overlap:Float, dt:Float) {
        var action = this.options.onContact;
        var p = particle.position;
        var n = this.options.normal;

        if (action == Wall.ON_CONTACT.REFLECT) {
            particle.setPosition(p.add(n.mult(-overlap)));
        }
    }

    /**
     * Adds an impulse to a physics body's velocity due to the wall constraint
     *
     * @method applyConstraint
     * @param targets {Array.Body}  Array of bodies to apply the constraint to
     * @param source {Body}         The source of the constraint
     * @param dt {Number}           Delta time
     */
    override public function applyConstraint(targets:Array<Dynamic>, source:Dynamic, dt:Float) {
        var n:Vector = this.options.normal;

        for (particle in targets) {
            var p = particle.position;
            var v = particle.velocity;
            var r = particle.radius != null? particle.radius : 0;

            var overlap = _getDistanceFromOrigin(p.add(n.mult(-r)));
            var nv = _getNormalVelocity(n, v);

            if (overlap <= 0) {
                if (nv < 0) _onEnter(particle, overlap, dt);
                else _onExit(particle, overlap, dt);
            }
        }
    }	
}