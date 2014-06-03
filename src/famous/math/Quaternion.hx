package famous.math;

import famous.core.Transform.Matrix4;

/**
 * Docs: TODO
 */
class Quaternion {

	static var register = new Quaternion(1, 0, 0, 0);
    static var conjugation = new Quaternion(1,0,0,0);
    static var matrixRegister = new Matrix();
    static var epsilon = 1e-5;

	public var w:Float;
	public var x:Float;
	public var y:Float;
	public var z:Float;
	
    /**
     * @constructor
     *
     * @param {Number} w
     * @param {Number} x
     * @param {Number} y
     * @param {Number} z
     */
	public function new(?w:Float, ?x:Float, ?y:Float, ?z:Float) {
		this.w = (w != null) ? w : 1;  //Angle
		this.x = (x != null) ? x : 0;  //Axis.x
		this.y = (y != null) ? y : 0;  //Axis.y
		this.z = (z != null) ? z : 0;  //Axis.z
	}
	
    /**
     * Doc: TODO
     * @method add
     * @param {Quaternion} q
     * @return {Quaternion}
     */
    public function add(q:Quaternion):Quaternion {
        return register.setWXYZ(
            this.w + q.w,
            this.x + q.x,
            this.y + q.y,
            this.z + q.z
        );
    }

    /*
     * Docs: TODO
     *
     * @method sub
     * @param {Quaternion} q
     * @return {Quaternion}
     */
    public function sub(q:Quaternion):Quaternion {
        return register.setWXYZ(
            this.w - q.w,
            this.x - q.x,
            this.y - q.y,
            this.z - q.z
        );
    }

    /**
     * Doc: TODO
     *
     * @method scalarDivide
     * @param {Number} s
     * @return {Quaternion}
     */
    public function scalarDivide(s:Float):Quaternion {
        return this.scalarMultiply(1/s);
    }

    /*
     * Docs: TODO
     *
     * @method scalarMultiply
     * @param {Number} s
     * @return {Quaternion}
     */
    public function scalarMultiply(s:Float):Quaternion {
        return register.setWXYZ(
            this.w * s,
            this.x * s,
            this.y * s,
            this.z * s
        );
    }

    /*
     * Docs: TODO
     *
     * @method multiply
     * @param {Quaternion|Vector} q
     * @return {Quaternion}
     */
    public function multiply(q:Dynamic):Quaternion {
        //left-handed coordinate system multiplication
        var x1 = this.x;
        var y1 = this.y;
        var z1 = this.z;
        var w1 = this.w;
        var x2 = q.x;
        var y2 = q.y;
        var z2 = q.z;
        var w2 = (q.w != null)? q.w : 0;

        return register.setWXYZ(
            w1*w2 - x1*x2 - y1*y2 - z1*z2,
            x1*w2 + x2*w1 + y2*z1 - y1*z2,
            y1*w2 + y2*w1 + x1*z2 - x2*z1,
            z1*w2 + z2*w1 + x2*y1 - x1*y2
        );
    }

    /*
     * Docs: TODO
     *
     * @method rotateVector
     * @param {Vector} v
     * @return {Quaternion}
     */
    public function rotateVector(v:Vector):Quaternion {
        conjugation.set(this.conj());
        return register.set(this.multiply(v).multiply(conjugation));
    }

    /*
     * Docs: TODO
     *
     * @method inverse
     * @return {Quaternion}
     */
    public function inverse():Quaternion {
        return register.set(this.conj().scalarDivide(this.normSquared()));
    }

    /*
     * Docs: TODO
     *
     * @method negate
     * @return {Quaternion}
     */
    public function negate():Quaternion {
        return this.scalarMultiply(-1);
    }

    /*
     * Docs: TODO
     *
     * @method conj
     * @return {Quaternion}
     */
    public function conj():Quaternion {
        return register.setWXYZ(
             this.w,
            -this.x,
            -this.y,
            -this.z
        );
    }

    /*
     * Docs: TODO
     *
     * @method normalize
     * @param {Number} length
     * @return {Quaternion}
     */
    public function normalize(?length:Int):Quaternion {
        length = (length == null) ? 1 : length;
        return this.scalarDivide(length * this.norm());
    }

    /*
     * Docs: TODO
     *
     * @method makeFromAngleAndAxis
     * @param {Number} angle
     * @param {Vector} v
     * @return {Quaternion}
     */
    public function makeFromAngleAndAxis(angle:Float, v:Vector):Quaternion {
        //left handed quaternion creation: theta -> -theta
        var n  = v.normalize();
        var ha = angle*0.5;
        var s  = -Math.sin(ha);
        this.x = s*n.x;
        this.y = s*n.y;
        this.z = s*n.z;
        this.w = Math.cos(ha);
        return this;
    }

