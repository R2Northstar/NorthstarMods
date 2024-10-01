untyped

global function PIN_GameStart
global function SetGameState
global function GameState_EntitiesDidLoad
global function WaittillGameStateOrHigher
global function AddCallback_OnRoundEndCleanup

global function SetShouldUsePickLoadoutScreen
global function SetShouldSpectateInPickLoadoutScreen
global function SetSwitchSidesBased
global function SetSuddenDeathBased
global function SetTimerBased
global function SetShouldUseRoundWinningKillReplay
global function SetRoundWinningKillReplayKillClasses
global function SetRoundWinningKillReplayAttacker
global function SetCallback_TryUseProjectileReplay
global function ShouldTryUseProjectileReplay
global function SetWinner
global function SetTimeoutWinnerDecisionFunc
global function AddTeamScore

global function GameState_GetTimeLimitOverride
global function IsRoundBasedGameOver
global function SpectatePlayerDuringPickLoadout
global function ShouldRunEvac
global function GiveTitanToPlayer
global function GetTimeLimit_ForGameMode

struct {
	// used for togglable parts of gamestate
	bool usePickLoadoutScreen
	bool spectateInPickLoadoutScreen = false
	bool switchSidesBased
	bool suddenDeathBased
	bool timerBased = true
	int functionref() timeoutWinnerDecisionFunc
	
	bool hasSwitchedSides
	
	int announceRoundWinnerWinningSubstr
	int announceRoundWinnerLosingSubstr
		
	bool roundWinningKillReplayTrackPilotKills = true 
	bool roundWinningKillReplayTrackTitanKills = false
	
	bool gameWonThisFrame
	bool hasKillForGameWonThisFrame
	float roundWinningKillReplayTime
	entity roundWinningKillReplayVictim
	entity roundWinningKillReplayAttacker
	int roundWinningKillReplayInflictorEHandle // this is either the inflictor or the attacker
	int roundWinningKillReplayMethodOfDeath
	float roundWinningKillReplayTimeOfDeath
	float roundWinningKillReplayHealthFrac
	
	array<void functionref()> roundEndCleanupCallbacks
	bool functionref( entity victim, entity attacker, var damageInfo, bool isRoundEnd ) shouldTryUseProjectileReplayCallback
} file









/*
 ██████   █████  ███    ███ ███████ ███████ ████████  █████  ████████ ███████ ███████ 
██       ██   ██ ████  ████ ██      ██         ██    ██   ██    ██    ██      ██      
██   ███ ███████ ██ ████ ██ █████   ███████    ██    ███████    ██    █████   ███████ 
██    ██ ██   ██ ██  ██  ██ ██           ██    ██    ██   ██    ██    ██           ██ 
 ██████  ██   ██ ██      ██ ███████ ███████    ██    ██   ██    ██    ███████ ███████ 
*/

void function PIN_GameStart()
{
	SetServerVar( "switchedSides", 0 )
	
	AddCallback_GameStateEnter( eGameState.WaitingForCustomStart, GameStateEnter_WaitingForCustomStart )
	AddCallback_GameStateEnter( eGameState.WaitingForPlayers, GameStateEnter_WaitingForPlayers )
	AddCallback_OnClientConnected( WaitingForPlayers_ClientConnected )
	
	AddCallback_GameStateEnter( eGameState.PickLoadout, GameStateEnter_PickLoadout )
	AddCallback_GameStateEnter( eGameState.Prematch, GameStateEnter_Prematch )
	AddCallback_GameStateEnter( eGameState.Playing, GameStateEnter_Playing )
	AddCallback_GameStateEnter( eGameState.WinnerDetermined, GameStateEnter_WinnerDetermined )
	AddCallback_GameStateEnter( eGameState.SwitchingSides, GameStateEnter_SwitchingSides )
	AddCallback_GameStateEnter( eGameState.SuddenDeath, GameStateEnter_SuddenDeath )
	AddCallback_GameStateEnter( eGameState.Postmatch, GameStateEnter_Postmatch )
	
	AddCallback_OnPlayerKilled( OnPlayerKilled )
	AddDeathCallback( "npc_titan", OnTitanKilled )
	AddCallback_EntityChangedTeam( "player", OnPlayerChangedTeam )
	PilotBattery_SetMaxCount( GetCurrentPlaylistVarInt( "pilot_battery_inventory_size", 1 ) )
	
	RegisterSignal( "CleanUpEntitiesForRoundEnd" )
}

void function GameState_EntitiesDidLoad()
{
	ClassicMP_SetupIntro()
}

void function WaittillGameStateOrHigher( int gameState )
{
	while ( GetGameState() < gameState )
		svGlobal.levelEnt.WaitSignal( "GameStateChanged" )
}

bool function ShouldTryUseProjectileReplay( entity victim, entity attacker, var damageInfo, bool isRoundEnd )
{
	if ( file.shouldTryUseProjectileReplayCallback != null )
		return file.shouldTryUseProjectileReplayCallback( victim, attacker, damageInfo, isRoundEnd )
	// default to true (vanilla behaviour)
	return true
}

/// This is to move all NPCs that a player owns from one team to the other during a match
/// Auto-Titans, Turrets, Ticks and Hacked Spectres will all move along together with the player to the new Team
/// Also possibly prevents mods that spawns other types of NPCs that players can own from breaking when switching (i.e Drones, Hacked Reapers)
void function OnPlayerChangedTeam( entity player )
{
	if ( !player.hasConnected ) //Prevents players who just joined to trigger below code, as server always pre setups their teams
		return
	
	if ( IsIMCOrMilitiaTeam( player.GetTeam() ) )
		NotifyClientsOfTeamChange( player, GetOtherTeam( player.GetTeam() ), player.GetTeam() )
	
	foreach ( npc in GetNPCArray() )
	{
		entity bossPlayer = npc.GetBossPlayer()
		if ( IsValidPlayer( bossPlayer ) && bossPlayer == player && IsAlive( npc ) )
			SetTeam( npc, player.GetTeam() )
	}
}









/*
 ██████   █████  ███    ███ ███████     ███████ ███████ ████████ ██    ██ ██████  
██       ██   ██ ████  ████ ██          ██      ██         ██    ██    ██ ██   ██ 
██   ███ ███████ ██ ████ ██ █████       ███████ █████      ██    ██    ██ ██████  
██    ██ ██   ██ ██  ██  ██ ██               ██ ██         ██    ██    ██ ██      
 ██████  ██   ██ ██      ██ ███████     ███████ ███████    ██     ██████  ██      
*/

void function SetGameState( int newState )
{
	if ( newState == GetGameState() )
		return

	SetServerVar( "gameStateChangeTime", Time() )
	SetServerVar( "gameState", newState )
	svGlobal.levelEnt.Signal( "GameStateChanged" )

	foreach ( callbackFunc in svGlobal.gameStateEnterCallbacks[ newState ] )
		callbackFunc()
}

