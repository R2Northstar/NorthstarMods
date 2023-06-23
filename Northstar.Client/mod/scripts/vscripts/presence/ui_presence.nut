untyped
globalize_all_functions

UIPresenceStruct function NorthstarCodeCallback_GenerateUIPresence( UIPresenceStruct uis ) {
	if (uiGlobal.isLoading)
		uis.game_state = eDiscordGameState.LOADING;
	else if (uiGlobal.loadedLevel == "")
		uis.game_state = eDiscordGameState.MAINMENU;
	else if (IsLobby())
		uis.game_state = eDiscordGameState.LOBBY;
	else
		uis.game_state = eDiscordGameState.INGAME;

	return uis
}