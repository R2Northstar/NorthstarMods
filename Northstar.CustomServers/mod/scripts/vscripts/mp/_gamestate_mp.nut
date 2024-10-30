untyped

global function PIN_GameStart
global function SetGameState
global function GameState_EntitiesDidLoad
global function WaittillGameStateOrHigher
global function AddCallback_OnRoundEndCleanup

global function SetShouldUsePickLoadoutScreen
global function SetShouldSpectateInPickLoadoutScreen
global function SetSwitchSidesBased
global function SetShouldUseRoundWinningKillReplay
global function SetRoundWinningKillReplayKillClasses
global function SetRoundWinningKillReplayAttacker
global function SetCallback_TryUseProjectileReplay
global function ShouldTryUseProjectileReplay
global function SetWinner
global function SetTimeoutWinnerDecisionFunc
global function AddTeamScore

// For more complex logics involving rounds (i.e flag condition in Live-Fire)
global function AddTeamRoundScoreNoStateChange

global function GameState_GetTimeLimitOverride
global function IsRoundBasedGameOver
global function SpectatePlayerDuringPickLoadout
global function ShouldRunEvac
global function GiveTitanToPlayer
global function GetTimeLimit_ForGameMode

struct {
	bool usePickLoadoutScreen
	bool spectateInPickLoadoutScreen = false // This is so joining players stay absent from distracting others with invulnerability given by the Titan Selection Screen
	bool switchSidesBased
	int functionref() timeoutWinnerDecisionFunc
	
	bool hasSwitchedSides
	
	bool roundWinningKillReplayTrackPilotKills = true 
	bool roundWinningKillReplayTrackTitanKills = false
	
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
	PilotBattery_SetMaxCount( GetCurrentPlaylistVarInt( "pilot_battery_inventory_size", 1 ) ) // Game unironically supports players carrying more than one battery
	
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
	AddTeamRoundScoreNoStateChange( team, amount )
	
	int scoreLimit = GameMode_GetScoreLimit( GAMETYPE )
	int score = GameRules_GetTeamScore( team )
	
	if ( IsRoundBased() )
	{
		scoreLimit = GameMode_GetRoundScoreLimit( GAMETYPE )
		score = GameRules_GetTeamScore2( team )
	}

	if ( score >= scoreLimit && ( IsRoundBased() && !HasRoundScoreLimitBeenReached() ) )
		SetWinner( team, "#GAMEMODE_ROUND_LIMIT_REACHED", "#GAMEMODE_ROUND_LIMIT_REACHED" )
	else if ( score >= scoreLimit )
		SetWinner( team, "#GAMEMODE_SCORE_LIMIT_REACHED", "#GAMEMODE_SCORE_LIMIT_REACHED" )
	else if ( GetGameState() == eGameState.SuddenDeath )
		SetWinner( team, "#SUDDEN_DEATH_WIN_ANNOUNCEMENT", "#SUDDEN_DEATH_LOSS_ANNOUNCEMENT" )
	else if ( ( file.switchSidesBased && !file.hasSwitchedSides ) && score >= ( scoreLimit.tofloat() / 2.0 ) )
		SetGameState( eGameState.SwitchingSides )
}

void function AddTeamRoundScoreNoStateChange( int team, int amount = 1 )
{
	int scoreLimit = GameMode_GetScoreLimit( GAMETYPE )
	int score = GameRules_GetTeamScore( team )
	
	if ( IsRoundBased() )
	{
		scoreLimit = GameMode_GetRoundScoreLimit( GAMETYPE )
		score = GameRules_GetTeamScore2( team )
	}

	int newScore = score + amount
	if( newScore > scoreLimit && !GameScore_AllowPointsOverLimit() ) // Don't allow over the limit if not enabled
		newScore = scoreLimit

	GameRules_SetTeamScore( team, newScore )
	GameRules_SetTeamScore2( team, newScore )
}

