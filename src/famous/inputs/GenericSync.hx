package famous.inputs;

import famous.core.DynamicMap;
import famous.core.EventHandler;

/**
 * Combines multiple types of sync classes (e.g. mouse, touch,
 *  scrolling) into one standardized interface for inclusion in widgets.
 *
 *  Sync classes are first registered with a key, and then can be accessed
 *  globally by key.
 *
 *  Emits 'start', 'update' and 'end' events as a union of the sync class
 *  providers.
 */
class GenericSync extends EventHandleable {

    static public var DIRECTION_X = 0;
    static public var DIRECTION_Y = 1;
    static public var DIRECTION_Z = 2;

    // Global registry of sync classes. Append only.
    static var registry:DynamicMap = {};
	
	var _eventInput:EventHandler;
	var _eventOutput:EventHandler;
	
	var _syncs:DynamicMap;
	
    /**
     * @constructor
     * @param syncs {Object|Array} object with fields {sync key : sync options}
     *    or an array of registered sync keys
     * @param [options] {Object|Array} options object to set on all syncs
     */
	public function new(?syncs:Dynamic, ?options:Dynamic) {
        this._eventInput = new EventHandler();
        this._eventOutput = new EventHandler();

        EventHandler.setInputHandler(this, this._eventInput);
        EventHandler.setOutputHandler(this, this._eventOutput);

        this._syncs = {};
        if (syncs != null) this.addSync(syncs);
        if (options != null) this.setOptions(options);
	}
	
    /**
     * Register a global sync class with an identifying key
     *
     * @static
     * @method register
     *
     * @param syncObject {Object} an object of {sync key : sync options} fields
     */
    static public function register(syncObject:Dynamic) {
        for (key in Reflect.fields(syncObject)){
            if (registry[key] != null){
                if (registry[key] == syncObject[cast key]) return; // redundant registration
                else throw 'this key is registered to a different sync class';
            }
            else registry[key] = syncObject[cast key];
        }
    }

    /**
     * Helper to set options on all sync instances
     *
     * @method setOptions
     * @param options {Object} options object
     */
	public function setOptions(options:Dynamic) {
        for (key in this._syncs.keys()) {
            this._syncs[key].setOptions(options);
        }
    }

    /**
     * Pipe events to a sync class
     *
     * @method pipeSync
     * @param key {String} identifier for sync class
     */
    public function pipeSync(key:String) {
        var sync = this._syncs[key];
        this._eventInput.pipe(sync);
        sync.pipe(this._eventOutput);
    }

    /**
     * Unpipe events from a sync class
     *
     * @method unpipeSync
     * @param key {String} identifier for sync class
     */
    public function unpipeSync(key:String) {
        var sync = this._syncs[key];
        this._eventInput.unpipe(sync);
        sync.unpipe(this._eventOutput);
    }

    function _addSingleSync(key, ?options) {
        if (registry[key] == null) return;
        this._syncs[key] = Type.createInstance(registry[key], [options]);
        this.pipeSync(key);
    }

    /**
     * Add a sync class to from the registered classes
     *
     * @method addSync
     * @param syncs {Object|Array.String} an array of registered sync keys
     *    or an object with fields {sync key : sync options}
     */
    public function addSync(syncs:Dynamic) {
        if (Std.is(syncs, Array)) {
			var _syncs:Array<Dynamic> = cast syncs;
            for (sync in _syncs) {
                _addSingleSync(sync);
			}
		}
        else if (Reflect.isObject(syncs)) {
            for (key in Reflect.fields(syncs)) {
                _addSingleSync(key, syncs[cast key]);
			}
		}
    }
}