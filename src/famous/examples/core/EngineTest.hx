package famous.examples.core;

import famous.core.Engine;
import famous.core.Surface;

/**
 * Engine
 * ------
 *
 * The Famo.us Engine is responsible for managing the requestAnimationFrame loop,
 * creating Famo.us contexts, and listening to DOM events on the window. The
 * Engine is a JavaScript singleton: there is only one instance per app.
 *
 */
class EngineTest {

	static function main() {
		var mainContext = Engine.createContext();
		
		var surface = new Surface({
			size: [null, 200],
			content: "Hello World",
			classes: ["red-bg"],
			properties: {
				textAlign: "center"
			}
		});

		mainContext.add(surface);
		
		// listen on window resize
		Engine.on("resize", function(_) {
			surface.setContent(
				'dimensions:' + '<br>' +
				'width : ' + js.Browser.window.innerWidth  + 'px ' + '<br>' +
				'height: ' + js.Browser.window.innerHeight + 'px'
			);
		});
				
		// listen on click
		Engine.on("click", function(event){
			surface.setContent(
				'click position:' + '<br>' +
				'x :' + event.clientX + 'px ' + '<br>' +
				'y :' + event.clientY + 'px'
			);
		});

		// exectute function on next requestAnimationFrame cycle
		Engine.nextTick(function() {
			surface.setContent("Try resizing the device/window or clicking somewhere!");
		});
	}
	
}