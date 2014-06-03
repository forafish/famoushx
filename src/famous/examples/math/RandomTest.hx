package famous.examples.math;

import famous.core.Engine;
import famous.core.Surface;
import famous.math.Random;

/**
 * Random
 * -------
 *
 * Random is a library for creating random integers,
 * booleans, ranges, and signs.
 *
 * In this example we set the content based on the random
 * boolean that is created.
 */
class RandomTest {

	static function main() {
		var mainContext = Engine.createContext();
		
		var surface = new Surface({
			size: [200, 200],
			classes: ['red-bg'],
			properties: {
				lineHeight: '200px',
				textAlign: 'center'
			}
		});
		var is_heads = Random.bool();
		surface.setContent(is_heads ? 'Heads' : 'Tails');

		mainContext.add(surface);

		Engine.on('click', function(data) {
			surface.setContent(Random.bool() ? 'Heads' : 'Tails');
		});
	}
	
}