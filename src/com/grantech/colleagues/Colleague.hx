package com.grantech.colleagues;

class Colleague {
	public var x:Float = 0;
	public var y:Float = 0;
	public var mass:Float = 0;
	public var invMass:Float = 0;
	public var shape:Shape;

	public var side:Int;
	public var speed:Float;
	public var speedX:Float = 0;
	public var speedY:Float = 0;
	// public var targetX:Float = 0;
	// public var targetY:Float = 0;

	public function new(shape:Shape, x:Int, y:Int) {
		this.x = x;
		this.y = y;
		this.shape = shape;
		this.shape.colleague = this;
		this.shape.initialize();
	}

	/* 	public function applyImpulse(impulse:Vec2, contactVector:Vec2) {
		// velocity += im * impulse;
		// angularVelocity += iI * Cross( contactVector, impulse );

		velocity.addsi(impulse, invMass);
		// angularVelocity += invInertia * Vec2.crossVV(contactVector, impulse);
	}*/
	public function setStatic() {
		// inertia = 0.0;
		// invInertia = 0.0;
		mass = 0.0;
		invMass = 0.0;
	}
}
