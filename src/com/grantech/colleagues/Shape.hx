package com.grantech.colleagues;

class Shape {
	static public var TYPE_CIRCLE:Int = 0;
	static public var TYPE_POLY:Int = 1;

	public var type:Int = 0;
	public var radius:Float = 0;
	public var vertexCount:Int = 0;
	public var colleague:Colleague;

	public var matrix:Array<Float>;

	private var normals:Array<Float>;
	private var vertices:Array<Float>;

	static public function create_circle(radius:Float):Shape {
		return new Shape(TYPE_CIRCLE, radius);
	}

	static public function create_box(hw:Float, hh:Float):Shape {
		var shape = new Shape(TYPE_POLY, Math.max(hw, hh));
		shape.vertexCount = 4;
		shape.set(0, -hw, -hh);
		shape.set(1, hw, -hh);
		shape.set(2, hw, hh);
		shape.set(3, -hw, hh);
		shape.setNormal(0, 0.0, -1.0);
		shape.setNormal(1, 1.0, 0.0);
		shape.setNormal(2, 0.0, 1.0);
		shape.setNormal(3, -1.0, 0.0);
		return shape;
	}

	public function new(type:Int, radius:Float) {
		this.type = type;
		this.radius = radius;
		this.normals = new Array();
		this.vertices = new Array();
		this.matrix = [0.0, 0.0, 0.0, 0.0];
	}

	public function initialize() {
		computeMass(1.0);
	}

	public function computeMass(density:Float):Void {
		if (type == TYPE_CIRCLE) {
			colleague.mass = Math.PI * radius * radius * density;
			colleague.invMass = (colleague.mass != 0.0) ? 1.0 / colleague.mass : 0.0;
			return;
		}

		// centroid 
		var cx:Float = 0;
		var cy:Float = 0;
		var area = 0.0;
		var I = 0.0;
		var k_inv3 = 1.0 / 3.0;

		for (i in 0...vertexCount) {
			var px1 = getX(i);
			var py1 = getY(i);
			var px2 = getX((i + 1) % vertexCount);
			var py2 = getY((i + 1) % vertexCount);

			var D = px1 * py2 - py1 * px2;
			var triangleArea = 0.5 * D;

			area += triangleArea;

			// Use area to weight the centroid average, not just vertex position
			var weight = triangleArea * k_inv3;
			cx += px1 * weight;
			cy += py1 * weight;
			cx += px2 * weight;
			cy += py2 * weight;

			// var intx2 = p1.x * p1.x + p2.x * p1.x + p2.x * p2.x;
			// var inty2 = p1.y * p1.y + p2.y * p1.y + p2.y * p2.y;
			var intx2 = px1 * px1 + px2 * px1 + px2 * px2;
			var inty2 = py1 * py1 + py2 * py1 + py2 * py2;
			I += (0.25 * k_inv3 * D) * (intx2 + inty2);
		}

		cx *= (1.0 / area);
		cy *= (1.0 / area);

		// Translate vertices to centroid (make the centroid (0, 0)
		// for the polygon in model space)
		// Not really necessary, but I like doing this anyway
		for (i in 0...vertexCount)
			set(i, getX(i) - cx, getY(i) - cy);

		colleague.mass = density * area;
		colleague.invMass = (colleague.mass != 0.0) ? 1.0 / colleague.mass : 0.0;
		CMath.matrix_rotate(matrix, 0);
	}

	public function set(index:Int, x:Float, y:Float):Void {
		this.vertices[index * 2] = x;
		this.vertices[index * 2 + 1] = y;
	}

	private function setX(index:Int, value:Float):Float {
		return this.vertices[index * 2] = value;
	}

	private function setY(index:Int, value:Float):Float {
		return this.vertices[index * 2 + 1] = value;
	}

	public function getX(index:Int):Float {
		return this.vertices[index * 2];
	}

	public function getY(index:Int):Float {
		return this.vertices[index * 2 + 1];
	}

	private function setNormal(index:Int, x:Float, y:Float):Void {
		this.normals[index * 2] = x;
		this.normals[index * 2 + 1] = y;
	}

	private function setNormalX(index:Int, x:Float):Float {
		return this.normals[index * 2] = x;
	}

	private function setNormalY(index:Int, y:Float):Float {
		return this.normals[index * 2 + 1] = y;
	}

	public function getNormalX(index:Int):Float {
		return this.normals[index * 2];
	}

	public function getNormalY(index:Int):Float {
		return this.normals[index * 2 + 1];
	}
}
