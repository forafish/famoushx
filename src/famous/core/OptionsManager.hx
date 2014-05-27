package famous.core;

import famous.core.EventEmitter.HandlerFunc;

/**
 *  A collection of methods for setting options which can be extended
 *  onto other classes.
 *
 *
 *  **** WARNING ****
 *  You can only pass through objects that will compile into valid JSON.
 *
 *  Valid options:
 *      Strings,
 *      Arrays,
 *      Objects,
 *      Numbers,
 *      Nested Objects,
 *      Nested Arrays.
 *
 *    This excludes:
 *        Document Fragments,
 *        Functions
 */
class OptionsManager {
	
	var _value:Options;
	var eventOutput:Dynamic;
	
    /**
     * @class OptionsManager
     * @constructor
     * @param {Object} value options dictionary
     */
	public function new(value:Options) {
        this._value = value;
        this.eventOutput = null;
	}
	
    /**
     * Create options manager from source dictionary with arguments overriden by patch dictionary.
     *
     * @static
     * @method OptionsManager.patch
     *
     * @param {Object} source source arguments
     * @param {...Object} data argument additions and overwrites
     * @return {Object} source object
     */
    static public function patchObject(source:Dynamic, datas:Array<Dynamic>) {
        var manager = new OptionsManager(source);
        for (data in datas) {
			manager.patch(data);
		}
        return source;
    }

    function _createEventOutput() {
        this.eventOutput = new EventHandler();
        this.eventOutput.bindThis(this);
        EventHandler.setOutputHandler(this, this.eventOutput);
    }

    /**
     * Create OptionsManager from source with arguments overriden by patches.
     *   Triggers 'change' event on this object's event handler if the state of
     *   the OptionsManager changes as a result.
     *
     * @method patch
     *
     * @param {...Object} arguments list of patch objects
     * @return {OptionsManager} this
     */
    public function patch(datas:Array<Options>) {
        var myState = this._value;
        for (data in datas) {
            for (k in data.keys()) {
				var b = Std.is([1, 2], { } );
                if (myState.exists(k) && (data[k] != null && Std.is(data[k], {})) 
						&& (myState[k] != null && Std.is(myState[k], {}))) {
                    myState[k] = Reflect.copy(myState[k]);
                    this.key(k).patch(data[k]);
                    if (this.eventOutput) {
						this.eventOutput.emit('change', {id: k, value: this.key(k).value()});
					}
                } else {
					this.set(k, data[k]);
				}
            }
        }
        return this;
    }

    /**
     * Alias for patch
     *
     * @method setOptions
     *
     */
	inline public function setOptions(datas:Options) {
		patch([datas]);
	}

    /**
     * Return OptionsManager based on sub-object retrieved by key
     *
     * @method key
     *
     * @param {string} identifier key
     * @return {OptionsManager} new options manager with the value
     */
    public function key(identifier:String):OptionsManager {
        var result = new OptionsManager(Reflect.field(this._value, identifier));
        if (!Reflect.isObject(result) || Std.is(result._value, Array)) {
			result._value = {};
		}
        return result;
    }

    /**
     * Look up value by key
     * @method get
     *
     * @param {string} key key
     * @return {Object} associated object
     */
	public function get(key:String) {
        return Reflect.field(this._value, key);
    }

    /**
     * Alias for get
     * @method getOptions
     */
	inline public function getOptions(key:String) {
		return get(key);
	}

    /**
     * Set key to value.  Outputs 'change' event if a value is overwritten.
     *
     * @method set
     *
     * @param {string} key key string
     * @param {Object} value value object
     * @return {OptionsManager} new options manager based on the value object
     */
    public function set(key:String, value:Dynamic) {
        var originalValue = this.get(key);
        Reflect.setField(this._value, key, value);
        if (this.eventOutput != null && value != originalValue) {
			this.eventOutput.emit('change', {id: key, value: value});
		}
        return this;
    }

    /**
     * Return entire object contents of this OptionsManager.
     *
     * @method value
     *
     * @return {Object} current state of options
     */
    public function value():Dynamic {
        return this._value;
    }

    /**
     * Bind a callback function to an event type handled by this object.
     *
     * @method "on"
     *
     * @param {string} type event type key (for example, 'change')
     * @param {function(string, Object)} handler callback
     * @return {EventHandler} this
     */
    public function on(type:String, handler:HandlerFunc):EventHandler {
        _createEventOutput();
        return this.on(type, handler);
    }

    /**
     * Unbind an event by type and handler.
     *   This undoes the work of "on".
     *
     * @method removeListener
     *
     * @param {string} type event type key (for example, 'change')
     * @param {function} handler function object to remove
     * @return {EventHandler} internal event handler object (for chaining)
     */
    public function removeListener(type:String, handler:HandlerFunc):EventHandler {
        _createEventOutput();
        return this.removeListener(type, handler);
    }

    /**
     * Add event handler object to set of downstream handlers.
     *
     * @method pipe
     *
     * @param {EventHandler} target event handler target object
     * @return {EventHandler} passed event handler
     */
	public function pipe(target:Dynamic):EventHandler {
        _createEventOutput();
        return this.pipe(target);
    }

    /**
     * Remove handler object from set of downstream handlers.
     * Undoes work of "pipe"
     *
     * @method unpipe
     *
     * @param {EventHandler} target target handler object
     * @return {EventHandler} provided target
     */
    public function unpipe(target:Dynamic):EventHandler {
        _createEventOutput();
        return this.unpipe(target);
    }
	
}