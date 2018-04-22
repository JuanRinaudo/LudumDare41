let project = new Project('LudumDare41');

project.addLibrary('zui');
project.addLibrary('kext');
project.addLibrary('tweenxcore');

project.addShaders('Assets/Shaders/**');

project.addAssets('Assets/Common/**');
project.addAssets('Assets/Images/**');
project.addAssets('Assets/Atlas/**');
project.addAssets('Assets/Sound/**');

project.addSources('Source');

// project.addParameter('-dce std');
// project.addParameter('-debug');

if (platform === 'debug-html5' || platform === 'html5') {
	project.addAssets('Assets/Web/**');
}

if (platform === 'debug-html5' || platform === 'krom') {
	project.addAssets('Data/**');
}

resolve(project);