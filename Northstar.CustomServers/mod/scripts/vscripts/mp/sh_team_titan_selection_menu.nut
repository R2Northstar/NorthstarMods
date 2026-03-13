#if SERVER
global function TeamTitanSelectMenu_Init
#endif

#if CLIENT
global function ServerCallback_OpenTeamTitanMenu
global function ServerCallback_CloseTeamTitanMenu
global function ServerCallback_UpdateTeamTitanMenuTime
global function ClTeamTitanSelectMenu_Init
global function PlayTTSMusic
#endif

global function TimeIsBeforeJumpSound

global const TEAM_TITAN_SELECT_DURATION_MIDGAME = 20.0

const float PICK_LOADOUT_TIME_MAX = 40.0

struct
{
	float pick_loadout_start_time
} file

#if SERVER
void function TeamTitanSelectMenu_Init()
{
	RegisterSignal( "StopSendingTTSMenuCommand" )
	AddCallback_GameStateEnter( eGameState.PickLoadout, TeamTitan_OnPickLoadout )
	AddCallback_GameStateEnter( eGameState.Prematch, TeamTitan_OnPrematch )
	AddCallback_OnClientConnected( TTS_OnClientConnected )
	TeamTitanSelection_Init()
}

void function TeamTitan_OnPickLoadout()
{
	StartUpdatingTeamTitanSelection()
	foreach ( player in GetPlayerArray() )
	{
		thread TryOpenTTSMenu( player )
	}

	file.pick_loadout_start_time = Time()
}

void function TeamTitan_OnPrematch()
{
	StopUpdatingTeamTitanSelection()
	foreach ( player in GetPlayerArray() )
	{
		player.Signal( "StopSendingTTSMenuCommand" )
		Remote_CallFunction_NonReplay( player, "ServerCallback_CloseTeamTitanMenu" )
	}
}

void function TTS_OnClientConnected( entity player ) //LTS Only
{
	float soundTime = DoPrematchWarpSound() ? PICK_LOADOUT_SOUND_TIME : 0.0

	if ( GetGameState() == eGameState.PickLoadout && TimeIsBeforeJumpSound() )
	{
		TryExtendPickLoadoutTime()
		thread TryOpenTTSMenu( player )
	}
	else if ( GetGameState() >= eGameState.PickLoadout && GetCurrentPlaylistVarInt( "tts_menu_join_in_progress", 0 ) == 1 )
	{
		float endTime = Time() + TEAM_TITAN_SELECT_DURATION_MIDGAME

		thread SpawnPlayerAfterDelay( player, endTime - soundTime )
		thread TryOpenTTSMenu( player, endTime )
	}
}

void function TryExtendPickLoadoutTime()
{
	float soundTime = DoPrematchWarpSound() ? PICK_LOADOUT_SOUND_TIME : 0.0

	if ( level.nv.minPickLoadOutTime == null )
		return

	float endTime = expect float( level.nv.minPickLoadOutTime )

	printt( "OLD END TIME : " + endTime )

	level.nv.minPickLoadOutTime = min( max( endTime, Time() + 20.0 + soundTime ), file.pick_loadout_start_time + PICK_LOADOUT_TIME_MAX )
	endTime = expect float( level.nv.minPickLoadOutTime )

	printt( "NEW END TIME : " + endTime )

	foreach ( player in GetPlayerArray() )
	{
		Remote_CallFunction_Replay( player, "ServerCallback_UpdateTeamTitanMenuTime", endTime )
	}
}

void function SpawnPlayerAfterDelay( entity player, float endTime )
{
	player.EndSignal( "OnDestroy" )
	player.SetInvulnerable()

	wait endTime - Time() - 0.5

	ScreenFadeToBlack( player, 0.5, 2.0 )

	wait 0.5

	player.Signal( "StopSendingTTSMenuCommand" )
	Remote_CallFunction_NonReplay( player, "ServerCallback_CloseTeamTitanMenu" )
	FadeOutSoundOnEntity( player, "Duck_For_FrontierDefenseTitanSelectScreen" , 1.0)
	StopUpdatingTeamTitanSelection()

	wait 0.1

	ScreenFadeFromBlack( player, 0.5, 0.0 )
	player.ClearInvulnerable()
}

