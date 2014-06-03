package famous.examples.math;

import famous.core.Engine;
import famous.core.Surface;
import famous.core.Modifier;
import famous.core.Transform;
import famous.math.Matrix;
import famous.math.Vector;
import famous.core.Transform.Matrix4;

/**
 * Matrix
 * -------
 *
 * Matrix is a library for creating a 3x3 matrix and applying
 * various math operations to them such as multiplication
 * or finding the transpose.
 *
 * In this example we create a 3x3 matrix and multiply it by a
 * unit vector to create the 3x1 matrix [0.707,0.707,0].
 */
class MatrixTest {

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