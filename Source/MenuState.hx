import kext.ExtAssets;
import kext.Application;
import kext.AppState;
import kext.g2basics.BasicSprite;
import kext.g2basics.Button;

import kha.Assets;
import kha.Image;
import kha.Color;

class MenuState extends AppState {

	private var background:BasicSprite;
	private var title:BasicSprite;

	private var easyButton:Button;
	private var normalButton:Button;
	private var hardButton:Button;
	private var insanityButton:Button;

	public function new() {
		super();

		GameData.init();

		background = BasicSprite.fromFrame(Application.width * 0.5, Application.height * 0.5, ExtAssets.frames.Background);
		title = BasicSprite.fromFrame(Application.width * 0.5, Application.height * 0.2, ExtAssets.frames.Title);

		var buttonsOffsetY = 128;
		easyButton = Button.fromFrame(Application.width * 0.5, buttonsOffsetY + 64, ExtAssets.frames.UIButton,
			"Easy\n4 Cars - 10 Car Lanes");
		normalButton = Button.fromFrame(Application.width * 0.5, buttonsOffsetY + 64 * 2, ExtAssets.frames.UIButton,
			"Normal\n8 Cars - 8 Car Lanes");
		hardButton = Button.fromFrame(Application.width * 0.5, buttonsOffsetY + 64 * 3, ExtAssets.frames.UIButton,
			"Hard\n12 Cars - 6 Car Lanes");
		insanityButton = Button.fromFrame(Application.width * 0.5, buttonsOffsetY + 64 * 4, ExtAssets.frames.UIButton,
			"Total Insanity\n12 Cars - 2 Car Lanes");
	}

	override public function update(delta:Float) {
		if(easyButton.inputPressed()) { startGame(Data.game.easyLanes, Data.game.easyCars, Data.game.easyCivilianCars); }
		if(normalButton.inputPressed()) { startGame(Data.game.normalLanes, Data.game.normalCars, Data.game.normalCivilianCars); }
		if(hardButton.inputPressed()) { startGame(Data.game.hardLanes, Data.game.hardCars, Data.game.hardCivilianCars); }
		if(insanityButton.inputPressed()) { startGame(Data.game.insanityLanes, Data.game.insanityCars, Data.game.insanityCivilianCars); }
		
		GameData.updateUI(delta);
	}

	private function startGame(lanes:Int, cars:Int, civilianCars:Int) {
		GameData.currentRaceLanes = lanes;
		GameData.currentRaceCars = cars;
		GameData.currentCivilianCars = civilianCars;
		GameData.finalRacecarListing = [];
		Application.changeState(CarSelectionState);
	}

	private static var clearColor = Color.fromString("#FF008000");
	override public function render(backbuffer:Image) {
		backbuffer.g2.begin(true, clearColor);

		background.render(backbuffer);
		title.render(backbuffer);

		easyButton.render(backbuffer);
		normalButton.render(backbuffer);
		hardButton.render(backbuffer);
		insanityButton.render(backbuffer);

		GameData.renderUI(backbuffer);

		backbuffer.g2.end();
	}

}