package famous.examples.inputs;

import famous.core.Engine;
import famous.core.Surface;
import famous.inputs.ScrollSync;

/**
 * ScrollSync
 * ------------
 * 
 * ScrollSync handles piped in mousewheel events. Can be used
 * as delegate of GenericSync.
 *
 * In this example, we create a ScrollSync and displays the data
 * it recieves to the screen.
 */
class ScrollSyncTest {

	static function main() {
		var mainContext = Engine.createContext();

		var start = 0;
		var update = 0;
		var end = 0;
		var delta = [0,0];
		var position = [0,0];

		var scrollSync = new ScrollSync();

		Engine.pipe(scrollSync);

		var contentTemplate = function() {
			return "<div>Start Count: " + start + "</div>" +
			"<div>End Count: " + end + "</div>" +
			"<div>Update Count: " + update + "</div>" +
			"<div>Delta: " + delta + "</div>" +
			"<div>Position: " + position + "</div>";
		};

		var surface = new Surface({
			size: [null, null],
			classes: ['grey-bg'],
			content: contentTemplate()
		});

		scrollSync.on("start", function() {
			start++;
			surface.setContent(contentTemplate());
		});

		scrollSync.on("update", function(data) {
			update++;
			position = data.position;
			delta = data.delta;
			surface.setContent(contentTemplate());
		});

		scrollSync.on("end", function() {
			end++;
			surface.setContent(contentTemplate());
		});

		mainContext.add(surface);
	}
	
}