import kha.Assets;
import kha.Image;
import kha.Sound;
import kha.input.KeyCode;

import kext.Application;
import kext.Basic;
import kext.ExtAssets;
import kext.g2basics.BasicSprite;
import kext.g2basics.Button;
import kext.utils.Countdown;

enum AbilityType {
	BOOST;
	LIGHTING;
	HOLE;
	PLANKS;
	COMMANDLEFT;
	COMMANDRIGHT;
	REPAIR;
	IMMUNITY;
	TELEPORT;
	SHRINK;
	ENLARGE;
}

class GodAbilities extends Basic {

	public var buttonSelected:Button;
	public var countdownSelected:Countdown;
	public var abilityButtons:Array<Button>;
	public var abilityCooldowns:Array<Countdown>;

	public var buttonSelectedHighlight:BasicSprite;

	public function new() {
		super();

		abilityButtons = [];
		abilityCooldowns = [];
		createButton(BOOST, Data.game.boostCooldown);
		createButton(LIGHTING, Data.game.lightingCooldown);
		// createButton(HOLE);
		// createButton(PLANKS);
		createButton(COMMANDLEFT, Data.game.commandLeftCooldown);
		createButton(COMMANDRIGHT, Data.game.commandRightCooldown);
		createButton(REPAIR, Data.game.repairCooldown);
		createButton(IMMUNITY, Data.game.immunityCooldown);
		createButton(TELEPORT, Data.game.teleportCooldown);
		createButton(SHRINK, Data.game.shrinkCooldown);
		createButton(ENLARGE, Data.game.enlargeCooldown);

		buttonSelectedHighlight = BasicSprite.fromFrame(0, 0, ExtAssets.frames.ButtonSelected);
	}

	private function createButton(type:AbilityType, cooldown:Float) {
		var frame = getButtonAsset(type);
		var x = Application.width - frame.rectangle.width * 1.2 * (2 - abilityButtons.length % 2);
		var y = Application.height * 0.1 + Math.floor(abilityButtons.length / 2) * frame.rectangle.height * 1.2;
		var button = new Button(x, y, null, "", true);
		button.setFrame(frame);
		abilityButtons.push(button);
		abilityCooldowns.push(new Countdown(cooldown, Application.deltaTime));
	}

	private function getButtonAsset(type:AbilityType) {
		switch(type) {
			case BOOST: return ExtAssets.frames.ButtonBoost;
			case LIGHTING: return ExtAssets.frames.ButtonLighting;
			case HOLE: return ExtAssets.frames.ButtonHole;
			case PLANKS: return ExtAssets.frames.ButtonPlank;
			case COMMANDLEFT: return ExtAssets.frames.ButtonCommandLeft;
			case COMMANDRIGHT: return ExtAssets.frames.ButtonCommandRight;
			case REPAIR: return ExtAssets.frames.ButtonRepair;
			case IMMUNITY: return ExtAssets.frames.ButtonImmunity;
			case TELEPORT: return ExtAssets.frames.ButtonTeleport;
			case SHRINK: return ExtAssets.frames.ButtonShrink;
			case ENLARGE: return ExtAssets.frames.ButtonEnlarge;
		}
	}

	override public function update(delta:Float) {
		for(cooldown in abilityCooldowns) {
			cooldown.tick();
		}

		var clickedAbility:Bool = false;
		var i = 0;
		for(button in abilityButtons) {
			if(button.inputPressed() && abilityCooldowns[i].done()) {
				buttonSelected = button;
				countdownSelected = abilityCooldowns[i];
				clickedAbility = true;
				break;
			}
			i++;
		}

		if(Application.keyboard.keyDown(KeyCode.One) && abilityCooldowns[0].done()) { buttonSelected = abilityButtons[0]; countdownSelected = abilityCooldowns[0]; }
		if(Application.keyboard.keyDown(KeyCode.Two) && abilityCooldowns[1].done()) { buttonSelected = abilityButtons[1]; countdownSelected = abilityCooldowns[1]; }
		if(Application.keyboard.keyDown(KeyCode.Three) && abilityCooldowns[2].done()) { buttonSelected = abilityButtons[2]; countdownSelected = abilityCooldowns[2]; }
		if(Application.keyboard.keyDown(KeyCode.Four) && abilityCooldowns[3].done()) { buttonSelected = abilityButtons[3]; countdownSelected = abilityCooldowns[3]; }
		if(Application.keyboard.keyDown(KeyCode.Five) && abilityCooldowns[4].done()) { buttonSelected = abilityButtons[4]; countdownSelected = abilityCooldowns[4]; }
		if(Application.keyboard.keyDown(KeyCode.Six) && abilityCooldowns[5].done()) { buttonSelected = abilityButtons[5]; countdownSelected = abilityCooldowns[5]; }
		if(Application.keyboard.keyDown(KeyCode.Seven) && abilityCooldowns[6].done()) { buttonSelected = abilityButtons[6]; countdownSelected = abilityCooldowns[6]; }
		if(Application.keyboard.keyDown(KeyCode.Eight) && abilityCooldowns[7].done()) { buttonSelected = abilityButtons[7]; countdownSelected = abilityCooldowns[7]; }
		if(Application.keyboard.keyDown(KeyCode.Nine) && abilityCooldowns[8].done()) { buttonSelected = abilityButtons[8]; countdownSelected = abilityCooldowns[8]; }
		
		if(buttonSelected != null) {
			buttonSelectedHighlight.position = buttonSelected.position;
			if(!clickedAbility && Application.mouse.buttonPressed(0)) {
				castAbility(getSelectedType());
				countdownSelected.start();
			}
		}
	}