void function AddTeamScore( int team, int amount )
{
	GameRules_SetTeamScore( team, GameRules_GetTeamScore( team ) + amount )
	GameRules_SetTeamScore2( team, GameRules_GetTeamScore2( team ) + amount )
	
	int scoreLimit
	int score = GameRules_GetTeamScore( team )
	
	if ( IsRoundBased() )
		scoreLimit = GameMode_GetRoundScoreLimit( GAMETYPE )
	else
		scoreLimit = GameMode_GetScoreLimit( GAMETYPE )
	
	if ( score >= scoreLimit && IsRoundBased() )
		SetWinner( team, "#GAMEMODE_ROUND_LIMIT_REACHED", "#GAMEMODE_ROUND_LIMIT_REACHED" )
	else if ( score >= scoreLimit )
		SetWinner( team, "#GAMEMODE_SCORE_LIMIT_REACHED", "#GAMEMODE_SCORE_LIMIT_REACHED" )
	else if ( GetGameState() == eGameState.SuddenDeath )
		SetWinner( team )
	else if ( ( file.switchSidesBased && !file.hasSwitchedSides ) && score >= ( scoreLimit.tofloat() / 2.0 ) )
		SetGameState( eGameState.SwitchingSides )
}

void function SetWinner( int ornull team, string winningReason = "", string losingReason = "" )
{
	if( team != null )
		SetServerVar( "winningTeam", team )
	
	file.gameWonThisFrame = true
	thread UpdateGameWonThisFrameNextFrame()
	
	if ( winningReason == "" )
		file.announceRoundWinnerWinningSubstr = 0
	else
		file.announceRoundWinnerWinningSubstr = GetStringID( winningReason )
		
	if ( losingReason == "" )
		file.announceRoundWinnerLosingSubstr = 0
	else
		file.announceRoundWinnerLosingSubstr = GetStringID( losingReason )
	
	float endTime
	if ( IsRoundBased() )
		endTime = expect float( GetServerVar( "roundEndTime" ) )
	else
		endTime = expect float( GetServerVar( "gameEndTime" ) )
	
	if ( GameRules_GetGameMode() == FD ) // Reset IMC scorepoints to prevent ties and properly display winner in post-summary screen for FD
	{
		if ( team == TEAM_MILITIA )
		{
			GameRules_SetTeamScore( TEAM_IMC, 0 )
			GameRules_SetTeamScore( TEAM_MILITIA, 1 )
		}
		else if ( team == TEAM_IMC && !IsRoundBased() )
		{
			GameRules_SetTeamScore( TEAM_IMC, 1 )
			GameRules_SetTeamScore( TEAM_MILITIA, 0 )
		}
	}
	else if ( team != null && team != TEAM_UNASSIGNED )
	{
		if ( !file.timerBased || Time() < endTime && GetGameState() != eGameState.SuddenDeath )
			DebounceScoreTie( expect int( team ) )
	}
	
	if ( GamePlayingOrSuddenDeath() )
	{
		if ( IsRoundBased() )
		{
			SetGameState( eGameState.WinnerDetermined )
			if ( team != null && team != TEAM_UNASSIGNED )
				ScoreEvent_RoundComplete( expect int( team ) )
		}
		else
		{
			SetGameState( eGameState.WinnerDetermined )
			if ( team != null && team != TEAM_UNASSIGNED )
				ScoreEvent_MatchComplete( expect int( team ) )
			
			array<entity> players = GetPlayerArray()
			int functionref( entity, entity ) compareFunc = GameMode_GetScoreCompareFunc( GAMETYPE )
			if ( compareFunc != null )
			{
				players.sort( compareFunc )
				int playerCount = players.len()
				int currentPlace = 1
				for ( int i = 0; i < 3; i++ )
				{
					if ( i >= playerCount )
						continue
					
					if ( i > 0 && compareFunc( players[i - 1], players[i] ) != 0 )
						currentPlace += 1

					switch( currentPlace ) // Update player persistent stats in here
					{
						case 1:
							UpdatePlayerStat( players[i], "game_stats", "mvp" ) // MVP in the current map played
							UpdatePlayerStat( players[i], "game_stats", "mvp_total" ) // MVP in the overall profile
							UpdatePlayerStat( players[i], "game_stats", "top3OnTeam" )
							break
						case 2:
							UpdatePlayerStat( players[i], "game_stats", "top3OnTeam" )
							break
						case 3:
							UpdatePlayerStat( players[i], "game_stats", "top3OnTeam" )
							break
					}
				}
			}
		}
	}
}

void function SetTimeoutWinnerDecisionFunc( int functionref() callback )
{
	file.timeoutWinnerDecisionFunc = callback
}

void function SetCallback_TryUseProjectileReplay( bool functionref( entity victim, entity attacker, var damageInfo, bool isRoundEnd ) callback )
{
	file.shouldTryUseProjectileReplayCallback = callback
}

void function AddCallback_OnRoundEndCleanup( void functionref() callback )
{
	file.roundEndCleanupCallbacks.append( callback )
}

void function SetShouldUsePickLoadoutScreen( bool shouldUse )
{
	file.usePickLoadoutScreen = shouldUse
}

void function SetShouldSpectateInPickLoadoutScreen( bool shouldSpec )
{
	file.spectateInPickLoadoutScreen = shouldSpec
}

bool function SpectatePlayerDuringPickLoadout()
{
	return ( file.usePickLoadoutScreen && file.spectateInPickLoadoutScreen )
}

void function SetSwitchSidesBased( bool switchSides )
{
	file.switchSidesBased = switchSides
}

void function SetSuddenDeathBased( bool suddenDeathBased )
{
	file.suddenDeathBased = suddenDeathBased
}

void function SetTimerBased( bool timerBased )
{
	file.timerBased = timerBased
}

void function SetShouldUseRoundWinningKillReplay( bool shouldUse )
{
	SetServerVar( "roundWinningKillReplayEnabled", shouldUse )
}

void function SetRoundWinningKillReplayKillClasses( bool pilot, bool titan )
{
	file.roundWinningKillReplayTrackPilotKills = pilot
	file.roundWinningKillReplayTrackTitanKills = titan // player kills in titans should get tracked anyway, might be worth renaming this
}

void function SetRoundWinningKillReplayAttacker( entity attacker, int inflictorEHandle = -1 )
{
	file.roundWinningKillReplayTime = Time()
	file.roundWinningKillReplayHealthFrac = GetHealthFrac( attacker )
	file.roundWinningKillReplayAttacker = attacker
	file.roundWinningKillReplayInflictorEHandle = inflictorEHandle == -1 ? attacker.GetEncodedEHandle() : inflictorEHandle
	file.roundWinningKillReplayTimeOfDeath = Time()
}








