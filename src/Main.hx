package ;

import js.Browser;
import js.Lib;
import famous.core.EventEmitter;
import famous.core.EventHandler;
import famous.events.EventArbiter;
import famous.events.EventFilter;
import famous.events.EventMapper;
import famous.math.Vector;
import famous.math.Utilities;
import famous.core.Entity;
import famous.core.Transform;
import famous.core.Context;
import famous.core.Surface;
import famous.core.OptionsManager;
import famous.core.Engine;
import famous.core.ViewSequence;
import famous.core.View;
import famous.core.Group;

class WidgetTest {
	public var eventOutput:EventHandler;
	public var eventInput:EventHandler;
	
	public function new() {
		this.eventOutput = new EventHandler();
		this.eventInput = new EventHandler();
		EventHandler.setInputHandler(this, this.eventInput);
		EventHandler.setOutputHandler(this, this.eventOutput);
	}
}

class Main {
	
	static function main() {
		var el = js.Browser.document.createElement("div");
		el.classList.add("famousBlueBackground");
		el.innerHTML = "ABC";
		js.Browser.document.body.appendChild(el);
	}
	
}