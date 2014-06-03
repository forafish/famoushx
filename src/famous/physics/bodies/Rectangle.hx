package famous.physics.bodies;

import famous.math.Matrix;
import famous.physics.bodies.Body;

typedef RectangleOptions = {
	> BodyOptions,
	?size: Array<Float>,
};

/**
 * Implements a rectangular geometry for an Body with
 * size = [width, height].
 */
class Rectangle extends Body {

	var size:Array<Float>;
	
    /**
     * @constructor
     */
	public function new(?options:RectangleOptions) {
		options = options != null? options : {};
		this.size = options.size != null? options.size : [0,0];
		super(options);
	}
	
    /**
     * Basic setter for size.
     * @method setSize
     * @param size {Array} size = [width, height]
     */
    public function setSize(size) {
        this.size = size;
        this.setMomentsOfInertia();
    }

    override public function setMomentsOfInertia() {
        var m = this.mass;
        var w = this.size[0];
        var h = this.size[1];

        this.inertia = new Matrix([
            [m * h * h / 12, 0, 0],
            [0, m * w * w / 12, 0],
            [0, 0, m * (w * w + h * h) / 12]
        ]);

        this.inverseInertia = new Matrix([
            [12 / (m * h * h), 0, 0],
            [0, 12 / (m * w * w), 0],
            [0, 0, 12 / (m * (w * w + h * h))]
        ]);
    }	
}