#if SERVER
global function gf 			// get file
global function CreditsInit
global function ClientCallback_CreditsOver
#endif

#if CLIENT
global function ServerCallback_AddCredits
global function ServerCallback_DoF_SetNearDepth
global function ServerCallback_DoF_SetFarDepth
global function ServerCallback_DoF_SetNearDepthToDefault
global function ServerCallback_DoF_SetFarDepthToDefault
global function ServerCallback_EnableFog
global function ServerCallback_DisableFog
global function ServerCallback_CsmTexelScale
global function ServerCallback_FOVLock
#endif

enum eCredits
{
	DIRECTORS,
	ENGINEERS,
	DESIGNERS,
	ARTISTS,
	VFX,
	ANIMATORS,
	AUDIO,
	OFFICERS,
	PRODUCTION,
	ADMIN,
	IT,
	MUSIC,
	WRITING,
	CAST,
	QA,
	PLAYFIGHT,
	DARKBURN,
	MULTIPLAY,
	SPOV,
	GLASSEGG,
	VIRTUOS,
	ADDITIONAL,
	THANKS,
	BABIES
	EA,
	MICROSOFT,
	SONY,
	LEGAL,
	END,
	NORTHSTAR_DEVS,

	COLUMN_CENTER,
	COLUMN_LEFT,
	COLUMN_RIGHT,
	ACTORS_INSTANT,

	ACTOR_COOPER,
	ACTOR_BT,
	ACTOR_OG,
	ACTOR_SARAH,
	ACTOR_BARKER,
	ACTOR_BLISK,
	ACTOR_BARKER,
	ACTOR_GATES,
	ACTOR_BEAR,
	ACTOR_DAVIS,
	ACTOR_DROZ,
	ACTOR_MARDER,
	ACTOR_ASH,
	ACTOR_KANE,
	ACTOR_RICHTER,
	ACTOR_VIPER,
	ACTOR_SLONE,
}

const float COLUMN_DEFAULT = 999
const float COLUMN_CENTER = 0.0
const float COLUMN_LEFT = -0.2
const float COLUMN_RIGHT = 0.2
const float BLACKSCREEN_DELAY = 2.5

global function Credits_MapInit
void function Credits_MapInit()
{
	#if SERVER
		Credits_Init_Server()
	#endif

	#if CLIENT
		Credits_Init_Client()
	#endif
}

/************************************************************************************************\

███████╗███████╗██████╗ ██╗   ██╗███████╗██████╗
██╔════╝██╔════╝██╔══██╗██║   ██║██╔════╝██╔══██╗
███████╗█████╗  ██████╔╝██║   ██║█████╗  ██████╔╝
╚════██║██╔══╝  ██╔══██╗╚██╗ ██╔╝██╔══╝  ██╔══██╗
███████║███████╗██║  ██║ ╚████╔╝ ███████╗██║  ██║
╚══════╝╚══════╝╚═╝  ╚═╝  ╚═══╝  ╚══════╝╚═╝  ╚═╝

\************************************************************************************************/
#if SERVER
struct MyFile
{
	entity camera
	vector skycam_origin
	vector skycam_angles
}
MyFile file

const FX_DLIGHT_COCKPIT = $"P_veh_int_Dlight_cockpit_cred"
const asset PLAYER_WIND_FX 	= $"P_wind_cruising"

const asset CROW_HERO_MODEL = $"models/vehicle/crow_dropship/crow_dropship_hero.mdl"

const float PLAYBACKRATE = 0.2
const asset MODEL_JACK 				= $"models/humans/heroes/mlt_hero_jack.mdl"
const asset MODEL_BT 				= $"models/titans/buddy/titan_buddy_skyway.mdl"
const asset MODEL_OG 				= $"models/humans/heroes/mlt_hero_lastimosa.mdl"
const asset HELMET_MODEL 			= $"models/Humans/heroes/mlt_hero_lastimosa_helmet.mdl"
const asset MODEL_SARAH 			= $"models/Humans/heroes/mlt_hero_sarah.mdl"
const asset MODEL_R101 				= $"models/weapons/r101/w_r101.mdl"
const asset MODEL_MASTIFF			= $"models/weapons/mastiff_stgn/w_mastiff.mdl"
const asset MODEL_DAVIS 			= $"models/humans/pilots/sp_medium_stalker_m.mdl"
const asset MODEL_DROZ 				= $"models/humans/pilots/sp_medium_reaper_m.mdl"
const asset MODEL_GATES 			= $"models/humans/pilots/sp_medium_geist_f.mdl"
const asset MODEL_BEAR 				= $"models/humans/pilots/sp_heavy_roog_m.mdl"
const asset MODEL_MALTA 			= $"models/vehicles_r2/spacecraft/malta/malta_flying_hero_farlod.mdl"
const asset BT_EYE_CASE_MODEL 		= $"models/Titans/buddy/titan_buddy_hatch_eye.mdl"
const asset MODEL_BARKER 			= $"models/humans/heroes/mlt_hero_barker.mdl"
const asset MODEL_FLASK 			= $"models/props/flask/prop_flask_animated.mdl"
const asset MODEL_BLISK 			= $"models/Humans/heroes/imc_hero_blisk.mdl"
const asset COMBAT_KNIFE 			= $"models/weapons/combat_knife/w_combat_knife.mdl"
const asset MARDER_HOLOGRAM_MODEL 	= $"models/humans/heroes/imc_hero_marder.mdl"
const asset MARVIN_MODEL 			= $"models/robots/marvin/marvin.mdl"
const asset MODEL_ASH 				= $"models/humans/heroes/imc_hero_ash.mdl"
const asset MODEL_KANE 				= $"models/humans/heroes/imc_hero_kane.mdl"
const asset MODEL_RICHTER			= $"models/humans/heroes/imc_hero_richter.mdl"
const asset MODEL_VIPER 			= $"models/humans/heroes/imc_hero_viper.mdl"
const asset MODEL_SLONE 			= $"models/humans/heroes/imc_hero_slone.mdl"
const asset MODEL_EARTH_PIECE 		= $"models/levels_terrain/sp_skyway/skyway_floating_earth_large_grass_01.mdl"
const asset MODEL_SEAT 				= $"models/utilities/power_cell_64_single_01.mdl"
const asset MODEL_CROW_X 			= $"models/vehicle/crow_dropship/crow_dropship_xsmall.mdl"
const asset MODEL_TRINITY_X			= $"models/vehicles_r2/spacecraft/trinity/Trinity_xsmall.mdl"

void function Credits_Init_Server()
{
	FlagInit( "CreditsOver" )

	PrecacheModel( MODEL_JACK )
	PrecacheModel( MODEL_BT )
	PrecacheModel( MODEL_OG )
	PrecacheModel( HELMET_MODEL )
	PrecacheModel( MODEL_SARAH )
	PrecacheModel( MODEL_R101 )
	PrecacheModel( MODEL_MASTIFF )
	PrecacheModel( TEAM_MIL_GRUNT_MODEL_LMG )
	PrecacheModel( TEAM_MIL_GRUNT_MODEL_RIFLE )
	PrecacheModel( TEAM_MIL_GRUNT_MODEL_SHOTGUN )
	PrecacheModel( TEAM_MIL_GRUNT_MODEL_SMG )
	PrecacheModel( MODEL_DAVIS )
	PrecacheModel( MODEL_DROZ )
	PrecacheModel( MODEL_GATES )
	PrecacheModel( MODEL_BEAR )
	PrecacheModel( MODEL_MALTA )
	PrecacheModel( BT_EYE_CASE_MODEL )
	PrecacheModel( MODEL_BARKER )
	PrecacheModel( CROW_HERO_MODEL )
	PrecacheModel( MODEL_FLASK )
	PrecacheModel( MODEL_BLISK )
	PrecacheModel( COMBAT_KNIFE )
	PrecacheModel( MARDER_HOLOGRAM_MODEL )
	PrecacheModel( MARVIN_MODEL )
	PrecacheModel( MODEL_ASH )
	PrecacheModel( MODEL_KANE )
	PrecacheModel( MODEL_RICHTER )
	PrecacheModel( MODEL_VIPER )
	PrecacheModel( MODEL_SLONE )
	PrecacheModel( MODEL_EARTH_PIECE )
	PrecacheModel( MODEL_SEAT )
	PrecacheModel( MODEL_CROW_X )
	PrecacheModel( MODEL_TRINITY_X )

	PrecacheParticleSystem( $"P_xo_jet_fly_large" )
	PrecacheParticleSystem(	$"P_xo_jet_fly_small" )
	PrecacheParticleSystem( FX_DLIGHT_COCKPIT )
	PrecacheParticleSystem( PLAYER_WIND_FX )

	AddClientCommandCallback( "Client_CreditsOver", ClientCallback_CreditsOver )

	AddStartPoint( "--- CREDITS ---",	Credits_Main, 			null, 					Credits_Skip )

	AddStartPoint( "sarah intro",		SarahIntro_Main )
//	AddStartPoint( "meet sarah",		MeetSarah_Main )
//	AddStartPoint( "hand shake",		HandShake_Main )

	AddStartPoint( "walk",				Walk_Main )
	AddStartPoint( "hug",				Hug_Main )
	AddStartPoint( "cheer",				Cheer_Main )
//	AddStartPoint( "meet bear",			MeetBear_Main )
	AddStartPoint( "actor jack cooper",	Actor_Cooper_Main )

	AddStartPoint( "actor BT / OG",		Actor_BTOG_Main )
//	AddStartPoint( "actor BT Alt",		Actor_BTAlt_Main )
//	AddStartPoint( "actor OG Alt",		Actor_OGAlt_Main )

	AddStartPoint( "actor blisk",		Actor_Blisk_Main )
	AddStartPoint( "actor sarah",		Actor_Sarah_Main )
	AddStartPoint( "actor bosses", 		Actor_Bosses_main )
	AddStartPoint( "actor marder", 		Actor_Marder_Main )
	AddStartPoint( "actors 6-4",		Actor_The64_Main )
	AddStartPoint( "actor barker",		Actor_Barker_Main )

	AddStartPoint( "new BT",			NewBT_Main )
	AddStartPoint( "board ship",		BoardShip_Main )
	AddStartPoint( "final image",		FinalImage_Main )
}

MyFile function gf()
{
	return file
}

void function Credits_Main( entity player )
{
	CreditsInit( player )
	wait 2
	
	foreach( player in GetPlayerArray() )
		Credits_Part1( player )

	wait 8.5 //don't change this wait
}

void function Credits_Part1( entity player )
{
	Remote_CallFunction_NonReplay( player, "ServerCallback_AddCredits", eCredits.DIRECTORS )
	Remote_CallFunction_NonReplay( player, "ServerCallback_AddCredits", eCredits.ENGINEERS )
	Remote_CallFunction_NonReplay( player, "ServerCallback_AddCredits", eCredits.DESIGNERS )
	Remote_CallFunction_NonReplay( player, "ServerCallback_AddCredits", eCredits.ARTISTS )
	Remote_CallFunction_NonReplay( player, "ServerCallback_AddCredits", eCredits.VFX )
	Remote_CallFunction_NonReplay( player, "ServerCallback_AddCredits", eCredits.ANIMATORS )
	Remote_CallFunction_NonReplay( player, "ServerCallback_AddCredits", eCredits.AUDIO )
	Remote_CallFunction_NonReplay( player, "ServerCallback_AddCredits", eCredits.OFFICERS )
	Remote_CallFunction_NonReplay( player, "ServerCallback_AddCredits", eCredits.PRODUCTION )
	Remote_CallFunction_NonReplay( player, "ServerCallback_AddCredits", eCredits.ADMIN )
	Remote_CallFunction_NonReplay( player, "ServerCallback_AddCredits", eCredits.IT )
	Remote_CallFunction_NonReplay( player, "ServerCallback_AddCredits", eCredits.QA )
	Remote_CallFunction_NonReplay( player, "ServerCallback_AddCredits", eCredits.WRITING )
}

void function Credits_Part2( entity player )
{
	Remote_CallFunction_NonReplay( player, "ServerCallback_AddCredits", eCredits.CAST )
	Remote_CallFunction_NonReplay( player, "ServerCallback_AddCredits", eCredits.MUSIC )
	Remote_CallFunction_NonReplay( player, "ServerCallback_AddCredits", eCredits.PLAYFIGHT )
	Remote_CallFunction_NonReplay( player, "ServerCallback_AddCredits", eCredits.DARKBURN )
	Remote_CallFunction_NonReplay( player, "ServerCallback_AddCredits", eCredits.MULTIPLAY )
	Remote_CallFunction_NonReplay( player, "ServerCallback_AddCredits", eCredits.SPOV )
	Remote_CallFunction_NonReplay( player, "ServerCallback_AddCredits", eCredits.GLASSEGG )
	Remote_CallFunction_NonReplay( player, "ServerCallback_AddCredits", eCredits.VIRTUOS )
	Remote_CallFunction_NonReplay( player, "ServerCallback_AddCredits", eCredits.ADDITIONAL )
	Remote_CallFunction_NonReplay( player, "ServerCallback_AddCredits", eCredits.THANKS )
	Remote_CallFunction_NonReplay( player, "ServerCallback_AddCredits", eCredits.BABIES )
	Remote_CallFunction_NonReplay( player, "ServerCallback_AddCredits", eCredits.EA )

	#if DURANGO_PROG
		Remote_CallFunction_NonReplay( player, "ServerCallback_AddCredits", eCredits.MICROSOFT )
	#elseif PS4_PROG
		Remote_CallFunction_NonReplay( player, "ServerCallback_AddCredits", eCredits.SONY )
	#endif

	Remote_CallFunction_NonReplay( player, "ServerCallback_AddCredits", eCredits.LEGAL )
	Remote_CallFunction_NonReplay( player, "ServerCallback_AddCredits", eCredits.NORTHSTAR_DEVS )
	Remote_CallFunction_NonReplay( player, "ServerCallback_AddCredits", eCredits.END )
}

void function Credits_Skip( entity player )
{
	CreditsInit( player )
}

void function EmptyFunc()
{

}

void function GivePlayerCreditsCam( entity player )
{
	NormalSkywaySetup( player )
	
	entity skycam = GetEnt( "skybox_cam_skyway_harmony" )
	player.SetSkyCamera( skycam )

	TakeAllWeapons( player )
	player.Hide()

	player.SetParent( file.camera, "", false, 0.0 )
	ViewConeZero( player )
	player.SetViewEntity( file.camera, true )
	player.SetAnimNearZ( 4 )

	Remote_CallFunction_NonReplay( player, "ServerCallback_FOVLock" )
	Remote_CallFunction_NonReplay( player, "ServerCallback_DisableFog" )
	ScreenFadeToBlackForever( player, 0 )
}

void function CreditsInit( entity player )
{
	FlagClear( "TR_StartBurn" )
	FlagClear( "TR_Burn_Stage_1" )
	FlagClear( "TR_Burn_Stage_2" )
	FlagClear( "TR_Burn_Stage_3" )
	FlagClear( "TR_Burn_Stage_4" )
	FlagClear( "TR_Burn_Stage_5" )
	FlagClear( "TR_Burn_Stage_Black" )

	SetCutSceneEvent( EmptyFunc, GivePlayerCreditsCam, EmptyFunc )
	
	foreach( player in GetPlayerArray() )
		NormalSkywaySetup( player )

	entity skycam = GetEnt( "skybox_cam_skyway_harmony" )
	file.skycam_origin = skycam.GetOrigin()
	file.skycam_angles = skycam.GetAngles()
	
	foreach( player in GetPlayerArray() )
		player.SetSkyCamera( skycam )

	vector origin = skycam.GetOrigin()
	origin -= < 438, 673, -220 >

	GetEnt( "skybox_cam_skyway_harmony" ).SetOrigin( origin )
	GetEnt( "skybox_cam_skyway_harmony" ).SetAngles( <0,0,0> )
	
	foreach( player in GetPlayerArray() )
	{
		TakeAllWeapons( player )
		player.Hide()
	}
	
	foreach( player in GetPlayerArray() )
	{
		if ( IsValid( player.GetPetTitan() ) )
		{
			player.GetPetTitan().SetOrigin( <0,0,0> )
			player.GetPetTitan().SetEfficientMode( true )
			player.GetPetTitan().Hide()
			player.GetPetTitan().TakeActiveWeapon()
		}
	}

	file.camera = CreateScriptMover( player.GetOrigin(), player.GetAngles() )
	foreach( player in GetPlayerArray() )
	{
		player.SetParent( file.camera, "", false, 0.0 )
		ViewConeZero( player )
		player.SetViewEntity( file.camera, true )
		player.SetAnimNearZ( 4 )
	}

	{
		array<entity> allprops = GetEntArrayByClass_Expensive( "prop_dynamic" )
		foreach ( p in allprops )
		{
			if ( p.GetModelName() == MODEL_CROW_X )
				p.Destroy()
			if ( p.GetModelName() == MODEL_TRINITY_X )
				p.Destroy()
		}
	}

	array<entity> props = GetEntArrayByScriptName( "harmony_props" )
	foreach ( p in props )
		p.Destroy()

	//DebugDrawCircleOnEnt( file.camera, 40, 255, 0, 0, 1000 )
	foreach( player in GetPlayerArray() )
	{
		Remote_CallFunction_NonReplay( player, "ServerCallback_FOVLock" )
		Remote_CallFunction_NonReplay( player, "ServerCallback_DisableFog" )
		ScreenFadeToBlackForever( player, 0 )
	}

	EmitSoundOnEntity( player, "Credits_fadeout_to_music" )
}

/************************************************************************************************\

███╗   ███╗███████╗███████╗████████╗    ███████╗ █████╗ ██████╗  █████╗ ██╗  ██╗
████╗ ████║██╔════╝██╔════╝╚══██╔══╝    ██╔════╝██╔══██╗██╔══██╗██╔══██╗██║  ██║
██╔████╔██║█████╗  █████╗     ██║       ███████╗███████║██████╔╝███████║███████║
██║╚██╔╝██║██╔══╝  ██╔══╝     ██║       ╚════██║██╔══██║██╔══██╗██╔══██║██╔══██║
██║ ╚═╝ ██║███████╗███████╗   ██║       ███████║██║  ██║██║  ██║██║  ██║██║  ██║
╚═╝     ╚═╝╚══════╝╚══════╝   ╚═╝       ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝

\************************************************************************************************/
void function SarahIntro_Main( entity player )
{
	waitthread MeetSarah_Main( player )
	waitthread HandShake_Main( player )
}

entity function CreateJack()
{
	entity jack = CreatePropDynamic( MODEL_JACK )
	int bodyGroupIndex = jack.FindBodyGroup( "head" )
	jack.SetBodygroup( bodyGroupIndex, 1 )

	return jack
}

void function MeetSarah_Main( entity player )
{
	foreach( player in GetPlayerArray() )
	{
		Remote_CallFunction_NonReplay( player, "ServerCallback_DoF_SetFarDepth", 1024, 2048 )
		Remote_CallFunction_NonReplay( player, "ServerCallback_DoF_SetNearDepthToDefault" )

		ScreenFadeFromBlack( player, 4.0, 2.0 )
	}

	entity jack = CreateJack()
	entity helmet = CreateExpensiveScriptMoverModel( HELMET_MODEL )
	entity node = GetEntByScriptName( "meetSarah1" )

	helmet.SetParent( jack, "L_HAND" )
	helmet.NonPhysicsSetMoveModeLocal( true )
	helmet.NonPhysicsRotateTo( < 100,0,180>, 0.1, 0, 0 )
	helmet.NonPhysicsMoveTo( < 2,-4,0>, 0.1, 0, 0 )

	jack.Anim_PlayWithRefPoint( "jack_O2_briefing_crew_L", node.GetOrigin(), node.GetAngles(), 0 )
	jack.Anim_SetInitialTime( 9.3 )
	jack.SetPlaybackRate( PLAYBACKRATE )

	entity sarah = CreatePropDynamic( MODEL_SARAH )
	entity node2 = GetEntByScriptName( "meetSarah2" )
	entity anchor = CreateOwnedScriptMover( node2 )
	sarah.SetParent( anchor )
	anchor.SetOrigin( anchor.GetOrigin() + < -16,0,0 > )

	sarah.Anim_Play( "pt_beacon_cavalry_arrives_grunt" )
	sarah.Anim_SetInitialTime( 46.0 )
	sarah.SetPlaybackRate( PLAYBACKRATE )

	file.camera.SetOrigin( node.GetOrigin() + < 10, 15, 60 > )
	file.camera.SetAngles( node.GetAngles() )
	file.camera.NonPhysicsMoveTo( node.GetOrigin() + < -15, 90, 60 >, 30, 0, 0 )

	wait 8

	thread MeetSarah_JackHead( jack )
	anchor.NonPhysicsMoveTo( anchor.GetOrigin() + < 16,0,0 >, 6, 0, 6 )
	
	foreach( player in GetPlayerArray() )
		Remote_CallFunction_NonReplay( player, "ServerCallback_DoF_SetNearDepth", 0, 24 )

	wait 8
	float fadeout = 4.0
	foreach( player in GetPlayerArray() )
		ScreenFadeToBlackForever( player, fadeout )

	wait fadeout + 0.1

	file.camera.NonPhysicsStop()

	jack.Destroy()
	helmet.Destroy()
	sarah.Destroy()
	anchor.Destroy()
}

void function MeetSarah_JackHead( entity jack )
{
	int yawID 		= jack.LookupPoseParameterIndex( "head_yaw" )
	int pitchID 	= jack.LookupPoseParameterIndex( "head_pitch" )
	jack.SetPoseParameterOverTime( pitchID, 18.5, 3.0 )

	jack.SetPoseParameterOverTime( yawID, -8.0, 5.0 )

	wait 5.5

	jack.SetPoseParameterOverTime( yawID, 15.4, 2.5 )
}


/************************************************************************************************\

██╗  ██╗ █████╗ ███╗   ██╗██████╗     ███████╗██╗  ██╗ █████╗ ██╗  ██╗███████╗
██║  ██║██╔══██╗████╗  ██║██╔══██╗    ██╔════╝██║  ██║██╔══██╗██║ ██╔╝██╔════╝
███████║███████║██╔██╗ ██║██║  ██║    ███████╗███████║███████║█████╔╝ █████╗
██╔══██║██╔══██║██║╚██╗██║██║  ██║    ╚════██║██╔══██║██╔══██║██╔═██╗ ██╔══╝
██║  ██║██║  ██║██║ ╚████║██████╔╝    ███████║██║  ██║██║  ██║██║  ██╗███████╗
╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝     ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝

\************************************************************************************************/
void function HandShake_Main( entity player )
{
	wait BLACKSCREEN_DELAY

	entity node = GetEntByScriptName( "meetSarahshake" )
	entity jack = CreateJack()
	entity helmet = CreatePropDynamic( HELMET_MODEL )
	entity sarah = CreatePropDynamic( MODEL_SARAH )
	entity anchor = CreateOwnedScriptMover( node )

	jack.SetParent( anchor )
	helmet.SetParent( anchor )
	sarah.SetParent( anchor )

	float initialTime = 14.3
	jack.Anim_Play( "jack_intro_scene_OG" )
	jack.Anim_SetInitialTime( initialTime )
	jack.SetPlaybackRate( PLAYBACKRATE )

	helmet.Anim_Play( "helmet_intro_scene_OG" )
	helmet.Anim_SetInitialTime( initialTime )
	helmet.SetPlaybackRate( PLAYBACKRATE )

	sarah.Anim_Play( "sa_intro_scene_Anderson" )
	sarah.Anim_SetInitialTime( initialTime )
	sarah.SetPlaybackRate( PLAYBACKRATE )

	file.camera.NonPhysicsStop()
	file.camera.SetOrigin( node.GetOrigin() + < -30, -40, 40 > )
	file.camera.SetAngles( AnglesCompose( node.GetAngles(), < -15,130,0 > ) )

	file.camera.NonPhysicsMoveTo( file.camera.GetOrigin() + < 0, 90, 0 >, 15, 0, 0 )
	file.camera.NonPhysicsRotateTo( file.camera.GetAngles() + < 0, -100, 0 >, 15, 0, 0 )
	
	foreach( player in GetPlayerArray() )
	{
		Remote_CallFunction_NonReplay( player, "ServerCallback_DoF_SetFarDepth", 300, 1000 )
		Remote_CallFunction_NonReplay( player, "ServerCallback_DoF_SetNearDepthToDefault" )

		ScreenFadeFromBlack( player, 4.0, 0.3 )
	}

	wait 7

	float fadeout = 4.0
	foreach( player in GetPlayerArray() )
		ScreenFadeToBlackForever( player, fadeout )

	wait fadeout + 0.1

	file.camera.NonPhysicsStop()

	jack.Destroy()
	helmet.Destroy()
	sarah.Destroy()
	anchor.Destroy()
}

/************************************************************************************************\

██╗    ██╗ █████╗ ██╗     ██╗  ██╗
██║    ██║██╔══██╗██║     ██║ ██╔╝
██║ █╗ ██║███████║██║     █████╔╝
██║███╗██║██╔══██║██║     ██╔═██╗
╚███╔███╔╝██║  ██║███████╗██║  ██╗
 ╚══╝╚══╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝

\************************************************************************************************/
void function Walk_Main( entity player )
{
	wait BLACKSCREEN_DELAY

	entity grunt1 = CreatePropDynamic( TEAM_MIL_GRUNT_MODEL_LMG )
	entity grunt2 = CreatePropDynamic( TEAM_MIL_GRUNT_MODEL_RIFLE )
	entity grunt3 = CreatePropDynamic( TEAM_MIL_GRUNT_MODEL_SHOTGUN )
	entity grunt4 = CreatePropDynamic( TEAM_MIL_GRUNT_MODEL_SMG )
	entity grunt5 = CreatePropDynamic( TEAM_MIL_GRUNT_MODEL_LMG )
	entity grunt6 = CreatePropDynamic( TEAM_MIL_GRUNT_MODEL_RIFLE )
	entity grunt7 = CreatePropDynamic( TEAM_MIL_GRUNT_MODEL_SHOTGUN )
	entity grunt8 = CreatePropDynamic( TEAM_MIL_GRUNT_MODEL_SMG )
	entity grunt9 = CreatePropDynamic( TEAM_MIL_GRUNT_MODEL_SHOTGUN )

	entity node = GetEntByScriptName( "walknode2" )
	entity anchor1 = CreateOwnedScriptMover( node )
	entity anchor2 = CreateScriptMover( node.GetOrigin() + <64,0,0>, node.GetAngles() )
	entity anchor3 = CreateScriptMover( node.GetOrigin() + < -120,-10,0>, node.GetAngles() + <0,45,0> )

	grunt1.SetParent( anchor1 )
	grunt1.Anim_Play( "pt_control_roomC_gruntA_scene" )
	grunt1.Anim_SetInitialTime( 21.5 )
	grunt1.SetPlaybackRate( PLAYBACKRATE )

	grunt2.SetParent( anchor1 )
	grunt2.Anim_Play( "pt_control_roomC_gruntB_scene" )
	grunt2.Anim_SetInitialTime( 21.5 )
	grunt2.SetPlaybackRate( PLAYBACKRATE )

	grunt3.SetParent( anchor2 )
	grunt3.Anim_Play( "pt_control_roomC_gruntC_scene" )
	grunt3.Anim_SetInitialTime( 21.5 )
	grunt3.SetPlaybackRate( PLAYBACKRATE )

	grunt4.SetParent( anchor3 )
	grunt4.Anim_Play( "pt_control_roomC_gruntD_scene" )
	grunt4.Anim_SetInitialTime( 21.5 )
	grunt4.SetPlaybackRate( PLAYBACKRATE )

	entity anchor4 = CreateScriptMover( anchor2.GetOrigin() + < -140,20,0>, node.GetAngles() + <0,-45,0> )
	entity anchor5 = CreateScriptMover( anchor3.GetOrigin() + < -80,-30,0>, node.GetAngles() + <0,30,0> )
	entity anchor6 = CreateScriptMover( node.GetOrigin() + < 110,0,0>, node.GetAngles() + <0,-30,0> )

	grunt5.SetParent( anchor4 )
	grunt5.Anim_Play( "pt_control_roomC_gruntA_scene" )
	grunt5.Anim_SetInitialTime( 20.5 )
	grunt5.SetPlaybackRate( PLAYBACKRATE )

	grunt6.SetParent( anchor4 )
	grunt6.Anim_Play( "pt_control_roomC_gruntB_scene" )
	grunt6.Anim_SetInitialTime( 20.5 )
	grunt6.SetPlaybackRate( PLAYBACKRATE )

	grunt7.SetParent( anchor5 )
	grunt7.Anim_Play( "pt_control_roomC_gruntA_scene" )
	grunt7.Anim_SetInitialTime( 22.0 )
	grunt7.SetPlaybackRate( PLAYBACKRATE )

	grunt8.SetParent( anchor5 )
	grunt8.Anim_Play( "pt_control_roomC_gruntB_scene" )
	grunt8.Anim_SetInitialTime( 22.0 )
	grunt8.SetPlaybackRate( PLAYBACKRATE )

	grunt9.SetParent( anchor6 )
	grunt9.Anim_Play( "pt_control_roomC_gruntD_scene" )
	grunt9.Anim_SetInitialTime( 22.0 )
	grunt9.SetPlaybackRate( PLAYBACKRATE )

	node = GetEntByScriptName( "walknode" )
	entity jack = CreateJack()
	entity anchor = CreateOwnedScriptMover( node )

	entity helmet = CreateExpensiveScriptMoverModel( HELMET_MODEL )
	helmet.SetParent( jack, "L_HAND" )
	helmet.NonPhysicsSetMoveModeLocal( true )
	helmet.NonPhysicsRotateTo( < 60,-90,0>, 0.1, 0, 0 )
	helmet.NonPhysicsMoveTo( < 5,3,0>, 0.1, 0, 0 )

	jack.SetParent( anchor )
	jack.Anim_Play( "patrol_walk_bored" )
	jack.SetPlaybackRate( PLAYBACKRATE )

	file.camera.NonPhysicsStop()
	file.camera.SetOrigin( jack.GetOrigin() + <0,-40,13> )
	file.camera.SetAngles( jack.GetAngles() + <0,-90,0> )
	file.camera.SetParent( jack, "OFFSET", true, 0 )
	
	foreach( player in GetPlayerArray() )
	{
		Remote_CallFunction_NonReplay( player, "ServerCallback_DoF_SetFarDepth", 60, 128 )
		Remote_CallFunction_NonReplay( player, "ServerCallback_DoF_SetNearDepthToDefault" )

		ScreenFadeFromBlack( player, 4.0, 0.3 )
	}

	wait 16

	float fadeout = 4.0
	foreach( player in GetPlayerArray() )
		ScreenFadeToBlackForever( player, fadeout )

	wait fadeout + 0.1

	file.camera.ClearParent()
	file.camera.NonPhysicsStop()

	jack.Destroy()
	helmet.Destroy()
	anchor.Destroy()
	anchor1.Destroy()
	anchor2.Destroy()
	anchor3.Destroy()
	anchor4.Destroy()
	anchor5.Destroy()
	anchor6.Destroy()
}

