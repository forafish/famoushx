package famous.core;

import famous.core.EventEmitter;

typedef TriggerFunc = String -> Dynamic -> EventEmitter;


class EventHandleable {
	public var on:String -> HandlerFunc -> EventEmitter;
	public var pipe:Dynamic -> Dynamic;
	public var unpipe:Dynamic -> Dynamic;
	public var addListener:String -> HandlerFunc -> EventEmitter;
	public var removeListener:String -> HandlerFunc -> EventEmitter;
	
	public var subscribe:Dynamic -> EventEmitter;
	public var unsubscribe:Dynamic -> EventEmitter;
}

/**
 * EventHandler forwards received events to a set of provided callback functions.
 * It allows events to be captured, processed, and optionally piped through to other event handlers.
 * 
 * @extends EventEmitter
 */
class EventHandler extends EventEmitter {

	var downstream:Array<{trigger:TriggerFunc}>; // downstream event handlers
	var downstreamFn:Array<TriggerFunc>; // downstream functions

	var upstream:Array<Dynamic>; // upstream event handlers
	var upstreamListeners:Map<String, HandlerFunc>; // upstream listeners
	
    /**
     * @class EventHandler
     * @constructor
     */
	public function new() {
		super();
		
        this.downstream = [];
        this.downstreamFn = [];

        this.upstream = [];
        this.upstreamListeners = new Map();
	}
	
    /**
     * Assign an event handler to receive an object's input events.
     *
     * @method setInputHandler
     * @static
     *
     * @param {Object} object object to mix trigger, subscribe, and unsubscribe functions into
     * @param {EventHandler} handler assigned event handler
     */
    static public function setInputHandler(object:Dynamic, handler:Dynamic) {
        object.trigger = handler.trigger;
        if (handler.subscribe != null && handler.unsubscribe != null) {
            object.subscribe = handler.subscribe.bind(handler);
            object.unsubscribe = handler.unsubscribe.bind(handler);
        }
    }

    /**
     * Assign an event handler to receive an object's output events.
     *
     * @method setOutputHandler
     * @static
     *
     * @param {Object} object object to mix pipe, unpipe, on, addListener, and removeListener functions into
     * @param {EventHandler} handler assigned event handler
     */
    static public function setOutputHandler(object:Dynamic, handler:Dynamic) {
		handler.bindThis(object);
        object.pipe = handler.pipe.bind(handler);
        object.unpipe = handler.unpipe.bind(handler);
        object.on = handler.on.bind(handler);
        object.addListener = object.on.bind(handler);//?? handler.on;
        object.removeListener = handler.removeListener.bind(handler);
    }

    /**
     * Trigger an event, sending to all downstream handlers
     *   listening for provided 'type' key.
     *
     * @method emit
     *
     * @param {string} type event type key (for example, 'click')
     * @param {Object} event event data
     * @return {EventHandler} this
     */
    override public function emit(type:String, ?event:Dynamic):EventEmitter {
        super.emit(type, event);
        for (ds in downstream) {
            if (ds.trigger != null) {
				ds.trigger(type, event);
			}
        }
        for (fn in downstreamFn) {
            fn(type, event);
        }
        return this;
    }

    /**
     * Alias for emit
     * @method addListener
     */
	inline public function trigger(type:String, event:Dynamic):EventEmitter {
		return emit(type, event);
	}
	
    /**
     * Add event handler object to set of downstream handlers.
     *
     * @method pipe
     *
     * @param {EventHandler} target event handler target object
     * @return {EventHandler} passed event handler
     */
    public function pipe(target:Dynamic) {
        if (Reflect.isFunction(target.subscribe)) {
			return target.subscribe(this);
		}

        var downstreamCtx:Array<Dynamic> = Reflect.isFunction(target) ? this.downstreamFn : this.downstream;
        var index = downstreamCtx.indexOf(target);
        if (index < 0) {
			downstreamCtx.push(target);
		}

        if (Reflect.isFunction(target)) {
			target('pipe', null);
		}
        else if (target.trigger) {
			target.trigger('pipe', null);
		}

        return target;
    }

    /**
     * Remove handler object from set of downstream handlers.
     *   Undoes work of "pipe".
     *
     * @method unpipe
     *
     * @param {EventHandler} target target handler object
     * @return {EventHandler} provided target
     */
    public function unpipe(target:Dynamic):EventHandler {
        if (Reflect.isFunction(target.unsubscribe)) {
			return target.unsubscribe(this);
		}

        var downstreamCtx:Array<Dynamic> = Reflect.isFunction(target) ? this.downstreamFn : this.downstream;
        var index = downstreamCtx.indexOf(target);
        if (index >= 0) {
            downstreamCtx.splice(index, 1);
            if (Reflect.isFunction(target)) {
				target('unpipe', null);
			}
            else if (target.trigger) {
				target.trigger('unpipe', null);
			}
            return target;
        }
        else {
			return null;
		}
    }

    /**
     * Bind a callback function to an event type handled by this object.
     *
     * @method "on"
     *
     * @param {string} type event type key (for example, 'click')
     * @param {function(string, Object)} handler callback
     * @return {EventHandler} this
     */
	override public function on(type:String, handler:HandlerFunc):EventEmitter {
        super.on(type, handler);
        if (!this.upstreamListeners.exists(type)) {
            var upstreamListener:HandlerFunc = this.trigger.bind(type);
            this.upstreamListeners[type] = upstreamListener;
            for (h in this.upstream) {
                h.on(type, upstreamListener);
            }
        }
        return this;
    }

    /**
     * Listen for events from an upstream event handler.
     *
     * @method subscribe
     *
     * @param {EventEmitter} source source emitter object
     * @return {EventHandler} this
     */
    dynamic public function subscribe(source:Dynamic):EventHandler {
        var index = this.upstream.indexOf(source);
        if (index < 0) {
            this.upstream.push(source);
            for (type in this.upstreamListeners.keys()) {
                source.on(type, this.upstreamListeners[type]);
            }
        }
        return this;
    }

    /**
     * Stop listening to events from an upstream event handler.
     *
     * @method unsubscribe
     *
     * @param {EventEmitter} source source emitter object
     * @return {EventHandler} this
     */
	dynamic public function unsubscribe(source:Dynamic):EventHandler {
        var index = this.upstream.indexOf(source);
        if (index >= 0) {
            this.upstream.splice(index, 1);
            for (type in this.upstreamListeners.keys()) {
                source.removeListener(type, this.upstreamListeners[type]);
            }
        }
        return this;
    }
	
}