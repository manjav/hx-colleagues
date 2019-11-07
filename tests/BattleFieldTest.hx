package;

import com.grantech.colleagues.CMath;
import com.grantech.colleagues.Shape;
import com.grantech.colleagues.Colleague;
import com.grantech.colleagues.Colleagues2d;
import haxe.Timer;
import flash.events.MouseEvent;
import flash.events.Event;
import flash.display.Sprite;

class BattleFieldTest extends Sprite {
	static function main() {
		flash.Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		flash.Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		flash.Lib.current.addChild(new BattleFieldTest());
	}

	private var dt:Float = 0;
	private var accumulator:Float = 0;
	private var skipDrawing:Bool;
	private var engine:Colleagues2d;
	private var targets:Array<Float>;

	/* ENTRY POINT */
	public function new() {
		super();
		this.addEventListener(Event.ADDED_TO_STAGE, this.this_addedToStageHandler);
	}

	private function this_addedToStageHandler(event:Event):Void {
		this.removeEventListener(Event.ADDED_TO_STAGE, this.this_addedToStageHandler);

		this.engine = new Colleagues2d(1 / stage.frameRate);

		var b:Colleague = null;
		// center
		var p = Shape.create_box(200, 44);
		b = this.engine.add(p, 300, 400);
		b.setStatic();
		// top side
		var p = Shape.create_box(300, 10);
		b = this.engine.add(p, 300, 0);
		b.setStatic();
		// right side
		var p = Shape.create_box(30, 400);
		b = this.engine.add(p, 600, 400);
		b.setStatic();
		// bottom side
		var p = Shape.create_box(300, 30);
		b = this.engine.add(p, 300, 800);
		b.setStatic();
		// left side
		var p = Shape.create_box(30, 400);
		b = this.engine.add(p, 0, 400);
		b.setStatic();

		targets = new Array();
		var p = 50;
		var p2 = 150;
		targets = targets.concat([p, p2]);
		targets = targets.concat([stage.stageWidth * 0.5, p]);
		targets = targets.concat([stage.stageWidth - p, p2]);
		targets = targets.concat([stage.stageWidth - p, stage.stageHeight * 0.5]);
		targets = targets.concat([stage.stageWidth - p, stage.stageHeight - p2]);
		targets = targets.concat([stage.stageWidth * 0.5, stage.stageHeight - p]);
		targets = targets.concat([p, stage.stageHeight - p2]);
		targets = targets.concat([p, stage.stageHeight * 0.5]);

		this.addEventListener(Event.ENTER_FRAME, this.this_enterFrameHandler);
		this.stage.addEventListener(MouseEvent.CLICK, this.stage_clickHandler);
	}

	private function stage_clickHandler(event:MouseEvent):Void {
		var mx = Math.round(event.stageX);
		var my = Math.round(event.stageY);
		var min = 10;
		var max = 30;
		var b:Colleague;
		if (event.shiftKey) {
			b = this.engine.add(Shape.create_box(random(min, max), random(min, max)), mx, my);
			if (event.ctrlKey)
				b.setStatic();
		} else if (event.altKey) {
			skipDrawing = !skipDrawing;
			return;
			/* 	} else if (event.ctrlKey) {
				var r = random(min, max);
				var vertCount = random(6, 16);
							var verts = new Array<Float>();
				for (i in 0...vertCount)
					verts[i] = random(-r, r);
				b = this.engine.add(new Polygon(verts), mx, my);
				// b.setOrient(engineMath.random(-engineMath.PI, engineMath.PI));
				// b.restitution = 0.2;
				// b.dynamicFriction = 0.2;
				// b.staticFriction = 0.4; */
		} else {
			b = this.engine.add(Shape.create_circle(random(min, max)), mx, my);
			b.speed = random(50, 150);
			b.side = b.y > stage.stageHeight * 0.5 ? 0 : 1;
		}
	}

	private function random(min:Float, max:Float):Float {
		return min + Math.random() * (max - min);
	}

