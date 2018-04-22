import kext.Application;
import kext.ExtAssets;
import kext.math.MathExt;
import kext.g2basics.BasicSprite;
import kext.utils.Countdown;

import kha.Assets;
import kha.math.Vector2;

class Car extends BasicSprite {

	public var carId:Int;
	public var lane:Int;
	public var targetLane:Int;
	public var commandedChange:Bool;
	public var travelX:Float;

	public var carSpeed:Vector2;
	public var carBoost:Float;

	public var health:Int = 3;
	public var immuneTime:Float;

	public var finished:Bool = false;

	public var civilian:Bool = false;
	public var randomCivilianSpeedMultiplier:Float;

	public var repairCountdown:Countdown;

	public function new(x:Float, y:Float, carId:Int, lane:Int) {
		super(x, y, null); 

		this.carId = carId;
		this.lane = lane;
		targetLane = lane;

		carSpeed = new Vector2(0, 0);
		carBoost = 1;

		setFrame(ExtAssets.frames.get("Car"));
		color = GameData.carColors[carId];

		repairCountdown = new Countdown(Data.game.carRepairTime, Application.deltaTime);
	}

	public function reset(x:Float, y:Float, lane:Int) {
		position.x = x;
		position.y = y;
		this.lane = lane;
		targetLane = lane;
		carSpeed.x = 0;
		carSpeed.y = 0;
		exists = true;
		finished = false;
		setCarScale(1);
		repair(Data.game.carMaxHealth, true);
	}

	public function setCarScale(value:Float) {
		scale.x = value;
		scale.y = value;
		bounds.setScaleFromCenter(Data.game.carBoundScale, Data.game.carBoundOffset.mult(value));
	}

	public function scaleCar(value:Float) {
		scale.x += value;
		scale.y += value;
		bounds.setScaleFromCenter(Data.game.carBoundScale, Data.game.carBoundOffset.mult(scale.x));
	}

	public function repair(ammount:Int = 1, noSound:Bool = false) {
		health = Math.floor(MathExt.clamp(health + ammount, 0, Data.game.carMaxHealth));
		changeCarAsset();
		if(noSound) { return; }
		GameData.playSound(Assets.sounds.Repair, Data.game.carRepairVolume, position);
	}

	public function damage(ammount:Int = 1) {
		if(immuneTime > 0) { return; }
		immuneTime = Data.game.carImmuneTime;
		health = Math.floor(MathExt.clamp(health - ammount, 0, Data.game.carMaxHealth));
		carSpeed.x = 0;
		carSpeed.y = 0;
		changeCarAsset();
		GameData.playSound(Assets.sounds.CarHit, Data.game.carHitVolume, position);
	}

	private function changeCarAsset() {
		switch(health) {
			case 3: setFrame(ExtAssets.frames.Car);
			case 2: setFrame(ExtAssets.frames.CarDamaged1);
			case 1: setFrame(ExtAssets.frames.CarDamaged2);
			case 0: setFrame(ExtAssets.frames.CarDestroyed);
		}
	}

	override public function update(delta:Float) {
		immuneTime = Math.max(0, immuneTime - delta);
		color.A = 1 - Math.sin(immuneTime * 10) * 0.5;

		if(health != Data.game.carMaxHealth) {
			repairCountdown.tick();
			if(repairCountdown.done()) {
				repair();
				repairCountdown.start();
			}
		}

		if(health <= 0) {
			carSpeed.x = 0;
			carSpeed.y = 0;
			return;
		}

		if(civilian) {
			civilianAI(delta);
		} else {
			racecarAI(delta);
		}
	}

