import kext.data.DataWatcher;

@:build(kext.data.DataBuilder.getJSONData("system.json"))
class SystemParameters {
	public function new() {}
}

@:build(kext.data.DataBuilder.getJSONData("game.json"))
class GameParameters {
	public function new() {}
}

@:build(kext.data.DataBuilder.getJSONData("ui.json"))
class UIParameters {
	public function new() {}
}

#if debug
@:build(kext.data.DataBuilder.getJSONData("debug.json"))
class DebugParameters {
	public function new() {}
}
#end

class Data {

	public static var system: SystemParameters = new SystemParameters();
	public static var game: GameParameters = new GameParameters();
	public static var ui: UIParameters = new UIParameters();
	#if debug
	public static var debug: DebugParameters = new DebugParameters();

	public static function watchData() {
		DataWatcher.watchJSONRefreshOnChange(system, "system.json");
		DataWatcher.watchJSONRefreshOnChange(game, "game.json");
		DataWatcher.watchJSONRefreshOnChange(ui, "ui.json");
		DataWatcher.watchJSONRefreshOnChange(debug, "debug.json");
	}
	#end

}