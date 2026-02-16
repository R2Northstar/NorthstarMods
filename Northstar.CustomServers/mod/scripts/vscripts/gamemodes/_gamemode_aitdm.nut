global function GamemodeAITdm_Init

// these are now default settings
const int SQUADS_PER_TEAM = 4
const int SPECTRES_PER_TEAM = 12
const int REAPERS_PER_TEAM = 2

const int LEVEL_SPECTRES = 125
const int LEVEL_STALKERS = 380
const int LEVEL_REAPERS = 500

// add settings
global function AITdm_SetSquadsPerTeam
global function AITdm_SetSpectresPerTeam
global function AITdm_SetReapersPerTeam
global function AITdm_SetLevelSpectres
global function AITdm_SetLevelStalkers
global function AITdm_SetLevelReapers

struct
{
	// Due to team based escalation everything is an array
	array< int > levels = [] // Initilazed in `Spawner_Threaded`
	array< array< string > > podEntities = [ [ "npc_soldier" ], [ "npc_soldier" ] ]
	array< bool > reapers = [ false, false ]

	// default settings
	int squadsPerTeam = SQUADS_PER_TEAM
	int spectresPerTeam = SPECTRES_PER_TEAM
	int reapersPerTeam = REAPERS_PER_TEAM
	int levelSpectres = LEVEL_SPECTRES
	int levelStalkers = LEVEL_STALKERS
	int levelReapers = LEVEL_REAPERS

	table< int, array<entity> > spawnedMinions
	table< int, array<entity> > spawnedSpectres
	table< int, array<entity> > spawnedReapers
} file

void function GamemodeAITdm_Init()
{
	InitializeFrontline()

	AddCallback_GameStateEnter( eGameState.Prematch, OnPrematchStart )
	AddCallback_GameStateEnter( eGameState.Playing, OnPlaying )

	AddCallback_OnNPCKilled( HandleScoreEvent )
	AddCallback_OnPlayerKilled( HandleScoreEvent )

	AddCallback_OnClientConnected( OnPlayerConnected )

	AddCallback_NPCLeeched( OnSpectreLeeched )

	if ( !GetCurrentPlaylistVarInt( "aitdm_archer_grunts", 0 ) )
	{
		AiGameModes_SetNPCWeapons( "npc_soldier", [ "mp_weapon_rspn101", "mp_weapon_dmr", "mp_weapon_vinson", "mp_weapon_hemlok_smg", "mp_weapon_mastiff", "mp_weapon_shotgun_pistol" ] )
		AiGameModes_SetNPCWeapons( "npc_spectre", [ "mp_weapon_g2", "mp_weapon_doubletake", "mp_weapon_hemlok", "mp_weapon_rspn101_og", "mp_weapon_r97" ] )
		AiGameModes_SetNPCWeapons( "npc_stalker", [ "mp_weapon_esaw", "mp_weapon_lstar", "mp_weapon_shotgun", "mp_weapon_lmg", "mp_weapon_smr", "mp_weapon_epg" ] )
	}
	else
	{
		AiGameModes_SetNPCWeapons( "npc_soldier", [ "mp_weapon_rocket_launcher" ] )
		AiGameModes_SetNPCWeapons( "npc_spectre", [ "mp_weapon_rocket_launcher" ] )
		AiGameModes_SetNPCWeapons( "npc_stalker", [ "mp_weapon_rocket_launcher" ] )
	}

	ScoreEvent_SetupEarnMeterValuesForMixedModes()
	SetupGenericTDMChallenge()
	SetAILethality( eAILethality.High )

	level.endOfRoundPlayerState = ENDROUND_FREE
}

// add settings
void function AITdm_SetSquadsPerTeam( int squads )
{
	file.squadsPerTeam = squads
}

void function AITdm_SetSpectresPerTeam( int spectres )
{
	file.spectresPerTeam = spectres
}

void function AITdm_SetReapersPerTeam( int reapers )
{
	file.reapersPerTeam = reapers
}

void function AITdm_SetLevelSpectres( int level )
{
	file.levelSpectres = level
}

void function AITdm_SetLevelStalkers( int level )
{
	file.levelStalkers = level
}

void function AITdm_SetLevelReapers( int level )
{
	file.levelReapers = level
}
//

