package famous.examples.views;

import famous.core.Engine;
import famous.core.Surface;
import famous.views.GridLayout;

/**
 * GridLayout
 * -------------
 * 
 * GridLayout is a layout which divides a context into several evenly-sized grid cells.
 * If dimensions are provided, the grid is evenly subdivided with children
 * cells representing their own context, otherwise the cellSize property is used to compute 
 * dimensions so that items of cellSize will fit.
 *
 * In this example, we make a 4x2 grid with 8 surfaces with varying hues. 
 */
class GridLayoutTest {

	static function main() {
		var mainContext = Engine.createContext();

		var grid = new GridLayout({
			dimensions: [4, 2]
		});

		var surfaces = [];
		grid.sequenceFrom(surfaces);

		for(i in 0...8) {
			surfaces.push(new Surface({
				content: "I am panel " + (i + 1),
				size: [null, null],
				properties: {
					backgroundColor: "hsl(" + (i * 360 / 8) + ", 100%, 50%)",
					color: "black",
					lineHeight: js.Browser.window.innerHeight / 2 + 'px',
					textAlign: 'center'
				}
			}));
		}

		mainContext.add(grid);
	}
	
}