untyped

global function GamemodeAITdm_Init

const int DEFCON_1 = 125
const int DEFCON_2 = 250
const int DEFCON_3 = 380
const int DEFCON_4 = 500
const int DEFCON_5 = 575

// add settings
global function AITdm_SetDefcon_1
global function AITdm_SetDefcon_2
global function AITdm_SetDefcon_3
global function AITdm_SetDefcon_4
global function AITdm_SetDefcon_5

struct
{
	int defcon_1 = DEFCON_1
	int defcon_2 = DEFCON_2
	int defcon_3 = DEFCON_3
	int defcon_4 = DEFCON_4
	int defcon_5 = DEFCON_5
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
		SetNPCWeapons( "npc_soldier", [ "mp_weapon_rspn101", "mp_weapon_dmr", "mp_weapon_r97", "mp_weapon_lmg" ] )
		SetNPCWeapons( "npc_spectre", [ "mp_weapon_hemlok_smg", "mp_weapon_doubletake", "mp_weapon_mastiff" ] )
		SetNPCWeapons( "npc_stalker", [ "mp_weapon_hemlok_smg", "mp_weapon_lstar", "mp_weapon_mastiff" ] )
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
	SetPlayThreeMinuteMusicCheck( ThreeMinuteMusicCheck )

	level.endOfRoundPlayerState = ENDROUND_FREE
}

// add settings
void function AITdm_SetDefcon_1( int score )
{
	file.defcon_1 = score
}

void function AITdm_SetDefcon_2( int score )
{
	file.defcon_2 = score
}

void function AITdm_SetDefcon_3( int score )
{
	file.defcon_3 = score
}

void function AITdm_SetDefcon_4( int score )
{
	file.defcon_4 = score
}

void function AITdm_SetDefcon_5( int score )
{
	file.defcon_5 = score
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
		int currentDefCon = GetGlobalNetInt( defcon )

		team = GetOtherTeam( team )

		while (
			( !currentDefCon && score >= file.defcon_1 ) || ( currentDefCon == 1 && score >= file.defcon_2 ) || ( currentDefCon == 2 && score >= file.defcon_3 ) ||
			( currentDefCon == 3 && score >= file.defcon_4 ) || ( currentDefCon == 4 && score >= file.defcon_5 )
		)
		{
			// Based on score escalate a team
			switch ( currentDefCon )
			{
				case 0:
					level.spectreSpawnChance[ team ] = 10
					level.maxSpectrePerSide[ team ] += 8

					SetGlobalNetInt( defcon, 1 )
					break

				case 1:
					level.spectreSpawnChance[ team ] = 20
					level.maxSpectrePerSide[ team ] += 4

					SetGlobalNetInt( defcon, 2 )
					break

				case 2:
					level.stalkerSpawnChance[ team ] = 10
					level.maxStalkersPerSide[ team ] += 8

					SetGlobalNetInt( defcon, 3 )
					break

				case 3:
					level.reaperSpawnChance[ team ] = 100
					level.maxReapersPerSide[ team ] += 2
					level.modifyAISlots[ team ] += 2

					SetGlobalNetInt( defcon, 4 )
					break

				case 4:
					level.maxReapersPerSide[ team ] += 1
					level.modifyAISlots[ team ] += 1

					SetGlobalNetInt( defcon, 5 )
					break
			}

			currentDefCon = GetGlobalNetInt( defcon )
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

bool function ThreeMinuteMusicCheck( int timeLeftSeconds, float timeLimit )
{
	return level.nv.matchProgress >= 75 || timeLeftSeconds < ( timeLimit * 0.4 - 60 )
}
