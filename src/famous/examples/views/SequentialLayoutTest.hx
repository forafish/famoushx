package famous.examples.views;

import famous.core.Engine;
import famous.core.Surface;
import famous.views.SequentialLayout;

/**
 * SequentialLayout
 * ------------------
 *
 * SequentialLayout will lay out a collection of renderables
 * sequentially in the specified direction.
 *
 * In this example, we have ten surfaces displayed veritcally.
 */
class SequentialLayoutTest {

	static function main() {
		var mainContext = Engine.createContext();

		var sequentialLayout = new SequentialLayout({
			direction: 1
		});
		var surfaces = [];

		sequentialLayout.sequenceFrom(surfaces);

		for (i in 0...10) {
			surfaces.push(new Surface({
				 content: "Surface: " + (i + 1),
				 size: [null, js.Browser.window.innerHeight/10],
				 properties: {
					 backgroundColor: "hsl(" + (i * 360 / 10) + ", 100%, 50%)",
					 lineHeight: js.Browser.window.innerHeight/10 + "px",
					 textAlign: "center"
				 }
			}));
		}

		mainContext.add(sequentialLayout);
	}
	
}