/*
 ██████ ██    ██ ███████ ████████  ██████  ███    ███     ███████ ████████  █████  ██████  ████████ 
██      ██    ██ ██         ██    ██    ██ ████  ████     ██         ██    ██   ██ ██   ██    ██    
██      ██    ██ ███████    ██    ██    ██ ██ ████ ██     ███████    ██    ███████ ██████     ██    
██      ██    ██      ██    ██    ██    ██ ██  ██  ██          ██    ██    ██   ██ ██   ██    ██    
 ██████  ██████  ███████    ██     ██████  ██      ██     ███████    ██    ██   ██ ██   ██    ██    
*/

void function GameStateEnter_WaitingForCustomStart()
{
	// unused in release, comments indicate this was supposed to be used for an e3 demo
	// perhaps games in this demo were manually started by an employee? no clue really
}









/*
██     ██  █████  ██ ████████ ██ ███    ██  ██████      ███████  ██████  ██████      ██████  ██       █████  ██    ██ ███████ ██████  ███████ 
██     ██ ██   ██ ██    ██    ██ ████   ██ ██           ██      ██    ██ ██   ██     ██   ██ ██      ██   ██  ██  ██  ██      ██   ██ ██      
██  █  ██ ███████ ██    ██    ██ ██ ██  ██ ██   ███     █████   ██    ██ ██████      ██████  ██      ███████   ████   █████   ██████  ███████ 
██ ███ ██ ██   ██ ██    ██    ██ ██  ██ ██ ██    ██     ██      ██    ██ ██   ██     ██      ██      ██   ██    ██    ██      ██   ██      ██ 
 ███ ███  ██   ██ ██    ██    ██ ██   ████  ██████      ██       ██████  ██   ██     ██      ███████ ██   ██    ██    ███████ ██   ██ ███████ 
*/

void function GameStateEnter_WaitingForPlayers()
{
	thread WaitForPlayers()
}

void function WaitForPlayers()
{
	float endTime = Time() + 30.0
	
	SetServerVar( "connectionTimeout", endTime ) // This makes a clock ticking sound and is used to tell server when to force start the match
	while ( GetPendingClientsCount() != 0 && endTime > Time() || !GetPlayerArray().len() )
		WaitFrame()
	
	// The wait from above works just fine alone, but this one makes fancier in terms of making server truly wait for everyone being fully loaded and ready
	bool allClientsConnected = false
	while ( !allClientsConnected && endTime > Time() )
	{
		array< entity > pendingLoadingClients
		foreach ( player in GetPlayerArray() )
		{
			if ( !player.hasConnected )
				pendingLoadingClients.append( player )
		}
		
		if ( !pendingLoadingClients.len() )
			allClientsConnected = true
		
		WaitFrame()
	}
	
	print( "Finished waiting for players, starting match." )
	
	wait 2
	
	if( IsFFAGame() ) // FFA has no Dropships and logic crash clients if casted into PickLoadout
		SetGameState( eGameState.Prematch )
	else
		SetGameState( eGameState.PickLoadout ) // Even if the game mode don't use it, vanilla still cast this game state to make the dropship jump sound when match starts
}

void function WaitingForPlayers_ClientConnected( entity player )
{
	if ( GetGameState() == eGameState.WaitingForPlayers )
		ScreenFadeToBlackForever( player, 0.0 )
}









/*
██████  ██  ██████ ██   ██     ██       ██████   █████  ██████   ██████  ██    ██ ████████ 
██   ██ ██ ██      ██  ██      ██      ██    ██ ██   ██ ██   ██ ██    ██ ██    ██    ██    
██████  ██ ██      █████       ██      ██    ██ ███████ ██   ██ ██    ██ ██    ██    ██    
██      ██ ██      ██  ██      ██      ██    ██ ██   ██ ██   ██ ██    ██ ██    ██    ██    
██      ██  ██████ ██   ██     ███████  ██████  ██   ██ ██████   ██████   ██████     ██    
*/

void function GameStateEnter_PickLoadout()
{
	thread GameStateEnter_PickLoadout_Threaded()
}

void function GameStateEnter_PickLoadout_Threaded()
{
	float pickloadoutLength = GameMode_GetLoadoutSelectTime()
	pickloadoutLength += GetCurrentPlaylistVarFloat( "pick_loadout_extension", 0 )
	
	SetServerVar( "minPickLoadOutTime", Time() + pickloadoutLength )
	
	// titan selection menu can change minPickLoadOutTime so we need to wait manually until we hit the time
	while ( Time() < GetServerVar( "minPickLoadOutTime" ) )
		WaitFrame()
	
	SetGameState( eGameState.Prematch )
}









/*
██████  ██████  ███████ ███    ███  █████  ████████  ██████ ██   ██ 
██   ██ ██   ██ ██      ████  ████ ██   ██    ██    ██      ██   ██ 
██████  ██████  █████   ██ ████ ██ ███████    ██    ██      ███████ 
██      ██   ██ ██      ██  ██  ██ ██   ██    ██    ██      ██   ██ 
██      ██   ██ ███████ ██      ██ ██   ██    ██     ██████ ██   ██ 
*/

void function GameStateEnter_Prematch()
{	
	int timeLimit = GameMode_GetTimeLimit( GAMETYPE ) * 60
	if ( file.switchSidesBased )
		timeLimit /= 2 // endtime is half of total per side
	
	if ( !GetClassicMPMode() && !ClassicMP_ShouldTryIntroAndEpilogueWithoutClassicMP() )
	{
		SetGameEndTime( timeLimit + ClassicMP_DefaultNoIntro_GetLength() )
		SetRoundEndTime( timeLimit + ClassicMP_DefaultNoIntro_GetLength() )
	}
	else
	{
		SetGameEndTime( timeLimit + ClassicMP_GetIntroLength() )
		SetRoundEndTime( timeLimit + ClassicMP_GetIntroLength() )
	}
}









/*
██████  ██       █████  ██    ██ ██ ███    ██  ██████  
██   ██ ██      ██   ██  ██  ██  ██ ████   ██ ██       
██████  ██      ███████   ████   ██ ██ ██  ██ ██   ███ 
██      ██      ██   ██    ██    ██ ██  ██ ██ ██    ██ 
██      ███████ ██   ██    ██    ██ ██   ████  ██████  
*/

void function GameStateEnter_Playing()
{
	GameRules_MarkGameStatePrematchEnding()
	thread GameStateEnter_Playing_Threaded()
}

