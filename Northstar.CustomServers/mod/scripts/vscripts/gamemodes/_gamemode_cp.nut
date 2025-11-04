untyped

global function GamemodeCP_Init
global function RateSpawnpoints_CP

// docker run --rm -it --network=host -v ./Northstar.CustomServers/mod/scripts:/usr/lib/northstar/R2Northstar/mods/Northstar.CustomServers/mod/scripts:ro -v /run/media/pg/Titanfall2:/mnt/titanfall:ro -e 'NS_SERVER_NAME=amped hardpoint test' -e 'NS_SERVER_PASSWORD=pg' -e 'NS_INSECURE=1' -e 'NS_EXTRA_ARGUMENTS=+spewlog_enable 0 +setplaylist cp +launchplaylist cp +ns_should_return_to_lobby 0' ghcr.io/pg9182/northstar-dedicated:1-tf2.0.11.0

// 1: ./NorthstarLauncher.exe -multiple -windowed -allowdupeaccounts -width 960 -height 540 -port 37016 +ns_report_server_to_masterserver 0 +ns_auth_allow_insecure 1 +ns_erase_auth_info 0
// 2: ./NorthstarLauncher.exe -multiple -windowed -allowdupeaccounts -width 960 -height 540 -port 37017 +ns_report_server_to_masterserver 0 +ns_auth_allow_insecure 1 +ns_erase_auth_info 0
// 2: private match
// 1: connect 10.33.0.189:37017
// 2: reload

// needed for sh_gamemode_cp_dialogue
global array<entity> HARDPOINTS

struct HardpointState {
	string group
	entity ent // CHardPoint
	entity trigger
	entity prop
	int oldState = CAPTURE_POINT_STATE_UNASSIGNED
	int oldTeam = TEAM_UNASSIGNED
	float lastTime = 0
	array<entity> capPlayers = []
}

struct State {
    bool ampingEnabled
	array<HardpointState> hardpoints
}

State state

void function GamemodeCP_Init()
{
	state.ampingEnabled = GetCurrentPlaylistVarInt("cp_amped_capture_points", 1) == 1

	RegisterSignal( "HardpointCaptureStart" )
	RegisterSignal( "CapturePointStateChange" )
	RegisterSignal( "CapturePointStateChangeSend" )

	ScoreEvent_SetupEarnMeterValuesForMixedModes()

	AddCallback_EntitiesDidLoad(EntitiesDidLoad_SpawnHardpoints)
	AddCallback_OnPlayerKilled(OnPlayerKilled_UpdateMedals)
	AddCallback_OnPlayerKilled(OnPlayerKilled_UpdateHardpoints)

	ScoreEvent_SetEarnMeterValues("KillPilot", 0.1, 0.12)
	ScoreEvent_SetEarnMeterValues("KillTitan", 0, 0)
	ScoreEvent_SetEarnMeterValues("TitanKillTitan", 0, 0)
	ScoreEvent_SetEarnMeterValues("PilotBatteryStolen", 0, 35)
	ScoreEvent_SetEarnMeterValues("Headshot", 0, 0.02)
	ScoreEvent_SetEarnMeterValues("FirstStrike", 0, 0.05)

	ScoreEvent_SetEarnMeterValues("ControlPointCapture", 0.1, 0.1)
	ScoreEvent_SetEarnMeterValues("ControlPointHold", 0.02, 0.02)
	ScoreEvent_SetEarnMeterValues("ControlPointAmped", 0.2, 0.15)
	ScoreEvent_SetEarnMeterValues("ControlPointAmpedHold", 0.05, 0.05)

	ScoreEvent_SetEarnMeterValues("HardpointAssault", 0.10, 0.15)
	ScoreEvent_SetEarnMeterValues("HardpointDefense", 0.5, 0.10)
	ScoreEvent_SetEarnMeterValues("HardpointPerimeterDefense", 0.1, 0.12)
	ScoreEvent_SetEarnMeterValues("HardpointSiege", 0.1, 0.15)
	ScoreEvent_SetEarnMeterValues("HardpointSnipe", 0.1, 0.15)
}