// Starts skyshow, this also requiers AINs but doesn't crash if they're missing
void function OnPrematchStart()
{
	thread StratonHornetDogfightsIntense()
}

void function OnPlaying()
{
	file.levels = [ file.levelSpectres, file.levelSpectres ]

	// don't run spawning code if ains and nms aren't up to date
	if ( GetAINScriptVersion() == AIN_REV && GetNodeCount() )
	{
		thread SpawnIntroBatch_Threaded( TEAM_MILITIA )
		delaythread ( 0.0001 ) SpawnIntroBatch_Threaded( TEAM_IMC )
	}
}

// Sets up mode specific hud on client
void function OnPlayerConnected( entity player )
{
	Remote_CallFunction_NonReplay( player, "ServerCallback_AITDM_OnPlayerConnected" )
	Remote_CallFunction_UI( player, "SCB_SetEvacMeritState", 0 )
}

// Used to handle both player and ai events
void function HandleScoreEvent( entity victim, entity attacker, var damageInfo )
{
	// Basic checks
	if ( victim == attacker || !( attacker.IsPlayer() || attacker.IsTitan() ) || GetGameState() != eGameState.Playing )
		return

	// Hacked spectre filter
	if ( victim.GetOwner() == attacker )
		return

	// NPC titans without an owner player will not count towards any team's score
	if ( attacker.IsNPC() && attacker.IsTitan() && !IsValid( GetPetTitanOwner( attacker ) ) )
		return

	// Split score so we can check if we are over the score max
	// without showing the wrong value on client
	int teamScore
	int playerScore
	string eventName

	// Handle AI, marvins aren't setup so we check for them to prevent crash
	if ( victim.IsNPC() && victim.GetClassName() != "npc_marvin" )
	{
		switch ( victim.GetClassName() )
		{
			case "npc_soldier":
			case "npc_spectre":
			case "npc_stalker":
				playerScore = 1
				break
			case "npc_super_spectre":
				playerScore = 3
				break
			default:
				playerScore = 0
				break
		}

		// Titan kills get handled bellow this
		if ( eventName != "KillNPCTitan"  && eventName != "" )
			playerScore = ScoreEvent_GetPointValue( GetScoreEvent( eventName ) )
	}

	if ( victim.IsPlayer() )
		playerScore = 5

	// Player ejecting triggers this without the extra check
	if ( victim.IsTitan() && victim.GetBossPlayer() != attacker )
		playerScore += 10

	teamScore = playerScore

	// Check score so we dont go over max
	if ( GameRules_GetTeamScore( attacker.GetTeam()) + teamScore > GetScoreLimit_FromPlaylist() )
		teamScore = GetScoreLimit_FromPlaylist() - GameRules_GetTeamScore( attacker.GetTeam() )

	// Add score + update network int to trigger the "Score +n" popup
	AddTeamScore( attacker.GetTeam(), teamScore )

	attacker.AddToPlayerGameStat( PGS_ASSAULT_SCORE, playerScore )

	int assaultscore = attacker.GetPlayerGameStat( PGS_ASSAULT_SCORE )
	int assaultscore256 = assaultscore / 256

	attacker.SetPlayerNetInt( "AT_bonusPoints", assaultscore - assaultscore256 * 256 )
	attacker.SetPlayerNetInt( "AT_bonusPoints256", assaultscore256 )
}

// When attrition starts both teams spawn ai on preset nodes, after that
// Spawner_Threaded is used to keep the match populated
void function SpawnIntroBatch_Threaded( int team )
{
	array<entity> dropPodNodes = GetEntArrayByClass_Expensive( "info_spawnpoint_droppod_start" )
	array<entity> dropShipNodes = GetValidIntroDropShipSpawn( dropPodNodes )

	array<entity> podNodes
	array<entity> shipNodes

	foreach ( entity node in dropPodNodes )
		if ( node.GetTeam() == team )
			podNodes.append( node )

	foreach ( entity node in dropShipNodes )
		if ( node.GetTeam() == team )
			shipNodes.append( node )

	// Spawn logic
	int podspawnsUsed = podNodes.len()
	int shipspawnsUsed = shipNodes.len()
	entity node

	for ( int i = 0; i < file.squadsPerTeam; i++ )
	{
		if ( podspawnsUsed && ( !shipspawnsUsed || CoinFlip() ) )
		{
			node = GetSpawnPoint( podNodes, team )

			thread AiGameModes_SpawnDropPod( node, team, "npc_soldier", SquadHandler )

			podspawnsUsed--

			wait 0.5
		}
		else if ( shipspawnsUsed )
		{
			node = GetSpawnPoint( shipNodes, team )

			thread AiGameModes_SpawnDropShip( node, team, 4, SquadHandler )

			shipspawnsUsed--

			wait 2.5
		}
		else
			break

		// Vanilla has a delay after first spawn
		if ( !i )
			wait 2
	}

	wait 15

	thread Spawner_Threaded( team )
}

