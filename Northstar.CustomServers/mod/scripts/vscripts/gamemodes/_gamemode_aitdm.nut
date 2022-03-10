untyped
global function GamemodeAITdm_Init

const SQUADS_PER_TEAM = 3

const REAPERS_PER_TEAM = 2

const LEVEL_SPECTRES = 125
const LEVEL_STALKERS = 380
const LEVEL_REAPERS = 500

struct
{
	// Due to team based escalation everything is an array
	array< int > levels = [ LEVEL_SPECTRES, LEVEL_SPECTRES ]
	array< array< string > > podEntities = [ [ "npc_soldier" ], [ "npc_soldier" ] ]
	array< bool > reapers = [ false, false ]
} file


void function GamemodeAITdm_Init()
{
	AddCallback_GameStateEnter( eGameState.Prematch, OnPrematchStart )
	AddCallback_GameStateEnter( eGameState.Playing, OnPlaying )
	
	AddCallback_OnNPCKilled( HandleScoreEvent )
	AddCallback_OnPlayerKilled( HandleScoreEvent )
		
	AddCallback_OnClientConnected( OnPlayerConnected )
	
	SetGruntWeapons( [ "mp_weapon_rspn101", "mp_weapon_dmr", "mp_weapon_r97", "mp_weapon_lmg" ] )
	SetSpectreWeapons( [ "mp_weapon_hemlok_smg", "mp_weapon_doubletake", "mp_weapon_mastiff" ] )
	
	ScoreEvent_SetupEarnMeterValuesForMixedModes()
}

//------------------------------------------------------

void function OnPrematchStart()
{
	thread StratonHornetDogfightsIntense()
}

void function OnPlaying()
{
	thread SpawnIntroBatch( TEAM_MILITIA )
	thread SpawnIntroBatch( TEAM_IMC )
}

void function OnPlayerConnected( entity player )
{
	Remote_CallFunction_NonReplay( player, "ServerCallback_AITDM_OnPlayerConnected" )
}

//------------------------------------------------------

void function HandleScoreEvent( entity victim, entity attacker, var damageInfo )
{
	if ( !( victim != attacker && attacker.IsPlayer() || attacker.IsTitan() && GetGameState() == eGameState.Playing ) )
		return
	
	int score
	string eventName
	
	if ( victim.IsNPC() && victim.GetClassName() != "npc_marvin" )
	{
		eventName = ScoreEventForNPCKilled( victim, damageInfo )
		if ( eventName != "KillNPCTitan"  && eventName != "" )
			score = ScoreEvent_GetPointValue( GetScoreEvent( eventName ) )
	}
	
	if ( victim.IsPlayer() )
		score = 5
	
	// Player ejecting triggers this without the extra check
	if ( victim.IsTitan() && victim.GetBossPlayer() != attacker )
		score += 10
	
	AddTeamScore( attacker.GetTeam(), score )
	attacker.AddToPlayerGameStat( PGS_ASSAULT_SCORE, score )
	attacker.SetPlayerNetInt("AT_bonusPoints", attacker.GetPlayerGameStat( PGS_ASSAULT_SCORE ) )
}

//------------------------------------------------------

void function SpawnIntroBatch( int team )
{
	array<entity> dropPodNodes = GetEntArrayByClass_Expensive( "info_spawnpoint_droppod_start" )
	array<entity> dropShipNodes = GetValidIntroDropShipSpawn( dropPodNodes )  
	
	array<entity> podNodes
	
	array<entity> shipNodes
	
	// Sort per team
	foreach ( node in dropPodNodes )
	{
		if ( node.GetTeam() == team )
			podNodes.append( node )
	}
	
	// Spawn logic
	int startIndex = 0
	bool first = true
	entity node
	
	int pods = RandomInt( podNodes.len() + 1 )
	
	int ships = shipNodes.len()
	
	for ( int i = 0; i < SQUADS_PER_TEAM; i++ )
	{
		if ( pods != 0 || ships == 0 )
		{
			int index = i
			
			if ( index > podNodes.len() - 1 )
			index = RandomInt( podNodes.len() )
			
			node = podNodes[ index ]
			thread SpawnDropPod( node.GetOrigin(), node.GetAngles(), team, "npc_soldier", SquadHandler )
			
			pods--
		}
		else
		{
			if ( startIndex == 0 ) 
			startIndex = i // save where we started
			
			node = shipNodes[ i - startIndex ]
			thread SpawnDropShip( node.GetOrigin(), node.GetAngles(), team, 4, SquadHandler )
			
			ships--
		}
		
		// Vanilla has a delay after first spawn
		if ( first )
			wait 2
		
		first = false
	}
	
	wait 15
	
	thread Spawner( team )
}