void function RateSpawnpoints_CP( int checkClass, array<entity> spawnpoints, int team, entity player )
{
	if ( HasSwitchedSides() )
		team = GetOtherTeam( team )

	// check hardpoints, determine which ones we own
	array<entity> startSpawns = SpawnPoints_GetPilotStart( team )
	vector averageFriendlySpawns

	// average out startspawn positions
	foreach ( entity spawnpoint in startSpawns )
		averageFriendlySpawns += spawnpoint.GetOrigin()

	averageFriendlySpawns /= startSpawns.len()

	entity friendlyHardpoint // determine our furthest out hardpoint
	foreach ( entity hardpoint in HARDPOINTS )
	{
		if ( hardpoint.GetTeam() == player.GetTeam() && GetGlobalNetFloat( "objective" + CapturePoint_GetGroup(hardpoint) + "Progress" ) >= 0.95 )
		{
			if ( IsValid( friendlyHardpoint ) )
			{
				if ( Distance2D( averageFriendlySpawns, hardpoint.GetOrigin() ) > Distance2D( averageFriendlySpawns, friendlyHardpoint.GetOrigin() ) )
					friendlyHardpoint = hardpoint
			}
			else
				friendlyHardpoint = hardpoint
		}
	}

	vector ratingPos
	if ( IsValid( friendlyHardpoint ) )
		ratingPos = friendlyHardpoint.GetOrigin()
	else
		ratingPos = averageFriendlySpawns

	foreach ( entity spawnpoint in spawnpoints )
	{
		// idk about magic number here really
		float rating = 1.0 - ( Distance2D( spawnpoint.GetOrigin(), ratingPos ) / 1000.0 )
		spawnpoint.CalculateRating( checkClass, player.GetTeam(), rating, rating )
	}
}

void function EntitiesDidLoad_SpawnHardpoints()
{
	foreach ( entity hp in GetEntArrayByClass_Expensive("info_hardpoint") )
	{
		if ( GameModeRemove( hp ) )
			continue

		HardpointState hpState
		hpState.group = CapturePoint_GetGroup( hp )
		hpState.ent = hp
		hpState.prop = CreatePropDynamic( hp.GetModelName(), hp.GetOrigin(), hp.GetAngles(), SOLID_VPHYSICS )
		hpState.trigger = GetEnt( expect string(hp.kv.triggerTarget) )
		state.hardpoints.append( hpState )

		switch (hpState.group) {
			case "A":
				hp.SetHardpointID( 0 )
				break
			case "B":
				hp.SetHardpointID( 1 )
				break
			case "C":
				hp.SetHardpointID( 2 )
				break
			default:
				throw "unknown hardpoint group name"
		}

		SetTeam( hpState.ent, TEAM_UNASSIGNED )
		SetGlobalNetEnt( "objective" + hpState.group + "Ent", hpState.ent )
		

		hpState.trigger.SetEnterCallback( OnHardpointEnter )
		hpState.trigger.SetLeaveCallback( OnHardpointLeave )
		hpState.trigger.SetOwner( hp )

		hpState.ent.Minimap_SetCustomState( hpState.ent.GetHardpointID() + 1 )
		hpState.ent.Minimap_AlwaysShow( TEAM_MILITIA, null )
		hpState.ent.Minimap_AlwaysShow( TEAM_IMC, null )
		hpState.ent.Minimap_SetAlignUpright( true )

		hpState.ent.s.prop <- hpState.prop
		hpState.ent.s.reachedAmeped <- false
		hpState.ent.s.state <- CAPTURE_POINT_STATE_UNASSIGNED


		HARDPOINTS.append( hpState.ent ) // for vo script
		hpState.ent.s.trigger <- hpState.trigger // also for vo script

		thread PlayAnim( hpState.prop, "mh_inactive_idle" )

		thread Hardpoint_Think( hpState )
	}

	thread TrackChevronStates()
}

void function OnPlayerKilled_UpdateMedals( entity victim, entity attacker, var damageInfo )
{
    if (!attacker.IsPlayer())
        return
}

void function OnPlayerKilled_UpdateHardpoints( entity victim, entity attacker, var damageInfo )
{
	
}

void function OnHardpointEnter( entity trigger, entity player )
{
	entity hp = trigger.GetOwner();

	// don't handle anything other than players yet
	if ( !player.IsPlayer() )
		return

	// it's just too hard to handle emarking and disemarking with the count stuff
	HardpointState hpState = GetHardPointState( hp )
	if ( hpState.capPlayers.find( player ) == -1 )
		hpState.capPlayers.append( player )

	player.SetPlayerNetInt( "playerHardpointID", hp.GetHardpointID() )
}

