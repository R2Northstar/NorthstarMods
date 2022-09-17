global function StartPoint_Setup_Beacon_Ending
global function StartPoint_Beacon_Ending
global function BeaconEndingInit
global function CreateMaltaWithWarpIn

const WARP_IN_FX = $"veh_carrier_warp_full"
const TABLET_MODEL = $"models/props/tablet/tablet.mdl"

void function BeaconEndingInit()
{
	// replace with trinity models
	PrecacheModel( TRINITY_MDL )
	PrecacheModel( TABLET_MODEL )
	PrecacheParticleSystem( WARP_IN_FX )
}

void function StartPoint_Setup_Beacon_Ending( entity player )
{
}

void function StartPoint_Beacon_Ending( entity player )
{
	if ( !IsAlive( player ) )
		return
	if ( !IsAlive( player.GetPetTitan() ) )
		return
	TakeAllWeapons( player )

	StopMusicTrack( "music_beacon_29a_elevator" )
	PlayMusic( "music_beacon_30_sarahdebrief" )
	FlagSet( "CenterDoorsOpen" )

	thread ExtraEndingEnts()

	// kill enemies
	array<entity> npcs = GetNPCArrayOfEnemies( GetPlayerArray()[0].GetTeam() )
	foreach ( n in npcs )
	{
		if ( n.GetClassName() == "npc_bullseye" )
			continue

		if ( !IsAlive( n ) )
			continue
		n.Die()
	}

	DisableFriendlyHighlight()
	ScreenFadeFromBlack( player )

	Remote_CallFunction_NonReplay( player, "ServerCallback_CallInTheFleet" )
	player.SetInvulnerable()

	entity node = GetEntByScriptName( "ZiplineMomentNode" )
	vector origin = node.GetOrigin()
	vector angles = node.GetAngles()
	entity bt = player.GetPetTitan()

	thread PlayAnim( bt, "BT_beacon_cavalry_arrives_IDLE", node )

	FirstPersonSequenceStruct playerIdleSequence
	playerIdleSequence.blendTime = 0.0
	playerIdleSequence.origin = origin
	playerIdleSequence.angles = angles
	playerIdleSequence.attachment = "hijack"
	playerIdleSequence.useAnimatedRefAttachment = true
	playerIdleSequence.firstPersonAnim = "ptpov_beacon_cavalry_arrives_player_alt_IDLE"
	playerIdleSequence.thirdPersonAnim = "pt_beacon_cavalry_arrives_player_alt_IDLE"
	playerIdleSequence.viewConeFunction = ViewConeEnding

	thread FirstPersonSequence( playerIdleSequence, player, bt )
	WaitFrame()
	player.SetAngles( < -50,52,0> )
	player.SetAnimNearZ( 1 )

	entity soldier = CreateNPC( "npc_soldier", TEAM_MILITIA, origin, angles )
	DispatchSpawn( soldier )
	soldier.DisableHibernation()

	entity sarah = CreateNPCFromAISettings( "npc_soldier_hero_sarah", TEAM_MILITIA, origin, angles )
	SetTargetName( sarah, "Sarah" )
	DispatchSpawn( sarah )
	sarah.DisableHibernation()

	entity tablet = CreatePropDynamic( TABLET_MODEL )
	tablet.SetParent( soldier, "PROPGUN", false, 0 )
	TakeAllWeapons( soldier )

	thread PlayAnim( soldier, "pt_beacon_cavalry_arrives_grunt_IDLE", node )
	thread PlayAnim( sarah, "pt_beacon_cavalry_arrives_sarah_IDLE", node )


	wait 3.0

	wait 0.2 // sv/cl view delay
	wait 0.4 // sv/cl view delay

	float delay = 6.2
	/*
	thread DelayedVoiceOver( delay, sarah,	"diag_sp_sendSignal_BE411_12_01_mcor_sarah" ); 	delay += 6.1	// BT-7274, your data recorder says your original Pilot was KIA...
	thread DelayedVoiceOver( delay, bt,		"diag_sp_sendSignal_BE411_13_01_mcor_bt" ); 	delay += 4.0	// Correct. Captain Tai Lastimosa was killed in action.
	thread DelayedVoiceOver( delay, bt,		"diag_sp_sendSignal_BE411_14_01_mcor_bt" ); 	delay += 4.1	// I am now linked to an Acting Pilot - Rifleman Jack Cooper.
	thread DelayedVoiceOver( delay, sarah,	"diag_sp_sendSignal_BE411_15_01_mcor_sarah" ); 	delay += 3.6	// Wait a minute - Lastimosa linked you to a Rifleman?
	thread DelayedVoiceOver( delay, bt,		"diag_sp_sendSignal_BE411_16_01_mcor_bt" ); 	delay += 3.0	// Yes. He had no other options.
	thread DelayedVoiceOver( delay, sarah,	"diag_sp_sendSignal_BE411_19a_01_mcor_sarah" ); delay += 3.5	// Understood, we'll get you transfered to a fully qualified Pilot.
	thread DelayedVoiceOver( delay, bt,		"diag_sp_sendSignal_BE411_20_01_mcor_bt" ); 	delay += 6.80	// Objection: Cooper is my Pilot. Our combat effectiveness rating now exceeds ninety percent.
	thread DelayedVoiceOver( delay, bt,		"diag_sp_sendSignal_BE411_21a_01_mcor_bt" ); 	delay += 4.2	// Request permission to retain this link.
	thread DelayedVoiceOver( delay, sarah,	"diag_sp_sendSignal_BE411_22a_01_mcor_sarah" ); delay += 6.95	// *sigh*...You're lucky our backs are up against the wall, BT. Permission granted.
	thread DelayedVoiceOver( delay, sarah,	"diag_sp_sendSignal_BE411_23_01_mcor_sarah" ); 	delay += 4.4	// That's high praise coming from a machine, Cooper.
	thread DelayedVoiceOver( delay, sarah,	"diag_sp_sendSignal_BE411_27a_01_mcor_sarah" ); delay += 6.0	// Thanks to your scan data of the Ark, we’ve tracked its energy signature to an IMC base right here on Typhon.
	thread DelayedVoiceOver( delay, sarah,	"diag_sp_sendSignal_BE411_27b_01_mcor_sarah" ); delay += 4.0	// We don’t have much time! Let’s go!
	*/
	float endTime = Time() + delay

	entity dropship = CreateNPC( "npc_dropship", TEAM_MILITIA, origin, angles )
	DispatchSpawn( dropship )
	dropship.DisableHibernation()

	thread PlayAnim( bt, "BT_beacon_cavalry_arrives", node )
	thread PlayAnimTeleport( dropship, "ds_beacon_cavalry_arrives", node )
	thread PlayAnim( sarah, "pt_beacon_cavalry_arrives_sarah", node )
	thread PlayAnim( soldier, "pt_beacon_cavalry_arrives_grunt", node )

	FirstPersonSequenceStruct playerSequence
	playerSequence.blendTime = 0.0
	playerSequence.origin = origin
	playerSequence.angles = angles
	playerSequence.attachment = "hijack"
	playerSequence.useAnimatedRefAttachment = true
	playerSequence.firstPersonAnim = "ptpov_beacon_cavalry_arrives_player_alt"
	playerSequence.thirdPersonAnim = "pt_beacon_cavalry_arrives_player_alt"
	playerSequence.viewConeFunction = ViewConeEndingInstant


	thread PlayerViewConeBlend( player )
	/*
	thread PlayAnim( player.GetFirstPersonProxy(), playerSequence.firstPersonAnim, playerSequence.origin, playerSequence.angles, playerSequence.blendTime )

	player.PlayerCone_SetLerpTime( 0.0 )
	player.PlayerCone_SetMinYaw( -80 )
	player.PlayerCone_SetMaxYaw( 80 )
	player.PlayerCone_SetMinPitch( -50 )
	player.PlayerCone_SetMaxPitch( 50 )
	wait 2.5

	waitthread PlayAnim( player, playerSequence.thirdPersonAnim, playerSequence.origin, playerSequence.angles, playerSequence.blendTime )
	*/
	vector playerView = player.GetViewVector()
	vector playerAngles = VectorToAngles( playerView )
	thread FirstPersonSequence( playerSequence, player, bt )
	player.SetAngles( playerAngles )

	float fadeTime = 1.3
	float animationDuration = player.GetSequenceDuration( playerSequence.thirdPersonAnim ) - fadeTime
	float dialogueDuration = ( endTime - Time() ) - 1.2
	wait max( animationDuration, dialogueDuration ) // which is longer?

	ScreenFade( player, 0, 0, 1, 255, fadeTime, 999, FFADE_OUT | FFADE_PURGE )
	wait fadeTime

	if ( LockedView() )
		WaitForever()

	ScreenFadeToBlackForever( player )

	MuteAll( player, 1 )
	// need global audio fader

	string mapName = "sp_tday"
	string startPointEnum = "Intro"
	// work around for bug where these client commands don't always take effect in time
	ExecuteLoadingClientCommands_SetStartPoint( mapName, GetStartPointIndexFromName( mapName, startPointEnum ) )
	wait 2.5

	PickStartPoint_NoFadeOut_NoPilotWeaponCarryover( mapName, startPointEnum )
}