// Populates the match
void function Spawner( int team )
{
	int index = team == TEAM_MILITIA ? 0 : 1
	
	while( true )
	{
		Escalate( team )
		
		// TODO: this should possibly not count scripted npc spawns, probably only the ones spawned by this script
		array<entity> npcs = GetNPCArrayOfTeam( team )
		int count = npcs.len()
		int reaper_count = GetNPCArrayEx( "npc_super_spectre", team, -1, <0,0,0>, -1 ).len()
		
		// REAPERS
		if ( file.reapers[ index ] )
		{
			array< entity > points = SpawnPoints_GetDropPod()
			if ( reaper_count < REAPERS_PER_TEAM )
			{
				entity node = points[ GetSpawnPointIndex( points, team ) ]
				waitthread SpawnReaper( node.GetOrigin(), node.GetAngles(), team )
			}
		}
		
		// NORMAL SPAWNS
		if ( count < SQUADS_PER_TEAM * 4 - 2 )
		{
			string ent = file.podEntities[ index ][ RandomInt( file.podEntities[ index ].len() ) ]
			
			// Prefer dropship when spawning grunts
			if ( ent == "npc_soldier" )
			{
				array< entity > points = GetZiplineDropshipSpawns()
				if ( RandomInt( points.len() / 4 ) )
				{
					entity node = points[ GetSpawnPointIndex( points, team ) ]
					waitthread SpawnDropShip( node.GetOrigin(), node.GetAngles(), team, 4, SquadHandler )
					continue
				}
			}
			
			array< entity > points = SpawnPoints_GetDropPod()
			entity node = points[ GetSpawnPointIndex( points, team ) ]
			waitthread SpawnDropPod( node.GetOrigin(), node.GetAngles(), team, ent, SquadHandler )
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
	
	if ( score < file.levels[ index ] )
		return
	
	switch ( file.levels[ index ] )
	{
		case LEVEL_SPECTRES:
			file.levels[ index ] = LEVEL_STALKERS
			file.podEntities[ index ].append( "npc_spectre" )
			SetGlobalNetInt( defcon, 2 )
			return
		case LEVEL_STALKERS:
			file.levels[ index ] = LEVEL_REAPERS
			file.podEntities[ index ].append( "npc_stalker" )
			SetGlobalNetInt( defcon, 3 )
			return
		case LEVEL_REAPERS:
			file.levels[ index ] = 9999
			file.reapers[ index ] = true
			SetGlobalNetInt( defcon, 4 )
			return
	}
	
	unreachable // hopefully
}

//------------------------------------------------------

int function GetSpawnPointIndex( array< entity > points, int team )
{
	entity zone = DecideSpawnZone_Generic( points, team )
	
	if ( IsValid( zone ) )
	{
		// 20 Tries to get a random point close to the zone
		for ( int i = 0; i < 20; i++ )
		{
			int index = RandomInt( points.len() )
		
			if ( Distance2D( points[ index ].GetOrigin(), zone.GetOrigin() ) < 6000 )
				return index
		}
	}
	
	return RandomInt( points.len() )
}

//------------------------------------------------------

void function SquadHandler( string squad )
{
	array< entity > guys
	array< entity > points = GetEntArrayByClass_Expensive( "assault_assaultpoint" )
	
	vector point
	
	// We need to try catch this since some dropships fail to spawn
	try
	{
		guys = GetNPCArrayBySquad( squad )
		
		point = points[ RandomInt( points.len() ) ].GetOrigin()
		
		array<entity> players = GetPlayerArrayOfEnemies( guys[0].GetTeam() )
		
		// Setup AI
		foreach ( guy in guys )
		{
			guy.EnableNPCFlag( NPC_ALLOW_PATROL | NPC_ALLOW_INVESTIGATE | NPC_ALLOW_HAND_SIGNALS | NPC_ALLOW_FLEE )
			guy.AssaultPoint( point )
			guy.AssaultSetGoalRadius( 100 )
			
			// show on enemy radar
			foreach ( player in players )
				guy.Minimap_AlwaysShow( 0, player )
			
			thread AITdm_CleanupBoredNPCThread( guy )
		}
		
		// Every 15 secs change AssaultPoint
		for( ;; )
		{
			guys = GetNPCArrayBySquad( squad )
			point = points[ RandomInt( points.len() ) ].GetOrigin()
			
			foreach ( guy in guys )
				guy.AssaultPoint( point )
			
			wait 15
		}
	}
	catch ( ex )
	{
		printt( "Squad doesn't exist or has been killed off" )
	}
}

void function ReaperHandler( entity reaper )
{
	array<entity> players = GetPlayerArrayOfEnemies( reaper.GetTeam() )
	foreach ( player in players )
		reaper.Minimap_AlwaysShow( 0, player )
	
	thread AITdm_CleanupBoredNPCThread( reaper )
}

void function AITdm_CleanupBoredNPCThread( entity guy )
{
	// track all ai that we spawn, ensure that they're never "bored" (i.e. stuck by themselves doing fuckall with nobody to see them) for too long
	// if they are, kill them so we can free up slots for more ai to spawn
	// we shouldn't ever kill ai if players would notice them die

	guy.EndSignal( "OnDestroy" )
	wait 15.0 // cover spawning time from dropship/pod + before we start cleaning up
	
	int cleanupFailures = 0 // when this hits 2, cleanup the npc
	while ( cleanupFailures < 2 )
	{
		wait 10.0
	
		if ( guy.GetParent() != null )
			continue // never cleanup while spawning
	
		array<entity> otherGuys = GetPlayerArray()
		otherGuys.extend( GetNPCArrayOfTeam( GetOtherTeam( guy.GetTeam() ) ) )
		
		bool failedChecks = false
		
		foreach ( entity otherGuy in otherGuys )
		{	
			// skip dead people
			if ( !IsAlive( otherGuy ) )
				continue
		
			// don't kill if too close to anything
			if ( Distance( otherGuy.GetOrigin(), guy.GetOrigin() ) < 2000.0 )
				break
			
			// don't kill if ai or players can see them
			if ( otherGuy.IsPlayer() )
			{
				if ( PlayerCanSee( otherGuy, guy, true, 135 ) )
					break
			}
			else
			{
				if ( otherGuy.CanSee( guy ) )
					break
			}
			
			// don't kill if any ai can see you
			// note: CanSee could potentially be a bad call here, 
			if ( guy.CanSee( otherGuy ) )
				break
				
			failedChecks = true
		}
		
		if ( failedChecks )
			cleanupFailures++
		else
			cleanupFailures--
	}
	
	print( "cleaning up bored npc: " + guy + " from team " + guy.GetTeam() )
	guy.Destroy()
}