// -----------------------------------------------------------------------------------------------------------------------------------
//
// ██████╗  ██████╗  ██████╗ ███╗   ███╗████████╗ ██████╗ ██╗    ██╗███╗   ██╗    ██╗   ██╗████████╗██╗██╗     ██╗████████╗██╗   ██╗
// ██╔══██╗██╔═══██╗██╔═══██╗████╗ ████║╚══██╔══╝██╔═══██╗██║    ██║████╗  ██║    ██║   ██║╚══██╔══╝██║██║     ██║╚══██╔══╝╚██╗ ██╔╝
// ██████╔╝██║   ██║██║   ██║██╔████╔██║   ██║   ██║   ██║██║ █╗ ██║██╔██╗ ██║    ██║   ██║   ██║   ██║██║     ██║   ██║    ╚████╔╝
// ██╔══██╗██║   ██║██║   ██║██║╚██╔╝██║   ██║   ██║   ██║██║███╗██║██║╚██╗██║    ██║   ██║   ██║   ██║██║     ██║   ██║     ╚██╔╝
// ██████╔╝╚██████╔╝╚██████╔╝██║ ╚═╝ ██║   ██║   ╚██████╔╝╚███╔███╔╝██║ ╚████║    ╚██████╔╝   ██║   ██║███████╗██║   ██║      ██║
// ╚═════╝  ╚═════╝  ╚═════╝ ╚═╝     ╚═╝   ╚═╝    ╚═════╝  ╚══╝╚══╝ ╚═╝  ╚═══╝     ╚═════╝    ╚═╝   ╚═╝╚══════╝╚═╝   ╚═╝      ╚═╝
//
// -----------------------------------------------------------------------------------------------------------------------------------
untyped

global function NotSolidBoneFollowersForTime
global function GetBoneFollowersListForModel

global function SPBoomtownUtilityInit
global function SkyDome_TurnOffDome
global function SkyDome_TurnOnDome
global function SkyDome_ChangeSkinSequence
global function GenerateReapertownSkyDome
global function DEV_SkyPanelInfo

global function AssemblyArmsInit
global function GetChainOfNodesByScriptName
global function GetChainOfNodesLinked
global function CreateArm
global function CreatePlatform
global function PlayGrabberSoundOnArm
global function SetArmPose
global function AttachPlatformToArm
global function AttachEntityToArm
global function AttachPlatformToEnt
global function DetachPlatform
global function MovePlatformAtSpeed
global function RotatePlatform
global function PlatformAnim
global function DestroyPlatform
global function DestroyArm
global function MovePlatformForDuration
global function MoveArmForDuration
global function ChangePlatformModel
global function PlayerCanHearEnt
global function TurnOnParts
global function TurnOffParts
global function UpdateArmAndPlatformPushersForPlayer
global function RemovePlatformFromArray
global function RemovePlatformArmFromArray
global function AddCleanupEnt
global function RemoveCleanupEnt
global function CleanupAssemblyEnts
global function Boomtown_HandleSpecialDeathSounds
global function PlaySoundOnRail
global function UpdatePlatform4ModelToRigid
global function UpdatePlatform4ModelToAnimated
global function Boomtown_SetCSMTexelScale

#if DEV
	global function DevPoseArm
	global function DebugCleanupEnts
#endif

global const ARM_MODEL = $"models/Robots/world_builder_arm/world_builder_arm.mdl"
global const ARM_MODEL_SKYBOX = $"models/Robots/world_builder_arm/world_builder_arm_1000x.mdl"
global const ARM_MODEL_SMALL = $"models/Robots/world_builder_arm/world_builder_arm_small.mdl"
global const ARM_MODEL_SMALL_ANIMATED = $"models/boomtown/wf_platform_3_top_arm.mdl"

global const ARM_MODEL_AMBIENT_1 = $"models/kodai_live_fire/wf_rail_arm_distant_01.mdl"
global const ARM_MODEL_AMBIENT_2 = $"models/kodai_live_fire/wf_rail_arm_distant_02.mdl"
global const PLATFORM_MODEL_AMBIENT_1 = $"models/kodai_live_fire/wf_platform_grass_distant_01.mdl"
global const PLATFORM_MODEL_AMBIENT_2 = $"models/kodai_live_fire/wf_platform_grass_distant_02.mdl"

global const PLATFORM_MODEL_DIRT = $"models/boomtown/wf_platform_1.mdl"
global const PLATFORM_MODEL_FOUNDATION = $"models/boomtown/wf_platform_2.mdl"
global const PLATFORM_MODEL_FRAMING = $"models/boomtown/wf_platform_3.mdl"
global const PLATFORM_MODEL_WALLS = $"models/boomtown/wf_platform_4.mdl"
global const PLATFORM_MODEL_WALLS_RIGID = $"models/levels_terrain/sp_boomtown/wf_platform_04_highway.mdl"

global const PLATFORM_MODEL_DIRT_SKYBOX = $"models/boomtown/wf_platform_1_1000x.mdl"
global const PLATFORM_MODEL_FRAMING_SKYBOX = $"models/boomtown/wf_platform_3_1000x.mdl"
global const PLATFORM_MODEL_WALLS_SKYBOX = $"models/boomtown/wf_platform_4_1000x.mdl"

const MANTLE_CHECK_DIST = 900 * 900
const PUSHER_ENABLE_DIST = 4000 * 4000
const PUSHER_DISABLE_DIST = 4500 * 4500
const PUSHER_MAX_CHECKS_PER_FRAME_ARMS = 32
const PUSHER_MAX_CHECKS_PER_FRAME_PLATFORMS = 32
const DEBUG_PUSHER_UPDATES = false

const LOOP_SOUND_MIN_DURATION_FOR_SAVE = 10.0
const MAX_DISTANCE_TO_PLAY_SOUND = 6500
const RUMBLE_MAX_DIST_FOR_PLATFORMS = 3000 * 3000

const SKYPANEL_MAX_HEALTH     				= 200.0
const SKYPANEL_REPAIR_DELAY_MIN  			= 1.0
const SKYPANEL_REPAIR_DELAY_MAX  			= 2.0
const SKYPANEL_FLICKER_COUNT_MIN 			= 2
const SKYPANEL_FLICKER_COUNT_MAX 			= 4
const SKYPANEL_DAMAGE_FLICKER_WAIT_MIN 		= 0.1
const SKYPANEL_DAMAGE_FLICKER_WAIT_MAX 		= 0.3
const SKYPANEL_DAMAGE_FLICKER_FRAMES_MIN 	= 1
const SKYPANEL_DAMAGE_FLICKER_FRAMES_MAX 	= 5

const SKY_PANEL_MODEL = $"models/kodai_live_fire/fs_modular_single_01.mdl"

global enum eSkindex
{
	black = 0,
	staticPattern = 1,
	clouds = 2,
	desert = 3,
	mountain = 4,
	white = 5
}

struct SkyPanelData
{
	Point point,
	int skin,
	asset modelname
}

global struct Platform
{
	entity model
	entity mover
	bool playingMoveLoopSound = false
	string activeAnim = ""
	bool isHidden = false
}

global struct PlatformArm
{
	entity model
	entity mover
	bool playingMoveLoopSound = false
	bool posingOverTime = false
	entity grabberSoundEnt
}

struct
{
	array<SkyPanelData> reaperTown_skyPanelData = []    // An array of all the sky panel data to dynamically generate a skydome when reaching ReaperTown
	array<entity> SkyPanelArray = []  					// An array of all sky panels in the area. Old ones are culled out of this array when player moves to new area.

	bool foundArmPoseParams = false
	int ARM_POSE_PARAM_ROOT_YAW = -1
	int ARM_POSE_PARAM_BALL_YAW = -1
	int ARM_POSE_PARAM_TOP_ARM_PITCH = -1
	int ARM_POSE_PARAM_MID_ARM_PITCH = -1
	int ARM_POSE_PARAM_END_ARM_PITCH = -1
	int ARM_POSE_PARAM_BALL_ARM_PITCH = -1
	int ARM_POSE_PARAM_FORK_ARM_OPEN = -1
	array<PlatformArm> pusherArmsArray
	array<Platform> pusherPlatformsArray

	array<entity> cleanupEntities
	float lastRemoveInvalidTime

	float csmTexelScale_nearScale = -1
	float csmTexelScale_farScale = -1
} file