// Populates the match
void function Spawner_Threaded( int team )
{
	// used to index into escalation arrays
	int index = team == TEAM_MILITIA ? 0 : 1

	while ( GamePlaying() || GetWinningTeam() == team )
	{
		Escalate( team )

		if ( !( team in file.spawnedMinions ) )
			file.spawnedMinions[ team ] <- []

		if ( !( team in file.spawnedReapers ) )
			file.spawnedReapers[ team ] <- []

		ArrayRemoveDead( file.spawnedMinions[ team ] )
		ArrayRemoveDead( file.spawnedReapers[ team ] )

		int count = file.spawnedMinions[ team ].len()
		int reaperCount = file.spawnedReapers[ team ].len()

		// REAPERS
		if ( file.reapers[ index ] )
		{
			array< entity > points = SpawnPoints_GetDropPod()

			if ( reaperCount < file.reapersPerTeam )
			{
				entity node = GetSpawnPoint( points, team )

				waitthread AiGameModes_SpawnReaper( node, team, "npc_super_spectre_aitdm", ReaperHandler )
				continue
			}
		}

		// NORMAL SPAWNS
		if ( count < ( ( file.squadsPerTeam - 1 ) * 4 ) )
		{
			array<string> ents

			ents.extend( file.podEntities[ index ] )

			if ( team in file.spawnedSpectres && file.spawnedSpectres[ team ].len() > file.spectresPerTeam - 4 )
				ents.removebyvalue( "npc_spectre" )

			string ent = ents.getrandom()

			array<entity> points = GetZiplineDropshipSpawns()

			if ( ent != "npc_soldier" || !points.len() || ( CoinFlip() && CoinFlip() ) )
			{
				points = SpawnPoints_GetDropPod()

				entity node = GetSpawnPoint( points, team )

				thread AiGameModes_SpawnDropPod( node, team, ent, SquadHandler )

				wait 1.0
			}
			else
			{
				entity node = GetSpawnPoint( points, team )

				thread AiGameModes_SpawnDropShip( node, team, 4, SquadHandler )

				wait 4.0
			}
		}

		WaitFrame()
	}
}

// Based on points tries to balance match
void function Escalate( int team )
{
	int score = GameRules_GetTeamScore( team )
	int index = team == TEAM_MILITIA ? 1 : 0
	// This does the "Enemy x incoming" text
	string defcon = team == TEAM_MILITIA ? "IMCdefcon" : "MILdefcon"

	// Return if the team is under score threshold to escalate
	if ( score < file.levels[ index ] || file.reapers[ index ] )
		return

	// Based on score escalate a team
	switch ( GetGlobalNetInt( defcon ) )
	{
		case 0:
			file.levels[ index ] = file.levelStalkers
			file.podEntities[ index ].append( "npc_spectre" )
			SetGlobalNetInt( defcon, 2 )
			return
		
		case 2:
			file.levels[ index ] = file.levelReapers
			file.podEntities[ index ].append( "npc_stalker" )
			SetGlobalNetInt( defcon, 3 )
			return
		
		case 3:
			file.reapers[ index ] = true
			SetGlobalNetInt( defcon, 4 )
			return
	}

	unreachable // hopefully
}


// Decides where to spawn ai
// Each team has their "zone" where they and their ai spawns
// These zones should swap based on which team is dominating where
entity function GetSpawnPoint( array<entity> points, int team )
{
	entity point = GetFrontlineSpawnPoint( points, team )

	if ( IsValid( point ) )
		return point

	return points.getrandom()
}