void function OnHardpointLeave( entity trigger, entity player )
{
	entity hp = trigger.GetOwner();

	// don't handle anything other than players yet
	if ( !player.IsPlayer() )
		return

	// it's just too hard to handle emarking and disemarking with the count stuff
	HardpointState hpState = GetHardPointState( hp )
	int index = hpState.capPlayers.find( player );
	if ( index != -1 )
		hpState.capPlayers.fastremove( index )

	player.SetPlayerNetInt( "playerHardpointID", 1023 )
}

void function Hardpoint_Think( HardpointState hardpoint )
{
	// wait for game state playing otherwise vo might not correctly start
	while ( GetGameState() != eGameState.Playing )
		WaitFrame()

	thread GamemodeCP_VO_Think( hardpoint.ent )
	// there is also a thing called GamemodeCP_VO_Approaching but respawn never used?

	while ( GetGameState() <= eGameState.Playing )
	{
		// they will be recounted in the next "scope"
		hardpoint.ent.SetHardpointPlayerCount( TEAM_IMC, 0 )
		hardpoint.ent.SetHardpointPlayerCount( TEAM_MILITIA, 0 )
		hardpoint.ent.SetHardpointPlayerTitanCount( TEAM_IMC, 0 )
		hardpoint.ent.SetHardpointPlayerTitanCount( TEAM_MILITIA, 0 )

		// update counts based on capPlayers
		foreach( entity player in hardpoint.capPlayers )
		{
			if ( player.IsTitan() )
				hardpoint.ent.SetHardpointPlayerTitanCount( player.GetTeam(), hardpoint.ent.GetHardpointPlayerTitanCount( player.GetTeam() ) + 1 )
			else
				hardpoint.ent.SetHardpointPlayerCount( player.GetTeam(), hardpoint.ent.GetHardpointPlayerCount( player.GetTeam() ) + 1 )
		}

		Hardpoint_ThinkTick( hardpoint )

		SetTeam( hardpoint.prop, hardpoint.ent.GetTeam() ) // hardpoint has to have the correct color

		WaitFrame()
	}
}

