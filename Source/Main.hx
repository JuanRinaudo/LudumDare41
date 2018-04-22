import kext.Application;

class Main {

	public static function main() {
		var systemOptions:Dynamic = {
			width: Data.system.width,
			height: Data.system.height,
			title: Data.system.name
		};
		var applicationOptions:Dynamic = {
			initState: IntroState,
			bufferWidth: Data.system.bufferWidth,
			bufferHeight: Data.system.bufferHeight,
			defaultFontName: "KenPixel"
		};
		#if debug
		applicationOptions.initState = Data.debug.startingState != "" ? Type.resolveClass(Data.debug.startingState) : applicationOptions.initState;
		#end
		new Application(systemOptions, applicationOptions);
	}

}