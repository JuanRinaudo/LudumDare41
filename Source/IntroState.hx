import kext.Application;
import kext.AppState;
import kext.ExtAssets;
import kext.g2basics.BasicSprite;
import kext.g2basics.Button;
import kext.g2basics.Text;

import kha.Image;
import kha.Color;

class IntroState extends AppState {

	private var background:BasicSprite;

	private var loreText:Text;
	private var abilityHelp:BasicSprite;

	private var mainMenuButton:Button;

	public function new() {
		super();

		background = BasicSprite.fromFrame(Application.width * 0.5, Application.height * 0.5, ExtAssets.frames.Background);

		loreText = new Text(Application.width * 0.275, Application.height * 0.4, Application.width * 0.4, Application.height * 0.4,
			"You are a bored god.\n\nYou decide to play with some\nstreet racers.\n\nChoose a car and use your\ngodly abilities to make it win");
		abilityHelp = BasicSprite.fromFrame(Application.width * 0.7, Application.height * 0.4, ExtAssets.frames.AbilitiesHelp);

		mainMenuButton = Button.fromFrame(Application.width * 0.5, Application.height * 0.9, ExtAssets.frames.UIButton, "Main Menu");
	}

	override public function update(delta:Float) {
		if(mainMenuButton.inputPressed()) {
			Application.changeState(MenuState);
		}
	}

	private static var clearColor = Color.fromString("#FF008000");
	override public function render(backbuffer:Image) {
		backbuffer.g2.begin(true, clearColor);

		background.render(backbuffer);
		clearTransformation2D(backbuffer);
		backbuffer.g2.color = Color.fromFloats(0, 0, 0, 0.75);
		backbuffer.g2.fillRect(Application.width * 0.05, Application.height * 0.05, Application.width * 0.9, Application.height * 0.7);

		loreText.render(backbuffer);
		abilityHelp.render(backbuffer);

		mainMenuButton.render(backbuffer);

		backbuffer.g2.end();
	}


}