void function SPBoomtownUtilityInit()
{
	PrecacheModel( SKY_PANEL_MODEL )

	//------------------
	// Code Callbacks
	//------------------
	AddCallback_EntitiesDidLoad( BoomTownUtility_EntitiesDidLoad )

	AddSpawnCallback( "prop_dynamic", PropDynamicSpawnCallback )
	AddSpawnCallback( "prop_dynamic_lightweight", PropDynamicSpawnCallback )
	AddDamageCallback( "prop_dynamic", OnDamagedPropDynamic )
	AddDamageCallback( "prop_dynamic_lightweight", OnDamagedPropDynamic )

	AddCallback_OnLoadSaveGame( Boomtown_OnLoadSaveGame )

	//------------------
	// Flags
	//------------------
	FlagInit( "SkyPanelsCanSwap" )
	FlagSet( "SkyPanelsCanSwap" )
}


void function BoomTownUtility_EntitiesDidLoad()
{
	array<entity> skyPanels = GetEntArrayByScriptName( "sky_panel" )

	// OPTIMIZATION: Store off the ReaperTown sky panel data and delete the entities.  We will create them later using this data.
	if ( GetMapName() == "sp_boomtown" )
	{
		foreach( panel in skyPanels )
		{
			// Don't delete the panels we have hooked up to movers
			if ( panel.HasKey( "script_noteworthy" ) )
			{
				switch ( panel.kv.script_noteworthy )
				{
					case "ceiling_door":
						SetupSkyPanel( panel, panel.GetSkin() )
						file.SkyPanelArray.append( panel )
						continue
				}
			}


			SkyPanelData panelData
			panelData.point.origin = panel.GetOrigin()
			panelData.point.angles = panel.GetAngles()
			panelData.skin = panel.GetSkin()
			panelData.modelname = panel.GetModelName()

			file.reaperTown_skyPanelData.append( panelData )

			panel.Destroy()
		}
	}
	else
	{
		file.SkyPanelArray = skyPanels
	}
}


void function PropDynamicSpawnCallback( entity ent )
{
	// OPTIMIZATION - Setup these panels on level load except for sp_boomtown where we will spawn them and set them up dynamically later
	if ( GetMapName() == "sp_boomtown" )
		return

	// Do special stuff for sky panels
	string entName = ent.GetScriptName()
	if ( entName.find( "sky_panel" ) != null )
		SetupSkyPanel( ent, ent.GetSkin() )

}


void function OnDamagedPropDynamic( entity prop, var damageInfo )
{
	entity attacker 		= DamageInfo_GetAttacker( damageInfo )
	float damageAmount 		= DamageInfo_GetDamage( damageInfo )
	string entName 			= prop.GetScriptName()

	if ( !damageAmount )
		return

	// Do special stuff for sky panels
	if ( entName.find( "sky_panel" ) != null )
	{
		if ( !prop.s.enabled )
			return

		thread SkyPanel_DamageSkyPanel( prop, damageAmount )
	}
}


// ------------------------------------------------------------------------------------------------------
//
// ███████╗██╗  ██╗██╗   ██╗    ██████╗  █████╗ ███╗   ██╗███████╗██╗     ███████╗
// ██╔════╝██║ ██╔╝╚██╗ ██╔╝    ██╔══██╗██╔══██╗████╗  ██║██╔════╝██║     ██╔════╝
// ███████╗█████╔╝  ╚████╔╝     ██████╔╝███████║██╔██╗ ██║█████╗  ██║     ███████╗
// ╚════██║██╔═██╗   ╚██╔╝      ██╔═══╝ ██╔══██║██║╚██╗██║██╔══╝  ██║     ╚════██║
// ███████║██║  ██╗   ██║       ██║     ██║  ██║██║ ╚████║███████╗███████╗███████║
// ╚══════╝╚═╝  ╚═╝   ╚═╝       ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝╚══════╝╚══════╝
//
// ------------------------------------------------------------------------------------------------------

void function DEV_SkyPanelInfo()
{
	array<entity> panels = GetEntArrayByScriptName( "sky_panel" )
	printt("sky_panel count:", panels.len() )
	printt("file.SkyPanelArray.len():", file.SkyPanelArray.len() )
}


void function GenerateReapertownSkyDome()
{
	// Setup the normal sky panels
	foreach( panelData in file.reaperTown_skyPanelData )
	{
		entity panel = CreatePropDynamicLightweight( panelData.modelname, panelData.point.origin, panelData.point.angles, 6, 99999 )
		SetupSkyPanel( panel, panelData.skin )

		panel.PhysicsDummyEnableMotion( false )

		file.SkyPanelArray.append( panel )
	}


	// Setup the sky panels that are the doors out of this dome.  Be sure to parent them to the movers so they can move
	array<entity> doorPanels = GetEntArrayByScriptName( "reapertown_door_panel" )
	foreach( panel in doorPanels )
	{
		vector origin = panel.GetOrigin()
		vector angles = panel.GetAngles()
		int skin = panel.GetSkin()

		entity newPanel = CreatePropDynamicLightweight( SKY_PANEL_MODEL, origin, angles, 6, 99999 )
		SetupSkyPanel( newPanel, skin )

		file.SkyPanelArray.append( newPanel )

		entity panelParent = panel.GetParent()
		newPanel.SetParent( panelParent, "", true )

		panel.Destroy()
	}
}


void function SetupSkyPanel( entity panel, int skindex )
{
	panel.s.skindex <- skindex 					// We need to keep track of what skin we set it to because we flicker between skins during damage
	panel.s.enabled <- true 					// Set to true when player can shoot them.  Set to false when damaged & repairing or turned off.
	panel.s.health  <- SKYPANEL_MAX_HEALTH
	panel.kv.disableshadows = 1
	panel.SetSkin( skindex )
	panel.SetScriptName( "sky_panel" )
}


//------------------------------------------------------------------------------------------------------
// Sky panel damage
//------------------------------------------------------------------------------------------------------
void function SkyPanel_DamageSkyPanel( entity skyPanel, var damageAmount )
{
	if ( skyPanel.s.enabled == false )
		return

	skyPanel.s.health = skyPanel.s.health - damageAmount

	if ( skyPanel.s.health >= 0 )
	{
		thread SkyPanel_DamageFlicker( skyPanel, skyPanel.s.skindex )
	}
	else
	{
		skyPanel.s.enabled = false
		skyPanel.SetSkin( eSkindex.staticPattern )

		thread SkyPanel_RepairOverTime( skyPanel )
	}
}


void function SkyPanel_DamageFlicker( entity skyPanel, var skindex )
{
	skyPanel.EndSignal( "OnDestroy" )

	int frameCount  	= RandomIntRange( SKYPANEL_DAMAGE_FLICKER_FRAMES_MIN, SKYPANEL_DAMAGE_FLICKER_FRAMES_MAX )
	float flickerWait 	= RandomFloatRange( SKYPANEL_DAMAGE_FLICKER_WAIT_MIN, SKYPANEL_DAMAGE_FLICKER_WAIT_MAX )

	skyPanel.SetSkin( eSkindex.staticPattern )

	EmitSoundOnEntity( skyPanel, "Boomtown_ScreenGlitch_Short" )

	wait flickerWait

	for( int i = 0; i < frameCount; i++ )
	{
		skyPanel.SetSkin( skindex )
		WaitFrame()
		skyPanel.SetSkin( eSkindex.staticPattern )
	}

	if( skyPanel.s.enabled )
		skyPanel.SetSkin( skindex )
	else
		skyPanel.SetSkin( eSkindex.staticPattern )
}


void function SkyPanel_RepairOverTime( entity skyPanel )
{
	skyPanel.EndSignal( "OnDestroy" )

	EmitSoundOnEntity( skyPanel, "Boomtown_ScreenGlitch_Long" )

	wait RandomFloatRange( SKYPANEL_REPAIR_DELAY_MIN, SKYPANEL_REPAIR_DELAY_MAX )

	SkyPanel_FlickerOnFromDamage( skyPanel, skyPanel.s.skindex )

	skyPanel.s.health = SKYPANEL_MAX_HEALTH
	skyPanel.s.enabled = true
}


void function SkyPanel_FlickerOnFromDamage( entity skyPanel, var skindex )
{
	skyPanel.EndSignal( "OnDestroy" )

	int flickerCount = RandomIntRange( SKYPANEL_FLICKER_COUNT_MIN, SKYPANEL_FLICKER_COUNT_MAX )

	for( int i = 0; i < flickerCount; i++ )
	{
		skyPanel.SetSkin( skindex )

		wait 0.1
		skyPanel.SetSkin( eSkindex.staticPattern )
		EmitSoundOnEntity( skyPanel, "Boomtown_ScreenGlitch_Short" )
		wait 0.1
	}

	skyPanel.SetSkin( skindex )
}


