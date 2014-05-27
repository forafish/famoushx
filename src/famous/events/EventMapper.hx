package famous.events;

import famous.core.EventEmitter;
import famous.core.EventHandler;

typedef MappingFunc = String -> Dynamic -> EventHandler;

/**
 * EventMapper routes events to various event destinations
 *  based on custom logic.  The function signature is arbitrary.
 */
class EventMapper extends EventHandler {
	
	var _mappingFunction:MappingFunc;
	
    /**
     * @constructor
     *
     * @param {function} mappingFunction function to determine where
     *  events are routed to.
     */
	public function new(mappingFunction:MappingFunc) {
		super();
		this._mappingFunction = mappingFunction;
		this.subscribe = null;
		this.unsubscribe = null;
	}
	
    /**
     * Trigger an event, sending to all mapped downstream handlers
     *   listening for provided 'type' key.
     *
     * @method emit
     *
     * @param {string} type event type key (for example, 'click')
     * @param {Object} data event data
     * @return {EventHandler} this
     */
    override public function emit(type, ?data):EventEmitter {
        var target = this._mappingFunction(type, data);
        if (target != null && Reflect.isFunction(target.emit)) {
			return target.emit(type, data);
		}
		return this;
    }
	
}
