package famous.math;

/**
 * A library for using a 3x3 numerical matrix, represented as a two-level array.
 */
class Matrix {
	static var _register = new Matrix();
	static var _vectorRegister = new Vector();
	
	var values:Array<Array<Float>>;
	
    /**
     * @constructor
     *
     * @param {Array.Array} values array of rows
     */
	public function new(?values:Array<Array<Float>>) {
		this.values = (values != null)? values :
            [
                [1,0,0],
                [0,1,0],
                [0,0,1]
            ];
	}
	
    /**
     * Return the values in the matrix as an array of numerical row arrays
     *
     * @method get
     *
     * @return {Array.array} matrix values as array of rows.
     */
    public function get():Array<Array<Float>> {
        return this.values;
    }

    /**
     * Set the nested array of rows in the matrix.
     *
     * @method set
     *
     * @param {Array.array} values matrix values as array of rows.
     */
    public function set(values:Array<Array<Float>>):Matrix {
        this.values = values;
		return this;
    };

    /**
     * Take this matrix as A, input vector V as a column vector, and return matrix product (A)(V).
     *   Note: This sets the internal vector register.  Current handles to the vector register
     *   will see values changed.
     *
     * @method vectorMultiply
     *
     * @param {Vector} v input vector V
     * @return {Vector} result of multiplication, as a handle to the internal vector register
     */
	public function vectorMultiply(v:Vector):Vector {
        var M = this.get();
        var v0 = v.x;
        var v1 = v.y;
        var v2 = v.z;

        var M0 = M[0];
        var M1 = M[1];
        var M2 = M[2];

        var M00 = M0[0];
        var M01 = M0[1];
        var M02 = M0[2];
        var M10 = M1[0];
        var M11 = M1[1];
        var M12 = M1[2];
        var M20 = M2[0];
        var M21 = M2[1];
        var M22 = M2[2];

        return _vectorRegister.setXYZ(
            M00*v0 + M01*v1 + M02*v2,
            M10*v0 + M11*v1 + M12*v2,
            M20*v0 + M21*v1 + M22*v2
        );
    }

    /**
     * Multiply the provided matrix M2 with this matrix.  Result is (this) * (M2).
     *   Note: This sets the internal matrix register.  Current handles to the register
     *   will see values changed.
     *
     * @method multiply
     *
     * @param {Matrix} M input matrix to multiply on the right
     * @return {Matrix} result of multiplication, as a handle to the internal register
     */
    public function multiply(M:Matrix):Matrix {
        var M1 = this.get();
		var M2 = M.get();
        var result:Array<Array<Float>> = [[]];
        for (i in 0...3) {
            result[i] = [];
            for (j in 0...3) {
                var sum:Float = 0;
                for (k in 0...3) {
                    sum += M1[i][k] * M2[k][j];
                }
                result[i][j] = sum;
            }
        }
        return _register.set(result);
    };

    /**
     * Creates a Matrix which is the transpose of this matrix.
     *   Note: This sets the internal matrix register.  Current handles to the register
     *   will see values changed.
     *
     * @method transpose
     *
     * @return {Matrix} result of transpose, as a handle to the internal register
     */
	public function transpose():Matrix {
        var result = [];
        var M = this.get();
        for (row in 0...3) {
            for (col in 0...3) {
                result[row][col] = M[col][row];
            }
        }
        return _register.set(result);
    }

    /**
     * Clones the matrix
     *
     * @method clone
     * @return {Matrix} New copy of the original matrix
     */
	public function clone():Matrix {
        var values = this.get();
        var M = [];
        for (row in 0...3) {
            M[row] = values[row].slice(0);
		}
        return new Matrix(M);
    }
}