/************************************************************************************************\

██╗  ██╗██╗   ██╗ ██████╗
██║  ██║██║   ██║██╔════╝
███████║██║   ██║██║  ███╗
██╔══██║██║   ██║██║   ██║
██║  ██║╚██████╔╝╚██████╔╝
╚═╝  ╚═╝ ╚═════╝  ╚═════╝

\************************************************************************************************/
void function Hug_Main( entity player )
{
	wait BLACKSCREEN_DELAY

	entity grunt1 = CreatePropDynamic( TEAM_MIL_GRUNT_MODEL_SMG )
	entity grunt2 = CreatePropDynamic( TEAM_MIL_GRUNT_MODEL_RIFLE )
	entity grunt3 = CreatePropDynamic( TEAM_MIL_GRUNT_MODEL_SHOTGUN )
	entity grunt4 = CreatePropDynamic( TEAM_MIL_GRUNT_MODEL_LMG )
	entity grunt5 = CreatePropDynamic( TEAM_MIL_GRUNT_MODEL_SMG )
	entity grunt6 = CreatePropDynamic( TEAM_MIL_GRUNT_MODEL_RIFLE )
	entity grunt7 = CreatePropDynamic( TEAM_MIL_GRUNT_MODEL_SHOTGUN )
	entity grunt8 = CreatePropDynamic( TEAM_MIL_GRUNT_MODEL_LMG )
	entity grunt9 = CreatePropDynamic( TEAM_MIL_GRUNT_MODEL_SMG )
	entity grunt10 = CreatePropDynamic( TEAM_MIL_GRUNT_MODEL_RIFLE )

	entity jack = CreateJack()

	entity helmet = CreateExpensiveScriptMoverModel( HELMET_MODEL )
	helmet.SetParent( jack, "L_HAND" )
	helmet.NonPhysicsSetMoveModeLocal( true )
	helmet.NonPhysicsRotateTo( < 0,45,0>, 0.1, 0, 0 )
	helmet.NonPhysicsMoveTo( < 0,-4,0>, 0.1, 0, 0 )

	entity node = GetEntByScriptName( "hugnode" )
	entity anchor = CreateOwnedScriptMover( node )

	float initialTime = 22.0

	grunt1.SetParent( anchor )
	grunt1.Anim_Play( "pt_control_roomC_gruntA_scene_credits" )
	grunt1.Anim_SetInitialTime( initialTime )
	grunt1.SetPlaybackRate( PLAYBACKRATE )

	jack.SetParent( anchor )
	jack.Anim_Play( "jack_control_roomC_gruntB_scene" )
	jack.Anim_SetInitialTime( initialTime )
	jack.SetPlaybackRate( PLAYBACKRATE )

	vector right = node.GetRightVector() * 70
	vector forward = node.GetForwardVector() * 70
	grunt2.SetOrigin( node.GetOrigin() + forward + right )
	grunt2.SetAngles( AnglesCompose( node.GetAngles(), <0,200,0> ) )
	grunt2.Anim_Play( "pt_lecture_teacher_react_credits" )
	grunt2.SetPlaybackRate( PLAYBACKRATE )

	right = node.GetRightVector() * 195
	forward = node.GetForwardVector() * 100
	grunt3.SetOrigin( node.GetOrigin() + forward + right )
	grunt3.SetAngles( AnglesCompose( node.GetAngles(), <0,120,0> ) )
	grunt3.Anim_Play( "React_salute_raisefist" )
	grunt3.SetPlaybackRate( PLAYBACKRATE * 0.75 )

	right = node.GetRightVector() * 80
	forward = node.GetForwardVector() * -15
	grunt4.SetOrigin( node.GetOrigin() + forward + right )
	grunt4.SetAngles( AnglesCompose( node.GetAngles(), <0,90,0> ) )
	grunt4.Anim_Play( "React_salute_titan_thumbsup" )
	grunt4.SetPlaybackRate( PLAYBACKRATE * 0.6 )

	right = node.GetRightVector() * 180
	forward = node.GetForwardVector() * 20
	entity anchor2 = CreateScriptMover( node.GetOrigin() + forward + right, AnglesCompose( node.GetAngles(), <0,90,0> ) )
	grunt5.SetParent( anchor2 )
	grunt5.Anim_Play( "pt_control_roomC_gruntA_scene" )
	grunt5.Anim_SetInitialTime( 21.5 )
	grunt5.SetPlaybackRate( PLAYBACKRATE )
	grunt6.SetParent( anchor2 )
	grunt6.Anim_Play( "pt_control_roomC_gruntB_scene" )
	grunt6.Anim_SetInitialTime( 21.5 )
	grunt6.SetPlaybackRate( PLAYBACKRATE )

	right = node.GetRightVector() * 370
	forward = node.GetForwardVector() * 130
	entity anchor3 = CreateScriptMover( node.GetOrigin() + forward + right, AnglesCompose( node.GetAngles(), <0,140,0> ) )
	grunt7.SetParent( anchor3 )
	grunt7.Anim_Play( "pt_control_roomC_gruntD_scene" )
	grunt7.Anim_SetInitialTime( 21.2 )
	grunt7.SetPlaybackRate( PLAYBACKRATE )

	right = node.GetRightVector() * -90
	forward = node.GetForwardVector() * -120
	entity anchor4 = CreateScriptMover( node.GetOrigin() + forward + right, AnglesCompose( node.GetAngles(), <0,-130,0> ) )
	grunt8.SetParent( anchor4 )
	grunt8.Anim_Play( "pt_control_roomB_spotter_scene" )
	grunt8.Anim_SetInitialTime( 0.8 )
	grunt8.SetPlaybackRate( PLAYBACKRATE )

	right = node.GetRightVector() * 200
	forward = node.GetForwardVector() * -120
	entity anchor5 = CreateScriptMover( node.GetOrigin() + forward + right, AnglesCompose( node.GetAngles(), <0,-130,0> ) )
	grunt9.SetParent( anchor5 )
	grunt9.Anim_Play( "pt_control_roomB_spotter_scene" )
	grunt9.Anim_SetInitialTime( 0.7 )
	grunt9.SetPlaybackRate( PLAYBACKRATE )

	right = node.GetRightVector() * 410
	forward = node.GetForwardVector() * -50
	entity anchor6 = CreateScriptMover( node.GetOrigin() + forward + right, AnglesCompose( node.GetAngles(), <0,-120,0> ) )
	grunt10.SetParent( anchor6 )
	grunt10.Anim_Play( "pt_control_roomB_gruntB_salute" )
	grunt10.Anim_SetInitialTime( 1.0 )
	grunt10.SetPlaybackRate( PLAYBACKRATE )

	thread Hug_Heads( jack, grunt1, grunt2, grunt3, grunt9 )

	right = node.GetRightVector() * -70
	forward = node.GetForwardVector() * 20
	vector backward = node.GetForwardVector() * -40
	file.camera.NonPhysicsStop()
	file.camera.SetOrigin( node.GetOrigin() + right + forward + <0,0,55> )
	file.camera.SetAngles( node.GetAngles() + <0,-85,0> )

	file.camera.NonPhysicsMoveTo( node.GetOrigin() + right + backward + <0,0,70>, 25, 0, 0 )
	file.camera.NonPhysicsRotateTo( node.GetAngles() + < 10, -65, 0 >, 25, 0, 0 )
	
	foreach( player in GetPlayerArray() )
	{
		Remote_CallFunction_NonReplay( player, "ServerCallback_DoF_SetFarDepth", 64, 300 )
		Remote_CallFunction_NonReplay( player, "ServerCallback_DoF_SetNearDepthToDefault" )

		ScreenFadeFromBlack( player, 4.0, 0.3 )
	}
	wait 19

	float fadeout = 4.0
	foreach( player in GetPlayerArray() )
		ScreenFadeToBlackForever( player, fadeout )

	wait fadeout + 0.1

	file.camera.NonPhysicsStop()
	jack.Destroy()
	grunt1.Destroy()
	grunt2.Destroy()
	grunt3.Destroy()
	grunt4.Destroy()
	grunt5.Destroy()
	grunt6.Destroy()
	grunt7.Destroy()
	grunt8.Destroy()
	grunt9.Destroy()
	grunt10.Destroy()
	anchor.Destroy()
	anchor2.Destroy()
	anchor3.Destroy()
	anchor4.Destroy()
	anchor5.Destroy()
	anchor6.Destroy()
}

void function Hug_Heads( entity jack, entity grunt1, entity grunt2, entity grunt3, entity grunt9 )
{
	int yawJack 	= jack.LookupPoseParameterIndex( "head_yaw" )
	int pitchJack 	= jack.LookupPoseParameterIndex( "head_pitch" )
	int yawGrunt 	= grunt1.LookupPoseParameterIndex( "head_yaw" )
	int pitchGrunt 	= grunt1.LookupPoseParameterIndex( "head_pitch" )
	int yawGrunt2 	= grunt2.LookupPoseParameterIndex( "head_yaw" )
	int pitchGrunt2	= grunt2.LookupPoseParameterIndex( "head_pitch" )

	jack.SetPoseParameterOverTime( yawJack, -20, 0.1 )
	jack.SetPoseParameterOverTime( pitchJack, 50, 0.1 )
	grunt2.SetPoseParameterOverTime( yawGrunt2, 50, 10 )

	wait 4
	jack.SetPoseParameterOverTime( yawJack, 0, 2.0 )
	jack.SetPoseParameterOverTime( pitchJack, 0, 2.0 )

	wait 5.5
	grunt9.Anim_Play( "pt_control_roomB_spotter_scene" )
	grunt9.Anim_SetInitialTime( 0.4 )
	grunt9.SetPlaybackRate( PLAYBACKRATE * 0.8 )

	wait 2.5
	grunt3.Anim_Play( "React_salute_raisefist" )
	grunt3.SetPlaybackRate( PLAYBACKRATE * 0.75 )

	wait 1.5
	grunt1.SetPoseParameterOverTime( yawGrunt, -20, 1.0 )
	grunt1.SetPoseParameterOverTime( pitchGrunt, 50, 1.0 )
}

/************************************************************************************************\

 ██████╗██╗  ██╗███████╗███████╗██████╗
██╔════╝██║  ██║██╔════╝██╔════╝██╔══██╗
██║     ███████║█████╗  █████╗  ██████╔╝
██║     ██╔══██║██╔══╝  ██╔══╝  ██╔══██╗
╚██████╗██║  ██║███████╗███████╗██║  ██║
 ╚═════╝╚═╝  ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝

\************************************************************************************************/
void function Cheer_Main( entity player )
{
	wait BLACKSCREEN_DELAY

	entity node = GetEntByScriptName( "cheernode" )
	entity jack = CreateJack()
	entity anchor0 = CreateOwnedScriptMover( node )

	entity helmet = CreateExpensiveScriptMoverModel( HELMET_MODEL )
	helmet.SetParent( jack, "L_HAND" )
	helmet.NonPhysicsSetMoveModeLocal( true )
	helmet.NonPhysicsRotateTo( < -60,-90,180>, 0.1, 0, 0 )
	helmet.NonPhysicsMoveTo( < -2,-3,2>, 0.1, 0, 0 )

	jack.SetParent( anchor0 )
	jack.Anim_Play( "credits_walking_jack" )
	jack.SetPlaybackRate( PLAYBACKRATE )

	file.camera.NonPhysicsStop()
	file.camera.SetOrigin( jack.GetOrigin() + <20,-50,60> )
	file.camera.SetAngles( jack.GetAngles() + <0,90,0> )
	file.camera.SetParent( jack, "OFFSET", true, 0 )

	entity grunt1 = CreatePropDynamic( TEAM_MIL_GRUNT_MODEL_SMG )
	entity anchor1 = CreateScriptMover( node.GetOrigin() + < -150, -25, 5 >, <0,40,0> )
	grunt1.SetParent( anchor1 )
	grunt1.Anim_Play( "pt_VDU_dispatcher_drinking_point" )
	grunt1.Anim_SetInitialTime( 1.3 )
	grunt1.SetPlaybackRate( PLAYBACKRATE )

	entity grunt2 = CreatePropDynamic( TEAM_MIL_GRUNT_MODEL_LMG )
	entity anchor2 = CreateScriptMover( node.GetOrigin() + < -110, -30, 10 >, <0,130,0> )
	anchor2.NonPhysicsRotateTo( <0,90,0>, 15, 6, 4 )
	grunt2.SetParent( anchor2 )
	grunt2.Anim_Play( "pt_VDU_dispatcher_drinking_typing" )
	grunt2.Anim_SetInitialTime( 1.5 )
	grunt2.SetPlaybackRate( PLAYBACKRATE )

	entity grunt3 = CreatePropDynamic( TEAM_MIL_GRUNT_MODEL_RIFLE )
	entity anchor3 = CreateScriptMover( node.GetOrigin() + < -50,-12,-8 >, <0,180,0> )
	grunt3.SetParent( anchor3 )
	grunt3.Anim_Play( "pt_civ_walk_drink" )
	grunt3.Anim_SetInitialTime( 0.1 )
	grunt3.SetPlaybackRate( PLAYBACKRATE )


	entity grunt4 = CreatePropDynamic( TEAM_MIL_GRUNT_MODEL_RIFLE )
	entity anchor4 = CreateScriptMover( node.GetOrigin() + < -130,30,0 >, <0,-90,0> )
	grunt4.SetParent( anchor4 )
	grunt4.Anim_Play( "React_salute" )
	grunt4.Anim_SetInitialTime( 0.1 )
	grunt4.SetPlaybackRate( PLAYBACKRATE )

	entity grunt5 = CreatePropDynamic( TEAM_MIL_GRUNT_MODEL_SMG )
	entity anchor5 = CreateScriptMover( node.GetOrigin() + < -35,-5,-4 >, <0,90,0> )
	grunt5.SetParent( anchor5 )
	grunt5.Anim_Play( "React_salute_raisefist" )
	grunt5.Anim_SetInitialTime( 0.1 )
	grunt5.SetPlaybackRate( PLAYBACKRATE )

	entity grunt6 = CreatePropDynamic( TEAM_MIL_GRUNT_MODEL_SMG )
	entity anchor6 = CreateScriptMover( node.GetOrigin() + < -200,30,4 >, <0,-45,0> )
	grunt6.SetParent( anchor6 )
	grunt6.Anim_Play( "React_salute_raisefist" )
	grunt6.Anim_SetInitialTime( 0.3 )
	grunt6.SetPlaybackRate( PLAYBACKRATE * 0.7 )
	grunt6.SetPoseParameterOverTime( grunt6.LookupPoseParameterIndex( "head_yaw" ), -50, 7 )
	anchor6.NonPhysicsRotateTo( <0,0,0>, 7, 0, 0 )

	entity grunt7 = CreatePropDynamic( TEAM_MIL_GRUNT_MODEL_SHOTGUN )
	entity anchor7 = CreateScriptMover( node.GetOrigin() + < 0,-200,0 >, <0,40,0> )
	grunt7.SetParent( anchor7 )
	grunt7.Anim_Play( "pt_control_roomB_spotter_scene" )
	grunt7.Anim_SetInitialTime( 1.2 )
	grunt7.SetPlaybackRate( PLAYBACKRATE )
	grunt7.SetPoseParameterOverTime( grunt7.LookupPoseParameterIndex( "head_yaw" ), 50, 15 )
	grunt7.SetPoseParameterOverTime( grunt7.LookupPoseParameterIndex( "head_pitch" ), 50, 0.1 )

	entity grunt8 = CreatePropDynamic( TEAM_MIL_GRUNT_MODEL_RIFLE )
	AddFlask( grunt8 )
	entity anchor8 = CreateScriptMover( node.GetOrigin() + < -50,0,70 >, <0,-110,0> )
	grunt8.SetParent( anchor8 )
	grunt8.Anim_Play( "commander_MP_flyin_Barker_credits" )
	grunt8.Anim_SetInitialTime( 7.2 )
	grunt8.SetPlaybackRate( PLAYBACKRATE )

	entity grunt9 = CreatePropDynamic( TEAM_MIL_GRUNT_MODEL_LMG )
	AddFlask( grunt9 )
	entity anchor9 = CreateScriptMover( node.GetOrigin() + < -60,0,65 >, <0,-75,0> )
	grunt9.SetParent( anchor9 )
	grunt9.Anim_Play( "commander_MP_flyin_Barker_credits" )
	grunt9.Anim_SetInitialTime( 10 )
	grunt9.SetPlaybackRate( PLAYBACKRATE )

	entity grunt10 = CreatePropDynamic( TEAM_MIL_GRUNT_MODEL_SHOTGUN )
	entity anchor10 = CreateScriptMover( node.GetOrigin() + <10,40,-4 >, <0,-120,0> )
	grunt10.SetParent( anchor10 )
	grunt10.Anim_Play( "pt_control_roomC_gruntD_scene" )
	grunt10.Anim_SetInitialTime( 19 )
	grunt10.SetPlaybackRate( PLAYBACKRATE )

	entity gun4 = CreatePropDynamic( MODEL_R101, <0,0,0> )
	gun4.SetParent( grunt4, "PROPGUN" )
	entity gun10 = CreatePropDynamic( MODEL_R101, <0,0,0> )
	gun10.SetParent( grunt10, "PROPGUN" )

	thread Cheer_Heads( jack, grunt2, grunt4, grunt5 )

	foreach( player in GetPlayerArray() )
	{
		Remote_CallFunction_NonReplay( player, "ServerCallback_DoF_SetFarDepth", 64, 80 )
		Remote_CallFunction_NonReplay( player, "ServerCallback_DoF_SetNearDepth", 30, 38 )
		ScreenFadeFromBlack( player, 4.0, 0.3 )
	}

	wait 16

	float fadeout = 4.0
	foreach( player in GetPlayerArray() )
		ScreenFadeToBlackForever( player, fadeout )

	wait fadeout + 0.1

	file.camera.ClearParent()
	file.camera.NonPhysicsStop()

	jack.Destroy()
	helmet.Destroy()
	grunt1.Destroy()
	grunt2.Destroy()
	grunt3.Destroy()
	grunt4.Destroy()
	grunt5.Destroy()
	grunt6.Destroy()
	grunt7.Destroy()
	grunt8.Destroy()
	grunt9.Destroy()
	grunt10.Destroy()
	anchor0.Destroy()
	anchor1.Destroy()
	anchor2.Destroy()
	anchor3.Destroy()
	anchor4.Destroy()
	anchor5.Destroy()
	anchor6.Destroy()
	anchor7.Destroy()
	anchor8.Destroy()
	anchor9.Destroy()
	anchor10.Destroy()
}

void function Cheer_Heads( entity jack, entity grunt2, entity grunt4, entity grunt5 )
{
	int yawJack 	= jack.LookupPoseParameterIndex( "head_yaw" )
	int pitchJack 	= jack.LookupPoseParameterIndex( "head_pitch" )
	int yawgrunt2 	= grunt2.LookupPoseParameterIndex( "head_yaw" )
	int yawgrunt4 	= grunt4.LookupPoseParameterIndex( "head_yaw" )
	int pitchgrunt4 = grunt4.LookupPoseParameterIndex( "head_pitch" )

	jack.SetPoseParameterOverTime( pitchJack, 50, 5 )
	grunt2.SetPoseParameterOverTime( yawgrunt2, 5, 5 )

	wait 5
	grunt2.SetPoseParameterOverTime( yawgrunt2, -20, 5 )
	grunt2.SetPoseParameterOverTime( yawgrunt4, 50, 5 )

	wait 3
	grunt4.Anim_Play( "React_salute_headnod" )
	grunt4.Anim_SetInitialTime( 0.8 )
	grunt4.SetPlaybackRate( PLAYBACKRATE )
	grunt4.SetPoseParameterOverTime( yawgrunt4, 50, 5 )
	grunt4.SetPoseParameterOverTime( pitchgrunt4, 20, 0.1 )

	wait 3
	grunt5.Anim_Play( "React_salute_raisefist" )
	grunt5.Anim_SetInitialTime( 0.1 )
	grunt5.SetPlaybackRate( PLAYBACKRATE )

	wait 3
	jack.SetPoseParameterOverTime( pitchJack, -50, 5 )
}

/************************************************************************************************\

 █████╗  ██████╗████████╗ ██████╗ ██████╗      ██████╗ ██████╗  ██████╗ ██████╗ ███████╗██████╗
██╔══██╗██╔════╝╚══██╔══╝██╔═══██╗██╔══██╗    ██╔════╝██╔═══██╗██╔═══██╗██╔══██╗██╔════╝██╔══██╗
███████║██║        ██║   ██║   ██║██████╔╝    ██║     ██║   ██║██║   ██║██████╔╝█████╗  ██████╔╝
██╔══██║██║        ██║   ██║   ██║██╔══██╗    ██║     ██║   ██║██║   ██║██╔═══╝ ██╔══╝  ██╔══██╗
██║  ██║╚██████╗   ██║   ╚██████╔╝██║  ██║    ╚██████╗╚██████╔╝╚██████╔╝██║     ███████╗██║  ██║
╚═╝  ╚═╝ ╚═════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝     ╚═════╝ ╚═════╝  ╚═════╝ ╚═╝     ╚══════╝╚═╝  ╚═╝

\************************************************************************************************/
void function Actor_Cooper_Main( entity player )
{
	wait BLACKSCREEN_DELAY

	entity jack = CreateJack()
	entity helmet = CreateExpensiveScriptMoverModel( HELMET_MODEL )
	entity node = GetEntByScriptName( "actorCooper" )
	entity anchor = CreateOwnedScriptMover( node )

	jack.SetParent( anchor )
	jack.Anim_Play( "jack_O2_briefing_crew_R" )
	jack.Anim_SetInitialTime( 22 )
	jack.SetPlaybackRate( PLAYBACKRATE * 0.8 )
	jack.SetPoseParameterOverTime( jack.LookupPoseParameterIndex( "head_pitch" ), 5, 5.0 )

	file.camera.SetOrigin( node.GetOrigin() + < 15,-30,60> )
	file.camera.SetAngles( <5,60,0> )
	file.camera.NonPhysicsMoveTo( node.GetOrigin() + < 5,-60,60>, 10, 0, 0 )

	helmet.SetParent( jack, "R_HAND" )
	helmet.NonPhysicsSetMoveModeLocal( true )
	helmet.NonPhysicsSetRotateModeLocal( true )
	helmet.NonPhysicsRotateTo( < 90,0,0>, 0.1, 0, 0 )
	helmet.NonPhysicsMoveTo( < 2,4,-2>, 0.1, 0, 0 )
	foreach( player in GetPlayerArray() )
	{
		Remote_CallFunction_NonReplay( player, "ServerCallback_DoF_SetFarDepth", 100, 200 )
		Remote_CallFunction_NonReplay( player, "ServerCallback_DoF_SetNearDepthToDefault" )

		ScreenFadeFromBlack( player, 2.0, 0.3 )
	}
	thread Actor_Cooper_Stuff( jack, player )
	wait 7.5

	float fadeout = 1.0
	foreach( player in GetPlayerArray() )
		ScreenFadeToBlackForever( player, fadeout )

	wait fadeout + 0.1

	file.camera.ClearParent()
	file.camera.NonPhysicsStop()

	jack.Destroy()
	anchor.Destroy()
}

void function Actor_Cooper_Stuff( entity jack, entity player )
{
	jack.SetPoseParameterOverTime( jack.LookupPoseParameterIndex( "head_yaw" ), -5.0, 1.0 )
	wait 1
	foreach( player in GetPlayerArray() )
		Remote_CallFunction_NonReplay( player, "ServerCallback_AddCredits", eCredits.ACTOR_COOPER )

	wait 4
	jack.SetPoseParameterOverTime( jack.LookupPoseParameterIndex( "head_yaw" ), 18.5, 3.0 )
}

/************************************************************************************************\

 █████╗  ██████╗████████╗ ██████╗ ██████╗     ██████╗ ████████╗
██╔══██╗██╔════╝╚══██╔══╝██╔═══██╗██╔══██╗    ██╔══██╗╚══██╔══╝
███████║██║        ██║   ██║   ██║██████╔╝    ██████╔╝   ██║
██╔══██║██║        ██║   ██║   ██║██╔══██╗    ██╔══██╗   ██║
██║  ██║╚██████╗   ██║   ╚██████╔╝██║  ██║    ██████╔╝   ██║
╚═╝  ╚═╝ ╚═════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝    ╚═════╝    ╚═╝

\************************************************************************************************/
void function Actor_BTOG_Main( entity player )
{
	waitthread Actor_BTAlt_Main( player )
	waitthread Actor_OGAlt_Main( player )
}