	private function this_enterFrameHandler(event:flash.events.Event):Void {
		var t = Timer.stamp() * 1000;
		this.accumulator += (t - this.dt);
		this.dt = t;
		if (this.accumulator >= this.engine.deltaTime) {
			this.accumulator -= this.engine.deltaTime;
			this.findTargets();
			this.cleanup();
			this.engine.step();
			if (!skipDrawing)
				this.draw();
		}
	}

	private function findTargets():Void {
		for (c in this.engine.colleagues) {
			var dis = Math.POSITIVE_INFINITY;
			var i = -2;
			var tx:Float = 0;
			var ty:Float = 0;
			while (i < this.targets.length) {
				i += 2;
				if (c.shape.type == Shape.TYPE_POLY
					|| (c.side == 0 && c.y <= this.targets[i + 1] + 1)
					|| (c.side == 1 && c.y >= this.targets[i + 1] - 1))
					continue;
				var d = Math.pow(this.targets[i] - c.x, 2) + Math.pow(this.targets[i + 1] - c.y, 2);
				if (dis > d) {
					dis = d;
					tx = this.targets[i];
					ty = this.targets[i + 1];
				}
			}
			if (tx == 0) {
				c.speedX = c.speedY = 0;
			} else {
				var angle:Float = Math.atan2(ty - c.y, tx - c.x);
				c.speedX = c.speed * Math.cos(angle);
				c.speedY = c.speed * Math.sin(angle);
			}
		}
	}

	private function cleanup():Void {
		for (c in this.engine.colleagues)
			if (c.x < 0 || c.x > this.stage.stageWidth || c.y < 0 || c.y > this.stage.stageHeight)
				this.engine.colleagues.remove(c);
	}

	private function draw():Void {
		this.graphics.clear();
		if (skipDrawing)
			return;
		var x:Float = 0;
		var y:Float = 0;
		for (b in this.engine.colleagues) {
			if (b.shape.type == Shape.TYPE_CIRCLE) {
				this.graphics.lineStyle(1, b.speedX == 0 && b.speedY == 0 ? 0xAAAAAA : 0xFF0000);
				this.graphics.moveTo(b.x, b.y);
				// this.graphics.lineTo(b.position.x + b.shape.radius * Math.cos(b.orient), b.position.y + b.shape.radius * Math.sin(b.orient));
				this.graphics.drawCircle(b.x, b.y, b.shape.radius);
			} else {
				this.graphics.lineStyle(1, 0x0000FF);
				for (i in 0...b.shape.vertexCount) {
					// var v = new Vec2(b.shape.vertices[i].x, b.shape.vertices[i].y);
					// b.shape.u.muli(v);
					// v.addi(b.position);
					x = CMath.matrix_transformX(b.shape.matrix, b.shape.getX(i), b.shape.getY(i)) + b.x;
					y = CMath.matrix_transformY(b.shape.matrix, b.shape.getX(i), b.shape.getY(i)) + b.y;
					if (i == 0)
						this.graphics.moveTo(x, y);
					else
						this.graphics.lineTo(x, y);
				}
				x = CMath.matrix_transformX(b.shape.matrix, b.shape.getX(0), b.shape.getY(0)) + b.x;
				y = CMath.matrix_transformY(b.shape.matrix, b.shape.getX(0), b.shape.getY(0)) + b.y;
				this.graphics.lineTo(x, y);
			}
		}

		this.graphics.lineStyle(1, 0xAAAAAA);
		for (c in engine.contacts) {
			if (c.count > 0 && c.a.shape.type == Shape.TYPE_CIRCLE && c.b.shape.type == Shape.TYPE_CIRCLE && c.a.side != c.b.side) {
				engine.colleagues.remove(c.a);
				engine.colleagues.remove(c.b);
				continue;
			}
			for (i in 0...c.count) {
				this.graphics.moveTo(c.getPointX(i), c.getPointY(i));
				this.graphics.lineTo(c.getPointX(i) + c.normalX * 4, c.getPointY(i) + c.normalY * 4);
			}
		}

		// draw targets
		var i = 0;
		while (i < this.targets.length) {
			this.graphics.drawCircle(this.targets[i], this.targets[i + 1], 4);
			i += 2;
		}
	}
}
