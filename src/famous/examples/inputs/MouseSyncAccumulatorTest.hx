package famous.examples.inputs;

import famous.core.Engine;
import famous.core.Surface;
import famous.inputs.MouseSync;
import famous.inputs.Accumulator;

/**
 * MouseSync
 * ------------
 *
 * Famo.us syncs default to track two-dimensional movement,
 * but can be passed as optional direction parameter to restrict
 * movement to a single axis.
 *
 * In this example, we create a MouseSync but only track the x-axis
 * changes on mouse drag.
 *
 */
class MouseSyncAccumulatorTest {

	static function main() {
		var mainContext = Engine.createContext();

		var update = 0;

		var x = 0;
		var y = 0;
		var position = [x, y];

		var mouseSync = new MouseSync();
		var accumulator = new Accumulator(position);

		Engine.pipe(mouseSync);
		mouseSync.pipe(accumulator);

		var contentTemplate = function() {
			return "<div>Update Count: " + update + "</div>" +
				   "<div>Accumulated distance: " + accumulator.get() + "</div>";
		};

		var surface = new Surface({
			size: [null, null],
			classes: ["grey-bg"],
			content: contentTemplate()
		});

		mouseSync.on("start", function() {
			accumulator.set([x,y]);
			surface.setContent(contentTemplate());
		});

		mouseSync.on("update", function() {
			update++;
			surface.setContent(contentTemplate());
		});

		mainContext.add(surface);
	}
	
}