void function GameStateEnter_Playing_Threaded()
{
	WaitFrame()
	thread DialoguePlayNormal()

	while ( GetGameState() == eGameState.Playing )
	{
		float endTime
		if ( IsRoundBased() )
			endTime = expect float( GetServerVar( "roundEndTime" ) )
		else
			endTime = expect float( GetServerVar( "gameEndTime" ) )
	
		if ( Time() >= endTime && file.timerBased )
		{
			int winningTeam
			if ( file.timeoutWinnerDecisionFunc != null )
				winningTeam = file.timeoutWinnerDecisionFunc()
			else
				winningTeam = GetWinningTeam()
			
			if ( file.switchSidesBased && !file.hasSwitchedSides && !IsRoundBased() )
				SetGameState( eGameState.SwitchingSides )
			else if ( file.suddenDeathBased && winningTeam == TEAM_UNASSIGNED )
				SetGameState( eGameState.SuddenDeath )
			else
			{
				SetWinner( winningTeam, "#GAMEMODE_TIME_LIMIT_REACHED", "#GAMEMODE_TIME_LIMIT_REACHED" )
				SetServerVar( "replayDisabled", true )
			}
		}
		
		WaitFrame()
	}
}









/*
██     ██ ██ ███    ██ ███    ██ ███████ ██████      ██████  ███████ ████████ ███████ ██████  ███    ███ ██ ███    ██ ███████ ██████  
██     ██ ██ ████   ██ ████   ██ ██      ██   ██     ██   ██ ██         ██    ██      ██   ██ ████  ████ ██ ████   ██ ██      ██   ██ 
██  █  ██ ██ ██ ██  ██ ██ ██  ██ █████   ██████      ██   ██ █████      ██    █████   ██████  ██ ████ ██ ██ ██ ██  ██ █████   ██   ██ 
██ ███ ██ ██ ██  ██ ██ ██  ██ ██ ██      ██   ██     ██   ██ ██         ██    ██      ██   ██ ██  ██  ██ ██ ██  ██ ██ ██      ██   ██ 
 ███ ███  ██ ██   ████ ██   ████ ███████ ██   ██     ██████  ███████    ██    ███████ ██   ██ ██      ██ ██ ██   ████ ███████ ██████  
*/

void function GameStateEnter_WinnerDetermined()
{
	GameRules_MarkGameStateWinnerDetermined()
	thread GameStateEnter_WinnerDetermined_Threaded()
}

void function GameStateEnter_WinnerDetermined_Threaded()
{
	int winningTeam = GetWinningTeam()
		
	DialoguePlayWinnerDetermined()
	
	if ( IsRoundBased() )
		svGlobal.levelEnt.Signal( "RoundEnd" )
	else
		svGlobal.levelEnt.Signal( "GameEnd" )

	foreach ( entity player in GetPlayerArray() )
	{
		int announcementSubstr
		if ( winningTeam != TEAM_UNASSIGNED )
			announcementSubstr = player.GetTeam() == winningTeam ? file.announceRoundWinnerWinningSubstr : file.announceRoundWinnerLosingSubstr
	
		if ( IsRoundBased() )
			Remote_CallFunction_NonReplay( player, "ServerCallback_AnnounceRoundWinner", winningTeam, announcementSubstr, ROUND_WINNING_KILL_REPLAY_SCREEN_FADE_TIME, GameRules_GetTeamScore2( TEAM_MILITIA ), GameRules_GetTeamScore2( TEAM_IMC ) )
		else
			Remote_CallFunction_NonReplay( player, "ServerCallback_AnnounceWinner", winningTeam, announcementSubstr, ROUND_WINNING_KILL_REPLAY_SCREEN_FADE_TIME )
	
		if ( player.GetTeam() == winningTeam )
			UnlockAchievement( player, achievements.MP_WIN )
	}
	
	WaitFrame() // wait a frame so other scripts can setup killreplay stuff
	
	// Finish timers to make HUD not display more
	SetServerVar( "gameEndTime", Time() )
	SetServerVar( "roundEndTime", Time() )
	
	entity replayAttacker = file.roundWinningKillReplayAttacker
	bool doReplay = Replay_IsEnabled() && IsRoundWinningKillReplayEnabled() && IsValid( replayAttacker ) && !ClassicMP_ShouldRunEpilogue()
				 && Time() - file.roundWinningKillReplayTime <= ROUND_WINNING_KILL_REPLAY_LENGTH_OF_REPLAY && winningTeam != TEAM_UNASSIGNED
 	
	if ( doReplay )
	{
		bool killreplayEnabled = !level.nv.replayDisabled
		if ( killreplayEnabled ) // Prevent killcams interrupting
			SetServerVar( "replayDisabled", true )
	
		float replayLength = ROUND_WINNING_KILL_REPLAY_TOTAL_LENGTH
		if ( "respawnTime" in replayAttacker.s && Time() - replayAttacker.s.respawnTime < replayLength )
			replayLength += Time() - expect float ( replayAttacker.s.respawnTime )
		
		SetServerVar( "roundWinningKillReplayEntHealthFrac", file.roundWinningKillReplayHealthFrac )
		
		foreach ( entity player in GetPlayerArray() )
			ScreenFadeToBlackForever( player, 2.0 )
		
		wait 2
		
		foreach ( entity player in GetPlayerArray() )
			thread PlayerWatchesRoundWinningReplay( player, replayLength )
	
		wait replayLength
		foreach ( entity player in GetPlayerArray() )
		{
			ClearPlayerFromReplay( player )
			WaitFrame()
			ScreenFadeToBlackForever( player, 0.0 )
		}
		
		if ( IsRoundBased() && HasSwitchedSides() == 0 )
			CleanUpEntitiesForRoundEnd()
		
		if ( killreplayEnabled )
			SetServerVar( "replayDisabled", false )
	}
	else if ( IsRoundBased() || !ClassicMP_ShouldRunEpilogue() )
	{
		// Observation from vanilla hints that the gamemodes can choose how players will behave once match is over
		foreach ( entity player in GetPlayerArray() )
		{
			if ( level.endOfRoundPlayerState == ENDROUND_FREEZE )
				player.FreezeControlsOnServer()
			else if ( level.endOfRoundPlayerState == ENDROUND_MOVEONLY )
			{
				player.DisableWeapon()
				player.Server_TurnOffhandWeaponsDisabledOn()
			}
		}
		
		wait GAME_WINNER_DETERMINED_WAIT
		
		foreach ( entity player in GetPlayerArray() )
			ScreenFadeToBlackForever( player, ROUND_WINNING_KILL_REPLAY_SCREEN_FADE_TIME )
		
		wait ROUND_WINNING_KILL_REPLAY_SCREEN_FADE_TIME
		if ( IsRoundBased() && HasSwitchedSides() == 0 ) // Repeat check here just for the case match is over and epilogue is disabled, so it doesn't kill players randomly
			CleanUpEntitiesForRoundEnd()
	}
	
	wait CLEAR_PLAYERS_BUFFER // Required to properly restart without players in Titans crashing it in FD
	
	file.roundWinningKillReplayAttacker = null // Clear Replays
	file.roundWinningKillReplayInflictorEHandle = -1
	if ( IsRoundBased() )
	{
		ClearDroppedWeapons()
		int roundsPlayed = GetRoundsPlayed()
		roundsPlayed++
		SetServerVar( "roundsPlayed", roundsPlayed )

		int highestScore = GameRules_GetTeamScore2( winningTeam )
		int roundScoreLimit = GameMode_GetRoundScoreLimit( GAMETYPE )
		
		if ( highestScore >= roundScoreLimit )
		{
			if ( ClassicMP_ShouldRunEpilogue() )
			{
				ClassicMP_SetupEpilogue()
				SetGameState( eGameState.Epilogue )
			}
			else
				SetGameState( eGameState.Postmatch )
		}
		else if ( file.usePickLoadoutScreen && GetCurrentPlaylistVarInt( "pick_loadout_every_round", 1 ) ) //Playlist var needs to be enabled as well
			SetGameState( eGameState.PickLoadout )
		else
			SetGameState( eGameState.Prematch )
	}
	else
	{
		RegisterChallenges_OnMatchEnd()
		if ( ClassicMP_ShouldRunEpilogue() )
		{
			ClassicMP_SetupEpilogue()
			SetGameState( eGameState.Epilogue )
		}
		else
			SetGameState( eGameState.Postmatch )
	}
	
	AllPlayersUnMuteAll()
}

