untyped

global function GameState_Init_MP
global function SetGameState
global function GameState_EntitiesDidLoad
global function WaittillGameStateOrHigher
global function AddCallback_OnRoundEndCleanup

global function SetTimelimitCompleteFunc
global function SetPlayThreeMinuteMusic
global function SetEpilogueEliminationBased
global function SetSwitchSidesBased
global function SetShouldUseRoundWinningKillReplay
global function SetRoundWinningKillReplayKillClasses
global function SetRoundWinningKillReplayAttacker
global function SetCallback_TryUseProjectileReplay
global function ShouldTryUseProjectileReplay
global function SetWinner
global function AddTeamScore

global function GameState_GetTimeLimitOverride
global function GameState_SetTimeLimitOverride
global function IsRoundBasedGameOver
global function GiveTitanToPlayer
global function CodeCallback_GamerulesThink
global function GetWinnerDeterminedWait
global function WillShowRoundWinningKillReplay
global function ForceEliminationModeWinner
global function ShouldClearPlayersInWinnerDetermined
global function PerfInitLabels
global function GetConnectedPlayers
global function ClearPlayers
global function GetMatchWinnerFromScore
global function RoundScoreLimit_Complete

struct
{
	bool roundWinningKillReplayTrackPilotKills = true
	bool roundWinningKillReplayTrackTitanKills = false

	int gameState = -1

	float roundWinningKillReplayTime
	entity roundWinningKillReplayVictim
	entity roundWinningKillReplayAttacker
	int roundWinningKillReplayInflictorEHandle // this is either the inflictor or the attacker
	int roundWinningKillReplayMethodOfDeath
	float roundWinningKillReplayTimeOfDeath
	float roundWinningKillReplayHealthFrac

	array<void functionref()> roundEndCleanupCallbacks
	bool functionref( entity victim, entity attacker, var damageInfo, bool isRoundEnd ) shouldTryUseProjectileReplayCallback
	bool playingLastMinuteMusic = false
	bool playingThreeMinuteMusic = false
	float timeWithPlayers = -1
	bool endingMatch = false
	float timeLimitOverride = -1
	bool shouldPlayThreeMinuteMusic = false
	bool epilogueEliminationBased = true
} file

/*
 ██████   █████  ███    ███ ███████ ███████ ████████  █████  ████████ ███████ ███████
██       ██   ██ ████  ████ ██      ██         ██    ██   ██    ██    ██      ██
██   ███ ███████ ██ ████ ██ █████   ███████    ██    ███████    ██    █████   ███████
██    ██ ██   ██ ██  ██  ██ ██           ██    ██    ██   ██    ██    ██           ██
 ██████  ██   ██ ██      ██ ███████ ███████    ██    ██   ██    ██    ███████ ███████
*/

void function GameState_Init_MP()
{
	RegisterServerVarChangeCallback( "gameEndTime", GameEndTimeVarChanged )
	RegisterServerVarChangeCallback( "roundEndTime", RoundEndTimeVarChanged )

	AddCallback_OnClientConnected( GameState_OnClientConnected )
	AddCallback_OnPlayerKilled( OnPlayerKilled )
	AddDeathCallback( "npc_titan", OnTitanKilled )
	AddCallback_EntityChangedTeam( "player", OnPlayerChangedTeam )
	PilotBattery_SetMaxCount( GetCurrentPlaylistVarInt( "pilot_battery_inventory_size", 1 ) ) // Game unironically supports players carrying more than one battery

	RegisterSignal( "ClearPlayers" )
}

void function GameEndTimeVarChanged()
{
	if ( GetGameState() <= eGameState.SuddenDeath )
		file.timeLimitOverride = ( ( expect float( GetServerVar( "gameEndTime" ) ) - Time() ) - ( expect float( GetServerVar( "gameStartTime" ) ) - Time() ) ) / 60.0
}

