import kext.Application;
import kext.AppState;
import kext.ExtAssets;
import kext.g2basics.BasicSprite;
import kext.debug.Debug;
import kext.math.Rectangle;

import kha.Assets;
import kha.Image;
import kha.Color;
import kha.math.Vector2;

class GameState extends AppState {

	private var carSprites:Array<Car>;
	private var racecarSprites:Array<Car>;
	private var roadSprites:Array<BasicSprite>;
	private var treeSprites:Array<BasicSprite>;

	private var roadLaneWidth:Int;
	private var roadLaneHeight:Int;
	private var roadTraveled:Float;

	private var laneWidth:Float;
	private var laneHeight:Float;
	private var offsetX:Float;

	private var godAbilities:GodAbilities;

	public function new() {
		super();

		GameData.init();
		roadLaneWidth = GameData.currentRaceLanes;
		roadTraveled = 0;

		roadSprites = [];
		roadLaneHeight = Math.ceil(Application.height / ExtAssets.frames.Road.rectangle.height) + 1;
		laneWidth = ExtAssets.frames.Road.rectangle.width;
		laneHeight = ExtAssets.frames.Road.rectangle.height;
		offsetX = (Application.width - laneWidth * roadLaneWidth) * 0.5;
		for(y in -1...roadLaneHeight) {
			for(x in 0...roadLaneWidth) {
				var frame = ExtAssets.frames.Road;
				if(x == 0) { frame = ExtAssets.frames.RoadLeft; }
				else if(x == roadLaneWidth - 1) { frame = ExtAssets.frames.RoadRight; }
				roadSprites.push(BasicSprite.fromFrame(offsetX + laneWidth * 0.5 + x * laneWidth, laneHeight * 0.5 + y * laneHeight, frame));
			}
		}

		carSprites = [];
		racecarSprites = [];
		for(car in GameData.cars) {
			car.exists = false;
		}

		var i = 0;
		var j = Math.floor(Math.random() * GameData.currentRaceCars);
		while(i < GameData.currentRaceCars) {
			if(!GameData.cars[j].exists) {
				var car = GameData.cars[j];
				var carLane = Math.floor((roadLaneWidth * 0.5 + i % 2));
				var x = offsetX + carLane * Data.game.carLaneWidth - laneWidth * 0.5;
				var y = Application.height + laneHeight * 0.5 * Math.floor(i - 12);
				car.reset(x, y, carLane);
				carSprites.push(car);
				racecarSprites.push(car);
				j = Math.floor(Math.random() * GameData.GameData.currentRaceCars);
				i++;
			}
			j = (j + 1) % GameData.GameData.currentRaceCars;
		}

		treeSprites = [];
		for(i in 0...Data.game.treeCount) {
			var x = (Math.random() * 0.25 + (Math.random() < 0.5 ? 0 : 0.75)) * Application.width;
			var y = (Math.random() * 1.1 - 0.1) * Application.height;
			var tree:BasicSprite = BasicSprite.fromFrame(x, y, ExtAssets.frames.get("Tree" + Math.floor(Math.random() * 4)));
			tree.scale.x = tree.scale.y = Math.random() * 1.2 + 0.8;
			treeSprites.push(tree);
		}

		if(!GameData.currentRaceNoCivilians) {
			for(i in 0...GameData.currentCivilianCars) {
				createCivilianCar();
			}
		}

		godAbilities = new GodAbilities();
	}

