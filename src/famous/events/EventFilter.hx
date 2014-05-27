package famous.events;
import famous.core.EventEmitter;
import famous.core.EventHandler;

typedef ConditionFunc = String -> Dynamic -> Bool;

/**
 * EventFilter regulates the broadcasting of events based on
 *  a specified condition function of standard event type: function(type, data).
 */
class EventFilter extends EventHandler {
	
	var _condition:ConditionFunc;
	
    /**
     * @constructor
     *
     * @param {function} condition function to determine whether or not
     *    events are emitted.
     */
	public function new(condition:ConditionFunc) {
		super();
		
		this._condition = condition;
	}
	
    /**
     * If filter condition is met, trigger an event, sending to all downstream handlers
     *   listening for provided 'type' key.
     *
     * @method emit
     *
     * @param {string} type event type key (for example, 'click')
     * @param {Object} data event data
     * @return {EventHandler} this
     */
    override public function emit(type:String, ?data:Dynamic):EventEmitter {
        if (this._condition(type, data)) {
            return super.emit(type, data);
		}
		return this;
    }
}