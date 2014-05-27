package famous.examples.views;

import famous.core.Engine;
import famous.core.Surface;
import famous.core.Modifier;
import famous.views.EdgeSwapper;

/**
 * EdgeSwapper
 * ------------
 *
 * EdgeSwapper is a container which handles swapping 
 * renderables from the edge of its parent context.
 *
 * In this example, we toggle the view that is shown on every
 * click.
 */
class EdgeSwapperTest {

	static function main() {
		var mainContext = Engine.createContext();

		var edgeswapper = new EdgeSwapper();

		var primary = new Surface({
			size: [null, null],
			content: "Primary",
			classes: ["red-bg"],
			properties: {
				lineHeight: js.Browser.window.innerHeight + "px",
				textAlign: "center"
			}
		});

		var secondary = new Surface({
			size: [null, null],
			content: "Secondary",
			classes: ["grey-bg"],
			properties: {
				lineHeight: js.Browser.window.innerHeight + "px",
				textAlign: "center"
			}
		});
		mainContext.add(edgeswapper); 

		edgeswapper.show(primary);

		var showing = true;
		Engine.on("click", function(event) {
			if (showing) {
				edgeswapper.show(secondary);
				showing = false;
			} else {
				edgeswapper.show(primary);
				showing = true;
			}
		});
	}
	
}