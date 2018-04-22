import kha.Assets;
import kha.Color;
import kha.Image;
import kha.Sound;
import kha.math.Vector2;
import kha.audio1.AudioChannel;

import kext.Application;
import kext.ExtAssets;
import kext.g2basics.Button;
import kext.math.MathExt;

class GameData {

	public static var cars:Array<Car>;
	public static var carColors:Array<Color>;
	public static var currentRaceLanes:Int;
	public static var currentRaceCars:Int;
	public static var currentRaceLength:Float;
	public static var currentCivilianCars:Int;
	public static var currentRaceNoCivilians:Bool;

	public static var finalRacecarListing:Array<Car>;

	public static var money:Int;

	public static var totalMoneyBetted:Int;
	public static var totalMoneyWon:Int;
	public static var totalMoneyLost:Int;

	public static var bettedCar:Int;
	public static var carsBeeted:Array<Int>;

	private static var inited:Bool;

	private static var music:AudioChannel;

	private static var musicToggle:Button;
	private static var soundFXToggle:Button;
	public static var soundFX:Bool;

	private static inline var MAX_CAR_COUNT:Int = 12;

	public static function init(forceInit:Bool = false) {
		if(inited && !forceInit) { return; }
		inited = true;

		music = Application.audio.playSound(Assets.sounds.BackgroundMusic, Data.game.musicVolume, true);

		currentRaceLanes = Data.game.easyLanes;
		currentRaceCars = Data.game.easyCars;
		currentCivilianCars = Data.game.easyCivilianCars;
		currentRaceLength = Data.game.raceLength10k;
		currentRaceNoCivilians = false;

		finalRacecarListing = [];

		bettedCar = 0;

		money = 100;

		totalMoneyBetted = 0;
		totalMoneyWon = 0;
		totalMoneyLost = 0;

		carColors = [
			Color.fromFloats(1, 0, 0),
			Color.fromFloats(1, 1, 0),
			Color.fromFloats(0, 1, 0),
			Color.fromFloats(0, 1, 1),
			Color.fromFloats(0, 0, 1),
			Color.fromFloats(1, 0, 1),
			Color.fromFloats(0, 1, 0.5),
			Color.fromFloats(1, 0.5, 0),
			Color.fromFloats(0.5, 0, 1),
			Color.fromFloats(0.5, 1, 0),
			Color.fromFloats(.3, .3, .3),
			Color.fromFloats(.6, .6, .6),
			Color.fromFloats(1, 1, 1)
		];

		cars = [];
		for(i in 0...MAX_CAR_COUNT) {
			cars.push(new Car(0, 0, i, 0));
		}

		musicToggle = Button.fromFrame(Application.width * 0.85, Application.height * 0.95, ExtAssets.frames.ButtonMusic);
		soundFXToggle = Button.fromFrame(Application.width * 0.95, Application.height * 0.95, ExtAssets.frames.ButtonFX);
		soundFX = true;
	}

	public static function playSound(sound:Sound, soundVolume:Float, vector:Vector2) {
		if(soundFX) {
			var deltaY = (Math.abs(vector.y - cars[bettedCar].position.y) + 1) * Data.game.volumeDistanceMultiplier;
			var volume:Float = MathExt.clamp(soundVolume * (Application.height / deltaY), 0, 1);
			if(volume > Data.game.volumeThreshold) {
				Application.audio.playSound(sound, volume);
			}
		}
	}

	public static function updateUI(delta:Float) {
		if(musicToggle.inputPressed()) {
			if(music.volume > 0) {
				music.volume = 0;
				musicToggle.color.A = 0.3;
			}
			else {
				music.volume = Data.game.musicVolume;
				musicToggle.color.A = 1;
			}
		}

		if(soundFXToggle.inputPressed()) {
			for(audio in Application.audio.audios) {
				if(audio != music) {
					Application.audio.endChannel(audio);
				}
			}
			soundFX = !soundFX;
			soundFXToggle.color.A = soundFX ? 1 : 0.3;
		}
	}

	public static function renderUI(backbuffer:Image) {
		musicToggle.render(backbuffer);
		soundFXToggle.render(backbuffer);
	}

}