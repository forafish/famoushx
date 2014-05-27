package famous.examples.core;

import famous.core.Engine;
import famous.core.EventHandler;
import famous.core.Surface;

class EventHandlerTest {

	static function main() {
		var mainContext = Engine.createContext();
		
		var surface = new Surface({
			size: [200, 200],
			content: "Click Me",
			classes: ["red-bg"],
			properties: {
				lineHeight: "200px",
				textAlign: "center"
			}
		});
		
		var eventHandler = new EventHandler();
		
		surface.pipe(eventHandler);
		
		eventHandler.on("click", function(_) {
			js.Lib.alert("Click from the event handler");
		});
		
		mainContext.add(surface);
	}
	
}