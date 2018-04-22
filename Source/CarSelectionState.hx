import kext.Application;
import kext.AppState;
import kext.ExtAssets;
import kext.g2basics.BasicSprite;
import kext.g2basics.Button;

import kha.Image;
import kha.Color;

class CarSelectionState extends AppState {

	private var background:BasicSprite;
	private var title:BasicSprite;

	private var carButtons:Array<Button>;

	private var roadLengthButtons:Array<Button>;
	private var roadSelected:Button;
	private var roadSelectedSprite:BasicSprite;
	private var civiliansButtons:Array<Button>;
	private var civiliansSelected:Button;
	private var civiliansSelectedSprite:BasicSprite;

	public function new() {
		super();

		background = BasicSprite.fromFrame(Application.width * 0.5, Application.height * 0.5, ExtAssets.frames.Background);
		title = BasicSprite.fromFrame(Application.width * 0.5, Application.height * 0.2, ExtAssets.frames.CarSelectionTitle);

		carButtons = [];
		for(i in 0...GameData.currentRaceCars) {
			var x = Application.width * 0.25 + Application.width * 0.1 * (i % 6);
			var y = Application.height * 0.4 + Application.height * 0.2 * Math.floor(i / 6);
			var button:Button = Button.fromFrame(x, y, ExtAssets.frames.Car, "");
			button.color = GameData.carColors[i];
			carButtons.push(button);
		}

		roadLengthButtons = [];
		var x = Application.width * 0.2;
		var y = Application.height * 0.8;
		roadLengthButtons.push(Button.fromFrame(x, y, ExtAssets.frames.UIButtonSmall, "5 Km"));
		roadLengthButtons.push(Button.fromFrame(x + Application.width * 0.2, y, ExtAssets.frames.UIButtonSmall, "10 Km"));
		roadLengthButtons.push(Button.fromFrame(x + Application.width * 0.4, y, ExtAssets.frames.UIButtonSmall, "15 Km"));
		roadLengthButtons.push(Button.fromFrame(x + Application.width * 0.6, y, ExtAssets.frames.UIButtonSmall, "25 Km"));
		roadSelected = roadLengthButtons[1];
		GameData.currentRaceLength = Data.game.raceLength10k;
		roadSelectedSprite = BasicSprite.fromFrame(0, 0, ExtAssets.frames.UIButtonSmallSelected);

		civiliansButtons = [];
		var x = Application.width * 0.4;
		var y = Application.height * 0.9;
		civiliansButtons.push(Button.fromFrame(x, y, ExtAssets.frames.UIButtonSmall, "Civilian"));
		civiliansButtons.push(Button.fromFrame(x + Application.width * 0.2, y, ExtAssets.frames.UIButtonSmall, "No Civilian"));
		civiliansSelected = civiliansButtons[0];
		GameData.currentRaceNoCivilians = false;
		civiliansSelectedSprite = BasicSprite.fromFrame(0, 0, ExtAssets.frames.UIButtonSmallSelected);
	}

	override public function update(delta:Float) {
		var i = 0;
		for(button in carButtons) {
			if(button.inputPressed()) {
				startGame(i);
			}
			i++;
		}

		var i = 0;
		for(button in roadLengthButtons) {
			if(button.inputPressed()) {
				roadSelected = button;
				switch(i) {
					case 0: GameData.currentRaceLength = Data.game.raceLength5k;
					case 1: GameData.currentRaceLength = Data.game.raceLength10k;
					case 2: GameData.currentRaceLength = Data.game.raceLength15k;
					case 3: GameData.currentRaceLength = Data.game.raceLength25k;
				}
			}
			i++;
		}
		
		i = 0;
		for(button in civiliansButtons) {
			if(button.inputPressed()) {
				civiliansSelected = button;
				GameData.currentRaceNoCivilians = i == 1;
			}
			i++;
		}

		GameData.updateUI(delta);
	}

	private function startGame(carSelected:Int) {
		GameData.bettedCar = carSelected;
		Application.changeState(GameState);
	}

	private static var clearColor = Color.fromString("#FF008000");
	override public function render(backbuffer:Image) {
		backbuffer.g2.begin(true, clearColor);

		background.render(backbuffer);
		title.render(backbuffer);

		clearTransformation2D(backbuffer);
		backbuffer.g2.color = Color.fromFloats(0, 0, 0, 0.7);
		backbuffer.g2.fillRect(Application.width * 0.1, Application.height * 0.3,
			Application.width * 0.8, Application.height * 0.4);

		for(button in carButtons) {
			button.render(backbuffer);
		}

		for(button in roadLengthButtons) {
			button.render(backbuffer);
		}
		roadSelectedSprite.position = roadSelected.position;
		roadSelectedSprite.render(backbuffer);

		for(button in civiliansButtons) {
			button.render(backbuffer);
		}
		civiliansSelectedSprite.position = civiliansSelected.position;
		civiliansSelectedSprite.render(backbuffer);

		GameData.renderUI(backbuffer);

		backbuffer.g2.end();
	}

}