//------------------------------------------------------------------------------------------------------
// Sky panel control
//------------------------------------------------------------------------------------------------------
void function SkyDome_TurnOnDome( int skindex, int disableShadows = 1 )
{
	foreach( entity skyPanel in file.SkyPanelArray )
	{
		skyPanel.SetSkin( skindex )
		skyPanel.kv.disableshadows = disableShadows
		skyPanel.s.enabled = true
	}
}


void function SkyDome_TurnOffDome()
{
	foreach( entity skyPanel in file.SkyPanelArray )
	{
		skyPanel.SetSkin( eSkindex.black )
		skyPanel.kv.disableshadows = 0
		skyPanel.s.enabled = false
	}
}


//------------------------------------------------------------------------------------------------------
// Sky panel utility
//------------------------------------------------------------------------------------------------------
int function SkyPanel_AngleSort( entity a, entity b )
{
	if ( a.s.angleFromRoomCenter < b.s.angleFromRoomCenter )
		return 1
	else if ( a.s.angleFromRoomCenter > b.s.angleFromRoomCenter )
		return -1

	return 0;
}


//------------------------------------------------------------------------------------------------------
// Sky panel sequences
//------------------------------------------------------------------------------------------------------
function SkyDome_ChangeSkinSequence( string roomCenterEntName, int skindex )
{
	entity roomCenterEnt = GetEntByScriptName( roomCenterEntName )
	vector roomCenter 	 = roomCenterEnt.GetOrigin()
	roomCenter.z -= 2500

	vector dir = roomCenterEnt.GetForwardVector()

	foreach( panel in file.SkyPanelArray )
	{
		vector panelOrigin = panel.GetOrigin()
		vector diff = panelOrigin - roomCenter
		float xDist = DotProduct( diff, dir )
		float zDist = diff.z
		float angle = atan2( zDist, xDist ) + RandomFloat( 0.15 )   // add some random staggering
		panel.s.angleFromRoomCenter <- angle
	}

	file.SkyPanelArray.sort( SkyPanel_AngleSort )

	//printt( "DEV SkyDome_ChangeSkinSequence - Sky panel count:", file.SkyPanelArray.len() )
	//float timeTaken = 0.0

	entity previousPanel = null

	foreach( i, panel in file.SkyPanelArray )
	{
		panel.kv.disableshadows = 1
		panel.s.enabled = true

		panel.SetSkin( eSkindex.staticPattern )

		if ( previousPanel != null)
			previousPanel.SetSkin( skindex )

		previousPanel = panel

		// DONT TOUCH THESE!  They are timed to fit the bootup sounds
		if ( i % 6 == 0 )  // do 6 at a time
		{
			wait 0.09
			//timeTaken += 0.09
		}

		// Make SURE we get the last one
		if( i == file.SkyPanelArray.len() - 1 )
			previousPanel.SetSkin( skindex )

	}
	//printt("timeTaken:", timeTaken)
}


//-----------------------------------------------------------------------------------------------------------
//
//	█████╗  ███████╗███████╗███████╗███╗   ███╗██████╗ ██╗  ██╗   ██╗     █████╗ ██████╗ ███╗   ███╗███████╗
//	██╔══██╗██╔════╝██╔════╝██╔════╝████╗ ████║██╔══██╗██║  ╚██╗ ██╔╝    ██╔══██╗██╔══██╗████╗ ████║██╔════╝
//	███████║███████╗███████╗█████╗  ██╔████╔██║██████╔╝██║   ╚████╔╝     ███████║██████╔╝██╔████╔██║███████╗
//	██╔══██║╚════██║╚════██║██╔══╝  ██║╚██╔╝██║██╔══██╗██║    ╚██╔╝      ██╔══██║██╔══██╗██║╚██╔╝██║╚════██║
//	██║  ██║███████║███████║███████╗██║ ╚═╝ ██║██████╔╝███████╗██║       ██║  ██║██║  ██║██║ ╚═╝ ██║███████║
//	╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚═╝     ╚═╝╚═════╝ ╚══════╝╚═╝       ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝
//
//-----------------------------------------------------------------------------------------------------------

#if DEV
void function DevPoseArm()
{
	// Where to put it
	//entity railEndLeft = GetEntByScriptName( "town_climb_lower_rail_left" )
	//entity neighborPlatformOriginEnt = GetEntByScriptName( "neighbor_town_climb_platform_final_position" )
	//entity railArmOriginEnt = GetEntByScriptName( "town_climb_lower_rail_arm_attach" )
	//entity finalPositionOriginEnt = GetEntByScriptName( "final_platform_position_for_town_climb" )

	array<entity> nodes = GetChainOfNodesByScriptName( "track_sec2_start" )
	//vector origin = GetEntByScriptName( "town_climb_lower_rail_arm_attach" ).GetOrigin()
	//vector angles = GetEntByScriptName( "town_climb_lower_rail_arm_attach" ).GetAngles()
	//vector origin = <railEndLeft.GetOrigin().x, finalPositionOriginEnt.GetOrigin().y, railArmOriginEnt.GetOrigin().z>
	//vector angles = railArmOriginEnt.GetAngles()
	//vector origin = GetEntByScriptName( "bt_pickup_arm_pos" ).GetOrigin()
	//vector angles = GetEntByScriptName( "bt_pickup_arm_pos" ).GetAngles()
	vector origin = nodes[3].GetOrigin()
	vector angles = nodes[0].GetAngles()

	// Need BT for reference to pose the arm
	//entity bt = GetPlayerArray()[0].GetPetTitan()
	//entity btNode = GetEntByScriptName( "bt_grab_node" )
	//thread PlayAnimTeleport( bt, "bt_boomtown_body_grabbed", btNode )

	// Make arm and platform
	PlatformArm arm = CreateArm( ARM_MODEL, origin, angles, true )
	//vector originOffset = < 175, 0, -2020 >
	//vector angleOffset = < 90, 90, 180 >
	Platform platform = CreatePlatform( PLATFORM_MODEL_DIRT, origin, angles, true )
	AttachPlatformToArm( platform, arm, false )
	//SetArmPose( arm, 180, 0, 90, -52, -31, 90, 4.2, 0.0 )
	//TurnOnParts( platform.model, [ "station_1_1", "station_1_2", "station_1_3" ] )
	//TurnOnParts( platform.model, [ "station_2_1", "station_2_2" ] )
	//TurnOnParts( platform.model, [ "station_3_1", "station_3_2", "station_3_3", "station_3_4" ] )
	//TurnOnParts( platform.model, [ "station_4_1", "station_4_2", "station_4_3" ] )

	array<string> poseTags
	poseTags.append( "def_c_top_rotator" )
	poseTags.append( "def_c_clamp" )
	poseTags.append( "def_c_top_arm" )
	poseTags.append( "def_c_arm_mid" )
	poseTags.append( "def_c_arm_end" )
	poseTags.append( "def_c_ball_bearing" )
	poseTags.append( "xxxxxxxxxxx" )
	array<float> poseAmounts = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
	array<float> poseMins = [-180.0, -180.0, -90.0, -90.0, -90.0, -90.0, 0.0]
	array<float> poseMaxs = [180.0, 180.0, 90.0, 90.0, 90.0, 90.0, 10.0]
	int currentIndex = 0

	entity player = GetPlayerArray()[0]

	while( true )
	{
		if ( player.IsInputCommandHeld(IN_USE_AND_RELOAD) )
		{
			currentIndex++
			if ( currentIndex >= poseTags.len() )
				currentIndex = 0
			while ( player.IsInputCommandHeld(IN_USE_AND_RELOAD) )
				WaitFrame()
		}
		//DebugDrawSphere( arm.GetAttachmentOrigin( arm.LookupAttachment( poseTags[currentIndex] ) ), 25.0, 255, 0, 0, true, 0.1 )

		if ( player.IsInputCommandHeld(IN_OFFHAND1) )
			poseAmounts[ currentIndex ] -= 1.0
		if ( player.IsInputCommandHeld(IN_OFFHAND0) )
			poseAmounts[ currentIndex ] += 1.0
		if ( poseAmounts[ currentIndex ] < poseMins[ currentIndex ] )
			poseAmounts[ currentIndex ] = poseMins[ currentIndex ]
		if ( poseAmounts[ currentIndex ] > poseMaxs[ currentIndex ] )
			poseAmounts[ currentIndex ] = poseMaxs[ currentIndex ]

		arm.model.SetPoseParameter( 0, poseAmounts[0] )
		arm.model.SetPoseParameter( 1, poseAmounts[1] )
		arm.model.SetPoseParameter( 2, poseAmounts[2] )
		arm.model.SetPoseParameter( 3, poseAmounts[3] )
		arm.model.SetPoseParameter( 4, poseAmounts[4] )
		arm.model.SetPoseParameter( 5, poseAmounts[5] )
		arm.model.SetPoseParameter( 6, poseAmounts[6] )

		printt( "SetArmPose( arm, " + poseAmounts[0] + ", " + poseAmounts[1] + ", " + poseAmounts[2] + ", " + poseAmounts[3] + ", " + poseAmounts[4] + ", " + poseAmounts[5] + ", " + poseAmounts[6] + ", " + "X )" )

		WaitFrame()
	}
}
#endif // DEV

