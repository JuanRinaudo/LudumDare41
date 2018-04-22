import kext.Application;
import kext.AppState;
import kext.ExtAssets;
import kext.g2basics.BasicSprite;
import kext.g2basics.Button;

import kha.Image;
import kha.Color;

class GameEndState extends AppState {

	private var background:BasicSprite;
	private var rankSprites:Array<BasicSprite>;

	private var mainMenuButton:Button;

	public function new() {
		super();

		background = BasicSprite.fromFrame(Application.width * 0.5, Application.height * 0.5, ExtAssets.frames.Background);

		rankSprites = [];
		var i = 0;
		for(car in GameData.finalRacecarListing) {
			car.position.x = car.frame.rectangle.width * ((i % 2 + 1) * 4.5);
			car.position.y = car.frame.rectangle.height * 0.6 * (i + 2);
			var rankX = car.position.x + (i % 2 == 0 ? -1.5 : 1.5) * car.frame.rectangle.width; 
			rankSprites.push(BasicSprite.fromFrame(rankX, car.position.y, ExtAssets.frames.get("Rank" + i)));
			i++;
		}

		mainMenuButton = Button.fromFrame(Application.width * 0.75, 64, ExtAssets.frames.UIButton, "Main Menu");
	}

	override public function update(delta:Float) {
		if(mainMenuButton.inputPressed()) {
			Application.changeState(MenuState);
		}
		
		GameData.updateUI(delta);
	}

	private static var clearColor = Color.fromString("#FF008000");
	override public function render(backbuffer:Image) {
		backbuffer.g2.begin(true, clearColor);

		background.render(backbuffer);
		clearTransformation2D(backbuffer);
		backbuffer.g2.color = Color.fromFloats(0, 0, 0, 0.75);
		backbuffer.g2.fillRect(0, 0, Application.width * 0.5, Application.height);

		for(car in GameData.finalRacecarListing) {
			car.render(backbuffer);
		}

		for(sprite in rankSprites) {
			sprite.render(backbuffer);
		}

		mainMenuButton.render(backbuffer);
		
		GameData.renderUI(backbuffer);

		backbuffer.g2.end();
	}


}