// tells infantry where to go
// In vanilla there seem to be preset paths ai follow to get to the other teams vone and capture it
// AI can also flee deeper into their zone suggesting someone spent way too much time on this
void function SquadHandler( array<entity> guys )
{
	foreach ( guy in guys )
	{
		if ( IsValid( guy ) )
		{
			if ( !( guy.GetTeam() in file.spawnedMinions ) )
				file.spawnedMinions[ guy.GetTeam() ] <- []

			file.spawnedMinions[ guy.GetTeam() ].append( guy )

			if ( IsSpectre( guy ) )
			{
				if ( !( guy.GetTeam() in file.spawnedSpectres ) )
					file.spawnedSpectres[ guy.GetTeam() ] <- []

				file.spawnedSpectres[ guy.GetTeam() ].append( guy )

				thread SpectreSpawnedHandler( guy )
			}
		}
	}

	if ( !IsGrunt( guys[0] ) && !IsSpectre( guys[0] ) )
		return

	int team = guys[0].GetTeam()
	// show the squad enemy radar
	array<entity> players = GetPlayerArrayOfEnemies( team )

	foreach ( entity guy in guys )
		if ( IsAlive( guy ) )
			foreach ( player in players )
				guy.Minimap_AlwaysShow( 0, player )

	// Not all maps have assaultpoints / have weird assault points ( looking at you ac )
	// So we use enemies with a large radius

	// our waiting is end, check if any soldiers left
	ArrayRemoveDead( guys )

	if ( !guys.len() )
		return

	// Setup AI, first assault point
	foreach ( guy in guys )
		guy.EnableNPCFlag( NPC_ALLOW_PATROL | NPC_ALLOW_INVESTIGATE | NPC_ALLOW_HAND_SIGNALS | NPC_ALLOW_FLEE )

	SquadAssaultFrontline( guys )

	// Every time frontline moves change AssaultPoint
	while ( true )
	{
		WaitTillFrontlineMoved()

		ArrayRemoveDead( guys )

		if ( !guys.len() )
			return

		foreach ( guy in guys )
			if ( IsSpectre( guy ) && IsValid( guy.GetOwner() ) && IsValid( guy.GetBossPlayer() ) )
				guys.removebyvalue( guy )
			else
				SquadAssaultFrontline( guys )
	}
}

void function SpectreSpawnedHandler( entity spectre )
{
	spectre.EndSignal( "OnDestroy" )
	spectre.EndSignal( "OnDeath" )

	int team = spectre.GetTeam()

	OnThreadEnd
	(
		function() : ( spectre, team )
		{
			if ( !( team in file.spawnedSpectres ) )
				file.spawnedSpectres[ team ] <- []

			file.spawnedSpectres[ team ].removebyvalue( spectre )
		}
	)

	while ( true )
	{
		spectre.WaitSignal( "OnLeeched" )

		if ( !( spectre.GetTeam() in file.spawnedMinions ) )
			file.spawnedMinions[ spectre.GetTeam() ] <- []

		file.spawnedMinions[ spectre.GetTeam() ].removebyvalue( spectre )
	}
}

// Award for hacking
void function OnSpectreLeeched( entity spectre, entity player )
{
	// Set Owner so we can filter in HandleScore
	spectre.SetOwner( player )

	// Add score + update network int to trigger the "Score +n" popup
	AddTeamScore( player.GetTeam(), 1 )

	player.AddToPlayerGameStat( PGS_ASSAULT_SCORE, 1 )

	int assaultscore = player.GetPlayerGameStat( PGS_ASSAULT_SCORE )
	int assaultscore256 = assaultscore / 256

	player.SetPlayerNetInt( "AT_bonusPoints", assaultscore - assaultscore256 * 256 )
	player.SetPlayerNetInt( "AT_bonusPoints256", assaultscore256 )
}

// Same as SquadHandler, just for reapers
void function ReaperHandler( entity reaper )
{
	if ( !( reaper.GetTeam() in file.spawnedReapers ) )
		file.spawnedReapers[ reaper.GetTeam() ] <- []

	file.spawnedReapers[ reaper.GetTeam() ].append( reaper )

	array<entity> players = GetPlayerArrayOfEnemies( reaper.GetTeam() )

	foreach ( player in players )
		reaper.Minimap_AlwaysShow( 0, player )
}