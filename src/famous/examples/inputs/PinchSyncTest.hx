package famous.examples.inputs;

import famous.core.Engine;
import famous.core.Surface;
import famous.inputs.PinchSync;

/**
 * PinchSync
 * ------------
 * 
 * PinchSync handles piped-in two-finger touch events to change
 * position via pinching / expanding. It outputs an object with
 * position, velocity, touch IDs, and distance.
 *
 * In this example, we create a PinchSync and display the data
 * it receives to the screen.  Based on the data, we can decide if
 * it is pinching or expanding.
 */
class PinchSyncTest {

	static function main() {
		var mainCtx = Engine.createContext();

		var start = 0;
		var update = 0;
		var end = 0;
		var direction = "";
		var distance:Float = 0;
		var delta:Float = 0;
		var displacement:Float = 0;

		var pinchSync = new PinchSync();

		Engine.pipe(pinchSync);

		var contentTemplate = function() {
			return "<div>Start Count: " + start + "</div>" +
			"<div>End Count: " + end + "</div>" +
			"<div>Update Count: " + update + "</div>" +
			"<div>Pinch Direction: " + direction + "</div>" +
			"<div>Delta: " + delta + "</div>" +
			"<div>Separation Distance: " + distance + "</div>" +
			"<div>Separation Displacement: " + displacement + "</div>";
		};

		var surface = new Surface({
			size: [null, null],
			classes: ["grey-bg"],
			content: contentTemplate()
		});

		pinchSync.on("start", function(data) {
			start++;
			surface.setContent(contentTemplate());
		});

		pinchSync.on("update", function(data) {
			update++;
			distance = data.distance;
			direction = data.velocity > 0 ? "Expanding" : "Contracting";
			displacement = data.displacement;
			delta = data.delta;
			surface.setContent(contentTemplate());
		});

		pinchSync.on("end", function(data) {
			end++;
			surface.setContent(contentTemplate());
		});

		mainCtx.add(surface);
	}
	
}