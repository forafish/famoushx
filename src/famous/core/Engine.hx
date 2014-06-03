package famous.core;

import famous.core.EventEmitter.HandlerFunc;
import famous.inputs.GenericSync;
import famous.inputs.MouseSync;
import famous.inputs.TouchSync;
import famous.inputs.ScrollSync;

/**
 * The singleton object initiated upon process
 *   startup which manages all active Context instances, runs
 *   the render dispatch loop, and acts as a listener and dispatcher
 *   for events.  All methods are therefore static.
 *
 *   On static initialization, window.requestAnimationFrame is called with
 *     the event loop function.
 *
 *   Note: Any window in which Engine runs will prevent default
 *     scrolling behavior on the 'touchmove' event.
 */
class Engine {

    static var contexts = new Array<Context>();
    static var nextTickQueue = new Array<Void -> Void>();
    static var deferQueue = new Array<Void -> Void>();

    static var lastTime:Float = Date.now().getTime();
    static var frameTime:Float;
    static var frameTimeLimit:Float = Math.floor(1000 / 60);
    static var loopEnabled:Bool = true;
    static var eventForwarders = new Map<String, js.html.EventListener>();
    static var eventHandler = new EventHandler();

    static var options = {
        containerType: 'div',
        containerClass: 'famous-container',
        fpsCap: null,
        runLoop: true
    };
    static var optionsManager = new OptionsManager(options);

    /** @const */
    static var MAX_DEFER_FRAME_TIME = 10;	
		
    /**
     * Inside requestAnimationFrame loop, step() is called, which:
     *   calculates current FPS (throttling loop if it is over limit set in setFPSCap),
     *   emits dataless 'prerender' event on start of loop,
     *   calls in order any one-shot functions registered by nextTick on last loop,
     *   calls Context.update on all Context objects registered,
     *   and emits dataless 'postrender' event on end of loop.
     *
     * @static
     * @private
     * @method step
     */
    static public function step() {
        var currentTime = Date.now().getTime();

        // skip frame if we're over our framerate cap
        if (frameTimeLimit > 0 && currentTime - lastTime < frameTimeLimit) {
			return;
		}

        var i = 0;

        frameTime = currentTime - lastTime;
        lastTime = currentTime;

        eventHandler.emit('prerender');

        // empty the queue
        for (tick in nextTickQueue) {
			tick();
		}
        nextTickQueue.splice(0, nextTickQueue.length);

        // limit total execution time for deferrable functions
        while (deferQueue.length > 0 && (Date.now().getTime() - currentTime) < MAX_DEFER_FRAME_TIME) {
            deferQueue.shift()();
        }

        for (c in contexts) {
			c.update();
		}

        eventHandler.emit('postrender');
    }

    // engage requestAnimationFrame
    static function loop(arg:Float):Bool {
        if (options.runLoop) {
            Engine.step();
            js.Browser.window.requestAnimationFrame(loop);
        } else {
			loopEnabled = false;
		}
		return true;
    }
	static var _staticInitLoop = (function() {
		js.Browser.window.requestAnimationFrame(loop);
		return null;
	})();
    

    //
    // Upon main document window resize (unless on an "input" HTML element):
    //   scroll to the top left corner of the window,
    //   and for each managed Context: emit the 'resize' event and update its size.
    // @param {Object=} event document event
    //
    static public function handleResize(?event:js.html.Event) {
        for (c in contexts) {
            c.emit('resize');
        }
        eventHandler.emit('resize');
    }
	
	static var _staticInitListeners = (function() {
		js.Browser.window.addEventListener('resize', handleResize, false);
		handleResize();

		// prevent scrolling via browser
		//js.Browser.window.addEventListener('touchmove', function(event:js.html.Event) {
		//	event.preventDefault();
		//}, true);
		
		return null;
	})();
	
	static var _staticInitGenericSync = (function() {
		GenericSync.register({
			mouse : MouseSync,
			touch : TouchSync,
			scroll : ScrollSync
		});
		return null;
	})();
	
