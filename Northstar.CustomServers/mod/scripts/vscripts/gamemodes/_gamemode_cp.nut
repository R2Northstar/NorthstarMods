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

	RegisterSignal("HardpointCaptureStart")
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

		HARDPOINTS.append( hpState.ent ) // for vo script
		hpState.ent.s.trigger <- hpState.trigger // also for vo script

		thread PlayAnim( hpState.prop, "mh_inactive_idle" )

		thread Hardpoint_Think( hpState )
	}
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

	printt( "hp enter " + player.GetPlayerName() + " titans " + hp.GetHardpointPlayerTitanCount( player.GetTeam() ) + " players " + hp.GetHardpointPlayerCount( player.GetTeam() ) )
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

	printt( "hp leave " + player.GetPlayerName() + " titans " + hp.GetHardpointPlayerTitanCount( player.GetTeam() ) + " players " + hp.GetHardpointPlayerCount( player.GetTeam() ) )
}

void function Hardpoint_Think( HardpointState hardpoint )
{
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

		SetTeam( hardpoint.prop, hardpoint.ent.GetTeam() ) // just in case idk

		WaitFrame()
	}
}

// global const CAPTURE_POINT_STATE_UNASSIGNED		= 0					// State at start of match
// global const CAPTURE_POINT_STATE_HALTED			= 1					// In this state the bar is not moving and the icon is at full oppacity
// global const CAPTURE_POINT_STATE_CAPPING		= 2				// In this state the bar is moving and the icon pulsate
// global const CAPTURE_POINT_STATE_SELF_UNAMPING	= 3		// In this state the bar is moving and the icon pulsate

// //Script assumes >= CAPTURE_POINT_STATE_CAPTURED is equivalent to captured. Keep these two last numerically.
// global const CAPTURE_POINT_STATE_CAPTURED			= 4				// TBD what this looks like exatly.
// global const CAPTURE_POINT_STATE_AMPING				= 5
// global const CAPTURE_POINT_STATE_AMPED				= 6				// If held for > 1 minute.

// global const CAPTURE_POINT_STATE_CONTESTED	= 7					// In this state the bar is not moving and the icon is at full oppacity