void function PlayerWatchesRoundWinningReplay( entity player, float replayLength )
{
	entity attacker = file.roundWinningKillReplayAttacker
	if ( !IsValidPlayer( player ) || !IsValid( attacker ) )
		return
	
	player.Signal( "KillCamOver" )
	player.SetPredictionEnabled( false ) // Disable prediction to prevent issues with replays, respawning code restores it automatically
	player.ClearReplayDelay()
	player.ClearViewEntity()
	
	player.watchingKillreplayEndTime = Time() + replayLength
	player.SetKillReplayDelay( Time() - replayLength, THIRD_PERSON_KILL_REPLAY_ALWAYS )
	player.SetKillReplayInflictorEHandle( file.roundWinningKillReplayInflictorEHandle )
	player.SetKillReplayVictim( file.roundWinningKillReplayVictim )
	player.SetViewIndex( attacker.GetIndexForEntity() )
	player.SetIsReplayRoundWinning( true )
}

void function ClearPlayerFromReplay( entity player )
{
	if ( !IsValidPlayer( player ) )
		return
	
	player.ClearReplayDelay()
	player.ClearViewEntity()
}









/*
███████ ██     ██ ██ ████████  ██████ ██   ██ ██ ███    ██  ██████      ███████ ██ ██████  ███████ ███████ 
██      ██     ██ ██    ██    ██      ██   ██ ██ ████   ██ ██           ██      ██ ██   ██ ██      ██      
███████ ██  █  ██ ██    ██    ██      ███████ ██ ██ ██  ██ ██   ███     ███████ ██ ██   ██ █████   ███████ 
     ██ ██ ███ ██ ██    ██    ██      ██   ██ ██ ██  ██ ██ ██    ██          ██ ██ ██   ██ ██           ██ 
███████  ███ ███  ██    ██     ██████ ██   ██ ██ ██   ████  ██████      ███████ ██ ██████  ███████ ███████ 
*/

void function GameStateEnter_SwitchingSides()
{
	thread DialogueAnnounceSwitchingSides()
	thread GameStateEnter_SwitchingSides_Threaded()
}

void function GameStateEnter_SwitchingSides_Threaded()
{
	bool killreplayEnabled = !level.nv.replayDisabled
	if ( killreplayEnabled ) // Prevent killcams interrupting
		SetServerVar( "replayDisabled", true )
		
	WaitFrame()
	
	svGlobal.levelEnt.Signal( "RoundEnd" )

	entity replayAttacker = file.roundWinningKillReplayAttacker
	bool doReplay = Replay_IsEnabled() && IsRoundWinningKillReplayEnabled() && IsValid( replayAttacker ) && !IsRoundBased() // for roundbased modes, we've already done the replay
				 && Time() - file.roundWinningKillReplayTime <= ROUND_WINNING_KILL_REPLAY_LENGTH_OF_REPLAY
	
	float replayLength = ROUND_WINNING_KILL_REPLAY_STARTUP_WAIT
	
	foreach ( entity player in GetPlayerArray() )
	{
		player.FreezeControlsOnServer()
		ScreenFadeToBlackForever( player, 2.0 )
	}
	
	if ( doReplay )
	{
		replayLength = ROUND_WINNING_KILL_REPLAY_TOTAL_LENGTH
		if ( "respawnTime" in replayAttacker.s && Time() - replayAttacker.s.respawnTime < replayLength )
			replayLength += Time() - expect float ( replayAttacker.s.respawnTime )
			
		SetServerVar( "roundWinningKillReplayEntHealthFrac", file.roundWinningKillReplayHealthFrac )
		
		wait 2
		
		foreach ( entity player in GetPlayerArray() )
			thread PlayerWatchesRoundWinningReplay( player, replayLength )
	}
	
	wait replayLength
	foreach ( entity player in GetPlayerArray() )
	{
		ClearPlayerFromReplay( player )
		WaitFrame()
		ScreenFadeToBlackForever( player, 0.0 )
	}
	CleanUpEntitiesForRoundEnd()
	wait CLEAR_PLAYERS_BUFFER
	
	ClearDroppedWeapons()
	if ( killreplayEnabled )
		SetServerVar( "replayDisabled", false )
	
	file.hasSwitchedSides = true
	SetServerVar( "switchedSides", 1 )
	file.roundWinningKillReplayAttacker = null // reset this after replay
	file.roundWinningKillReplayInflictorEHandle = -1
	
	if ( file.usePickLoadoutScreen && GetCurrentPlaylistVarInt( "pick_loadout_every_round", 1 ) ) //Playlist var needs to be enabled too
		SetGameState( eGameState.PickLoadout )
	else
		SetGameState( eGameState.Prematch )
}

void function DialogueAnnounceSwitchingSides()
{
	foreach ( entity player in GetPlayerArray() )
		PlayFactionDialogueToPlayer( "mp_halftime", player )

	wait ROUND_WINNING_KILL_REPLAY_DELAY_BETWEEN_ANNOUNCEMENTS

	foreach ( entity player in GetPlayerArray() )
		PlayFactionDialogueToPlayer( "mp_sideSwitching", player )
}









/*
███████ ██    ██ ██████  ██████  ███████ ███    ██     ██████  ███████  █████  ████████ ██   ██ 
██      ██    ██ ██   ██ ██   ██ ██      ████   ██     ██   ██ ██      ██   ██    ██    ██   ██ 
███████ ██    ██ ██   ██ ██   ██ █████   ██ ██  ██     ██   ██ █████   ███████    ██    ███████ 
     ██ ██    ██ ██   ██ ██   ██ ██      ██  ██ ██     ██   ██ ██      ██   ██    ██    ██   ██ 
███████  ██████  ██████  ██████  ███████ ██   ████     ██████  ███████ ██   ██    ██    ██   ██ 
*/