    /**
     * Add event handler object to set of downstream handlers.
     *
     * @method pipe
     *
     * @param {EventHandler} target event handler target object
     * @return {EventHandler} passed event handler
     */
    static public function pipe(target:Dynamic):EventHandler {
        if (Reflect.isFunction(target.subscribe)) {
			return target.subscribe({
				emit:Engine.emit, 
				on:Engine.on, 
				addListener:null, 
				removeListener:Engine.removeListener
				});
		} else {
			return eventHandler.pipe(target);
		}
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
    static public function unpipe(target:Dynamic):EventHandler {
        if (Reflect.isFunction(target.unsubscribe)) {
			return target.unsubscribe({
				emit:Engine.emit, 
				on:Engine.on, 
				addListener:null, 
				removeListener:Engine.removeListener
				});
		} else {
			return eventHandler.unpipe(target);
		}
    }

    /**
     * Bind a callback function to an event type handled by this object.
     *
     * @static
     * @method "on"
     *
     * @param {string} type event type key (for example, 'click')
     * @param {function(string, Object)} handler callback
     * @return {EventHandler} this
     */
	static public function on(type:String, handler:HandlerFunc) {
        if (!eventForwarders.exists(type)) {
            eventForwarders[type] = eventHandler.emit.bind(type, _);
			if (js.Browser.document.body != null) {
				js.Browser.document.body.addEventListener(type, eventForwarders[type]);
			} else {
				Engine.nextTick(function(type, forwarder) {
					js.Browser.document.body.addEventListener(type, forwarder);
				}.bind(type, eventForwarders[type]));
			}
        }
        return eventHandler.on(type, handler);
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
	static public function emit(type:String, ?event:Dynamic):EventEmitter {
        return eventHandler.emit(type, event);
    }

    /**
     * Unbind an event by type and handler.
     *   This undoes the work of "on".
     *
     * @static
     * @method removeListener
     *
     * @param {string} type event type key (for example, 'click')
     * @param {function} handler function object to remove
     * @return {EventHandler} internal event handler object (for chaining)
     */
    static public function removeListener(type:String, handler:HandlerFunc) {
        return eventHandler.removeListener(type, handler);
    }

    /**
     * Return the current calculated frames per second of the Engine.
     *
     * @static
     * @method getFPS
     *
     * @return {Number} calculated fps
     */
    static public function getFPS():Float {
        return 1000 / frameTime;
    }

    /**
     * Set the maximum fps at which the system should run. If internal render
     *    loop is called at a greater frequency than this FPSCap, Engine will
     *    throttle render and update until this rate is achieved.
     *
     * @static
     * @method setFPSCap
     *
     * @param {Number} fps maximum frames per second
     */
    static public function setFPSCap(fps:Float) {
        frameTimeLimit = Math.floor(1000 / fps);
    }

    /**
     * Return engine options.
     *
     * @static
     * @method getOptions
     * @param {string} key
     * @return {Object} engine options
     */
    static public function getOptions(key:String):Dynamic {
        return optionsManager.getOptions(key);
    }

    /**
     * Set engine options
     *
     * @static
     * @method setOptions
     *
     * @param {Object} [options] overrides of default options
     * @param {Number} [options.fpsCap]  maximum fps at which the system should run
     * @param {boolean} [options.runLoop=true] whether the run loop should continue
     * @param {string} [options.containerType="div"] type of container element.  Defaults to 'div'.
     * @param {string} [options.containerClass="famous-container"] type of container element.  Defaults to 'famous-container'.
     */
	static public function setOptions(options:Array<DynamicMap>) {
        return optionsManager.setOptions(options);
    }

    /**
     * Creates a new Context for rendering and event handling with
     *    provided document element as top of each tree. This will be tracked by the
     *    process-wide Engine.
     *
     * @static
     * @method createContext
     *
     * @param {Node} el will be top of Famo.us document element tree
     * @return {Context} new Context within el
     */
    static public function createContext(?el:js.html.Element):Context {
		var needMountContainer = false;
        if (el == null) {
            el = js.Browser.document.createElement(options.containerType);
            el.classList.add(options.containerClass);
            needMountContainer = true;
        }
        var context = new Context(el);
        Engine.registerContext(context);
		if (needMountContainer) {
			Engine.nextTick(function() {
				js.Browser.document.body.appendChild(el);
				context.emit('resize');
			});
		}
        return context;
    }

    /**
     * Registers an existing context to be updated within the run loop.
     *
     * @static
     * @method registerContext
     *
     * @param {Context} context Context to register
     * @return {FamousContext} provided context
     */
    static public function registerContext(context:Context):Context {
        contexts.push(context);
        return context;
    }

    /**
     * Queue a function to be executed on the next tick of the
     *    Engine.
     *
     * @static
     * @method nextTick
     *
     * @param {function(Object)} fn function accepting window object
     */
    static public function nextTick(fn:Void->Void) {
        nextTickQueue.push(fn);
    }

    /**
     * Queue a function to be executed sometime soon, at a time that is
     *    unlikely to affect frame rate.
     *
     * @static
     * @method defer
     *
     * @param {Function} fn
     */
    static public function defer(fn:Void->Void) {
        deferQueue.push(fn);
    }
	
	static var _staticInitOptionManager = (function() {
		optionsManager.on('change', function(data:Dynamic) {
			if (data.id == 'fpsCap') {
				Engine.setFPSCap(data.value);
			} else if (data.id == 'runLoop') {
				// kick off the loop only if it was stopped
				if (!loopEnabled && data.value != null) {
					loopEnabled = true;
					js.Browser.window.requestAnimationFrame(loop);
				}
			}
		});
		return null;
	})();
}