void function DelayedVoiceOver( float delay, entity actor, string line )
{
	actor.EndSignal( "OnDeath" )
	int frameNum = int( delay * 30.0 )
	printt( "event AE_CL_PLAYSOUND " + frameNum + " \"" + line + "\"" )
	wait delay

	EmitSoundOnEntity( actor, line )
	printt( line )
}

void function ViewConeEnding( entity player )
{
	if ( !player.IsPlayer() )
		return
	player.PlayerCone_SetLerpTime( 0.5 )

	player.PlayerCone_FromAnim()
	player.PlayerCone_SetMinYaw( -15 )
	player.PlayerCone_SetMaxYaw( 15 )
	player.PlayerCone_SetMinPitch( -15 )
	player.PlayerCone_SetMaxPitch( 0 )

	if ( LockedView() )
	{
		player.PlayerCone_SetMinYaw( 0 )
		player.PlayerCone_SetMaxYaw( 0 )
		player.PlayerCone_SetMinPitch( 0 )
		player.PlayerCone_SetMaxPitch( 0 )
	}
}

void function ViewConeEndingInstant( entity player )
{
	if ( !player.IsPlayer() )
		return
	player.PlayerCone_SetLerpTime( 0.0 )

	player.PlayerCone_FromAnim()
	player.PlayerCone_SetMinYaw( -15 )
	player.PlayerCone_SetMaxYaw( 15 )
	player.PlayerCone_SetMinPitch( -15 )
	player.PlayerCone_SetMaxPitch( 15 )

	if ( LockedView() )
	{
		player.PlayerCone_SetMinYaw( 0 )
		player.PlayerCone_SetMaxYaw( 0 )
		player.PlayerCone_SetMinPitch( 0 )
		player.PlayerCone_SetMaxPitch( 0 )
	}
}




