package famous.core;

typedef HandlerFunc = Dynamic -> Void;

/**
 * EventEmitter represents a channel for events.
 */
class EventEmitter {
	
	public var listeners:Map<String, Array<HandlerFunc> >;
	var _owner:Dynamic;
		
    /**
     * @class EventEmitter
     * @constructor
     */
	public function new() {
		listeners = new Map();
		this._owner = this;
	}

    /**
     * Trigger an event, sending to all downstream handlers
     *   listening for provided 'type' key.
     *
     * @method emit
     *
     * @param {string} type event type key (for example, 'click')
     * @param {Object} event event data
     * @return {HandlerFunc} this
     */
    public function emit(type:String, ?event:Dynamic):EventEmitter {
        var handlers = this.listeners[type];
        if (handlers != null) {
            for (fn in handlers) {
                Reflect.callMethod(_owner, fn, [event]);
            }
        }
        return this;
    }

    /**
     * Bind a callback function to an event type handled by this object.
     *
     * @method "on"
     *
     * @param {string} type event type key (for example, 'click')
     * @param {function(string, Object)} handler callback
     * @return {HandlerFunc} this
     */
	public function on(type:String, handler:HandlerFunc):EventEmitter {
        if (!this.listeners.exists(type)) {
			this.listeners[type] = [];
		}
        var index = this.listeners[type].indexOf(handler);
        if (index < 0) {
			this.listeners[type].push(handler);
		}
        return this;
    }

    /**
     * Alias for "on".
     * @method addListener
     */
    inline public function addListener(type:String, handler:HandlerFunc):EventEmitter {
		return on(type, handler);
	}

	/**
     * Unbind an event by type and handler.
     *   This undoes the work of "on".
     *
     * @method removeListener
     *
     * @param {string} type event type key (for example, 'click')
     * @param {function} handler function object to remove
     * @return {EventEmitter} this
     */
    public function removeListener(type:String, handler:HandlerFunc):EventEmitter {
        var index = this.listeners[type].indexOf(handler);
        if (index >= 0) {
			this.listeners[type].splice(index, 1);
		}
        return this;
    }

    /**
     * Call event handlers with this set to owner.
     *
     * @method bindThis
     *
     * @param {Object} owner object this EventEmitter belongs to
     */
    public function bindThis(owner:Dynamic) {
        this._owner = owner;
    }
	
}