void function Actor_BTAlt_Main( entity player )
{
	wait 0.5
	entity node 	= GetEntByScriptName( "btaltnode" )
	entity anchor 	= CreateScriptMover( node.GetOrigin(), node.GetAngles() )
	entity jack 	= CreateJack()
	entity bt 		= CreatePropDynamic( MODEL_BT )
	entity eyecase 	= CreateExpensiveScriptMoverModel( BT_EYE_CASE_MODEL )

	float initialTime = 1.0

	jack.SetParent( anchor )
	jack.Anim_Play( "jack_intro_scene_OG" )
	jack.Anim_SetInitialTime( initialTime )
	jack.SetPlaybackRate( PLAYBACKRATE )

	bt.SetParent( anchor )
	bt.Anim_Play( "BT_intro_scene_OG_credits" )
	bt.Anim_SetInitialTime( initialTime )
	bt.SetPlaybackRate( PLAYBACKRATE )
	bt.Hide()

	eyecase.SetParent( bt, "EYEGLOW" )
	eyecase.NonPhysicsSetMoveModeLocal( true )
	eyecase.NonPhysicsSetRotateModeLocal( true )
	eyecase.SetLocalOrigin( < -8,4,0> )
	eyecase.SetLocalAngles( <0,130,90> )

	vector right = node.GetRightVector() * -25
	vector forward = node.GetForwardVector() * 40
	file.camera.SetOrigin( node.GetOrigin() + right + forward + < 0,0,70 > )
	file.camera.SetAngles( AnglesCompose( node.GetAngles(), <40, -120, 0> ) )

	right = node.GetRightVector() * -15
	forward = node.GetForwardVector() * -25
	file.camera.NonPhysicsMoveTo( file.camera.GetOrigin() + right + forward, 15, 0, 0 )
	file.camera.NonPhysicsRotateTo( AnglesCompose( file.camera.GetAngles(), <0,20,0> ), 10,0,0 )
	
	foreach( player in GetPlayerArray() )
	{
		Remote_CallFunction_NonReplay( player, "ServerCallback_DoF_SetFarDepth", 40, 70 )
		ScreenFadeFromBlack( player, 2.0, 0.3 )
	}

	wait 1.5
	foreach( player in GetPlayerArray() )
		Remote_CallFunction_NonReplay( player, "ServerCallback_DoF_SetNearDepth", 10, 25, 1 )
	wait 3.5

	float fadeout = 0.2
	foreach( player in GetPlayerArray() )
		ScreenFadeToColor( player, 255, 255, 255, 255, fadeout, 999 )

	wait fadeout + 0.1

	file.camera.NonPhysicsStop()
	file.camera.ClearParent()

	jack.Destroy()
	eyecase.Destroy()
	bt.Show()

	//WHITE OUT TO MEMORY
	vector OFFSET = < 0, 8192, 0 >
	entity malta = CreateExpensiveScriptMoverModel( MODEL_MALTA, < -12416, -9320, -15488 > + OFFSET, < -3.5, 0, 10.5 > )

	int attachID = player.LookupAttachment( "REF" )
	entity fx = StartParticleEffectOnEntityWithPos_ReturnEntity( player, GetParticleSystemIndex( PLAYER_WIND_FX ), FX_PATTACH_POINT_FOLLOW_NOROTATE, attachID, <0,0,0>, <0,0,0> )
	
	foreach( player in GetPlayerArray() )
	{
		player.SetSkyCamera( GetEnt( "skybox_cam_level" ) )
		Remote_CallFunction_NonReplay( player, "ServerCallback_EnableFog" )
		Remote_CallFunction_NonReplay( player, "ServerCallback_DoF_SetFarDepth", 200, 2000 )
		Remote_CallFunction_NonReplay( player, "ServerCallback_DoF_SetNearDepthToDefault" )

		ScreenFadeFromColor( player, 255, 255, 255, 255, 1.0, 0.3 )
	}

	anchor.SetParent( malta )
	anchor.NonPhysicsSetMoveModeLocal( true )
	anchor.NonPhysicsSetRotateModeLocal( true )
	anchor.SetLocalOrigin( < 5200, -200, 932 > )
	anchor.SetLocalAngles( < -7, -40, 0 > )

	bt.SetParent( anchor )
	bt.Anim_Play( "bt_s2s_end_fight_finale_credits" )
	bt.Anim_SetInitialTime( 6.3 )
	bt.SetPlaybackRate( PLAYBACKRATE )
	SetTeam( bt, TEAM_MILITIA )

	file.camera.SetParent( anchor )
	file.camera.NonPhysicsSetMoveModeLocal( true )
	file.camera.NonPhysicsSetRotateModeLocal( true )
	file.camera.SetLocalOrigin( < -110, -160, 60> )
	file.camera.SetLocalAngles( < -15, 60, 0> )

	entity env_shake = CreateEntity( "env_shake" )
	env_shake.kv.amplitude = 1
	env_shake.kv.radius = 4098
	env_shake.kv.duration = 30
	env_shake.kv.frequency = 10
	env_shake.kv.spawnflags = SF_SHAKE_INAIR
	DispatchSpawn( env_shake )
	env_shake.SetOrigin( file.camera.GetOrigin() )

	EntFireByHandle( env_shake, "StartShake", "", 0, null, null )

	vector skyangles = GetEnt( "skybox_cam_level" ).GetAngles()
	entity skyAnchor = CreateOwnedScriptMover( GetEnt( "skybox_cam_level" ) )
	GetEnt( "skybox_cam_level" ).SetParent( skyAnchor )
	skyAnchor.SetAngles( < -10,0,-10> )
	skyAnchor.NonPhysicsRotateTo( < -5,0,30>, 10, 0, 0 )
	
	foreach( player in GetPlayerArray() )
		Remote_CallFunction_NonReplay( player, "ServerCallback_AddCredits", eCredits.ACTOR_BT )

	wait 7

	fadeout = 0.2
	foreach( player in GetPlayerArray() )
		ScreenFadeToColor( player, 255, 255, 255, 255, fadeout, 999 )

	wait fadeout + 0.1
	foreach( player in GetPlayerArray() )
	{
		Remote_CallFunction_NonReplay( player, "ServerCallback_DisableFog" )
		player.SetSkyCamera( GetEnt( "skybox_cam_skyway_harmony" ) )
	}

	file.camera.NonPhysicsStop()
	file.camera.ClearParent()

	bt.Destroy()
	anchor.Destroy()
	malta.Destroy()
	fx.Destroy()

	EntFireByHandle( env_shake, "StopShake", "", 0, null, null )
	env_shake.Destroy()
	GetEnt( "skybox_cam_level" ).ClearParent()
	GetEnt( "skybox_cam_level" ).SetAngles( skyangles )
	skyAnchor.Destroy()
}

/************************************************************************************************\

 █████╗  ██████╗████████╗ ██████╗ ██████╗      ██████╗  ██████╗
██╔══██╗██╔════╝╚══██╔══╝██╔═══██╗██╔══██╗    ██╔═══██╗██╔════╝
███████║██║        ██║   ██║   ██║██████╔╝    ██║   ██║██║  ███╗
██╔══██║██║        ██║   ██║   ██║██╔══██╗    ██║   ██║██║   ██║
██║  ██║╚██████╗   ██║   ╚██████╔╝██║  ██║    ╚██████╔╝╚██████╔╝
╚═╝  ╚═╝ ╚═════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝     ╚═════╝  ╚═════╝

\************************************************************************************************/
void function Actor_OGAlt_Main( entity player )
{
	wait 0.5
	entity eyecase = CreatePropDynamic( BT_EYE_CASE_MODEL )
	entity node 	= GetEntByScriptName( "actorBT" )
	entity anchor 	= CreateScriptMover( node.GetOrigin(), node.GetAngles() )
	entity dir 		= GetEntByScriptName( "dir_BTOG" )

	vector forward = dir.GetForwardVector()
	vector right = dir.GetRightVector()
	vector dirAng = AnglesCompose( dir.GetAngles(), <0,-90,0> )

	eyecase.SetParent( anchor )
	eyecase.Anim_Play( "bt_eye_skyway_reunion_insert" )
	eyecase.Anim_SetInitialTime( 8.7 )
	eyecase.SetPlaybackRate( PLAYBACKRATE )

	//DebugDrawCircleOnTag( eyecase, "EYE_CENTER", 64, 255, 0, 0, 10 )

	file.camera.SetOrigin( node.GetOrigin() + ( forward * -20 ) + ( right * 5 ) + < 0,0,105> )
	file.camera.SetAngles( AnglesCompose( dirAng, <0,90,0> ) )
	file.camera.NonPhysicsMoveTo( file.camera.GetOrigin() + ( forward * -25 ) , 10, 0, 6 )
	
	foreach( player in GetPlayerArray() )
	{
		Remote_CallFunction_NonReplay( player, "ServerCallback_DoF_SetFarDepth", 40, 80 )
		Remote_CallFunction_NonReplay( player, "ServerCallback_DoF_SetNearDepth", 16, 20 )
	}

	entity helmet = CreateExpensiveScriptMoverModel( HELMET_MODEL )
	node = GetEntByScriptName( "actorOG" )
	vector helmetRestO = node.GetOrigin() + <0,0,4>
	vector helmetRestA = AnglesCompose( node.GetAngles(), < -30, 60, 0> )

	helmet.SetOrigin( helmetRestO + ( right * -12 ) + < 0,0,4> )
	helmet.SetAngles( AnglesCompose( helmetRestA + <5,5,5> ) )

	entity jack = CreateExpensiveScriptMoverModel( MODEL_JACK )
	int bodyGroupIndex = jack.FindBodyGroup( "head" )
	jack.SetBodygroup( bodyGroupIndex, 1 )

	node = GetEntByScriptName( "actorOG2" )
	entity anchor0 = CreateOwnedScriptMover( node )
	jack.SetParent( anchor0 )
	jack.Anim_Play( "jack_O2_briefing_crew_L" )
	jack.Anim_SetInitialTime( 9.3 )
	jack.SetPlaybackRate( PLAYBACKRATE )
	
	foreach( player in GetPlayerArray() )
		ScreenFadeFromColor( player, 255, 255, 255, 255, 1.0, 0.3 )
	wait 0.5

	helmet.NonPhysicsMoveTo( helmetRestO, 3, 1.5, 1.5 )
	helmet.NonPhysicsRotateTo( helmetRestA, 3, 1.5, 1.5 )

	wait 2.5

	foreach( player in GetPlayerArray() )
	{
		Remote_CallFunction_NonReplay( player, "ServerCallback_DoF_SetFarDepth", 20, 40, 1 )
		Remote_CallFunction_NonReplay( player, "ServerCallback_DoF_SetNearDepth", 0, 8, 1 )
	}

	wait 4.0

	float fadeout = 0.2
	foreach( player in GetPlayerArray() )
		ScreenFadeToColor( player, 255, 255, 255, 255, fadeout, 999 )

	wait fadeout + 0.1

	file.camera.NonPhysicsStop()
	file.camera.ClearParent()

	//WHITE OUT TO MEMORY

	foreach( player in GetPlayerArray() )
	{
		player.SetSkyCamera( GetEnt( "skybox_cam_level" ) )
		Remote_CallFunction_NonReplay( player, "ServerCallback_EnableFog" )
	}

	entity og = CreatePropDynamic( MODEL_OG )
	entity nodeG = GetEntByScriptName( "actorOGalt" )
	entity anchorG = CreateOwnedScriptMover( nodeG )

	og.SetParent( anchorG )
	og.Anim_Play( "OG_all_done_credits" )
	og.SetPlaybackRate( PLAYBACKRATE )

	file.camera.SetOrigin( og.GetOrigin() + < -45,-3,55> )
	file.camera.SetAngles( <0,0,0> )
	file.camera.NonPhysicsMoveTo( file.camera.GetOrigin() + < 0,-15,0>, 10, 0, 0 )
	
	foreach( player in GetPlayerArray() )
	{
		Remote_CallFunction_NonReplay( player, "ServerCallback_DoF_SetFarDepth", 100, 1000 )
		Remote_CallFunction_NonReplay( player, "ServerCallback_DoF_SetNearDepthToDefault" )
	}

//	ScreenFadeFromBlack( player, 2.0, 0.3 )
	foreach( player in GetPlayerArray() )
		ScreenFadeFromColor( player, 255, 255, 255, 255, 1.0, 0.3 )
	thread Actor_OG_Stuff( og, player )
	wait 8.5

	fadeout = 0.2
	//ScreenFadeToBlackForever( player, fadeout )
	foreach( player in GetPlayerArray() )
		ScreenFadeToColor( player, 255, 255, 255, 255, fadeout, 999 )

	wait fadeout + 0.1

	file.camera.NonPhysicsStop()
	file.camera.ClearParent()

	og.Destroy()
	anchorG.Destroy()

	foreach( player in GetPlayerArray() )
	{
		Remote_CallFunction_NonReplay( player, "ServerCallback_DisableFog" )
		player.SetSkyCamera( GetEnt( "skybox_cam_skyway_harmony" ) )

		Remote_CallFunction_NonReplay( player, "ServerCallback_DoF_SetFarDepth", 20, 40, 1 )
		Remote_CallFunction_NonReplay( player, "ServerCallback_DoF_SetNearDepth", 0, 8, 1 )
		ScreenFadeFromColor( player, 255, 255, 255, 255, 1.0, 0.3 )
	}

	//WHITE OUT TO PRESENT

	jack.Anim_Play( "jack_O2_briefing_crew_L" )
	jack.Anim_SetInitialTime( 10.5 )
	jack.SetPlaybackRate( PLAYBACKRATE )

	eyecase.Anim_Play( "bt_eye_skyway_reunion_insert" )
	eyecase.Anim_SetInitialTime( 9 )
	eyecase.SetPlaybackRate( PLAYBACKRATE )

	node 	= GetEntByScriptName( "actorBT" )
	file.camera.SetOrigin( node.GetOrigin() + ( forward * -40 ) + ( right * 5 ) + < 0,0,105> )
	file.camera.SetAngles( AnglesCompose( dirAng, <0,90,0> ) )
	file.camera.NonPhysicsMoveTo( file.camera.GetOrigin() + ( forward * -15 ) , 10, 0, 0 )

	wait 1
	foreach( player in GetPlayerArray() )
		Remote_CallFunction_NonReplay( player, "ServerCallback_DoF_SetFarDepth", 40, 60, 6 )

	wait 0.5
	anchor0.NonPhysicsMoveTo( anchor0.GetOrigin() + ( right * -64 ) + <0,0,50>, 6, 5, 0 )

	wait 1

	fadeout = 1.0
	foreach( player in GetPlayerArray() )
		ScreenFadeToBlackForever( player, fadeout )

	wait fadeout + 0.1

	file.camera.ClearParent()
	file.camera.NonPhysicsStop()

	jack.Destroy()
	helmet.Destroy()
	eyecase.Destroy()
	anchor.Destroy()
	anchor0.Destroy()
}

void function Actor_OG_Stuff( entity og, entity player )
{
	wait 1
	foreach( player in GetPlayerArray() )
		Remote_CallFunction_NonReplay( player, "ServerCallback_AddCredits", eCredits.ACTOR_OG )

	wait 3
	og.SetPoseParameterOverTime( og.LookupPoseParameterIndex( "head_yaw" ), 0, 0 )
}


/************************************************************************************************\

 █████╗  ██████╗████████╗ ██████╗ ██████╗     ██████╗ ██╗     ██╗███████╗██╗  ██╗
██╔══██╗██╔════╝╚══██╔══╝██╔═══██╗██╔══██╗    ██╔══██╗██║     ██║██╔════╝██║ ██╔╝
███████║██║        ██║   ██║   ██║██████╔╝    ██████╔╝██║     ██║███████╗█████╔╝
██╔══██║██║        ██║   ██║   ██║██╔══██╗    ██╔══██╗██║     ██║╚════██║██╔═██╗
██║  ██║╚██████╗   ██║   ╚██████╔╝██║  ██║    ██████╔╝███████╗██║███████║██║  ██╗
╚═╝  ╚═╝ ╚═════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝    ╚═════╝ ╚══════╝╚═╝╚══════╝╚═╝  ╚═╝

\************************************************************************************************/
void function Actor_Blisk_Main( entity player )
{
	wait 0.5

	array<entity> removes = GetEntArrayByScriptName( "torture_room_BT" )
	foreach ( item in removes )
		item.Hide()

	entity blisk = CreatePropDynamic( MODEL_BLISK )
	entity node = GetEntByScriptName( "tr_sequence_ref" )
	entity anchor = CreateOwnedScriptMover( node )
	entity knife = CreatePropDynamic( COMBAT_KNIFE )
	knife.SetParent( blisk, "knife", false, 0.0 )

	blisk.SetParent( anchor )
	blisk.Anim_Play( "pt_torture_intro_Blisk_credits" )
	blisk.Anim_SetInitialTime( 0.5 )
	blisk.SetPlaybackRate( PLAYBACKRATE )

	file.camera.SetOrigin( blisk.GetOrigin() + < -7,30,30> )
	file.camera.SetAngles( <0,-45,0> )
	file.camera.NonPhysicsMoveTo( file.camera.GetOrigin() + < -5,10,0>, 10, 0, 0 )
	
	foreach( player in GetPlayerArray() )
	{
		Remote_CallFunction_NonReplay( player, "ServerCallback_DoF_SetFarDepth", 100, 500 )
		Remote_CallFunction_NonReplay( player, "ServerCallback_DoF_SetNearDepthToDefault" )

		ScreenFadeFromBlack( player, 2.0, 0.3 )

		thread Actor_Blisk_Stuff( blisk, player )
	}
	wait 7.5

	float fadeout = 1.0
	foreach( player in GetPlayerArray() )
		ScreenFadeToBlackForever( player, fadeout )

	wait fadeout + 0.1

	file.camera.NonPhysicsStop()

	blisk.Destroy()
	anchor.Destroy()
}

void function Actor_Blisk_Stuff( entity blisk, entity player )
{
	wait 1
	Remote_CallFunction_NonReplay( player, "ServerCallback_AddCredits", eCredits.ACTOR_BLISK )
}

/************************************************************************************************\

 █████╗  ██████╗████████╗ ██████╗ ██████╗     ███████╗ █████╗ ██████╗  █████╗ ██╗  ██╗
██╔══██╗██╔════╝╚══██╔══╝██╔═══██╗██╔══██╗    ██╔════╝██╔══██╗██╔══██╗██╔══██╗██║  ██║
███████║██║        ██║   ██║   ██║██████╔╝    ███████╗███████║██████╔╝███████║███████║
██╔══██║██║        ██║   ██║   ██║██╔══██╗    ╚════██║██╔══██║██╔══██╗██╔══██║██╔══██║
██║  ██║╚██████╗   ██║   ╚██████╔╝██║  ██║    ███████║██║  ██║██║  ██║██║  ██║██║  ██║
╚═╝  ╚═╝ ╚═════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝

\************************************************************************************************/
void function Actor_Sarah_Main( entity player )
{
	wait 0.4
	entity sarah = CreatePropDynamic( MODEL_SARAH )
	entity node = GetEntByScriptName( "actorSarah" )
	entity anchor = CreateOwnedScriptMover( node )

	sarah.DisableHibernation()
	sarah.SetParent( anchor )
	wait 0.1 // no idea why i have to add this - but if I don't the animation just hangs 50% of the time.
	sarah.Anim_Play( "sa_beacon_cavalry_arrives_credits" )
	sarah.Anim_SetInitialTime( 0.66 )
	sarah.SetPlaybackRate( PLAYBACKRATE )

	file.camera.SetOrigin( sarah.GetOrigin() + < 35,55,60> )
	file.camera.SetAngles( <0,-90,0> )
	file.camera.NonPhysicsMoveTo( file.camera.GetOrigin() + < 0,-10,0>, 10, 0, 0 )
	
	foreach( player in GetPlayerArray() )
	{
		Remote_CallFunction_NonReplay( player, "ServerCallback_DoF_SetFarDepth", 200, 1000 )
		Remote_CallFunction_NonReplay( player, "ServerCallback_DoF_SetNearDepthToDefault" )

		ScreenFadeFromBlack( player, 2.0, 0.3 )
		thread Actor_Sarah_Stuff( sarah, player )
	}
	wait 7.5

	float fadeout = 1.0
	foreach( player in GetPlayerArray() )
		ScreenFadeToBlackForever( player, fadeout )

	wait fadeout + 0.1

	file.camera.NonPhysicsStop()

	sarah.Destroy()
	anchor.Destroy()
}

void function Actor_Sarah_Stuff( entity sarah, entity player )
{
	wait 1
	Remote_CallFunction_NonReplay( player, "ServerCallback_AddCredits", eCredits.ACTOR_SARAH )

//	wait 3
//	sarah.SetPoseParameterOverTime( sarah.LookupPoseParameterIndex( "head_pitch" ), 18.5, 2.0 )
}

/************************************************************************************************\

 █████╗  ██████╗████████╗ ██████╗ ██████╗     ███╗   ███╗ █████╗ ██████╗ ██████╗ ███████╗██████╗
██╔══██╗██╔════╝╚══██╔══╝██╔═══██╗██╔══██╗    ████╗ ████║██╔══██╗██╔══██╗██╔══██╗██╔════╝██╔══██╗
███████║██║        ██║   ██║   ██║██████╔╝    ██╔████╔██║███████║██████╔╝██║  ██║█████╗  ██████╔╝
██╔══██║██║        ██║   ██║   ██║██╔══██╗    ██║╚██╔╝██║██╔══██║██╔══██╗██║  ██║██╔══╝  ██╔══██╗
██║  ██║╚██████╗   ██║   ╚██████╔╝██║  ██║    ██║ ╚═╝ ██║██║  ██║██║  ██║██████╔╝███████╗██║  ██║
╚═╝  ╚═╝ ╚═════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝    ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝ ╚══════╝╚═╝  ╚═╝

\************************************************************************************************/
void function Actor_Marder_Main( entity player )
{
	wait 0.5
	entity marder = CreatePropDynamic( MARDER_HOLOGRAM_MODEL )
	entity marder2 = CreatePropDynamic( MARDER_HOLOGRAM_MODEL )
	entity anchor = CreateScriptMover( < 7038, 13094, 5397 >, <0,37,0> )

	//marder.SetSkin( 1 )
	marder.SetParent( anchor )
	marder.Anim_Play( "pt_injectore_room_credits" )
	marder.Anim_SetInitialTime( 5.4 )
	marder.SetPlaybackRate( PLAYBACKRATE )

	int attachIndex = marder.LookupAttachment( "CHESTFOCUS" )
	StartParticleEffectOnEntity( marder, GetParticleSystemIndex( GHOST_TRAIL_EFFECT ), FX_PATTACH_POINT_FOLLOW, attachIndex )
	StartParticleEffectOnEntity( marder, GetParticleSystemIndex( GHOST_FLASH_EFFECT ), FX_PATTACH_POINT, attachIndex )

	vector origin = anchor.GetOrigin() + <308,208,303>
	vector angles = AnglesCompose( anchor.GetAngles(), < 0,27,0 > )
	vector forward = AnglesToForward( angles )
	file.camera.SetOrigin( origin + <0,0,-6> )
	file.camera.SetAngles( angles + < -10,0,0> )
	file.camera.NonPhysicsMoveTo( origin + forward * -25, 10, 7, 0 )
	file.camera.NonPhysicsRotateTo( angles + < 5,-5,0>, 10, 5, 5 )

	//DebugDrawCircleOnEnt( marder, 64, 255, 0, 0, 1000 )
	foreach( player in GetPlayerArray() )
	{
		Remote_CallFunction_NonReplay( player, "ServerCallback_DoF_SetFarDepth", 60, 100 )
		Remote_CallFunction_NonReplay( player, "ServerCallback_DoF_SetNearDepth", 4, 16 )

		ScreenFadeFromBlack( player, 2.0, 0.3 )
	}
	thread Actor_Marder_Stuff( marder, player )
	wait 7.5

	float fadeout = 1.0
	foreach( player in GetPlayerArray() )
		ScreenFadeToBlackForever( player, fadeout )

	wait fadeout + 0.1

	if ( IsValid( marder ) )
		marder.Destroy()

	file.camera.NonPhysicsStop()
	anchor.Destroy()
}

void function Actor_Marder_Stuff( entity marder, entity player )
{
	marder.SetPoseParameterOverTime( marder.LookupPoseParameterIndex( "head_pitch" ), 15, 0.1 )
	marder.SetPoseParameterOverTime( marder.LookupPoseParameterIndex( "head_yaw" ), 70, 0 )
	wait 0.1
	marder.SetPoseParameterOverTime( marder.LookupPoseParameterIndex( "head_yaw" ), 40, 0 )

	wait 0.9
	foreach( player in GetPlayerArray() )
		Remote_CallFunction_NonReplay( player, "ServerCallback_AddCredits", eCredits.ACTOR_MARDER )
	marder.SetPoseParameterOverTime( marder.LookupPoseParameterIndex( "head_pitch" ), 0, 7 )

	wait 0.5
	marder.SetPoseParameterOverTime( marder.LookupPoseParameterIndex( "head_yaw" ), 50, 3.5 )

	wait 1
	marder.SetPoseParameterOverTime( marder.LookupPoseParameterIndex( "head_yaw" ), 0, 4 )

	wait 3.5
	marder.Dissolve( ENTITY_DISSOLVE_CHAR, < 0, 0, 0 >, 500 )
}