void function AssemblyArmsInit()
{
	//RegisterSignal( "SettingArmPose" )
	RegisterSignal( "MovePlatformForDuration" )
	RegisterSignal( "MoveArmForDuration" )
}

array<entity> function GetChainOfNodesByScriptName( string scriptName )
{
	array<entity> nodes
	entity node = GetEntByScriptName( scriptName )
	while( true )
	{
		nodes.append( node )
		node = node.GetLinkEnt()
		if ( !IsValid( node ) )
			break
	}
	return nodes
}

array<entity> function GetChainOfNodesLinked( entity linkedFromEnt )
{
	array<entity> nodes
	array<entity> linkedEnts = linkedFromEnt.GetLinkEntArray()
	entity node
	foreach( entity ent in linkedEnts )
	{
		if ( ent.GetClassName() != "info_target" )
			continue
		node = ent
		break
	}

	Assert( IsValid( node ) )
	while( true )
	{
		nodes.append( node )
		node = node.GetLinkEnt()
		if ( !IsValid( node ) )
			break
	}
	return nodes
}

PlatformArm function CreateArm( asset model, vector origin, vector angles, bool playerCollides, bool optimized = true )
{
	int solidType = optimized ? 0 : SOLID_VPHYSICS

	PlatformArm platformArm

	platformArm.model = CreatePropDynamic( model, origin, angles, solidType )
	platformArm.model.DisableHibernation()

	platformArm.mover = CreateEntity( "script_mover_lightweight" )
	platformArm.mover.kv.solid = 0
	platformArm.mover.kv.SpawnAsPhysicsMover = 0
	platformArm.mover.SetOrigin( origin )
	platformArm.mover.SetAngles( angles )
	platformArm.mover.SetValueForModelKey( $"models/dev/empty_model.mdl" )
	DispatchSpawn( platformArm.mover )

	platformArm.model.SetParent( platformArm.mover, "", false )

	if ( playerCollides && optimized )
		file.pusherArmsArray.append( platformArm )

	if ( !optimized )
		platformArm.model.SetPusher( playerCollides )

	AddCleanupEnt( platformArm.model )
	AddCleanupEnt( platformArm.mover )

	if ( model == ARM_MODEL_SMALL_ANIMATED )
	{
		platformArm.grabberSoundEnt = CreateScriptMover()
		platformArm.grabberSoundEnt.SetParent( platformArm.model, "SOUNDPOS", false )
	}

	platformArm.model.PhysicsDummyEnableMotion( playerCollides )

	return platformArm
}

Platform function CreatePlatform( asset model, vector origin, vector angles, bool playerCollides )
{
	Platform platform

	platform.model = CreatePropDynamic( model, origin, angles, 0 )
	platform.model.DisableHibernation()

	platform.mover = CreateEntity( "script_mover_lightweight" )
	platform.mover.kv.solid = 0
	platform.mover.kv.SpawnAsPhysicsMover = 0
	platform.mover.SetOrigin( origin )
	platform.mover.SetAngles( angles )
	platform.mover.SetValueForModelKey( $"models/dev/empty_model.mdl" )
	DispatchSpawn( platform.mover )

	thread NotSolidBoneFollowers( platform.model, GetBoneFollowersListForModel( platform.model.GetModelName() ) )

	platform.model.SetParent( platform.mover, "", false )
	if ( playerCollides )
		file.pusherPlatformsArray.append( platform )

	AddCleanupEnt( platform.model )
	AddCleanupEnt( platform.mover )

	platform.model.PhysicsDummyEnableMotion( playerCollides )

	return platform
}

void function ChangePlatformModel( Platform platform, asset newModel )
{
	// If the model has bone followers we have to destroy it and recreate a new one. We can't just SetModel because it will keep the old bone followers and not make the new ones
	entity newModel = CreatePropDynamic( newModel, platform.model.GetOrigin(), platform.model.GetAngles(), SOLID_VPHYSICS )
	newModel.DisableHibernation()
	newModel.SetParent( platform.mover, "", false )
	platform.model.Destroy()
	platform.model = newModel

	platform.activeAnim = ""

	thread NotSolidBoneFollowers( platform.model, GetBoneFollowersListForModel( platform.model.GetModelName() ) )
}

void function PlayGrabberSoundOnArm( PlatformArm arm, string soundAlias )
{
	Assert( IsValid( arm.grabberSoundEnt ) )
	EmitSoundOnEntity( arm.grabberSoundEnt, soundAlias )
}

void function SetArmPose( PlatformArm arm, float rootYaw, float ballYaw, float topArmPitch, float midArmPitch, float endArmPitch, float ballArmPitch, float forkArmOpen, float duration )
{
	//Signal( arm, "SettingArmPose" )
	//EndSignal( arm, "SettingArmPose" )
	//EndSignal( arm.model, "OnDestroy" )

	OnThreadEnd(
		function() : ( arm )
		{
			arm.posingOverTime = false
		}
	)

	arm.posingOverTime = true

	if ( !file.foundArmPoseParams )
	{
		file.ARM_POSE_PARAM_ROOT_YAW = arm.model.LookupPoseParameterIndex( "root_yaw" )
		Assert( file.ARM_POSE_PARAM_ROOT_YAW >= 0 )
		file.ARM_POSE_PARAM_BALL_YAW = arm.model.LookupPoseParameterIndex( "ball_yaw" )
		Assert( file.ARM_POSE_PARAM_BALL_YAW >= 0 )
		file.ARM_POSE_PARAM_TOP_ARM_PITCH = arm.model.LookupPoseParameterIndex( "top_arm_pitch" )
		Assert( file.ARM_POSE_PARAM_TOP_ARM_PITCH >= 0 )
		file.ARM_POSE_PARAM_MID_ARM_PITCH = arm.model.LookupPoseParameterIndex( "mid_arm_pitch" )
		Assert( file.ARM_POSE_PARAM_MID_ARM_PITCH >= 0 )
		file.ARM_POSE_PARAM_END_ARM_PITCH = arm.model.LookupPoseParameterIndex( "end_arm_pitch" )
		Assert( file.ARM_POSE_PARAM_END_ARM_PITCH >= 0 )
		file.ARM_POSE_PARAM_BALL_ARM_PITCH = arm.model.LookupPoseParameterIndex( "ball_arm_pitch" )
		Assert( file.ARM_POSE_PARAM_BALL_ARM_PITCH >= 0 )
		file.ARM_POSE_PARAM_FORK_ARM_OPEN = arm.model.LookupPoseParameterIndex( "folk_arm_open" )
		Assert( file.ARM_POSE_PARAM_FORK_ARM_OPEN >= 0 )

		file.foundArmPoseParams = true
	}

	Assert( duration >= 0.0 )

	float startTime = Time()
	float endTime = startTime + duration

	if ( !IsValid( arm.model ) )
		return

	array<float> poseStart
	poseStart.append( arm.model.GetPoseParameter( file.ARM_POSE_PARAM_ROOT_YAW ) )
	poseStart.append( arm.model.GetPoseParameter( file.ARM_POSE_PARAM_BALL_YAW ) )
	poseStart.append( arm.model.GetPoseParameter( file.ARM_POSE_PARAM_TOP_ARM_PITCH ) )
	poseStart.append( arm.model.GetPoseParameter( file.ARM_POSE_PARAM_MID_ARM_PITCH ) )
	poseStart.append( arm.model.GetPoseParameter( file.ARM_POSE_PARAM_END_ARM_PITCH ) )
	poseStart.append( arm.model.GetPoseParameter( file.ARM_POSE_PARAM_BALL_ARM_PITCH ) )
	poseStart.append( arm.model.GetPoseParameter( file.ARM_POSE_PARAM_FORK_ARM_OPEN ) )

	while( Time() < endTime )
	{
		float timeFrac = GraphCapped( Time(), startTime, endTime, 0.0, 1.0 )
		float easeFrac = EaseInOut( timeFrac )

		arm.model.SetPoseParameterOverTime( file.ARM_POSE_PARAM_ROOT_YAW, GraphCapped( easeFrac, 0.0, 1.0, poseStart[0], rootYaw ), 0.1 )
		arm.model.SetPoseParameterOverTime( file.ARM_POSE_PARAM_BALL_YAW, GraphCapped( easeFrac, 0.0, 1.0, poseStart[1], ballYaw ), 0.1 )
		arm.model.SetPoseParameterOverTime( file.ARM_POSE_PARAM_TOP_ARM_PITCH, GraphCapped( easeFrac, 0.0, 1.0, poseStart[2], topArmPitch ), 0.1 )
		arm.model.SetPoseParameterOverTime( file.ARM_POSE_PARAM_MID_ARM_PITCH, GraphCapped( easeFrac, 0.0, 1.0, poseStart[3], midArmPitch ), 0.1 )
		arm.model.SetPoseParameterOverTime( file.ARM_POSE_PARAM_END_ARM_PITCH, GraphCapped( easeFrac, 0.0, 1.0, poseStart[4], endArmPitch ), 0.1 )
		arm.model.SetPoseParameterOverTime( file.ARM_POSE_PARAM_BALL_ARM_PITCH, GraphCapped( easeFrac, 0.0, 1.0, poseStart[5], ballArmPitch ), 0.1 )
		arm.model.SetPoseParameterOverTime( file.ARM_POSE_PARAM_FORK_ARM_OPEN, GraphCapped( easeFrac, 0.0, 1.0, poseStart[6], forkArmOpen ), 0.1 )
		wait 0.05

		if ( !IsValid( arm.model ) )
			return
	}

	arm.model.SetPoseParameterOverTime( file.ARM_POSE_PARAM_ROOT_YAW, rootYaw, 0.05 )
	arm.model.SetPoseParameterOverTime( file.ARM_POSE_PARAM_BALL_YAW, ballYaw, 0.05 )
	arm.model.SetPoseParameterOverTime( file.ARM_POSE_PARAM_TOP_ARM_PITCH, topArmPitch, 0.05 )
	arm.model.SetPoseParameterOverTime( file.ARM_POSE_PARAM_MID_ARM_PITCH, midArmPitch, 0.05 )
	arm.model.SetPoseParameterOverTime( file.ARM_POSE_PARAM_END_ARM_PITCH, endArmPitch, 0.05 )
	arm.model.SetPoseParameterOverTime( file.ARM_POSE_PARAM_BALL_ARM_PITCH, ballArmPitch, 0.05 )
	arm.model.SetPoseParameterOverTime( file.ARM_POSE_PARAM_FORK_ARM_OPEN, forkArmOpen, 0.05 )
}

