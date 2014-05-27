package famous.math;

/**
 * Very simple uniform random number generator library wrapping Math.random().
 */
class Random {
	
	static var RAND = Math.random;
	
    static function _randomFloat(min:Float, max:Float):Float {
        return min + RAND() * (max - min);
    }

    static function _randomInteger(min:Int, max:Int):Int {
        return Std.int(min + RAND() * (max - min + 1));
    }

    /**
     * Get single random integer between min and max (inclusive), or array
     *   of size dim if specified.
     *
     * @method integer
     *
     * @param {Number} min lower bound, default 0
     * @param {Number} max upper bound, default 1
     * @param {Number} dim (optional) dimension of output array, if specified
     * @return {number | array<number>} random integer, or optionally, an array of random integers
     */
    static public function integer(?min:Int, ?max:Int, ?dim:Int):Dynamic {
        min = (min != null) ? min : 0;
        max = (max != null) ? max : 1;
        if (dim != null) {
            var result = [];
            for (i in 0...dim) {
				result.push(_randomInteger(min, max));
			}
            return result;
        }
        else return _randomInteger(min, max);
    }

    /**
     * Get single random float between min and max (inclusive), or array
     *   of size dim if specified
     *
     * @method range
     *
     * @param {Number} min lower bound, default 0
     * @param {Number} max upper bound, default 1
     * @param {Number} [dim] dimension of output array, if specified
     * @return {Number} random float, or optionally an array
     */
    static public function range(?min:Float, ?max:Float, ?dim:Int):Dynamic {
        min = (min != null) ? min : 0;
        max = (max != null) ? max : 1;
        if (dim != null) {
            var result = [];
            for (i in 0...dim) {
				result.push(_randomFloat(min,max));
			}
            return result;
        }
        else return _randomFloat(min, max);
    }

    /**
     * Return random number among the set {-1 ,1}
     *
     * @method sign
     *
     * @param {Number} prob probability of returning 1, default 0.5
     * @return {Number} random sign (-1 or 1)
     */
    static public function sign(?prob:Float):Int {
        prob = (prob != null) ? prob : 0.5;
        return (RAND() < prob) ? 1 : -1;
    }

    /**
     * Return random boolean value, true or false.
     *
     * @method bool
     *
     * @param {Number} prob probability of returning true, default 0.5
     * @return {Boolean} random boolean
     */
    static public function bool(?prob:Float):Bool {
        prob = (prob != null) ? prob : 0.5;
        return RAND() < prob;
    }
	
}