void function GameStateEnter_SuddenDeath()
{
	// disable respawns, suddendeath calling is done on a kill callback
	SetRespawnsEnabled( false )

	// restart the timer for timelimits to show Sudden Death extra time
	float timeLimit = GetCurrentPlaylistVarFloat( "suddendeath_timelimit", 2.0 ) * 60
	SetGameEndTime( timeLimit )
	SetRoundEndTime( timeLimit )

	thread GameStateEnter_SuddenDeath_Threaded()
}

void function GameStateEnter_SuddenDeath_Threaded()
{
	while ( GetGameState() == eGameState.SuddenDeath )
	{
		WaitFrame()

		float endTime
		if ( IsRoundBased() )
			endTime = expect float( GetServerVar( "roundEndTime" ) )
		else
			endTime = expect float( GetServerVar( "gameEndTime" ) )
		
		bool mltElimited = GameTeams_GetNumLivingPlayers( TEAM_MILITIA ) == 0 ? true : false
		bool imcElimited = GameTeams_GetNumLivingPlayers( TEAM_IMC ) == 0 ? true : false
		
		if ( mltElimited && imcElimited )
			SetWinner( null, "#GENERIC_DRAW_ANNOUNCEMENT", "#GENERIC_DRAW_ANNOUNCEMENT" )
		else if ( mltElimited )
			SetWinner( TEAM_IMC, "#GAMEMODE_ENEMY_PILOTS_ELIMINATED", "#GAMEMODE_FRIENDLY_PILOTS_ELIMINATED" )
		else if ( imcElimited )
			SetWinner( TEAM_MILITIA, "#GAMEMODE_ENEMY_PILOTS_ELIMINATED", "#GAMEMODE_FRIENDLY_PILOTS_ELIMINATED" )
	
		if ( Time() >= endTime )
			SetWinner( null, "#GENERIC_DRAW_ANNOUNCEMENT", "#GENERIC_DRAW_ANNOUNCEMENT" )
	}
}









/*
██████   ██████  ███████ ████████ ███    ███  █████  ████████  ██████ ██   ██ 
██   ██ ██    ██ ██         ██    ████  ████ ██   ██    ██    ██      ██   ██ 
██████  ██    ██ ███████    ██    ██ ████ ██ ███████    ██    ██      ███████ 
██      ██    ██      ██    ██    ██  ██  ██ ██   ██    ██    ██      ██   ██ 
██       ██████  ███████    ██    ██      ██ ██   ██    ██     ██████ ██   ██ 
*/

void function GameStateEnter_Postmatch()
{
	SetServerVar( "replayDisabled", true ) //Disable kill replays on this moment just to ensure no camera problems
	foreach ( entity player in GetPlayerArray() )
	{
		player.FreezeControlsOnServer()
		player.SetNoTarget( true ) //Stop AI from targeting this player at this state of the match
		player.SetInvulnerable() //Players could still die to some post-damaging stuff they might release (i.e: Electric Smokes, AI)
		thread ForceFadeToBlack( player )
	}
	
	thread GameStateEnter_Postmatch_Threaded()
}

void function GameStateEnter_Postmatch_Threaded()
{
	wait GAME_POSTMATCH_LENGTH
	
	AllPlayersMuteAll( 2 ) //Vanilla has a fadeout in sound right before it really finishes the match
	
	wait 2.0
	
	GameRules_EndMatch()
}









/*
██   ██ ██ ██      ██           ██████  █████  ██      ██      ██████   █████   ██████ ██   ██ ███████ 
██  ██  ██ ██      ██          ██      ██   ██ ██      ██      ██   ██ ██   ██ ██      ██  ██  ██      
█████   ██ ██      ██          ██      ███████ ██      ██      ██████  ███████ ██      █████   ███████ 
██  ██  ██ ██      ██          ██      ██   ██ ██      ██      ██   ██ ██   ██ ██      ██  ██       ██ 
██   ██ ██ ███████ ███████      ██████ ██   ██ ███████ ███████ ██████  ██   ██  ██████ ██   ██ ███████ 
*/

void function OnPlayerKilled( entity victim, entity attacker, var damageInfo )
{
	if ( !GamePlayingOrSuddenDeath() )
	{
		if ( file.gameWonThisFrame )
		{
			if ( file.hasKillForGameWonThisFrame )
				return
		}
		else
			return
	}
	
	entity inflictor = DamageInfo_GetInflictor( damageInfo )
	bool shouldUseInflictor = IsValid( inflictor ) && ShouldTryUseProjectileReplay( victim, attacker, damageInfo, true )
	if ( victim.IsPlayer() )
	{
		victim.p.numberOfDeaths++
		ShowDeathHint( victim, damageInfo )
	}

	// set round winning killreplay info here if we're tracking pilot kills
	// todo: make this not count environmental deaths like falls, unsure how to prevent this
	if ( file.roundWinningKillReplayTrackPilotKills && victim != attacker && attacker != svGlobal.worldspawn && IsValid( attacker ) )
	{
		if ( file.gameWonThisFrame )
			file.hasKillForGameWonThisFrame = true
		file.roundWinningKillReplayTime = Time()
		file.roundWinningKillReplayVictim = victim
		file.roundWinningKillReplayAttacker = attacker
		file.roundWinningKillReplayInflictorEHandle = ( shouldUseInflictor ? inflictor : attacker ).GetEncodedEHandle()
		file.roundWinningKillReplayMethodOfDeath = DamageInfo_GetDamageSourceIdentifier( damageInfo )
		file.roundWinningKillReplayTimeOfDeath = Time()
		file.roundWinningKillReplayHealthFrac = GetHealthFrac( attacker )
	}

	if ( ( Riff_EliminationMode() == eEliminationMode.Titans || Riff_EliminationMode() == eEliminationMode.PilotsTitans ) && victim.IsTitan() ) // need an extra check for this
		OnTitanKilled( victim, damageInfo )	

	if ( !GamePlayingOrSuddenDeath() )
		return

	// note: pilotstitans is just win if enemy team runs out of either pilots or titans
	if ( IsPilotEliminationBased() )
	{
		if ( !GetPlayerArrayOfTeam_Alive( victim.GetTeam() ).len() )
		{
			// for ffa we need to manually get the last team alive 
			if ( IsFFAGame() )
			{
				array<int> teamsWithLivingPlayers
				foreach ( entity player in GetPlayerArray_Alive() )
				{
					if ( !teamsWithLivingPlayers.contains( player.GetTeam() ) )
						teamsWithLivingPlayers.append( player.GetTeam() )
				}
				
				if ( teamsWithLivingPlayers.len() == 1 )
					SetWinner( teamsWithLivingPlayers[ 0 ], "#GAMEMODE_ENEMY_PILOTS_ELIMINATED", "#GAMEMODE_FRIENDLY_PILOTS_ELIMINATED" )
				else if ( teamsWithLivingPlayers.len() == 0 ) // failsafe: only team was the dead one
					SetWinner( TEAM_UNASSIGNED, "#GAMEMODE_ENEMY_PILOTS_ELIMINATED", "#GAMEMODE_FRIENDLY_PILOTS_ELIMINATED" ) // this is fine in ffa
			}
			else
				SetWinner( GetOtherTeam( victim.GetTeam() ), "#GAMEMODE_ENEMY_PILOTS_ELIMINATED", "#GAMEMODE_FRIENDLY_PILOTS_ELIMINATED" )
		}
	}
	
	array<entity> players = GetPlayerArrayOfTeam( victim.GetTeam() )
	int functionref( entity, entity ) compareFunc = GameMode_GetScoreCompareFunc( GAMETYPE )
	if ( compareFunc != null && players.len() )
	{
		players.sort( compareFunc )
		if ( victim == players[0] && attacker.IsPlayer() && attacker != victim )
			AddPlayerScore( attacker, "KilledMVP" )
	}
}

