package famous.examples.inputs;

import famous.core.Engine;
import famous.core.Surface;
import famous.inputs.RotateSync;

/**
 * RotateSync
 * ------------
 * 
 * RotateSync handles piped-in two-finger touch events to support rotation.
 * It outputs an object with position, velocity, touches, and angle.
 *
 * In this example, we create a RotateSync and display the data
 * it receives to the screen.
 */
class RotateSyncTest {

	static function main() {
		var mainContext = Engine.createContext();

		var start = 0;
		var update = 0;
		var end = 0;
		var direction = "";
		var angle:Float = 0;
		var delta:Float = 0;

		var rotateSync = new RotateSync();

		Engine.pipe(rotateSync);

		var contentTemplate = function() {
			return "<div>Start Count: " + start + "</div>" +
			"<div>End Count: " + end + "</div>" +
			"<div>Update Count: " + update + "</div>" +
			"<div>Direction: " + direction + "</div>" +
			"<div>Delta: " + delta + "</div>" +
			"<div>Angle: " + angle + "</div>";
		};

		var surface = new Surface({
			size: [null, null],
			classes: ['grey-bg'],
			content: contentTemplate()
		});

		rotateSync.on("start", function(data) {
			start++;
			angle = 0;
			surface.setContent(contentTemplate());
		});

		rotateSync.on("update", function(data) {
			update++;
			direction = data.velocity > 0 ? "Clockwise" : "Counter-Clockwise";
			angle = data.angle;
			delta = data.delta;
			surface.setContent(contentTemplate());
		});

		rotateSync.on("end", function(data) {
			end++;
			surface.setContent(contentTemplate());
		});

		mainContext.add(surface);
	}
	
}