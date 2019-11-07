package com.grantech.colleagues;

class Contacts {
	public var a:Colleague;
	public var b:Colleague;
	public var penetration:Float = 0;
	public var normalX:Float = 0;
	public var normalY:Float = 0;
	public var count:Int;

	private var points:Array<Float>;
	private var collision:Collision;

	public function new(a:Colleague, b:Colleague) {
		this.a = a;
		this.b = b;
		this.points = [0, 0, 0, 0];
		this.collision = new Collision();
	}

	public function solve():Void {
		this.collision.methods[a.shape.type][b.shape.type](this, a, b);
	}

	public function setPoint(index:Int, x:Float, y:Float):Void {
		this.points[index * 2] = x;
		this.points[index * 2 + 1] = y;
	}

	public function getPointX(index:Int):Float {
		return this.points[index * 2];
	}

	public function getPointY(index:Int):Float {
		return this.points[index * 2 + 1];
	}

	public function positionalCorrection():Void {
		var correction:Float = Math.max(penetration - CMath.PENETRATION_ALLOWANCE, 0.0) / (a.invMass + b.invMass) * CMath.PENETRATION_CORRETION;
		a.x += normalX * -a.invMass * correction;
		a.y += normalY * -a.invMass * correction;
		b.x += normalX * b.invMass * correction;
		b.y += normalY * b.invMass * correction;
	}
}
