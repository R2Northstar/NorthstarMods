global function SpectatorPovButtonFixInit

void function SpectatorPovButtonFixInit()
{
	RegisterButtonPressedCallback( MOUSE_MIDDLE, SwitchPov )
	RegisterButtonPressedCallback( BUTTON_B, SwitchPov )
}

void function SwitchPov(var button)
{
	// the vanilla (native) way of calling spec_mode works just fine when in first person spectating
	// but not in third person. Duplicate spec_mode commands just result in it going back to what it was
	// originally, so only call spec_mode if we are in third person spectate
	if ( IsSpectating() && IsValid(GetLocalClientPlayer()) && GetLocalClientPlayer().GetObserverMode() == OBS_MODE_CHASE )
		GetLocalClientPlayer().ClientCommand("spec_mode")
}

