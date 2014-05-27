package famous.inputs;

import famous.core.EventHandler;
import famous.inputs.MouseSync.MouseSyncPayload;
import famous.transitions.Transitionable;

/**
 * Accumulates differentials of event sources that emit a `delta`
 *  attribute taking a Number or Array of Number types. The accumulated
 *  value is stored in a getter/setter.
 */
class Accumulator {
	
	var _state:Dynamic;
	
	var _eventInput:EventHandler;
	
    /**
     * @constructor
     * @param value {Number|Array|Transitionable}   Initializing value
     * @param [eventName='update'] {String}         Name of update event
     */
	public function new(value:Dynamic, ?eventName:String) {
        if (eventName == null) eventName = 'update';

        this._state = (value != null && value.get != null && value.set != null)
            ? value
            : new Transitionable(value != null? value : 0);

        this._eventInput = new EventHandler();
		
        EventHandler.setInputHandler(this, this._eventInput);

        this._eventInput.on(eventName, _handleUpdate);
	}
	
    function _handleUpdate(data:MouseSyncPayload) {
        var delta = data.delta;
        var state = this.get();
		
        if (Type.getClass(delta) == Type.getClass(state)) {
            var newState:Dynamic = Std.is(delta, Array)
                ? [state[0] + delta[0], state[1] + delta[1]]
                : cast(state, Int) + cast(delta, Int);
            this.set(newState);
        }
    }

    /**
     * Basic getter
     *
     * @method get
     * @return {Number|Array} current value
     */
    public function get() {
        return this._state.get();
    };

    /**
     * Basic setter
     *
     * @method set
     * @param value {Number|Array} new value
     */
    public function set(value) {
        this._state.set(value);
    }
	
}