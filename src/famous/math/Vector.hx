package famous.math;

/**
 * Three-element floating point vector.
 */
class Vector {
	
	static var _register = new Vector(0, 0, 0);
	
	public var x:Float;
	public var y:Float;
	public var z:Float;
	
    /**
     * @constructor
     *
     * @param {number} x x element value
     * @param {number} y y element value
     * @param {number} z z element value
     */
	public function new(?x:Float, ?y:Float, ?z:Float) {
		this.x = x != null? x : 0;
		this.y = y != null? y : 0;
		this.z = z != null? z : 0;
	}
	
    /**
     * Add this element-wise to another Vector, element-wise.
     *   Note: This sets the internal result register, so other references to that vector will change.
     *
     * @method add
     * @param {Vector} v addend
     * @return {Vector} vector sum
     */
    public function add(v:Vector):Vector {
        return Reflect.callMethod(_register, _setXYZ, [
            this.x + v.x,
            this.y + v.y,
            this.z + v.z
        ]);
    }

    /**
     * Subtract another vector from this vector, element-wise.
     *   Note: This sets the internal result register, so other references to that vector will change.
     *
     * @method sub
     * @param {Vector} v subtrahend
     * @return {Vector} vector difference
     */
	public function sub(v:Vector):Vector {
        return Reflect.callMethod(_register, _setXYZ, [
            this.x - v.x,
            this.y - v.y,
            this.z - v.z
        ]);
    }

    /**
     * Scale Vector by floating point r.
     *   Note: This sets the internal result register, so other references to that vector will change.
     *
     * @method mult
     *
     * @param {number} r scalar
     * @return {Vector} vector result
     */
    public function mult(r:Float):Vector {
        return Reflect.callMethod(_register, _setXYZ, [
            r * this.x,
            r * this.y,
            r * this.z
        ]);
    }

    /**
     * Scale Vector by floating point 1/r.
     *   Note: This sets the internal result register, so other references to that vector will change.
     *
     * @method div
     *
     * @param {number} r scalar
     * @return {Vector} vector result
     */
    public function div(r:Float):Vector {
        return this.mult(1 / r);
    }

    /**
     * Given another vector v, return cross product (v)x(this).
     *   Note: This sets the internal result register, so other references to that vector will change.
     *
     * @method cross
     * @param {Vector} v Left Hand Vector
     * @return {Vector} vector result
     */
    public function cross(v:Vector):Vector {
        var x = this.x;
        var y = this.y;
        var z = this.z;
        var vx = v.x;
        var vy = v.y;
        var vz = v.z;

        return Reflect.callMethod(_register, _setXYZ, [
            z * vy - y * vz,
            x * vz - z * vx,
            y * vx - x * vy
        ]);
    }

    /**
     * Component-wise equality test between this and Vector v.
     * @method equals
     * @param {Vector} v vector to compare
     * @return {boolean}
     */
	public function equals(v:Vector):Bool {
        return (v.x == this.x && v.y == this.y && v.z == this.z);
    }

    /**
     * Rotate clockwise around x-axis by theta radians.
     *   Note: This sets the internal result register, so other references to that vector will change.
     * @method rotateX
     * @param {number} theta radians
     * @return {Vector} rotated vector
     */
	public function rotateX(theta:Float):Vector {
        var x = this.x;
        var y = this.y;
        var z = this.z;

        var cosTheta = Math.cos(theta);
        var sinTheta = Math.sin(theta);

        return Reflect.callMethod(_register, _setXYZ, [
            x,
            y * cosTheta - z * sinTheta,
            y * sinTheta + z * cosTheta
        ]);
    }

    /**
     * Rotate clockwise around y-axis by theta radians.
     *   Note: This sets the internal result register, so other references to that vector will change.
     * @method rotateY
     * @param {number} theta radians
     * @return {Vector} rotated vector
     */
    public function rotateY(theta:Float):Vector {
        var x = this.x;
        var y = this.y;
        var z = this.z;

        var cosTheta = Math.cos(theta);
        var sinTheta = Math.sin(theta);

        return Reflect.callMethod(_register, _setXYZ, [
            z * sinTheta + x * cosTheta,
            y,
            z * cosTheta - x * sinTheta
        ]);
    }

    /**
     * Rotate clockwise around z-axis by theta radians.
     *   Note: This sets the internal result register, so other references to that vector will change.
     * @method rotateZ
     * @param {number} theta radians
     * @return {Vector} rotated vector
     */
    public function rotateZ(theta:Float):Vector {
        var x = this.x;
        var y = this.y;
        var z = this.z;

        var cosTheta = Math.cos(theta);
        var sinTheta = Math.sin(theta);

        return Reflect.callMethod(_register, _setXYZ, [
            x * cosTheta - y * sinTheta,
            x * sinTheta + y * cosTheta,
            z
        ]);
    }