    /*
     * Docs: TODO
     *
     * @method setWXYZ
     * @param {Number} w
     * @param {Number} x
     * @param {Number} y
     * @param {Number} z
     * @return {Quaternion}
     */
    public function setWXYZ(w:Float, x:Float, y:Float, z:Float):Quaternion {
        register.clear();
        this.w = w;
        this.x = x;
        this.y = y;
        this.z = z;
        return this;
    }

    /*
     * Docs: TODO
     *
     * @method set
     * @param {Array|Quaternion} v
     * @return {Quaternion}
     */
    public function set(v:Dynamic):Quaternion {
        if (Std.is(v, Array)) {
            this.w = v[0];
            this.x = v[1];
            this.y = v[2];
            this.z = v[3];
        }
        else {
            this.w = v.w;
            this.x = v.x;
            this.y = v.y;
            this.z = v.z;
        }
        if (this != register) {
			register.clear();
		}
        return this;
    }

    /**
     * Docs: TODO
     *
     * @method put
     * @param {Quaternion} q
     * @return {Quaternion}
     */
    public function put(q:Quaternion):Quaternion {
        q.set(register);
		return this;
    }

    /**
     * Doc: TODO
     *
     * @method clone
     * @return {Quaternion}
     */
    public function clone():Quaternion {
        return new Quaternion().set(this);
    }

    /**
     * Doc: TODO
     *
     * @method clear
     * @return {Quaternion}
     */
    public function clear():Quaternion {
        this.w = 1;
        this.x = 0;
        this.y = 0;
        this.z = 0;
        return this;
    }

    /**
     * Doc: TODO
     *
     * @method isEqual
     * @param {Quaternion} q
     * @return {Boolean}
     */
    public function isEqual(q:Quaternion):Bool {
        return q.w == this.w && q.x == this.x && q.y == this.y && q.z == this.z;
    };

    /**
     * Doc: TODO
     *
     * @method dot
     * @param {Quaternion} q
     * @return {Number}
     */
    public function dot(q:Quaternion):Float {
        return this.w * q.w + this.x * q.x + this.y * q.y + this.z * q.z;
    }

    /**
     * Doc: TODO
     *
     * @method normSquared
     * @return {Number}
     */
    public function normSquared():Float {
        return this.dot(this);
    }

    /**
     * Doc: TODO
     *
     * @method norm
     * @return {Number}
     */
    public function norm():Float {
        return Math.sqrt(this.normSquared());
    };

    /**
     * Doc: TODO
     *
     * @method isZero
     * @return {Boolean}
     */
    public function isZero():Bool {
        return !(this.x != 0 || this.y != 0 || this.z != 0);
    };

    /**
     * Doc: TODO
     *
     * @method getTransform
     * @return {Transform}
     */
    public function getTransform():Matrix4 {
        var temp = this.normalize(1);
        var x = temp.x;
        var y = temp.y;
        var z = temp.z;
        var w = temp.w;

        //LHC system flattened to column major = RHC flattened to row major
        return [
            1 - 2*y*y - 2*z*z,
                2*x*y - 2*z*w,
                2*x*z + 2*y*w,
            0,
                2*x*y + 2*z*w,
            1 - 2*x*x - 2*z*z,
                2*y*z - 2*x*w,
            0,
                2*x*z - 2*y*w,
                2*y*z + 2*x*w,
            1 - 2*x*x - 2*y*y,
            0,
            0,
            0,
            0,
            1
        ];
    }

    /**
     * Doc: TODO
     *
     * @method getMatrix
     * @return {Transform}
     */
    public function getMatrix():Matrix {
        var temp = this.normalize(1);
        var x = temp.x;
        var y = temp.y;
        var z = temp.z;
        var w = temp.w;

        //LHC system flattened to row major
        return matrixRegister.set([
            [
                1 - 2*y*y - 2*z*z,
                    2*x*y + 2*z*w,
                    2*x*z - 2*y*w
            ],
            [
                    2*x*y - 2*z*w,
                1 - 2*x*x - 2*z*z,
                    2*y*z + 2*x*w
            ],
            [
                    2*x*z + 2*y*w,
                    2*y*z - 2*x*w,
                1 - 2*x*x - 2*y*y
            ]
        ]);
    };

    /**
     * Doc: TODO
     *
     * @method slerp
     * @param {Quaternion} q
     * @param {Number} t
     * @return {Transform}
     */
	public function slerp(q:Quaternion, t:Float):Quaternion {
        var omega;
        var cosomega;
        var sinomega;
        var scaleFrom;
        var scaleTo;

        cosomega = this.dot(q);
        if ((1.0 - cosomega) > epsilon) {
            omega       = Math.acos(cosomega);
            sinomega    = Math.sin(omega);
            scaleFrom   = Math.sin((1.0 - t) * omega) / sinomega;
            scaleTo     = Math.sin(t * omega) / sinomega;
        } else {
            scaleFrom   = 1.0 - t;
            scaleTo     = t;
        }
        return register.set(this.scalarMultiply(scaleFrom/scaleTo).add(q).multiply(scaleTo));
    }
}