	public inline function civilianAI(delta:Float) {
		var carFront:Car = null;
		for(car in GameData.cars) {
			if(car.exists && car != this) {
				var deltaY = position.y - car.position.y;
				if(lane == car.lane && deltaY > 0 && deltaY < Data.game.distanceDectectionLane) {
					if(carFront == null || (deltaY < position.y - carFront.position.y)) {		
						carFront = car;
					}
				}
			}
		}

		if(carFront != null) {
			carSpeed.y *= 0.90;
		} else {
			carSpeed.y -= Data.game.carAcceleration.y * delta;
		}

		if(targetLane != lane) {
			if(targetLane > lane) {
				carSpeed.x += Data.game.carAcceleration.x * delta;
			}
			if(targetLane < lane) {
				carSpeed.x -= Data.game.carAcceleration.x * delta;
			}
			if(Math.abs(travelX) >= Data.game.carLaneWidth) {
				carSpeed.x = 0;
				travelX = 0;
				lane = targetLane;
				commandedChange = false;
				position.x = Math.floor(position.x / Data.game.carLaneWidth) * Data.game.carLaneWidth + Data.game.carLaneWidth * 0.5;
			}
		}

		var maxSpeedMultiplier = Data.game.civilianMaxSpeedMultiplier * randomCivilianSpeedMultiplier;
		carSpeed.x = MathExt.clamp(carSpeed.x, -Data.game.maxCarSpeed.x * maxSpeedMultiplier, Data.game.maxCarSpeed.x * maxSpeedMultiplier);
		carSpeed.y = MathExt.clamp(carSpeed.y, -Data.game.maxCarSpeed.x * maxSpeedMultiplier, Data.game.maxCarSpeed.y * maxSpeedMultiplier);
	}

	public inline function racecarAI(delta:Float) {
		var carFront:Car = null;
		var carLeft:Car = null;
		var carRight:Car = null;
		for(car in GameData.cars) {
			if(car.exists && car != this) {
				var deltaY = position.y - car.position.y;
				if(lane == car.lane && deltaY > 0 && deltaY < Data.game.distanceDectectionLane) {
					if(carFront == null || (deltaY < position.y - carFront.position.y)) {		
						carFront = car;
					}
				}
				if(carRight == null && lane + 1 == car.lane && checkCarDistance(car)) {
					carRight = car;
				}
				if(carLeft == null && lane - 1 == car.lane && checkCarDistance(car)) {
					carLeft = car;
				}
			}
		}

		carBoost = Math.max(1, carBoost - Data.game.carBoostDroprate * delta);

		if(carFront != null && immuneTime == 0) {
			if(position.y - carFront.position.y < Data.game.distanceBreakLane) {
				carSpeed.y *= 0.90;
			}
			if(targetLane == lane) {
				if(Math.random() > 0.5) {
					if(carLeft == null) { targetLane = lane - 1; }
					else if(carRight == null) { targetLane = lane + 1; }
				} else {
					if(carRight == null) { targetLane = lane + 1; }
					else if(carLeft == null) { targetLane = lane - 1; }
				}
			}
		} else {
			carSpeed.y -= Data.game.carAcceleration.y * delta;
		}
		if(targetLane != lane) {
			if(targetLane > lane && (carRight == null || commandedChange)) {
				carSpeed.x += Data.game.carAcceleration.x * delta;
			}
			if(targetLane < lane && (carLeft == null || commandedChange)) {
				carSpeed.x -= Data.game.carAcceleration.x * delta;
			}
			if(Math.abs(travelX) >= Data.game.carLaneWidth) {
				carSpeed.x = 0;
				travelX = 0;
				lane = targetLane;
				commandedChange = false;
				position.x = Math.floor(position.x / Data.game.carLaneWidth) * Data.game.carLaneWidth + Data.game.carLaneWidth * 0.5;
			}
		}
		var maxSpeedMultiplier:Float = lane <= 0 || lane > GameData.currentRaceLanes ? 0.5 : 1;
		carSpeed.x = MathExt.clamp(carSpeed.x, -Data.game.maxCarSpeed.x * maxSpeedMultiplier, Data.game.maxCarSpeed.x * maxSpeedMultiplier);
		carSpeed.y = MathExt.clamp(carSpeed.y, -Data.game.maxCarSpeed.x * maxSpeedMultiplier, Data.game.maxCarSpeed.y * maxSpeedMultiplier);
	}

	public inline function checkCarDistance(car:Car):Bool {
		return Math.abs(car.position.y - position.y) < Data.game.distanceDectectionY;
	}

	public function move(delta:Float, levelSpeed:Float) {
		var deltaSpeed:Vector2 = carSpeed.mult(carBoost * scale.y).add(new Vector2(0, levelSpeed));
		position.x += deltaSpeed.x * delta;
		travelX += deltaSpeed.x * delta;
		position.y += deltaSpeed.y * delta;
	}

}