void function OnTitanKilled( entity victim, var damageInfo )
{
	if ( !GamePlayingOrSuddenDeath() )
	{
		if ( file.gameWonThisFrame )
		{
			if ( file.hasKillForGameWonThisFrame )
				return
		}
		else
			return
	}

	entity inflictor = DamageInfo_GetInflictor( damageInfo )
	bool shouldUseInflictor = IsValid( inflictor ) && ShouldTryUseProjectileReplay( victim, DamageInfo_GetAttacker( damageInfo ), damageInfo, true )

	// set round winning killreplay info here if we're tracking titan kills
	// todo: make this not count environmental deaths like falls, unsure how to prevent this
	entity attacker = DamageInfo_GetAttacker( damageInfo )
	if ( file.roundWinningKillReplayTrackTitanKills && victim != attacker && attacker != svGlobal.worldspawn && IsValid( attacker ) )
	{
		if ( file.gameWonThisFrame )
			file.hasKillForGameWonThisFrame = true
		file.roundWinningKillReplayTime = Time()
		file.roundWinningKillReplayVictim = victim
		file.roundWinningKillReplayAttacker = attacker
		file.roundWinningKillReplayInflictorEHandle = ( shouldUseInflictor ? inflictor : attacker ).GetEncodedEHandle()
		file.roundWinningKillReplayMethodOfDeath = DamageInfo_GetDamageSourceIdentifier( damageInfo )
		file.roundWinningKillReplayTimeOfDeath = Time()
		file.roundWinningKillReplayHealthFrac = GetHealthFrac( attacker )
	}
	
	if ( !GamePlayingOrSuddenDeath() )
		return

	// note: pilotstitans is just win if enemy team runs out of either pilots or titans
	if ( IsTitanEliminationBased() )
	{
		int livingTitans
		foreach ( entity titan in GetTitanArrayOfTeam( victim.GetTeam() ) )
			livingTitans++
	
		if ( livingTitans == 0 )
		{
			// for ffa we need to manually get the last team alive 
			if ( IsFFAGame() )
			{
				array<int> teamsWithLivingTitans
				foreach ( entity titan in GetTitanArray() )
				{
					if ( !teamsWithLivingTitans.contains( titan.GetTeam() ) )
						teamsWithLivingTitans.append( titan.GetTeam() )
				}
				
				if ( teamsWithLivingTitans.len() == 1 )
					SetWinner( teamsWithLivingTitans[ 0 ], "#GAMEMODE_ENEMY_TITANS_DESTROYED", "#GAMEMODE_FRIENDLY_TITANS_DESTROYED" )
				else if ( teamsWithLivingTitans.len() == 0 ) // failsafe: only team was the dead one
					SetWinner( TEAM_UNASSIGNED, "#GAMEMODE_ENEMY_TITANS_DESTROYED", "#GAMEMODE_FRIENDLY_TITANS_DESTROYED" ) // this is fine in ffa
			}
			else
				SetWinner( GetOtherTeam( victim.GetTeam() ), "#GAMEMODE_ENEMY_TITANS_DESTROYED", "#GAMEMODE_FRIENDLY_TITANS_DESTROYED" )
		}
	}
}










/*
████████  ██████   ██████  ██          ███████ ██    ██ ███    ██  ██████ ████████ ██  ██████  ███    ██ ███████ 
   ██    ██    ██ ██    ██ ██          ██      ██    ██ ████   ██ ██         ██    ██ ██    ██ ████   ██ ██      
   ██    ██    ██ ██    ██ ██          █████   ██    ██ ██ ██  ██ ██         ██    ██ ██    ██ ██ ██  ██ ███████ 
   ██    ██    ██ ██    ██ ██          ██      ██    ██ ██  ██ ██ ██         ██    ██ ██    ██ ██  ██ ██      ██ 
   ██     ██████   ██████  ███████     ██       ██████  ██   ████  ██████    ██    ██  ██████  ██   ████ ███████ 
*/

void function ForceFadeToBlack( entity player )
{
	player.EndSignal( "OnDestroy" )
	while ( true )
	{
		WaitFrame()
		ScreenFadeToBlackForever( player, 0.0 )
	}
}

void function CleanUpEntitiesForRoundEnd()
{
	SetPlayerDeathsHidden( true )
	svGlobal.levelEnt.Signal( "CleanUpEntitiesForRoundEnd" ) 
	foreach ( entity player in GetPlayerArray() )
	{
		if ( IsPrivateMatchSpectator( player ) )
			continue
		
		PlayerEarnMeter_Reset( player )
		ClearTitanAvailable( player )
		PROTO_CleanupTrackedProjectiles( player )
		player.SetPlayerNetInt( "batteryCount", 0 ) 
		player.ClearInvulnerable()
		player.SetNoTarget( false )
		player.ClearParent() //Dropship parenting causes observer mode crash
		if ( IsAlive( player ) )
			KillPlayer( player, eDamageSourceId.round_end )
	}
	
	foreach ( entity npc in GetNPCArray() )
	{
		if ( !IsAlive( npc ) )
			continue
		
		if ( npc.e.fd_roundDeployed != -1 || npc.ai.buddhaMode ) // FD uses this var to cleanup stuff placed in current wave restart, buddha is for offline Turrets
			continue
		
		if ( npc.IsTitan() )
		{
			npc.e.forceRagdollDeath = true
			if ( !( "silentDeath" in npc.s ) ) // Ensure no background explosions will be heard from titans dying to round cleanup
				npc.s.silentDeath <- true
		}
		else
			npc.EnableNPCFlag( NPC_NO_WEAPON_DROP )
		
		// Kill rather than destroy, as destroying will cause issues with children which is an issue especially for dropships and titans
		npc.Die( svGlobal.worldspawn, svGlobal.worldspawn, { scriptType = DF_SKIP_DAMAGE_PROT | DF_SKIPS_DOOMED_STATE | DF_GIB, damageSourceId = eDamageSourceId.round_end } )
	}
	
	foreach ( entity battery in GetEntArrayByClass_Expensive( "item_titan_battery" ) )
		battery.Destroy()
	
	foreach ( void functionref() callback in file.roundEndCleanupCallbacks )
		callback()
	
	WaitFrame()
	
	ClearDroppedWeapons()
	SetPlayerDeathsHidden( false )
}