/************************************************************************************************\

 █████╗  ██████╗████████╗ ██████╗ ██████╗     ██████╗  ██████╗ ███████╗███████╗███████╗███████╗
██╔══██╗██╔════╝╚══██╔══╝██╔═══██╗██╔══██╗    ██╔══██╗██╔═══██╗██╔════╝██╔════╝██╔════╝██╔════╝
███████║██║        ██║   ██║   ██║██████╔╝    ██████╔╝██║   ██║███████╗███████╗█████╗  ███████╗
██╔══██║██║        ██║   ██║   ██║██╔══██╗    ██╔══██╗██║   ██║╚════██║╚════██║██╔══╝  ╚════██║
██║  ██║╚██████╗   ██║   ╚██████╔╝██║  ██║    ██████╔╝╚██████╔╝███████║███████║███████╗███████║
╚═╝  ╚═╝ ╚═════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝    ╚═════╝  ╚═════╝ ╚══════╝╚══════╝╚══════╝╚══════╝

\************************************************************************************************/
void function Actor_Bosses_main( entity player )
{
	wait 0.5
	foreach( player in GetPlayerArray() )
		player.SetSkyCamera( GetEnt( "skybox_cam_level" ) )

	array<entity> lands
	array<entity> nodes = GetEntArrayByScriptName( "earthLarge_01" )
	foreach ( item in nodes )
		lands.append( CreatePropDynamic( MODEL_EARTH_PIECE, item.GetOrigin(), item.GetAngles() ) )

	entity spawner 	= GetEntByScriptName( "actorRonin" )
	entity ronin 	= spawner.SpawnEntity()
	entity anchorR 	= CreateOwnedScriptMover( ronin )
	DispatchSpawn( ronin )
	ronin.Show()
	ronin.SetSkin( 1 )
	ronin.DisableHibernation()
	ronin.SetValidHealthBarTarget( false )
	HideName( ronin )

	entity node 	= GetEntByScriptName( "actorAsh" )
	entity ash 		= CreatePropDynamic( MODEL_ASH )
	entity anchorA 	= CreateOwnedScriptMover( node )
	entity gunA = CreatePropDynamic( MODEL_R101, <0,0,0> )

	vector ruiAngles = AnglesCompose( anchorR.GetAngles(), < 0,160,0 > )
	vector forwardUI = AnglesToForward( ruiAngles )
	vector rightUI = AnglesToRight( ruiAngles )

	vector forward = anchorR.GetForwardVector() * 130
	vector right = anchorR.GetRightVector() * 40
	vector camAngles = AnglesCompose( ruiAngles, < -10,0,0 > )

	file.camera.SetOrigin( anchorR.GetOrigin() + forward + right + <0,0,53> )
	file.camera.SetAngles( camAngles )

	ronin.SetParent( anchorR )
	ronin.Anim_ScriptedPlay( "titan_light_menu_main_idle_01" )
	ronin.Anim_SetInitialTime( 1.1 )
	ronin.SetPlaybackRate( PLAYBACKRATE * 1.5 )

	ash.SetParent( anchorA )
	ash.Anim_Play( "stand_2_walk_180L" )
	ash.Anim_SetInitialTime( 1.2 )
	ash.SetPlaybackRate( PLAYBACKRATE * 0.4 )
	SetTeam( ash, TEAM_IMC )
	gunA.SetParent( ash, "PROPGUN" )
	anchorA.SetOrigin( anchorA.GetOrigin() + forwardUI * -10 )
	anchorA.NonPhysicsMoveTo( anchorA.GetOrigin() + rightUI * 40, 30, 10, 0 )

	entity anchor_UI_Ash = CreateScriptMover( ash.GetOrigin() + rightUI * 20 + forwardUI * 50 + <0,0,60>, camAngles )

	spawner 		= GetEntByScriptName( "actorScorch" )
	entity scorch 	= spawner.SpawnEntity()
	entity anchorS 	= CreateOwnedScriptMover( scorch )
	DispatchSpawn( scorch )
	scorch.Show()
	scorch.SetSkin( 1 )
	scorch.DisableHibernation()
	scorch.SetValidHealthBarTarget( false )
	HideName( scorch )

	scorch.SetParent( anchorS )
	scorch.Anim_ScriptedPlay( "at_MP_embark_idle_blended" )
	scorch.SetPlaybackRate( PLAYBACKRATE )

	node 			= GetEntByScriptName( "actorKane" )
	entity kane 	= CreatePropDynamic( MODEL_KANE )
	entity link 	= CreateOwnedScriptMover( node )

	kane.SetParent( link )
	kane.Anim_Play( "pt_Kane_boss_intro_kane_credits" )
	kane.Anim_SetInitialTime( 1.4 )
	kane.SetPlaybackRate( PLAYBACKRATE )
	SetTeam( ash, TEAM_IMC )
	link.SetOrigin( link.GetOrigin() + rightUI * 15 + forwardUI * -4 )
	kane.SetPoseParameter( kane.LookupPoseParameterIndex( "head_yaw" ), -25 )
	kane.SetPoseParameter( kane.LookupPoseParameterIndex( "head_pitch" ), 10 )

	int attachID = kane.LookupAttachment( "CHESTFOCUS" )
	entity anchorK = CreateScriptMover(  kane.GetAttachmentOrigin( attachID ), <0,0,0> )
	kane.GetParent().SetParent( anchorK, "REF", true, 0 )
	anchorK.SetAngles( <0,-30,0> )

	entity anchor_UI_Kane = CreateScriptMover( ash.GetOrigin() + rightUI * 130 + forwardUI * 50 + <0,0,60>, camAngles )

	spawner 		= GetEntByScriptName( "actorTone" )
	entity tone 	= spawner.SpawnEntity()
	entity anchorT 	= CreateOwnedScriptMover( tone )
	DispatchSpawn( tone )
	tone.Show()
	tone.SetSkin( 1 )
	tone.DisableHibernation()
	tone.SetValidHealthBarTarget( false )
	HideName( tone )

	tone.SetParent( anchorT )
	tone.Anim_ScriptedPlay( "at_IDLE_2" )
	tone.Anim_SetInitialTime( 5.0 )
	tone.SetPlaybackRate( PLAYBACKRATE )

	node 			= GetEntByScriptName( "actorRichter" )
	entity richter 	= CreatePropDynamic( MODEL_RICHTER )
	entity anchorRc	= CreateOwnedScriptMover( node )

	richter.SetParent( anchorRc )
	richter.Anim_Play( "pt_family_photo_Richter_credits" )
	richter.Anim_SetInitialTime( 1.8 )
	richter.SetPlaybackRate( PLAYBACKRATE )
	SetTeam( richter, TEAM_IMC )

	entity anchor_UI_Richter = CreateScriptMover( ash.GetOrigin() + rightUI * 265 + forwardUI * 50 + <0,0,60>, camAngles )

	spawner 		= GetEntByScriptName( "actorNorthStar" )
	entity northstar = spawner.SpawnEntity()
	entity anchorN 	= CreateOwnedScriptMover( northstar )
	DispatchSpawn( northstar )
	northstar.Show()
	northstar.SetSkin( 1 )
	northstar.DisableHibernation()
	northstar.SetValidHealthBarTarget( false )
	HideName( northstar )
	northstar.TakeActiveWeapon()

	northstar.SetParent( anchorN )
	northstar.Anim_ScriptedPlay( "lt_viper_main_intro_credits" )
	northstar.Anim_SetInitialTime( 1.0 )
	northstar.SetPlaybackRate( PLAYBACKRATE * 1.5 )
	thread Actor_Northstar_Stuff( northstar, anchorN )

	StartParticleEffectOnEntity( northstar, GetParticleSystemIndex( $"P_xo_jet_fly_large" ), FX_PATTACH_POINT_FOLLOW, northstar.LookupAttachment( "FX_L_BOT_THRUST" ) )
	StartParticleEffectOnEntity( northstar, GetParticleSystemIndex( $"P_xo_jet_fly_large" ), FX_PATTACH_POINT_FOLLOW, northstar.LookupAttachment( "FX_R_BOT_THRUST" ) )
	StartParticleEffectOnEntity( northstar, GetParticleSystemIndex( $"P_xo_jet_fly_small" ), FX_PATTACH_POINT_FOLLOW, northstar.LookupAttachment( "FX_L_TOP_THRUST" ) )
	StartParticleEffectOnEntity( northstar, GetParticleSystemIndex( $"P_xo_jet_fly_small" ), FX_PATTACH_POINT_FOLLOW, northstar.LookupAttachment( "FX_R_TOP_THRUST" ) )

	entity anchor_UI_Viper = CreateScriptMover( ash.GetOrigin() + rightUI * 400 + forwardUI * 50 + <0,0,60>, camAngles )

	spawner 		= GetEntByScriptName( "actorIon" )
	entity ion 	= spawner.SpawnEntity()
	entity anchorI 	= CreateOwnedScriptMover( ion )
	DispatchSpawn( ion )
	ion.Show()
	ion.SetSkin( 1 )
	ion.DisableHibernation()
	ion.SetValidHealthBarTarget( false )
	HideName( ion )

	ion.SetParent( anchorI )
	ion.Anim_ScriptedPlay( "at_MP_embark_idle_blended" )
	ion.SetPlaybackRate( PLAYBACKRATE )

	node 			= GetEntByScriptName( "actorSlone" )
	entity slone 	= CreatePropDynamic( MODEL_SLONE )
	entity anchorSl	= CreateOwnedScriptMover( node )
	anchorSl.SetOrigin( anchorSl.GetOrigin() + rightUI * -40 )

	slone.SetParent( anchorSl )
	slone.Anim_Play( "pt_torture_intro_slone_credits" )
	slone.Anim_SetInitialTime( 10.0 )
	slone.SetPlaybackRate( PLAYBACKRATE * 1.5 )
	SetTeam( slone, TEAM_IMC )

	entity anchor_UI_Slone = CreateScriptMover( ash.GetOrigin() + rightUI * 500 + forwardUI * 50 + <0,0,60>, camAngles )

	file.camera.NonPhysicsMoveTo( file.camera.GetOrigin() + rightUI * 600, 62.5, 0, 5 )
	
	foreach( player in GetPlayerArray() )
	{
		Remote_CallFunction_NonReplay( player, "ServerCallback_EnableFog" )
		Remote_CallFunction_NonReplay( player, "ServerCallback_DoF_SetFarDepth", 1000, 2000 )
		Remote_CallFunction_NonReplay( player, "ServerCallback_DoF_SetNearDepth", 4, 16 )
		ScreenFadeFromBlack( player, 2.0, 0.3 )
	}

	thread Actor_Ash_Stuff( ash, player, anchor_UI_Ash )
	wait 8

	thread Actor_Kane_Stuff( kane, player, anchor_UI_Kane )
	wait 8

	thread Actor_Richter_Stuff( richter, player, anchor_UI_Richter )
	wait 14

	anchorK.Destroy()

	node 			= GetEntByScriptName( "actorViper" )
	entity viper 	= CreatePropDynamic( MODEL_VIPER )
	entity anchorV	= CreateOwnedScriptMover( node )
	anchorV.SetOrigin( anchorV.GetOrigin() + rightUI * -30 )

	viper.SetParent( anchorV )
	viper.Anim_Play( "pt_torture_intro_viper_credits" )
	viper.Anim_SetInitialTime( 1.0 )
	viper.SetPlaybackRate( PLAYBACKRATE * 1.7 )
	SetTeam( viper, TEAM_IMC )

	wait 3

	anchorV.NonPhysicsMoveTo( anchorV.GetOrigin() + rightUI * 150, 35, 0, 0 )

	wait 2

	thread Actor_Viper_Stuff( viper, player, anchor_UI_Viper )
	wait 8

	thread Actor_Slone_Stuff( slone, ion, player, anchor_UI_Slone )
	wait 15

	float fadeout = 1.0
	foreach( player in GetPlayerArray() )
		ScreenFadeToBlackForever( player, fadeout )

	wait fadeout + 0.1
	
	foreach( player in GetPlayerArray() )
	{
		Remote_CallFunction_NonReplay( player, "ServerCallback_DisableFog" )
		player.SetSkyCamera( GetEnt( "skybox_cam_skyway_harmony" ) )
	}

	anchorA.Destroy()
	anchor_UI_Ash.Destroy()
	anchorR.Destroy()

	//anchorK.Destroy()
	anchor_UI_Kane.Destroy()
	anchorS.Destroy()

	anchorRc.Destroy()
	anchor_UI_Richter.Destroy()
	anchorT.Destroy()

	anchorV.Destroy()
	anchor_UI_Viper.Destroy()
	anchorN.Destroy()

	anchorSl.Destroy()
	anchor_UI_Slone.Destroy()
	anchorI.Destroy()

	foreach ( item in lands )
		item.Destroy()
}

void function Actor_Ash_Stuff( entity ash, entity player, entity anchor )
{
	SetGlobalNetEnt( "uiAnchor_Ash", anchor )

	ash.SetPoseParameter( ash.LookupPoseParameterIndex( "head_yaw" ), 5 )
	ash.SetPoseParameter( ash.LookupPoseParameterIndex( "head_pitch" ), 5 )
	ash.SetPoseParameterOverTime( ash.LookupPoseParameterIndex( "head_yaw" ), 33, 6 )

	wait 1
	foreach( player in GetPlayerArray() )
		Remote_CallFunction_NonReplay( player, "ServerCallback_AddCredits", eCredits.ACTOR_ASH )
}

void function Actor_Kane_Stuff( entity kane, entity player, entity anchor )
{
	SetGlobalNetEnt( "uiAnchor_Kane", anchor )
	anchor.NonPhysicsMoveTo( anchor.GetOrigin() + anchor.GetRightVector() * -15, 20, 10, 0 )

	entity anchorK = kane.GetParent().GetParent()
	anchorK.NonPhysicsRotateTo( <0,45,0>, 10, 2, 3 )
	kane.SetPoseParameterOverTime( kane.LookupPoseParameterIndex( "head_yaw" ), 10, 6 )
	anchorK.NonPhysicsMoveTo( anchorK.GetOrigin() + anchor.GetRightVector() * 30, 20, 10, 0 )

	wait 4
	foreach( player in GetPlayerArray() )
		Remote_CallFunction_NonReplay( player, "ServerCallback_AddCredits", eCredits.ACTOR_KANE )
}

void function Actor_Richter_Stuff( entity richter, entity player, entity anchor )
{
	SetGlobalNetEnt( "uiAnchor_Richter", anchor )

	richter.SetPoseParameterOverTime( richter.LookupPoseParameterIndex( "head_pitch" ), 20, 5 )
	wait 8

	richter.GetParent().NonPhysicsMoveTo( richter.GetParent().GetOrigin() + anchor.GetRightVector() * 70, 15, 7, 2 )
	richter.SetPoseParameterOverTime( richter.LookupPoseParameterIndex( "head_pitch" ), 0, 5 )
	wait 1

	anchor.NonPhysicsMoveTo( anchor.GetOrigin() + anchor.GetRightVector() * 50, 15, 0, 5 )

	wait 2
	foreach( player in GetPlayerArray() )
		Remote_CallFunction_NonReplay( player, "ServerCallback_AddCredits", eCredits.ACTOR_RICHTER )
	richter.SetPoseParameterOverTime( richter.LookupPoseParameterIndex( "head_pitch" ), 20, 4 )

	wait 4
	richter.SetPoseParameterOverTime( richter.LookupPoseParameterIndex( "head_pitch" ), 0, 4 )
	richter.SetPoseParameterOverTime( richter.LookupPoseParameterIndex( "head_yaw" ), 20, 8 )
}

void function Actor_Viper_Stuff( entity viper, entity player, entity anchor )
{
	SetGlobalNetEnt( "uiAnchor_Viper", anchor )

	wait 3
	foreach( player in GetPlayerArray() )
		Remote_CallFunction_NonReplay( player, "ServerCallback_AddCredits", eCredits.ACTOR_VIPER )
	anchor.NonPhysicsMoveTo( anchor.GetOrigin() + anchor.GetRightVector() * 30, 10, 5, 0 )

	wait 1
	viper.SetPoseParameterOverTime( viper.LookupPoseParameterIndex( "head_yaw" ), 60, 13 )
}

void function Actor_Northstar_Stuff( entity northstar, entity anchor )
{
	wait 40
	anchor.NonPhysicsMoveTo( anchor.GetOrigin() + anchor.GetRightVector() * 600, 20, 5, 10 )

	WaittillAnimDone( northstar )
	//vector origin = HackGetDeltaToRef( northstar.GetOrigin(), northstar.GetAngles(), northstar, anim )

	northstar.Anim_ScriptedPlay( "lt_viper_main_intro_end" )
	northstar.SetPlaybackRate( PLAYBACKRATE * 0.1 )
	northstar.Anim_DisableAnimDelta()
}

void function Actor_Slone_Stuff( entity slone, entity ion, entity player, entity anchor )
{
	SetGlobalNetEnt( "uiAnchor_Slone", anchor )

	wait 4
	foreach( player in GetPlayerArray() )
		Remote_CallFunction_NonReplay( player, "ServerCallback_AddCredits", eCredits.ACTOR_SLONE )

	anchor.NonPhysicsMoveTo( anchor.GetOrigin() + anchor.GetRightVector() * 80, 15, 5, 5 )
	slone.GetParent().NonPhysicsMoveTo( slone.GetParent().GetOrigin() + anchor.GetRightVector() * 80, 15, 5, 5 )

	wait 10
	ion.Anim_ScriptedPlay( "at_mount_kneel_front" )
	ion.SetPlaybackRate( PLAYBACKRATE )

}

void function NormalSkywaySetup( entity player )
{
	array<entity> debrisMid = GetEntArrayByScriptName( "core_debris_mid" )
	debrisMid.extend( GetEntArrayByScriptName( "floating_debris" ) )
	foreach ( entity dMid in debrisMid )
		dMid.GetParent().Destroy()
	FlagClear( "StartLandingAreaRise" )
	Signal( level, "HarmonySceneStart" )
	FlagSet( "sp_run_vista_titan_hill" )
	svGlobal.levelEnt.Signal( "StratonHornetDogfights" )
	FlagSet( "injector_lighting_FX" )
	GetEntByScriptName( "outer_ring" ).Show()
	GetEntByScriptName( "middle_ring" ).Show()
	GetEntByScriptName( "inner_ring" ).Show()
	GetEntByScriptName( "outer_ring" ).SetModel( $"models/levels_terrain/sp_skyway/sculpter_outer_ring.mdl" )
	GetEntByScriptName( "middle_ring" ).SetModel( $"models/levels_terrain/sp_skyway/sculpter_middle_ring.mdl" )
	GetEntByScriptName( "inner_ring" ).SetModel( $"models/levels_terrain/sp_skyway/sculpter_inner_ring.mdl" )
}

/************************************************************************************************\

 █████╗  ██████╗████████╗ ██████╗ ██████╗     ██████╗  █████╗ ██████╗ ██╗  ██╗███████╗██████╗
██╔══██╗██╔════╝╚══██╔══╝██╔═══██╗██╔══██╗    ██╔══██╗██╔══██╗██╔══██╗██║ ██╔╝██╔════╝██╔══██╗
███████║██║        ██║   ██║   ██║██████╔╝    ██████╔╝███████║██████╔╝█████╔╝ █████╗  ██████╔╝
██╔══██║██║        ██║   ██║   ██║██╔══██╗    ██╔══██╗██╔══██║██╔══██╗██╔═██╗ ██╔══╝  ██╔══██╗
██║  ██║╚██████╗   ██║   ╚██████╔╝██║  ██║    ██████╔╝██║  ██║██║  ██║██║  ██╗███████╗██║  ██║
╚═╝  ╚═╝ ╚═════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝

\************************************************************************************************/
void function Actor_Barker_Main( entity player )
{
	wait 0.5
	entity ship = CreatePropDynamic( CROW_HERO_MODEL )
	SetTeam( ship, TEAM_MILITIA )
	DropshipFX( ship )
	entity node = GetEntByScriptName( "actorBarkerShip" )
	thread PlayAnimTeleport( ship, "test_runway_idle", node )

	entity barker = CreatePropDynamic( MODEL_BARKER )
	AddFlask( barker )

	node = GetEntByScriptName( "actorBarker" )
	entity anchor = CreateOwnedScriptMover( node )

	barker.SetParent( anchor )
	barker.Anim_Play( "commander_MP_flyin_Barker_credits" )
	barker.Anim_SetInitialTime( 10.6 )
	barker.SetPlaybackRate( PLAYBACKRATE )

	vector forward = node.GetForwardVector() * 35
	vector right = node.GetRightVector() * -15
	file.camera.SetOrigin( barker.GetOrigin() + forward + right + <0,0,60> )
	file.camera.SetAngles( AnglesCompose( node.GetAngles(), < 0,190,0 > ) )
	file.camera.NonPhysicsMoveTo( file.camera.GetOrigin() + forward + right, 30, 0, 0 )
	
	foreach( player in GetPlayerArray() )
	{
		Remote_CallFunction_NonReplay( player, "ServerCallback_DoF_SetFarDepth", 60, 500 )
		Remote_CallFunction_NonReplay( player, "ServerCallback_DoF_SetNearDepth", 0, 16 )
		ScreenFadeFromBlack( player, 2.0, 0.3 )
		
		thread Actor_Barker_Stuff( barker, player )
	}
	
	wait 7.5

	float fadeout = 1.0
	foreach( player in GetPlayerArray() )
		ScreenFadeToBlackForever( player, fadeout )

	wait fadeout + 0.1

	file.camera.NonPhysicsStop()
	barker.Destroy()
	anchor.Destroy()
	ship.Destroy()
}

void function AddFlask( entity guy )
{
	entity flask = CreateExpensiveScriptMoverModel( MODEL_FLASK )
	flask.SetParent( guy, "R_HAND" )
	flask.NonPhysicsSetMoveModeLocal( true )
	flask.NonPhysicsSetRotateModeLocal( true )
	flask.SetLocalOrigin( < -4.2,2.4, -1.1> )
	flask.SetLocalAngles( < 185,70,-10 > )

//	flask.SetLocalOrigin( < 0.3,-0.3,0> )
//	flask.SetLocalAngles( < -90,-20,-70> )
//	level.flask <- flask
}

void function Actor_Barker_Stuff( entity barker, entity player )
{
	wait 1
	Remote_CallFunction_NonReplay( player, "ServerCallback_AddCredits", eCredits.ACTOR_BARKER )
}

/************************************************************************************************\

 █████╗  ██████╗████████╗ ██████╗ ██████╗     ████████╗██╗  ██╗███████╗     ██████╗       ██╗  ██╗
██╔══██╗██╔════╝╚══██╔══╝██╔═══██╗██╔══██╗    ╚══██╔══╝██║  ██║██╔════╝    ██╔════╝       ██║  ██║
███████║██║        ██║   ██║   ██║██████╔╝       ██║   ███████║█████╗      ███████╗ █████╗███████║
██╔══██║██║        ██║   ██║   ██║██╔══██╗       ██║   ██╔══██║██╔══╝      ██╔═══██╗╚════╝╚════██║
██║  ██║╚██████╗   ██║   ╚██████╔╝██║  ██║       ██║   ██║  ██║███████╗    ╚██████╔╝           ██║
╚═╝  ╚═╝ ╚═════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝       ╚═╝   ╚═╝  ╚═╝╚══════╝     ╚═════╝            ╚═╝

\************************************************************************************************/
void function Actor_The64_Main( entity player )
{
	wait 0.5
	entity gates = CreatePropDynamic( MODEL_GATES )
	entity nodeg = GetEntByScriptName( "actorGates" )
	entity anchorG = CreateOwnedScriptMover( nodeg )

	entity bear = CreatePropDynamic( MODEL_BEAR )
	entity nodeb = GetEntByScriptName( "actorBear" )

	gates.SetParent( anchorG )
	gates.SetSkin( 1 )
	gates.Anim_Play( "commander_MP_flyin_Ash_credits" )
	gates.SetPlaybackRate( PLAYBACKRATE )
	SetTeam( gates, TEAM_MILITIA )

	bear.SetSkin( 1 )
	SetTeam( bear, TEAM_MILITIA )

	string anim = "casual_walkturn_135L"
	vector angs = AnglesCompose( nodeb.GetAngles(), <0,90,0> )
	entity anchorB = CreateScriptMover( nodeb.GetOrigin() + <52,-75,0> , angs )
	bear.SetParent( anchorB )
	bear.Anim_Play( anim )
	bear.SetPlaybackRate( 0.0 )

	entity gun = CreatePropDynamic( MODEL_MASTIFF )
	gun.SetParent( bear, "PROPGUN" )

	entity davis = CreatePropDynamic( MODEL_DAVIS )
	entity droz = CreatePropDynamic( MODEL_DROZ )
	entity node1 = GetEntByScriptName( "davisNode" )
	entity node2 = GetEntByScriptName( "drozNode" )
	entity anchor1 = CreateOwnedScriptMover( node1 )
	entity anchor2 = CreateOwnedScriptMover( node2 )

	float initialTime = 38.7 - 3.6

	davis.SetParent( anchor1 )
	davis.SetSkin( 1 )
	davis.Anim_Play( "pt_family_photo_Blisk_credits" )
	davis.Anim_SetInitialTime( initialTime + 1.2 )
	davis.SetPlaybackRate( PLAYBACKRATE - 0.05 )
	davis.SetPoseParameter( davis.LookupPoseParameterIndex( "head_yaw" ), -20 )
	SetTeam( davis, TEAM_MILITIA )
	davis.Hide()

	droz.SetParent( anchor2 )
	droz.SetSkin( 1 )
	droz.Anim_Play( "pt_family_photo_Richter_credits" )
	droz.Anim_SetInitialTime( initialTime )
	droz.SetPlaybackRate( PLAYBACKRATE )
	SetTeam( droz, TEAM_MILITIA )

	////////////////////////////////////////////////////////
	vector OFFSET = < 0, 8192, 0 >

	vector origin = < -8110, -7818, -12720 > + OFFSET
	vector angles = < -15, 115, 0 >
	file.camera.NonPhysicsStop()
	file.camera.SetOrigin( origin )
	file.camera.SetAngles( angles )
	
	foreach( player in GetPlayerArray() )
	{
		ScreenFadeFromBlack( player, 2.0, 0.3 )
		Remote_CallFunction_NonReplay( player, "ServerCallback_DoF_SetFarDepth", 50, 130 )
		Remote_CallFunction_NonReplay( player, "ServerCallback_DoF_SetNearDepth", 8, 20 )
		Remote_CallFunction_NonReplay( player, "ServerCallback_CsmTexelScale", 0.1, 0.5 )
	}

	origin = < -8136, -7875, -12728 > + OFFSET
	file.camera.NonPhysicsMoveTo( origin, 11, 7, 4 )

	thread Actor_Gates_Stuff( gates, player )
	wait 9

	origin = < -8160, -7940, -12728 > + OFFSET
	angles = < 0, 70, 0 >
	thread Actor_Bear_Stuff( bear, player, origin, angles, davis )
	wait 9

	thread Actor_Davis_Stuff( davis, anchor1, player )
	wait 2

	vector forward = AnglesToForward( angles )
	foreach( player in GetPlayerArray() )
		file.camera.NonPhysicsMoveTo( origin + forward * -40, 15.7, 10, 5.5 )
	//Remote_CallFunction_NonReplay( player, "ServerCallback_DoF_SetFarDepth", 200, 300, 5 )
	wait 5

	file.camera.NonPhysicsRotateTo( angles + <0,-30,0>, 15, 7, 0 )
	wait 2

	thread Actor_Droz_Stuff( droz, player )
	wait 2
	foreach( player in GetPlayerArray() )
		Remote_CallFunction_NonReplay( player, "ServerCallback_DoF_SetFarDepth", 100, 200, 7 )
	wait 5.5

	float fadeout = 1.0
	foreach( player in GetPlayerArray() )
		ScreenFadeToBlackForever( player, fadeout )

	wait fadeout + 0.1

	file.camera.NonPhysicsStop()
	foreach( player in GetPlayerArray() )
		Remote_CallFunction_NonReplay( player, "ServerCallback_CsmTexelScale", 1, 1 )

	davis.Destroy()
	droz.Destroy()
	gates.Destroy()
	bear.Destroy()
	anchorB.Destroy()
	anchorG.Destroy()
	anchor1.Destroy()
	anchor2.Destroy()
}

void function Actor_Gates_Stuff( entity gates, entity player )
{
	gates.SetPoseParameter( gates.LookupPoseParameterIndex( "head_yaw" ), -5 )
	gates.SetPoseParameter( gates.LookupPoseParameterIndex( "head_pitch" ), 50 )
	gates.SetPoseParameterOverTime( gates.LookupPoseParameterIndex( "head_yaw" ), -21, 9 )

	wait 1
	foreach( player in GetPlayerArray() )
		Remote_CallFunction_NonReplay( player, "ServerCallback_AddCredits", eCredits.ACTOR_GATES )

	wait 1
	vector angles = < 0, 108, 0 >
	file.camera.NonPhysicsRotateTo( angles, 9, 5, 4 )

	wait 4.5
	
	foreach( player in GetPlayerArray() )
		Remote_CallFunction_NonReplay( player, "ServerCallback_DoF_SetNearDepth", 50, 60, 3.5 )
}

void function Actor_Bear_Stuff( entity bear, entity player, vector origin, vector angles, entity davis )
{
	foreach( player in GetPlayerArray() )
	{
		Remote_CallFunction_NonReplay( player, "ServerCallback_DoF_SetFarDepth", 50, 130, 1 )
		Remote_CallFunction_NonReplay( player, "ServerCallback_DoF_SetNearDepth", 20, 32, 1 )
	}

	wait 1
	foreach( player in GetPlayerArray() )
		Remote_CallFunction_NonReplay( player, "ServerCallback_AddCredits", eCredits.ACTOR_BEAR )

	bear.SetPoseParameterOverTime( bear.LookupPoseParameterIndex( "head_yaw" ), 45, 1.0 )
	bear.SetPoseParameterOverTime( bear.LookupPoseParameterIndex( "head_pitch" ), -10, 1.0 )

	wait 1

	file.camera.NonPhysicsMoveTo( origin, 10, 6, 4 )
	file.camera.NonPhysicsRotateTo( angles, 10, 6, 4 )
	davis.Show()

	bear.SetPoseParameterOverTime( bear.LookupPoseParameterIndex( "head_yaw" ), 10, 10 )
	bear.SetPoseParameterOverTime( bear.LookupPoseParameterIndex( "head_pitch" ), -20, 10 )

	wait 1

	bear.Anim_Play( "casual_walkturn_135L" )
	bear.SetPlaybackRate( PLAYBACKRATE )

	wait 11.3

	string anim = "patrol_walk_lowport"
	vector angles = bear.GetAngles()
	vector origin = HackGetDeltaToRef( bear.GetOrigin(), angles, bear, anim )

	entity anchor = CreateScriptMover( origin, angles )
//	anchor.SetOrigin( origin )
//	anchor.SetAngles( angles )
	bear.SetParent( anchor, "", false, 0 )
	bear.Anim_Play( anim )
	bear.SetPlaybackRate( PLAYBACKRATE )

	bear.WaitSignal( "OnDestroy" )
	anchor.Destroy()
}

void function Actor_Davis_Stuff( entity davis, entity anchor1, entity player )
{
	foreach( player in GetPlayerArray() )
	{
		Remote_CallFunction_NonReplay( player, "ServerCallback_DoF_SetFarDepth", 50, 100, 2 )
		Remote_CallFunction_NonReplay( player, "ServerCallback_DoF_SetNearDepth", 8, 20, 2 )
	}

	wait 1
	foreach( player in GetPlayerArray() )
		Remote_CallFunction_NonReplay( player, "ServerCallback_AddCredits", eCredits.ACTOR_DAVIS )

	wait 4.5
	anchor1.NonPhysicsMoveTo( anchor1.GetOrigin() + <0,0,16>, 12, 3, 6 )

	davis.SetPoseParameterOverTime( davis.LookupPoseParameterIndex( "head_yaw" ), 0, 3.5 )
}

void function Actor_Droz_Stuff( entity droz, entity player )
{
	wait 1
	foreach( player in GetPlayerArray() )
		Remote_CallFunction_NonReplay( player, "ServerCallback_AddCredits", eCredits.ACTOR_DROZ )
}

