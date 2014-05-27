package famous.examples.events;

import js.Lib;
import famous.core.EventEmitter;
import famous.core.EventHandler;
import famous.events.EventFilter;
import famous.events.EventMapper;

/**
 * EventMapper
 * ------------
 *
 * EventMapper is a way to route events to various EventHandlers
 * based on the type of the event.
 *
 * In this example, we pipe all events from eventHandlerA to
 * the EventMapper.  This filter will decide whether to send
 * the event to eventHandlerB or eventHandlerC based on the
 * direction property of the data sent along with the event.
 */
class EventMapperTest {
	
	static function main() {
		var eventHandlerA = new EventHandler();
		var eventHandlerB = new EventHandler();
		var eventHandlerC = new EventHandler();
		
		var myMapper = new EventMapper(function(type, data) {
			return (data != null && (data.direction == "x"))? eventHandlerB : eventHandlerC;
		});
		eventHandlerA.pipe(myMapper);
		
		eventHandlerB.on("A", function(data) {
			Lib.alert("B direction: " + data.direction);
		});
		eventHandlerC.on("A", function(data) {
			Lib.alert("C direction: " + data.direction);
		});
		
		eventHandlerA.trigger("A", { direction : "x" } ); // pipes to eventHandlerB
		eventHandlerA.trigger("A", { direction : "y" } ); // pipes to eventHandlerC
	}
	
}