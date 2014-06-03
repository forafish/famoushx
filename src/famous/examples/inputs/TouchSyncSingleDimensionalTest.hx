package famous.examples.inputs;

import famous.core.Engine;
import famous.core.Surface;
import famous.inputs.TouchSync;

/**
 * MouseSync
 * ------------
 *
 * Famo.us syncs default to track two-dimensional movement,
 * but can be passed as optional direction parameter to restrict
 * movement to a single axis.
 *
 * In this example, we create a TouchSync but only track the y-axis
 * changes on touchmove.
 *
 */
class TouchSyncSingleDimensionalTest {

	static function main() {
		var mainContext = Engine.createContext();

		var start = 0;
		var update = 0;
		var end = 0;
		var delta = 0;

		var x = 0;
		var y = 0;
		var position = [x, y];

		var touchSync = new TouchSync({direction : TouchSync.DIRECTION_Y});

		Engine.pipe(touchSync);

		var contentTemplate = function() {
			return "<div>Start Count: " + start + "</div>" +
				   "<div>End Count: " + end + "</div>" +
				   "<div>Update Count: " + update + "</div>" +
				   "<div>Delta: " + delta + "</div>" +
				   "<div>Distance from start: " + position + "</div>";
		};

		var surface = new Surface({
			size: [null, null],
			classes: ["grey-bg"],
			content: contentTemplate()
		});

		touchSync.on("start", function(data) {
			start++;
			position = [x, y];
			surface.setContent(contentTemplate());
		});

		touchSync.on("update", function(data) {
			update++;
			position[1] = data.position;
			delta = data.delta;
			surface.setContent(contentTemplate());
		});

		touchSync.on("end", function(data) {
			end++;
			surface.setContent(contentTemplate());
		});

		mainContext.add(surface);
	}
	
}