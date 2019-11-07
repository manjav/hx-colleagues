package com.grantech.colleagues;

class Collision {
	var contacts:Contacts;
	var normalX:Float;
	var normalY:Float;
	var distance:Float;
	var radiuses:Float;

	public var methods:Array<Array<(Contacts, Colleague, Colleague) -> Bool>>;

	public function new() {
		this.methods = [[checkCC, checkCP], [checkPC, checkCC]];
	}

	public function check(contacts:Contacts, a:Colleague, b:Colleague):Bool {
		this.contacts = contacts;

		// Calculate translational vector, which is normal
		this.normalX = b.x - a.x;
		this.normalY = b.y - a.y;

		this.distance = Math.sqrt(this.normalX * this.normalX + this.normalY * this.normalY);
		this.radiuses = a.shape.radius + b.shape.radius;

		// is far
		if (this.distance > this.radiuses) {
			this.contacts.count = 0;
			return false;
		}
		return true;
	}

	public function checkCC(contacts:Contacts, a:Colleague, b:Colleague):Bool {
		if (!check(contacts, a, b))
			return false;

		contacts.count = 1;

		if (distance == 0.0) {
			contacts.penetration = a.shape.radius;
			contacts.normalX = 1;
			contacts.normalY = 0;
			contacts.setPoint(0, a.x, a.y);
		} else {
			contacts.penetration = radiuses - distance;
			contacts.normalX = normalX / distance;
			contacts.normalY = normalY / distance;
			contacts.setPoint(0, contacts.normalX * a.shape.radius + a.x, contacts.normalY * a.shape.radius + a.y);
		}
		return true;
	}

	public function checkPC(contacts:Contacts, a:Colleague, b:Colleague):Bool {
		if (!checkCP(contacts, b, a))
			return false;

		if (contacts.count > 0) {
			contacts.normalX *= -1;
			contacts.normalY *= -1;
		}
		return true;
	}

	public function checkCP(contacts:Contacts, a:Colleague, b:Colleague):Bool {
		if (!check(contacts, a, b))
			return false;

		contacts.count = 0;

		CMath.matrix_transpose(b.shape.matrix);
		var centerX = CMath.matrix_transformX(b.shape.matrix, a.x - b.x, a.y - b.y);
		var centerY = CMath.matrix_transformY(b.shape.matrix, a.x - b.x, a.y - b.y);
		CMath.matrix_transpose(b.shape.matrix);

		// Find edge with minimum penetration
		// Exact concept as using support points in Polygon vs Polygon
		var separation:Float = Math.NEGATIVE_INFINITY;
		var faceNormal:Int = 0;
		for (i in 0...b.shape.vertexCount) {
			var cxsb = centerX - b.shape.getX(i);
			var cysb = centerY - b.shape.getY(i);
			var s = b.shape.getNormalX(i) * cxsb + b.shape.getNormalY(i) * cysb;

			if (s > a.shape.radius)
				return true;

			if (s > separation) {
				separation = s;
				faceNormal = i;
			}
		}

		// Grab face's vertices
		var v1x:Float = b.shape.getX(faceNormal);
		var v1y:Float = b.shape.getY(faceNormal);
		var i2:Int = faceNormal + 1 < b.shape.vertexCount ? faceNormal + 1 : 0;
		var v2x:Float = b.shape.getX(i2);
		var v2y:Float = b.shape.getY(i2);

		// Check to see if center is within polygon
		if (separation < CMath.EPSILON) {
			contacts.count = 1;
			contacts.normalX = -CMath.matrix_transformX(b.shape.matrix, b.shape.getNormalX(faceNormal), b.shape.getNormalY(faceNormal));
			contacts.normalY = -CMath.matrix_transformY(b.shape.matrix, b.shape.getNormalX(faceNormal), b.shape.getNormalY(faceNormal));
			contacts.setPoint(0, contacts.normalX * a.shape.radius + a.x, contacts.normalY * a.shape.radius + a.y);
			contacts.penetration = a.shape.radius;
			return true;
		}

		var dot1 = (centerX - v1x) * (v2x - v1x) + (centerY - v1y) * (v2y - v1y);
		var dot2 = (centerX - v2x) * (v1x - v2x) + (centerY - v2y) * (v1y - v2y);

		contacts.penetration = a.shape.radius - separation;

		// Closest to v1
		if (dot1 <= 0.0) {
			if ((centerX - v1x) * (centerX - v1x) + (centerY - v1y) * (centerY - v1y) > a.shape.radius * a.shape.radius)
				return true;

			contacts.count = 1;
			contacts.normalX = v1x - centerX;
			contacts.normalY = v1y - centerY;
			contacts.normalX = CMath.matrix_transformX(b.shape.matrix, contacts.normalX, contacts.normalY);
			contacts.normalY = CMath.matrix_transformY(b.shape.matrix, contacts.normalX, contacts.normalY);
			contacts.normalX = CMath.vector_normalizeX(contacts.normalX, contacts.normalY);
			contacts.normalY = CMath.vector_normalizeY(contacts.normalX, contacts.normalY);
			contacts.setPoint(0, CMath.matrix_transformX(b.shape.matrix, v1x, v1y) + b.x, CMath.matrix_transformY(b.shape.matrix, v1x, v1y) + b.y);
		}

		// Closest to v2
		else if (dot2 <= 0.0) {
			if ((centerX - v2x) * (centerX - v2x) + (centerY - v2y) * (centerY - v2y) > a.shape.radius * a.shape.radius)
				return true;

			contacts.count = 1;
			contacts.normalX = v2x - centerX;
			contacts.normalY = v2y - centerY;
			contacts.normalX = CMath.matrix_transformX(b.shape.matrix, contacts.normalX, contacts.normalY);
			contacts.normalY = CMath.matrix_transformY(b.shape.matrix, contacts.normalX, contacts.normalY);
			contacts.normalX = CMath.vector_normalizeX(contacts.normalX, contacts.normalY);
			contacts.normalY = CMath.vector_normalizeY(contacts.normalX, contacts.normalY);
			contacts.setPoint(0, CMath.matrix_transformX(b.shape.matrix, v2x, v2y) + b.x, CMath.matrix_transformY(b.shape.matrix, v2x, v2y) + b.y);
		}

		// Closest to face
		else {
			var nx = b.shape.getNormalX(faceNormal);
			var ny = b.shape.getNormalY(faceNormal);
			var csv1x = centerX - v1x;
			var csv1y = centerY - v1y;
			var dotcsv1 = csv1x * nx + csv1y * ny; // a.x * b.x + a.y * b.y
			if (dotcsv1 > a.shape.radius)
				return true;

			contacts.count = 1;
			contacts.normalX = -CMath.matrix_transformX(b.shape.matrix, nx, ny);
			contacts.normalY = -CMath.matrix_transformY(b.shape.matrix, nx, ny);
			contacts.setPoint(0, a.x + contacts.normalX * a.shape.radius, a.y + contacts.normalY * a.shape.radius);
		}
		return true;
	}
}