/************************************************************************************************\

███╗   ██╗███████╗██╗    ██╗    ██████╗ ████████╗
████╗  ██║██╔════╝██║    ██║    ██╔══██╗╚══██╔══╝
██╔██╗ ██║█████╗  ██║ █╗ ██║    ██████╔╝   ██║
██║╚██╗██║██╔══╝  ██║███╗██║    ██╔══██╗   ██║
██║ ╚████║███████╗╚███╔███╔╝    ██████╔╝   ██║
╚═╝  ╚═══╝╚══════╝ ╚══╝╚══╝     ╚═════╝    ╚═╝

\************************************************************************************************/
void function NewBT_Main( entity player )
{
	foreach( player in GetPlayerArray() )
		Credits_Part2( player )

	wait 3

	entity anchor1	= GetEntByScriptName( "animref_drop_hangar_titan_2" )
	entity titan 	= CreatePropDynamic( MODEL_BT )
	titan.SetSkin( 4 )
	entity marvin1 	= CreatePropDynamic( MARVIN_MODEL )
	entity rack	 	= GetEntByScriptName( "hangar_titan_rack_2" )

	vector origin = rack.GetOrigin()
	vector angles = rack.GetAngles()

	titan.SetParent( anchor1 )
	titan.Anim_Play( "bt_TDay_drop_titan3_credits" )
	titan.SetPlaybackRate( PLAYBACKRATE )

	rack.SetParent( anchor1 )
	rack.Anim_Play( "rack_TDay_drop_rack3" )
	rack.Anim_SetInitialTime( 19 )
	rack.SetPlaybackRate( PLAYBACKRATE )

	marvin1.SetParent( anchor1 )
	marvin1.Anim_Play( "mv_TDay_drop_marvin3" )
	marvin1.Anim_SetInitialTime( 19 )
	marvin1.SetPlaybackRate( PLAYBACKRATE )

	entity anchor2	= CreateOwnedScriptMover( GetEntByScriptName( "newBT_marv1" ) )
	entity marvin2 	= CreatePropDynamic( MARVIN_MODEL )
	marvin2.SetParent( anchor2 )
	marvin2.Anim_Play( "mv_idle_weld" )
	marvin2.SetPlaybackRate( PLAYBACKRATE )

	entity anchor3	= CreateOwnedScriptMover( GetEntByScriptName( "newBT_marv2" ) )
	entity marvin3 	= CreatePropDynamic( MARVIN_MODEL )
	marvin3.SetParent( anchor3 )
	marvin3.Anim_Play( "mv_idle_weld" )
	marvin3.Anim_SetInitialTime( 7 )
	marvin3.SetPlaybackRate( PLAYBACKRATE )

	entity anchor4	= CreateOwnedScriptMover( GetEntByScriptName( "newBT_marv3" ) )
	entity marvin4 	= CreatePropDynamic( MARVIN_MODEL )
	marvin4.SetParent( anchor4 )
	marvin4.Anim_Play( "mv_weld_under" )
	marvin4.Anim_SetInitialTime( 3 )
	marvin4.SetPlaybackRate( PLAYBACKRATE )

	entity anchor0	= CreateOwnedScriptMover( GetEntByScriptName( "newBT_jack" ) )
	entity jack 	= CreateJack()
	jack.SetParent( anchor0 )
	jack.Anim_Play( "jack_injectore_room_villain" )
	jack.Anim_SetInitialTime( 5.8 + 0.9 )
	jack.SetPlaybackRate( PLAYBACKRATE * 0.5 )
	thread NewBT_Jack_Stuff( jack )

	angles = AnglesCompose( angles, <0,180,0> )
	vector forward = AnglesToForward( angles )
	origin += <0,0,60> + forward * -150
	file.camera.SetOrigin( origin )
	file.camera.SetAngles( angles )
	file.camera.NonPhysicsMoveTo( origin + < 0,0,-30 > + forward * -100, 30, 0, 0 )
	file.camera.NonPhysicsRotateTo( angles + < -30,0,0>, 30, 0, 0 )
	
	foreach( player in GetPlayerArray() )
	{
		Remote_CallFunction_NonReplay( player, "ServerCallback_DoF_SetFarDepth", 50, 60 )
		Remote_CallFunction_NonReplay( player, "ServerCallback_DoF_SetNearDepthToDefault" )
		ScreenFadeFromBlack( player, 4.0, 0.3 )
	}

	wait 1
	foreach( player in GetPlayerArray() )
		Remote_CallFunction_NonReplay( player, "ServerCallback_DoF_SetFarDepth", 300, 500, 10 )

	wait 24

	float fadeout = 4.0
	foreach( player in GetPlayerArray() )
		ScreenFadeToBlackForever( player, fadeout )

	wait fadeout + 0.1

	file.camera.ClearParent()
	file.camera.NonPhysicsStop()

	titan.Destroy()
	marvin1.Destroy()
	marvin2.Destroy()
	marvin3.Destroy()
	marvin4.Destroy()
	jack.Destroy()
	anchor0.Destroy()
	anchor1.Destroy()
	anchor2.Destroy()
	anchor3.Destroy()
	anchor4.Destroy()
}

void function NewBT_Jack_Stuff( entity jack )
{
	wait 2
	jack.SetPoseParameterOverTime( jack.LookupPoseParameterIndex( "head_yaw" ), -25, 3.0 )

	wait 15
	jack.SetPoseParameterOverTime( jack.LookupPoseParameterIndex( "head_yaw" ), 10, 5.0 )

	wait 7
	jack.SetPoseParameterOverTime( jack.LookupPoseParameterIndex( "head_yaw" ), 60, 4.5 )
}

/************************************************************************************************\

██████╗  ██████╗  █████╗ ██████╗ ██████╗     ███████╗██╗  ██╗██╗██████╗
██╔══██╗██╔═══██╗██╔══██╗██╔══██╗██╔══██╗    ██╔════╝██║  ██║██║██╔══██╗
██████╔╝██║   ██║███████║██████╔╝██║  ██║    ███████╗███████║██║██████╔╝
██╔══██╗██║   ██║██╔══██║██╔══██╗██║  ██║    ╚════██║██╔══██║██║██╔═══╝
██████╔╝╚██████╔╝██║  ██║██║  ██║██████╔╝    ███████║██║  ██║██║██║
╚═════╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝     ╚══════╝╚═╝  ╚═╝╚═╝╚═╝

\************************************************************************************************/
void function BoardShip_Main( entity player )
{
	waitthread ClimbShip_Main( player )
	waitthread EndShip_Main( player )
}

void function ClimbShip_Main( entity player )
{
	wait BLACKSCREEN_DELAY

	entity node = GetEntByScriptName( "finalShipShip" )
	entity ship = CreatePropDynamic( CROW_HERO_MODEL )
	entity mover = CreateOwnedScriptMover( node )
	SetTeam( ship, TEAM_MILITIA )
	DropshipFX( ship )

	ship.SetParent( mover )
	ship.Anim_Play( "test_fly_idle_act" )
	ship.SetPlaybackRate( PLAYBACKRATE )

	node = GetEntByScriptName( "finalShipSit" )
	entity guy = CreatePropDynamic( TEAM_MIL_GRUNT_MODEL_RIFLE )
	entity anchor = CreateOwnedScriptMover( node )
	anchor.SetParent( ship, "RAMPDOORLIP", true, 0 )

	guy.SetParent( anchor )
	guy.Anim_Play( "pt_guard_seated_bored" )
	guy.SetPlaybackRate( PLAYBACKRATE )

	node = GetEntByScriptName( "finalShipSit2" )
	guy = CreatePropDynamic( TEAM_MIL_GRUNT_MODEL_SMG )
	anchor = CreateOwnedScriptMover( node )
	anchor.SetParent( ship, "RAMPDOORLIP", true, 0 )

	guy.SetParent( anchor )
	guy.Anim_Play( "OG_sit_low_talk" )
	guy.SetPlaybackRate( PLAYBACKRATE )

	node = GetEntByScriptName( "climbShipship" )
	mover.SetAngles( AnglesCompose( node.GetAngles(), <0,90,90> ) )
	mover.SetOrigin( node.GetOrigin() + < -100,0,-7.5> )
	ship.Anim_Play( "crow_credits" )
	ship.SetPlaybackRate( PLAYBACKRATE )

	node = GetEntByScriptName( "climbShipsarah" )
	entity sarah = CreatePropDynamic( MODEL_SARAH )
	anchor = CreateOwnedScriptMover( node )
	anchor.SetParent( ship, "RAMPDOORLIP", true, 0 )

	sarah.SetParent( anchor )
	sarah.Anim_Play( "sa_credits_flight_intro" )
	sarah.Anim_SetInitialTime( 8 )
	sarah.SetPlaybackRate( PLAYBACKRATE )

	node = GetEntByScriptName( "climbShipjack" )
	entity jack = CreateJack()
	anchor = CreateOwnedScriptMover( node )
	anchor.SetParent( ship, "RAMPDOORLIP", true, 0 )

	float initialTime = 19.6
	jack.SetParent( anchor )
	jack.Anim_Play( "jack_intro_scene_OG" )
	jack.Anim_SetInitialTime( initialTime )
	jack.SetPlaybackRate( PLAYBACKRATE )

	entity helmet = CreatePropDynamic( HELMET_MODEL )
	helmet.SetParent( anchor )
	helmet.Anim_Play( "helmet_intro_scene_OG" )
	helmet.Anim_SetInitialTime( initialTime )
	helmet.SetPlaybackRate( PLAYBACKRATE )

	vector origin = node.GetOrigin() + <0,0,55> + node.GetForwardVector() * -80
	file.camera.SetOrigin( origin )
	file.camera.SetAngles( node.GetAngles() + <0,20,0> )
	
	foreach( player in GetPlayerArray() )
	{
		Remote_CallFunction_NonReplay( player, "ServerCallback_DoF_SetFarDepthToDefault" )
		Remote_CallFunction_NonReplay( player, "ServerCallback_DoF_SetNearDepth", 8, 16 )
		ScreenFadeFromBlack( player, 4.0, 0.3 )
	}

	wait 1.5
	file.camera.NonPhysicsMoveTo( node.GetOrigin() + <0,-50,55>, 22, 15, 5 )
	file.camera.NonPhysicsRotateTo( node.GetAngles(), 22, 15, 5 )

	wait 16

	float fadeout = 4.0
	foreach( player in GetPlayerArray() )
		ScreenFadeToBlackForever( player, fadeout )

	wait fadeout + 0.1

	file.camera.NonPhysicsStop()

	mover.Destroy()
}

/************************************************************************************************\

███████╗███╗   ██╗██████╗     ███████╗██╗  ██╗██╗██████╗
██╔════╝████╗  ██║██╔══██╗    ██╔════╝██║  ██║██║██╔══██╗
█████╗  ██╔██╗ ██║██║  ██║    ███████╗███████║██║██████╔╝
██╔══╝  ██║╚██╗██║██║  ██║    ╚════██║██╔══██║██║██╔═══╝
███████╗██║ ╚████║██████╔╝    ███████║██║  ██║██║██║
╚══════╝╚═╝  ╚═══╝╚═════╝     ╚══════╝╚═╝  ╚═╝╚═╝╚═╝

\************************************************************************************************/
const vector FLIGHTDELTA = < 0, -10000, 0 >
const float FLIGHTTIME = 200
void function EndShip_Main( entity player )
{
	wait BLACKSCREEN_DELAY

	entity node = GetEntByScriptName( "finalShipShip" )
	entity ship = CreatePropDynamic( CROW_HERO_MODEL )
	entity mover = CreateOwnedScriptMover( node )
	SetTeam( ship, TEAM_MILITIA )
	DropshipFX( ship )

	ship.SetParent( mover )
	ship.Anim_Play( "test_fly_idle_act" )
	ship.SetPlaybackRate( PLAYBACKRATE )

	node = GetEntByScriptName( "finalShipSeat" )
	entity seat = CreatePropDynamic( MODEL_SEAT, node.GetOrigin(), node.GetAngles() )
	seat.DisableHibernation()
	seat.SetParent( ship, "ORIGIN", true )
	seat.MarkAsNonMovingAttachment()

	node = GetEntByScriptName( "finalShipSit" )
	entity guy = CreatePropDynamic( TEAM_MIL_GRUNT_MODEL_RIFLE )
	entity anchor = CreateOwnedScriptMover( node )
	anchor.SetParent( ship, "ORIGIN", true, 0 )

	guy.SetParent( anchor )
	guy.Anim_Play( "pt_guard_seated_bored" )
	guy.SetPlaybackRate( PLAYBACKRATE )

	node = GetEntByScriptName( "finalShipSit2" )
	guy = CreatePropDynamic( TEAM_MIL_GRUNT_MODEL_SMG )
	anchor = CreateOwnedScriptMover( node )
	anchor.SetParent( ship, "ORIGIN", true, 0 )

	guy.SetParent( anchor )
	guy.Anim_Play( "OG_sit_low_talk" )
	guy.SetPlaybackRate( PLAYBACKRATE )

	node = GetEntByScriptName( "finalShipCooper" )
	entity jack = CreateJack()
	anchor = CreateOwnedScriptMover( node )
	anchor.SetParent( ship, "ORIGIN", true, 0 )

	jack.SetParent( anchor )
	jack.Anim_Play( "pt_O2_finale_credits" )
	jack.Anim_SetInitialTime( 30.5 )
	jack.SetPlaybackRate( PLAYBACKRATE )

	node = GetEntByScriptName( "finalShippilot" )
	entity barker = CreatePropDynamic( MODEL_BARKER )
	anchor = CreateOwnedScriptMover( node )
	anchor.SetParent( ship, "ORIGIN", true, 0 )

	barker.SetParent( anchor )
	barker.Anim_Play( "sa_credits_flight_pilot" )
	barker.Anim_SetInitialTime( 2.5 )
	barker.SetPlaybackRate( PLAYBACKRATE )

	entity sarah = CreatePropDynamic( MODEL_SARAH )
	sarah.SetParent( ship, "ORIGIN" )
	sarah.Anim_Play( "sa_credits_flight_middle" )
	sarah.Anim_SetInitialTime( 1.5 )
	sarah.SetPlaybackRate( PLAYBACKRATE )
	
	foreach( player in GetPlayerArray() )
	{
		Remote_CallFunction_NonReplay( player, "ServerCallback_CsmTexelScale", 0.5, 1.5 )
		Remote_CallFunction_NonReplay( player, "ServerCallback_DoF_SetFarDepthToDefault" )
		Remote_CallFunction_NonReplay( player, "ServerCallback_DoF_SetNearDepth", 8, 16 )
		ScreenFadeFromBlack( player, 4.0, 0.3 )
	}

	thread EndShip_Camera( ship )
	thread EndShip_SarahAndGuys( sarah, ship )
	thread EndShip_Ship( ship, player )
	thread EndShip_SkyCam()
	thread EndShip_Crows()
	thread EndShip_Trinity()

	ship.Anim_Play( "idle" )
	ship.SetPlaybackRate( PLAYBACKRATE )

	FlagWait( "CreditsOver" )
	float waitTime = 3
	wait waitTime

	float fadeout = 5.0
	foreach( player in GetPlayerArray() )
		ScreenFadeToBlackForever( player, fadeout )
	float finalWait = fadeout + 7.0 - waitTime

	delaythread( finalWait - 2.0 ) StopMusic()

	wait finalWait

	EndEvent()

	wait 10
}

void function EndShip_Crows()
{
	entity node = GetEntByScriptName( "finalShipShip" )
	delaythread( 60 ) EndShip_CrowThink( node.GetOrigin() + < -222, 400, 90 > )
	thread EndShip_CrowThink( node.GetOrigin() + < 150, -500, 250 > )
	thread EndShip_CrowThink( node.GetOrigin() + < -300, -1000, 450 > )
	thread EndShip_CrowThink( node.GetOrigin() + < -500, 600, 0 > )
	thread EndShip_CrowThink( node.GetOrigin() + < -800, 900, -100 > )

	float x, y, z
	while( 1 )
	{
		x = RandomFloatRange( 50, 500 )
		z = RandomFloatRange( 50, 500 )
		y = 0

		if ( CoinFlip() )
			x *= -1
		if ( CoinFlip() )
			z *= -1

		if ( CoinFlip() )
		{
			x = RandomFloatRange( 800, 2800 )
			z = RandomFloatRange( 0, 250 )
			y = -100
		}

		thread EndShip_CrowThink( file.camera.GetOrigin() + <x,y,z - 30> )
		wait RandomFloatRange( 2, 5 ) + 5
	}
}

void function EndShip_Trinity()
{
	entity node = GetEntByScriptName( "finalShipShip" )
	thread EndShip_TrinityThink( node.GetOrigin() + < -2000, 100, 170 > )
	thread EndShip_TrinityThink( node.GetOrigin() + < 1500, -3000, 600 > )
	thread EndShip_TrinityThink( node.GetOrigin() + < 600, 3500, -350 > )
	thread EndShip_TrinityThink( node.GetOrigin() + < 3000, -600, 0 > )
}

void function EndShip_TrinityThink( vector origin )
{
	entity node = GetEntByScriptName( "finalShipShip" )
	float y = node.GetOrigin().y + FLIGHTDELTA.y

	entity ship = CreateScriptMoverModel( MODEL_TRINITY_X, origin, <0,-90,0> )
	ship.EnableRenderAlways()
	vector origin = < ship.GetOrigin().x, y, ship.GetOrigin().z >
	float timeLeft = FLIGHTTIME * 1.5

	ship.NonPhysicsMoveTo( origin, timeLeft, 0, 0 )
	wait timeLeft
}

void function EndShip_CrowThink( vector origin )
{
	entity node = GetEntByScriptName( "finalShipShip" )
	float y = node.GetOrigin().y + FLIGHTDELTA.y

	entity ship = CreateScriptMoverModel( MODEL_CROW_X, origin, <0,-90,0> )
	ship.EnableRenderAlways()
	SetTeam( ship, TEAM_MILITIA )
	vector origin = < ship.GetOrigin().x, y, ship.GetOrigin().z >
	float timeLeft = FLIGHTTIME

	float endTime = Time() + FLIGHTTIME
	float side = 1.0
	if ( CoinFlip() )
		side = -1.0

	ship.NonPhysicsMoveTo( origin, FLIGHTTIME, 0, 0 )

	while( Time() < endTime )
	{
		float mag = RandomFloatRange( 1, 2 )
		vector offset = < 500 * mag * -side, 0, 0 >
		vector angles = < 0, -90, 7 * mag * side >
		float time = 10 * mag

		ship.NonPhysicsRotateTo( angles, time, time * 0.25, time * 0.75 )

		wait time
		timeLeft -= time
		side *= -1.0
	}

	ship.Destroy()
}

void function EndShip_SkyCam()
{
	entity skycam = GetEnt( "skybox_cam_skyway_harmony" )
	vector origin = skycam.GetOrigin()
	origin += < 250, 200, 50 >
	skycam.SetOrigin( origin )

	entity skyMover = CreateOwnedScriptMover( skycam )
	skycam.SetParent( skyMover )
	skyMover.NonPhysicsMoveTo( origin + < -50, -250, 0>, 45, 0, 10 )

	wait 48.9
	skyMover.NonPhysicsMoveTo( origin, 15, 5, 10 )
}

void function EndShip_Ship( entity ship, entity player )
{
	entity mover = ship.GetParent()

	mover.NonPhysicsRotateTo( <0,-80, -10>, 8, 0, 8 )
	wait 8

	mover.NonPhysicsRotateTo( <0,-100, 12>, 15, 7, 7 )
	wait 14.9

	mover.NonPhysicsRotateTo( <0,-80, -20>, 20, 5, 5 )
	wait 20

	mover.NonPhysicsRotateTo( <0, -90, 0>, 6, 3, 3 )
	wait 2.8

	//Remote_CallFunction_NonReplay( player, "ServerCallback_DoF_SetNearDepth", 200, 250, 0.1 )
	wait 0.8

	//Remote_CallFunction_NonReplay( player, "ServerCallback_DoF_SetNearDepth", 8, 16, 0.1 )
	wait 2.4

	mover.NonPhysicsRotateTo( <0,-90, -10>, 10, 5, 5 )
	mover.NonPhysicsMoveTo( mover.GetOrigin() + < 200,0,0> + FLIGHTDELTA, 20, 20, 0 )
	wait 10

	mover.NonPhysicsRotateTo( <0,-90, 15>, 7, 3, 3 )
	wait 7

	mover.NonPhysicsRotateTo( <0,-90, -10>, 7, 3, 3 )
	wait 3

	WarpoutEffect( ship )
	wait 5

	mover.Destroy()
}

void function EndShip_SarahAndGuys( entity sarah, entity ship )
{
	wait 15.4

	sarah.Anim_Play( "sa_credits_flight_end" )
	sarah.Anim_SetInitialTime( 1.75 )
	sarah.SetPlaybackRate( PLAYBACKRATE )

	entity guy = CreatePropDynamic( TEAM_MIL_GRUNT_MODEL_SHOTGUN )
	guy.SetParent( ship, "ORIGIN" )
	guy.Anim_Play( "Classic_MP_flyin_exit_playerB_idle" )
	guy.SetPlaybackRate( PLAYBACKRATE )
	entity gun = CreatePropDynamic( MODEL_MASTIFF, <0,0,0> )
	gun.SetParent( guy, "PROPGUN" )

	guy = CreatePropDynamic( TEAM_MIL_GRUNT_MODEL_LMG )
	guy.SetParent( ship, "ORIGIN" )
	guy.Anim_Play( "Classic_MP_flyin_exit_playerC_idle" )
	guy.SetPlaybackRate( PLAYBACKRATE )
	gun = CreatePropDynamic( MODEL_R101, <0,0,0> )
	gun.SetParent( guy, "PROPGUN" )

	wait 32

	entity node = GetEntByScriptName( "finalShipSit3" )
	guy = CreatePropDynamic( TEAM_MIL_GRUNT_MODEL_LMG )
	entity anchor = CreateOwnedScriptMover( node )
	anchor.SetParent( ship, "", true, 0 )
	anchor.NonPhysicsSetMoveModeLocal( true )
	vector origin = anchor.GetLocalOrigin()
	anchor.SetLocalOrigin( origin + < -25,10,8> )
	anchor.NonPhysicsMoveTo( origin + < -5,4,0>, 3, 0, 1.5 )

	guy.SetParent( anchor )
	guy.Anim_Play( "pt_guard_seated_drink" )
	guy.SetPlaybackRate( PLAYBACKRATE )
}

void function EndShip_Camera( entity ship )
{
	file.camera.SetParent( ship, "ORIGIN" )
	file.camera.SetLocalOrigin( <120,0,0> )
	file.camera.SetLocalAngles( < -7,0,0> )
	file.camera.NonPhysicsSetMoveModeLocal( true )
	file.camera.NonPhysicsSetRotateModeLocal( true )
	wait 3

	file.camera.NonPhysicsMoveTo( <100,0,0>, 8.5, 6.4, 2 )
	wait 5.0

	file.camera.NonPhysicsRotateTo( < 15,-75,0>, 5.5, 3, 1 )
	wait 4.9

	file.camera.NonPhysicsMoveTo( < -7,-63.5,-13 >, 11, 2, 9.0 )
	wait 1.0
	file.camera.NonPhysicsRotateTo( <0,-20,0>, 6, 0.5, 4 )
	wait 11.5

	file.camera.NonPhysicsRotateTo( <0,90,0>, 15, 5, 5 )
	wait 16

	file.camera.NonPhysicsMoveTo( < 7,-88,-18>, 7, 3, 2 )
	file.camera.NonPhysicsRotateTo( < 0,50,0>, 7, 3, 2 )
	wait 7

	file.camera.ClearParent()

	file.camera.NonPhysicsMoveTo( file.camera.GetOrigin() + < -100,-100,0>, 5, 3, 2 )
	file.camera.NonPhysicsRotateTo( <0,-90,0>, 10, 5, 3 )

	wait 5
	file.camera.NonPhysicsMoveTo( file.camera.GetOrigin() + < -100,650,0>, 16, 12, 4 )
}

bool function ClientCallback_CreditsOver( entity player, array<string> args )
{
	FlagSet( "CreditsOver" )
	return true
}

void function DropshipFX( entity ship )
{

	int index 		= ship.LookupAttachment( "IntLightCockpit1" )
	StartParticleEffectOnEntity( ship,  GetParticleSystemIndex( FX_DLIGHT_COCKPIT ), FX_PATTACH_POINT_FOLLOW, index )
}

/************************************************************************************************\

███████╗██╗███╗   ██╗ █████╗ ██╗         ██╗███╗   ███╗ █████╗  ██████╗ ███████╗
██╔════╝██║████╗  ██║██╔══██╗██║         ██║████╗ ████║██╔══██╗██╔════╝ ██╔════╝
█████╗  ██║██╔██╗ ██║███████║██║         ██║██╔████╔██║███████║██║  ███╗█████╗
██╔══╝  ██║██║╚██╗██║██╔══██║██║         ██║██║╚██╔╝██║██╔══██║██║   ██║██╔══╝
██║     ██║██║ ╚████║██║  ██║███████╗    ██║██║ ╚═╝ ██║██║  ██║╚██████╔╝███████╗
╚═╝     ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝    ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝

\************************************************************************************************/
void function FinalImage_Main( entity player )
{
	EmitSoundOnEntity( player, "skyway_scripted_credits_helmet_roomtone" )

	wait 1.0

	GetEntByScriptName( "outer_ring" ).Hide()
	GetEntByScriptName( "middle_ring" ).Hide()
	GetEntByScriptName( "inner_ring" ).Hide()

	entity spacenode = GetEnt( "spacenode_2" )
	entity spacenodeEnd = GetEnt( "spacenode_end_move" )

	entity mover = CreateEntity( "point_viewcontrol" )
	mover.kv.spawnflags = 56 // infinite hold time, snap to goal angles, make player non-solid

	mover.SetOrigin( spacenode.GetOrigin() )
	mover.SetAngles( spacenode.GetAngles() )
	DispatchSpawn( mover )

	entity skyCamHarmony = GetEnt( "skybox_cam_skyway_harmony" )
	skyCamHarmony.ClearParent()
	skyCamHarmony.SetOrigin( file.skycam_origin )
	skyCamHarmony.SetAngles( file.skycam_angles )
	
	foreach( player in GetPlayerArray() )
	{
		player.SetSkyCamera( skyCamHarmony )
		player.LerpSkyScale( 0.0, 0.01 )
		player.SetOrigin( spacenodeEnd.GetOrigin() )
		player.SetParent( mover, "", false, 0.0 )
		player.Hide()
		ViewConeZero( player )
		player.SetViewEntity( mover, true )
	}

	entity trueMover = CreateScriptMover()
	trueMover.SetOrigin( mover.GetOrigin() )
	trueMover.SetAngles( mover.GetAngles() )

	mover.SetParent( trueMover )

	trueMover.SetOrigin( spacenodeEnd.GetOrigin() )
	
	foreach( player in GetPlayerArray() )
	{
		Remote_CallFunction_NonReplay( player, "ServerCallback_CsmTexelScale", 0.1, 0.1 )
		Remote_CallFunction_NonReplay( player, "ServerCallback_DoF_SetNearDepth", 0, 10 )
		Remote_CallFunction_NonReplay( player, "ServerCallback_DoF_SetFarDepth", 1000, 2000 )
	}

	wait 1.0
	
	foreach( player in GetPlayerArray() )
		ScreenFadeFromBlack( player, 0.1 )

	wait 4
	
	foreach( player in GetPlayerArray() )
		Remote_CallFunction_Replay( player, "ServerCallback_BeginHelmetBlink" )

	wait 900
}
#endif

/************************************************************************************************\

 ██████╗██╗     ██╗███████╗███╗   ██╗████████╗
██╔════╝██║     ██║██╔════╝████╗  ██║╚══██╔══╝
██║     ██║     ██║█████╗  ██╔██╗ ██║   ██║
██║     ██║     ██║██╔══╝  ██║╚██╗██║   ██║
╚██████╗███████╗██║███████╗██║ ╚████║   ██║
 ╚═════╝╚══════╝╚═╝╚══════╝╚═╝  ╚═══╝   ╚═╝

\************************************************************************************************/
#if CLIENT

const int ZDEPTH = 32000
const float STANDARD_DELAY = 0.5


struct MyFile
{
	array<void functionref()> creditNameFuncs
	table<int, void functionref()> registeredFuncs
	float defaultColumn = COLUMN_CENTER
}
MyFile file

