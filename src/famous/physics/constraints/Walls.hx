package famous.physics.constraints;

import famous.math.Vector;
import famous.physics.bodies.Body;
import famous.physics.bodies.Particle;
import famous.physics.constraints.Constraint;
import famous.physics.constraints.Wall;
import js.Browser;

/**
 * An enumeration of common types of walls
 *    LEFT, RIGHT, TOP, BOTTOM, FRONT, BACK
 *    TWO_DIMENSIONAL, THREE_DIMENSIONAL
 *
 * @property Walls.SIDES
 * @type Object
 * @final
 * @static
 */

typedef WallsOptions = {
	sides : Dynamic,
	size : Array<Float>,
	origin : Array<Float>,
	drift : Float,
	slop : Float,
	restitution : Float,
	onContact : Dynamic
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
class Walls extends Constraint {

	static public var DEFAULT_OPTIONS:WallsOptions = {
        sides : Walls.SIDES.TWO_DIMENSIONAL,
        size : [js.Browser.window.innerWidth, js.Browser.window.innerHeight, 0],
        origin : [.5, .5, .5],
        drift : 0.5,
        slop : 0,
        restitution : 0.5,
        onContact : Wall.ON_CONTACT.REFLECT
    };
	
	public static var SIDES = {
        LEFT   : 0,
        RIGHT  : 1,
        TOP    : 2,
        BOTTOM : 3,
        FRONT  : 4,
        BACK   : 5,
        TWO_DIMENSIONAL : [0, 1, 2, 3],
        THREE_DIMENSIONAL : [0, 1, 2, 3, 4, 5]
    };
	
	public static var _SIDE_NORMALS = [
        /*0 : */new Vector(1, 0, 0),
        /*1 : */new Vector(-1, 0, 0),
        /*2 : */new Vector(0, 1, 0),
        /*3 : */new Vector(0,-1, 0),
        /*4 : */new Vector(0, 0, 1),
        /*5 : */new Vector(0, 0,-1)
    ];

	public var components:Array<Wall>;
	
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
        this.options = Reflect.copy(Walls.DEFAULT_OPTIONS);
        if (options != null) this.setOptions(options);

        _createComponents(options.sides != null? options.sides : this.options.sides);

        super();
	}
	
    function _getDistance(side:Dynamic, size:Array<Float>, origin:Array<Float>) {
        var distance;
        switch (Std.parseInt(side)) {
            case 0:// Walls.SIDES.LEFT:
                distance = size[0] * origin[0];
            case 1://Walls.SIDES.TOP:
                distance = size[1] * origin[1];
            case 2://Walls.SIDES.FRONT:
                distance = size[2] * origin[2];
            case 3://Walls.SIDES.RIGHT:
                distance = size[0] * (1 - origin[0]);
            case 4://Walls.SIDES.BOTTOM:
                distance = size[1] * (1 - origin[1]);
            case 5://Walls.SIDES.BACK:
                distance = size[2] * (1 - origin[2]);
        }
        return distance;
    }
	
    /*
     * Setter for options.
     *
     * @method setOptions
     * @param options {Objects}
     */
    override public function setOptions(options:Dynamic) {
        var resizeFlag = false;
        if (options.restitution != null) {
			_setOptionsForEach({restitution : options.restitution});
		}
        if (options.drift != null) {
			_setOptionsForEach({drift : options.drift});
		}
        if (options.slop != null) {
			_setOptionsForEach({slop : options.slop});
		}
        if (options.onContact != null) {
			_setOptionsForEach({onContact : options.onContact});
		}
        if (options.size != null) {
			resizeFlag = true;
		}
        if (options.sides != null) {
			this.options.sides = options.sides;
		}
        if (options.origin != null) {
			resizeFlag = true;
		}
        if (resizeFlag) {
			this.setSize(options.size, options.origin);
		}
    }

    function _createComponents(sides:Array<Dynamic>) {
        this.components = [];
        var components = this.components;

        for (i in 0...sides.length) {
            var side = sides[i];
            components[i] = new Wall({
                normal   : _SIDE_NORMALS[side].clone(),
                distance : _getDistance(side, this.options.size, this.options.origin)
            });
        }
    }

    /*
     * Setter for size.
     *
     * @method setOptions
     * @param options {Objects}
     */
    public function setSize(size:Array<Float>, origin:Array<Float>) {
        origin = origin != null? origin : this.options.origin;
        if (origin.length < 3) origin[2] = 0.5;

        this.forEach(function(wall:Wall, ?side:Int) {
            var d = _getDistance(side, size, origin);
            wall.setOptions({distance : d});
        });

        this.options.size   = size;
        this.options.origin = origin;
    };

    function _setOptionsForEach(options:Dynamic) {
        this.forEach(function(wall:Wall, ?side:Int) {
            wall.setOptions(options);
        });
        for (key in Reflect.fields(options)) {
			this.options[cast key] = options[cast key];
		}
    }

    /**
     * Adds an impulse to a physics body's velocity due to the walls constraint
     *
     * @method applyConstraint
     * @param targets {Array.Body}  Array of bodies to apply the constraint to
     * @param source {Body}         The source of the constraint
     * @param dt {Number}           Delta time
     */
    override public function applyConstraint(targets:Array<Dynamic>, source:Dynamic, dt:Float) {
        this.forEach(function(wall:Wall, ?side:Int) {
            wall.applyConstraint(targets, source, dt);
        });
    }
	
    /**
     * Apply a method to each wall making up the walls
     *
     * @method applyConstraint
     * @param fn {Function}  Function that takes in a wall as its first parameter
     */
    public function forEach(fn:Wall -> ?Int -> Void) {
        for (key in 0...this.components.length) {
			fn(this.components[key], key);
		}
    };

    /**
     * Rotates the walls by an angle in the XY-plane
     *
     * @method applyConstraint
     * @param angle {Function}
     */
    public function rotateZ(angle:Float) {
        this.forEach(function(wall:Wall, ?side:Int) {
            var n:Vector = wall.options.normal;
            n.rotateZ(angle).put(n);
        });
    }

    /**
     * Rotates the walls by an angle in the YZ-plane
     *
     * @method applyConstraint
     * @param angle {Function}
     */
    public function rotateX(angle:Float) {
        this.forEach(function(wall:Wall, ?side:Int) {
            var n:Vector = wall.options.normal;
            n.rotateX(angle).put(n);
        });
    }

    /**
     * Rotates the walls by an angle in the XZ-plane
     *
     * @method applyConstraint
     * @param angle {Function}
     */
    public function rotateY(angle:Float) {
        this.forEach(function(wall:Wall, ?side:Int) {
            var n:Vector = wall.options.normal;
            n.rotateY(angle).put(n);
        });
    }	
}