const HAS_IMC = 1
const HAS_MILITIA = 1 << 1
const HAS_IMC_TITAN = 1 << 2
const HAS_MILITIA_TITAN = 1 << 3
const CONTESTED = HAS_IMC | HAS_MILITIA | HAS_IMC_TITAN | HAS_MILITIA_TITAN
const IMC_HOLD = HAS_IMC | HAS_IMC_TITAN
const MILITIA_HOLD = HAS_MILITIA | HAS_MILITIA_TITAN
void function Hardpoint_ThinkTick( HardpointState hardpoint )
{
	
	int currentState = expect int( hardpoint.ent.s.state )
	int currentTeam = CapturePoint_GetOwningTeam( hardpoint.ent )
	int oldState = hardpoint.oldState
	int oldTeam = hardpoint.oldTeam
	float deltaTime = Time() - hardpoint.lastTime
	int imcCappers = hardpoint.ent.GetHardpointPlayerCount( TEAM_IMC ) + hardpoint.ent.GetHardpointPlayerTitanCount( TEAM_IMC );
	int militiaCappers = hardpoint.ent.GetHardpointPlayerCount( TEAM_MILITIA ) + hardpoint.ent.GetHardpointPlayerTitanCount( TEAM_MILITIA );

	int occupation = min( abs( hardpoint.ent.GetHardpointPlayerCount( TEAM_IMC ) ), 1 ).tointeger()
		| min( abs( hardpoint.ent.GetHardpointPlayerCount( TEAM_MILITIA ) ), 1 ).tointeger() << 1
		| min( abs( hardpoint.ent.GetHardpointPlayerTitanCount( TEAM_IMC ) ), 1 ).tointeger() << 2
		| min( abs( hardpoint.ent.GetHardpointPlayerTitanCount( TEAM_MILITIA ) ), 1 ).tointeger() << 3

	// I am pretty sure it's just a check for if both teams are present not which one has more
	if ( ( occupation & CONTESTED ) > 0 && !( ( occupation & IMC_HOLD ) == 0 || ( occupation & MILITIA_HOLD ) == 0 ) && ( ( occupation & HAS_IMC_TITAN ) == ( occupation & HAS_MILITIA_TITAN ) ) )
	{
		CapturePoint_SetState( hardpoint.ent, CapturePoint_GetState( hardpoint.ent ) | CAPTURE_POINT_FLAGS_CONTESTED ) // add contested flag
		hardpoint.ent.s.state = CAPTURE_POINT_STATE_HALTED
	}
	else if ( ( occupation & IMC_HOLD ) != 0 )
	{
		CapturePoint_SetState( hardpoint.ent, CapturePoint_GetState( hardpoint.ent ) & ~CAPTURE_POINT_FLAGS_CONTESTED ) // remove contested flag
		CaptureHardPoint( hardpoint.ent, TEAM_IMC, deltaTime, imcCappers )
	}
	else if ( ( occupation & MILITIA_HOLD ) != 0 )
	{
		CapturePoint_SetState( hardpoint.ent, CapturePoint_GetState( hardpoint.ent ) & ~CAPTURE_POINT_FLAGS_CONTESTED ) // remove contested flag
		CaptureHardPoint( hardpoint.ent, TEAM_MILITIA, deltaTime, militiaCappers )
	}
	else
	{
		CapturePoint_SetState( hardpoint.ent, CapturePoint_GetState( hardpoint.ent ) & ~CAPTURE_POINT_FLAGS_CONTESTED ) // remove contested flag
		if( CapturePoint_GetCaptureProgress( hardpoint.ent ) <=1.001 ) // unamp
		{
			if ( hardpoint.ent.s.reachedAmeped ) // only play 2inactive animation if we were amped
				thread PlayAnim( hardpoint.prop, "mh_active_2_inactive" )

			CapturePoint_SetState( hardpoint.ent, CapturePoint_GetState( hardpoint.ent ) & ~CAPTURE_POINT_FLAGS_AMPED ) // remove amped flag
			hardpoint.ent.s.reachedAmeped = false
		}
		else
		{
			CapturePoint_SetCappingTeam( hardpoint.ent, TEAM_UNASSIGNED )
			CapturePoint_SetCaptureProgress( hardpoint.ent, max( 1.0, min( 2.0, CapturePoint_GetCaptureProgress( hardpoint.ent ) - ( deltaTime / HARDPOINT_AMPED_DELAY ) ) ) )

			if ( currentState == CAPTURE_POINT_STATE_AMPING || currentState != CAPTURE_POINT_STATE_SELF_UNAMPING ) // idk the old code does this
				hardpoint.ent.s.state = CAPTURE_POINT_STATE_SELF_UNAMPING
		}
	}

	// steal state code from respawn vo think since it won't work
	// I assume this is what respawn did in their own sv code since the state net var is using flags not state
	int newState = expect int( hardpoint.ent.s.state )
	if ( oldState == CAPTURE_POINT_STATE_UNASSIGNED && newState == CAPTURE_POINT_STATE_CAPPING )
	{
		// starting capture of uncaptured point
		printt( "starting capture of uncaptured point" )
		GamemodeCP_VO_StartCapping( hardpoint.ent )
	}
	else if ( oldState == CAPTURE_POINT_STATE_SELF_UNAMPING && newState == CAPTURE_POINT_STATE_CAPPING )
	{
		//Started capping a point that was naturally unamping
		printt( "Started capping a point that was naturally unamping" )
		GamemodeCP_VO_StartCapping( hardpoint.ent )
	}
	else if ( oldState >= CAPTURE_POINT_STATE_CAPTURED && newState == CAPTURE_POINT_STATE_CAPPING )
	{
		// started capturing an unoccupied hardpoint
		printt( "started capturing an unoccupied hardpoint" )
		GamemodeCP_VO_StartCapping( hardpoint.ent )
	}
	else if ( oldState == CAPTURE_POINT_STATE_HALTED && newState == CAPTURE_POINT_STATE_CAPPING )
	{
		// cleared hardpoint OR exited and re-entered hardpoint
		printt( "cleared hardpoint OR exited and re-entered hardpoint. Hardpoint was previously unowned" )
		GamemodeCP_VO_StartCapping( hardpoint.ent )
	}

	table oldStates = { oldTeam = oldTeam, oldState = oldState }
	// SendVoSignal( hardpoint.ent, oldStates )

	// update old stuff
	hardpoint.oldTeam = hardpoint.ent.GetTeam();
	hardpoint.oldState = expect int( hardpoint.ent.s.state );
	hardpoint.lastTime = Time()
}

void function CaptureHardPoint( entity hardpoint, int team, float deltaTime, int cappers )
{
	if ( CapturePoint_GetOwningTeam( hardpoint ) != team && CapturePoint_GetOwningTeam( hardpoint ) != TEAM_UNASSIGNED )
		CaptureHardPointEnemy( hardpoint, team, deltaTime, cappers )
	else
		CaptureHardPointAllied( hardpoint, team, deltaTime, cappers )		
}