void function SetWinner( int ornull team, string winningReason = "", string losingReason = "", bool addedTeamScore = true )
{
	if ( !GamePlayingOrSuddenDeath() ) // SetWinner should not be used outside the gamestates that can decide a winner
		return
	
	if ( team != null ) // Team being null means to ServerCallback_AnnounceRoundWinner and ServerCallback_AnnounceWinner to display "DRAW"
		SetServerVar( "winningTeam", team )
	
	int announceRoundWinnerWinningSubstr
	int announceRoundWinnerLosingSubstr
	if ( winningReason == "" )
		announceRoundWinnerWinningSubstr = 0
	else
		announceRoundWinnerWinningSubstr = GetStringID( winningReason )
	
	if ( losingReason == "" )
		announceRoundWinnerLosingSubstr = 0
	else
		announceRoundWinnerLosingSubstr = GetStringID( losingReason )
	
	float endTime
	if ( IsRoundBased() )
		endTime = expect float( GetServerVar( "roundEndTime" ) )
	else
		endTime = expect float( GetServerVar( "gameEndTime" ) )
	
	foreach ( entity player in GetPlayerArray() )
	{
		int announcementSubstr = announceRoundWinnerLosingSubstr

		if( team != null && player.GetTeam() == team )
			announcementSubstr = announceRoundWinnerWinningSubstr
	
		if( Flag( "AnnounceWinnerEnabled" ) )
		{
			if ( IsRoundBased() && !HasRoundScoreLimitBeenReached() )
				Remote_CallFunction_NonReplay( player, "ServerCallback_AnnounceRoundWinner", 0, announcementSubstr, ROUND_WINNING_KILL_REPLAY_SCREEN_FADE_TIME, GameRules_GetTeamScore2( TEAM_MILITIA ), GameRules_GetTeamScore2( TEAM_IMC ) )
			else
				Remote_CallFunction_NonReplay( player, "ServerCallback_AnnounceWinner", 0, announcementSubstr, ROUND_WINNING_KILL_REPLAY_SCREEN_FADE_TIME )
		}

		if( team != null && player.GetTeam() == team )
			UnlockAchievement( player, achievements.MP_WIN )
	}

	if ( !team ) // This is to make GetWinningTeam return TEAM_UNASSIGNED for clients so they don't crash due to music logic upon entering WinnerDetermined state
		SetServerVar( "winningTeam", GetWinningTeam() )
	
	SetGameState( eGameState.WinnerDetermined )
	if ( IsRoundBased() && !HasRoundScoreLimitBeenReached() )
	{
		if ( team != null && team != TEAM_UNASSIGNED )
			ScoreEvent_RoundComplete( expect int( team ) )
	}
	else
	{
		if ( team != null && team != TEAM_UNASSIGNED )
			ScoreEvent_MatchComplete( expect int( team ) )
		
		RegisterMatchStats_OnMatchComplete()
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
	
	if ( IsFFAGame() ) // FFA has no Dropships and logic crash clients if casted into PickLoadout
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
	float pickloadoutLength = GameMode_GetLoadoutSelectTime() // Default is 5 seconds from playlistvar, for the Dropship warp sound
	pickloadoutLength += GetCurrentPlaylistVarFloat( "pick_loadout_extension", 0 ) // Actual addition of time for the Titan Selection Screen
	
	SetServerVar( "minPickLoadOutTime", Time() + pickloadoutLength )
	
	// The Titan Selection Screen can extend the minPickLoadOutTime, so wait for natural expire
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
	
	if ( IsRoundBased() ) // Override with roundtimelimits even if it have switching sides enabled
		timeLimit = int( GameMode_GetRoundTimeLimit( GAMETYPE ) * 60 )
	
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
	if( Flag( "AnnounceProgressEnabled" ) )
		thread DialoguePlayNormal()

	while ( GetGameState() == eGameState.Playing )
	{
		float endTime
		if ( IsRoundBased() )
			endTime = expect float( GetServerVar( "roundEndTime" ) )
		else
			endTime = expect float( GetServerVar( "gameEndTime" ) )
	
		if ( Time() >= endTime && !Flag( "DisableTimeLimit" ) )
		{
			int winningTeam
			if ( file.timeoutWinnerDecisionFunc != null )
				winningTeam = file.timeoutWinnerDecisionFunc()
			else
				winningTeam = GetWinningTeam()
			
			if ( file.switchSidesBased && !file.hasSwitchedSides && !IsRoundBased() )
				SetGameState( eGameState.SwitchingSides )
			else if ( IsSuddenDeathGameMode() && winningTeam == TEAM_UNASSIGNED )
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
	
	if ( IsRoundBased() && !HasRoundScoreLimitBeenReached() )
		svGlobal.levelEnt.Signal( "RoundEnd" )
	else
		svGlobal.levelEnt.Signal( "GameEnd" )
	
	WaitFrame() // wait a frame so other scripts can setup killreplay stuff
	
	// Finish timers to make HUD not display more
	SetServerVar( "gameEndTime", Time() )
	SetServerVar( "roundEndTime", Time() )

	entity replayAttacker = file.roundWinningKillReplayAttacker
	bool doReplay = Replay_IsEnabled() && IsRoundWinningKillReplayEnabled() && IsValid( replayAttacker ) && !ClassicMP_ShouldRunEpilogue()
				 && Time() - file.roundWinningKillReplayTime <= ROUND_WINNING_KILL_REPLAY_LENGTH_OF_REPLAY && winningTeam != TEAM_UNASSIGNED
 	
	SetServerVar( "roundWinningKillReplayPlaying", doReplay )
	if ( doReplay )
	{
		float replayLength = ROUND_WINNING_KILL_REPLAY_TOTAL_LENGTH
		if ( "respawnTime" in replayAttacker.s && Time() - replayAttacker.s.respawnTime < replayLength )
			replayLength += Time() - expect float ( replayAttacker.s.respawnTime )
		
		SetServerVar( "roundWinningKillReplayEntHealthFrac", file.roundWinningKillReplayHealthFrac )
		
		foreach ( entity player in GetPlayerArray() )
		{
			ClearPlayerFromReplay( player ) // If there's a replay already happening, cut it
			CheckGameStateForPlayerMovement( player )
		}
		wait  1.5
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
		
		if ( IsRoundBased() && !HasRoundScoreLimitBeenReached() && HasSwitchedSides() == 0 )
			CleanUpEntitiesForRoundEnd()
		
		SetServerVar( "roundWinningKillReplayPlaying", false )
	}
	else if ( IsRoundBased() && !HasRoundScoreLimitBeenReached() || !ClassicMP_ShouldRunEpilogue() )
	{
		// Observation from vanilla hints that the gamemodes can choose how players will behave once match is over
		foreach ( entity player in GetPlayerArray() )
			CheckGameStateForPlayerMovement( player )
		
		wait GAME_WINNER_DETERMINED_WAIT
		
		foreach ( entity player in GetPlayerArray() )
			ScreenFadeToBlackForever( player, ROUND_WINNING_KILL_REPLAY_SCREEN_FADE_TIME )
		
		wait ROUND_WINNING_KILL_REPLAY_SCREEN_FADE_TIME
		if ( IsRoundBased() && !HasRoundScoreLimitBeenReached() && HasSwitchedSides() == 0 ) // Repeat check here just for the case match is over and epilogue is disabled, so it doesn't kill players randomly
			CleanUpEntitiesForRoundEnd()
	}
	
	wait CLEAR_PLAYERS_BUFFER // Required to properly restart without players in Titans crashing it in FD

	file.roundWinningKillReplayAttacker = null // Clear Replays
	file.roundWinningKillReplayInflictorEHandle = -1
	if ( IsRoundBased() && !HasRoundScoreLimitBeenReached() )
	{
		ClearDroppedWeapons()
		int roundsPlayed = GetRoundsPlayed()
		roundsPlayed++
		SetServerVar( "roundsPlayed", roundsPlayed )

		int highestScore = GameRules_GetTeamScore2( winningTeam )
		int roundScoreLimit = GameMode_GetRoundScoreLimit( GAMETYPE )
		
		if ( highestScore >= roundScoreLimit )
		{
			if ( ShouldRunEvac() )
			{
				ClassicMP_SetupEpilogue()
				SetGameState( eGameState.Epilogue )
			}
			else
			{
				foreach ( entity player in GetPlayerArray() )
					CheckGameStateForPlayerMovement( player )
				
				RegisterChallenges_OnMatchEnd()
				SetGameState( eGameState.Postmatch )
			}
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
		{
			foreach ( entity player in GetPlayerArray() )
				CheckGameStateForPlayerMovement( player )
			
			SetGameState( eGameState.Postmatch )
		}
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

	if( !HasRoundScoreLimitBeenReached() )
		player.SetIsReplayRoundWinning( true )
}

void function ClearPlayerFromReplay( entity player )
{
	if ( !IsValidPlayer( player ) )
		return
	
	player.Signal( "KillCamOver" )
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
	WaitFrame()
	
	svGlobal.levelEnt.Signal( "RoundEnd" )

	entity replayAttacker = file.roundWinningKillReplayAttacker
	bool doReplay = Replay_IsEnabled() && IsRoundWinningKillReplayEnabled() && IsValid( replayAttacker ) && !IsRoundBased() // for roundbased modes, we've already done the replay
				 && Time() - file.roundWinningKillReplayTime <= ROUND_WINNING_KILL_REPLAY_LENGTH_OF_REPLAY
	
	float replayLength = ROUND_WINNING_KILL_REPLAY_STARTUP_WAIT
	SetServerVar( "roundWinningKillReplayPlaying", doReplay )

	foreach ( entity player in GetPlayerArray() )
	{
		ClearPlayerFromReplay( player )
		CheckGameStateForPlayerMovement( player )
	}
	wait  1.5
	foreach ( entity player in GetPlayerArray() )
		ScreenFadeToBlackForever( player, 2.0 )
	
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
	SetServerVar( "roundWinningKillReplayPlaying", false )
	
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
	Riff_ForceSetEliminationMode( eEliminationMode.Pilots )

	// Restart the timer for Timelimits to show Sudden Death extra time (Because it does have it)
	float timeLimit = GetCurrentPlaylistVarFloat( "suddendeath_timelimit", 2.0 )
	bool useSDTimelimit = false
	if( timeLimit > 0 )
	{
		timeLimit *= 60 // Minutes conversion
		SetGameEndTime( timeLimit )
		SetRoundEndTime( timeLimit )
		useSDTimelimit = true
	}
	else if( timeLimit == 0 ) // Allows 0 to make SD fallback into Draw directly (used by Live-Fire)
	{
		SetWinner( null, "#GENERIC_DRAW_ANNOUNCEMENT", "#GENERIC_DRAW_ANNOUNCEMENT" )
		return
	}
	
	// If SD timer playlistvar was set to a negative value, then SD will stay on forever until the tiebreaker is score or elimination
	thread GameStateEnter_SuddenDeath_Threaded( useSDTimelimit )
}

void function GameStateEnter_SuddenDeath_Threaded( bool useTimelimit )
{
	while ( GetGameState() == eGameState.SuddenDeath )
	{
		WaitFrame()

		float endTime
		if ( IsRoundBased() )
			endTime = expect float( GetServerVar( "roundEndTime" ) )
		else
			endTime = expect float( GetServerVar( "gameEndTime" ) )
		
		if( !IsFFAGame() ) // Death callbacks have dedicated logic to handle FFA modes
		{
			bool mltElimited = IsTeamEliminated( TEAM_MILITIA )
			bool imcElimited = IsTeamEliminated( TEAM_IMC )
			
			if ( mltElimited && imcElimited )
				SetWinner( null, "#GENERIC_DRAW_ANNOUNCEMENT", "#GENERIC_DRAW_ANNOUNCEMENT" )
			else if ( mltElimited )
				SetWinner( TEAM_IMC, "#GAMEMODE_ENEMY_PILOTS_ELIMINATED", "#GAMEMODE_FRIENDLY_PILOTS_ELIMINATED" )
			else if ( imcElimited )
				SetWinner( TEAM_MILITIA, "#GAMEMODE_ENEMY_PILOTS_ELIMINATED", "#GAMEMODE_FRIENDLY_PILOTS_ELIMINATED" )
		}

		if ( Time() >= endTime && useTimelimit )
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
	if ( IsEliminationBased() )
		SetPlayerEliminated( victim )
	
	// MVP kills in vanilla is just the top scoring player of a Team
	array<entity> players = GetSortedPlayers( GetScoreboardCompareFunc(), victim.GetTeam() )
	if( IsFFAGame() || IsSingleTeamMode() )
		players = GetSortedPlayers( GetScoreboardCompareFunc(), 0 )
	
	if ( victim == players[0] && attacker.IsPlayer() && attacker != victim )
		AddPlayerScore( attacker, "KilledMVP" )
	
	if ( !GamePlayingOrSuddenDeath() )
		return

	if ( IsTitanEliminationBased() && victim.IsTitan() ) // need an extra check for this
	{
		OnTitanKilled( victim, damageInfo )
		return
	}

	CheckEliminationRiffMode( victim, attacker )

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
		file.roundWinningKillReplayTime = Time()
		file.roundWinningKillReplayVictim = victim
		file.roundWinningKillReplayAttacker = attacker
		file.roundWinningKillReplayInflictorEHandle = ( shouldUseInflictor ? inflictor : attacker ).GetEncodedEHandle()
		file.roundWinningKillReplayMethodOfDeath = DamageInfo_GetDamageSourceIdentifier( damageInfo )
		file.roundWinningKillReplayTimeOfDeath = Time()
		file.roundWinningKillReplayHealthFrac = GetHealthFrac( attacker )
	}
}

void function OnTitanKilled( entity victim, var damageInfo )
{
	if ( !GamePlayingOrSuddenDeath() )
		return

	entity attacker = DamageInfo_GetAttacker( damageInfo )
	CheckEliminationRiffMode( victim, attacker )

	entity inflictor = DamageInfo_GetInflictor( damageInfo )
	bool shouldUseInflictor = IsValid( inflictor ) && ShouldTryUseProjectileReplay( victim, DamageInfo_GetAttacker( damageInfo ), damageInfo, true )

	// set round winning killreplay info here if we're tracking titan kills
	// todo: make this not count environmental deaths like falls, unsure how to prevent this
	if ( file.roundWinningKillReplayTrackTitanKills && victim != attacker && attacker != svGlobal.worldspawn && IsValid( attacker ) )
	{
		file.roundWinningKillReplayTime = Time()
		file.roundWinningKillReplayVictim = victim
		file.roundWinningKillReplayAttacker = attacker
		file.roundWinningKillReplayInflictorEHandle = ( shouldUseInflictor ? inflictor : attacker ).GetEncodedEHandle()
		file.roundWinningKillReplayMethodOfDeath = DamageInfo_GetDamageSourceIdentifier( damageInfo )
		file.roundWinningKillReplayTimeOfDeath = Time()
		file.roundWinningKillReplayHealthFrac = GetHealthFrac( attacker )
	}
}

void function CheckEliminationRiffMode( entity victim, entity attacker )
{
	// note: pilotstitans is just win if enemy team runs out of either pilots or titans
	if ( IsPilotEliminationBased() )
	{
		if ( IsTeamEliminated( victim.GetTeam() ) )
		{
			if ( IsFFAGame() ) // for ffa we need to manually get the last team alive 
			{
				array<int> teamsWithLivingPlayers
				foreach ( entity player in GetPlayerArray_Alive() )
				{
					if ( !teamsWithLivingPlayers.contains( player.GetTeam() ) )
						teamsWithLivingPlayers.append( player.GetTeam() )
				}
				
				if ( teamsWithLivingPlayers.len() == 1 )
				{
					if( IsRoundBased() )
						AddTeamRoundScoreNoStateChange( teamsWithLivingPlayers[0] )
					
					SetWinner( teamsWithLivingPlayers[0], "#GAMEMODE_ENEMY_PILOTS_ELIMINATED", "#GAMEMODE_FRIENDLY_PILOTS_ELIMINATED" )

					if( IsValidPlayer( attacker ) )
						AddPlayerScore( attacker, "VictoryKill", attacker )
				}
				else if ( teamsWithLivingPlayers.len() == 0 ) // failsafe: only team was the dead one
					SetWinner( null, "#GENERIC_DRAW_ANNOUNCEMENT", "#GENERIC_DRAW_ANNOUNCEMENT" ) // this is fine in ffa
			}
			else
			{
				if( IsRoundBased() )
					AddTeamRoundScoreNoStateChange( GetOtherTeam( victim.GetTeam() ) )
				
				SetWinner( GetOtherTeam( victim.GetTeam() ), "#GAMEMODE_ENEMY_PILOTS_ELIMINATED", "#GAMEMODE_FRIENDLY_PILOTS_ELIMINATED" )

				if( IsValidPlayer( attacker ) )
					AddPlayerScore( attacker, "VictoryKill", attacker )
			}
		}
	}

	if ( IsTitanEliminationBased() )
	{
		if ( !GetPlayerTitansOnTeam( victim.GetTeam() ).len() )
		{
			if ( IsFFAGame() )
			{
				array<int> teamsWithLivingTitans
				foreach ( entity titan in GetTitanArray() )
				{
					if ( !teamsWithLivingTitans.contains( titan.GetTeam() ) )
						teamsWithLivingTitans.append( titan.GetTeam() )
				}
				
				if ( teamsWithLivingTitans.len() == 1 )
				{
					if( IsRoundBased() )
						AddTeamRoundScoreNoStateChange( teamsWithLivingTitans[0] )
					
					SetWinner( teamsWithLivingTitans[0], "#GAMEMODE_ENEMY_TITANS_DESTROYED", "#GAMEMODE_FRIENDLY_TITANS_DESTROYED" )

					if( IsValidPlayer( attacker ) )
						AddPlayerScore( attacker, "VictoryKill", attacker )
				}
				else if ( teamsWithLivingTitans.len() == 0 )
					SetWinner( null, "#GENERIC_DRAW_ANNOUNCEMENT", "#GENERIC_DRAW_ANNOUNCEMENT" )
			}
			else
			{
				if( IsRoundBased() )
					AddTeamRoundScoreNoStateChange( GetOtherTeam( victim.GetTeam() ) )
				
				SetWinner( GetOtherTeam( victim.GetTeam() ), "#GAMEMODE_ENEMY_TITANS_DESTROYED", "#GAMEMODE_FRIENDLY_TITANS_DESTROYED" )

				if( IsValidPlayer( attacker ) )
					AddPlayerScore( attacker, "VictoryKill", attacker )
			}
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
	if( !IsFFAGame() )
	{
		int losingTeam = GetOtherTeam( GetWinningTeam() )
		if( IsEliminationBased() && IsTeamEliminated( losingTeam ) )
			return false
	}
	
	return GameMode_GetEvacEnabled( GAMETYPE ) && ClassicMP_ShouldRunEpilogue()
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