void function PlayerViewConeBlend( entity player )
{
	wait 6
	printt( "BLEND TO ZERO" )
	player.PlayerCone_SetLerpTime( 2.0 )

	player.PlayerCone_FromAnim()
	player.PlayerCone_SetMinYaw( -15 )
	player.PlayerCone_SetMaxYaw( 15 )
	player.PlayerCone_SetMinPitch( -15 )
	player.PlayerCone_SetMaxPitch( 15 )

	if ( LockedView() )
	{
		player.PlayerCone_SetMinYaw( 0 )
		player.PlayerCone_SetMaxYaw( 0 )
		player.PlayerCone_SetMinPitch( 0 )
		player.PlayerCone_SetMaxPitch( 0 )
	}
}

/*
{
"angles" "0 154.641 0"
"classname" "prop_dynamic"
"collide_ai" "0"
"collide_titan" "0"
"model" "models/vehicles_r2/spacecraft/malta/malta_flying_hero_farlod.mdl"
"origin" "36584.3 2206.38 9380"
"script_name" "malta"
}
*/

void function CreateMaltaWithWarpIn( vector origin, vector angles, float delay = 0 )
{
	entity ship = CreatePropDynamic( TRINITY_MDL, origin, angles )

	#if DEV
	if ( !( "t" in level ) )
		level.t <- null
	if ( IsValid( level.t ) )
	{
		entity oldShip = expect entity( level.t )
		oldShip.Destroy()
	}

	level.t = ship
	#endif

	ship.EnableRenderAlways()
	ship.SetFadeDistance( 80000 )

	ship.EndSignal( "OnDestroy" )

	vector finalPos = ship.GetOrigin()
	vector fwd = AnglesToForward( ship.GetAngles() )
	fwd += <0,0,0.5>
	vector offset = 8000*fwd
	ship.SetOrigin( ship.GetOrigin() - offset )

	ship.EndSignal( "OnDestroy" )
	ship.Hide()

	ship.DisableHibernation()

	EmitSoundOnEntity( ship, "AngelCity_Scr_MegaCarrierWarpIn" )

	if ( delay > 0 )
		wait delay

	EmitSoundAtPosition( TEAM_UNASSIGNED, origin, "dropship_warpin" )
	wait ( 2.0 )
	entity fx = PlayFX( WARP_IN_FX, origin, angles )
	fx.DisableHibernation()
	fx.FXEnableRenderAlways()

	wait 0.95

	ship.Show()

	/*

	entity mover = CreateScriptMover()
	mover.SetAngles( ship.GetAngles() )
	mover.SetOrigin( ship.GetOrigin() )
	ship.SetParent( mover )

	vector oldAngles = mover.GetAngles()

	mover.NonPhysicsRotateTo( mover.GetAngles() + < -5,0,0 >, 10, 2, 2 )
	wait 3.0
	mover.NonPhysicsMoveTo( finalPos, 15, 2, 2 )
	wait 5.0
	mover.NonPhysicsRotateTo( oldAngles, 15, 2, 2 )

	wait 5

	mover.Destroy()
	*/
}

bool function LockedView()
{
	return GetBugReproNum() == 99
}

void function ExtraEndingEnts()
{
	wait 1

	entity spawner = GetSpawnerByScriptName( "ending_vanguard_spawner" )
	entity titan = spawner.SpawnEntity()
	DispatchSpawn( titan )
	titan.SetSkin( 1 )
	titan.SetValidHealthBarTarget( false )
	titan.SetTitle( "" )
	titan.DisableHibernation()

	wait 6.5

	foreach ( spawner in GetSpawnerArrayByScriptName( "ending_first_runner_spawner" ) )
	{
		entity grunt = spawner.SpawnEntity()
		DispatchSpawn( grunt )
		grunt.DisableHibernation()
		grunt.kv.alwaysalert = 1
		grunt.EnableNPCMoveFlag( NPCMF_PREFER_SPRINT )
	}

	wait 28.5

	foreach ( spawner in GetSpawnerArrayByScriptName( "ending_runner_spawner" ) )
	{
		entity grunt = spawner.SpawnEntity()
		DispatchSpawn( grunt )
		grunt.DisableHibernation()
		grunt.kv.alwaysalert = 1
		grunt.EnableNPCMoveFlag( NPCMF_PREFER_SPRINT )
	}

}