const HAS_IMC = 1
const HAS_MILTIA = 1 << 1
const HAS_IMC_TITAN = 1 << 2
const HAS_MILTIA_TITAN = 1 << 3
const CONTESTED = HAS_IMC | HAS_MILTIA | HAS_IMC_TITAN | HAS_MILTIA_TITAN
const IMC_HOLD = HAS_IMC | HAS_IMC_TITAN
const MILTIA_HOLD = HAS_MILTIA | HAS_MILTIA_TITAN
void function Hardpoint_ThinkTick( HardpointState hardpoint )
{
	
	int currentState = hardpoint.ent.GetHardpointState()
	int currentTeam = CapturePoint_GetOwningTeam( hardpoint.ent )
	int oldState = hardpoint.oldState
	int oldTeam = hardpoint.oldTeam

	int occupation = min( abs( hardpoint.ent.GetHardpointPlayerCount( TEAM_IMC ) ), 1 ).tointeger()
		| min( abs( hardpoint.ent.GetHardpointPlayerCount( TEAM_MILITIA ) ), 1 ).tointeger() << 1
		| min( abs( hardpoint.ent.GetHardpointPlayerTitanCount( TEAM_IMC ) ), 1 ).tointeger() << 2
		| min( abs( hardpoint.ent.GetHardpointPlayerTitanCount( TEAM_MILITIA ) ), 1 ).tointeger() << 3

	// I am pretty sure it's just a check for if both teams are present not which one has more
	if ( ( occupation & CONTESTED ) > 0 && !( ( occupation & IMC_HOLD ) == 0 || ( occupation & MILTIA_HOLD ) == 0 ) && ( ( occupation & HAS_IMC_TITAN ) == ( occupation & HAS_MILTIA_TITAN ) ) )
	{
		CapturePoint_SetState( hardpoint.ent, CAPTURE_POINT_STATE_CONTESTED )
	}
	else if ( ( occupation & IMC_HOLD ) != 0 && currentTeam != TEAM_IMC )
	{
		CapturePoint_SetCappingTeam( hardpoint.ent, TEAM_IMC )
		if ( CapturePoint_GetStartProgress( hardpoint.ent ) < 1.0 )
			CapturePoint_SetState( hardpoint.ent, CAPTURE_POINT_STATE_CAPPING )
		else if ( CapturePoint_GetStartProgress( hardpoint.ent ) == 1.0 )
			CapturePoint_SetState( hardpoint.ent, CAPTURE_POINT_STATE_CAPTURED )
		else if ( CapturePoint_GetStartProgress( hardpoint.ent ) >= 2.0 )
			CapturePoint_SetState( hardpoint.ent, CAPTURE_POINT_STATE_AMPED )
		else if ( CapturePoint_GetStartProgress( hardpoint.ent ) > 1.0 )
			CapturePoint_SetState( hardpoint.ent, CAPTURE_POINT_STATE_AMPING )
	}
	else if ( ( occupation & MILTIA_HOLD ) != 0 && currentTeam != TEAM_MILITIA )
	{
		CapturePoint_SetCappingTeam( hardpoint.ent, TEAM_MILITIA )
		if ( CapturePoint_GetCaptureProgress( hardpoint.ent ) < 1.0 )
			CapturePoint_SetState( hardpoint.ent, CAPTURE_POINT_STATE_CAPPING )
		else if ( CapturePoint_GetCaptureProgress( hardpoint.ent ) == 1.0 )
			CapturePoint_SetState( hardpoint.ent, CAPTURE_POINT_STATE_CAPTURED )
		else if ( CapturePoint_GetCaptureProgress( hardpoint.ent ) >= 2.0 )
			CapturePoint_SetState( hardpoint.ent, CAPTURE_POINT_STATE_AMPED )
		else if ( CapturePoint_GetCaptureProgress( hardpoint.ent ) > 1.0 )
			CapturePoint_SetState( hardpoint.ent, CAPTURE_POINT_STATE_AMPING )
	}
	else if ( ( occupation & IMC_HOLD ) != 0 )
	{
		CapturePoint_SetCappingTeam( hardpoint.ent, TEAM_IMC )
		if ( CapturePoint_GetCaptureProgress( hardpoint.ent ) < 1.0 )
			CapturePoint_SetState( hardpoint.ent, CAPTURE_POINT_STATE_CAPPING )
		else if ( CapturePoint_GetCaptureProgress( hardpoint.ent ) == 1.0 )
			CapturePoint_SetState( hardpoint.ent, CAPTURE_POINT_STATE_CAPTURED )
		else if ( CapturePoint_GetCaptureProgress( hardpoint.ent ) >= 2.0 )
			CapturePoint_SetState( hardpoint.ent, CAPTURE_POINT_STATE_AMPED )
		else if ( CapturePoint_GetCaptureProgress( hardpoint.ent ) > 1.0 )
			CapturePoint_SetState( hardpoint.ent, CAPTURE_POINT_STATE_AMPING )
	}
	else if ( ( occupation & MILTIA_HOLD ) != 0 )
	{
		CapturePoint_SetCappingTeam( hardpoint.ent, TEAM_MILITIA )
		if ( CapturePoint_GetCaptureProgress( hardpoint.ent ) < 1.0 )
			CapturePoint_SetState( hardpoint.ent, CAPTURE_POINT_STATE_CAPPING )
		else if ( CapturePoint_GetCaptureProgress( hardpoint.ent ) == 1.0 )
			CapturePoint_SetState( hardpoint.ent, CAPTURE_POINT_STATE_CAPTURED )
		else if ( CapturePoint_GetCaptureProgress( hardpoint.ent ) >= 2.0 )
			CapturePoint_SetState( hardpoint.ent, CAPTURE_POINT_STATE_AMPED )
		else if ( CapturePoint_GetStartProgress( hardpoint.ent ) > 1.0 )
			CapturePoint_SetState( hardpoint.ent, CAPTURE_POINT_STATE_AMPING )
	}
	else if ( currentTeam == TEAM_UNASSIGNED )
	{
		if( CapturePoint_GetCaptureProgress( hardpoint.ent ) <= 1.001 ) // unamp
		{
			CapturePoint_SetState( hardpoint.ent, CAPTURE_POINT_STATE_HALTED )
		}
		else
		{
			CapturePoint_SetState( hardpoint.ent, CAPTURE_POINT_STATE_SELF_UNAMPING )
		}
	}
	else
	{
		if( CapturePoint_GetCaptureProgress( hardpoint.ent ) <=1.001 ) // unamp
		{
			if ( currentState == CAPTURE_POINT_STATE_AMPED ) // only play 2inactive animation if we were amped
				thread PlayAnim( hardpoint.prop, "mh_active_2_inactive" )
			CapturePoint_SetState( hardpoint.ent, CAPTURE_POINT_STATE_CAPTURED )
		}
	}
	
	// debugging ?
	int newState = hardpoint.ent.GetHardpointState()
	int newTeam = CapturePoint_GetOwningTeam( hardpoint.ent )

	if ( oldState == CAPTURE_POINT_STATE_UNASSIGNED && newState == CAPTURE_POINT_STATE_CAPPING )
	{
		// starting capture of uncaptured point
		printt( "starting capture of uncaptured point" )
	}
	else if ( oldState == CAPTURE_POINT_STATE_CAPPING && newState == CAPTURE_POINT_STATE_CAPTURED )
	{
		printt( "Owned Point was being captured, but got interrupted" )
	}
	else if ( oldState == CAPTURE_POINT_STATE_CAPPING && newState == CAPTURE_POINT_STATE_HALTED )
	{
		printt( "Unowned Point was being captured, but got interrupted" )
	}
	else if ( oldState == CAPTURE_POINT_STATE_AMPING && newState == CAPTURE_POINT_STATE_CAPTURED )
	{
		// completed capturing hardpoint
		printt( "Owned Point was being amped, but got interrupted" )
	}
	else if ( oldState == CAPTURE_POINT_STATE_CAPPING && newState == CAPTURE_POINT_STATE_AMPING && CapturePoint_GetStartProgress( hardpoint.ent ) == 1.0 )
	{
		// completed capturing hardpoint
		printt( "completed capturing hardpoint, going to amping automatically" )
	}
	else if ( oldState == CAPTURE_POINT_STATE_AMPING && newState == CAPTURE_POINT_STATE_AMPED )
	{
		printt( "completed amping hardpoint" )
	}
	else if ( oldState == CAPTURE_POINT_STATE_AMPED && newState == CAPTURE_POINT_STATE_SELF_UNAMPING )
	{
		printt( "naturally unamping unoccupied hardpoint" )
	}
	else if ( oldState == CAPTURE_POINT_STATE_SELF_UNAMPING && newState == CAPTURE_POINT_STATE_CAPPING )
	{
		//Started capping a point that was naturally unamping
		printt( "Started capping a point that was naturally unamping" )
	}

	else if ( oldState == CAPTURE_POINT_STATE_SELF_UNAMPING && newState == CAPTURE_POINT_STATE_CAPTURED )
	{
		//Started capping a point that was naturally unamping
		printt( "Point unamped all the way to normal capped" )

	}
	else if ( oldState == CAPTURE_POINT_STATE_CAPPING && newState == CAPTURE_POINT_STATE_SELF_UNAMPING )
	{
		printt( "Started manually unamping a point but got interrupted" )

	}
	else if ( oldState == CAPTURE_POINT_STATE_CAPPING && newState == CAPTURE_POINT_STATE_CAPPING )
	{
		// changed from owned by a team to neutral during capping
		printt( "changed from owned by a team to neutral during capping" )
	}
	else if ( oldState >= CAPTURE_POINT_STATE_CAPTURED && newState == CAPTURE_POINT_STATE_CAPPING )
	{
		// started capturing an unoccupied hardpoint
		printt( "started capturing an unoccupied hardpoint" )
	}
	//CAPTURE_POINT_STATE_HALTED only used when point is not owned by anyone
	/*else if ( oldState >= CAPTURE_POINT_STATE_CAPTURED && newState == CAPTURE_POINT_STATE_HALTED )
	{
		// started capturing an occupied hardpoint
		printt( "started capturing an occupied hardpoint" )
	}
	else if ( oldState == CAPTURE_POINT_STATE_HALTED && newState == CAPTURE_POINT_STATE_CAPTURED )
	{
		// prevented neutralizing of a captured hardpoint
		printt( "prevented neutralizing of a captured hardpoint" )
	}*/
	else if ( oldState == CAPTURE_POINT_STATE_HALTED && newState == CAPTURE_POINT_STATE_CAPPING )
	{
		// cleared hardpoint OR exited and re-entered hardpoint
		printt( "cleared hardpoint OR exited and re-entered hardpoint. Hardpoint was previously unowned" )
	}
	else if ( oldState == newState )
	{
		// nothing happens
	}
	else
	{
		printt( "unhandled state change" )
	}

	// update old stuff
	hardpoint.oldTeam = hardpoint.ent.GetTeam();
	hardpoint.oldState = hardpoint.ent.GetHardpointState();
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
