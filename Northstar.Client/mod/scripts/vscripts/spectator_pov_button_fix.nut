global function SpectatorPovButtonFixInit

void function SpectatorPovButtonFixInit(){
	RegisterButtonPressedCallback(MOUSE_MIDDLE, SwitchPov)
}

void function SwitchPov(var button){
	if(IsSpectating() && GetLocalClientPlayer() != null){
		GetLocalClientPlayer().ClientCommand("spec_mode")
	}
}