    /**
     * Return dot product of this with a second Vector
     * @method dot
     * @param {Vector} v second vector
     * @return {number} dot product
     */
    public function dot(v:Vector):Float {
        return this.x * v.x + this.y * v.y + this.z * v.z;
    }

    /**
     * Return squared length of this vector
     * @method normSquared
     * @return {number} squared length
     */
	public function normSquared():Float {
        return this.dot(this);
    }

    /**
     * Return length of this vector
     * @method norm
     * @return {number} length
     */
	public function norm():Float {
        return Math.sqrt(this.normSquared());
    }

    /**
     * Scale Vector to specified length.
     *   If length is less than internal tolerance, set vector to [length, 0, 0].
     *   Note: This sets the internal result register, so other references to that vector will change.
     * @method normalize
     *
     * @param {number} length target length, default 1.0
     * @return {Vector}
     */
	public function normalize(?length:Float):Vector {
        if (length == null) length = 1;
        var norm = this.norm();

        if (norm > 1e-7) {
			return Reflect.callMethod(_register, _setFromVector, [this.mult(length / norm)]);
		} else {
			return Reflect.callMethod(_register, _setXYZ, [length, 0, 0]);
		}
    }

    /**
     * Make a separate copy of the Vector.
     *
     * @method clone
     *
     * @return {Vector}
     */
	public function clone():Vector {
        return new Vector().set(this);
    }

    /**
     * True if and only if every value is 0 (or falsy)
     *
     * @method isZero
     *
     * @return {boolean}
     */
	public function isZero():Bool {
        return !(this.x != 0 || this.y != 0 || this.z != 0);
    }

	private function _setXYZ(x:Float, y:Float, z:Float):Vector {
        this.x = x;
        this.y = y;
        this.z = z;
        return this;
    }

    private function _setFromArray(v:Array<Float>):Vector {
        return _setXYZ(v[0], v[1], v[2] != null? v[2] : 0);
    }

    private function _setFromVector(v:Vector):Vector {
        return _setXYZ(v.x, v.y, v.z);
    }

    private function _setFromNumber(x:Float):Vector {
        return _setXYZ(x, 0, 0);
    }

    /**
     * Set this Vector to the values in the provided Array or Vector.
     *
     * @method set
     * @param {object} v array, Vector, or number
     * @return {Vector} this
     */
    public function set(v:Dynamic):Vector {
        if (Std.is(v, Array)) {
			return _setFromArray(v);
		}
        if (Std.is(v, Vector)) {
			return _setFromVector(v);
		}
        if (Std.is(v, Float)) {
			return _setFromNumber(v);
		}
		return null;
    }

    public function setXYZ(x:Float, y:Float, z:Float) {
        return _setXYZ(x, y, z);
    }

    public function set1D(x:Float) {
        return _setFromNumber(x);
    }

    /**
     * Put result of last internal register calculation in specified output vector.
     *
     * @method put
     * @param {Vector} v destination vector
     * @return {Vector} destination vector
     */
    public function put(v) {
        Reflect.callMethod(v, _setFromVector, [_register]);
    }

    /**
     * Set this vector to [0,0,0]
     *
     * @method clear
     */
    public function clear() {
        return _setXYZ(0, 0, 0);
    }

    /**
     * Scale this Vector down to specified "cap" length.
     *   If Vector shorter than cap, or cap is Infinity, do nothing.
     *   Note: This sets the internal result register, so other references to that vector will change.
     *
     * @method cap
     * @return {Vector} capped vector
     */
    public function cap(cap) {
        if (cap == Math.POSITIVE_INFINITY) {
			return Reflect.callMethod(_register, _setFromVector, [this]);
		}
        var norm = this.norm();
        if (norm > cap) {
			return Reflect.callMethod(_register, _setFromVector, [this.mult(cap / norm)]);
		} else {
			return Reflect.callMethod(_register, _setFromVector, [this]);
		}
    }

    /**
     * Return projection of this Vector onto another.
     *   Note: This sets the internal result register, so other references to that vector will change.
     *
     * @method project
     * @param {Vector} n vector to project upon
     * @return {Vector} projected vector
     */
    public function project(n:Vector):Vector {
        return n.mult(this.dot(n));
    }

    /**
     * Reflect this Vector across provided vector.
     *   Note: This sets the internal result register, so other references to that vector will change.
     *
     * @method reflectAcross
     * @param {Vector} n vector to reflect across
     * @return {Vector} reflected vector
     */
    public function reflectAcross(n:Vector):Vector {
        n.normalize().put(n);
        return Reflect.callMethod(_register, _setFromVector, [this.sub(this.project(n).mult(2))]);
    }

    /**
     * Convert Vector to three-element array.
     *
     * @method get
     * @return {array<number>} three-element array
     */
    public function get() {
        return [this.x, this.y, this.z];
    }

	public function get1D () {
        return this.x;
    }
}