float function EaseInOut( float frac )
{
	Assert( frac >= 0.0 && frac <= 1.0 )

	if ( frac <= 0.5 )
		return 2.0 * ( frac * frac )
	frac -= 0.5;
	return 2.0 * frac * ( 1.0 - frac ) + 0.5
}

void function AttachPlatformToArm( Platform platform, PlatformArm arm, bool maintainOffset, string attachment = "platform" )
{
	// Doesn't need to be a pusher anymore, the arm will be the pusher. We always want the highest level mover to be the pusher
	//file.pusherPlatformsArray.fastremovebyvalue( platform )
	platform.mover.SetParent( arm.model, attachment, maintainOffset )
}

void function AttachEntityToArm( PlatformArm arm, entity ent, bool maintainOffset, string attachment = "platform" )
{
	ent.SetParent( arm.model, attachment, maintainOffset )
}

void function AttachPlatformToEnt( Platform platform, entity ent, string tag, bool maintainOffset )
{
	// Doesn't need to be a pusher anymore, the arm will be the pusher. We always want the highest level mover to be the pusher
	//file.pusherPlatformsArray.fastremovebyvalue( platform )
	platform.mover.SetPusher( false )
	platform.mover.SetParent( ent, tag, maintainOffset )
}

void function DetachPlatform( Platform platform )
{
	platform.mover.ClearParent()
	//platform.mover.SetPusher( true )
	//file.pusherPlatformsArray.append( platform )
}

void function MovePlatformAtSpeed( Platform platform, vector endPos, float speed, float easeIn, float easeOut )
{
	float moveTime = Distance( platform.mover.GetOrigin(), endPos ) / speed
	easeIn = min( easeIn, moveTime * 0.5 )
	easeOut = min( easeOut, moveTime * 0.5 )
	waitthread MovePlatformForDuration( platform, endPos, moveTime, easeIn, easeOut )
}

void function RotatePlatform( Platform platform, vector angles, float duration, float easeIn, float easeOut )
{
	platform.mover.NonPhysicsRotateTo( angles, duration, easeIn, easeOut )
	wait duration
	PlatformRumble( platform )
}

void function PlatformRumble( Platform platform )
{
	if ( !IsValid( platform.model ) )
		return
	if ( !PlayerCanFeelRumble( platform.model.GetOrigin() ) )
		return

	//DebugDrawSphere( platform.model.GetOrigin(), 64, 255, 0, 0, true, 2.0 )

	float amplitude = 10
	float frequency = 300
	float duration = 1.5
	float radius = 600
	CreateShake( platform.model.GetOrigin(), amplitude, frequency, duration, radius )
}

void function ArmRumble( PlatformArm arm )
{
	if ( !IsValid( arm.model ) )
		return
	if ( !PlayerCanFeelRumble( arm.model.GetOrigin() ) )
		return

	int attachIdx = arm.model.LookupAttachment( "platform" )
	if ( attachIdx < 0 )
		return

	vector origin = arm.model.GetAttachmentOrigin( attachIdx )

	//DebugDrawSphere( origin, 64, 255, 0, 0, true, 2.0 )

	float amplitude = 10
	float frequency = 300
	float duration = 1.5
	float radius = 600
	CreateShake( origin, amplitude, frequency, duration, radius )
}

bool function PlayerCanFeelRumble( vector pos )
{
	array<entity> players = GetPlayerArray()
	if ( players.len() == 0 )
		return false
	entity player = players[0]
	if ( !IsValid( player ) )
		return false
	return DistanceSqr( player.GetOrigin(), pos ) <= RUMBLE_MAX_DIST_FOR_PLATFORMS
}

void function DestroyPlatform( Platform platform )
{
	file.pusherPlatformsArray.fastremovebyvalue( platform )

	if ( IsValid( platform.mover ) )
	{
		if ( IsValid( platform.model ) )
			platform.model.ClearParent()
		RemoveCleanupEnt( platform.mover )
		platform.mover.Destroy()
	}
	if ( IsValid( platform.model ) )
	{
		RemoveCleanupEnt( platform.model )
		platform.model.Destroy()
	}
}

void function PlatformAnim( Platform platform, string anim )
{
	platform.activeAnim = anim
	platform.model.Anim_Play( anim )
}

void function DestroyArm( PlatformArm arm )
{
	file.pusherArmsArray.fastremovebyvalue( arm )

	if ( IsValid( arm.grabberSoundEnt ) )
		arm.grabberSoundEnt.Destroy()

	if ( IsValid( arm.mover ) )
	{
		if ( IsValid( arm.model ) )
			arm.model.ClearParent()
		RemoveCleanupEnt( arm.mover )
		arm.mover.Destroy()
	}

	if ( IsValid( arm.model ) )
	{
		RemoveCleanupEnt( arm.model )
		arm.model.Destroy()
	}
}

void function MovePlatformForDuration( Platform platform, vector endPos, float duration, float easeIn, float easeOut, bool playSound = true )
{
	Assert( IsNewThread(), "MovePlatformForDuration must be threaded off" )

	Signal( platform.model, "MovePlatformForDuration" )
	EndSignal( platform.model, "MovePlatformForDuration" )

	platform.mover.NonPhysicsMoveTo( endPos, duration, easeIn, easeOut )

	if ( playSound && !platform.playingMoveLoopSound && PlayerCanHearEnt( platform.mover ) )
	{
		if ( duration < LOOP_SOUND_MIN_DURATION_FOR_SAVE )
			EmitSoundOnEntityNoSave( platform.mover, "Boomtown_PlateConveyor_MoveStartLoop" )
		else
			EmitSoundOnEntity( platform.mover, "Boomtown_PlateConveyor_MoveStartLoop" )
		platform.playingMoveLoopSound = true
	}

	wait duration

	PlatformRumble( platform )

	if ( playSound )
	{
		if ( IsValid( platform.mover ) )
		{
			if ( easeOut > 0.0 && PlayerCanHearEnt( platform.mover ) )
				EmitSoundOnEntityNoSave( platform.mover, "Boomtown_PlateConveyor_MoveStop" )
		}
		WaitFrame()
		if ( IsValid( platform.mover ) )
			StopSoundOnEntity( platform.mover, "Boomtown_PlateConveyor_MoveStartLoop" )
		if ( IsValid( platform ) )
			platform.playingMoveLoopSound = false
	}
}

