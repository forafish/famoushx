package famous.examples.inputs;

import famous.core.Engine;
import famous.core.Surface;
import famous.inputs.MouseSync;

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
class MouseSyncSingleDimensionTest {

	static function main() {
		var mainContext = Engine.createContext();

		var start = 0;
		var update = 0;
		var end = 0;
		var delta = 0;

		var x = 0;
		var y = 0;
		var position = [x, y];

		var mouseSync = new MouseSync({direction : MouseSync.DIRECTION_X});

		Engine.pipe(mouseSync);

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

		mouseSync.on("start", function() {
			start++;
			position = [x, y];
			surface.setContent(contentTemplate());
		});

		mouseSync.on("update", function(data) {
			update++;
			position[0] = data.position;
			delta = data.delta;
			surface.setContent(contentTemplate());
		});

		mouseSync.on("end", function() {
			end++;
			surface.setContent(contentTemplate());
		});

		mainContext.add(surface);
	}
	
}