	override public function update(delta:Float) {
		for(car in carSprites) {
			if(car.exists) {
				car.update(delta);
			}
		}

		var levelSpeed = Math.max(Application.height * 0.7 - GameData.cars[GameData.bettedCar].position.y, 0) * 5;
		for(car in carSprites) {
			car.move(delta, levelSpeed);

			if(car.exists) {
				for(otherCar in carSprites) {
					if(otherCar.exists && car != otherCar && car.bounds.checkRectOverlap(otherCar.bounds)) {
						car.damage();
						otherCar.damage();
					}
				}
			}
		}

		roadTraveled += levelSpeed * delta;
		for(road in roadSprites) {
			road.position.y += levelSpeed * delta;
			if(road.position.y - road.subimage.height * 0.5 > Application.height) {
				road.position.y -= Application.height + road.subimage.height * 1.5;
			}
		}

		for(tree in treeSprites) {
			tree.position.y += levelSpeed * delta;
			if(tree.position.y - tree.subimage.height * 0.5 > Application.height) {
				var x = (Math.random() * 0.25 + (Math.random() < 0.5 ? 0 : 0.75)) * Application.width;
				tree.position.x = x;
				tree.position.y -= Application.height + tree.subimage.height * 1.5;
				tree.scale.x = tree.scale.y = Math.random() * 1.2 + 0.8;
			}
		}

		racecarSprites.sort(function(a:Car, b:Car) {
			if(a.position.y > b.position.y) { return 1; }
			if(a.position.y < b.position.y) { return -1; }
			return 0;
		});

		for(car in racecarSprites) {
			if(!car.finished && roadTraveled - car.position.y > GameData.currentRaceLength) {
				car.finished = true;
				GameData.finalRacecarListing.push(car);
			}
		}

		if(GameData.cars[GameData.bettedCar].finished) {
			for(car in racecarSprites) {
				if(!car.finished) {
					GameData.finalRacecarListing.push(car);
				}
			}
			Application.changeState(GameEndState);
		}

		godAbilities.update(delta);
		
		GameData.updateUI(delta);
	}

	private static var clearColor = Color.fromString("#FF008000");
	override public function render(backbuffer:Image) {
		beginAndClear2D(backbuffer, clearColor);

		for(road in roadSprites) {
			road.render(backbuffer);
		}

		for(car in carSprites) {
			car.render(backbuffer);
		}

		for(tree in treeSprites) {
			tree.render(backbuffer);
		}

		godAbilities.render(backbuffer);

		var i = 0;
		for(car in racecarSprites) {
			var tempPositionX = car.position.x;
			var tempPositionY = car.position.y;
			car.position.x = car.frame.rectangle.width * ((i % 2 + 1) * 1.5);
			car.position.y = car.frame.rectangle.height * 0.6 * (i + 2);
			car.render(backbuffer);
			car.position.x = tempPositionX;
			car.position.y = tempPositionY;
			i++;
		}

		clearTransformation2D(backbuffer);
		backbuffer.g2.color = Color.Black;
		backbuffer.g2.fillRect(8, 8, Application.width - 16, 8);
		for(car in racecarSprites) {
			var mapPercentageX = (roadTraveled - car.position.y) / GameData.currentRaceLength;
			backbuffer.g2.color = car.color;
			backbuffer.g2.fillRect(mapPercentageX * (Application.width - 16) + 8, 4, 4, 16);
		}

		backbuffer.g2.color = Color.Red;
		backbuffer.g2.fillRect(0, roadTraveled - GameData.currentRaceLength, Application.width, 4);
		backbuffer.g2.color = Color.Blue;
		backbuffer.g2.fillRect(0, 0 + roadTraveled, Application.width, 4);
		
		GameData.renderUI(backbuffer);

		backbuffer.g2.end();
	}
	
	public function createCivilianCar() {
		var i = 0;
		var car:Car = null;
		while(i < GameData.cars.length) {
			if(!GameData.cars[i].exists && GameData.cars[i].civilian) {
				car = GameData.cars[i];
				break;
			}
			i++;
		}
		if(car == null) {
			car = new Car(0, 0, 12, 0);
			car.civilian = true;
			GameData.cars.push(car);
		}
		var carLane = Math.floor(Math.random() * roadLaneWidth) + 1;
		var x = offsetX + carLane * Data.game.carLaneWidth - laneWidth * 0.5;
		var y = -Math.random() * (GameData.currentRaceLength - roadTraveled);
		car.reset(x, y, carLane);
		car.randomCivilianSpeedMultiplier = Math.random() * Data.game.civilianRandomSpeed + Data.game.civilianBaseSpeed;
		carSprites.push(car);
	}

}