void function Credits_Init_Client()
{
	FlagInit( "AddingCredits" )

	file.registeredFuncs[ eCredits.COLUMN_CENTER ] 		<- SetColumnCenter
	file.registeredFuncs[ eCredits.COLUMN_LEFT ] 		<- SetColumnLeft
	file.registeredFuncs[ eCredits.COLUMN_RIGHT ] 		<- SetColumnRight

	file.registeredFuncs[ eCredits.DIRECTORS ] 	<- Add_Directors
	file.registeredFuncs[ eCredits.ENGINEERS ] 	<- Add_Engineers
	file.registeredFuncs[ eCredits.DESIGNERS ] 	<- Add_Designers
	file.registeredFuncs[ eCredits.ARTISTS ] 	<- Add_Artists
	file.registeredFuncs[ eCredits.VFX ] 		<- Add_VFX
	file.registeredFuncs[ eCredits.ANIMATORS ] 	<- Add_Animators
	file.registeredFuncs[ eCredits.AUDIO ] 		<- Add_Audio
	file.registeredFuncs[ eCredits.OFFICERS ] 	<- Add_Officers
	file.registeredFuncs[ eCredits.PRODUCTION ] <- Add_Production
	file.registeredFuncs[ eCredits.ADMIN ] 		<- Add_Admin
	file.registeredFuncs[ eCredits.IT ] 		<- Add_IT
	file.registeredFuncs[ eCredits.MUSIC ] 		<- Add_Music
	file.registeredFuncs[ eCredits.WRITING ] 	<- Add_Writing

	file.registeredFuncs[ eCredits.ACTOR_COOPER ] 		<- Add_Actor_Cooper
	file.registeredFuncs[ eCredits.ACTOR_BT ] 			<- Add_Actor_BT
	file.registeredFuncs[ eCredits.ACTOR_OG ] 			<- Add_Actor_OG
	file.registeredFuncs[ eCredits.ACTOR_SARAH ]		<- Add_Actor_Sarah
	file.registeredFuncs[ eCredits.ACTOR_BARKER ]		<- Add_Actor_Barker
	file.registeredFuncs[ eCredits.ACTOR_GATES ]		<- Add_Actor_Gates
	file.registeredFuncs[ eCredits.ACTOR_BEAR ]			<- Add_Actor_Bear
	file.registeredFuncs[ eCredits.ACTOR_DAVIS ]		<- Add_Actor_Davis
	file.registeredFuncs[ eCredits.ACTOR_DROZ ]			<- Add_Actor_Droz
	file.registeredFuncs[ eCredits.ACTOR_BLISK ]		<- Add_Actor_Blisk
	file.registeredFuncs[ eCredits.ACTOR_MARDER ]		<- Add_Actor_Marder
	file.registeredFuncs[ eCredits.ACTOR_ASH ]			<- Add_Actor_Ash
	file.registeredFuncs[ eCredits.ACTOR_KANE ]			<- Add_Actor_Kane
	file.registeredFuncs[ eCredits.ACTOR_RICHTER ]		<- Add_Actor_Richter
	file.registeredFuncs[ eCredits.ACTOR_VIPER ]		<- Add_Actor_Viper
	file.registeredFuncs[ eCredits.ACTOR_SLONE ]		<- Add_Actor_Slone

	file.registeredFuncs[ eCredits.CAST ]		<- Add_Cast
	file.registeredFuncs[ eCredits.QA ]		 	<- Add_QA
	file.registeredFuncs[ eCredits.PLAYFIGHT ]	<- Add_Playfight
	file.registeredFuncs[ eCredits.DARKBURN ]	<- Add_Darkburn
	file.registeredFuncs[ eCredits.MULTIPLAY ]	<- Add_MultiPlay
	file.registeredFuncs[ eCredits.SPOV ]		<- Add_Spov
	file.registeredFuncs[ eCredits.GLASSEGG ]	<- Add_GlassEgg
	file.registeredFuncs[ eCredits.VIRTUOS ]	<- Add_Virtuos
	file.registeredFuncs[ eCredits.ADDITIONAL ]	<- Add_Additional
	file.registeredFuncs[ eCredits.THANKS ]		<- Add_Thanks
	file.registeredFuncs[ eCredits.BABIES ]		<- Add_Babies
	file.registeredFuncs[ eCredits.EA ]			<- Add_EA
	file.registeredFuncs[ eCredits.MICROSOFT ]	<- Add_Microsoft
	file.registeredFuncs[ eCredits.SONY ]		<- Add_Sony
	file.registeredFuncs[ eCredits.LEGAL ]		<- Add_Legal
	file.registeredFuncs[ eCredits.END ]		<- EndCredits
	file.registeredFuncs[ eCredits.NORTHSTAR_DEVS ] <- Add_Northstar_Devs
}

void function SetColumnCenter()
{
	file.defaultColumn = COLUMN_CENTER
}

void function SetColumnLeft()
{
	file.defaultColumn = COLUMN_LEFT
}

void function SetColumnRight()
{
	file.defaultColumn = COLUMN_RIGHT
}

void function Add_Directors()
{
	var logo = RuiCreate( $"ui/credits_company_logo.rpak", clGlobal.topoFullScreen, RUI_DRAW_HUD, ZDEPTH )
	RuiSetGameTime( logo, "startTime", Time() )

	wait 3.0

	Add_Title( "Game Director" )
	Add_Name( "Steve Fukuda" )
	wait STANDARD_DELAY

	Add_Title( "Technical Director" )
	Add_Name( "Richard A. Baker" )
	wait STANDARD_DELAY
}

void function Add_Engineers()
{
	Add_Title( "Engineering" )

	Add_SubtitleName( "Lead Software Engineer", 	"Earl Hammon, Jr." )
	Add_SubtitleName( "Lead Software Engineer", 	"Jon 'Slothy' Shiring" )
	Add_SubtitleName( "Lead Software Engineer", 	"Jiesang Song" )

	Add_SubtitleName( "Senior Software Engineer", 	"Chad Barb" )
	Add_SubtitleName( "Senior Software Engineer", 	"Gilles Cadet" )
	Add_SubtitleName( "Senior Software Engineer", 	"Jon Davis" )
	Add_SubtitleName( "Senior Software Engineer", 	"Joel Gompert" )
	Add_SubtitleName( "Senior Software Engineer", 	"John Haggerty" )
	Add_SubtitleName( "Senior Software Engineer", 	"Roger Hughston" )
	Add_SubtitleName( "Senior Software Engineer", 	"Mike Kalas" )
	Add_SubtitleName( "Senior Software Engineer", 	"Steve Marton" )
	Add_SubtitleName( "Senior Software Engineer", 	"Rayme C. Vinson" )

	Add_SubtitleName( "Software Engineer", 			"Joel Conger" )
	Add_SubtitleName( "Software Engineer", 			"Justin Cook" )
	Add_SubtitleName( "Software Engineer", 			"Michael Durnhofer" )
	Add_SubtitleName( "Software Engineer", 			"Xin Liu" )
	Add_SubtitleName( "Software Engineer", 			"Steven Kah Hien Wong" )
	wait STANDARD_DELAY
}

void function Add_Designers()
{
	Add_Title( "Design" )

	Add_SubtitleName( "Multiplayer Design Lead", 	"Todd Alderman" )
	Add_SubtitleName( "Singleplayer Design Lead", 	"Mackey McCandlish" )
	Add_SubtitleName( "Lead Game Designer", 		"Jason McCord" )
	Add_SubtitleName( "Lead Game Designer", 		"Brent McLeod" )
	Add_SubtitleName( "Lead Game Designer", 		"Geoffrey Bickford Smith" )

	Add_SubtitleName( "Senior Game Designer", "Roger Abrahamsson" )
	Add_SubtitleName( "Senior Game Designer", "Mohammad Alavi" )
	Add_SubtitleName( "Senior Game Designer", "Chris 'Soupy' Dionne" )
	Add_SubtitleName( "Senior Game Designer", "Preston Glenn" )
	Add_SubtitleName( "Senior Game Designer", "Chad Grenier" )
	Add_SubtitleName( "Senior Game Designer", "Jake Keating " )
	Add_SubtitleName( "Senior Game Designer", "Ryan Redetzke" )
	Add_SubtitleName( "Senior Game Designer", "Alexander Roycewicz" )
	Add_SubtitleName( "Senior Game Designer", "Sean Slayback" )

	Add_SubtitleName( "Game Designer", "Chin Xiang Chong" )
	Add_SubtitleName( "Game Designer", "Griffin Brennan Dean" )
	Add_SubtitleName( "Game Designer", "Steven DeRose" )
	Add_SubtitleName( "Game Designer", "Carlos Emmanuel Pineda" )
	Add_SubtitleName( "Game Designer", "David Shaver" )
	Add_SubtitleName( "Game Designer", "Davis Freeborn Standley" )
	Add_SubtitleName( "Game Designer", "Nathan Tullis" )
	Add_SubtitleName( "Game Designer", "Chuck Wilson" )
	wait STANDARD_DELAY
}

void function Add_Artists()
{
	Add_Title( "Art Director" )
	Add_Name( "Joel Emslie" )
	wait STANDARD_DELAY

	Add_Title( "Environment Art Director" )
	Add_Name( "Todd Sue" )
	wait STANDARD_DELAY

	Add_Title( "Art" )
	Add_SubtitleName( "Lead Environment Artist", "Robert Taube" )
	Add_SubtitleName( "Lead 3D Artist", "Ryan M. Lastimosa" )
	Add_SubtitleName( "Lead Concept Artist", "Jung Park" )
	Add_SubtitleName( "Senior Technical Artist", "Chris Shelton" )
	Add_SubtitleName( "Senior Artist", "Brad Allen" )
	Add_SubtitleName( "Senior Environment Artist", "Kristen Carrie-Wong Altamirano" )
	Add_SubtitleName( "Senior Environment Artist", "Michael Cristobal Altamirano" )
	Add_SubtitleName( "Senior Environment Artist", "Austin Arnett" )
	Add_SubtitleName( "Senior Environment Artist", "Tri Do" )
	Add_SubtitleName( "Senior Environment Artist", "Jacob Virginia" )
	Add_SubtitleName( "Senior Environment Artist", "Lewis Walden" )
	Add_SubtitleName( "Senior Environment Artist", "Robert Wilinski" )
	Add_SubtitleName( "Senior Environment Artist", "Jose Zavala" )
	Add_SubtitleName( "Environment Artist", "David Brumbley" )
	Add_SubtitleName( "Environment Artist", "Josh Dunnam" )
	Add_SubtitleName( "Environment Artist", "Tragan Monaghan" )
	Add_SubtitleName( "Senior 3D Artist", "Brian Burrell" )
	Add_SubtitleName( "Senior 3D Artist", "William Cho" )
	Add_SubtitleName( "Senior 3D Artist", "Wonjae Kim" )
	Add_SubtitleName( "Senior 3D Artist", "Robb Shoberg" )
	Add_SubtitleName( "3D Artist", "Corwin N. Paradinha" )
	Add_SubtitleName( "Senior Character Artist", "Kevin Anderson" )
	Add_SubtitleName( "Senior Character Artist", "Jason Hill" )
	Add_SubtitleName( "Senior Character Artist", "Regie Santiago" )
	Add_SubtitleName( "Senior Concept Artist", "Cliff Childs" )
	Add_SubtitleName( "Senior Concept Artist", "Rodrigo Ribeiro" )
	Add_SubtitleName( "Senior Concept Artist", "Hethe Srodawa" )
	Add_SubtitleName( "Concept Artist", "Danny Gardner" )
	Add_SubtitleName( "Senior Matte and Concept Artist", "Tu Bui" )
	Add_SubtitleName( "Matte Painter", "Ethan Ayer" )
	wait STANDARD_DELAY
}

void function Add_VFX()
{
	Add_Title( "Visual FX" )
	Add_SubtitleName( "Lead VFX Artist", "Robert 'RoBoT' Gaines" )
	Add_SubtitleName( "Senior VFX Artist", "Ryan 'BigRig' Ehrenberg" )
	Add_SubtitleName( "VFX Artist", "Jason Burton" )
	wait STANDARD_DELAY
}

void function Add_Animators()
{
	Add_Title( "Animation" )
	Add_SubtitleName( " Lead Animator", "Mark Grigsby" )
	Add_SubtitleName( " Lead Animator", "Paul Messerly" )
	Add_SubtitleName( "Motion Capture Expert", "Mario Perez" )
	Add_SubtitleName( "Senior Technical Animator", "Cheng Kou Lor" )
	Add_SubtitleName( "Technical Animator", "Sungwoo Bae" )
	Add_SubtitleName( "Senior Animator", "Bruce Ferriz" )
	Add_SubtitleName( "Senior Animator", "Shawn Lee Wilson" )
	Add_SubtitleName( "Animator", "Moy Parra" )
	Add_SubtitleName( "Animator", "Laure Retif" )
	Add_SubtitleName( "Animator", "Ranon Sarono" )

	wait STANDARD_DELAY
}

void function Add_Audio()
{
	Add_Title( "Senior Audio Director" )
	Add_Name( "Erik Kraber" )
	wait STANDARD_DELAY

	Add_Title( "Audio" )
	Add_SubtitleName( "Music Lead", "Nick Laviers" )
	Add_SubtitleName( "Dialogue Lead", "Joshua Nelson" )
	Add_SubtitleName( "Senior Sound Designer", "Rick Hernandez" )
	Add_SubtitleName( "Senior Sound Designer", "Steve Johnson" )
	Add_SubtitleName( "Senior Sound Designer", "Tyler Parsons" )
	Add_SubtitleName( "Sound Designer", "Bradley Snyder" )
	Add_SubtitleName( "Contract Sound Designer", "David R. Nazario" )
	Add_SubtitleName( "Dialogue Editor", "Victor Durling" )
	wait STANDARD_DELAY
}

void function Add_Officers()
{
	Add_Title( "CEO" )
	Add_Name( "Vince Zampella" )
	wait STANDARD_DELAY

	Add_Title( "COO" )
	Add_Name( "Dusty Welch" )
	wait STANDARD_DELAY
}

void function Add_Production()
{
	Add_Title( "Head of Development" )
	Add_Name( "David Wightman" )
	wait STANDARD_DELAY

	Add_Title( "Production" )
	Add_SubtitleName( "Senior Producer", "Drew McCoy" )
	Add_SubtitleName( "Producer", "Chris Hughes" )
	Add_SubtitleName( "Producer", "Dom McCarthy" )
	Add_SubtitleName( "Art Producer ", "Madison Cromwell" )
	Add_SubtitleName( "Production Assistant", "Josue Medina" )
	wait STANDARD_DELAY

	Add_Title( "Head of Marketing" )
	Add_Name( "Arturo Castro" )
	wait STANDARD_DELAY

	Add_SubtitleName( "Senior Producer of Game Footage", "Rick Grubel" )
	wait STANDARD_DELAY
}

void function Add_Admin()
{
	Add_Title( "Administration" )
	//Add_SubtitleName( "Office Manager", "Cathie Ichige" )
	Add_SubtitleName( "Human Resources and Recruiting Manager", "Kristin Christopher" )
	Add_SubtitleName( "Human Resources Generalist ", "Alicia 'Keeper of the Cookie Jar' Alunni" )
	Add_SubtitleName( "Executive Assistant", "JoLenna Johnson" )
	Add_SubtitleName( "Controller ", "Logan Miller" )
	Add_SubtitleName( "Recruiter ", "Miriam Anderson" )
	Add_SubtitleName( "Facility Coordinator", "Carlos Rivera" )
	Add_SubtitleName( "Administrative Assistant ", "Amy Fry" )
	Add_SubtitleName( "Office Assistant", "Diana Ryabstev" )
	Add_SubtitleName( "Security Supervisor", "Doug Lopez" )
	wait STANDARD_DELAY
}

void function Add_IT()
{
	Add_Title( "IT" )
	Add_SubtitleName( "IT Manager", "Roni Papouban" )
	Add_SubtitleName( "Systems Administrator", "Jimmie Harlow" )
	Add_SubtitleName( "Network Administrator", "Masseeh Ghafarshad" )
	Add_SubtitleName( "Desktop Support Specialist", "Shane Holloway" )
	Add_SubtitleName( "IT Technician", "Mitchell Norris" )
	wait STANDARD_DELAY
}

void function Add_Music()
{
	Add_Title( "Music Composed By" )
	Add_Name( "Stephen Barton" )
	wait STANDARD_DELAY

	//Add_Title( "Music" )
	Add_SubtitleName( "Score Producers", "Erik Kraber, Nick Laviers, Steve Fukuda and Stephen Barton" )
	Add_SubtitleName( "Score recorded at", "Abbey Road Studios, London" )
	Add_SubtitleName( "Additional Music recorded at", "The Michael Fowler Center, Wellington, NZ" )
	Add_SubtitleName( "Score performed by", "The London Session Orchestra" )
	Add_SubtitleName( "Additional music performed by", "The New Zealand Symphony Orchestra" )
	Add_SubtitleName( "Orchestra Leader", "Perry Montague-Mason" )
	Add_SubtitleName( "Electric Cello", "Peter Gregson" )
	Add_SubtitleName( "Horn Soloist", "Richard Watkins" )
	Add_SubtitleName( "Guitars", "Leo Abrahams" )
	Add_SubtitleName( "Percussion", "Paul Clarvis, Frank Ricotti" )
	Add_SubtitleName( "Orchestra Contractor, London", "Isobel Griffiths Ltd." )
	Add_SubtitleName( "Contracting Assistant, London", "Susie Gillis" )
	Add_SubtitleName( "Orchestra Manager, NZSO", "Usha Bhana" )
	Add_SubtitleName( "Score Recording Engineers", "Sam Okell, Graham Kennedy, Andrew Dudman" )
	Add_SubtitleName( "Pro Tools Engineer", "Matt Jones" )
	Add_SubtitleName( "Studio Manager, Abbey Road", "Fiona Gillott" )
	Add_SubtitleName( "Orchestrations", "Stephen Barton, David Andrew Shipps, Kirk Bennett" )
	Add_SubtitleName( "Score Preparation and Copying", "Jill Streater Music Ltd." )
	Add_SubtitleName( "Librarian, London", "Ann Barnard" )
	Add_SubtitleName( "Librarian, NZSO", "Feby Idrus" )
	Add_SubtitleName( "Score Mix Engineers", "Malcolm Luker, Jonathan Allen, Alan Meyerson" )
	Add_SubtitleName( "Score Mix Assistant", "Jamie Luker" )
	Add_SubtitleName( "Ambient Music Design", "Mel Wesson" )
	Add_SubtitleName( "Synth Patch Design", "Matt Bowdler, Luftrum" )
	Add_SubtitleName( "Synthesist", "Nick Laviers" )
	Add_SubtitleName( "Special Music Thanks To", "Margaret Whitman, Abbey Rose Whitman-Barton" )
	wait STANDARD_DELAY

	Add_Title( "Sound Services provided by Warner Brothers Game Audio" )
	Add_SubtitleName( "Sound Designer", "Bryan Watkins" )
	Add_SubtitleName( "Sound Designer", "Mitch Osias" )
	Add_SubtitleName( "Manager, Gaming Operations and Services", "Emma Weston" )
	Add_SubtitleName( "Recording Engineer", "R. Dutch Hill" )
	Add_SubtitleName( "Recording Engineer", "Alan Freedman, C.A.S." )
	Add_SubtitleName( "Dialogue Editor", "Goeun Lee" )
	Add_SubtitleName( "Dialogue Editor", "Christopher Cody Flick" )
	Add_SubtitleName( "Voice Over Director", "Pierce O'Toole" )
	wait STANDARD_DELAY
}

void function Add_Writing()
{
	Add_Title( "Written By" )
	Add_Name( "Steve Fukuda" )
	Add_Name( "Manny Hagopian" )
	Add_Name( "Jesse Stern" )
	wait STANDARD_DELAY

	Add_Title( "Additional Writing" )
	Add_Name( "Mohammad Alavi" )
	Add_Name( "Sean Slayback" )
	wait STANDARD_DELAY
}

void function Add_Cast()
{
	Add_Title( "Casting Director" )
	Add_Name( "Terri Douglas" )
	wait STANDARD_DELAY

	Add_Title( "Additional Cast" )

	Add_SubtitleName( "Major Eli Anderson", "James Kirkland" )
	Add_SubtitleName( "Captain Cole", "Mark Teich" )

	Add_SubtitleName( "Militia Captain", "Omid Abtahi" )
	Add_SubtitleName( "Militia Soldier", "Ryan Alosio" )
	Add_SubtitleName( "Militia Soldier", "Noshir Dalal" )
	Add_SubtitleName( "Militia Soldier", "Brandon R. Johnson" )

	Add_SubtitleName( "IMC Soldier", "Raphael Corkhill" )
	Add_SubtitleName( "IMC Soldier", "Mark Healy" )
	Add_SubtitleName( "IMC Soldier", "Alan Mckenna" )
	Add_SubtitleName( "IMC Soldier", "Tim Pocock" )
	Add_SubtitleName( "IMC Soldier", "Julian Stone" )
	Add_SubtitleName( "IMC Soldier", "Eric Tiede" )

	Add_SubtitleName( "Tone Titan", "Jocelyn Blue" )
	Add_SubtitleName( "Ion Titan", "Corri English" )
	Add_SubtitleName( "Ronin Titan", "Keith Ferguson" )
	Add_SubtitleName( "Northstar Titan", "Nora-Jane Noone" )
	Add_SubtitleName( "Legion Titan", "David Scheinkopf" )
	Add_SubtitleName( "Scorch Titan", "Rick Wasserman" )

	Add_SubtitleName( "Crow Captain", "Matt Lowe" )

	Add_SubtitleName( "Lifeboat & Systems AI", "Zehra Fazal" )
	Add_SubtitleName( "Testing Facility AI", "Lex Lang" )
	Add_SubtitleName( "Facility AI", "Laura Post" )

	Add_SubtitleName( "Dr. Jefferson Boyle", "Breckin Meyer" )
	Add_SubtitleName( "Scientist", "Jamie Irvine" )
	Add_SubtitleName( "Scientist", "James Lancaster" )
	Add_SubtitleName( "Scientist", "Scott Whyte" )

	Add_SubtitleName( "MP Pilot", "Victoria Atkin" )
	Add_SubtitleName( "MP Pilot", "Paula Jean Hixon" )

	Add_SubtitleName( "Titan Pilot", "Ronald Bottitta" )
	Add_SubtitleName( "Titan Pilot", "Ben Crowe" )
	Add_SubtitleName( "Titan Pilot", "Mitch Eakins" )
	Add_SubtitleName( "Titan Pilot", "Mark Ford" )
	Add_SubtitleName( "Titan Pilot", "David L. Fynn" )
	Add_SubtitleName( "Titan Pilot", "Anthony Garland" )
	Add_SubtitleName( "Titan Pilot", "Devon Graye" )
	Add_SubtitleName( "Titan Pilot", "Dan C. Johnson" )
	Add_SubtitleName( "Titan Pilot", "Graham Shiels" )
	Add_SubtitleName( "Titan Pilot", "Matthew Waterson" )


	wait STANDARD_DELAY

	Add_Title( "MoCap Actors" )
	Add_Name( "Mohammad Alavi" )
	Add_Name( "Kevin Dorman" )
	Add_Name( "Abbie Heppe" )
	Add_Name( "Paul Messerly" )
	Add_Name( "Mark Musashi" )
	Add_Name( "Shawn Wilson" )
	wait STANDARD_DELAY
}

void function Add_QA()
{
	Add_Title( "Quality Assurance" )
	Add_SubtitleName( "QA Manager", "Chris Hughes" )
	Add_SubtitleName( "QA Lead", "Tim Shanks" )
	Add_SubtitleName( "QA Floor Lead", "Felipe Lerma" )

	Add_SubtitleName( "Senior QA Tester", "Paul Barfield" )
	Add_SubtitleName( "Senior QA Tester", "Kyle Fujita" )
	Add_SubtitleName( "Senior QA Tester", "Josue Medina" )

	Add_SubtitleName( "QA Tester", "Leanne Garand" )
	Add_SubtitleName( "QA Tester", "Mark 'BizBear' Grimenstein" )
	Add_SubtitleName( "QA Tester", "Ryan Hakik" )
	Add_SubtitleName( "QA Tester", "Steven Mitchell" )
	Add_SubtitleName( "QA Tester", "Taylor West" )
	wait STANDARD_DELAY

	Add_Title( "Testers" )
	Add_NameTriple( "Daniel Bach", "Eric Baskin", "Edward Boning" )
	Add_NameTriple( "Carolina Camilli", "Sean Castle", "Eric Deerson" )
	Add_NameTriple( "Brian Dionne", "Dennis Duchscher", "Eric Elder" )
	Add_NameTriple( "Chris Galasso", "Jason Garza", "Christian Gomez" )
	Add_NameTriple( "Nicholas Graham", "Josh Green", "Frederick Guese" )
	Add_NameTriple( "Jordan Harmon", "Kevin Howes", "Aunri James" )
	Add_NameTriple( "Mason Kenton", "Bryan Kurtzman", "Kevin Kusch" )
	Add_NameTriple( "Jeffery Kwon", "Paulette Larriva", "John Law" )
	Add_NameTriple( "Natasha Lee", "Moises Lopez", "Brandon Mancilla" )
	Add_NameTriple( "Ian McLeod", "Jonny Mendoza", "Joshua Mendoza" )
	Add_NameTriple( "Andy Milenovic", "Henry Montiel", "Alan Morales" )
	Add_NameTriple( "TJ Mota", "David Rathaus", "Jon Rios" )
	Add_NameTriple( "Mark Ruzicka", "Paula Sar", "Jason Soss" )
	Add_NameTriple( "Tyler Stanton", "Byron Taylor", "Brandon Tepezano" )
	Add_NameTriple( "Torrance Trotter", "Edward Vernon", "Caleb Zavala" )
	wait STANDARD_DELAY
}

void function Add_Playfight()
{
	Add_Title( "Intro Created by: PlayFight" )
	Add_SubtitleName( "Director / Director of Photography", "William Chang" )
	Add_SubtitleName( "Assistant Director", "Ryan Freer" )
	Add_SubtitleName( "Producer", "Brian Huynh" )
	Add_SubtitleName( "Line Producer", "Monica Cote" )
	Add_SubtitleName( "Executive Producer", "Jeff Chan" )
	wait STANDARD_DELAY

	Add_Title( "Intro Post Production Team"  )
	Add_SubtitleName( "Technical Director", "Sang Hoon Hwang"  )
	Add_SubtitleName( "FX Technical Lead", "Stephen Wagner"  )
	Add_SubtitleName( "Compositing Supervisor", "Steven Huynh"  )
	Add_SubtitleName( "CG Supervisor", "Josh George"  )
	Add_SubtitleName( "VFX Generalist", "Sophia Jooyeon Lee"  )
	Add_SubtitleName( "3D & Texture Lead", "Justin Perreault"  )
	Add_SubtitleName( "VFX Generalist", "Melissa Costa"  )
	Add_SubtitleName( "VFX Generalist / Mo Cap", "Shashaank Sreenivasan"  )
	Add_SubtitleName( "VFX Generalist / Mo Cap", "Adam Collver"  )
	Add_SubtitleName( "VFX Generalist", "Spencer Wyatt"  )
	Add_SubtitleName( "Matte Painter", "Jordan Jardine"  )
	Add_SubtitleName( "VFX Generalist", "Calvin Hui"  )
	Add_SubtitleName( "Lead animator / Mo Cap", "Charlie Di Liberto"  )
	Add_SubtitleName( "VFX Generalist", "Miguel Basulto"  )
	Add_SubtitleName( "CG Artist", "Stephen Wagner"  )
	Add_SubtitleName( "Operations Manager", "Unity Hendricks-Chang"  )
	wait STANDARD_DELAY

	Add_Title( "Intro Filming Crew" )
	Add_SubtitleName( "Key Rigger", "Tom Farr" )
	Add_SubtitleName( "Rigger", "Steve 'Shack' Shackleton" )
	Add_SubtitleName( "B Camera Operator", "Patrick Scopick" )
	Add_SubtitleName( "DMT", "Allan Schwartzenberger" )
	Add_SubtitleName( "Gaffer", "Todd Hamacher" )
	Add_SubtitleName( "Best Boy Electric", "Lee Smith" )
	Add_SubtitleName( "Key Grip", "James Gordon" )
	Add_SubtitleName( "Best Boy Grip", "Jake Rogers" )
	Add_SubtitleName( "Swing", "Ashleigh Brady" )
	Add_SubtitleName( "Art Director", "Rui Santos" )
	Add_SubtitleName( "Art Production Assistant", "Robbie Beniuk" )
	Add_SubtitleName( "Set Design", "PunchKlok Ltd." )
	Add_SubtitleName( "Costumes", "Henchmen Props" )
	Add_SubtitleName( "Costume Designer", "Jordan Duncan" )
	Add_SubtitleName( "Assistant Costume Designer", "Nathan Deluca" )
	Add_SubtitleName( "Specialty Costumer", "Alex Sullivan" )
	Add_SubtitleName( "Specialty Props", "Jarrah Brouwer" )
	Add_SubtitleName( "Costumer", "Kiga Tymianski" )
	Add_SubtitleName( "Costumer", "Jacob Johnson" )
	Add_SubtitleName( "Costume Assistant", "James Studer" )
	Add_SubtitleName( "Costume Assistant", "Taryn Krueger" )
	Add_SubtitleName( "Costume Assistant", "Christopher Guidotti" )
	Add_SubtitleName( "Production Assistant", "Makenzie Smith" )
	Add_SubtitleName( "Key Make up / SFX", "Shaun Hunter" )
	Add_SubtitleName( "On Set VFX Supervisor", "Steven Huynh" )
	Add_SubtitleName( "On Set VFX Supervisor", "Sophia Jooyeon Lee" )
	Add_SubtitleName( "Production Assistant", "Josh George" )
	Add_SubtitleName( "Production Assistant", "Melissa Costa" )
	Add_SubtitleName( "Production Assistant", "Shashaank Sreenivasan" )
	Add_SubtitleName( "Production Assistant", "Adam Collver" )
	Add_SubtitleName( "Production Assistant", "Sid Sawant" )
	Add_SubtitleName( "Production Assistant", "Alex Varlis" )
	Add_SubtitleName( "Production Assistant", "Kelvin Lee" )
	wait STANDARD_DELAY

	Add_Title( "Playfight Intro Video Cast" )
	Add_SubtitleName( "Stunt Coordinator / Performer", "Neil Davison" )
	Add_SubtitleName( "Stunt Performer", "Christopher Di Meo" )
	Add_SubtitleName( "Special Skills Extra", "Todd Campbell" )
	Add_SubtitleName( "Special Skills Extra", "Shawn J. Hamilton" )
	Add_SubtitleName( "Special Skills Extra", "Daniel Levinson" )
	Add_SubtitleName( "Special Skills Extra", "AJ Risi" )
	Add_SubtitleName( "Special Skills Extra", "Ben Van Huis" )
	wait STANDARD_DELAY

	Add_SubtitleName( "Location", "Pie West Studios" )
	wait STANDARD_DELAY

	Add_SubtitleName( "Storyboard Artist", "Darren Rawlings" )
	Add_SubtitleName( "Catering", "Rancho Relaxo" )
	Add_SubtitleName( "On Set Paramedic", "Yan Regis" )
	wait STANDARD_DELAY

	Add_Name( "Made with the Generous Support of ACTRA Toronto." )
	wait STANDARD_DELAY
}

