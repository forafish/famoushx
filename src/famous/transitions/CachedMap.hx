package famous.transitions;

/**
 * A simple in-memory object cache.  Used as a helper for Views with
 * provider functions.
 */
class CachedMap {

	var _map:Dynamic -> Dynamic;
	var _cachedOutput:Dynamic;
	var _cachedInput:Float; //never valid as input
	
    /**
     * @constructor
     */
	public function new(mappingFunction) {
        this._map = mappingFunction != null? mappingFunction : null;
        this._cachedOutput = null;
        this._cachedInput = Math.NaN; //never valid as input
	}
	
    /**
     * Creates a mapping function with a cache.
     * This is the main entrypoint for this object.
     * @static
     * @method create
     * @param {function} mappingFunction mapping
     * @return {function} memoized mapping function
     */
    static public function create(mappingFunction) {
        var instance = new CachedMap(mappingFunction);
        return instance.get;
    }

    /**
     * Retrieve items from cache or from mapping functin.
     *
     * @method get
     * @param {Object} input input key
     */
    public function get(input:Dynamic) {
        if (input != this._cachedInput) {
            this._cachedInput = input;
            this._cachedOutput = this._map(input);
        }
        return this._cachedOutput;
    }
	
}