void function MoveArmForDuration( PlatformArm arm, vector dest, float duration, float easeIn, float easeOut )
{
	Assert( IsNewThread(), "MoveArmForDuration must be threaded off" )

	if ( !IsValid( arm.mover ) )
		return

	Signal( arm.model, "MoveArmForDuration" )
	EndSignal( arm.model, "MoveArmForDuration" )

	OnThreadEnd(
		function() : ( arm, easeOut )
		{
			// Stop the move sounds
			if ( !IsValid( arm ) || !IsValid( arm.mover ) )
				return

			StopSoundOnEntity( arm.mover, "Boomtown_RobotArmTrack_MoveSlow" )
			StopSoundOnEntity( arm.mover, "Boomtown_RobotArmTrack_MoveMedium" )
			StopSoundOnEntity( arm.mover, "Boomtown_RobotArmTrack_MoveFast" )
			StopSoundOnEntity( arm.mover, "Boomtown_RobotArmTrack_MoveHighwaySpeed" )
			arm.playingMoveLoopSound = false

			// If the arm is coming to a stop play the stop sound
			// If easeOut is 0.0 we assume it's about to get another move command so we don't play stop sound.
			if ( PlayerCanHearEnt( arm.mover ) )
			{
				if ( easeOut > 0.0 )
					EmitSoundOnEntityNoSave( arm.mover, "Boomtown_RobotArmTrack_Stop" )
				else
					EmitSoundOnEntityNoSave( arm.mover, "Boomtown_RobotArmTrack_SpeedChange" )
			}
		}
	)

	float moveDist = Distance( arm.model.GetOrigin(), dest )
	float speed = moveDist / duration

	string moveAlias = "Boomtown_RobotArmTrack_MoveSlow"
	if ( speed > 200 )
		moveAlias = "Boomtown_RobotArmTrack_MoveMedium"
	if ( speed > 500 )
		moveAlias = "Boomtown_RobotArmTrack_MoveFast"

	if ( FlagExists( "HighwayStart" ) )
	{
		if ( Flag( "HighwayStart" ) && speed > 800 )
		{
			moveAlias = "Boomtown_RobotArmTrack_MoveHighwaySpeed"
		}
	}

	// Play move sound on entity
	if ( !arm.playingMoveLoopSound && PlayerCanHearEnt( arm.mover ) )
	{
		//if ( duration < LOOP_SOUND_MIN_DURATION_FOR_SAVE )
			EmitSoundOnEntityNoSave( arm.mover, moveAlias )
		//else
		//	EmitSoundOnEntity( arm.mover, moveAlias )
		arm.playingMoveLoopSound = true
	}

	// Move the arm
	arm.mover.NonPhysicsMoveTo( dest, duration, easeIn, easeOut )
	wait duration

	ArmRumble( arm )
}

bool function PlayerCanHearEnt( entity ent )
{
	array<entity> players = GetPlayerArray()
	if ( players.len() == 0 )
		return false
	entity player = players[0]
	if ( !IsValid( player ) )
		return false
	return Distance( player.GetOrigin(), ent.GetOrigin() ) <= MAX_DISTANCE_TO_PLAY_SOUND
}

void function TurnOnParts( entity platform, array<string> parts )
{
	foreach( string part in parts )
	{
		int bodyGroupIndex = platform.FindBodyGroup( part )
		platform.SetBodygroup( bodyGroupIndex, 1 )

		switch ( platform.GetModelName() )
		{
			case PLATFORM_MODEL_FRAMING:
			case PLATFORM_MODEL_WALLS:
				thread UpdateBoneFollowers( part, platform, true )
		}
	}
}

void function TurnOffParts( entity platform, array<string> parts )
{
	foreach( string part in parts )
	{
		int bodyGroupIndex = platform.FindBodyGroup( part )
		platform.SetBodygroup( bodyGroupIndex, 0 )

		switch ( platform.GetModelName() )
		{
			case PLATFORM_MODEL_FRAMING:
			case PLATFORM_MODEL_WALLS:
				thread UpdateBoneFollowers( part, platform, false )
		}
	}
}

void function UpdateArmAndPlatformPushersForPlayer( entity player )
{
	EndSignal( player, "StopUpdatingArmAndPlatformPushers" )
	EndSignal( player, "OnDeath" )

	int numPusherEnts

	int currentArmIndex = 0
	int currentPlatformIndex = 0
	int numCheckedThisFrame = 0

	while( true )
	{
		numPusherEnts = file.pusherArmsArray.len()
		numCheckedThisFrame = 0

		/*
		if ( DEBUG_PUSHER_UPDATES )
		{
			printt( "##### UPDATING PUSHER ARMS ######" )
			printt( "Potential pusher ents:", numPusherEnts )
		}
		*/

		while( numCheckedThisFrame < PUSHER_MAX_CHECKS_PER_FRAME_ARMS && numCheckedThisFrame < numPusherEnts )
		{
			//if ( DEBUG_PUSHER_UPDATES )
			//	printt( currentArmIndex )

			if ( currentArmIndex >= file.pusherArmsArray.len() )
				currentArmIndex = 0

			PlatformArm arm = file.pusherArmsArray[ currentArmIndex ]
			if ( IsValid( arm.mover ) && IsValid( arm.model ) )//&& !arm.model.Anim_IsActive() )
			{
				bool isPusher = arm.mover.GetPusher()
				float dist = DistanceSqr( player.GetOrigin(), arm.mover.GetOrigin() )

				if ( isPusher && dist >= PUSHER_DISABLE_DIST && !arm.posingOverTime )
				{
					EnableBoneFollowersOnArm( arm, false )
				}
				else if ( !isPusher && dist <= PUSHER_ENABLE_DIST && !arm.posingOverTime )
				{
					ClearPlayerMantleIfNearby( player, arm.mover, dist )
					EnableBoneFollowersOnArm( arm, true )
				}

				if ( DEBUG_PUSHER_UPDATES )
				{
					float debugDrawTime = ((numPusherEnts / PUSHER_MAX_CHECKS_PER_FRAME_ARMS) * 0.05) + 0.1
					if ( arm.mover.GetPusher() )
						DebugDrawSphere( arm.mover.GetOrigin(), 64.0, 255, 255, 0, true, debugDrawTime, 4 )
					else
						DebugDrawSphere( arm.mover.GetOrigin(), 64.0, 255, 0, 0, true, debugDrawTime, 4 )
				}
			}

			numCheckedThisFrame++
			currentArmIndex++
		}


		numPusherEnts = file.pusherPlatformsArray.len()
		numCheckedThisFrame = 0

		/*
		if ( DEBUG_PUSHER_UPDATES )
		{
			printt( "### UPDATING PUSHER PLATFORMS ###" )
			printt( "Potential pusher ents:", numPusherEnts )
		}
		*/

		while( numCheckedThisFrame < PUSHER_MAX_CHECKS_PER_FRAME_PLATFORMS && numCheckedThisFrame < numPusherEnts )
		{
			//if ( DEBUG_PUSHER_UPDATES )
			//	printt( currentPlatformIndex )

			if ( currentPlatformIndex >= file.pusherPlatformsArray.len() )
				currentPlatformIndex = 0

			Platform platform = file.pusherPlatformsArray[ currentPlatformIndex ]
			if ( IsValid( platform.mover ) && IsValid( platform.model ) )// && !platform.model.Anim_IsActive() )
			{
				bool isPusher = platform.mover.GetPusher()
				float dist = DistanceSqr( player.GetOrigin(), platform.mover.GetOrigin() )

				if ( isPusher && dist >= PUSHER_DISABLE_DIST )
				{
					EnableBoneFollowersOnPlatform( platform, false )
				}
				else if ( !isPusher && dist <= PUSHER_ENABLE_DIST )
				{
					ClearPlayerMantleIfNearby( player, platform.mover, dist )
					EnableBoneFollowersOnPlatform( platform, true )
				}

				if ( DEBUG_PUSHER_UPDATES )
				{
					float debugDrawTime = ((numPusherEnts / PUSHER_MAX_CHECKS_PER_FRAME_PLATFORMS) * 0.05) + 0.1
					if ( platform.mover.GetPusher() )
						DebugDrawSphere( platform.mover.GetOrigin(), 64.0, 255, 255, 0, true, debugDrawTime, 4 )
					else
						DebugDrawSphere( platform.mover.GetOrigin(), 64.0, 255, 0, 0, true, debugDrawTime, 4 )
				}
			}

			numCheckedThisFrame++
			currentPlatformIndex++
		}

		//if ( DEBUG_PUSHER_UPDATES )
		//	printt( "################################" )

		WaitFrame()
	}
}

