package famous.examples.views;

import famous.core.Engine;
import famous.core.Surface;
import famous.core.Modifier;
import famous.views.FlexibleLayout;

/**
 * Flipper
 * -------------
 *
 * GridLayout is a layout which divides a context into several evenly-sized grid cells.
 * If dimensions are provided, the grid is evenly subdivided with children
 * cells representing their own context, otherwise the cellSize property is used to compute
 * dimensions so that items of cellSize will fit.
 *
 * In this example, we make a 4x2 grid with 8 surfaces with varying hues.
 */
class FlexibleLayoutTest {

	static function main() {
		var mainContext = Engine.createContext();

		var colors = [
			'rgba(256, 0, 0, .7)',
			'rgba(0, 256, 0, .7)',
			'rgba(0, 0, 256, .7)',
			'rgba(256, 0, 0, .7)',
			'rgba(0, 256, 0, .7)',
			'rgba(0, 0, 256, .7)',
			'rgba(256, 0, 0, .7)',
			'rgba(0, 256, 0, .7)',
			'rgba(0, 0, 256, .7)'
		];

		var initialRatios:Array<Dynamic> = [1, true, 1, true, 1, true, 1, true];

		var flex = new FlexibleLayout({
			ratios : initialRatios
		});

		var surfaces = [];
		for (i in 1...9) {
			var size:Array<Float> = (i % 2 == 0) ? [10, null] : [null, null];
			surfaces.push(new Surface({
				size: size,
				properties: {
					backgroundColor: colors[i-1]
				}
			}));
		}

		flex.sequenceFrom(surfaces);

		var finalRatios:Array<Dynamic> = [4, true, 1, true, 0, true, 7, true];
		var toggle = false;
		Engine.on('click', function(event){
			var ratios = toggle ? initialRatios : finalRatios;
			flex.setRatios(ratios, {curve : 'easeOut', duration : 500});
			toggle = !toggle;
		});

		mainContext.add(flex);		
	}
	
}