package famous.examples.events;

import js.Lib;
import famous.core.EventEmitter;
import famous.core.EventHandler;
import famous.events.EventFilter;
import famous.events.EventMapper;
import famous.events.EventArbiter;

class EventArbiterTest {

	static public function main() {
		var MODES = {A: 'A', B: 'B'};
		
		var eventArbiter = new EventArbiter(MODES.A);
		
		var AHandler = eventArbiter.forMode(MODES.A);
		AHandler.on('my_event', function(event) { 
			Lib.alert('AHandler'); 
		});

		var BHandler = eventArbiter.forMode(MODES.B);
		BHandler.on('my_event', function(event) { 
			Lib.alert('BHandler'); 
		});
		
		eventArbiter.setMode("A");
		eventArbiter.emit('my_event', {data: 123});
		eventArbiter.setMode("B");
		eventArbiter.emit('my_event', {data: 123});
	}
	
}