void function RemovePlatformFromArray( Platform platform )
{
	file.pusherPlatformsArray.fastremovebyvalue( platform )
}

void function RemovePlatformArmFromArray( PlatformArm arm )
{
	file.pusherArmsArray.fastremovebyvalue( arm )
}

void function EnableBoneFollowersOnArm( PlatformArm arm, bool boneFollowersEnabled )
{
	// Hack to get rid of bone followers when they aren't needed. Haggerty making this optimization in code soon

	Assert( IsValid( arm.model ) )
	Assert( file.pusherArmsArray.find( arm ) >= 0 )

	if ( arm.model.GetModelName() != ARM_MODEL && arm.model.GetModelName() != ARM_MODEL_SMALL )
	{
		arm.mover.SetPusher( boneFollowersEnabled )
		arm.mover.PhysicsDummyEnableMotion( boneFollowersEnabled )
		return
	}

	// Create the new model
	int solidType = boneFollowersEnabled ? SOLID_VPHYSICS : 0
	entity newArm = CreatePropDynamic( arm.model.GetModelName(), arm.model.GetOrigin(), arm.model.GetAngles(), solidType )

	// Match the pose
	const int NUM_POSE_PARAMS = 7
	for ( int i = 0 ; i < NUM_POSE_PARAMS ; i++ )
		newArm.SetPoseParameter( i, arm.model.GetPoseParameter( i ) )

	// Transfer children (this will transfer a platform it may have been carrying)
	arm.model.TransferChildrenTo( newArm )

	// Link the new arm model to the mover
	newArm.SetParent( arm.mover, "", false )
	newArm.SetVelocity( arm.mover.GetVelocity() )

	// Replace model reference in the struct and delete the old model
	entity oldModel = arm.model
	arm.model = newArm
	oldModel.Destroy()

	// Update pusher flag on the mover
	arm.mover.SetPusher( boneFollowersEnabled )
	arm.mover.PhysicsDummyEnableMotion( boneFollowersEnabled )
}

void function EnableBoneFollowersOnPlatform( Platform platform, bool boneFollowersEnabled )
{
	// Hack to get rid of bone followers when they aren't needed. Haggerty making this optimization in code soon

	Assert( IsValid( platform.model ) )
	Assert( file.pusherPlatformsArray.find( platform ) >= 0 )

	array<string> bodyGroups
	switch( platform.model.GetModelName() )
	{
		case PLATFORM_MODEL_DIRT:
			bodyGroups = [ "dirt", "grass_1", "grass_2", "grass_3", "grass_4", "grass_5", "grass_6", "grass_7", "grass_8" ]
			break
		case PLATFORM_MODEL_FOUNDATION:
			break
		case PLATFORM_MODEL_FRAMING:
			bodyGroups = [ "prop_1", "prop_2", "prop_4", "prop_5", "prop_6", "prop_7" ]
			break
		case PLATFORM_MODEL_WALLS:
			bodyGroups = [ 	"station_1_1", "station_1_2", "station_1_3",
							"station_2_1", "station_2_2",
							"station_3_1", "station_3_2", "station_3_3", "station_3_4",
							"station_4_1", "station_4_2", "station_4_3" ] //, "station_4_1_window", "station_4_1_door" ]
			break
		default:
			platform.mover.SetPusher( boneFollowersEnabled )
			platform.mover.PhysicsDummyEnableMotion( boneFollowersEnabled )
			return
	}

	// Create the new model
	int solidType = boneFollowersEnabled ? SOLID_VPHYSICS : 0
	entity newPlatform = CreatePropDynamic( platform.model.GetModelName(), platform.model.GetOrigin(), platform.model.GetAngles(), solidType )

	// Link the new platform model to the mover
	newPlatform.SetParent( platform.mover, "", false )
	newPlatform.SetVelocity( platform.mover.GetVelocity() )
	newPlatform.SetPusher( boneFollowersEnabled )

	// Match the body group states
	foreach( string group in bodyGroups )
	{
		int i = platform.model.FindBodyGroup( group )
		int state = platform.model.GetBodyGroupState( i )
		newPlatform.SetBodygroup( i, state )
		if ( boneFollowersEnabled )
		{
			switch ( platform.model.GetModelName() )
			{
				case PLATFORM_MODEL_FRAMING:
				case PLATFORM_MODEL_WALLS:
					thread UpdateBoneFollowers( group, newPlatform, state==1 )
			}
		}
	}

	// Make the new platform play the same animation as the old one, and at the same spot in the anim
	if ( platform.activeAnim != "" )
	{
		float cycle = platform.model.GetCycle()
		float animDuration = platform.model.GetSequenceDuration( platform.activeAnim )
		if ( DEBUG_PUSHER_UPDATES )
			printt( "PLATFORM", platform.model, "WAS PLAYING ANIM", platform.activeAnim, "WITH DURATION", animDuration, "AND CYLCE:", cycle )
		newPlatform.Anim_Play( platform.activeAnim )
		float animTime = animDuration * cycle
		if ( DEBUG_PUSHER_UPDATES )
			printt( "Setting initial anim time:", animTime, platform.model.GetModelName() )
		newPlatform.Anim_SetInitialTime( animTime )
	}

	if ( platform.isHidden )
	{
		newPlatform.Hide()
		newPlatform.NotSolid()
	}

	// Replace model reference in the struct and delete the old model
	entity oldModel = platform.model
	platform.model = newPlatform
	oldModel.Destroy()

	platform.model.SetKillNPCOnPush( boneFollowersEnabled )

	// Update pusher flag on the mover
	// Even though it may be parented to a pusher arm we still have to set pusher on models with bone followers
	platform.mover.SetPusher( boneFollowersEnabled )
	platform.mover.PhysicsDummyEnableMotion( boneFollowersEnabled )
}

void function AddCleanupEnt( entity ent )
{
	if ( IsValid( ent ) )
		file.cleanupEntities.append( ent )

	CleanupEntRemoveInvalid()

	//printt( "CLEANUP ENTITIES:", file.cleanupEntities.len() )
}

void function RemoveCleanupEnt( entity ent )
{
	if ( IsValid( ent ) )
		file.cleanupEntities.fastremovebyvalue( ent )

	CleanupEntRemoveInvalid()

	//printt( "CLEANUP ENTITIES:", file.cleanupEntities.len() )
}

void function CleanupEntRemoveInvalid()
{
	if ( Time() >= file.lastRemoveInvalidTime + 3.0 )
	{
		//printt( "REMOVING INVALID CLEANUP ENTITIES" )
		ArrayRemoveInvalid( file.cleanupEntities )
		file.lastRemoveInvalidTime = Time()
	}
}

#if DEV
void function DebugCleanupEnts()
{
	ArrayRemoveInvalid( file.cleanupEntities )
	foreach( int i, entity ent in file.cleanupEntities )
		DebugDrawLine( ent.GetOrigin(), ent.GetOrigin() + RandomVec( 128 ), 255, 0, 0, true, 10.0 )
}
#endif

void function CleanupAssemblyEnts()
{
	svGlobal.levelEnt.Signal( "ReapertownStarting" )

	int count = 0
	int npcCount = 0

	for ( int i = file.cleanupEntities.len() - 1 ; i >= 0 ; i-- )
	{
		if ( IsValid( file.cleanupEntities[i] ) )
		{
			file.cleanupEntities[i].Destroy()
			count++
		}
	}

	// Remove AI hints
	array<entity> hints = GetEntArrayByClass_Expensive( "ai_hint" )
	foreach ( hint in hints )
	{
		if ( hint.GetOrigin().z <= 5000 )
		{
			hint.Destroy()
			count++
		}
	}

	// Remove any remaining NPCs
	array<entity> npcs = GetNPCArrayOfTeam( TEAM_IMC )
	foreach( entity npc in npcs )
	{
		npc.Destroy()
		count++
		npcCount++
	}

	printt( "####################################" )
	printt( "####################################" )
	printt( "REMOVED", count, " ASSEMBLY ENTITIES" )
	printt( "   ", npcCount, "were NPCs" )
	printt( "####################################" )
	printt( "####################################" )
}


