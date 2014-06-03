package famous.examples.inputs;

import famous.core.Engine;
import famous.core.Surface;
import famous.inputs.Accumulator;
import famous.inputs.TouchSync;

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
class TouchSyncAccumulatorTest {

	static function main() {
		var mainContext = Engine.createContext();

		var update = 0;

		var x = 0;
		var y = 0;
		var position = [x, y];

		var touchSync = new TouchSync();
		var accumulator = new Accumulator(position);

		Engine.pipe(touchSync);
		touchSync.pipe(accumulator);

		var contentTemplate = function() {
			return "<div>Update Count: " + update + "</div>" +
				   "<div>Accumulated distance: " + accumulator.get() + "</div>";
		};

		var surface = new Surface({
			size: [null, null],
			classes: ["grey-bg"],
			content: contentTemplate()
		});

		touchSync.on("start", function(data) {
			accumulator.set([x,y]);
			surface.setContent(contentTemplate());
		});

		touchSync.on("update", function(data) {
			update++;
			surface.setContent(contentTemplate());
		});

		mainContext.add(surface);
	}
	
}