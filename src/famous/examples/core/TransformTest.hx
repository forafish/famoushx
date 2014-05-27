package famous.examples.core;

import famous.core.Transform;
import famous.core.Modifier;

class TransformTest {

	static function main() {
		var rotateModifier = new Modifier({
			transform: Transform.rotateZ(Math.PI/4)
		});
	}
	
}