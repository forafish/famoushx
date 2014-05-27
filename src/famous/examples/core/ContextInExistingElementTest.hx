package famous.examples.core;

import famous.core.Engine;
import famous.core.Surface;

/**
 * Context inside of an existing element
 * -------------------------------------
 *
 * A Famo.us Context can be applied to a pre-existing HTML element.
 * Note: You may need to add properties from famous.css for your
 * targeted HTML element to respect Famo.us 3D primites.
 */
class ContextInExistingElementTest {

	static function main() {
		var el = js.Browser.document.createElement('div');
		el.id = 'test';
		js.Browser.document.body.appendChild(el);
	
		var mainContext = Engine.createContext(el);
		
		var surface = new Surface({
			size: [200, 200],
			content: "Hello World",
			classes: ["red-bg"],
			properties: {
				lineHeight: "200px",
				textAlign: "center"
			}
		});

		mainContext.add(surface);
	}
	
}