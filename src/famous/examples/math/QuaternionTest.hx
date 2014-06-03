package famous.examples.math;

import famous.core.Engine;
import famous.core.Surface;
import famous.core.Modifier;
import famous.core.Transform;
import famous.math.Matrix;
import famous.math.Quaternion;

/**
 * Quaternion
 * ----------
 * 
 * Quaternions are used to represent rotations.  It has two components,
 * an axis represented by x, y, and z and the amount of rotation to
 * be applied around that axis, represented by w.  Quaternions are
 * particularly useful because they have no chance of gimbal lock.
 *
 * In this example, we have a Quaternion that defined the surface's
 * rotation.
 */
class QuaternionTest {

	static function main() {
		var mainContext = Engine.createContext();

		var quaternion = new Quaternion(Math.PI/3, .5, .5, 0);

		var surface = new Surface({
			size: [200, 200],
			content: 'Hello World',
			classes: ["red-bg"],
			properties: {
				lineHeight: '200px',
				textAlign: 'center'
			}
		});

		var toggle = true;

		var modifier = new Modifier();
		modifier.transformFrom(function() {
			return toggle ? Transform.identity : quaternion.getTransform();
		});

		mainContext.add(new Modifier({origin: [.5, .5]})).add(modifier).add(surface);

		Engine.on('click', function(data) {
			toggle = toggle ? false : true;
		});
	}
	
}