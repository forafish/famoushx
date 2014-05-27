package famous.examples.core;

import famous.core.Engine;
import famous.core.Surface;
import famous.core.Transform;
import famous.core.Modifier;

/**
 * Modifier
 * --------
 *
 * Modifiers are Famo.us nodes that can be added to the render tree which affect
 * the appearance of the nodes below. Modifiers can apply a CSS3 3D
 * transform (translation, rotation, scale or skew), or an opacity. Modifiers also
 * affect layout primitives by defining a size context (bounding box) and origin.
 *
 * In this example, we can see that the surface is translated 50
 * pixels right and 50 pixels down because it sits below the
 * modifier in the render tree.
 */
class ModifierTest {

	static function main() {
		var mainContext = Engine.createContext();

		var transform = new Modifier({
			transform: Transform.translate(50, 50, 0)
		});

		var surface = new Surface({
			size: [200, 200],
			content: "Hello World",
			classes: ["red-bg"],
			properties: {
				lineHeight: "200px",
				textAlign: "center"
			}
		});

		mainContext.add(transform).add(surface);

	}
	
}