void function Add_Darkburn()
{
	Add_Title( "Dark Burn Creative" )
	Add_SubtitleName( "Creative Director", "Chase Boyajian" )
	Add_SubtitleName( "Creative Producer", "Tanner Boyajian" )
	Add_SubtitleName( "Producer", "Andrew William Chan" )
	Add_SubtitleName( "Video Editor and Compositor", "Christopher Harris" )
	Add_SubtitleName( "Video Editor", "Grant Martin" )
	Add_SubtitleName( "Sound Engineer", "Hunter Boyajian" )
	Add_SubtitleName( "Sound Designer", "Eric Marks" )
	Add_SubtitleName( "Capture Director", "Michael Callahan" )
	Add_SubtitleName( "Hero Capture Artist", "Michael Serrano" )
	Add_SubtitleName( "Capture Build Tech", "Danielle Hidalgo" )
	wait STANDARD_DELAY

	Add_Name( "Special Thanks for all the hard work from our capture artists!" )
	wait STANDARD_DELAY
}

void function Add_MultiPlay()
{
	Add_Title( "Multiplay" )
	Add_SubtitleName( "Technical Director", "Steven Hartland" )
	Add_SubtitleName( "Senior Sales Manager", "Isaac Douglas" )
	Add_SubtitleName( "Director of Digital", "Paul Manuel" )
	Add_SubtitleName( "Technical Account Manager", "Jonny Hughes" )
	Add_SubtitleName( "Business Development Manager", "Will Lowther" )
	Add_SubtitleName( "Solutions Architect", "Stuart Muckley" )
	Add_SubtitleName( "Developer", "Andrew Montgomery-Hurrell" )
	Add_SubtitleName( "Senior Dev-ops", "Daniel Offord" )
	Add_SubtitleName( "Developer", "Brian Tyndall" )
	Add_SubtitleName( "Developer", "Pepe Osca" )
	Add_SubtitleName( "Developer", "Milan Boleradszki" )
	Add_SubtitleName( "Legal Counsel", "Jas Purewal" )
	wait STANDARD_DELAY

	Add_Name( "Special Thanks to the rest of the team at Multiplay" )
	wait STANDARD_DELAY
}

void function Add_Spov()
{
	Add_Title( "SPOV" )
	Add_SubtitleName( "Director", "Miles Christensen" )
	Add_SubtitleName( "Technical Director", "Julio Dean" )
	Add_SubtitleName( "2D/3D Art & Animation", "Adam Roche" )
	Add_SubtitleName( "2D/3D Art & Animation", "Mantas Grigaitis" )
	Add_SubtitleName( "2D/3D Art & Animation", "James Brocklebank" )
	Add_SubtitleName( "2D/3D Art & Animation", "Marco Gifuni" )
	Add_SubtitleName( "2D/3D Art & Animation", "Ian Jones" )
	Add_SubtitleName( "Character Animation", "Rachel Chu" )
	Add_SubtitleName( "Character Animation", "Fabiana Ciatti" )
	Add_SubtitleName( "Additional Storyboards", "Bill Elliott" )
	Add_SubtitleName( "Senior Producer", "Emma Middlemiss" )
	Add_SubtitleName( "Executive Producer", "Allen Leitch" )
	wait STANDARD_DELAY
}

void function Add_GlassEgg()
{
	Add_Title( "Outsourcing: Glass Egg" )
	Add_SubtitleName( "Artist", "Dung Truong" )
	Add_SubtitleName( "Artist", "Cuong Phan" )
	Add_SubtitleName( "Artist", "Long Huynh" )
	Add_SubtitleName( "Artist", "Lan Ngo" )
	Add_SubtitleName( "Artist", "Hue Le" )
	Add_SubtitleName( "Artist", "Nguyen Vu" )
	Add_SubtitleName( "Artist", "Thanh Nquyen" )
	Add_SubtitleName( "Artist", "Phu Luc" )
	Add_SubtitleName( "Artist", "Hanh Vo" )
	Add_SubtitleName( "Artist", "Hieu Le" )
	Add_SubtitleName( "Artist", "Duc Nguyen" )
	Add_SubtitleName( "Artist", "Tung Le" )
	Add_SubtitleName( "Art Director", "Tung Vo" )
	Add_SubtitleName( "Art Supervisor", "Thang Bui" )
	wait STANDARD_DELAY
}

void function Add_Virtuos()
{
	Add_Title( "Outsourcing: Virtuos" )
	Add_SubtitleName( "Art Director", "Ron Mayland" )
	Add_SubtitleName( "Producer", "Xuan Huong" )
	Add_SubtitleName( "Artist", "Tan Dat" )
	Add_SubtitleName( "Artist", "Nam Son" )
	Add_SubtitleName( "Artist", "Tuan Anh" )
	Add_SubtitleName( "Artist", "Gia Bao" )
	wait STANDARD_DELAY
}

void function Add_Additional()
{
	float left = -0.14
	float right = 0.14
	Add_Title( "Additional Contributions" )
	thread Add_SubtitleName( "Engineering", "Kurihi Chargualaf", left )
	Add_SubtitleName( "Engineering", "Glenn Fiedler", right )
	thread Add_SubtitleName( "Engineering", "Chris Lambert", left )
	Add_SubtitleName( "Engineering", "Joe 'Pancakes' Lubertazzi", right )
	thread Add_SubtitleName( "Engineering", "Eric Mecklenburg", left )
	Add_SubtitleName( "Engineering", "Tom Spencer-Smith", right )
	thread Add_SubtitleName( "Design", "Justin Hendry", left )
	Add_SubtitleName( "Art", "Andrew Hackathorn", right )
	thread Add_SubtitleName( "Art", "Timo Pihlajamaki", left )
	Add_SubtitleName( "Art", "Jean-Francois Rey", right )
	thread Add_SubtitleName( "Art", "Theerapol Srisuphan", left )
	Add_SubtitleName( "Animation", "Damon Tasker", right )
	thread Add_SubtitleName( "Community Manager", "Abbie Heppe", left )
	Add_SubtitleName( "Mocap Assistance", "Mark Grimenstein", right )
	Add_SubtitleName( "QA", "Jesse McCann", left )
	wait STANDARD_DELAY
}

void function Add_Thanks()
{
	Add_Title( "Special Thanks" )
	Add_NameDouble( "Andrew Fox", "Richard Cole" )
	Add_NameDouble( "Predators in Action", "Lil' Orphan Hammies" )
	Add_NameDouble( "Luke Welch", "Peter Hirschmann" )
	Add_NameDouble( "Lisa Stone", "Ben Belser" )
	Add_NameDouble( "Jared Bailey", "Jenny Hyams" )
	Add_NameDouble( "Terri Mozilo", "The Respawn Star Wars Team" )
	wait STANDARD_DELAY
}

void function Add_Babies()
{
	Add_Title( "Production Babies" )
	/*
	Add_Name( "Kingston Arnett" )
	Add_Name( "Lena Bae" )
	Add_Name( "Cyril Barb" )
	Add_Name( "Gabriel Arturo Castro" )
	Add_Name( "Nathan John Douglas Dionne" )
	Add_Name( "Oliver James and Barrett Alexander Emslie" )
	Add_Name( "Lucia Madeleine Gompert" )
	Add_Name( "Griffin Maxwell Hughes" )
	Add_Name( "Kannon Siwhan Kim" )
	Add_Name( "Lorenzo Lopez Lastimosa" )
	Add_Name( "Tess 'Toshie' Amelia McCandlish" )
	Add_Name( "Emma Papouban" )
	Add_Name( "Cale Jao Pineda" )
	Add_Name( "Ellie Santiago" )
	Add_Name( "William Robert Slayback" )
	Add_Name( "Stella Sue" )
	Add_Name( "Zachary Rayme Vinson" )
	*/

	Add_Name( "Kingston Arnett, mother Gloriann" )
	Add_Name( "Dean and Lena Bae, mother Seunghee Oh" )
	Add_Name( "Cyril Barb, mother Rocheal" )
	Add_Name( "Gabriel Antonio Castro, mother Iliana" )
	Add_Name( "Nathan John Douglas Dionne, mother Jessica" )
	Add_Name( "Oliver James and Barrett Alexander Emslie, mother Wendy" )
	Add_Name( "Lucia Madeleine Gompert, mother Elizabeth" )
	Add_Name( "Griffin Maxwell Hughes, mother Elisa" )
	Add_Name( "Kannon Siwhan Kim, mother Yeonhee Kim" )
	Add_Name( "Lorenzo Lopez Lastimosa, mother Carina" )
	Add_Name( "Tess 'Toshie' Amelia McCandlish, mother Shari" )
	Add_Name( "Emma Papouban, mother Vilma" )
	Add_Name( "Cale Jao Pineda, mother Carren" )
	Add_Name( "Ellie Tong Santiago, mother Jennifer" )
	Add_Name( "William Robert Slayback, mother Jessica & brother Roscoe" )
	Add_Name( "Stella Sue, mother Emily" )
	Add_Name( "Zachary Rayme Vinson, mother Sarah" )

	wait STANDARD_DELAY
}

void function Add_EA()
{
	Add_Title( "EA" )
	Add_SubtitleName( "CEO Electronic Arts", "Andrew Wilson" )
	Add_SubtitleName( "EVP EA Studios", "Patrick Soderlund" )
	Add_SubtitleName( "SVP COO EA Studios", "Steve Pointon" )
	Add_SubtitleName( "CFO EA Studios", "Marcus Edholm" )
	Add_SubtitleName( "Finance Manager EA Studios", "Vikramjit Chall" )
	Add_SubtitleName( "VP of Production", "Colin Robinson" )
	Add_SubtitleName( "Executive Producer", "Rob Letts" )
	Add_SubtitleName( "Technical Director", "Fred Gill" )
	Add_SubtitleName( "Director Product Development", "Samantha Parker" )
	Add_SubtitleName( "Director, Developer Relations", "Anna Kulinskaya" )
	Add_SubtitleName( "Senior Program Manager", "Abigail Poquez-Cervantes" )
	Add_SubtitleName( "Sr Manager Online Operations", "Nathan Weast" )
	Add_SubtitleName( "CMO", "Chris Bruzzo" )
	Add_SubtitleName( "VP of Marketing", "Lincoln Hershberger" )
	Add_SubtitleName( "Senior Director, Global Marketing", "Craig Malanka" )
	Add_SubtitleName( "Global Product Manager", "Brian Austin" )
	Add_SubtitleName( "Senior Brand Manager", "Charlie Hauser " )
	Add_SubtitleName( "Global Product Manager", "Alec Shobin" )
	Add_SubtitleName( "Senior Director Marketing", "Erika Peterson" )
	Add_SubtitleName( "International Franchise Leader", "Gustav Enekull" )
	Add_SubtitleName( "International Product Manager", "Andrew Terrett" )
	Add_SubtitleName( "Senior Product Marketing Manager", "Yohko Atsuchi" )
	Add_SubtitleName( "Creative Director", "Drew Stauffer" )

	Add_Title( "Heads of Product Marketing" )
	Add_NameTriple( "Craig Auld", "Jerome Austin", "Colin Blackwood")
	Add_NameTriple( "Michal Hinc", "Heiner Kuhlmann", "Lorenzo Maini" )
	Add_NameTriple( "Daniel Montes", "Fredrik Ribbing", "Kirill Ustinovich" )

	Add_Title( "Product Managers" )
	Add_NameDouble( "Stephan Graffin", "Marcella Morcio" )
	Add_NameDouble( "Benjamin Pistilli", "Emmanuelle Stevenin" )

	Add_Title( "Product Marketing Managers" )
	Add_NameTriple( "Alexander Bowman", "Rob Clarke", "Federico Garcia de Salazar" )
	Add_NameTriple( "Hideharu Nakamatsu", "Anna Szarska", "" )

	thread Add_SubtitleName( "Marketing Coordinator", "Benoit Bouchez", COLUMN_LEFT )
	Add_SubtitleName( "Country Manager", "Shaun Campbell", COLUMN_RIGHT )
	thread Add_SubtitleName( "Sr Campaign Marketing Manager", "Xavier Constans", COLUMN_LEFT )
	Add_SubtitleName( "Associate Product Manager", "Hampus Erlandsson", COLUMN_RIGHT )
	thread Add_SubtitleName( "Marketing Intern", "Cesare Fedele", COLUMN_LEFT )
	Add_SubtitleName( "Digital Merchandising Manager", "Thomas Gaidier", COLUMN_RIGHT )
	thread Add_SubtitleName( "Publishing Manager", "Jonathan Harris", COLUMN_LEFT )
	Add_SubtitleName( "Marketing Coordinator", "Alice Martone", COLUMN_RIGHT )
	thread Add_SubtitleName( "Marketing Intern", "Esther Sodeke", COLUMN_LEFT )
	Add_SubtitleName( "Brand Marketing Manager", "Joshua White", COLUMN_RIGHT )
	thread Add_SubtitleName( "Sr. Brand Marketing Manager", "Nick Wong", COLUMN_LEFT )
	Add_SubtitleName( "Marketing Intern", "Tom Woodhouse", COLUMN_RIGHT )
	thread Add_SubtitleName( "Head of Marketing", "Krzysztof Zych", COLUMN_LEFT )
	Add_SubtitleName( "Director, Integrated Communications", "Andrew Wong", COLUMN_RIGHT )
	thread Add_SubtitleName( "Sr. Manager, Integrated Communications", "Devin Bennett", COLUMN_LEFT )
	Add_SubtitleName( "Director, Content and Digital Strategy", "Duke Indrasigamany", COLUMN_RIGHT )
	thread Add_SubtitleName( "Manager, Content and Digital Strategy", "Matt Tong", COLUMN_LEFT )
	Add_SubtitleName( "Director, Global Community & Influencers", "Chris Mancil", COLUMN_RIGHT )
	thread Add_SubtitleName( "Lead Community Manager", "Mathew Everett", COLUMN_LEFT )
	Add_SubtitleName( "Conversation Manager", "Cory Banks", COLUMN_RIGHT )
	thread Add_SubtitleName( "Digital Content Manager", "Zach Farley", COLUMN_LEFT )
	Add_SubtitleName( "Director Integrated Communications", "Bettina Munn", COLUMN_RIGHT )
	thread Add_SubtitleName( "International Communications Specialist", "Iris Arzur", COLUMN_LEFT )
	Add_SubtitleName( "VP, Global Analytics and Insights", "Zachery Anderson ", COLUMN_RIGHT )
	thread Add_SubtitleName( "Director, Business Analytics", "Ben Tisdale", COLUMN_LEFT )
	Add_SubtitleName( "Sr. Digital Portfolio Manager", "Andrew Hill", COLUMN_RIGHT )
	thread Add_SubtitleName( "Sr. Business Analyst", "Alex Monte Calvo", COLUMN_LEFT )
	Add_SubtitleName( "Consumer Insights Manager", "Ravi Gogte", COLUMN_RIGHT )

	Add_Title( "Heads of Communications" )
	Add_NameTriple( "Ralf Anheier", "Mario Fernandez", "Tom Lindgren" )
	Add_NameTriple( "Stefano Maestro", "Romain Montegu", "Rafael Ojeda" )
	Add_NameTriple( "Inna Shevchenko", "Wojciech Szajdak", "Shaun White" )

	Add_Title( "Communications Managers" )
	Add_NameTriple( "Milosz Bialas", "Paul Ganchou", "Bryony Gittins" )
	Add_NameTriple( "Ruslan Pyatkin", "Tristan Rosenfeldt" )

	Add_Title( "Social & Community Managers" )
	Add_NameTriple( "Mickael Da Costa", "Michele Gennari", "Torsten Haase" )
	Add_NameTriple( "Joyce Op de Weegh", "Michal Tomal", "Lee Williams" )

	thread Add_SubtitleName( "Sr. Community Manager", "Daniel Lingen", COLUMN_LEFT )
	Add_SubtitleName( "Community Manager", "Aitor Gomez", COLUMN_RIGHT )
	thread Add_SubtitleName( "Community Manager", "Andreas Koch", COLUMN_LEFT )
	Add_SubtitleName( "Community Manager ", "Hugo Rene Wingartz", COLUMN_RIGHT )
	thread Add_SubtitleName( "Sr. Communications Manager", "Snezana Hay", COLUMN_LEFT )
	Add_SubtitleName( "Sr. Communications Manager", "Stefan Hoelzel", COLUMN_RIGHT )
	thread Add_SubtitleName( "Sr. Communications Manager", "Andrea Müller", COLUMN_LEFT )
	Add_SubtitleName( "Jr. Communications Manager", "Lukas Maassen", COLUMN_RIGHT )
	thread Add_SubtitleName( "Digital Publishing Manager", "Lloyd Sharp", COLUMN_LEFT )
	Add_SubtitleName( "Content Lead", "Pierre Lamoure", COLUMN_RIGHT )
	thread Add_SubtitleName( "Content Lead", "David McDonagh", COLUMN_LEFT )
	Add_SubtitleName( "Content Manager", "Chris Bon", COLUMN_RIGHT )
	thread Add_SubtitleName( "Sr. Director Operations and Reporting", "Craig Hiland", COLUMN_LEFT )
	Add_SubtitleName( "Global PLM Director", "Chris Strong", COLUMN_RIGHT )
	thread Add_SubtitleName( "VP Business Affairs", "Paul Cairns", COLUMN_LEFT )
	Add_SubtitleName( "Managing Counsel", "Marvin Pena", COLUMN_RIGHT )
	thread Add_SubtitleName( "Data Privacy and Consumer Protection Counsel", "Jo Copping", COLUMN_LEFT )
	Add_SubtitleName( "IP Associate", "Randy Hembrador", COLUMN_RIGHT )
	thread Add_SubtitleName( "Online Architect", "Brett Spangler", COLUMN_LEFT )
	Add_SubtitleName( "Director Service Operations", "John Hanley", COLUMN_RIGHT )
	thread Add_SubtitleName( "Hosting Operations Engineer", "Ryan Burk", COLUMN_LEFT )
	Add_SubtitleName( "EADP Monitoring", "Isreal Ochoa", COLUMN_RIGHT )
	thread Add_SubtitleName( "Origin Team", "Origin Team", COLUMN_LEFT )
	Add_SubtitleName( "EASE Sr. QA Director", "Chris Carter", COLUMN_RIGHT )
	thread Add_SubtitleName( "EAP QA Manager", "Warren Buss", COLUMN_LEFT )
	Add_SubtitleName( "EAP QA Project Manager", "Will Lindesay", COLUMN_RIGHT )
	thread Add_SubtitleName( "EAP Quality Designer", "Nathan Jacobs", COLUMN_LEFT )
	Add_SubtitleName( "EAP QA Project Lead", "Eric Hanna", COLUMN_RIGHT )
	thread Add_SubtitleName( "EAUK QA Analyst", "Adam Blyth", COLUMN_LEFT )
	Add_SubtitleName( "EAUK QA Analyst", "Sam Dutton", COLUMN_RIGHT )
	Add_SubtitleName( "EAUK QA Analyst", "Tim Wayman", COLUMN_LEFT )

	Add_Title( "EAV QA Testers" )
	Add_NameTriple( "Andy Chan", "King Duque", "Ash Dutton" )
	Add_NameTriple( "Timothee Gautron", "Sean Kumar", "Brendan Mills" )
	Add_NameTriple( "Kathy Nguyen", "Conor Williams" )

	thread Add_SubtitleName( "QA Compliance Project Manager", "Roland Birsan", COLUMN_LEFT )
	Add_SubtitleName( "QA Compliance Project Manager", "Michael Dutel", COLUMN_RIGHT )
	thread Add_SubtitleName( "QA Compliance Project Lead", "Frances Kerr", COLUMN_LEFT )
	Add_SubtitleName( "QA Compliance Analyst", "Andrew Plaisance", COLUMN_RIGHT )
	thread Add_SubtitleName( "QA Compliance Analyst", "Robert Baker", COLUMN_LEFT )
	Add_SubtitleName( "QA Compliance Analyst", "Solon Starr", COLUMN_RIGHT )
	thread Add_SubtitleName( "Compliance QA Lead Tester", "William Decker", COLUMN_LEFT )
	Add_SubtitleName( "Compliance QA Lead Tester", "Jared LaCombe", COLUMN_RIGHT )
	thread Add_SubtitleName( "Compliance Sr. QA Tester", "Stephen Solomon", COLUMN_LEFT )
	Add_SubtitleName( "Compliance Sr. QA Tester", "Shane Myers", COLUMN_RIGHT )
	thread Add_SubtitleName( "Compliance Sr. QA Tester", "Matthew Dutel", COLUMN_LEFT )
	Add_SubtitleName( "Compliance Sr. QA Tester", "Chris Dugas", COLUMN_RIGHT )
	thread Add_SubtitleName( "Compliance QA Tester", "Tylar Spencer", COLUMN_LEFT )
	Add_SubtitleName( "EARO Sr. Test Director", "Razvan Sighinas", COLUMN_RIGHT )
	thread Add_SubtitleName( "EARO QA Manager", "Vlad Olteanu", COLUMN_LEFT )
	Add_SubtitleName( "EARO QA Project Manager", "Alin George Vladuca", COLUMN_RIGHT )
	thread Add_SubtitleName( "EARO QA Project Lead", "Valentin Vinturis", COLUMN_LEFT )
	Add_SubtitleName( "EARO QA Test Lead", "Vlad Nicolae Dumitriu", COLUMN_RIGHT )
	thread Add_SubtitleName( "EARO QA Test Lead", "Bogdan Alexandru Murguly", COLUMN_LEFT )
	Add_SubtitleName( "EARO QA Test Lead", "Horia Adrian Neagu", COLUMN_RIGHT )
	thread Add_SubtitleName( "EARO QA Test Lead", "George Valeriu Radu", COLUMN_LEFT )
	Add_SubtitleName( "EARO QA Test Lead", "Iulian Vechiu", COLUMN_RIGHT )

	Add_Title( "EARO QA Testers" )
	Add_NameTriple( "Stefan Anghelet", "Oana Bucuresteanu", "Cristi Chirila" )
	Add_NameTriple( "Tiberiu Cristian Craciun", "Olivia Crisan", "Razvan Alexandru Donita" )
	Add_NameTriple( "Cosmin George Dragu", "Stefanita Ene", "Ion Adrian Jiga" )
	Add_NameTriple( "Maxim Lazar", "Cristian Marcu", "Andrei Gavril Marinescu Hulea" )
	Add_NameTriple( "Mihai Robert Mihaita", "Matei Mistretu", "Ionut Alexandru Munteanu" )
	Add_NameTriple( "Marinescu Francesco Nordfors", "Marius Claudiu Oprea", "Gabriel Sergiu Oprescu" )
	Add_NameTriple( "Laurentiu Catalin Pascariu", "Claudia Petre", "Alexandru Petrescu" )
	Add_NameTriple( "Mihai Popa", "Florin Roseanu", "Mario Robert Sanda" )
	Add_NameTriple( "Anghel Adrian Serban", "Alexandru Dumitru Soare", "Alexandru Tilita" )
	Add_NameTriple( "Loredana Andreea Tirnus", "Georgian Vladut Toma", "Cristian Alexandru Vasile" )
	Add_NameTriple( "Sebastian Mihail Vidu", "Ioana Cristina Voicu Mic" )

	thread Add_SubtitleName( "CATLab QA Test Lead", "Steve Dunn", COLUMN_LEFT )
	Add_SubtitleName( "CATLab QA Lead Tester", "Mark Brockhoeft", COLUMN_RIGHT )
	thread Add_SubtitleName( "CATLab QA Tester", "Brandon Barre", COLUMN_LEFT )
	Add_SubtitleName( "CATLab QA Tester", "David Barbay", COLUMN_RIGHT )
	thread Add_SubtitleName( "CATLab QA Tester", "David Morales", COLUMN_LEFT )
	Add_SubtitleName( "CATLab QA Tester", "Stephen Duran", COLUMN_RIGHT )
	thread Add_SubtitleName( "Age Ratings Sr. Quality Analyst", "Missy Bedio", COLUMN_LEFT )
	Add_SubtitleName( "Age Ratings Quality Analyst", "Luis Negron", COLUMN_RIGHT )
	thread Add_SubtitleName( "Age Ratings Quality Analyst", "Jeremy Weber", COLUMN_LEFT )
	Add_SubtitleName( "Engineering Program Manager (System Test)", "Vanaja Bolagyathanahally", COLUMN_RIGHT )
	thread Add_SubtitleName( "Quality Engineering Architect  (System Test)", "Ramaraju Pinnamaraju", COLUMN_LEFT )
	Add_SubtitleName( "Project Manager (System Test)", "Craig Glass", COLUMN_RIGHT )
	thread Add_SubtitleName( "Certification Project Manager", "Luis Ruano", COLUMN_LEFT )
	Add_SubtitleName( "Certification Project Lead", "Noel Caba Jr.", COLUMN_RIGHT )
	thread Add_SubtitleName( "Certification Sr. Test Specialist", "Alex Martinez Rosson", COLUMN_LEFT )
	Add_SubtitleName( "Certification Sr. Test Specialist", "Iker Souto Hernandez", COLUMN_RIGHT )
	thread Add_SubtitleName( "Sr. International Project Manager", "Hugo Rivalland", COLUMN_LEFT )
	Add_SubtitleName( "Localization Project Manager", "Laurent Gabas", COLUMN_RIGHT )
	thread Add_SubtitleName( "Localization Project Manager", "Maria Rey Sampayo", COLUMN_LEFT )
	Add_SubtitleName( "Linguistic Testing Head Tester", "Jan Kramer", COLUMN_RIGHT )
	thread Add_SubtitleName( "Linguistic Testing Head Tester", "Baptiste Ratieuville", COLUMN_LEFT )
	Add_SubtitleName( "Linguistic Testing Head Tester", "Paolo Catozzella", COLUMN_RIGHT )

	Add_Title( "Linguistic Testing team" )
	Add_NameTriple( "Adria Burgos", "Alexandra Hettergott", "Alice Nezzi" )
	Add_NameTriple( "Ana Pescador ", "Anna Tubashova", "Arthur Alves" )
	Add_NameTriple( "Beatriz Mantovan", "David Borghetti", "Dennis Häringer" )
	Add_NameTriple( "Elisa Espino ", "Elsa Lamiel", "Florencia Rivaud" )
	Add_NameTriple( "Giorgia Troiani", "Juan Jose Bavaresco", "Mariusz Pilch" )
	Add_NameTriple( "Matheus Nascimento", "Mikolaj Bernecki", "Monique Couttolenc" )
	Add_NameTriple( "Pavel Permin", "Piotr Sterczewski", "Po Hun Lin" )
	Add_NameTriple( "Prunelle Lebrun", "Sandy Mischak", "Victor Hallard" )
	Add_NameTriple( "Yuri Kork" )

	Add_Title( "LT Compliance team" )
	Add_NameTriple( "Carmen Vidal", "Ekaterina Samolyak ", "Serena Cannizzaro" )
	Add_NameTriple( "Sonja Bolton", "Stefania Caravello", "Julien Pepin" )

	thread Add_SubtitleName( "Multilingual Localization Specialist", "Felicia Bender", COLUMN_LEFT )
	Add_SubtitleName( "Multilingual Localization Specialist", "Veronica Morales Beltran", COLUMN_RIGHT )

	Add_Title( "Translation" )
	Add_NameDouble( "Ampersand Content", "Böck GmbH" )
	Add_NameDouble( "Jérémy Jourdan", "Narcís Lozano Drago" )
	Add_NameDouble(  "Intrawords", "Beyondsoft Corporation" )
	Add_NameDouble( "Active Gaming Media Inc.", "Roboto" )
	Add_NameDouble( "Sylvain Deniau", "Locsmiths / LuckyDolphin" )
	Add_NameDouble( "International Translation & Informatics Ltd." )

	thread Add_SubtitleName( "Audio Engineering", "Fran Maciá", COLUMN_LEFT )
	Add_SubtitleName( "Audio Engineering", "Mario A. Morellón", COLUMN_RIGHT )
	thread Add_SubtitleName( "Audio Engineering", "Álvaro Paniagua", COLUMN_LEFT )
	Add_SubtitleName( "Audio Engineering", "Alberto Sánchez", COLUMN_RIGHT )
	Add_SubtitleName( "Engineering Project Manager", "Rubén Cabello Sanabria", COLUMN_LEFT )

	Add_Title( "Engineering" )
	Add_NameTriple("Josu Bardasco Casal", "Alberto Ayuso Pérez", "Marina Copado Martínez" )
	Add_NameTriple("Sonia Molina Pérez", "Daniel Carpio Martín", "Andrés Lorbada Sánchez" )
	Add_NameTriple("Rubén López Aparicio", "Francisco Núñez Sánchez", "Juan Serrano Yuste" )
	Add_NameTriple( "Iker Aneiros", "Álvaro Pérez Liaño" )

	thread Add_SubtitleName( "i18n Team Lead", "Iñaki Ayucar", COLUMN_LEFT )
	Add_SubtitleName( "i18n Engineering", "Jorge Campillo Tomico", COLUMN_RIGHT )
	thread Add_SubtitleName( "i18n Engineering", "Jaime Chapinal Cervantes", COLUMN_LEFT )
	Add_SubtitleName( "Product Localization Manager", "Yuhei Nasu", COLUMN_RIGHT )
	thread Add_SubtitleName( "LQA Coordinator", "Robin Fukuzaki ", COLUMN_LEFT )
	Add_SubtitleName( "LQA Coordinator", "Alexander Bravo", COLUMN_RIGHT )
	Add_SubtitleName( "LQA Test Lead", "Peggy Wang", COLUMN_LEFT )

	Add_Title( "LQA Testers" )
	Add_NameTriple("Shota Ichishima", "Seishin Kuroki ", "Eric Voon" )
	Add_NameTriple("Chen Shih-Chun", "Koh Fu Jie", "Loke Jie Sheng" )
	Add_NameTriple( "Tan Soon Meng" )

	thread Add_SubtitleName( "Audio Capture Specialist", "Pablo Ministral Riaza", COLUMN_LEFT )
	Add_SubtitleName( "Audio Capture Specialist", "Chloé Anastasia Añón Pasleau", COLUMN_RIGHT )
	thread Add_SubtitleName( "Audio Capture Specialist Assistant", "Eric Rethans", COLUMN_LEFT )
	Add_SubtitleName( "Audio Capture Specialist Assistant", "Jacques Saudubray", COLUMN_RIGHT )

	Add_Title( "Recording studios" )
	Add_NameTriple( "Sonox Audio Solutions, S.L.", "Jinglebell Communication S.r.l.", "Synthesis International S.r.l." )
	Add_NameTriple( "Rain Production", "Roboto ", "Quoted" )
	Add_NameTriple( "La Marque Rose", "AC Create" )

	thread Add_SubtitleName( "WWCE Readiness Manager", "Nicole Adams", COLUMN_LEFT )
	Add_SubtitleName( "WWCE Director of Partner Relations", "Andreas Wilhelmsson", COLUMN_RIGHT )
	thread Add_SubtitleName( "WWCE Live Service Manager", "Barry Whelan", COLUMN_LEFT )
	Add_SubtitleName( "WWCE Product Expert", "Paul Burns " , COLUMN_RIGHT)
	thread Add_SubtitleName( "WWCE Product Expert", "Paul Murphy", COLUMN_LEFT )
	Add_SubtitleName( "PULSE Director, Product Management", "Jan Carter" , COLUMN_RIGHT)
	thread Add_SubtitleName( "PULSE Sr. Product Manager", "Jeremy Mackay", COLUMN_LEFT )
	Add_SubtitleName( "PULSE Tech Ops", "PePe Amengual" , COLUMN_RIGHT)
	thread Add_SubtitleName( "Director, Strategic Planning", "Benoit Schotte-Daudin ", COLUMN_LEFT )
	Add_SubtitleName( "Director Engineering", "Feifeng Yang" , COLUMN_RIGHT)
	thread Add_SubtitleName( "Sr. Software Engineer", "Haidong (Hunter) Chen", COLUMN_LEFT )
	Add_SubtitleName( "Software Engineer II", "Karan Kaul" , COLUMN_RIGHT)
	thread Add_SubtitleName( "Sr. Manager, Engineering", "DanJun Xing", COLUMN_LEFT )
	Add_SubtitleName( "Software Engineer II", "Yijun (Chris) Mao" , COLUMN_RIGHT)
	thread Add_SubtitleName( "Software Engineer II", "Jiajun Wang", COLUMN_LEFT )
	Add_SubtitleName( "Sr. Manager Software Engineer in Test", "Yi (William) Xu", COLUMN_RIGHT )
	thread Add_SubtitleName( "Software Engineer III", "Xiaokai (Marvin) Wu", COLUMN_LEFT )
	Add_SubtitleName( "Software Engineer in Test", "Jiajian Yu" , COLUMN_RIGHT)
	thread Add_SubtitleName( "Software Development Manager", "Xinfeng (Vincent) Zhang", COLUMN_LEFT )
	Add_SubtitleName( "Software Engineer in Test", "Chao Yuan" , COLUMN_RIGHT)
	thread Add_SubtitleName( "Software Engineer (Campus Hire)", "Xinjian Zhang", COLUMN_LEFT )
	Add_SubtitleName( "Software Engineer", "Jie (Jay) Chen" , COLUMN_RIGHT)
	thread Add_SubtitleName( "Sr. Technical Program Manager", "MengXin (Shirley) Ye", COLUMN_LEFT )
	Add_SubtitleName( "Director, Program Management", "Anand Nair" , COLUMN_RIGHT)
	thread Add_SubtitleName( "Engineering Director, Commerce", "Shengyong Li", COLUMN_LEFT )
	Add_SubtitleName( "Engineering Director", "Kun Wei" , COLUMN_RIGHT)
	thread Add_SubtitleName( "Data Scientist", "Igor Borovikov", COLUMN_LEFT )
	Add_SubtitleName( "Principal Data Scientist ", "John Kolen" , COLUMN_RIGHT)
	thread Add_SubtitleName( "Software Engineer II", "Sijia Huang", COLUMN_LEFT )
	Add_SubtitleName( "Software Engineer II", "Kevin Koh" , COLUMN_RIGHT)
	thread Add_SubtitleName( "Software Engineer II", "Hao Zhang", COLUMN_LEFT )
	Add_SubtitleName( "Sr. Product Manager", "Scot Orriss" , COLUMN_RIGHT)
}

