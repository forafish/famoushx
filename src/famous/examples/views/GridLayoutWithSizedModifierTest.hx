package famous.examples.views;

import famous.core.Engine;
import famous.core.Surface;
import famous.views.GridLayout;
import famous.core.Modifier;

/**
 * GridLayout with sized modifier
 * ------------------------------
 * 
 * GridLayouts will respect their parents size.  When placed behind
 * a modifier with a set size, the layout will expand to that size
 * instead of filling the full window.
 *
 * In this example, we see a GridLayout behind a sized Modifier.
 */
class GridLayoutWithSizedModifierTest {

	static function main() {
		var mainContext = Engine.createContext();

		var grid = new GridLayout({
			dimensions: [4, 2]
		});

		var surfaces = [];
		grid.sequenceFrom(surfaces);

		for (i in 0...8) {
			surfaces.push(new Surface({
				content: "I am panel " + (i + 1),
				size: [null, 100],
				properties: {
					backgroundColor: "hsl(" + (i * 360 / 8) + ", 100%, 50%)",
					color: "black",
					lineHeight: '100px',
					textAlign: 'center'
				}
			}));
		}

		mainContext.add(new Modifier({size: [400, 200], origin: [.5, .5]})).add(grid);
	}
	
}