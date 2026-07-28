untyped

global function GamemodeAITdm_Init

// these are now default settings
const int SQUADS_PER_TEAM = 4
const int SPECTRES_PER_TEAM = 12
const int REAPERS_PER_TEAM = 2

const int LEVEL_SPECTRES = 125
const int LEVEL_SPECTRES_2 = 350
const int LEVEL_STALKERS = 380
const int LEVEL_REAPERS = 500
const int LEVEL_REAPERS_2 = 575

// add settings
global function AITdm_SetSquadsPerTeam
global function AITdm_SetSpectresPerTeam
global function AITdm_SetReapersPerTeam
global function AITdm_SetLevelSpectres
global function AITdm_SetLevelSpectres_2
global function AITdm_SetLevelStalkers
global function AITdm_SetLevelReapers
global function AITdm_SetLevelReapers_2

struct
{
	// Due to team based escalation everything is an array

	// default settings
	int squadsPerTeam = SQUADS_PER_TEAM
	int spectresPerTeam = SPECTRES_PER_TEAM
	int reapersPerTeam = REAPERS_PER_TEAM
	int levelSpectres = LEVEL_SPECTRES
	int levelSpectres_2 = LEVEL_SPECTRES_2
	int levelStalkers = LEVEL_STALKERS
	int levelReapers = LEVEL_REAPERS
	int levelReapers_2 = LEVEL_REAPERS_2

	table<int, array<entity> > spawnedMinions
	table<int, array<entity> > spawnedSpectres
	table<int, array<entity> > spawnedReapers
} file

void function GamemodeAITdm_Init()
{
	GM_AddPlayingThinkFunc( Escalate )

	AddCallback_GameStateEnter( eGameState.Prematch, OnPrematchStart )
	thread SetupTeamDeathmatchNPCs()

	AddCallback_OnNPCKilled( HandleScoreEvent )
	AddCallback_OnPlayerKilled( HandleScoreEvent )

	AddCallback_OnClientConnected( OnPlayerConnected )

	AddCallback_NPCLeeched( OnSpectreLeeched )

	if ( !GetCurrentPlaylistVarInt( "aitdm_archer_grunts", 0 ) )
	{
		SetNPCWeapons(
			"npc_soldier",
			[ "mp_weapon_rspn101", "mp_weapon_dmr", "mp_weapon_vinson", "mp_weapon_hemlok_smg", "mp_weapon_mastiff", "mp_weapon_shotgun_pistol" ]
		)
		SetNPCWeapons( "npc_spectre", [ "mp_weapon_g2", "mp_weapon_doubletake", "mp_weapon_hemlok", "mp_weapon_rspn101_og", "mp_weapon_r97" ] )
		SetNPCWeapons( "npc_stalker", [ "mp_weapon_esaw", "mp_weapon_lstar", "mp_weapon_shotgun", "mp_weapon_lmg", "mp_weapon_smr", "mp_weapon_epg" ] )
	}
	else
	{
		SetNPCWeapons( "npc_soldier", [ "mp_weapon_rocket_launcher" ] )
		SetNPCWeapons( "npc_spectre", [ "mp_weapon_rocket_launcher" ] )
		SetNPCWeapons( "npc_stalker", [ "mp_weapon_rocket_launcher" ] )
	}

	ScoreEvent_SetupEarnMeterValuesForMixedModes()
	SetupGenericTDMChallenge()
	SetAILethality( eAILethality.High )
	SetPlayThreeMinuteMusic( true )

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

void function AITdm_SetLevelSpectres_2( int level )
{
	file.levelSpectres_2 = level
}

void function AITdm_SetLevelStalkers( int level )
{
	file.levelStalkers = level
}

void function AITdm_SetLevelReapers( int level )
{
	file.levelReapers = level
}

void function AITdm_SetLevelReapers_2( int level )
{
	file.levelReapers_2 = level
}

// Starts skyshow, this also requiers AINs but doesn't crash if they're missing
void function OnPrematchStart()
{
	thread StratonHornetDogfightsIntense()
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
		if ( eventName != "KillNPCTitan" && eventName != "" )
			playerScore = ScoreEvent_GetPointValue( GetScoreEvent( eventName ) )
	}

	if ( victim.IsPlayer() )
		playerScore = 5

	// Player ejecting triggers this without the extra check
	if ( victim.IsTitan() && victim.GetBossPlayer() != attacker )
		playerScore += 10

	teamScore = playerScore

	// Check score so we dont go over max
	if ( GameRules_GetTeamScore( attacker.GetTeam() ) + teamScore > GetScoreLimit_FromPlaylist() )
		teamScore = GetScoreLimit_FromPlaylist() - GameRules_GetTeamScore( attacker.GetTeam() )

	// Add score + update network int to trigger the "Score +n" popup
	AddTeamScore( attacker.GetTeam(), teamScore )

	attacker.AddToPlayerGameStat( PGS_ASSAULT_SCORE, playerScore )

	int assaultscore = attacker.GetPlayerGameStat( PGS_ASSAULT_SCORE )
	int assaultscore256 = assaultscore / 256

	attacker.SetPlayerNetInt( "AT_bonusPoints", assaultscore - assaultscore256 * 256 )
	attacker.SetPlayerNetInt( "AT_bonusPoints256", assaultscore256 )
}

// Based on points tries to balance match
void function Escalate()
{
	foreach ( int team in [ TEAM_IMC, TEAM_MILITIA ] )
	{
		int score = GameRules_GetTeamScore( team )
		int index = team == TEAM_MILITIA ? 1 : 0
		// This does the "Enemy x incoming" text
		string defcon = team == TEAM_MILITIA ? "IMCdefcon" : "MILdefcon"

		team = GetOtherTeam( team )

		while ( true )
		{
			int currentDefCon = GetGlobalNetInt( defcon )

			if (
				!( !currentDefCon && score >= file.levelSpectres ) && !( currentDefCon == 1 && score >= file.levelSpectres_2 ) &&
				!( currentDefCon == 2 && score >= file.levelStalkers ) && !( currentDefCon == 3 && score >= file.levelReapers ) &&
				!( currentDefCon == 4 && score >= file.levelReapers_2 )
			)
				return

			// Based on score escalate a team
			switch ( currentDefCon )
			{
				case 0:
					level.spectreSpawnChance[ team ] = 10
					level.maxSpectrePerSide[ team ] += 4

					SetGlobalNetInt( defcon, 1 )

				case 1:
					level.spectreSpawnChance[ team ] = 15
					level.maxSpectrePerSide[ team ] += 8

					SetGlobalNetInt( defcon, 2 )

				case 2:
					level.stalkerSpawnChance[ team ] = 10
					level.maxStalkersPerSide[ team ] += 4

					SetGlobalNetInt( defcon, 3 )

				case 3:
					level.reaperSpawnChance[ team ] = 100
					level.maxReapersPerSide[ team ] += 2
					level.modifyAISlots[ team ] += 2

					SetGlobalNetInt( defcon, 4 )

				case 4:
					level.maxReapersPerSide[ team ] += 1
					level.modifyAISlots[ team ] += 1

					SetGlobalNetInt( defcon, 5 )
			}
		}
	}
}

// Award for hacking
void function OnSpectreLeeched( entity spectre, entity player )
{
	if ( !IsSpectre( spectre ) )
		return

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
