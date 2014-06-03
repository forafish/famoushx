package famous.physics.bodies;

import famous.math.Matrix;
import famous.physics.bodies.Body;

typedef CircleOptions = {
	> BodyOptions,
	?radius: Float,
};

/**
 * Implements a circle, or spherical, geometry for an Body with
 * radius.
 */
class Circle extends Body {
    var radius:Float;
    var size:Array<Float>;
	
    /**
     * @constructor
     */
	public function new(?options:CircleOptions) {
		options = options != null? options : {};
		this.setRadius(options.radius != null? options.radius : 0);
		super(options);
	}
	
    /**
     * Basic setter for radius.
     * @method setRadius
     * @param r {Number} radius
     */
    public function setRadius(r) {
        this.radius = r;
        this.size = [2*this.radius, 2*this.radius];
        this.setMomentsOfInertia();
    }

    override public function setMomentsOfInertia() {
        var m = this.mass;
        var r = this.radius;

        this.inertia = new Matrix([
            [0.25 * m * r * r, 0, 0],
            [0, 0.25 * m * r * r, 0],
            [0, 0, 0.5 * m * r * r]
        ]);

        this.inverseInertia = new Matrix([
            [4 / (m * r * r), 0, 0],
            [0, 4 / (m * r * r), 0],
            [0, 0, 2 / (m * r * r)]
        ]);
    }
	
}