void function RoundEndTimeVarChanged()
{
	if ( GetGameState() <= eGameState.SuddenDeath )
		file.timeLimitOverride =
			( ( expect float( GetServerVar( "roundEndTime" ) ) - Time() ) - ( expect float( GetServerVar( "roundStartTime" ) ) - Time() ) ) / 60.0
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

void function GameState_OnClientConnected( entity player )
{
	if (
		GetGameState() == eGameState.WaitingForPlayers || ( GetGameState() == eGameState.PickLoadout && DoPrematchWarpSound() ) ||
		GetGameState() == eGameState.Postmatch
	)
		ScreenFadeToBlackForever( player, 0.0 )

	if ( !GetClassicMPMode() && GetGameState() == eGameState.Prematch )
	{
		if ( IsPrivateMatchSpectator( player ) )
			return

		if ( ShouldIntroSpawnAsTitan() )
		{
			PutPlayerInObserverMode( player, OBS_MODE_STATIC_LOCKED )

			thread void function() : ( player )
			{
				WaitEndFrame()

				if ( IsValidPlayer( player ) )
					ScreenFadeFromBlack( player, 0.0 )
			}()

			return
		}

		if ( GameTime_TimeLeftSeconds() > 1.0 )
			AddCinematicFlag( player, CE_FLAG_CLASSIC_MP_SPAWNING )

		DecideRespawnPlayer( player )
		HolsterViewModelAndDisableWeapons( player )
		ScreenFadeFromBlack( player, 0.0 )
		DeployViewModelAndEnableWeapons( player )

		player.FreezeControlsOnServer()
	}
}

//  This is to move all NPCs that a player owns from one team to the other during a match
//  Auto-Titans, Turrets, Ticks and Hacked Spectres will all move along together with the player to the new Team
//  Also possibly prevents mods that spawns other types of NPCs that players can own from breaking when switching (i.e Drones, Hacked Reapers)
void function OnPlayerChangedTeam( entity player )
{
	if ( !player.hasConnected ) // Prevents players who just joined to trigger below code, as server always pre setups their teams
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

void function CodeCallback_GamerulesThink()
{
	int gameState = GetGameState()

	if ( gameState != file.gameState )
	{
		string oldPrintVal = file.gameState == -1 ? "-1" : DEV_GetEnumStringFromIndex( "eGameState", file.gameState )
		string newPrintVal = gameState == -1 ? "-1" : DEV_GetEnumStringFromIndex( "eGameState", gameState )

		printt( "GameState changed from", oldPrintVal, "to", newPrintVal )

		file.gameState = gameState
	}

	switch ( gameState )
	{
		case eGameState.WaitingForCustomStart:
			// printt( "STATE: waiting for custom start" )
			GameRulesThink_WaitingForCustomStart()
			break

		case eGameState.WaitingForPlayers:
			// printt( "STATE: waiting for players" )
			GameRulesThink_WaitingForPlayers()
			break

		case eGameState.PickLoadout:
			// printt( "STATE: Pick Loadout" )
			GameRulesThink_PickLoadout()
			break

		case eGameState.Prematch:
			// printt( "STATE: prematch" )
			GameRulesThink_Prematch()
			break

		case eGameState.Playing:
			// printt( "STATE: playing" )
			GameRulesThink_Playing()
			break

		case eGameState.SuddenDeath:
			// printt( "STATE: SuddenDeath" )
			GameRulesThink_SuddenDeath()
			break

		case eGameState.WinnerDetermined:
			// printt( "STATE: WinnerDetermined" )
			GameRulesThink_WinnerDetermined()
			break

		case eGameState.SwitchingSides:
			// printt( "STATE: SwitchingSides" )
			GameRulesThink_SwitchingSides()
			break

		case eGameState.Epilogue:
			// printt( "STATE: Epilogue" )
			GameRulesThink_Epilogue()
			break

		case eGameState.Postmatch:
			// printt( "STATE: post" )
			GameRulesThink_Postmatch()
			break
	}

	UpdateMatchStateToCode()
}

int function GetCodeMatchPhaseForGameState()
{
	int gameState = GetGameState()

	switch ( gameState )
	{
		case eGameState.WaitingForPlayers:
		case eGameState.PickLoadout:
		case eGameState.Prematch:
			return MATCHPHASE_PREMATCH

		case eGameState.Playing:
		case eGameState.SwitchingSides:
			return MATCHPHASE_MATCH

		case eGameState.SuddenDeath:
		case eGameState.WinnerDetermined:
		case eGameState.Epilogue:
		case eGameState.Postmatch:
			return MATCHPHASE_EPILOGUE

		default:
			printt( " ** Warning: GetCodeMatchPhaseForGameState() - Unhandeled eGameState", gameState )
	}

	return MATCHPHASE_UNSPECIFIED
}

void function UpdateMatchStateToCode()
{
	int maxRounds
	int roundsIMC
	int roundsMilitia
	int scoreLimit
	int scoreIMC
	int scoreMilitia

	if ( IsRoundBased() )
	{
		maxRounds = GetRoundScoreLimit_FromPlaylist()
		roundsIMC = GameRules_GetTeamScore2( TEAM_IMC )
		roundsMilitia = GameRules_GetTeamScore2( TEAM_MILITIA )
		scoreLimit = GetRoundScoreLimit_FromPlaylist()
		scoreIMC = GameRules_GetTeamScore2( TEAM_IMC )
		scoreMilitia = GameRules_GetTeamScore2( TEAM_MILITIA )
	}
	else
	{
		maxRounds = 1
		roundsIMC = 0
		roundsMilitia = 0
		scoreLimit = GetScoreLimit_FromPlaylist()
		scoreIMC = GameRules_GetTeamScore( TEAM_IMC )
		scoreMilitia = GameRules_GetTeamScore( TEAM_MILITIA )
	}

	int timeLimit
	int timePassed

	if ( GameRules_TimeLimitEnabled() )
	{
		timeLimit = int( GetTimeLimit_ForGameMode() * 60.0 )
		timePassed = int( GameTime_PlayingTime() )
	}
	else
	{
		timeLimit = 0
		timePassed = int( GameTime_PlayingTime() )
	}

	int phase = GetCodeMatchPhaseForGameState()
	// printt( "NoteMatchState:", phase, maxRounds, roundsIMC, roundsMilitia, timeLimit, timePassed, scoreLimit, scoreIMC, scoreMilitia )
	NoteMatchState( phase, maxRounds, roundsIMC, roundsMilitia, timeLimit, timePassed, scoreLimit, scoreIMC, scoreMilitia )
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
	Assert( newState >= 0 )
	Assert( newState < eGameState._count_ )

	if ( newState == GetGameState() )
		return

	level.nv.gameStateChangeTime = Time()
	level.nv.gameState = newState

	// Epilogue or later?  Don't let ranks be late enabled

	svGlobal.levelEnt.Signal( "GameStateChanged" )

	foreach ( callbackFunc in svGlobal.gameStateEnterCallbacks[ newState ] )
		callbackFunc()

	switch ( newState )
	{
		case eGameState.WaitingForCustomStart:
			GameStateEnter_WaitingForCustomStart()
			break

		case eGameState.WaitingForPlayers:
			GameStateEnter_WaitingForPlayers()
			break

		case eGameState.PickLoadout:
			GameStateEnter_PickLoadout()
			break

		case eGameState.Prematch:
			GameStateEnter_Prematch()
			break

		case eGameState.Playing:
			GameStateEnter_Playing()
			break

		case eGameState.SuddenDeath:
			GameStateEnter_SuddenDeath()
			break

		case eGameState.WinnerDetermined:
			GameStateEnter_WinnerDetermined()
			break

		case eGameState.SwitchingSides:
			GameStateEnter_SwitchingSides()
			break

		case eGameState.Epilogue:
			break

		case eGameState.Postmatch:
			GameStateEnter_Postmatch()
			break
	}
}

void function AddTeamScore( int team, int amount )
{
	if ( GameScore_GetFirstToScoreLimit() )
		return

	if ( !GamePlayingOrSuddenDeath() )
		return

	int scoreLimit = GameMode_GetScoreLimit( GAMETYPE )
	int newScore = GameRules_GetTeamScore( team ) + amount

	if ( newScore > scoreLimit && !GameScore_AllowPointsOverLimit() ) // Don't allow over the limit if not enabled
		newScore = scoreLimit

	GameRules_SetTeamScore( team, newScore )

	if ( newScore == scoreLimit && !GameScore_GetFirstToScoreLimit() )
		level.firstToScoreLimit = team
}

void function SetWinner( int team, string winningReason = "", string losingReason = "" )
{
	if ( !GamePlayingOrSuddenDeath() )
		return

	if ( IsRoundBased() )
	{
		if ( team != TEAM_UNASSIGNED )
		{
			int roundWins = GameRules_GetTeamScore2( team )
			int newRoundWins = roundWins + 1

			GameRules_SetTeamScore2( team, newRoundWins )
			GameRules_SetTeamScore( team, newRoundWins ) // HACK; client scorebars don't know how to display TeamScore2
		}
	}

	if ( ShouldEnterSuddenDeath( team ) )
	{
		SetGameState( eGameState.SuddenDeath )
		return
	}

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

	foreach ( entity player in GetPlayerArray() )
	{
		int announcementSubstr = announceRoundWinnerLosingSubstr

		if ( player.GetTeam() == team )
			announcementSubstr = announceRoundWinnerWinningSubstr

		if ( Flag( "AnnounceWinnerEnabled" ) )
		{
			if ( IsRoundBased() && !HasRoundScoreLimitBeenReached() )
				Remote_CallFunction_NonReplay(
					player,
					"ServerCallback_AnnounceRoundWinner",
					0,
					announcementSubstr,
					GetWinnerDeterminedWait(),
					GameRules_GetTeamScore2( TEAM_MILITIA ),
					GameRules_GetTeamScore2( TEAM_IMC )
				)
			else
				Remote_CallFunction_NonReplay( player, "ServerCallback_AnnounceWinner", 0, announcementSubstr, GetWinnerDeterminedWait() )
		}

		if ( player.GetTeam() == team )
			UnlockAchievement( player, achievements.MP_WIN )
	}

	SetServerVar( "winningTeam", GetWinningTeam() ) // This is to make GetWinningTeam return TEAM_UNASSIGNED for clients so they don't crash due to music logic upon entering WinnerDetermined state
	SetGameState( eGameState.WinnerDetermined )
}

void function SetCallback_TryUseProjectileReplay( bool functionref( entity victim, entity attacker, var damageInfo, bool isRoundEnd ) callback )
{
	file.shouldTryUseProjectileReplayCallback = callback
}

void function AddCallback_OnRoundEndCleanup( void functionref() callback )
{
	file.roundEndCleanupCallbacks.append( callback )
}

void function SetTimelimitCompleteFunc( bool functionref() timeLimitCompleteFunc )
{
	svGlobal.timelimitCompleteFunc = timeLimitCompleteFunc
}

void function SetPlayThreeMinuteMusic( bool value )
{
	file.shouldPlayThreeMinuteMusic = value
}

void function SetEpilogueEliminationBased( bool value )
{
	file.epilogueEliminationBased = value
}

void function SetSwitchSidesBased( bool switchSides )
{
	level.nv.switchedSides = switchSides ? 0 : null
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
	level.nv.gameStartTime = Time() + 980
}

void function GameRulesThink_WaitingForCustomStart()
{
	SetGameState( eGameState.WaitingForPlayers )
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
	level.nv.gameStartTime = Time() + 980
}

void function GameRulesThink_WaitingForPlayers()
{
	if ( !DoneWaitingForPlayers() )
		return

	if ( GetClassicMPMode() && !IsFFAGame() )
		SetGameState( eGameState.PickLoadout )
	else
		SetGameState( eGameState.Prematch )
}

array<entity> function GetConnectedPlayers()
{
	array<entity> players = GetPlayerArray()
	array<entity> guys

	foreach ( entity player in players )
	{
		if ( !IsValidPlayer( player ) )
			continue

		guys.append( player )
	}

	return guys
}

bool function IsAnyPlayerMMDebug()
{
	array<entity> players = GetPlayerArray()

	foreach ( entity player in players )
	{
		if ( player.GetMMDbgFlags() > 0 )
			return true
	}

	return false
}

bool function DoneWaitingForPlayers()
{
	array<entity> connectedPlayers = GetConnectedPlayers()
	int connectedPlayersCount = connectedPlayers.len()

	// wait for one player to connect
	if ( connectedPlayersCount < 1 )
		return false

	// developer 1 skips the remaining script, we can test the rest in developer mode with developer > 1
	if ( GetDeveloperLevel() == 1 || ( IsPrivateMatch() && IsAnyPlayerMMDebug() ) )
		return true

	// start failsafe timer
	if ( !level.doneWaitingForPlayersTimeout )
		level.doneWaitingForPlayersTimeout = Time() + GetCurrentPlaylistVarInt( "waiting_for_players_timeout_seconds", 45 )

	int minPlayers = 0 // GetCurrentPlaylistVarInt( "min_players", 0 )
	int knownPlayersCount = GetConnectingAndConnectedPlayerArray().len() + GetPendingClientsCount()
	float expectedPlayers = max( minPlayers, knownPlayersCount )

	// test that we haven't hit the failsafe timeout
	if ( Time() < level.doneWaitingForPlayersTimeout )
	{
		// wait for minPlayers to connect or a portion of all expectedPlayers, whichever is greater
		float playersDesiredForCountdownStart = max(
			minPlayers,
			( expectedPlayers * GetCurrentPlaylistVarInt( "waiting_for_players_percentage_desired", 70 ) * 0.01 ).tointeger()
		)

		if ( connectedPlayersCount < playersDesiredForCountdownStart )
			return false
	}

	// all expectedPlayers are here, done waiting
	if ( connectedPlayersCount == expectedPlayers )
		return true

	int countdownSeconds = GetCurrentPlaylistVarInt( "waiting_for_players_countdown_seconds", 0 )

	// only wait X more seconds if the playlist var is greater than 0
	if ( countdownSeconds <= 0 )
		return true

	// start X second countdown
	if ( level.nv.connectionTimeout == null || !level.nv.connectionTimeout )
		level.nv.connectionTimeout = Time() + countdownSeconds

	return Time() >= level.nv.connectionTimeout
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
	ClearWeapons()

	level.nv.minPickLoadOutTime = Time() + GameMode_GetLoadoutSelectTime() + GetCurrentPlaylistVarFloat( "pick_loadout_extension", 0 )
}

void function GameRulesThink_PickLoadout()
{
	var loadOutTime = level.nv.minPickLoadOutTime

	if ( loadOutTime == null )
		return

	if ( Time() < loadOutTime )
		return

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
	PerfInitLabels()

	SetPrematchStartTime()

	ClearWeapons()

	level.clearedPlayers = false
	level.lastTimeLeftSeconds = 0
	level.firstTitanfall = false
	file.playingLastMinuteMusic = false
	file.playingThreeMinuteMusic = false
	file.timeWithPlayers = -1
	file.timeLimitOverride = -1

	if ( IsRoundBased() ) // Override with roundtimelimits even if it have switching sides enabled
	{
		level.nv.roundScoreLimitComplete = false

		if ( IsRoundWinningKillReplayEnabled() )
		{
			// Clear here as opposed to at the end of roundwinningkillreplay to not change the time spent in WinnerDetermined state.
			file.roundWinningKillReplayAttacker = null
			file.roundWinningKillReplayInflictorEHandle = -1
		}
	}

	array<entity> players = GetPlayerArray()

	foreach ( entity player in players )
	{
		if ( IsPrivateMatchSpectator( player ) )
			thread ObserverThread( player )
		else
			ClearPlayerEliminated( player )
	}

	if ( !GetClassicMPMode() )
		thread StartGameWithoutClassicMP()
}

void function GameRulesThink_Prematch()
{
	if ( Time() < level.nv.gameStartTime )
		return

	SetGameState( eGameState.Playing )

	level.nv.winningTeam = null

	GameRules_MarkGameStatePrematchEnding()
}

void function SetPrematchStartTime()
{
	if ( GetClassicMPMode() )
	{
		SetServerVar( "roundStartTime", Time() + ClassicMP_GetIntroLength() )
		SetServerVar( "gameStartTime", Time() + ClassicMP_GetIntroLength() )
	}
	else
	{
		SetServerVar( "roundStartTime", Time() + 3.0 )
		SetServerVar( "gameStartTime", Time() + 3.0 )
	}
}

void function StartGameWithoutClassicMP()
{
	bool respawnAsTitan = expect bool( ShouldIntroSpawnAsTitan() )

	if ( respawnAsTitan )
	{
		foreach ( entity player in GetPlayerArray() )
		{
			if ( IsPrivateMatchSpectator( player ) )
				continue

			PutPlayerInObserverMode( player, OBS_MODE_STATIC_LOCKED )

			thread void function() : ( player )
			{
				WaitEndFrame()

				if ( IsValidPlayer( player ) )
					ScreenFadeFromBlack( player, 0.0 )
			}()
		}

		WaittillGameStateOrHigher( eGameState.Playing )
	}

	foreach ( entity player in GetPlayerArray() )
	{
		if ( IsPrivateMatchSpectator( player ) )
			continue

		if ( !respawnAsTitan )
			AddCinematicFlag( player, CE_FLAG_CLASSIC_MP_SPAWNING )

		DecideRespawnPlayer( player )
		HolsterViewModelAndDisableWeapons( player )
		ScreenFadeFromBlack( player, 0.0 )
		DeployViewModelAndEnableWeapons( player )

		player.FreezeControlsOnServer()
	}

	if ( respawnAsTitan )
		return

	wait GameTime_TimeLeftSeconds() - 1.0

	foreach ( entity player in GetPlayerArray() )
		RemoveCinematicFlag( player, CE_FLAG_CLASSIC_MP_SPAWNING )
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
	array<entity> players = GetPlayerArray()

	foreach ( entity player in players )
	{
		if ( !IsPrivateMatchSpectator( player ) )
			player.StopObserverMode()

		player.UnfreezeControlsOnServer()

		UnMuteAll( player )
	}

	if ( IsRoundBased() )
	{
		SetServerVar( "roundStartTime", Time() )

		if ( GetRoundTimeLimit_ForGameMode() > 0.0 )
		{
			float timeLimit = GetRoundTimeLimit_ForGameMode() * 60.0

			if ( timeLimit > 0.0 )
				SetRoundEndTime( timeLimit )
		}
	}
	else
	{
		if ( GetTimeLimit_ForGameMode() > 0.0 )
		{
			float timeLimit = GetTimeLimit_ForGameMode() * 60.0

			if ( timeLimit > 0.0 )
				SetGameEndTime( timeLimit )
			else
				Assert( false, "TimeLimit is enabled but TimeLimitFromPlaylist is 0" )
		}
	}

	if ( Flag( "AnnounceProgressEnabled" ) )
		thread DialoguePlayNormal()
}

void function GameRulesThink_Playing()
{
	if ( CheckForEmptyTeamVictory() )
		return

	if ( EliminationMode_Complete() )
		return

	if ( !IsRoundBased() && ScoreLimit_Complete() )
		return

	if ( TimeLimit_Complete() )
		return

	if ( GetConVarBool( "ns_match_end_if_no_players" ) )
	{
		if ( GetPlayerArray().len() )
		{
			file.timeWithPlayers = Time()
		}
		else if ( file.timeWithPlayers == -1 || file.timeWithPlayers + 15.0 < Time() )
		{
			GameRules_EndMatch()
			return
		}
	}

	UpdateMatchProgress()

	foreach ( callbackFunc in svGlobal.playingThinkFuncTable )
		callbackFunc()
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
	level.nv.gameEndTime += ( GetSuddenDeathTimeLimit_ForGameMode() * 60.0 ).tointeger()

	if ( IsRoundBased() )
		level.nv.roundEndTime += ( GetSuddenDeathTimeLimit_ForGameMode() * 60.0 ).tointeger()

	Riff_ForceSetEliminationMode( eEliminationMode.Pilots )
}

void function GameRulesThink_SuddenDeath()
{
	if ( EliminationMode_Complete() )
		return

	if ( !IsRoundBased() && ScoreLimit_Complete() )
		return

	if ( TimeLimit_Complete() )
		return
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

	svGlobal.levelEnt.Signal( "RoundEnd" )

	if ( IsRoundBased() )
	{
		level.nv.roundsPlayed++
		level.nv.roundEndTime = Time()

		if ( !RoundScoreLimit_Complete() )
		{
			array<entity> players = GetPlayerArray()

			ScoreEvent_RoundComplete( GetWinningTeam() )

			foreach ( entity player in players )
			{
				ScreenFade( player, 0, 0, 0, 255, GetWinnerDeterminedWait() - CLEAR_PLAYERS_BUFFER, 0, FFADE_OUT | FFADE_STAYOUT )
				SetPlayerEliminated( player )
				CheckGameStateForPlayerMovement( player )
			}

			if ( WillShowRoundWinningKillReplay() )
				thread RoundWinningKillReplay()

			return
		}

		level.nv.roundScoreLimitComplete = true
	}

	level.nv.gameEndTime = Time()

	DialoguePlayWinnerDetermined()
	CreateLevelWinnerDeterminedMusicEvent()
	thread ScoreEvent_MatchComplete( GetWinningTeam() )
	RegisterMatchStats_OnMatchComplete()

	level.ui.penalizeDisconnect = false

	if ( WillShowRoundWinningKillReplay() )
	{
		array<entity> players = GetPlayerArray()

		foreach ( entity player in players )
			SetPlayerEliminated( player )

		thread RoundWinningKillReplay()
	}
	else if ( ShouldRunEvac() ) // RoundWinningKillReplay doesn't work with Evac!
	{
		PlayerWinStreak()
		ClassicMP_SetupEpilogue()
		SetGameState( eGameState.Epilogue )
	}

	if ( GetClassicMPMode() )
		svGlobal.levelEnt.Signal( "StratonHornetDogfights" ) // Stop skyshow for classic MP

	CheckForEmptyTeamVictory()
}

void function GameRulesThink_WinnerDetermined()
{
	if ( GameTime_TimeSpentInCurrentState() < GetWinnerDeterminedWait() )
	{
		if ( ShouldClearPlayersInWinnerDetermined() && GameTime_TimeSpentInCurrentState() > GetWinnerDeterminedWait() - CLEAR_PLAYERS_BUFFER && !level.clearedPlayers )
		{
			ClearPlayers()

			level.clearedPlayers = true
		}

		return
	}

	level.clearedPlayers = false

	if ( !IsRoundBased() )
	{
		PlayerWinStreak()
		RegisterChallenges_OnMatchEnd()

		if ( ShouldRunEvac() )
		{
			ClassicMP_SetupEpilogue()
			SetGameState( eGameState.Epilogue )
		}
		else
			SetGameState( eGameState.Postmatch )

		return
	}

	if ( IsRoundBasedGameOver() )
	{
		PlayerWinStreak()
		RegisterChallenges_OnMatchEnd()

		if ( ShouldRunEvac() )
		{
			ClassicMP_SetupEpilogue()
			SetGameState( eGameState.Epilogue )
		}
		else
			SetGameState( eGameState.Postmatch )

		return
	}

	int roundLimit = GetRoundScoreLimit_FromPlaylist()
	float idealMinSwitchSides = roundLimit * 0.5
	float idealMaxSwitchSides = ( ( roundLimit * 2 ) - 1 ) * 0.5
	int idealSwitchSides = int( floor( ( ( idealMinSwitchSides + idealMaxSwitchSides ) * 0.5 ) + 0.49 ) ) // average, round to closest (1.5 rounds to 1.0, 1.6 to 2.0)

	if ( roundLimit > 0 && GetRoundsPlayed() == idealSwitchSides && IsSwitchSidesBased() )
	{
		SetGameState( eGameState.SwitchingSides )
		return
	}

	if ( GetClassicMPMode() && !DoPrematchWarpSound() && GetCurrentPlaylistVarInt( "pick_loadout_every_round", 0 ) )
		SetGameState( eGameState.PickLoadout )
	else
		SetGameState( eGameState.Prematch )
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
	svGlobal.levelEnt.Signal( "RoundEnd" )

	if ( WillShowRoundWinningKillReplay() )
		thread RoundWinningKillReplay()

	if ( !IsRoundBased() )
	{
		level.nv.switchedSides = 1
		level.nv.roundsPlayed = 1
	}
	else
		level.nv.switchedSides = GetRoundsPlayed()

	array<entity> players = GetPlayerArray()

	foreach ( entity player in players )
	{
		player.s.respawnCount = 0

		SetPlayerEliminated( player )
		ScreenFade( player, 0, 0, 0, 255, SWITCHING_SIDES_DELAY - CLEAR_PLAYERS_BUFFER, 0, FFADE_OUT | FFADE_STAYOUT )
		CheckGameStateForPlayerMovement( player )
		UnMuteAll( player )

		// Only mute halftime if we've already shown our kill replay or we aren't going to show it.
		// Handles cases, such as ctf, where the kill replay is shown after the half-time announcement.
		if ( !WillShowRoundWinningKillReplay() )
			MuteHalfTime( player ) // Mute everything except halftime sounds and dialogue
	}

	MoveFrontline( TEAM_IMC )

	thread DialogueAnnounceSwitchingSides()
}

void function GameRulesThink_SwitchingSides()
{
	if ( GameTime_TimeSpentInCurrentState() < GetSwitchingSidesWait() )
	{
		if ( GameTime_TimeSpentInCurrentState() > GetSwitchingSidesWait() - CLEAR_PLAYERS_BUFFER && !level.clearedPlayers )
		{
			ClearPlayers()

			level.clearedPlayers = true
		}

		return
	}

	level.clearedPlayers = false

	AllPlayersUnMuteAll()

	if ( GetClassicMPMode() && !DoPrematchWarpSound() && GetCurrentPlaylistVarInt( "pick_loadout_every_round", 0 ) )
		SetGameState( eGameState.PickLoadout )
	else
		SetGameState( eGameState.Prematch )
}

void function DialogueAnnounceSwitchingSides()
{
	#if FACTION_DIALOGUE_ENABLED
		foreach ( entity player in GetPlayerArray() )
			PlayFactionDialogueToPlayer( "mp_halftime", player )

		wait ROUND_WINNING_KILL_REPLAY_DELAY_BETWEEN_ANNOUNCEMENTS

		foreach ( entity player in GetPlayerArray() )
			PlayFactionDialogueToPlayer( "mp_sideSwitching", player )
	#endif
}

/*
███████ ██████  ██ ██       ██████   ██████  ██    ██ ███████
██      ██   ██ ██ ██      ██    ██ ██       ██    ██ ██
█████   ██████  ██ ██      ██    ██ ██   ███ ██    ██ █████
██      ██      ██ ██      ██    ██ ██    ██ ██    ██ ██
███████ ██      ██ ███████  ██████   ██████   ██████  ███████
*/

void function GameRulesThink_Epilogue()
{
	if ( !file.epilogueEliminationBased )
		return

	float epilogueRespawnTimeLimit = expect float( level.nv.gameEndTime ) + GAME_EPILOGUE_PLAYER_RESPAWN_LEEWAY

	if ( Time() > epilogueRespawnTimeLimit )
	{
		Riff_ForceSetEliminationMode( eEliminationMode.Pilots )

		array<entity> players = GetPlayerArray()

		foreach ( entity player in players )
		{
			// allow players who died before the game ended and may still be watching kill replay a chance to respawn
			if ( !IsAlive( player ) && player.p.postDeathThreadStartTime < epilogueRespawnTimeLimit )
				continue

			if ( !IsPlayerEliminated( player ) )
				SetPlayerEliminated( player )
		}
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
	array<entity> players = GetPlayerArray()

	foreach ( entity player in players )
	{
		ScreenFade( player, 0, 2, 1, 255, 1.0, 0.0, FFADE_OUT | FFADE_STAYOUT )

		player.FreezeControlsOnServer()

		thread DelayedTakeAllWeapons( player )

		player.SetInvulnerable() // Don't let the player get killed when controls are frozen
	}

	float delay = GAME_POSTMATCH_LENGTH - 1.0 - MUTEALLFADEIN

	delaythread( delay ) AllPlayersMuteAll()
}

void function GameRulesThink_Postmatch()
{
	if ( GameTime_TimeSpentInCurrentState() < GAME_POSTMATCH_LENGTH )
		return

	if ( file.endingMatch )
		return

	file.endingMatch = true

	GameRules_EndMatch()
}

void function DelayedTakeAllWeapons( entity player )
{
	player.EndSignal( "Disconnected" )
	player.EndSignal( "OnDeath" )

	wait 1.25

	if ( IsValid( player ) )
		TakeAllWeapons( player )
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
	if ( IsFFAGame() || IsSingleTeamMode() )
		players = GetSortedPlayers( GetScoreboardCompareFunc(), 0 )

	if ( victim == players[ 0 ] && attacker.IsPlayer() && attacker != victim )
		AddPlayerScore( attacker, "KilledMVP" )

	if ( !GamePlayingOrSuddenDeath() )
		return

	if ( IsTitanEliminationBased() && victim.IsTitan() ) // need an extra check for this
	{
		OnTitanKilled( victim, damageInfo )
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
		file.roundWinningKillReplayTime = Time()
		file.roundWinningKillReplayVictim = victim
		file.roundWinningKillReplayAttacker = attacker
		file.roundWinningKillReplayInflictorEHandle = ( shouldUseInflictor ? inflictor : attacker ).GetEncodedEHandle()
		file.roundWinningKillReplayMethodOfDeath = DamageInfo_GetDamageSourceIdentifier( damageInfo )
		file.roundWinningKillReplayTimeOfDeath = Time()
		file.roundWinningKillReplayHealthFrac = GetHealthFrac( attacker )
	}

	CheckEliminationModeWinner()
}

void function OnTitanKilled( entity victim, var damageInfo )
{
	if ( !GamePlayingOrSuddenDeath() || ( victim.IsNPC() && !IsValid( victim.GetBossPlayer() ) ) )
		return

	entity attacker = DamageInfo_GetAttacker( damageInfo )
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

	CheckEliminationModeWinner()
}

/*
████████  ██████   ██████  ██          ███████ ██    ██ ███    ██  ██████ ████████ ██  ██████  ███    ██ ███████
   ██    ██    ██ ██    ██ ██          ██      ██    ██ ████   ██ ██         ██    ██ ██    ██ ████   ██ ██
   ██    ██    ██ ██    ██ ██          █████   ██    ██ ██ ██  ██ ██         ██    ██ ██    ██ ██ ██  ██ ███████
   ██    ██    ██ ██    ██ ██          ██      ██    ██ ██  ██ ██ ██         ██    ██ ██    ██ ██  ██ ██      ██
   ██     ██████   ██████  ███████     ██       ██████  ██   ████  ██████    ██    ██  ██████  ██   ████ ███████
*/

void function ClearPlayers()
{
	svGlobal.levelEnt.Signal( "ClearPlayers" )

	SetPlayerDeathsHidden( true )

	foreach ( entity player in GetPlayerArray() )
	{
		// Depend on SwitchingSides etc to screenfade correctly
		PROTO_CleanupTrackedProjectiles( player )

		player.ClearInvulnerable()
		player.ClearParent()
		player.SetPlayerNetInt( "batteryCount", 0 )

		PlayerEarnMeter_Reset( player )
		ClearTitanAvailable( player )
		SetPlayerEliminated( player )

		player.SetOrigin( Vector( 10000, 10000, 10000 ) )

		if ( IsAlive( player ) )
			player.Die( svGlobal.worldspawn, svGlobal.worldspawn, { damageSourceId = eDamageSourceId.round_end } )

		player.SetPlayerSettingsWithMods( "spectator", [] )
	}

	array<entity> npcs = GetNPCArray()

	foreach ( entity npc in npcs )
	{
		if ( npc.e.fd_roundDeployed != -1 || npc.ai.buddhaMode ) // FD uses this var to cleanup stuff placed in current wave restart, buddha is for offline Turrets
			continue

		if ( npc.IsTitan() && IsValid( npc.GetTitanSoul() ) )
		{
			ClearAndKillChildren( npc.GetTitanSoul(), npcs )

			npc.GetTitanSoul().Destroy()
		}

		ClearAndKillChildren( npc, npcs )

		npc.Destroy()
	}

	foreach ( entity battery in GetEntArrayByClass_Expensive( "item_titan_battery" ) )
		battery.Destroy()

	foreach ( void functionref() callback in file.roundEndCleanupCallbacks )
		callback()

	delaythread( 0.0001 ) SetPlayerDeathsHidden( false )
}

void function ClearAndKillChildren( entity parentEnt, array<entity> excludedEntities )
{
	entity childEnt = parentEnt.FirstMoveChild()
	entity nextChildEnt

	while ( childEnt != null )
	{
		nextChildEnt = childEnt.NextMovePeer()

		childEnt.ClearParent()

		if ( !excludedEntities.contains( childEnt ) )
		{
			if ( childEnt.IsPlayer() )
			{
				if ( IsAlive( childEnt ) )
					childEnt.Die( svGlobal.worldspawn, svGlobal.worldspawn, { damageSourceId = eDamageSourceId.round_end } )
			}
			else
			{
				ClearAndKillChildren( childEnt, excludedEntities )

				childEnt.Destroy()
			}
		}

		childEnt = nextChildEnt
	}
}

float function GameState_GetTimeLimitOverride()
{
	return file.timeLimitOverride
}

void function GameState_SetTimeLimitOverride( float timeLimitOverride )
{
	file.timeLimitOverride = timeLimitOverride
}

bool function IsRoundBasedGameOver()
{
	int defaultWinner = TEAM_UNASSIGNED

	if ( !IsFFAGame() )
	{
		if ( !GetTeamPlayerCount( TEAM_MILITIA ) )
			defaultWinner = TEAM_IMC
		else if ( !GetTeamPlayerCount( TEAM_IMC ) && GetCurrentPlaylistVarInt( "max_teams", 2 ) != 1 )
			defaultWinner = TEAM_MILITIA
	}
	else
	{
		int team = TEAM_UNASSIGNED

		foreach ( entity player in GetPlayerArray() )
		{
			if ( team != TEAM_UNASSIGNED )
			{
				team = TEAM_UNASSIGNED
				break
			}

			team = player.GetTeam()
		}

		defaultWinner = team
	}

	if ( RoundScoreLimit_Complete() || ( defaultWinner != TEAM_UNASSIGNED && GetRoundsPlayed() > 1 ) )
		return true

	return false
}

void function GiveTitanToPlayer( entity player )
{
	if ( IsPrivateMatchSpectator( player ) )
		return

	PlayerEarnMeter_SetMode( player, eEarnMeterMode.DEFAULT )
	PlayerEarnMeter_AddEarnedAndOwned( player, 1.0, 1.0 )
}

void function DialoguePlayNormal()
{
	#if FACTION_DIALOGUE_ENABLED
		svGlobal.levelEnt.EndSignal( "GameStateChanged" )

		int totalScore = GameMode_GetScoreLimit( GameRules_GetGameMode() )
		int winningTeam
		int losingTeam
		float diagInterval = 91

		while ( GamePlaying() )
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
	#endif
}

void function DialoguePlayWinnerDetermined()
{
	#if FACTION_DIALOGUE_ENABLED
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

		if ( IsRoundBased() && GameRules_GetTeamScore( winningTeam ) != GameMode_GetRoundScoreLimit( GAMETYPE ) )
			return

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
	#endif
}

void function PerfInitLabels()
{
	PerfClearAll()

	table Table = expect table( getconsttable().PerfIndexServer )

	foreach ( label, intval in Table )
		PerfInitLabel( intval, string( label ) )

	table sharedTable = expect table( getconsttable().PerfIndexShared )

	foreach ( label, intval in sharedTable )
		PerfInitLabel( intval + SharedPerfIndexStart, string( label ) )
}

bool function EliminationMode_Complete()
{
	if ( !IsEliminationBased() )
		return false

	if ( GameTime_PlayingTime() < ELIM_FIRST_SPAWN_GRACE_PERIOD )
		return false

	if ( IsPilotEliminationBased() )
	{
		array<entity> players = GetPlayerArray()

		foreach ( entity player in players )
			if ( !IsPlayerEliminated( player ) && !player.s.respawnCount )
				SetPlayerEliminated( player )
	}

	return ( CheckEliminationModeWinner() != TEAM_UNASSIGNED )
}

int function CheckEliminationModeWinner()
{
	int isComplete

	switch ( Riff_EliminationMode() )
	{
		case eEliminationMode.Pilots:
			isComplete = CheckEliminationPilotWinner()
			break

		case eEliminationMode.PilotsTitans:
		case eEliminationMode.Titans:
			isComplete = CheckEliminationTitanWinner()
			break
	}

	return isComplete
}

int function ForceEliminationModeWinner()
{
	int isComplete

	switch ( Riff_EliminationMode() )
	{
		case eEliminationMode.Pilots:
			isComplete = CheckEliminationPilotWinner( true )
			break

		case eEliminationMode.PilotsTitans:
		case eEliminationMode.Titans:
			isComplete = CheckEliminationTitanWinner( true )
			break
	}

	return isComplete
}

int function CheckEliminationPilotWinner( bool setWinner = false )
{
	if ( !GameRules_AllowMatchEnd() )
		return TEAM_UNASSIGNED

	array<entity> players = GetPlayerArray()
	table<int, int> teams

	foreach ( entity player in players )
		teams[ player.GetTeam() ] <- 0

	foreach ( entity player in players )
	{
		if ( !IsAlive( player ) )
			continue

		teams[ player.GetTeam() ]++
	}

	int teamsWithPlayers = 0
	int lastTeamWithPlayers = -1
	int teamHighestPlayers = -1
	array<int> teamsWithHighestPlayers = []

	foreach ( int team, int playerCount in teams )
	{
		if ( playerCount )
		{
			teamsWithPlayers++
			lastTeamWithPlayers = team
		}

		if ( playerCount > teamHighestPlayers )
		{
			teamHighestPlayers = playerCount
			teamsWithHighestPlayers = [ team ]
		}
		else if ( playerCount == teamHighestPlayers )
			teamsWithHighestPlayers.append( team )
	}

	int winningTeam
	string winReason
	string lossReason

	if ( teamsWithPlayers == 1 && ( setWinner || !IsSingleTeamMode() ) )
	{
		winReason = "#GAMEMODE_ENEMY_PILOTS_ELIMINATED"
		lossReason = "#GAMEMODE_FRIENDLY_PILOTS_ELIMINATED"
		winningTeam = lastTeamWithPlayers
		setWinner = true
	}
	else if ( !teamsWithPlayers )
	{
		if ( level.nv.attackingTeam && level.nv.attackingTeam != TEAM_UNASSIGNED )
		{
			winReason = "#GAMEMODE_ATTACKERS_WIN"
			lossReason = "#GAMEMODE_ATTACKERS_WIN"
			winningTeam = expect int( level.nv.attackingTeam )
		}
		else
			winningTeam = TEAM_UNASSIGNED

		setWinner = true
	}
	else if ( setWinner )
	{
		if ( teamsWithHighestPlayers.len() == 1 && teamHighestPlayers && ( setWinner || !IsSingleTeamMode() ) )
		{
			winReason = "#GAMEMODE_ENEMY_PILOTS_ELIMINATED"
			lossReason = "#GAMEMODE_FRIENDLY_PILOTS_ELIMINATED"
			winningTeam = teamsWithHighestPlayers[ 0 ]
		}
		else
		{
			if ( level.nv.attackingTeam && level.nv.attackingTeam != TEAM_UNASSIGNED )
			{
				winReason = "#GAMEMODE_ATTACKERS_WIN"
				lossReason = "#GAMEMODE_ATTACKERS_WIN"
				winningTeam = expect int( level.nv.attackingTeam )
			}
			else
				winningTeam = TEAM_UNASSIGNED
		}
	}

	if ( setWinner && level.nv.winningTeam == null )
	{
		SetWinner( winningTeam, winReason, lossReason )
		return winningTeam
	}

	return TEAM_UNASSIGNED
}

int function CheckEliminationTitanWinner( bool setWinner = false )
{
	if ( !GameRules_AllowMatchEnd() )
		return TEAM_UNASSIGNED

	array<entity> players = GetPlayerArray()
	table<int, int> teamPlayers
	table<int, array> teamTitans
	table<int, int> teamTitansAvailable
	table<int, int> teamPlayerTitans
	bool isPilotEliminationBased = IsPilotEliminationBased()

	foreach ( entity player in players )
	{
		int team = player.GetTeam()

		teamPlayers[ team ] <- 0
		teamTitans[ team ] <- []
		teamTitansAvailable[ team ] <- 0
		teamPlayerTitans[ team ] <- 0
	}

	if ( isPilotEliminationBased )
	{
		foreach ( entity player in players )
		{
			if ( !IsValidPlayer( player ) )
				continue

			entity petTitan = player.GetPetTitan()
			int team = player.GetTeam()

			if ( IsAlive( player ) )
				teamPlayers[ team ]++

			if ( IsAlive( petTitan ) && !( "noLongerCountsForLTS" in petTitan.s ) )
			{
				teamTitans[ team ].append( petTitan )
			}
			else if ( ( IsAlive( player ) && player.IsTitan() ) )
			{
				teamTitans[ team ].append( player )
				teamPlayerTitans[ team ]++
			}
			else if ( IsAlive( player ) && IsReplacementTitanAvailable( player ) )
				teamTitansAvailable[ team ]++
		}
	}
	else
	{
		foreach ( entity player in players )
		{
			if ( !IsValidPlayer( player ) )
				continue

			entity petTitan = player.GetPetTitan()
			int team = player.GetTeam()

			teamPlayers[ team ]++

			if ( IsAlive( petTitan ) && !( "noLongerCountsForLTS" in petTitan.s ) )
				teamTitans[ team ].append( petTitan )
			else if ( ( IsAlive( player ) && player.IsTitan() ) )
				teamTitans[ team ].append( player )
			else if ( !IsPlayerEliminated( player ) && IsReplacementTitanAvailable( player ) )
				teamTitansAvailable[ team ]++
		}
	}

	int teamsWithTitans = 0
	int lastTeamWithTitans = -1
	int teamHighestTitans = -1
	array<int> teamsWithHighestTitans = []
	int teamsWithAvailableTitans = 0

	foreach ( int team, array titans in teamTitans )
	{
		int titanCount = titans.len()

		if ( teamTitansAvailable[ team ] )
			teamsWithAvailableTitans++

		if ( titanCount )
		{
			teamsWithTitans++
			lastTeamWithTitans = team
		}

		if ( titanCount > teamHighestTitans )
		{
			teamHighestTitans = titanCount
			teamsWithHighestTitans = [ team ]
		}
		else if ( titanCount == teamHighestTitans )
			teamsWithHighestTitans.append( team )
	}

	int teamsWithPlayers = 0
	int lastTeamWithPlayers = -1
	int teamHighestPlayers = -1
	array<int> teamsWithHighestPlayers = []

	foreach ( int team, int playerCount in teamPlayers )
	{
		if ( playerCount )
		{
			teamsWithPlayers++
			lastTeamWithPlayers = team
		}

		if ( playerCount > teamHighestPlayers )
		{
			teamHighestPlayers = playerCount
			teamsWithHighestPlayers = [ team ]
		}
		else if ( playerCount == teamHighestPlayers )
			teamsWithHighestPlayers.append( team )
	}

	int winningTeam
	string winReason
	string lossReason

	if ( !setWinner && GameTime_PlayingTime() < ELIM_TITAN_SPAWN_GRACE_PERIOD && ( teamsWithTitans > 1 || teamsWithAvailableTitans > 1 ) )
		return TEAM_UNASSIGNED

	if ( teamsWithTitans == 1 && teamHighestTitans && ( setWinner || !IsSingleTeamMode() ) )
	{
		winReason = "#GAMEMODE_ENEMY_TITANS_DESTROYED"
		lossReason = "#GAMEMODE_FRIENDLY_TITANS_DESTROYED"
		winningTeam = lastTeamWithTitans
		setWinner = true
	}
	else if ( !teamsWithTitans )
	{
		if ( isPilotEliminationBased && CheckEliminationPilotWinner() != TEAM_UNASSIGNED )
			return TEAM_UNASSIGNED

		winReason = "#GAMEMODE_NO_TITANS_REMAINING"
		lossReason = "#GAMEMODE_NO_TITANS_REMAINING"
		winningTeam = TEAM_UNASSIGNED
		setWinner = true
	}
	else if ( isPilotEliminationBased && teamsWithPlayers == 1 && ( setWinner || !IsSingleTeamMode() ) )
	{
		winReason = "#GAMEMODE_ENEMY_PILOTS_ELIMINATED"
		lossReason = "#GAMEMODE_FRIENDLY_PILOTS_ELIMINATED"
		winningTeam = lastTeamWithPlayers
		setWinner = true
	}
	else if ( isPilotEliminationBased && !teamsWithPlayers )
	{
		winReason = "#GAMEMODE_ENEMY_PILOTS_ELIMINATED"
		lossReason = "#GAMEMODE_FRIENDLY_PILOTS_ELIMINATED"
		winningTeam = TEAM_UNASSIGNED
		setWinner = true
	}
	else if ( setWinner )
	{
		if ( teamsWithHighestTitans.len() == 1 && teamHighestTitans )
		{
			winReason = "#GAMEMODE_TITAN_TITAN_ADVANTAGE"
			lossReason = "#GAMEMODE_TITAN_TITAN_DISADVANTAGE"
			winningTeam = teamsWithHighestTitans[ 0 ]
		}
		else
		{
			int winnerByHealth = TEAM_UNASSIGNED
			float winnerByHealthHealth = -1.0
			bool winnerByHealthTie = false

			foreach ( int team in teamsWithHighestTitans )
			{
				float healthFrac = 0.0

				foreach ( entity titan in teamTitans[ team ] )
					if ( !GetDoomedState( titan ) )
						healthFrac += GetHealthFrac( titan )

				if ( healthFrac > winnerByHealthHealth )
				{
					winnerByHealthHealth = healthFrac
					winnerByHealth = team
					winnerByHealthTie = false
				}
				else if ( healthFrac == winnerByHealthHealth )
					winnerByHealthTie = true
			}

			if ( !winnerByHealthTie && winnerByHealth != TEAM_UNASSIGNED )
			{
				winReason = "#GAMEMODE_TITAN_DAMAGE_ADVANTAGE"
				lossReason = "#GAMEMODE_TITAN_DAMAGE_DISADVANTAGE"
				winningTeam = winnerByHealth
			}
			else
			{
				winReason = "#GAMEMODE_TIME_LIMIT_REACHED"
				lossReason = "#GAMEMODE_TIME_LIMIT_REACHED"
				winningTeam = TEAM_UNASSIGNED
			}
		}
	}

	if ( setWinner && level.nv.winningTeam == null )
	{
		SetWinner( winningTeam, winReason, lossReason )
		return winningTeam
	}

	return TEAM_UNASSIGNED
}

bool function ScoreLimit_Complete()
{
	if ( !GameRules_AllowMatchEnd() )
		return false

	if ( Flag( "DisableScoreLimit" ) )
		return false

	int scoreLimit = GetScoreLimit_FromPlaylist()
	int militiaScore = GameRules_GetTeamScore( TEAM_MILITIA )
	int imcScore = GameRules_GetTeamScore( TEAM_IMC )

	if ( ( GetGameState() == eGameState.SuddenDeath && militiaScore != imcScore ) || ( ( militiaScore >= scoreLimit ) || ( imcScore >= scoreLimit ) ) )
	{
		int winningTeam = TEAM_UNASSIGNED

		if ( imcScore > militiaScore )
			winningTeam = TEAM_IMC
		else if ( imcScore < militiaScore )
			winningTeam = TEAM_MILITIA

		SetWinner( winningTeam, "#GAMEMODE_SCORE_LIMIT_REACHED", "#GAMEMODE_SCORE_LIMIT_REACHED" )
		return true
	}

	if ( IsSwitchSidesBased() && !HasSwitchedSides() && level.nv.roundsPlayed == ( scoreLimit - 1 ) )
	{
		SetGameState( eGameState.SwitchingSides )
		return true
	}

	return false
}

bool function RoundScoreLimit_Complete()
{
	if ( !GameRules_AllowMatchEnd() )
		return false

	if ( Flag( "DisableScoreLimit" ) )
		return false

	int roundLimit = GetRoundScoreLimit_FromPlaylist()

	// TODO: Reexamine this next game? RoundScoreLimit_Complete shouldn't have side effect of setting winner sometimes
	int militiaScore = GameRules_GetTeamScore2( TEAM_MILITIA )
	int imcScore = GameRules_GetTeamScore2( TEAM_IMC )

	if ( ( militiaScore >= roundLimit ) || ( imcScore >= roundLimit ) || level.nv.roundsPlayed >= ( roundLimit * 2 ) )
	{
		int winningTeam = TEAM_UNASSIGNED

		if ( imcScore > militiaScore )
			winningTeam = TEAM_IMC
		else if ( imcScore < militiaScore )
			winningTeam = TEAM_MILITIA

		if ( level.nv.winningTeam == null )
		{
			if ( winningTeam == TEAM_UNASSIGNED )
				SetWinner( winningTeam, "#GAMEMODE_ROUND_LIMIT_REACHED", "#GAMEMODE_ROUND_LIMIT_REACHED" )
			else
				SetWinner( winningTeam, "#GAMEMODE_SCORE_LIMIT_REACHED", "#GAMEMODE_SCORE_LIMIT_REACHED" )
		}

		return true
	}

	return false
}

bool function TimeLimit_Complete()
{
	// Need to check with code how to set mp_enabletimelimit
	// and mp_timelimit
	if ( !GameRules_TimeLimitEnabled() )
		return false

	if ( !GameRules_AllowMatchEnd() )
		return false

	if ( Flag( "DisableTimeLimit" ) )
		return false

	float timeLimit

	if ( IsRoundBased() )
		timeLimit = GetRoundTimeLimit_ForGameMode() * 60.0
	else
		timeLimit = GetTimeLimit_ForGameMode() * 60.0

	int timeLeftSeconds = GameTime_TimeLeftSeconds()

	if ( timeLeftSeconds < 15 && timeLeftSeconds != level.lastTimeLeftSeconds )
	{
		array<entity> players = GetPlayerArray()

		foreach ( player in players )
		{
			EmitSoundOnEntity( player, "Menu_Match_Countdown" )

			if ( timeLeftSeconds < 5 && timeLeftSeconds >= 0 )
				EmitSoundOnEntityAfterDelay( player, "Menu_Match_Countdown", 0.5 )
		}
	}

	if ( GamePlaying() )
	{
		if ( GetCurrentPlaylistVarInt( "last_minute_music_enabled", 1 ) && timeLeftSeconds <= 60 )
		{
			if ( !file.playingLastMinuteMusic )
			{
				file.playingLastMinuteMusic = true

				foreach ( int team in [ TEAM_IMC, TEAM_MILITIA ] )
					CreateTeamMusicEvent( team, eMusicPieceID.LEVEL_LAST_MINUTE, Time() )

				foreach ( entity player in GetPlayerArray() )
					PlayCurrentTeamMusicEventsOnPlayer( player )
			}
		}
		else if (
			GetCurrentPlaylistVarInt( "three_minute_music_enabled", 1 ) && file.shouldPlayThreeMinuteMusic &&
			( level.nv.matchProgress >= 70 || timeLeftSeconds < ( timeLimit * 0.4 - 60 ) )
		)
		{
			if ( !file.playingThreeMinuteMusic )
			{
				file.playingThreeMinuteMusic = true

				foreach ( int team in [ TEAM_IMC, TEAM_MILITIA ] )
					CreateTeamMusicEvent( team, eMusicPieceID.LEVEL_THREE_MINUTE, Time() )

				foreach ( entity player in GetPlayerArray() )
					PlayCurrentTeamMusicEventsOnPlayer( player )
			}
		}
		else if ( file.playingLastMinuteMusic || file.playingThreeMinuteMusic )
		{
			file.playingLastMinuteMusic = false
			file.playingThreeMinuteMusic = false

			foreach ( int team in [ TEAM_IMC, TEAM_MILITIA ] )
				CreateTeamMusicEvent( team, eMusicPieceID.LEVEL_INTRO, expect float( level.nv.gameStartTime ) )

			StopPlayingMinuteMusicToAll()

			foreach ( entity player in GetPlayerArray() )
				PlayCurrentTeamMusicEventsOnPlayer( player )
		}
	}

	if ( timeLeftSeconds == 30 && timeLeftSeconds != level.lastTimeLeftSeconds )
		foreach ( callbackFunc in svGlobal.thirtySecondsLeftFuncTable )
			callbackFunc()

	if ( IsSwitchSidesBased() && !HasSwitchedSides() && !IsRoundBased() ) // TODO: fix LTS switching sides announcement
	{
		if ( timeLeftSeconds == 30 && timeLeftSeconds != level.lastTimeLeftSeconds )
		{
			PlayConversationToTeam( "SwitchingSidesSoon", TEAM_MILITIA )
			PlayConversationToTeam( "SwitchingSidesSoon", TEAM_IMC )
		}
	}

	level.lastTimeLeftSeconds = timeLeftSeconds

	if ( GameTime_PlayingTime() > timeLimit )
	{
		if ( svGlobal.timelimitCompleteFunc != null )
			return svGlobal.timelimitCompleteFunc()

		if ( IsSwitchSidesBased() && !HasSwitchedSides() && !IsRoundBased() )
		{
			SetGameState( eGameState.SwitchingSides )
			return true
		}
		else if ( IsEliminationBased() && ForceEliminationModeWinner() != TEAM_UNASSIGNED )
			return true

		int winningTeam = GetMatchWinnerFromScore()

		SetWinner( winningTeam, "#GAMEMODE_TIME_LIMIT_REACHED", "#GAMEMODE_TIME_LIMIT_REACHED" )
		return true
	}

	return false
}

bool function ShouldEnterSuddenDeath( int winningTeam )
{
	if ( GetGameState() == eGameState.SuddenDeath )
		return false

	if ( !( winningTeam == TEAM_UNASSIGNED ) )
		return false

	if ( !IsSuddenDeathGameMode() )
		return false

	if ( !GetTeamPlayerCount( TEAM_MILITIA ) || !GetTeamPlayerCount( TEAM_IMC ) )
		return false

	return true
}

bool function ShouldClearPlayersInWinnerDetermined()
{
	if ( !IsRoundBased() )
		return false

	if ( WillShowRoundWinningKillReplay() )
	{
		if ( RoundScoreLimit_Complete() ) // Don't do clear players in final round to avoid a bug with not consuming Titan Burn Cards
			return false
		else
			return true
	}

	if ( !RoundScoreLimit_Complete() )
		return true

	return false
}

float function GetWinnerDeterminedWait()
{
	if ( IsRoundBased() )
	{
		if ( WillShowRoundWinningKillReplay() )
		{
			if ( RoundScoreLimit_Complete() )
				return GAME_WINNER_DETERMINED_FINAL_ROUND_WITH_ROUND_WINNING_KILL_REPLAY_WAIT + CLEAR_PLAYERS_BUFFER
			else
				return GAME_WINNER_DETERMINED_ROUND_WAIT_WITH_ROUND_WINNING_KILL_REPLAY_WAIT + CLEAR_PLAYERS_BUFFER
		}
		else if ( RoundScoreLimit_Complete() )
			return GAME_WINNER_DETERMINED_FINAL_ROUND_WAIT + CLEAR_PLAYERS_BUFFER
		else
			return GAME_WINNER_DETERMINED_ROUND_WAIT + CLEAR_PLAYERS_BUFFER
	}

	if ( WillShowRoundWinningKillReplay() )
		return GAME_WINNER_DETERMINED_FINAL_ROUND_WITH_ROUND_WINNING_KILL_REPLAY_WAIT + CLEAR_PLAYERS_BUFFER

	return GAME_WINNER_DETERMINED_WAIT + CLEAR_PLAYERS_BUFFER
}

bool function WillShowRoundWinningKillReplay()
{
	if ( !IsRoundWinningKillReplayEnabled() )
		return false

	int currentGameState = GetGameState()

	if ( ( currentGameState != eGameState.WinnerDetermined ) && ( currentGameState != eGameState.SwitchingSides ) )
		return false

	if ( file.roundWinningKillReplayAttacker == null ) // Check for null specifically instead of IsValid because players can disconnect and become invalid, and we only want this to be false because we set it to null explicitly. ( Want to tell people that round winning kill replay was cancelled if a player disconnected)
		return false

	if ( IsRoundBased() ) // Note the order of the checks: RoundBasedModes that are also SwitchSidesBased will show in WinnerDetermined.
		return ( currentGameState == eGameState.WinnerDetermined )

	if ( IsSwitchSidesBased() )
		return ( currentGameState == eGameState.SwitchingSides )

	return true
}

void function ClearPlayerFromReplay( entity player )
{
	player.Signal( "KillCamOver" )
	player.ClearReplayDelay()
	player.ClearViewEntity()
}

void function RoundWinningKillReplay() // Only Tested in MFD Pro for now! SHould be minimal work to make sure it works for other game modes too though
{
	OnThreadEnd(
		function() : ()
		{
			foreach ( entity player in GetPlayerArray() )
			{
				ClearPlayerFromReplay( player )
				ScreenFade( player, 0, 0, 1, 255, 1.5, 1.5, FFADE_STAYOUT | FFADE_PURGE | FFADE_NOT_IN_REPLAY )
			}

			level.nv.replayDisabled = false
			level.nv.roundWinningKillReplayPlaying = false
			// ClearRoundWinningKillReplayEntities isn't done here, but instead in prematch instead to not change the time spent in winnerdetermined
		}
	)

	level.nv.roundWinningKillReplayPlaying = true
	level.nv.roundWinningKillReplayEntHealthFrac = file.roundWinningKillReplayHealthFrac
	level.nv.replayDisabled = true

	foreach ( entity player in GetPlayerArray() )
	{
		ClearPlayerFromReplay( player )
		ScreenFade( player, 0, 0, 2, 255, ROUND_WINNING_KILL_REPLAY_SCREEN_FADE_TIME - 1.5, 0.0, FFADE_OUT | FFADE_STAYOUT ) // Don't use the util ScreenFadeToBlack function because we don't want to purge the existing black screen fades that might be called from elsewhere
	}

	wait ROUND_WINNING_KILL_REPLAY_STARTUP_WAIT // Delay before we start kill replay proper

	entity attacker = file.roundWinningKillReplayAttacker

	if ( !IsValid( attacker ) )
	{
		MessageToAll( eEventNotifications.RoundWinningKillReplayCancelled )
		return
	}

	foreach ( entity player in GetPlayerArray() )
	{
		player.StopObserverMode()

		player.Signal( "KillCamOver" )
		player.SetPredictionEnabled( false ) // Disable prediction to prevent issues with replays, respawning code restores it automatically
		player.ClearReplayDelay()
		player.ClearViewEntity()

		player.watchingKillreplayEndTime = Time() + ROUND_WINNING_KILL_REPLAY_LENGTH_OF_REPLAY

		player.SetKillReplayDelay( Time() - ROUND_WINNING_KILL_REPLAY_LENGTH_OF_REPLAY, THIRD_PERSON_KILL_REPLAY_ALWAYS )
		player.SetKillReplayInflictorEHandle( file.roundWinningKillReplayInflictorEHandle )
		player.SetKillReplayVictim( file.roundWinningKillReplayVictim )
		player.SetViewIndex( attacker.GetIndexForEntity() )

		if ( !HasRoundScoreLimitBeenReached() )
			player.SetIsReplayRoundWinning( true )
	}

	wait ROUND_WINNING_KILL_REPLAY_LENGTH_OF_REPLAY

	foreach ( entity player in GetPlayerArray() )
		ScreenFadeToBlackForever( player, 1.0 )

	wait 2.0
}

float function GetSwitchingSidesWait()
{
	float waitTime = SWITCHING_SIDES_DELAY + CLEAR_PLAYERS_BUFFER

	if ( !IsRoundBased() || WillShowRoundWinningKillReplay() )
		waitTime = SWITCHING_SIDES_DELAY + ROUND_WINNING_KILL_REPLAY_TOTAL_LENGTH + CLEAR_PLAYERS_BUFFER

	return waitTime
}

void function UpdateMatchProgress()
{
	if ( !GetCurrentPlaylistVarInt( "enable_match_progress_update", 1 ) )
		return

	float progress_score = GetMatchProgress_Score()
	float progress_time = GetMatchProgress_Time()

	if ( IsSwitchSidesBased() && !IsRoundBased() )
	{
		progress_time *= 0.5

		if ( HasSwitchedSides() )
			progress_time += 50.0
	}

	float progress = max( progress_score, progress_time )
	int progressInt = floor( progress ).tointeger()

	if ( level.nv.matchProgress != progressInt )
	{
		level.nv.matchProgress = progressInt
		// printt( "Match Progress: " + progressInt + "%" )
	}
}

float function GetMatchProgress_Score( int team = TEAM_UNASSIGNED )
{
	// Returns a percent of progress for score 0.0 - 100.0%
	// Uses the team with higher score as returned progress

	int scoreLimit
	int militiaScore
	int imcScore

	if ( IsRoundBased() )
	{
		scoreLimit = GetRoundScoreLimit_FromPlaylist()
		militiaScore = GameRules_GetTeamScore2( TEAM_MILITIA )
		imcScore = GameRules_GetTeamScore2( TEAM_IMC )
	}
	else
	{
		scoreLimit = GetScoreLimit_FromPlaylist()
		militiaScore = GameRules_GetTeamScore( TEAM_MILITIA )
		imcScore = GameRules_GetTeamScore( TEAM_IMC )
	}

	if ( !scoreLimit )
		return 0.0

	float militiaProgress = ( militiaScore.tofloat() / scoreLimit.tofloat() ) * 100.0
	float imcProgress = ( imcScore.tofloat() / scoreLimit.tofloat() ) * 100.0

	if ( team == TEAM_MILITIA )
		return militiaProgress
	else if ( team == TEAM_IMC )
		return imcProgress

	return max( militiaProgress, imcProgress )
}

float function GetMatchProgress_Time()
{
	// Returns a percent of progress for time limit 0.0 - 100.0%

	if ( !GameRules_TimeLimitEnabled() )
		return 0.0

	if ( IsRoundBased() )
		return 0.0

	if ( !GetTimeLimit_ForGameMode() )
		return 0.0

	if ( Flag( "DisableTimeLimit" ) )
		return 0.0

	float timeLimit = GetTimeLimit_ForGameMode() * 60.0

	if ( !timeLimit )
		return 0.0

	if ( IsSwitchSidesBased() && !IsRoundBased() )
		timeLimit *= 0.5

	return ( GameTime_PlayingTime() / timeLimit ) * 100.0
}

int function GetMatchWinnerFromScore()
{
	int bestTeam = TEAM_UNASSIGNED
	int bestScore = 0
	array<int> teams = IsFFAGame() ? [ TEAM_UNASSIGNED ] : [ TEAM_IMC, TEAM_MILITIA ]
	array<entity> players = GetPlayerArray()

	foreach ( entity player in players )
		if ( !teams.contains( player.GetTeam() ) )
			teams.append( player.GetTeam() )

	foreach ( int team in teams )
	{
		int score = IsRoundBased() ? GameRules_GetTeamScore2( team ) : GameRules_GetTeamScore( team )

		if ( score > bestScore )
		{
			bestTeam = team
			bestScore = score
		}
		else if ( ( score == bestScore ) && ( bestTeam != TEAM_UNASSIGNED ) )
		{
			// tie game:
			bestTeam = TEAM_UNASSIGNED
		}
	}

	return bestTeam
}

void function PlayerWinStreak()
{
	foreach ( entity player in GetPlayerArray() )
	{
		if ( GetWinningTeam() != TEAM_UNASSIGNED )
		{
			player.SetPersistentVar( "winStreakIsDraws", false )

			if ( GetWinningTeam() == player.GetTeam() )
			{
				int highestWinStreak = player.GetPersistentVarAsInt( "highestWinStreakEver" )

				if ( highestWinStreak < player.GetPersistentVarAsInt( "winStreak" ) + 1 )
					player.SetPersistentVar( "highestWinStreakEver", player.GetPersistentVarAsInt( "winStreak" ) + 1 )

				player.SetPersistentVar( "lastDailyMatchVictory", Daily_GetCurrentTime() )
				player.SetPersistentVar( "winStreak", player.GetPersistentVarAsInt( "winStreak" ) + 1 )
			}
			else
			{
				int highestWinStreak = player.GetPersistentVarAsInt( "highestWinStreakEver" )

				if ( highestWinStreak < player.GetPersistentVarAsInt( "winStreak" ) )
					player.SetPersistentVar( "highestWinStreakEver", player.GetPersistentVarAsInt( "winStreak" ) )

				player.SetPersistentVar( "winStreak", 0 )
			}
		}
		else
			player.SetPersistentVar( "winStreakIsDraws", true )
	}
}

void function ClearWeapons()
{
	foreach ( entity weapon in GetWeaponArray( true ) )
		weapon.Destroy()
}