void function CaptureHardPointAllied( entity hardpoint, int team, float deltaTime, int cappers )
{
	CapturePoint_SetCappingTeam( hardpoint, team )

	if ( CapturePoint_GetStartProgress( hardpoint ) < 1.0 )
	{
		hardpoint.s.state = CAPTURE_POINT_STATE_CAPPING

		CapturePoint_SetCaptureProgress( hardpoint, max( 0.0, min( 1.0, CapturePoint_GetCaptureProgress( hardpoint ) + ( deltaTime / CAPTURE_DURATION_CAPTURE * cappers) ) ) )
	}
	else if ( CapturePoint_GetStartProgress( hardpoint ) >= 1.0 && expect int( hardpoint.s.state ) < CAPTURE_POINT_STATE_CAPTURED )
	{
		if ( hardpoint.s.state < CAPTURE_POINT_STATE_SELF_UNAMPING )
			SetCaptureHardpoint( hardpoint, team ) // respawn probably exposed this function for a reason so we use it

		hardpoint.s.state = CAPTURE_POINT_STATE_CAPTURED

		CapturePoint_SetOwningTeam( hardpoint, team )
		hardpoint.s.reachedAmeped = false
	}
	else if ( CapturePoint_GetStartProgress( hardpoint ) >= 2.0 && expect int( hardpoint.s.state ) >= CAPTURE_POINT_STATE_CAPTURED && state.ampingEnabled )
	{
		if ( !hardpoint.s.reachedAmeped )
			thread PlayAnim( hardpoint.s.prop, "mh_inactive_2_active" )
		hardpoint.s.reachedAmeped = true


		CapturePoint_SetState( hardpoint, CapturePoint_GetState( hardpoint ) | CAPTURE_POINT_FLAGS_AMPED ) // add apmed flag
		hardpoint.s.state = CAPTURE_POINT_STATE_AMPED
		CapturePoint_SetOwningTeam( hardpoint, team )
	}
	else if ( CapturePoint_GetStartProgress( hardpoint ) >= 1.0 && expect int( hardpoint.s.state ) >= CAPTURE_POINT_STATE_CAPTURED && state.ampingEnabled )
	{
		hardpoint.s.state = CAPTURE_POINT_STATE_CAPTURED
		CapturePoint_SetOwningTeam( hardpoint, team )


		CapturePoint_SetCaptureProgress( hardpoint, max( 1.0, min( 2.0, CapturePoint_GetCaptureProgress( hardpoint ) + ( deltaTime / HARDPOINT_AMPED_DELAY * cappers) ) ) )
	}

	printt( CapturePoint_GetStartProgress( hardpoint ) )
	printt( CaptureStateToString( CapturePoint_GetState( hardpoint ) ) )
}

void function CaptureHardPointEnemy( entity hardpoint, int team, float deltaTime, int cappers )
{
	CapturePoint_SetCappingTeam( hardpoint, team )

	if ( CapturePoint_GetStartProgress( hardpoint ) > 0.0 )
	{
		CapturePoint_SetCaptureProgress( hardpoint, max( 0.0, min( 2.0, CapturePoint_GetCaptureProgress( hardpoint ) - ( deltaTime / CAPTURE_DURATION_CAPTURE * cappers) ) ) )

		hardpoint.s.state = CAPTURE_POINT_STATE_CAPPING

		if ( hardpoint.s.reachedAmeped && CapturePoint_GetStartProgress( hardpoint ) <= 1.0 )
		{
			thread PlayAnim( hardpoint.s.prop, "mh_active_2_inactive" )
			CapturePoint_SetState( hardpoint, CapturePoint_GetState( hardpoint ) & ~CAPTURE_POINT_FLAGS_AMPED ) // remove apmed flag
			hardpoint.s.reachedAmeped = false
		}
	}
	else if ( CapturePoint_GetStartProgress( hardpoint ) == 0.0 )
	{
		if ( expect int( hardpoint.s.state ) != CAPTURE_POINT_STATE_CAPTURED )
			SetCaptureHardpoint( hardpoint, team ) // respawn probably exposed this function for a reason so we use it

		CapturePoint_SetState( hardpoint, CAPTURE_POINT_STATE_CAPTURED )
		CapturePoint_SetOwningTeam( hardpoint, team )
		CapturePoint_SetCaptureProgress( hardpoint, 1.0 )
		hardpoint.s.reachedAmeped = false
		CapturePoint_SetState( hardpoint, CapturePoint_GetState( hardpoint ) & ~CAPTURE_POINT_FLAGS_AMPED ) // remove apmed flag
	}

	printt( CapturePoint_GetStartProgress( hardpoint ) )
	printt( CaptureStateToString( CapturePoint_GetState( hardpoint ) ) )
}

