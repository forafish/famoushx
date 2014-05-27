package famous.core;

/**
 * A singleton that maintains a global registry of Surfaces.
 *   Private.
 */
class Entity {

	static var entities:Array<Dynamic> = [];
	
    /**
     * Get entity from global index.
     *
     * @private
     * @method get
     * @param {Number} id entity reigstration id
     * @return {Surface} entity in the global index
     */
    static public function get(id:Int):Dynamic {
        return entities[id];
    }

    /**
     * Overwrite entity in the global index
     *
     * @private
     * @method set
     * @param {Number} id entity reigstration id
     * @return {Surface} entity to add to the global index
     */
    static public function set(id:Int, entity:Dynamic) {
        entities[id] = entity;
    }

    /**
     * Add entity to global index
     *
     * @private
     * @method register
     * @param {Surface} entity to add to global index
     * @return {Number} new id
     */
    static public function register(entity:Dynamic):Int {
        var id = entities.length;
        set(id, entity);
        return id;
    }

    /**
     * Remove entity from global index
     *
     * @private
     * @method unregister
     * @param {Number} id entity reigstration id
     */
    static public function unregister(id:Int) {
        set(id, null);
    }	
	
}