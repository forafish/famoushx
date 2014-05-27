package famous.examples.events;

import js.Lib;
import famous.core.EventEmitter;
import famous.core.EventHandler;
import famous.events.EventFilter;
import famous.events.EventMapper;


/**
 * EventFilter with subscription
 * -----------------------------
 *
 * EventFilter provides a way to define a function that 
 * can decide whether or not to propogate events downwards.
 *
 * In this example, eventHandlerB is subscribed to all events coming
 * out of the filter and the filter is subscribed to all events
 * coming out of eventHandlerA.  This filter will only propogate events
 * if the data's 'msg' property is 'ALERT!'.  Because we change
 * the msg that is broadcast every click, you can see that the
 * alert occurs every other click.
 */
class EventFilterSubscribeTest {
	
	static function main() {
		var eventHandlerA = new EventHandler();
		var eventHandlerB = new EventHandler();
		
		var myFilter = new EventFilter(function(type, data) {
			return (data != null) && (data.msg == "ALERT!");
		});
		
		eventHandlerB.subscribe(myFilter);
		myFilter.subscribe(eventHandlerA);
		eventHandlerB.on("A", function(data) {
			Lib.alert("subscribed message: " + data.msg);
		});
		
		eventHandlerA.trigger("A", {msg: "ALERT!"});
	}
	
}