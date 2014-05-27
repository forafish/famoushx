package famous.math;

/**
 * A few static methods.
 */
class Utilities {

    /**
     * Constrain input to range.
     *
     * @method clamp
     * @param {Number} value input
     * @param {Array.Number} range [min, max]
     * @static
     */
    static public function clamp(value:Float, range:Array<Float>):Float {
        return Math.max(Math.min(value, range[1]), range[0]);
    };

    /**
     * Euclidean length of numerical array.
     *
     * @method length
     * @param {Array.Number} array array of numbers
     * @static
     */
    static public function length(array:Array<Float>):Float {
        var distanceSquared:Float = 0;
        for (a in array) {
            distanceSquared += a * a;
        }
        return Math.sqrt(distanceSquared);
    }
	
	static public function toFixed(x:Float, precision:Int):Float {
		var prec = Math.pow(10, precision);
		return Std.int(x * prec) / prec;
	}
	
}