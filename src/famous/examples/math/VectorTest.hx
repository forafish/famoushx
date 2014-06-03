package famous.examples.math;

import famous.core.Engine;
import famous.core.Surface;
import famous.math.Matrix;
import famous.math.Vector;

/**
 * Vector
 * --------
 *
 * Vector a way to create a three element float point vector.
 *
 * In the example you can see how a Vector is affected when it
 * is multiplied against a rotation matrix.
 */
class VectorTest {

	static function main() {
		var mainContext = Engine.createContext();

		// rotate 45 degrees about z axis
		var matrix = new Matrix([
		   [ .707, -.707, 0],
		   [ .707, .707, 0],
		   [ 0, 0, 1]
		]);

		var vector = new Vector(1, 0, 0);
		var rotatedVector = matrix.vectorMultiply(vector);

		var surface = new Surface({
			size: [200, 200],
			classes: ["red-bg"],
			properties: {
				lineHeight: '200px',
				textAlign: 'center'
			}
		});
		surface.setContent('[' + rotatedVector.get().toString() + ']');
		mainContext.add(surface);
	}
	
}