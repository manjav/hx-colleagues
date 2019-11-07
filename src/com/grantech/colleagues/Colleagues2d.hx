package com.grantech.colleagues;

class Colleagues2d {
	public var deltaTime:Float = 0;
	public var contacts:Array<Contacts>;
	public var colleagues:Array<Colleague>;

	public function new(deltaTime:Float) {
		this.deltaTime = deltaTime;
		this.contacts = new Array();
		this.colleagues = new Array();
	}

	public function step() {
		this.contacts = new Array();
		var len = colleagues.length;
		for (i in 0...len) {
			var a:Colleague = this.colleagues[i];

			for (j in i + 1...len) {
				var b:Colleague = this.colleagues[j];

				if (a.invMass == 0 && b.invMass == 0)
					continue;

				var contact = contactsInstatiate(a, b);
				contact.solve();
				if (contact.count > 0)
					this.contacts.push(contact);
				else
					contactsDispose(contact);
			}
		}

		// Integrate velocities
		for (i in 0...len)
			integrateVelocity(this.colleagues[i], deltaTime);

		// Correct positions
		for (i in 0...this.contacts.length) {
			this.contacts[i].positionalCorrection();
			contactsDispose(this.contacts[i]);
		}
	}

	public function add(shape:Shape, x:Int, y:Int):Colleague {
		var c = new Colleague(shape, x, y);
		this.colleagues.push(c);
		return c;
	}

	public function integrateVelocity(c:Colleague, deltaTime:Float) {
		if (c.invMass == 0 || c.speed == 0)
			return;
		c.x += c.speedX * deltaTime;
		c.y += c.speedY * deltaTime;
	}

	private var pool:Array<Contacts> = new Array();
	private var i:Int = 0;
	public function contactsDispose(m:Contacts):Void {
		pool[i++] = m;
	}
	public function contactsInstatiate(a:Colleague, b:Colleague):Contacts {
		if (i > 0) {
			i--;
			pool[i].a = a;
			pool[i].b = b;
			return pool[i];
		}
		return new Contacts(a, b);
	}
}