void function Add_Microsoft()
{
	Add_Title( "Microsoft" )
	Add_SubtitleName( "Xbox Sr. Developer Account Manager", "Erik Torgerson" )
	Add_SubtitleName( "Xbox Director, Account Management", "Patrick Mendenall" )
	Add_SubtitleName( "Xbox Account Manager", "Vance Polt" )
	Add_SubtitleName( "Xbox Sr. Product Marketing Manager", "Jeanie DuMont" )
	Add_SubtitleName( "Xbox Release Manager", "Kevin Salcedo" )
	Add_SubtitleName( "Xbox Dev R&D Program Manager II", "Jason Kepner" )
	Add_SubtitleName( "Xbox Dev R&D Software Engineer", "Tom Cooper" )
	Add_SubtitleName( "Xbox Dev R&D Senior Software Engineer", "Steve Spiller" )
	wait STANDARD_DELAY
}

void function Add_Sony()
{
	Add_Title( "Sony" )
	Add_SubtitleName( "SVP of Business Dev & Publisher & Dev Relations", "Phil Rosenberg" )
	Add_SubtitleName( "Sr. Director of Dev Relations and 3rd Party Production", "Gio Corsi" )
	Add_SubtitleName( "Sr. Account Executive Developer Relations", "Brian Silva" )
	Add_SubtitleName( "Director of Publisher Relations", "Carter Lipscomb" )
	Add_SubtitleName( "Sr. Account Executive Publisher Relation", "Phil Sinnott" )
	Add_SubtitleName( "Account Relations Manager", "Karl Jahn" )
	Add_SubtitleName( "Director of Partner Alliances", "Shelby Cox" )
	Add_SubtitleName( "Senior Manager Partner Alliances", "Theresa Custodio" )
	Add_SubtitleName( "Partner Alliances Manager", "Melissa Fricke" )
	Add_SubtitleName( "Director of Portfolio Strategy and Release Management", "John Drake" )
	Add_SubtitleName( "Senior Release Manager", "Jericho Guerrero" )
	Add_SubtitleName( "Senior Technical Account Manager", "Sam Charchian" )
	wait STANDARD_DELAY
}

void function Add_Legal()
{
	wait STANDARD_DELAY
	wait STANDARD_DELAY
//	wait STANDARD_DELAY
//	wait STANDARD_DELAY
//	wait STANDARD_DELAY
	Add_Name( "Uses Miles Sound System. Copyright © 1991-2016 by RAD Game Tools, Inc." )
	Add_Name( "Uses Bink Video. Copyright © 1997-2016 by RAD Game Tools, Inc." )
	Add_Name( "Uses Source Engine Technology. Copyright © 1997-2016 by Valve Corporation." )
	wait STANDARD_DELAY
	Add_Name( "Monotype is a trademark of Monotype Imaging Inc registered in the US Patent & Trademark Office and may be registered in certain jurisdictions." )
 	Add_Name( "JP2 is a trademark of Monotype GmbH and may be registered in certain jurisdictions." )
	wait STANDARD_DELAY
	Add_Name( "Copyright 2016 The Apache Software Foundation." )
	Add_Name( "This product includes software developed at The Apache Software Foundation (http://www.apache.org/). Portions of this software were" )
	Add_Name( "developed at the National Center for Supercomputing Applications (NCSA) at the University of Illinois at Urbana-Champaign. This software" )
	Add_Name( "contains code derived from the RSA Data Security Inc. MD5 Message-Digest Algorithm, including various modifications by Spyglass Inc.," )
	Add_Name( "Carnegie Mellon University, and Bell Communications Research, Inc (Bellcore)." )

}

void function Add_Northstar_Devs() // start point id for this is 29
{
	wait STANDARD_DELAY
	wait STANDARD_DELAY

	Add_Title( "Norsthar Devs" )
	Add_SubtitleName( "BIG MAN", "BobTheBob9", COLUMN_CENTER )
	thread Add_SubtitleName( "Contributor", "abarichello", COLUMN_LEFT  )
	Add_SubtitleName( "Contributor", "3x3Karma", COLUMN_RIGHT )
	thread Add_SubtitleName( "Contributor", "VITALISED", COLUMN_LEFT )
	Add_SubtitleName( "Contributor", "F1F7Y", COLUMN_RIGHT )
	thread Add_SubtitleName( "Contributor", "GeckoEidechse", COLUMN_LEFT )
	Add_SubtitleName( "Contributor", "Alystrasz", COLUMN_RIGHT )
	thread Add_SubtitleName( "Contributor", "connieprice", COLUMN_LEFT )
	Add_SubtitleName( "Contributor", "Dinorush", COLUMN_RIGHT )
	thread Add_SubtitleName( "Contributor", "emma-miler", COLUMN_LEFT )
	Add_SubtitleName( "Contributor", "RoyalBlue1", COLUMN_RIGHT )
	thread Add_SubtitleName( "Contributor", "ASpoonPlaysGames", COLUMN_LEFT )
	Add_SubtitleName( "Contributor", "hummusbird", COLUMN_RIGHT )
	thread Add_SubtitleName( "Contributor", "Neoministein", COLUMN_LEFT )
	Add_SubtitleName( "Contributor", "Coopyy", COLUMN_RIGHT )
	thread Add_SubtitleName( "Contributor", "MiloAkerman", COLUMN_LEFT )
	Add_SubtitleName( "Contributor", "Distion55x", COLUMN_RIGHT )
	thread Add_SubtitleName( "Contributor", "theroylee", COLUMN_LEFT )
	Add_SubtitleName( "Contributor", "cat_or_not", COLUMN_RIGHT )
	thread Add_SubtitleName( "Contributor", "Orpheus2401", COLUMN_LEFT )
	Add_SubtitleName( "Contributor", "zxcPandora", COLUMN_RIGHT )
	thread Add_SubtitleName( "Contributor", "Kaze-Kami", COLUMN_LEFT )
	Add_SubtitleName( "Contributor", "cpdt", COLUMN_RIGHT )
	thread Add_SubtitleName( "Contributor", "uniboi", COLUMN_LEFT )
	Add_SubtitleName( "Contributor", "H0L0theBard", COLUMN_RIGHT )
	thread Add_SubtitleName( "Contributor", "laundmo", COLUMN_LEFT )
	Add_SubtitleName( "Contributor", "alt4", COLUMN_RIGHT )
	thread Add_SubtitleName( "Contributor", "EladNLG", COLUMN_LEFT )
	Add_SubtitleName( "Contributor", "NikopolX", COLUMN_RIGHT )
	thread Add_SubtitleName( "Contributor", "Soup-64", COLUMN_LEFT )
	Add_SubtitleName( "Contributor", "0neGal", COLUMN_RIGHT )
	thread Add_SubtitleName( "Contributor", "DBmaoha", COLUMN_LEFT )
	Add_SubtitleName( "Contributor", "ScureX", COLUMN_RIGHT )
	thread Add_SubtitleName( "Contributor", "KyleGospo", COLUMN_LEFT )
	Add_SubtitleName( "Contributor", "Interesting-exe", COLUMN_RIGHT )
	thread Add_SubtitleName( "Contributor", "BotchedRPR", COLUMN_LEFT )
	Add_SubtitleName( "Contributor", "RomeoCantCode", COLUMN_RIGHT )
	thread Add_SubtitleName( "Contributor", "taskinoz", COLUMN_LEFT )
	Add_SubtitleName( "Contributor", "barnabwhy", COLUMN_RIGHT )
	thread Add_SubtitleName( "Contributor", "PANCHO7532B", COLUMN_LEFT )
	Add_SubtitleName( "Contributor", "JMM889901", COLUMN_RIGHT )
	thread Add_SubtitleName( "Contributor", "lapaxx", COLUMN_LEFT )
	Add_SubtitleName( "Contributor", "RealWorldExample", COLUMN_RIGHT )
	thread Add_SubtitleName( "Contributor", "m4t7w", COLUMN_LEFT )
	Add_SubtitleName( "Contributor", "OranGeNaL", COLUMN_RIGHT )
	thread Add_SubtitleName( "Contributor", "jerbmega", COLUMN_LEFT )
	Add_SubtitleName( "Contributor", "zestybaby", COLUMN_RIGHT )
	thread Add_SubtitleName( "Contributor", "castella-cake", COLUMN_LEFT )
	Add_SubtitleName( "Contributor", "Anreol", COLUMN_RIGHT )
	thread Add_SubtitleName( "Contributor", "Zetryox", COLUMN_LEFT )
	Add_SubtitleName( "Contributor", "Nekailrii", COLUMN_RIGHT )
	thread Add_SubtitleName( "Contributor", "L1ghtman2k", COLUMN_LEFT )
	Add_SubtitleName( "Contributor", "connorsullivan", COLUMN_RIGHT )
	thread Add_SubtitleName( "Contributor", "lolPants", COLUMN_LEFT )
	Add_SubtitleName( "Contributor", "anjannair", COLUMN_RIGHT )
	thread Add_SubtitleName( "Contributor", "wolf109909", COLUMN_LEFT )
	Add_SubtitleName( "Contributor", "JJRcop", COLUMN_RIGHT )
	thread Add_SubtitleName( "Contributor", "HappyDOGE", COLUMN_LEFT )
	Add_SubtitleName( "Contributor", "#3p0358", COLUMN_RIGHT )
	thread Add_SubtitleName( "Contributor", "geniiii", COLUMN_LEFT )
	Add_SubtitleName( "Contributor", "KittenPopo", COLUMN_RIGHT )
	thread Add_SubtitleName( "Contributor", "Mauler125", COLUMN_LEFT )
	Add_SubtitleName( "Contributor", "jakubiakdev", COLUMN_RIGHT )
	thread Add_SubtitleName( "Contributor", "Legonzaur", COLUMN_LEFT )
	Add_SubtitleName( "Contributor", "TienYou-Nathan", COLUMN_RIGHT )
	thread Add_SubtitleName( "Contributor", "r-ex", COLUMN_LEFT )
	Add_SubtitleName( "Contributor", "xamionex", COLUMN_RIGHT )
	thread Add_SubtitleName( "Contributor", "WtzLAS", COLUMN_LEFT )
	Add_SubtitleName( "Contributor", "MindSwipe", COLUMN_RIGHT )

	wait STANDARD_DELAY

	Add_Name( "MIT License" )

	Add_Name( "Copyright (c) 2021 R2Northstar" )
	Add_Name( "" )
	Add_Name( "Permission is hereby granted, free of charge, to any person obtaining a copy" )
	Add_Name( "of this software and associated documentation files (the \"Software\"), to deal" )
	Add_Name( "in the Software without restriction, including without limitation the rights" )
	Add_Name( "to use, copy, modify, merge, publish, distribute, sublicense, and/or sell" )
	Add_Name( "copies of the Software, and to permit persons to whom the Software is" )
	Add_Name( "furnished to do so, subject to the following conditions:" )
	Add_Name( "" )
	Add_Name( "The above copyright notice and this permission notice shall be included in all" )
	Add_Name( "copies or substantial portions of the Software." )
	Add_Name( "" )
	Add_Name( "THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR" )
	Add_Name( "IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY," )
	Add_Name( "FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE" )
	Add_Name( "AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER" )
	Add_Name( "LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM," )
	Add_Name( "OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE" )
	Add_Name( "SOFTWARE." )

	wait STANDARD_DELAY

	Add_Title( "Pet The Cat" )
	Add_Name( "always pet the cat" )
	Add_Name( "Sneshka is the best cat ever" )
	Add_Name( "<3 -cat_or_not" )

	wait STANDARD_DELAY

	Add_SubtitleName( "@Iniquity", "When mp_box gameplay?", COLUMN_CENTER )
}

void function EndCredits()
{
	entity player = GetLocalClientPlayer()
	player.ClientCommand( "Client_CreditsOver" )
}

void function Add_Actor_Cooper()
{
	CreditActor( "Matthew Mercer", "Jack Cooper" )
}

void function Add_Actor_BT()
{
	CreditActor( "Glenn Steinbaum", "BT-7274" )
}

void function Add_Actor_OG()
{
	CreditActor( "Fred Tatasciore", "Captain Tai Lastimosa" )
}

void function Add_Actor_Sarah()
{
	CreditActor( "Jolene Andersen", "Sarah Briggs" )
}

void function Add_Actor_Barker()
{
	CreditActor( "Liam O'Brien", "Barker", "and" )
}

void function Add_Actor_Gates()
{
	CreditActor( "Courtenay Taylor", "Gates" )
}

void function Add_Actor_Bear()
{
	CreditActor( "Chris Jai Alex", "Bear" )
}

void function Add_Actor_Davis()
{
	CreditActor( "Yuri Lowenthal", "Davis" )
}

void function Add_Actor_Droz()
{
	CreditActor( "Matthew Wolf", "Droz" )
}

void function Add_Actor_Blisk()
{
	CreditActor( "JB Blanc", "Kuben Blisk" )
}

void function Add_Actor_Marder()
{
	CreditActor( "Nicholas Guest", "General Marder" )
}

void function Add_Actor_Ash()
{
	CreditActor( "Anna Campbell", "Ash" )
	//entity anchor = GetGlobalNetEnt( "uiAnchor_Ash" )
	//CreditActor3D( "Anna Campbell", "Ash", anchor )
}

void function Add_Actor_Kane()
{
	CreditActor( "Mick Wingert", "Kane" )
	//entity anchor = GetGlobalNetEnt( "uiAnchor_Kane" )
	//CreditActor3D( "Mick Wingert", "Kane", anchor )
}

void function Add_Actor_Richter()
{
	CreditActor( "Andreas Beckett", "Richter" )
	//entity anchor = GetGlobalNetEnt( "uiAnchor_Richter" )
	//CreditActor3D( "Andreas Beckett", "Richter", anchor )
}

void function Add_Actor_Viper()
{
	CreditActor( "Evan Boymel", "Viper" )
	//entity anchor = GetGlobalNetEnt( "uiAnchor_Viper" )
	//CreditActor3D( "Evan Boymel", "Viper", anchor )
}

void function Add_Actor_Slone()
{
	CreditActor( "Amy Pemberton", "Slone" )
	//entity anchor = GetGlobalNetEnt( "uiAnchor_Slone" )
	//CreditActor3D( "Amy Pemberton", "Slone", anchor )
}

void function ServerCallback_AddCredits( int value )
{
	#if DEV
		if ( GetBugReproNum() != 0 )
			printt( "Added Credit: " + value )
	#endif

	Assert( value in file.registeredFuncs )

	if ( value > eCredits.ACTORS_INSTANT )
	{
		file.registeredFuncs[ value ]()
	}
	else
	{
		file.creditNameFuncs.append( file.registeredFuncs[ value ] )
		thread Add_Credits()
	}
}

void function Add_Credits()
{
	if ( Flag ( "AddingCredits" ) )
		return
	FlagSet( "AddingCredits" )

	Assert( file.creditNameFuncs.len() )

	while( file.creditNameFuncs.len() )
	{
		#if DEV
			if ( GetBugReproNum() != 0 )
				DEV_PrintFunc()
		#endif

		waitthread file.creditNameFuncs[ 0 ]()
		file.creditNameFuncs.remove( 0 )
	}

	FlagClear( "AddingCredits" )
}

void function DEV_PrintFunc()
{
	foreach ( value, func in file.registeredFuncs )
	{
		if ( func == file.creditNameFuncs[ 0 ] )
		{
			printt( "Played Credit: " + value )
			break
		}
	}
}

void function Add_Title( string title, float x = COLUMN_DEFAULT )
{
	if ( x == COLUMN_DEFAULT )
		x = file.defaultColumn

	var credit = RuiCreate( $"ui/credits_title.rpak", clGlobal.topoFullScreen, RUI_DRAW_HUD, ZDEPTH )
	RuiSetString( credit, "title", title )
	RuiSetGameTime( credit, "startTime", Time() )
	RuiSetFloat( credit, "xPos", x )

	wait STANDARD_DELAY
}

void function Add_Name( string name, float x = COLUMN_DEFAULT )
{
	if ( x == COLUMN_DEFAULT )
		x = file.defaultColumn

	var credit = RuiCreate( $"ui/credits_name.rpak", clGlobal.topoFullScreen, RUI_DRAW_HUD, ZDEPTH )
	RuiSetString( credit, "name", name )
	RuiSetGameTime( credit, "startTime", Time() )
	RuiSetFloat( credit, "xPos", x )

	wait STANDARD_DELAY
}

void function Add_SubtitleName( string subTitle, string name, float x = COLUMN_DEFAULT )
{
	if ( x == COLUMN_DEFAULT )
		x = file.defaultColumn

	var credit = RuiCreate( $"ui/credits_subtitle_name.rpak", clGlobal.topoFullScreen, RUI_DRAW_HUD, ZDEPTH )
	RuiSetString( credit, "subTitle", subTitle )
	RuiSetString( credit, "name", name )
	RuiSetGameTime( credit, "startTime", Time() )
	RuiSetFloat( credit, "xPos", x )

	wait STANDARD_DELAY
}

void function Add_NameRight( string name, float x = COLUMN_DEFAULT )
{
	if ( x == COLUMN_DEFAULT )
		x = file.defaultColumn

	var credit = RuiCreate( $"ui/credits_name_right.rpak", clGlobal.topoFullScreen, RUI_DRAW_HUD, ZDEPTH )
	RuiSetString( credit, "name", name )
	RuiSetGameTime( credit, "startTime", Time() )
	RuiSetFloat( credit, "xPos", x )

	wait STANDARD_DELAY
}

void function Add_NameDouble( string name1, string name2 = "" )
{
	var credit = RuiCreate( $"ui/credits_name_double.rpak", clGlobal.topoFullScreen, RUI_DRAW_HUD, ZDEPTH )
	RuiSetString( credit, "name1", name1 )
	RuiSetString( credit, "name2", name2 )
	RuiSetGameTime( credit, "startTime", Time() )

	wait STANDARD_DELAY
}

void function Add_NameTriple( string name1, string name2 = "", string name3 = "" )
{
	var credit = RuiCreate( $"ui/credits_name_triple.rpak", clGlobal.topoFullScreen, RUI_DRAW_HUD, ZDEPTH )
	RuiSetString( credit, "name1", name1 )
	RuiSetString( credit, "name2", name2 )
	RuiSetString( credit, "name3", name3 )
	RuiSetGameTime( credit, "startTime", Time() )

	wait STANDARD_DELAY
}

void function CreditActor( string actor, string char, string preface = "" )
{
	var credit = RuiCreate( $"ui/credits_actor_char.rpak", clGlobal.topoFullScreen, RUI_DRAW_HUD, 0 )
	RuiSetString( credit, "actor", actor )
	RuiSetString( credit, "character", char )
	RuiSetString( credit, "preface", preface )
	RuiSetGameTime( credit, "startTime", Time() )
}

void function CreditActor3D( string actor, string char, entity anchor, float scale = 0.09 )
{
	vector origin = <0,0,0>// anchor.GetOrigin()
	vector angles = <0,0,0>// anchor.GetAngles()

	float width = 1920 * scale
	float height = 1080 * scale

	// adjust so the RUI is drawn with the org as its center point
	origin += ( (AnglesToRight( angles )*-1) * (width*0.5) )
	origin += ( AnglesToUp( angles ) * (height*0.5) )

	// right and down vectors that get added to base org to create the display size
	vector right = ( AnglesToRight( angles ) * width )
	vector down = ( (AnglesToUp( angles )*-1) * height )

	var topo = RuiTopology_CreatePlane( origin, right, down, true )
	RuiTopology_SetParent( topo, anchor )

	var credit = RuiCreate( $"ui/credits_actor_char.rpak", topo, RUI_DRAW_WORLD, 0 )
	RuiSetString( credit, "actor", actor )
	RuiSetString( credit, "character", char )
	RuiSetGameTime( credit, "startTime", Time() )
}

void function ServerCallback_DoF_SetNearDepth( float nearStart, float nearEnd, float lerpDuration = 0.0 )
{
	if ( lerpDuration > 0 )
		DoF_LerpNearDepth( nearStart, nearEnd, lerpDuration )
	else
		DoF_SetNearDepth( nearStart, nearEnd )
}

void function ServerCallback_DoF_SetFarDepth( float farStart, float farEnd, float lerpDuration = 0.0 )
{
	if ( lerpDuration > 0 )
		DoF_LerpFarDepth( farStart, farEnd, lerpDuration )
	else
		DoF_SetFarDepth( farStart, farEnd )
}

void function ServerCallback_DoF_SetNearDepthToDefault( float lerpDuration = 0.0 )
{
	if ( lerpDuration > 0 )
		DoF_LerpNearDepthToDefault( lerpDuration )
	else
		DoF_SetNearDepthToDefault()
}

void function ServerCallback_DoF_SetFarDepthToDefault( float lerpDuration = 0.0 )
{
	if ( lerpDuration > 0 )
		DoF_LerpFarDepthToDefault( lerpDuration )
	else
		DoF_SetFarDepthToDefault()
}

void function ServerCallback_EnableFog()
{
	SetMapSetting_FogEnabled( true )
}

void function ServerCallback_DisableFog()
{
	SetMapSetting_FogEnabled( false )
}

void function ServerCallback_CsmTexelScale( float a, float b )
{
	SetMapSetting_CsmTexelScale( a, b )
}

void function ServerCallback_FOVLock()
{
	PushLockFOV()
}

#endif



