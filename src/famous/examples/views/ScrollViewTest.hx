package famous.examples.views;

import famous.core.Engine;
import famous.core.Surface;
import famous.views.ScrollView;

/**
 * Scrollview
 * ------------
 *
 * Scrollview is one of the core views in Famo.us. Scrollview
 * will lay out a collection of renderables sequentially in 
 * the specified direction, and will allow you to scroll 
 * through them with mousewheel or touch events.
 *
 * In this example, we have a Scrollview that sequences over
 * a collection of surfaces that vary in color
 */
class ScrollViewTest {

	static function main() {
		var mainContext = Engine.createContext();

		var scrollview = new ScrollView();
		var surfaces = [];

		scrollview.sequenceFrom(surfaces);

		for (i in 0...20) {
			var temp = new Surface({
				 content: "Surface: " + (i + 1),
				 size: [null, 200],
				 properties: {
					 backgroundColor: "hsl(" + (i * 360 / 40) + ", 100%, 50%)",
					 lineHeight: "200px",
					 textAlign: "center"
				 }
			});

			temp.pipe(scrollview);
			surfaces.push(temp);
		}

		mainContext.add(scrollview);
	}
	
}