void function TryOpenTTSMenu( entity player, float overrideEndTime = -1 )
{
	player.EndSignal( "OnDestroy" )
	ScreenFadeToBlackForever( player, 0.0 )

	while ( level.nv.minPickLoadOutTime == null )
		WaitFrame()

	wait 1.0

	player.StopObserverMode()

	thread PlayerUpdateTeamTitanSelectionThink( player )

	float endTime = overrideEndTime == -1 ? expect float( level.nv.minPickLoadOutTime ) : overrideEndTime

	EmitSoundOnEntityOnlyToPlayer( player, player, "Duck_For_FrontierDefenseTitanSelectScreen" )
	thread KeepSendingTTSMenuCommand( player, endTime )
	ScreenFadeFromBlack( player, 1.0, 1.5 )

	float soundTime = DoPrematchWarpSound() ? PICK_LOADOUT_SOUND_TIME : 0.0

	while ( Time() < endTime - soundTime )
	{
		WaitFrame()
		endTime = overrideEndTime == -1 ? expect float( level.nv.minPickLoadOutTime ) : overrideEndTime
	}

	player.Signal( "StopSendingTTSMenuCommand" )
	StopSoundOnEntity( player, "Duck_For_FrontierDefenseTitanSelectScreen" )

	if ( GetGameState() == eGameState.PickLoadout )
		ScreenFadeToBlackForever( player, 2.0 )
}

void function KeepSendingTTSMenuCommand( entity player, float endTime )
{
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "StopSendingTTSMenuCommand" )

	while ( 1 )
	{
		if ( !player.IsInvulnerable() )
			player.SetInvulnerable()
		Remote_CallFunction_UI( player, "ServerCallback_RegisterTeamTitanMenuButtons" )
		Remote_CallFunction_Replay( player, "ServerCallback_OpenTeamTitanMenu", endTime )
		wait 0.2
	}

}

#endif

#if CLIENT
void function ClTeamTitanSelectMenu_Init()
{
	CLTeamTitanSelection_Init()
}

void function ServerCallback_OpenTeamTitanMenu( float endTime )
{
	if ( Time() > endTime )
		return

	entity player = GetLocalClientPlayer()

	float soundTime = DoPrematchWarpSound() ? PICK_LOADOUT_SOUND_TIME : 0.0

	RunUIScript( "ServerCallback_OpenTeamTitanMenu", endTime - Time() - soundTime - 1.0 )
	string gameMode = GAMETYPE_TEXT[ GameRules_GetGameMode() ]
	RunUIScript( "TTSMenu_UpdateGameMode", gameMode )

	int xpMul = player.GetPlayerNetInt( "xpMultiplier" )
	int count = Player_GetDoubleXPCount( player )
	bool firstRound = ( GetRoundsPlayed() == 0 )
	bool avialable = (count > 0 || xpMul > 0) && !IsPrivateMatch() && firstRound
	float status = float( xpMul )

	RunUIScript( "TTSUpdateDoubleXP", count, avialable, status )
	if ( GameRules_GetGameMode() == FD )
	{
		string diff = FD_GetDifficultyString()
		RunUIScript( "TTSMenu_UpdateGameMode", Localize( "#FD_DIFFICULTY_TITLE", Localize( diff ) ) )
	}
}

void function PlayTTSMusic()
{
	thread PlayMusic( eMusicPieceID.TITAN_SELECT )

	bool showScore = GetCurrentPlaylistVarInt( "tts_menu_show_score", 1 ) == 1

	if ( !showScore )
		Menu_CreateTeamTitanSelectionScreen_NoScore()
	else
		Menu_CreateTeamTitanSelectionScreen()
}

void function ServerCallback_UpdateTeamTitanMenuTime( float endTime )
{
	printt( "NEW END TIME RECEIVED : " + endTime + " , " + Time() )

	if ( Time() > endTime )
		return

	printt( "NEW END TIME UPDATED : " + endTime )

	float soundTime = DoPrematchWarpSound() ? PICK_LOADOUT_SOUND_TIME : 0.0

	RunUIScript( "ServerCallback_UpdateTeamTitanMenuTime", endTime - Time() - soundTime - 1.0 )
}

void function ServerCallback_CloseTeamTitanMenu()
{
	DestroyTeamTitanSelectionScreen()
	RunUIScript( "ServerCallback_CloseTeamTitanMenu" )
	if ( IsMusicTrackPlaying( eMusicPieceID.TITAN_SELECT ) )
		StopMusic()
}
#endif

bool function TimeIsBeforeJumpSound()
{
	if ( level.nv.minPickLoadOutTime == null )
		return true

	float soundTime = DoPrematchWarpSound() ? PICK_LOADOUT_SOUND_TIME : 0.0

	float endTime = expect float( level.nv.minPickLoadOutTime )
	endTime -= soundTime

	return Time() < endTime
}