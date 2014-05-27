package famous.events;

import famous.core.EventEmitter;
import famous.core.EventHandler;

/**
 * A switch which wraps several event destinations and
 *  redirects received events to at most one of them.
 *  Setting the 'mode' of the object dictates which one
 *  of these destinations will receive events.
 */
class EventArbiter {

	var dispatchers:Map<String, EventHandler>;
	var currMode:String = null;
	
    /**
     * @constructor
     *
     * @param {Number | string} startMode initial setting of switch,
     */
	public function new(startMode:String) {
		this.dispatchers = new Map();
        this.currMode = null;
        this.setMode(startMode);
	}
	
    /**
     * Set switch to this mode, passing events to the corresponding
     *   EventHandler.  If mode has changed, emits 'change' event,
     *   emits 'unpipe' event to the old mode's handler, and emits 'pipe'
     *   event to the new mode's handler.
     *
     * @method setMode
     *
     * @param {string | number} mode indicating which event handler to send to.
     */
    public function setMode(mode:String) {
        if (mode != this.currMode) {
            var startMode = this.currMode;

            if (this.dispatchers[this.currMode] != null) {
				this.dispatchers[this.currMode].trigger('unpipe', null);
			}
            this.currMode = mode;
            if (this.dispatchers[mode] != null) {
				this.dispatchers[mode].emit('pipe', null);
			}
            this.emit('change', {from: startMode, to: mode});
        }
    }

    /**
     * Return the existing EventHandler corresponding to this
     *   mode, creating one if it doesn't exist.
     *
     * @method forMode
     *
     * @param {string | number} mode mode to which this eventHandler corresponds
     *
     * @return {EventHandler} eventHandler corresponding to this mode
     */
    public function forMode(mode:String):EventHandler {
        if (this.dispatchers[mode] == null) {
			this.dispatchers[mode] = new EventHandler();
		}
        return this.dispatchers[mode];
    }

    /**
     * Trigger an event, sending to currently selected handler, if
     *   it is listening for provided 'type' key.
     *
     * @method emit
     *
     * @param {string} eventType event type key (for example, 'click')
     * @param {Object} event event data
     * @return {EventHandler} this
     */
    public function emit(eventType:String, ?event:Dynamic):EventEmitter {
        if (this.currMode == null) {
			return null;
		}
        if (event == null) {
			event = {};
		}
        var dispatcher = this.dispatchers[this.currMode];
        if (dispatcher != null) {
			return dispatcher.trigger(eventType, event);
		}
		return null;
    }
}