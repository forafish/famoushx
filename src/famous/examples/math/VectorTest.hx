package famous.examples.math;

import famous.math.Matrix;
import famous.math.Vector;

class VectorTest {

	static function main() {
		// rotate 45 degrees about z axis
		var matrix = new Matrix([
		   [ .707, -.707, 0],
		   [ .707, .707, 0],
		   [ 0, 0, 1]
		]);
		
		var c = matrix.clone();
		
		var vector = new Vector(1, 0, 0);
		var rotatedVector = matrix.vectorMultiply(vector);
		trace(rotatedVector);
	}
	
}