void function DebounceScoreTie( int team )
{
	if ( IsRoundBased() )
	{
		if ( GameRules_GetTeamScore( team ) < GameMode_GetRoundScoreLimit( GAMETYPE ) )
			GameRules_SetTeamScore( team, GameMode_GetRoundScoreLimit( GAMETYPE ) )
					
		if ( GameRules_GetTeamScore2( team ) < GameMode_GetRoundScoreLimit( GAMETYPE ) )
			GameRules_SetTeamScore2( team, GameMode_GetRoundScoreLimit( GAMETYPE ) )
	}
	else
	{
		if ( GameRules_GetTeamScore( team ) < GameMode_GetScoreLimit( GAMETYPE ) )
			GameRules_SetTeamScore( team, GameMode_GetScoreLimit( GAMETYPE ) )
				
		if ( GameRules_GetTeamScore2( team ) < GameMode_GetScoreLimit( GAMETYPE ) )
			GameRules_SetTeamScore2( team, GameMode_GetScoreLimit( GAMETYPE ) )
	}
}

void function UpdateGameWonThisFrameNextFrame()
{
	WaitFrame()
	file.gameWonThisFrame = false
	file.hasKillForGameWonThisFrame = false
}

float function GameState_GetTimeLimitOverride()
{
	return 100
}

bool function IsRoundBasedGameOver()
{
	return false
}

bool function ShouldRunEvac()
{
	return GameMode_GetEvacEnabled( GAMETYPE )
}

void function GiveTitanToPlayer( entity player )
{
	if ( !IsValidPlayer( player ) || IsPrivateMatchSpectator( player ) )
		return
	
	PlayerEarnMeter_SetMode( player, eEarnMeterMode.DEFAULT )
	PlayerEarnMeter_AddEarnedAndOwned( player, 1.0, 1.0 )
}

float function GetTimeLimit_ForGameMode()
{
	string mode = GameRules_GetGameMode()
	string playlistString = "timelimit"
	
	if ( IsRoundBased() )
		playlistString = "roundtimelimit"

	return GetCurrentPlaylistVarFloat( playlistString, 10 )
}

void function DialoguePlayNormal()
{
	svGlobal.levelEnt.EndSignal( "GameStateChanged" )
	
	int totalScore = GameMode_GetScoreLimit( GameRules_GetGameMode() )
	int winningTeam
	int losingTeam
	float diagInterval = 91

	while( GamePlaying() )
	{
		wait diagInterval
		
		if ( GameRules_GetTeamScore( TEAM_MILITIA ) < GameRules_GetTeamScore( TEAM_IMC ) )
		{
			winningTeam = TEAM_IMC
			losingTeam = TEAM_MILITIA
		}
		
		if ( GameRules_GetTeamScore( TEAM_MILITIA ) > GameRules_GetTeamScore( TEAM_IMC ) )
		{
			winningTeam = TEAM_MILITIA
			losingTeam = TEAM_IMC
		}
		
		if ( GameRules_GetTeamScore( winningTeam ) - GameRules_GetTeamScore( losingTeam ) >= totalScore * 0.4 )
		{
			PlayFactionDialogueToTeam( "scoring_winningLarge", winningTeam )
			PlayFactionDialogueToTeam( "scoring_losingLarge", losingTeam )
		}
		
		else if ( GameRules_GetTeamScore( winningTeam ) - GameRules_GetTeamScore( losingTeam ) <= totalScore * 0.2 )
		{
			PlayFactionDialogueToTeam( "scoring_winningClose", winningTeam )
			PlayFactionDialogueToTeam( "scoring_losingClose", losingTeam )
		}
		
		else if ( GameRules_GetTeamScore( winningTeam ) == GameRules_GetTeamScore( losingTeam ) )
		{
			continue
		}
		
		else
		{
			PlayFactionDialogueToTeam( "scoring_winning", winningTeam )
			PlayFactionDialogueToTeam( "scoring_losing", losingTeam )
		}
	}
}

void function DialoguePlayWinnerDetermined()
{
	int totalScore = GameMode_GetScoreLimit( GameRules_GetGameMode() )
	int winningTeam
	int losingTeam

	if ( GameRules_GetTeamScore( TEAM_MILITIA ) < GameRules_GetTeamScore( TEAM_IMC ) )
	{
		winningTeam = TEAM_IMC
		losingTeam = TEAM_MILITIA
	}
	
	if ( GameRules_GetTeamScore( TEAM_MILITIA ) > GameRules_GetTeamScore( TEAM_IMC ) )
	{
		winningTeam = TEAM_MILITIA
		losingTeam = TEAM_IMC
	}
	
	if ( IsRoundBased() )
	{
		if ( GameRules_GetTeamScore( winningTeam ) != GameMode_GetRoundScoreLimit( GAMETYPE ) )
			return
	}
	
	if ( GameRules_GetTeamScore( winningTeam ) - GameRules_GetTeamScore( losingTeam ) >= totalScore * 0.4 )
	{
		PlayFactionDialogueToTeam( "scoring_wonMercy", winningTeam )
		PlayFactionDialogueToTeam( "scoring_lostMercy", losingTeam )
	}
	
	else if ( GameRules_GetTeamScore( winningTeam ) - GameRules_GetTeamScore( losingTeam ) <= totalScore * 0.2 )
	{
		PlayFactionDialogueToTeam( "scoring_wonClose", winningTeam )
		PlayFactionDialogueToTeam( "scoring_lostClose", losingTeam )
	}
	
	else if ( GameRules_GetTeamScore( winningTeam ) == GameRules_GetTeamScore( losingTeam ) )
	{
		PlayFactionDialogueToTeam( "scoring_tied", winningTeam )
		PlayFactionDialogueToTeam( "scoring_tied", losingTeam )
	}
	
	else
	{
		PlayFactionDialogueToTeam( "scoring_won", winningTeam )
		PlayFactionDialogueToTeam( "scoring_lost", losingTeam )
	}
}