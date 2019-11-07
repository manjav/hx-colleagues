package;

class CMath {
	static public var EPSILON:Float = 0.0001;
	static public var EPSILON_SQ:Float = EPSILON * EPSILON;
	static public var PENETRATION_ALLOWANCE:Float = 0.01;
	static public var PENETRATION_CORRETION:Float = 0.4;
	/**
	 * Normalizes this vector, making it a unit vector. A unit vector has a length of 1.0.
	 */
	static public function vector_normalizeX(x:Float, y:Float):Float {
		var lenSq = x * x + y * y;
		if (lenSq > CMath.EPSILON_SQ) {
			var invLen = 1.0 / Math.sqrt(lenSq);
			return x * invLen;
		}
		return x;
	}

	static public function vector_normalizeY(x:Float, y:Float):Float {
		var lenSq = x * x + y * y;
		if (lenSq > CMath.EPSILON_SQ) {
			var invLen = 1.0 / Math.sqrt(lenSq);
			return y * invLen;
		}
		return y;
	}

	/**
	 * Sets this matrix to a rotation matrix with the given radians.
	 */
	static public function matrix_rotate(matrix:Array<Float>, radians:Float):Void {
		var c:Float = Math.cos(radians);
		var s:Float = Math.sin(radians);
		matrix[0] = c;
		matrix[1] = -s;
		matrix[2] = s;
		matrix[3] = c;
	}

	/**
	 * Sets out to the absolute value of this matrix.
	 */
	static public function matrix_abs(matrix:Array<Float>) {
		for (i in 0...4)
			matrix[i] = Math.abs(matrix[i]);
	}

	/**
	 * Sets out to the transpose of this matrix.
	 */
	static public function matrix_transpose(matrix:Array<Float>):Void {
		var m1 = matrix[1];
		matrix[1] = matrix[2];
		matrix[2] = m1;
	}

	/**
	 * Sets out the to transformation of {x,y} by this matrix.
	 */
	static public function matrix_transformX(matrix:Array<Float>, x:Float, y:Float):Float {
		return matrix[0] * x + matrix[1] * y;
	}

	/**
	 * Sets out the to transformation of {x,y} by this matrix.
	 */
	static public function matrix_transformY(matrix:Array<Float>, x:Float, y:Float):Float {
		return matrix[2] * x + matrix[3] * y;
	}
}
