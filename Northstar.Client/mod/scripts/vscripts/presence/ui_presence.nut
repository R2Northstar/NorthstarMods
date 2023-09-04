untyped
globalize_all_functions

UIPresenceStruct function DiscordRPC_GenerateUIPresence( UIPresenceStruct uis )
{
	if ( uiGlobal.isLoading )
		uis.game_state = eDiscordGameState.LOADING;
	else if ( uiGlobal.loadedLevel == "" )
		uis.game_state = eDiscordGameState.MAINMENU;
	else if ( IsLobby() || uiGlobal.loadedLevel == "mp_lobby" )
		uis.game_state = eDiscordGameState.LOBBY;
	else
		uis.game_state = eDiscordGameState.INGAME;

	return uis
}