	private function getSelectedType():AbilityType {
		if(buttonSelected.frame == ExtAssets.frames.ButtonBoost) { return BOOST; }
		if(buttonSelected.frame == ExtAssets.frames.ButtonLighting) { return LIGHTING; }
		if(buttonSelected.frame == ExtAssets.frames.ButtonHole) { return HOLE; }
		if(buttonSelected.frame == ExtAssets.frames.ButtonPlank) { return PLANKS; }
		if(buttonSelected.frame == ExtAssets.frames.ButtonCommandLeft) { return COMMANDLEFT; }
		if(buttonSelected.frame == ExtAssets.frames.ButtonCommandRight) { return COMMANDRIGHT; }
		if(buttonSelected.frame == ExtAssets.frames.ButtonRepair) { return REPAIR; }
		if(buttonSelected.frame == ExtAssets.frames.ButtonImmunity) { return IMMUNITY; }
		if(buttonSelected.frame == ExtAssets.frames.ButtonTeleport) { return TELEPORT; }
		if(buttonSelected.frame == ExtAssets.frames.ButtonShrink) { return SHRINK; }
		if(buttonSelected.frame == ExtAssets.frames.ButtonEnlarge) { return ENLARGE; }
		
		return null;
	}

	public function castAbility(type:AbilityType) {
		buttonSelected = null;
		var car:Car = getCarOnMouse();
		switch(type) {
			case BOOST:
				if(car == null) { return; }
				car.carBoost = Data.game.carBoost;
				playAbilitySound(Assets.sounds.CarBoost, Data.game.commandVolume);
			case LIGHTING:
				if(car == null) { return; }
				car.damage();
				playAbilitySound(Assets.sounds.Lighting, Data.game.commandVolume);
				return;
			case HOLE:
				
				return;
			case PLANKS:

				return;
			case COMMANDLEFT:
				if(car == null) { return; }
				car.targetLane = car.lane - 1;
				car.commandedChange = true;
				playAbilitySound(Assets.sounds.Command, Data.game.commandVolume);
			case COMMANDRIGHT:
				if(car == null) { return; }
				car.targetLane = car.lane + 1;
				car.commandedChange = true;
				playAbilitySound(Assets.sounds.Command, Data.game.commandVolume);
			case REPAIR:
				if(car == null) { return; }
				car.repair();
			case IMMUNITY:
				if(car == null) { return; }
				car.immuneTime = Data.game.abilityImmuneTime;
				playAbilitySound(Assets.sounds.Immune, Data.game.immunityVolume);
			case TELEPORT:
				if(car == null) { return; }
				car.position.y -= Data.game.teleportDistance;
				playAbilitySound(Assets.sounds.Teleport, Data.game.teleportVolume);
			case SHRINK:
				if(car == null) { return; }
				car.scaleCar(Data.game.shrinkDelta);
				playAbilitySound(Assets.sounds.Shrink, Data.game.shrinkVolume);
			case ENLARGE:
				if(car == null) { return; }
				car.scaleCar(Data.game.enlargeDelta);
				playAbilitySound(Assets.sounds.Enlarge, Data.game.enlargeVolume);
		}
	}

	private inline function playAbilitySound(sound:Sound, volume:Float) {
		if(GameData.soundFX) {
			Application.audio.playSound(sound, volume);
		}
	}

	public function getCarOnMouse() {
		for(car in GameData.cars) {
			if(car.bounds.checkVectorOverlap(Application.mouse.mousePosition)) {
				return car;
			}
		}
		return null;
	}

	override public function render(backbuffer:Image) {
		var i = 0;
		for(button in abilityButtons) {
			var countdown:Countdown = abilityCooldowns[i];
			button.color.R = button.color.G = button.color.B = countdown.done() ? 1 : 0.4;
			button.color.A = (1 - (countdown.currentValue / countdown.targetValue)) * 0.8 + 0.2;
			button.render(backbuffer);
			i++;
		}

		if(buttonSelected != null) {
			buttonSelectedHighlight.render(backbuffer);
		}
	}

}