void function SetCaptureHardpoint( entity hardpoint, int team )
{
	HardpointState hpState = GetHardPointState( hardpoint )

	hardpoint.s.state = CAPTURE_POINT_STATE_CAPTURED
	CapturePoint_SetOwningTeam( hardpoint, team )
	
	EmitSoundOnEntityToTeamExceptPlayer( hardpoint, "hardpoint_console_captured", team, null )
	GamemodeCP_VO_Captured( hardpoint )

	foreach( entity player in hpState.capPlayers )
	{
		// the team check is just for race conditions
		if( player.IsPlayer() && player.GetTeam() == team )
		{
			AddPlayerScore( player,"ControlPointCapture" )
			player.AddToPlayerGameStat( PGS_ASSAULT_SCORE, POINTVALUE_HARDPOINT_CAPTURE )
			UpdatePlayerScoreForChallenge( player, POINTVALUE_HARDPOINT_CAPTURE, 0 )
		}
	}
}

void function TrackChevronStates() {
	while ( GetGameState() <= eGameState.Playing )
	{
		table <int, int> chevrons = {
			[TEAM_IMC] = 0,
			[TEAM_MILITIA] = 0,
		}

		foreach (HardpointState hardpoint in state.hardpoints) {
			foreach (team, chevronsCount in chevrons) {
				if ( team == CapturePoint_GetOwningTeam( hardpoint.ent ) ) {
					// 4 is the value for a amped chevron
					chevrons[team] += hardpoint.ent.s.state == CAPTURE_POINT_STATE_AMPED ? 5 : 1
				}
			}

			
			if ( hardpoint.ent.s.state == CAPTURE_POINT_STATE_AMPED )
				AddTeamScore( CapturePoint_GetOwningTeam( hardpoint.ent ), 2 )
			else if( hardpoint.ent.s.state >= CAPTURE_POINT_STATE_CAPTURED)
				AddTeamScore( CapturePoint_GetOwningTeam( hardpoint.ent ), 1 )
		}

		SetGlobalNetInt( "imcChevronState", chevrons[TEAM_IMC] )
		SetGlobalNetInt( "milChevronState", chevrons[TEAM_MILITIA] )

		// the cheverons get updated at the same rigth it seams
		wait TEAM_OWNED_SCORE_FREQ
	}
}

HardpointState function GetHardPointState( entity hp )
{
	foreach ( hpState in state.hardpoints )
	{
		if ( hpState.ent == hp )
			return hpState 
	}
	unreachable
} 

string function CaptureStateToString( int state ) {
	if ( state == 0 )
		return "NOTHING"

	string val = ""
	if ( state & CAPTURE_POINT_FLAGS_CONTESTED )
		val += " CONTESTED"
	if ( state & CAPTURE_POINT_FLAGS_AMPED )
		val += " AMPED"

	return val
}

// respawn can't even really use their vo think function since the state var uses flags instead of state therefore this is correct
void function GamemodeCP_VO_Amped( entity hardpoint )
{
	#if FACTION_DIALOGUE_ENABLED
		PlayFactionDialogueToTeam( "amphp_youAmped" + CapturePoint_GetGroup( hardpoint ), CapturePoint_GetCappingTeam( hardpoint ) )
		PlayFactionDialogueToTeam( "amphp_enemyAmped" + CapturePoint_GetGroup( hardpoint ), GetOtherTeam( CapturePoint_GetCappingTeam( hardpoint ) ) )
	#endif
}

void function UpdatePlayerScoreForChallenge( entity player, int assaultPoints = 0, int defensePoints = 0 ) {
	// if (player in file.playerAssaultPoints) {
	// 	file.playerAssaultPoints[player] += assaultpoints
	// 	if (file.playerAssaultPoints[player] >= 1000 && !HasPlayerCompletedMeritScore(player)) {
	// 		AddPlayerScore(player, "ChallengeCPAssault")
	// 		SetPlayerChallengeMeritScore(player)
	// 	}
	// }
	// if (player in file.playerDefensePoints) {
	// 	file.playerDefensePoints[player] += defensepoints
	// 	if (file.playerDefensePoints[player] >= 500 && !HasPlayerCompletedMeritScore(player)) {
	// 		AddPlayerScore(player, "ChallengeCPDefense")
	// 		SetPlayerChallengeMeritScore(player)
	// 	}
	// }
	// TODO
}