void function Boomtown_HandleSpecialDeathSounds( entity player, var damageInfo )
{
	if ( player.IsPlayer() )
	{
		array<DamageHistoryStruct> history = GetDamageEventsForTime( player, 1.0 )

		foreach ( data in history )
		{
			// laser damage doesn't seem to kill player immediately
			if ( data.damageSourceId == eDamageSourceId.lasergrid )
			{
				EmitSoundOnEntity( player, "Boomtown_Laser_Death" )
				return
			}
		}
	}

	int damageSourceId = DamageInfo_GetDamageSourceIdentifier( damageInfo )
	switch ( damageSourceId )
	{
		case eDamageSourceId.damagedef_crush:
			if ( !player.IsTitan() )
				EmitSoundOnEntity( player, "Boomtown_Death_Squish" )
			else
				EmitSoundOnEntity( player, "Boomtown_BT_Crushed" )
			break
		case eDamageSourceId.lasergrid:
			EmitSoundOnEntity( player, "Boomtown_Laser_Death" )
			break
	}
}



void function PlaySoundOnRail( entity rail, string sound, string attachment, float animDuration )
{
	int attachIdx = rail.LookupAttachment( attachment )
	entity soundSource = CreateScriptMover()
	soundSource.SetOrigin( rail.GetAttachmentOrigin( attachIdx ) )
	soundSource.SetParent( rail, attachment, false, 0.0 )
	EmitSoundOnEntityNoSave( soundSource, sound )
	wait animDuration
	if ( IsValid( soundSource ) )
		soundSource.Destroy()
}

void function ClearPlayerMantleIfNearby( entity player, entity mover, float distSq )
{
	if ( !player.IsMantling() )
		return

	if ( distSq < MANTLE_CHECK_DIST )
	{
		player.ClearTraverse()
	}
}

void function UpdatePlatform4ModelToRigid( Platform platform )
{
	if ( IsValid( platform.mover ) && IsValid( platform.model ) )// && !platform.model.Anim_IsActive() )
	{
		bool isPusher = platform.mover.GetPusher()
		float dist = 99999999.0

		foreach ( player in GetPlayerArray() )
		{
			float d = DistanceSqr( player.GetOrigin(), platform.mover.GetOrigin() )
			if ( d < dist )
				dist = d
			ClearPlayerMantleIfNearby( player, platform.mover, d )
		}

		entity newPlatform = CreatePropDynamic( PLATFORM_MODEL_WALLS_RIGID, platform.model.GetOrigin(), platform.model.GetAngles(), SOLID_VPHYSICS )

		// Link the new platform model to the mover
		newPlatform.SetParent( platform.mover, "", false )
		newPlatform.SetVelocity( platform.mover.GetVelocity() )
		newPlatform.SetPusher( false )

		if ( platform.isHidden )
		{
			newPlatform.Hide()
			newPlatform.NotSolid()
		}

		entity oldModel = platform.model
		platform.model = newPlatform
		oldModel.Destroy()

		platform.model.SetKillNPCOnPush( false )
		platform.mover.SetPusher( false )
	}
}

void function UpdatePlatform4ModelToAnimated( Platform platform )
{
	if ( IsValid( platform.mover ) && IsValid( platform.model ) )// && !platform.model.Anim_IsActive() )
	{
		bool isPusher = platform.mover.GetPusher()
		float dist = 99999999.0

		foreach ( player in GetPlayerArray() )
		{
			float d = DistanceSqr( player.GetOrigin(), platform.mover.GetOrigin() )
			if ( d < dist )
				dist = d
			ClearPlayerMantleIfNearby( player, platform.mover, d )
		}

		entity newPlatform = CreatePropDynamic( PLATFORM_MODEL_WALLS, platform.model.GetOrigin(), platform.model.GetAngles(), SOLID_VPHYSICS )

		array<string> bodyGroups = [ 	"station_1_1", "station_1_2", "station_1_3",
										"station_2_1", "station_2_2",
										"station_3_1", "station_3_2", "station_3_3", "station_3_4",
										"station_4_1", "station_4_2", "station_4_3" ] //, "station_4_1_window", "station_4_1_door" ]

		// Match the body group states
		foreach( string group in bodyGroups )
		{
			int i = newPlatform.FindBodyGroup( group )
			newPlatform.SetBodygroup( i, 1 )
		}

		// Link the new platform model to the mover
		newPlatform.SetParent( platform.mover, "", false )
		newPlatform.SetVelocity( platform.mover.GetVelocity() )
		newPlatform.SetPusher( true )

		if ( platform.isHidden )
		{
			newPlatform.Hide()
			newPlatform.NotSolid()
		}

		entity oldModel = platform.model
		platform.model = newPlatform
		oldModel.Destroy()

		platform.model.SetKillNPCOnPush( true )
		platform.mover.SetPusher( true )
	}
}

void function NotSolidBoneFollowers( entity model, array<string> boneFollowers )
{
	model.EndSignal( "OnDestroy" )

	WaitFrame()

	foreach ( bone in boneFollowers )
	{
		entity bf = model.GetBoneFollowerForBone( bone )
		if ( bf != null )
		{
			bf.NotSolid()
		}
		else
		{
			printt( model + ": couldn't find bone follower for bone " + bone + " modelname: " + model.GetModelName() )
		}
	}
}

void function NotSolidBoneFollowersForTime( entity model, float delay, array<string> boneList )
{
	model.EndSignal( "OnDestroy" )

	NotSolidBoneFollowers( model, boneList )

	wait delay

	foreach ( bone in boneList )
	{
		entity bf = model.GetBoneFollowerForBone( bone )
		if ( bf != null )
			bf.Solid()
	}
}

void function UpdateBoneFollowers( string group, entity model, bool solid )
{
	model.EndSignal( "OnDestroy" )

	WaitFrame()

	string bone = GetBoneFollowerPrefix( model ) + group
	entity bf = model.GetBoneFollowerForBone( bone )
	if ( bf != null )
	{
		if ( solid ) // visible
			bf.Solid()
		else
			bf.NotSolid()
	}
	else
	{
		printt( model + ": couldn't find bone follower for bone " + bone + " modelname: " + model.GetModelName() )
	}
}

string function GetBoneFollowerPrefix( entity model )
{
	switch( model.GetModelName() )
	{
		case PLATFORM_MODEL_FRAMING:
			return "def_c_"
		case PLATFORM_MODEL_WALLS:
			return "def_"
	}
	return ""
}

array<string> function GetBoneFollowersListForModel( asset modelName )
{
	array<string> boneFollowers = []

	switch( modelName )
	{
		case PLATFORM_MODEL_DIRT:
		case PLATFORM_MODEL_FOUNDATION:
			return boneFollowers
		case PLATFORM_MODEL_FRAMING:
			boneFollowers = [
			"def_c_prop_1",
			"def_c_prop_2",
			"def_c_prop_4",
			"def_c_prop_5",
			"def_c_prop_6",
			"def_c_prop_7",
			]
			break
		case PLATFORM_MODEL_WALLS:
			boneFollowers = [
			"def_station_1_1",
			"def_station_1_2",
			"def_station_1_3",
			"def_station_2_1",
			"def_station_2_2",
			"def_station_3_1",
			"def_station_3_2",
			"def_station_3_3",
			"def_station_3_4",
			"def_station_4_1",
			"def_station_4_2",
			"def_station_4_3",
			// "def_station_4_1_door",
			//"def_station_4_1_window",
			]
			break
		default:
			printt( "error! Tried to NotSolid bone followers on model " + modelName )
			return []
	}

	return boneFollowers
}


void function Boomtown_SetCSMTexelScale( entity player, float nearScale, float farScale )
{
	file.csmTexelScale_nearScale = nearScale
	file.csmTexelScale_farScale = farScale

	printt("Boomtown_SetCSMTexelScale - nearScale:", file.csmTexelScale_nearScale, ", farScale:", file.csmTexelScale_farScale )

	Remote_CallFunction_NonReplay( player, "ServerCallback_BoomtownSetCSMTexelScale", nearScale, farScale )
}


void function Boomtown_OnLoadSaveGame( entity player )
{
	thread Boomtown_OnLoadSaveGame_Internal( player )
}


void function Boomtown_OnLoadSaveGame_Internal( entity player )
{
	player.EndSignal( "OnDestroy" )

	wait 0.1  // HACK: Client isn't getting the message on respawn, so delay it.  Bug 196727.

	printt("Boomtown_OnLoadSaveGame - nearScale:", file.csmTexelScale_nearScale, ", farScale:", file.csmTexelScale_farScale )

	if ( file.csmTexelScale_nearScale == -1 )
		return

	if ( file.csmTexelScale_farScale == -1 )
		return

	Boomtown_SetCSMTexelScale( player, file.csmTexelScale_nearScale, file.csmTexelScale_farScale )
}