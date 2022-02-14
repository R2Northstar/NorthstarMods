global function ClientCodeCallback_MapInit
global function ServerCallback_ShellShock
global function ServerCallback_ShellShockStop
global function ServerCallback_TrackBatteryLocations
global function ServerCallback_ClearBatteryLocations
global function ServerCallback_WakingUpInEscapePod
global function ServerCallback_StartTitleSequence
global function ServerCallback_HideHudIcons
global function ServerCallback_ShowHudIcon
global function ServerCallback_HelmetBootUpSequence
global function ServerCallback_BuddyTitanFlyout
global function ServerCallback_JumpKitCalibrationStart
global function ServerCallback_JumpKitCalibrationStep
global function ServerCallback_NighttimeAmbient
global function ServerCallback_NeuralLink
global function ServerCallback_ActivateCockpitScreens
global function ServerCallback_PilotLinkHud
global function ServerCallback_StartCockpitLook
global function ServerCallback_StopCockpitLook
global function ServerCallback_GraveShadowsAndDOF
global function ServerCallback_FieldPromotionShadows
global function ServerCallback_LevelIntroText
global function ServerCallback_RumblePlay
global function ServerCallback_ShowBatteryIcon

global function ScriptCallback_DestroyHintOnMenuOpen	// called on "ingamemenu_activate"

#if DEV
global function Blink
global function AnimEvent_DOFStart
global function RevealHudIconsThread
#endif // DEV

const SHELL_SHOCK_EFFECT			= $"P_shell_shock_FP"
const BATTERY_MODEL					= $"models/props/bt_battery/bt_battery_animated.mdl"

const SCAN_ENVIRONMENT_EFFECT		= $"P_ar_holopulse_CP"

const BATTERY_FX_FRIENDLY			= $"P_xo_battery"
const COCKPIT_LIGHT_FX				= $"xo_cockpit_dlight"

const asset FX_POD_SCREEN_IN		= $"P_pod_screen_lasers_IN"
const asset FX_POD_LASER 			= $"P_pod_scan_laser_FP"


const asset SPACE_DEBRIS_TRAIL_FX	= $"droppod_trail"
//const asset POD_MODEL_DYN			= $"models/vehicle/escape_pod/escape_pod_dyn.mdl"

const asset POD_MODEL				= $"models/vehicle/escape_pod/escape_pod_animated.mdl"
const asset JACK_MODEL_ARMS			= $"models/Weapons/arms/pov_mlt_hero_jack.mdl"
const asset JACK_MODEL_RIFLEMAN		= $"models/humans/heroes/mlt_hero_jack_rifleman.mdl"

const float titleWidth				= 1300
const float titleHeight				= 130
const float scale					= 13.5

const float prestentsTime			= 4
const float titleTime				= 7
const float closeupTime				= 3.0

const float podStartUpOffset		= 100

const vector textColor				= <0.96, 0.96, 0.96>
const vector textYellow				= <1.0, 0.75, 0.0>
const float titleAlpha				= 1.0	//0.75
const float textAlpha				= 0.75	//0.5
const float xOffset					= 0.03
const float yOffset					= 0.1

const float fullWidth				= 1920
const float fullHeight				= 1080

const MIN_SUN_SCALE					= 0
const MIN_SKY_SCALE					= 2
const SUNSKY_LERP_TIME				= 4	//this should be based on where the signal is sent from the animation

const float YAW_MAX = 20.0
const float PITCH_MAX = 40.0
const float YAW_SPEED = 2.5
const float PITCH_SPEED = 5.0

struct
{
	int colorCorrection
	int ScreenFxHandle
	array<var> batteryRUIs
	var batteryValidRUI
	var batteryHintRui
	bool batteryTrackActive = false
	var bgRUI = null
	array<var> jumpKitRuiArray
	float nextAllowHintTime = 0.0
	float lastDoubleJumpTryTime = 0
	int newStepIndex = -1

	float cockpitYaw = 0.0
	float cockpitPitch = 0.0
	float currentStickYaw = 0.0
	float currentStickPitch = 0.0
	vector baseView = <0,0,0>
	bool cockpitLookActive = false
} file

struct WorldPos
{
	vector origin
	vector angles
}

struct hexSetStruct
{
	float msgFontSize =		24.0
	int maxLines = 			8
	int lineNum	=			2
	int colums	=			4
	int alignment =			0
	float lineHoldtime =	0.05
	float msgAlpha =		0.5
	vector msgColor =		<0.5, 0.5, 0.5>
	vector msgPos =			<xOffset,yOffset,0.0>
}

void function ClientCodeCallback_MapInit()
{
	printt( "********* CLIENT SCRIPT *************" )

	FlagInit( "double_jump_confirmed" )
	FlagInit( "activate_cockpit_screens" )
	FlagInit( "power_source_found" )
	FlagInit( "intro_over" )

	RegisterSignal( "start_intro_anim" )
	RegisterSignal( "shell_shock_end" )
	RegisterSignal( "StopScreenEffect" )
	RegisterSignal( "escapepodblur" )
	RegisterSignal( "next_calibration_step" )
	RegisterSignal( "player_doublejump" )
	RegisterSignal( "power_source_found" )
	RegisterSignal( "stop_animate_dots" )
	RegisterSignal( "end_flicker" )
	RegisterSignal( "end_pilot_link_hud" )
	RegisterSignal( "end_hide_after_time" )
	RegisterSignal( "end_fade_over_time" )
	RegisterSignal( "start_nightine_ambient" )
	RegisterSignal( "stop_nightine_ambient" )
	RegisterSignal( "fade_sunsky_scale" )
	RegisterSignal( "LookAround" )
	RegisterSignal( "stop_cockpit_light" )


	PrecacheParticleSystem( SHELL_SHOCK_EFFECT )
	PrecacheParticleSystem( SCAN_ENVIRONMENT_EFFECT )
	PrecacheParticleSystem( BATTERY_FX_FRIENDLY )
	PrecacheParticleSystem( COCKPIT_LIGHT_FX )
	PrecacheParticleSystem( FX_POD_SCREEN_IN )
	PrecacheParticleSystem( FX_POD_LASER )

	ShSpWildsCommonInit()

	AddCreateCallback( "first_person_proxy", CreateFirstPersonProxyAnimEvents )
	AddCreateCallback( "prop_dynamic", BatteryCreateCallback )

	AddCreateCallback( "player", PlayerCreateCallback )
	AddCreateCallback( "titan_cockpit", CreateCallback_TitanCockpit )

//	Doesn't work because it has to be called in remote_functions_sp.gnut but level script isn't loaded at that time.
//	RegisterNetworkedVariableChangeCallback_bool( "hideHudIcons", HideHudIconsChangeCallback )

	RegisterConCommandTriggeredCallback( "+jump", DoubleJumpDisabledWarning )

	file.colorCorrection = ColorCorrection_Register( "materials/correction/shell_shock.raw" )
	level.wui <- null

	RegisterConCommandTriggeredCallback( "ingamemenu_activate", ScriptCallback_DestroyHintOnMenuOpen )
}

void function ScriptCallback_DestroyHintOnMenuOpen( entity player )
{
	if ( GetGlobalNetBool( "DestroyHintOnMenuOpen" ) )
		DestroyOnscreenHint()
}

void function PlayerCreateCallback( entity player )
{
	if ( player.GetPlayerNetBool( "hideHudIcons" ) == true )
		ServerCallback_HideHudIcons()

	file.batteryHintRui = CreateCockpitRui( $"ui/battery_hud.rpak" )
	ServerCallback_ShowBatteryIcon( player.GetPlayerNetBool( "showBatteryIcon" ) )

	file.newStepIndex = player.GetPlayerNetInt( "jumpKitCalibrationStep" )
	switch( file.newStepIndex )
	{
		case -1:
			break
		case 0:
			JumpKitCalibrationRuiCreate()
			thread JumpKitCalibrationStart( player )
			break
		default:
			JumpKitCalibrationRuiCreate()
			thread JumpKitCalibrationSteps( player )
			break
	}

	ServerCallback_NighttimeAmbient( GetGlobalNetInt( "nighttimeAmbient" ) )
}

void function ServerCallback_LevelIntroText()
{
	BeginIntroSequence()
	var infoText = RuiCreate( $"ui/sp_level_title.rpak", clGlobal.topoFullScreen, RUI_DRAW_HUD, RUI_SORT_SCREENFADE + 100 )
	RuiSetGameTime( infoText, "startTime", Time() )
	RuiSetString( infoText, "txtLine1", "#WILDS_INTRO_TEXT_LINE1" )
	RuiSetString( infoText, "txtLine2", "#WILDS_INTRO_TEXT_LINE2" )
	RuiSetString( infoText, "txtLine3", "#WILDS_INTRO_TEXT_LINE3" )
}

void function ServerCallback_ShowBatteryIcon( bool state )
{
	if ( state )
		RuiSetInt( file.batteryHintRui, "batteryCount", 1 )
	else
		RuiSetInt( file.batteryHintRui, "batteryCount", 0 )
}

//  ######## #### ######## ##       ########     ######   ######  ########  ######## ######## ##    ##
//     ##     ##     ##    ##       ##          ##    ## ##    ## ##     ## ##       ##       ###   ##
//     ##     ##     ##    ##       ##          ##       ##       ##     ## ##       ##       ####  ##
//     ##     ##     ##    ##       ######       ######  ##       ########  ######   ######   ## ## ##
//     ##     ##     ##    ##       ##                ## ##       ##   ##   ##       ##       ##  ####
//     ##     ##     ##    ##       ##          ##    ## ##    ## ##    ##  ##       ##       ##   ###
//     ##    ####    ##    ######## ########     ######   ######  ##     ## ######## ######## ##    ##

void function ServerCallback_StartTitleSequence()
{
	thread StartTitleSequenceThread()
}

void function StartTitleSequenceThread()
{
	entity player = GetLocalViewPlayer()
	player.EndSignal( "OnDestroy" )

	ScreenFade( GetLocalViewPlayer(), 0, 0, 0, 255, 0.016, 2.5, FFADE_IN | FFADE_PURGE )

	AutoExposureSetMaxExposureMultiplier( 0.3 )
//	player.FreezeControlsOnClient()

	thread IntroRui()
	waitthread IntroAnims()

	ScreenFade( player, 0, 0, 0, 255, 1, 4, FFADE_IN | FFADE_PURGE )

	FlagSet( "intro_over" )
	player.ClientCommand( "IntroOver" )
	player.UnfreezeControlsOnClient()
	AutoExposureSetMaxExposureMultiplier( 1.0 )
}

void function IntroRui()
{
	const float DIST_TO_CARD = 25825.0
	const float CARD_HEIGHT = 27086 // 9000
	const float CARD_WIDTH = 48153 // 16000

	entity animRef = GetEntByScriptName( "title_ref" )
	entity cameraRig = CreateClientSidePropDynamic( <0,0,0>, <0,0,0>, JACK_MODEL_ARMS )
	AnimRefPoint refPoint = cameraRig.Anim_GetStartForRefEntity( "ptpov_wilds_intro_camera", animRef, "REF" )
	cameraRig.Destroy()

	vector forward = AnglesToForward( refPoint.angles )
	vector right = AnglesToRight( refPoint.angles )
	vector up = AnglesToUp( refPoint.angles )

	vector centerPos = refPoint.origin + forward * DIST_TO_CARD
	vector topLeft = centerPos - right * CARD_WIDTH / 2 + up * CARD_HEIGHT / 2
	vector cardRight = right * CARD_WIDTH
	vector cardDown = -up * CARD_HEIGHT

	var letterBoxRui = RuiCreate( $"ui/wilds_title_letterbox.rpak", clGlobal.topoFullScreen, RUI_DRAW_HUD, 0 )
	float[2] screenSize = GetScreenSize()
	RuiSetResolution( letterBoxRui, screenSize[0], screenSize[1] )

	var bgTopology = RuiTopology_CreatePlane( topLeft, cardRight, cardDown, false ) // don't clip
	file.bgRUI = RuiCreate( $"ui/wilds_title_screen.rpak", bgTopology, RUI_DRAW_WORLD, 0 )

	wait 3

	RuiSetGameTime( file.bgRUI, "showRespawn", Time() )
	wait 3

	RuiSetGameTime( file.bgRUI, "hideRespawn", Time() )
	wait 6

	animRef.Signal( "start_intro_anim" )

	RuiSetGameTime( file.bgRUI, "showTitanfall", Time() )
	wait 11 // fade bg at 22 // fade text at 24

	RuiSetGameTime( file.bgRUI, "hideTitanfall", Time() )
	wait 6

	RuiDestroyIfAlive( file.bgRUI )
	RuiTopology_Destroy( bgTopology )

	FlagWait( "intro_over" )
	wait 1
	RuiDestroyIfAlive( letterBoxRui )
}

void function IntroAnims()
{
	entity player = GetLocalViewPlayer()
	player.EndSignal( "OnDestroy" )

	entity animRef= GetEntByScriptName( "title_ref" )

	entity cameraRig = CreateClientSidePropDynamic( <0,0,0>, <0,0,0>, JACK_MODEL_ARMS )
	cameraRig.SetFadeDistance( 80000 )
	cameraRig.EnableRenderAlways()
	cameraRig.Hide()

	entity camera = CreateClientSidePointCamera( <0,0,0>, <0,0,0>, 70 )
	camera.SetParent( cameraRig, "CAMERA", false, 0 )

	player.SetMenuCameraEntity( camera )

	thread PlayAnimTeleport( cameraRig, "ptpov_wilds_intro_camera_idle", animRef, "REF" )
	animRef.WaitSignal( "start_intro_anim" )

	thread IntroRumble( player )

	entity mainPod = CreateClientSidePropDynamic( <0,0,0>, <0,0,0>, POD_MODEL )
	mainPod.SetFadeDistance( 80000 )
	mainPod.EnableRenderAlways()

	// don't forget to reset the sunsky scale for the rest of the level.
	thread LerpSunSkyScale( mainPod, MIN_SUN_SCALE, MIN_SKY_SCALE, SUNSKY_LERP_TIME )

	entity guy = CreateClientSidePropDynamic( <0,0,0>, <0,0,0>, JACK_MODEL_RIFLEMAN )
	guy.SetFadeDistance( 80000 )
	guy.EnableRenderAlways()

	thread IntroEscapePodExtra( "pod_wilds_intro_01" )
	thread IntroEscapePodExtra( "pod_wilds_intro_02" )
	thread IntroEscapePodExtra( "pod_wilds_intro_03" )
	thread IntroEscapePodExtra( "pod_wilds_intro_04" )

	entity skyboxModel = GetEntByScriptName( "intro_skybox_model" )
	skyboxModel = CreateClientSidePropDynamic(skyboxModel.GetOrigin(), skyboxModel.GetAngles(), skyboxModel.GetModelName() )
	entity skyCam = GetEntArrayByClassAndTargetname( "sky_camera", "sky_cam_title" )[0]
	WorldPos loc = GetRefLocationInSkyBox( animRef, skyCam )
	thread PlayAnimTeleport( skyboxModel, "animation", loc.origin, loc.angles, 0.0 )

	thread PlayAnimTeleport( mainPod, "pod_wilds_intro_jack", animRef, "REF" )
	thread PlayAnimTeleport( guy, "pt_wilds_intro_jack", animRef, "REF" )

	waitthread PlayAnimTeleport( cameraRig, "ptpov_wilds_intro_camera", animRef, "REF" )

	ResetSunSkyScale()

	player.ClearMenuCameraEntity()
	skyboxModel.Destroy()
	guy.Destroy()
	camera.Destroy()
	mainPod.Destroy()
	cameraRig.Destroy()
}

void function IntroRumble( entity player )
{
	// safer then recompiling models to make it a anim callback I think at this point.
	wait 37.25
	Rumble_Play( "wilds_intro", { position = player.GetOrigin() } )
}

void function IntroEscapePodExtra( string animationName )
{
	entity animRef = GetEntByScriptName( "title_ref" )
	entity pod = CreateClientSidePropDynamic( <0,0,0>, <0,0,0>, POD_MODEL )
	pod.SetFadeDistance( 80000 )
	pod.EnableRenderAlways()
	pod.SetParent( animRef )

	//	thread LineToBetween( animRef, pod, <RandomInt(255),RandomInt(255),RandomInt(255)> )

	waitthread PlayAnimTeleport( pod, animationName, animRef, "REF" )
	pod.Destroy()
}

void function LerpSunSkyScale( entity mainPod, float sunScaleEnd, float skyScaleEnd, float duration )
{
	mainPod.WaitSignal( "fade_sunsky_scale" )

	entity clight = GetLightEnvironmentEntity()
	float startTime = Time()
	while( Time() < startTime + duration )
	{
		float frac = (Time() - startTime) / duration
//		frac = QuadEaseIn( frac )
		float sunScale = Graph( frac, 0, 1, 1, sunScaleEnd )
		float skyScale = Graph( frac, 0, 1, 1, skyScaleEnd )

		clight.ScaleSunSkyIntensity( sunScale, skyScale )
		wait IntervalPerTick()
	}

	clight.ScaleSunSkyIntensity( sunScaleEnd, skyScaleEnd )
}

void function ResetSunSkyScale()
{
	entity clight = GetLightEnvironmentEntity()
	clight.ScaleSunSkyIntensity( 1.0, 1.0 )
}

//  ########  ######   ######     ###    ########  ########    ########   #######  ########
//  ##       ##    ## ##    ##   ## ##   ##     ## ##          ##     ## ##     ## ##     ##
//  ##       ##       ##        ##   ##  ##     ## ##          ##     ## ##     ## ##     ##
//  ######    ######  ##       ##     ## ########  ######      ########  ##     ## ##     ##
//  ##             ## ##       ######### ##        ##          ##        ##     ## ##     ##
//  ##       ##    ## ##    ## ##     ## ##        ##          ##        ##     ## ##     ##
//  ########  ######   ######  ##     ## ##        ########    ##         #######  ########

void function ServerCallback_WakingUpInEscapePod()
{
	thread WakingUpInEscapePodThread()
}

void function WakingUpInEscapePodThread()
{
	Signal( level, "escapepodblur" )
	EndSignal( level, "escapepodblur" )

	entity player = GetLocalViewPlayer()
	player.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function() : (  )
		{
			ScreenFade( GetLocalViewPlayer(), 0, 0, 0, 0, 0, 5, FFADE_IN | FFADE_PURGE )
			SetScreenBlur( 0, 0, EASING_SINE_INOUT )
			DoF_LerpFarDepthToDefault( 3 )
			DoF_LerpNearDepthToDefault( 3 )
		}
	)

	DoF_SetFarDepth( 4500, 7500 )
	DoF_SetNearDepth( 0, 18 )

	SetScreenBlur( 0.75, 0, EASING_SINE_INOUT )
	ScreenFade( player, 0, 0, 0, 255, 0.01, 4, FFADE_IN | FFADE_PURGE )	// fade from black to clear fast
	wait 4

	SetScreenBlur( 0, 3, EASING_SINE_INOUT )
	wait 2.0
	thread Blink( player, 3, false )
	wait 6.0
	thread Blink( player, 5, true )
	SetScreenBlur( 1, 4, EASING_CUBIC_OUT ) //EASING_CUBIC_IN
	wait 4.0
	thread Blink( player, 3, false )
	SetScreenBlur( 0.5, 4, EASING_SINE_INOUT )
	wait 4.0
	thread Blink( player, 2, true )
	SetScreenBlur( 1, 0.5, EASING_SINE_INOUT )
	wait 0.5
	SetScreenBlur( 0, 6, EASING_LINEAR )
	wait 4.0
	wait 1.25
	SetScreenBlur( 1, 0.1, EASING_SINE_INOUT )
	wait 0.5
	SetScreenBlur( 0, 5, EASING_CUBIC_OUT ) //EASING_CUBIC_IN
	wait 5
}

void function Blink( entity player, int blinks = 4, bool longBlink = true )
{
	// FADE_OUT is fade to value
	// FADE_IN is fade from value
	player.EndSignal( "OnDestroy" )

	const int darkAlpha = 200
	float fadeTime = blinks * 0.125 // 0.075 is the average of the random float range below
	if ( longBlink )
		fadeTime += 0.3

	float startTime = Time()
	ScreenFade( player, 0, 0, 0, darkAlpha, fadeTime, 0, FFADE_OUT )	// fade from black to clear

	for( int i = 0; i < blinks; i++ )
	{
		float blinkTime = RandomFloatRange( 0.05, 0.2 )

		if ( longBlink && i == blinks / 4 )
		{
			float holdTime = RandomFloatRange( 0.2, 0.4 )
			ScreenFade( player, 0, 0, 0, darkAlpha, blinkTime, holdTime, FFADE_OUT )	// fade from black to clear
			wait blinkTime + holdTime
			longBlink = false
		}

		ScreenFade( player, 0, 0, 0, darkAlpha, blinkTime, 0, FFADE_IN )	// fade from black to clear
		wait blinkTime
	}
	ScreenFade( player, 0, 0, 0, darkAlpha, 0.75 , 0, FFADE_IN )	// fade from black to clear
}

void function ServerCallback_NighttimeAmbient( int state )
{
	entity ambGeneric
	switch( state )
	{
		case 1:
			ambGeneric = GetEntByScriptName( "AMB_NightBattle_Front" )
			ambGeneric.SetEnabled( true )
			ambGeneric = GetEntByScriptName( "AMB_NightBattle_Rear" )
			ambGeneric.SetEnabled( true )
			break
		case 2:
			ambGeneric = GetEntByScriptName( "AMB_NightBattle_Front" )
			ambGeneric.SetEnabled( false )
			ambGeneric = GetEntByScriptName( "AMB_NightBattle_Rear" )
			ambGeneric.SetEnabled( false )

			ambGeneric = GetEntByScriptName( "AMB_NightBattle_Distant_Front" )
			ambGeneric.SetEnabled( true )
			ambGeneric = GetEntByScriptName( "AMB_NightBattle_Distant_Rear" )
			ambGeneric.SetEnabled( true )
			break
		default:
			ambGeneric = GetEntByScriptName( "AMB_NightBattle_Front" )
			ambGeneric.SetEnabled( false )
			ambGeneric = GetEntByScriptName( "AMB_NightBattle_Rear" )
			ambGeneric.SetEnabled( false )

			ambGeneric = GetEntByScriptName( "AMB_NightBattle_Distant_Front" )
			ambGeneric.SetEnabled( false )
			ambGeneric = GetEntByScriptName( "AMB_NightBattle_Distant_Rear" )
			ambGeneric.SetEnabled( false )
			break
	}
}

//  ########     ###    ########    ######## ########     ###     ######  ##    ##
//  ##     ##   ## ##      ##          ##    ##     ##   ## ##   ##    ## ##   ##
//  ##     ##  ##   ##     ##          ##    ##     ##  ##   ##  ##       ##  ##
//  ########  ##     ##    ##          ##    ########  ##     ## ##       #####
//  ##     ## #########    ##          ##    ##   ##   ######### ##       ##  ##
//  ##     ## ##     ##    ##          ##    ##    ##  ##     ## ##    ## ##   ##
//  ########  ##     ##    ##          ##    ##     ## ##     ##  ######  ##    ##

void function ServerCallback_TrackBatteryLocations( float x, float y, float z, bool real )
{
	vector origin = <x, y, z>
	CreateBatteryTracker( origin, real )
}

void function ServerCallback_ClearBatteryLocations( bool allRUI, float realDelay )
{
	if ( file.batteryValidRUI == null )
		return

	if ( allRUI == true && file.batteryValidRUI != null )
	{
		RuiDestroyIfAlive( file.batteryValidRUI )
		file.batteryValidRUI = null
		file.batteryTrackActive = false
	}
	else
	{
		RuiSetGameTime( file.batteryValidRUI, "fadeOutStart", Time() + realDelay )
		RuiSetBool( file.batteryValidRUI, "shouldDie", true )
	}

	foreach ( rui in file.batteryRUIs )
	{
		RuiSetGameTime( rui, "fadeOutStart", Time() )
		RuiSetBool( rui, "shouldDie", true )
	}
	file.batteryRUIs = []
}

void function BatteryCreateCallback( entity ent )
{
	if ( ent.GetModelName() != BATTERY_MODEL )
		return

	int attachID = ent.LookupAttachment( "fx_center" )
	StartParticleEffectOnEntity( ent, GetParticleSystemIndex( BATTERY_FX_FRIENDLY ), FX_PATTACH_POINT_FOLLOW, attachID )
}

void function CreateBatteryTracker( vector origin, bool real )
{
	entity player = GetLocalViewPlayer()

	if ( !file.batteryTrackActive )
	{
		file.batteryTrackActive = true
		int scanEffectIndex = GetParticleSystemIndex( SCAN_ENVIRONMENT_EFFECT )
		int particleIndex = StartParticleEffectInWorldWithHandle( scanEffectIndex, player.GetOrigin(), <0, 0, 0> )
		EffectSetControlPointVector( particleIndex, 1, <2.5, 50, 0> )
	}

	float targetValue = RandomFloatRange( 0.1, 0.4 )
	float capValue = RandomFloatRange( targetValue + 0.2, targetValue + 0.5 )

	if ( real )
	{
		targetValue = RandomFloatRange( 0.85, 0.95 )
		capValue = 1.0
	}

	const float DECRYPT_SPEED = 1
	float duration = ( capValue + ( capValue - targetValue ) ) * DECRYPT_SPEED

	var rui = CreateCockpitRui( $"ui/wilds_battery_tracker.rpak", 0 )
	RuiSetGameTime( rui, "startTime", Time() )
	RuiSetFloat( rui, "targetValue", targetValue )
	RuiSetFloat( rui, "capValue", capValue )
	RuiSetFloat( rui, "decryptDuration", duration )
	RuiSetFloat3( rui, "pos", origin )

	if( !real )
	{
		file.batteryRUIs.append( rui )
	}
	else
	{
		file.batteryValidRUI = rui
	}

	thread SoundsToMatch( duration, real )
}

void function SoundsToMatch( float decryptDuration, bool real )
{
	entity player = GetLocalViewPlayer()
	player.EndSignal( "OnDeath" )

	const float FADEIN_DURATION = 0.25
	const float FLICKER_IN_DURATION = 0.3

	wait FADEIN_DURATION

	EmitSoundOnEntity( player, "Wilds_Scr_HelmetHUD_PowerSourceScan" )

	wait FLICKER_IN_DURATION
	wait decryptDuration

	if ( real )
	{
		EmitSoundOnEntity( player, "Wilds_Scr_HelmetHUD_PowerSourceValid" )
		FlagSet( "power_source_found" )
	}
	else
	{
		EmitSoundOnEntity( player, "Wilds_Scr_HelmetHUD_PowerSourceInvalid" )
	}

}

//  ######## #### ########    ###    ##    ##     ######   #######   ######  ##    ## ########  #### ########
//     ##     ##     ##      ## ##   ###   ##    ##    ## ##     ## ##    ## ##   ##  ##     ##  ##     ##
//     ##     ##     ##     ##   ##  ####  ##    ##       ##     ## ##       ##  ##   ##     ##  ##     ##
//     ##     ##     ##    ##     ## ## ## ##    ##       ##     ## ##       #####    ########   ##     ##
//     ##     ##     ##    ######### ##  ####    ##       ##     ## ##       ##  ##   ##         ##     ##
//     ##     ##     ##    ##     ## ##   ###    ##    ## ##     ## ##    ## ##   ##  ##         ##     ##
//     ##    ####    ##    ##     ## ##    ##     ######   #######   ######  ##    ## ##        ####    ##

void function CockpitScreensThread( entity player, entity cockpit )
{
	player.EndSignal( "OnDestroy" )
	cockpit.EndSignal( "OnDestroy" )

	cockpit.SetCockpitPanelTransparency( 0, 0 )
	cockpit.SetCockpitPanelTransparency( 1, 0 )
	cockpit.SetCockpitPanelTransparency( 2, 0 )
	cockpit.SetCockpitPanelTransparency( 3, 0 )
	cockpit.SetCockpitPanelTransparency( 4, 0 )

	FlagWait( "activate_cockpit_screens" )
	EmitSoundOnEntity( player, "Wilds_Scr_ReinitializingCriticalSystems" )

	// center
	thread LerpCockpitPanelTransparency( cockpit, 2, 0.0, 1.0, 5, 0 )
	thread LerpCockpitPanelChroma( cockpit, 2, 1.0, 0.0, 8, 0 )

	// left
	thread LerpCockpitPanelTransparency( cockpit, 0, 0.0, 1.0, 4, 1 )
	thread LerpCockpitPanelChroma( cockpit, 0, 1.0, 0.0, 6, 1 )

	// upper
	thread LerpCockpitPanelTransparency( cockpit, 1, 0.0, 1.0, 3, 2 )
	thread LerpCockpitPanelChroma( cockpit, 1, 1.0, 0.0, 5, 2 )

	// bottom
	thread LerpCockpitPanelTransparency( cockpit, 3, 0.0, 1.0, 2, 3 )
	thread LerpCockpitPanelChroma( cockpit, 3, 1.0, 0.0, 4, 3 )

	// right
	thread LerpCockpitPanelTransparency( cockpit, 4, 0.0, 1.0, 1, 4 )
	thread LerpCockpitPanelChroma( cockpit, 4, 1.0, 0.0, 5, 4 )
}

void function ServerCallback_PilotLinkHud()
{
	thread PilotLinkHud()
}

void function PilotLinkHud()
{
	entity player = GetLocalClientPlayer()
	player.EndSignal( "OnDestroy" )

	array<var> ruiTextArray

	for( int i=0; i<5; i++ )
	{
		var rui = RuiCreate( $"ui/cockpit_console_text_top_left.rpak", clGlobal.topoFullScreen, RUI_DRAW_HUD, 0 )
		RuiSetInt( rui, "maxLines", 30 )
		RuiSetInt( rui, "lineNum", i )
		RuiSetString( rui, "msgText", "#BLANK_TEXT" )
		RuiSetFloat( rui, "msgFontSize", 36.0 )
		RuiSetFloat( rui, "msgAlpha", titleAlpha )
		RuiSetFloat3( rui, "msgColor", textYellow )
		RuiSetFloat2( rui, "msgPos", <250/fullWidth,380/fullHeight,0> ) //320
		ruiTextArray.append(rui)
	}

	thread HelmetBootUpAddLine( ruiTextArray, 0, "#WILDS_TITAN_PROTOCOL_1" )
	EmitSoundOnEntity( player, "Wilds_Scr_HelmetHUDText_BlipsProtocol" )
	wait 6
	RuiSetFloat( ruiTextArray[0], "msgAlpha", 0.0 )
	wait 3
	EmitSoundOnEntity( player, "Wilds_Scr_HelmetHUDText_BlipsProtocol" )
	thread HelmetBootUpAddLine( ruiTextArray, 0, "#WILDS_TITAN_PROTOCOL_1" )
	wait 9
	RuiSetFloat3( ruiTextArray[0], "msgColor", textColor )
	EmitSoundOnEntity( player, "Wilds_Scr_HelmetHUDText_BlipsProtocol" )
	waitthread HelmetBootUpAddLine( ruiTextArray, 2, "#WILDS_TITAN_PROTOCOL_2" )
	wait 6
	EmitSoundOnEntity( player, "Wilds_Scr_HelmetHUDText_BlipsProtocol" )
	EmitSoundOnEntity( player, "Wilds_Scr_HelmetHUDText_Mission" )
	waitthread HelmetBootUpAddLine( ruiTextArray, 2, "#WILDS_TITAN_PROTOCOL_2_LONG" )
	wait 7
	RuiSetFloat3( ruiTextArray[2], "msgColor", textColor )
	EmitSoundOnEntity( player, "Wilds_Scr_HelmetHUDText_BlipsProtocol" )
	waitthread HelmetBootUpAddLine( ruiTextArray, 4, "#WILDS_TITAN_PROTOCOL_3" )
	wait 5
	RuiSetFloat( ruiTextArray[0], "msgAlpha", 0.0 )
	wait 0.2
	RuiSetFloat( ruiTextArray[2], "msgAlpha", 0.0 )
	wait 0.2
	RuiSetFloat( ruiTextArray[4], "msgAlpha", 0.0 )

	wait 7 // some padding so that ruis can stop flicker.
	foreach( rui in ruiTextArray )
	{
		RuiDestroyIfAlive( rui )
	}
}

void function LerpCockpitPanelTransparency( entity cockpit, int screenNum, float startTrans, float endTrans, float duration, float delay )
{
	cockpit.EndSignal( "OnDestroy" )

	cockpit.SetCockpitPanelTransparency( screenNum, startTrans )

	if ( delay > 0 )
		wait delay

	float startTime = Time()
	while ( Time() < startTime + duration )
	{
		float frac = QuadEaseIn( ( Time() - startTime ) / duration )
		float transparency = GraphCapped( frac, 0, 1, startTrans, endTrans )

		float flickerFrac = (5.0/60) //* (1-frac)
		if ( RandomFloat( 1 ) < flickerFrac )
			transparency = RandomFloatRange( transparency * 2, min( transparency + transparency, 1 ) )

		cockpit.SetCockpitPanelTransparency( screenNum, transparency )
		WaitFrame()
	}

	cockpit.SetCockpitPanelTransparency( screenNum, endTrans )

}

void function LerpCockpitPanelChroma( entity cockpit, int screenNum, float startChroma, float endChroma, float duration, float delay )
{
	cockpit.EndSignal( "OnDestroy" )

	cockpit.SetCockpitPanelChroma( screenNum, startChroma )

	if ( delay > 0 )
		wait delay

	float startTime = Time()
	while ( Time() < startTime + duration )
	{
//		float frac = QuadEaseIn( ( Time() - startTime ) / duration )
		float frac = Tween_QuadEaseOut( ( Time() - startTime ) / duration )
		float rnd = RandomFloatRange( -0.25, 0.25 ) * ( 1 - frac )
		float chroma = GraphCapped( frac, 0, 1, startChroma, endChroma ) //+ rnd
		chroma = max( 0, min( 1, chroma ) )

		cockpit.SetCockpitPanelChroma( screenNum, chroma )
		WaitFrame()
	}

	cockpit.SetCockpitPanelChroma( screenNum, endChroma )
}

void function CreateCallback_TitanCockpit( entity cockpit )
{
	if ( !GetGlobalNetBool( "enteredTitanCockpit" ) )
		return

	thread EnteredTitanThread( cockpit )
}

void function EnteredTitanThread( entity createdCockpit )
{
	entity player = GetLocalClientPlayer()
	player.EndSignal( "OnDestroy" )

	// get titan cockpit for sure
	entity cockpit = player.GetCockpit()
	while ( !IsValid( cockpit ) || !player.IsTitan() )
	{
		cockpit = player.GetCockpit()
		WaitFrame()
	}
	cockpit.EndSignal( "OnDestroy" )

	ServerCallback_HideHudIcons()

	const lightDuration = 14.0

	thread CockpitScreensThread( player, cockpit )

	// color
	vector lightColor = < 0.65, 0.9, 1.0 >
	thread CockpitLight( cockpit, lightColor, 13, 4, "REF", <12,8,4>, "activate_cockpit_screens" )
	thread CockpitLight( cockpit, lightColor, 16, 2, "REF", <16,0,4>, "activate_cockpit_screens" )
	thread CockpitLight( cockpit, lightColor, 13, 4, "REF", <12,-8,4>, "activate_cockpit_screens" )

	cockpit.Anim_NonScriptedPlay( "ptpov_cockpit_first_embark" )
	cockpit.e.body.Anim_NonScriptedPlay( "ptpov_cockpit_first_embark" )

	wait 12.1 // 363 frames

	cockpit.Anim_NonScriptedPlay( "atpov_cockpit_hatch_close_idle" )
	cockpit.e.body.Anim_NonScriptedPlay( "atpov_cockpit_hatch_close_idle" )

	thread StartCockpitLook()
}

void function ServerCallback_NeuralLink()
{
	thread NeuralLinkScreenFX()
}

void function ServerCallback_ActivateCockpitScreens()
{
	FlagSet( "activate_cockpit_screens" )
}

void function NeuralLinkScreenFX()
{
	entity player = GetLocalClientPlayer()
	player.EndSignal( "OnDestroy" )

	// get titan cockpit for sure
	entity cockpit = player.GetCockpit()
	while ( !IsValid( cockpit ) || !player.IsTitan() )
	{
		cockpit = player.GetCockpit()
		WaitFrame()
	}
	cockpit.EndSignal( "OnDestroy" )

	int index1 = GetParticleSystemIndex( FX_POD_SCREEN_IN )
	int index2 = GetParticleSystemIndex( FX_POD_LASER )

	if ( IsValid( cockpit ) )
	{
		int fxID1 = StartParticleEffectOnEntity( player, index1, FX_PATTACH_POINT_FOLLOW, cockpit.LookupAttachment( "CAMERA" ) )
		//int fxID2 = StartParticleEffectOnEntity( player, index2, FX_PATTACH_POINT_FOLLOW, cockpit.LookupAttachment( "FX_LASER_L" ) )
		//int fxID3 = StartParticleEffectOnEntity( player, index2, FX_PATTACH_POINT_FOLLOW, cockpit.LookupAttachment( "FX_LASER_R" ) )
		EffectSetIsWithCockpit( fxID1, true )
		//EffectSetIsWithCockpit( fxID2, true )
		//EffectSetIsWithCockpit( fxID3, true )
	}

	wait 6
	player.ClientCommand( "NeuralLinkComplete" )
}

void function CockpitLight( entity cockpit, vector color, float radius, float duration, string tag = "SCR_CL_BL", vector offset = <0,0,0>, string endFlag = "" )
{
	cockpit.EndSignal( "TitanUnDoomed" )
	cockpit.EndSignal( "OnDestroy" )

	int attachID = cockpit.LookupAttachment( tag )
	Assert( attachID > 0 )

	vector angles = cockpit.GetAttachmentAngles( attachID )
	vector forward = AnglesToForward( angles )
	vector right = AnglesToRight( angles )
	vector up = AnglesToUp( angles )
	vector origin = cockpit.GetAttachmentOrigin( attachID )
	origin = origin + forward * offset.x + right * offset.y + up * offset.z

	entity fxLight = CreateClientSideDynamicLight( origin, <0,0,0>, color, radius )
	fxLight.SetCockpitLight( true )
	fxLight.SetParent( cockpit )

	OnThreadEnd(
		function() : ( fxLight )
		{
			fxLight.Destroy()
		}
	)

	float startTime = Time()
	float rate = 3.0

	fxLight.SetLightColor( color )

	if ( endFlag != "" )
		FlagWait( endFlag )

	if ( duration > 0 )
		wait duration
}

//   ######   #######   ######  ##    ## ########  #### ########    ##        #######   #######  ##    ##
//  ##    ## ##     ## ##    ## ##   ##  ##     ##  ##     ##       ##       ##     ## ##     ## ##   ##
//  ##       ##     ## ##       ##  ##   ##     ##  ##     ##       ##       ##     ## ##     ## ##  ##
//  ##       ##     ## ##       #####    ########   ##     ##       ##       ##     ## ##     ## #####
//  ##       ##     ## ##       ##  ##   ##         ##     ##       ##       ##     ## ##     ## ##  ##
//  ##    ## ##     ## ##    ## ##   ##  ##         ##     ##       ##       ##     ## ##     ## ##   ##
//   ######   #######   ######  ##    ## ##        ####    ##       ########  #######   #######  ##    ##

void function ServerCallback_StartCockpitLook()
{
	if ( file.cockpitLookActive )
		ServerCallback_StopCockpitLook()

	thread StartCockpitLook()
}

void function StartCockpitLook()
{
	file.cockpitLookActive = true
	entity player = GetLocalViewPlayer()

	// get titan cockpit for sure
	entity cockpit = player.GetCockpit()
	while ( !IsValid( cockpit ) || !player.IsTitan() )
	{
		cockpit = player.GetCockpit()
		WaitFrame()
	}

	cockpit.Anim_NonScriptedPlay( "atpov_look_idle" )
	thread LookAround( cockpit )

	RegisterStickMovedCallback( ANALOG_RIGHT_X, CockpitLookRightStickX )
	RegisterStickMovedCallback( ANALOG_RIGHT_Y, CockpitLookRightStickY )
}

void function ServerCallback_StopCockpitLook()
{
	thread StopCockpitLookThread()
}

void function StopCockpitLookThread()
{
	if ( !file.cockpitLookActive )
		return

	file.cockpitLookActive = false

	entity player = GetLocalViewPlayer()
	player.EndSignal( "OnDestroy" )

	// get titan cockpit for sure
	entity cockpit = player.GetCockpit()
	while ( !IsValid( cockpit ) || !player.IsTitan() )
	{
		cockpit = player.GetCockpit()
		WaitFrame()
	}

	cockpit.Anim_NonScriptedPlay( "atpov_cockpit_hatch_close_idle" )
	Signal( clGlobal.levelEnt, "LookAround" )
	DeregisterStickMovedCallback( ANALOG_RIGHT_X, CockpitLookRightStickX )
	DeregisterStickMovedCallback( ANALOG_RIGHT_Y, CockpitLookRightStickY )
	thread CenterView()
}

void function CenterView()
{
	while ( fabs(file.cockpitYaw) > 0 || fabs(file.cockpitPitch) > 0 )
	{
		if ( fabs(file.cockpitYaw) < 2 )
			file.cockpitYaw = 0
		else
			file.cockpitYaw *= 0.9

		if ( fabs(file.cockpitPitch) < 2 )
			file.cockpitPitch = 0
		else
			file.cockpitPitch *= 0.9

		wait 0.05
	}

	file.currentStickYaw = 0.0
	file.currentStickPitch = 0.0
}

void function LookAround( entity body )
{
	body.EndSignal( "OnDestroy" )
	EndSignal( clGlobal.levelEnt, "LookAround" )

	thread SineBaseView( body )

	int dir = 1
	float angle = 0.0
	while( 1 )
	{
		if ( fabs( file.currentStickYaw ) < 0.2 )
			file.currentStickYaw = 0.0
		if ( fabs( file.currentStickPitch ) < 0.2 )
			file.currentStickPitch = 0.0

		file.cockpitYaw = clamp( file.cockpitYaw - (file.currentStickYaw * YAW_SPEED ), -1*YAW_MAX, YAW_MAX )
		file.cockpitPitch = clamp( file.cockpitPitch + (file.currentStickPitch * PITCH_SPEED ), -1*PITCH_MAX, PITCH_MAX )

		// printt( "---------------" )
		// printt( file.cockpitYaw )
		// printt( file.cockpitPitch )
		// printt( "---------------" )

		body.SetPoseParameter( "aim_yaw", file.baseView.x + file.cockpitYaw )
		body.SetPoseParameter( "aim_pitch", file.baseView.y + file.cockpitPitch )
		WaitFrame()
	}
}

void function SineBaseView( entity body )
{
	body.EndSignal( "OnDestroy" )
	EndSignal( clGlobal.levelEnt, "LookAround" )

	float startTime = Time()
	float speedScale = 0.5

	while ( 1 )
	{
		float baseX = cos( (Time()-startTime) * speedScale )
		float baseY = cos( (Time()-startTime) * 2 * speedScale )

		file.baseView = <baseX,baseY,0>
		WaitFrame()
	}
}

void function CockpitLookRightStickX( entity player, float val )
{
	file.currentStickYaw = val
}

void function CockpitLookRightStickY( entity player, float val )
{
	if ( GetJoyInvert() )
		val *= -1

	file.currentStickPitch = val
}

//     ###    ##    ## #### ##     ##    ######## ##     ## ######## ##    ## ########  ######
//    ## ##   ###   ##  ##  ###   ###    ##       ##     ## ##       ###   ##    ##    ##    ##
//   ##   ##  ####  ##  ##  #### ####    ##       ##     ## ##       ####  ##    ##    ##
//  ##     ## ## ## ##  ##  ## ### ##    ######   ##     ## ######   ## ## ##    ##     ######
//  ######### ##  ####  ##  ##     ##    ##        ##   ##  ##       ##  ####    ##          ##
//  ##     ## ##   ###  ##  ##     ##    ##         ## ##   ##       ##   ###    ##    ##    ##
//  ##     ## ##    ## #### ##     ##    ########    ###    ######## ##    ##    ##     ######

void function CreateFirstPersonProxyAnimEvents( entity proxy )
{
	// prowler moment deepth of field
	AddAnimEvent( proxy, "prowler_dof_start", AnimEvent_DOFStart )
	AddAnimEvent( proxy, "prowler_dof_stop", AnimEvent_DOFStop )
}

void function AnimEvent_DOFStart( entity proxy )
{
	DoF_SetFarDepth( 400, 1500)
	DoF_SetNearDepth( 0, 350 )
	wait 5
	DoF_LerpNearDepth( 1, 20, 3.0 )
	wait 8
	DoF_LerpFarDepth( 2000, 8000, 4.0 )
}

void function AnimEvent_DOFStop( entity proxy )
{
	DoF_LerpFarDepthToDefault( 4.0 )
	DoF_LerpNearDepthToDefault( 4.0 )
}

//   ######  ##     ## ######## ##       ##           ######  ##     ##  #######   ######  ##    ##
//  ##    ## ##     ## ##       ##       ##          ##    ## ##     ## ##     ## ##    ## ##   ##
//  ##       ##     ## ##       ##       ##          ##       ##     ## ##     ## ##       ##  ##
//   ######  ######### ######   ##       ##           ######  ######### ##     ## ##       #####
//        ## ##     ## ##       ##       ##                ## ##     ## ##     ## ##       ##  ##
//  ##    ## ##     ## ##       ##       ##          ##    ## ##     ## ##     ## ##    ## ##   ##
//   ######  ##     ## ######## ######## ########     ######  ##     ##  #######   ######  ##    ##

void function ServerCallback_ShellShock()
{
//	thread ShellShockSceenShake()
	thread ShellShockDOF()
//	thread ShellShockBlur()
//	thread ShellShockScreenFade()
	thread ShellShockSceenEffect()
	thread ShellShockColorCorrection()
}

void function ServerCallback_ShellShockStop()
{
	entity player = GetLocalViewPlayer()

	Signal( level, "shell_shock_end" )
}

void function ShellShockSceenEffect()
{
	entity player = GetLocalViewPlayer()
	EndSignal( player, "OnDeath" )
	EndSignal( level, "shell_shock_end" )

	// get player cockpit
	entity cockpit = player.GetCockpit()
	while ( !IsValid( cockpit ) )
	{
		cockpit = player.GetCockpit()
		WaitFrame()
	}
	cockpit.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function() : ()
		{
			if ( !EffectDoesExist( file.ScreenFxHandle ) )
				return

			EffectStop( file.ScreenFxHandle, false, true )
		}
	)


	if ( IsValid( cockpit ) )
	{
		if ( EffectDoesExist( file.ScreenFxHandle ) )
			return

		file.ScreenFxHandle = StartParticleEffectOnEntity( cockpit, GetParticleSystemIndex( SHELL_SHOCK_EFFECT ), FX_PATTACH_ABSORIGIN_FOLLOW, -1 )
	}

	WaitSignal( level, "shell_shock_end" )

}

void function ScreenEffectThink( entity player, int fxHandle, entity cockpit )
{
	EndSignal( player, "OnDeath" )
	EndSignal( cockpit, "OnDestroy" )

	OnThreadEnd(
		function() : ( fxHandle )
		{
			if ( !EffectDoesExist( fxHandle ) )
				return

			EffectStop( fxHandle, false, true )
		}
	)

	WaitSignal( player, "StopScreenEffect" )
}


void function ShellShockColorCorrection()
{
	entity player = GetLocalViewPlayer()
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDeath" )
	EndSignal( level, "shell_shock_end" )

	OnThreadEnd(
		function() : ()
		{
			thread ColorCorrection_LerpWeight( file.colorCorrection, 1, 0, 0.5 )
		}
	)

	thread ColorCorrection_LerpWeight( file.colorCorrection, 0, 1, 0.5 )

	WaitForever()
}

void function ColorCorrection_LerpWeight( int colorCorrection, float startWeight, float endWeight, float lerpTime = 0 )
{
	float startTime = Time()
	float endTime = startTime + lerpTime
	while( Time() <= endTime )
	{
		WaitFrame()
		float weight = GraphCapped( Time(), startTime, endTime, startWeight, endWeight )
		ColorCorrection_SetWeight( colorCorrection, weight )
	}

	ColorCorrection_SetWeight( colorCorrection, endWeight )
}

void function ShellShockDOF()
{
	entity player = GetLocalClientPlayer()
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDeath" )
	EndSignal( level, "shell_shock_end" )

	OnThreadEnd(
		function() : ()
		{
			// reset Depth of Field
			DoF_LerpFarDepthToDefault( 1.5 )
			DoF_LerpNearDepthToDefault( 1.5 )
		}
	)

	DoF_LerpFarDepth( 2000, 8000, 1.0 )
	DoF_LerpNearDepth( 1, 50, 1.0 )

	WaitForever()
}

void function ShellShockBlur()
{
	entity player = GetLocalClientPlayer()
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDeath" )
	EndSignal( level, "shell_shock_end" )

	OnThreadEnd(
		function() : ()
		{
			SetScreenBlur( 0, 0.25, EASING_SINE_INOUT )
		}
	)

	float waitTime
	int inNOut = 1
	while( true )
	{

		// blur screen stuff
		if ( inNOut == 1 )
		{
			// blur
			float blurAmount = RandomFloatRange( 0.25, 1 )
			float blurTime = RandomFloatRange( blurAmount, blurAmount + 1.0 )

			SetScreenBlur( blurAmount, blurTime, EASING_SINE_INOUT )

			waitTime = RandomFloatRange( 0.25, 0.75 ) + blurTime
		}
		else
		{
			// clear
			float clearTime = RandomFloatRange( 0.5, 3 )
			SetScreenBlur( 0, clearTime, EASING_SINE_INOUT )

			waitTime = RandomFloatRange( 1, 4 ) + clearTime
		}

		wait waitTime

		inNOut = inNOut^1
	}
}

void function ShellShockScreenFade()
{
	entity player = GetLocalClientPlayer()
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDeath" )
	EndSignal( level, "shell_shock_end" )

	OnThreadEnd(
	function() : ( player )
		{
			ScreenFade( player, 0, 0, 0, 0, 0.1, 0, FFADE_PURGE )
		}
	)

	// alpha, fadein, hangTime, fadeout, waitTime
	array<float> fadePattern = [
		150.0, 1.0, 0.0, 2.0, 1.0,
		200.0, 1.0, 0.0, 4.0, 4.0,
		150.0, 2.0, 0.25, 1.0, 5.0,
	]
	Assert( fadePattern.len()%5 == 0 )

	float fadeTime
	while( true )
	{
		float oldAlpha = 0
		for( int i = 0; i < fadePattern.len(); )
		{
			float alpha = fadePattern[ i++ ]
			float fadeInTime = fadePattern[ i++ ]
			float hangTime = fadePattern[ i++ ]
			float fadeOutTime = fadePattern[ i++ ]
			float waitTime = fadePattern[ i++ ]

			thread ScreenFadeThread( player, alpha, fadeInTime, hangTime, fadeOutTime )
			wait waitTime

			if ( !RandomIntRange( 0, 4 ) )
			{
				// blink
				thread ScreenFadeThread( player, 255, 0.1, 0.0, 0.25 )
			}
		}
	}
}

void function ScreenFadeThread( entity player, float alpha, float fadeInTime, float hangTime, float fadeOutTime )
{
	ScreenFade( player, 0, 0, 0, alpha, fadeInTime, hangTime + 0.1, FFADE_OUT | FFADE_MODULATE ) // +0.1 is a hack to avoid flickering
	wait fadeInTime + hangTime
	ScreenFade( player, 0, 0, 0, alpha, fadeOutTime, 0.0, FFADE_IN | FFADE_MODULATE )
}

void function ShellShockSceenShake()
{
	entity player = GetLocalClientPlayer()
	player.EndSignal( "OnDestroy" )

	EndSignal( level, "shell_shock_end" )

	while( true )
	{
		vector vec
		switch( RandomIntRange( 0, 3 ) )
		{
			case 0:
				vec = player.GetForwardVector()
				break
			case 1:
				vec = player.GetRightVector()
				break
			case 2:
				vec = player.GetUpVector()
				break

		}
		ClientScreenShake( 4, 2, 5, vec )
		wait RandomFloatRange( 1.0, 2.0 )
	}
}

//  ##     ## ######## ##       ##     ## ######## ########    ########   #######   #######  ########    ##     ## ########
//  ##     ## ##       ##       ###   ### ##          ##       ##     ## ##     ## ##     ##    ##       ##     ## ##     ##
//  ##     ## ##       ##       #### #### ##          ##       ##     ## ##     ## ##     ##    ##       ##     ## ##     ##
//  ######### ######   ##       ## ### ## ######      ##       ########  ##     ## ##     ##    ##       ##     ## ########
//  ##     ## ##       ##       ##     ## ##          ##       ##     ## ##     ## ##     ##    ##       ##     ## ##
//  ##     ## ##       ##       ##     ## ##          ##       ##     ## ##     ## ##     ##    ##       ##     ## ##
//  ##     ## ######## ######## ##     ## ########    ##       ########   #######   #######     ##        #######  ##

void function ServerCallback_HelmetBootUpSequence()
{
	entity player = GetLocalClientPlayer()
	thread HelmetBootUpSequence( player )
	EmitSoundOnEntity( player, "Wilds_Scr_HelmetBootUp" )
}

void function ServerCallback_BuddyTitanFlyout( int eHandleBuddyTitan, bool nag = false )
{
	entity player = GetLocalClientPlayer()
	entity buddyTitan = GetEntityFromEncodedEHandle( eHandleBuddyTitan )

	if ( !nag )
		thread BuddyTitanFlyout( player, buddyTitan )
	else
		thread BuddyTitanFlyoutNag( player, buddyTitan )
}

void function HelmetBootUpSequence( entity player )
{
	array<var> allRuis
	array<var> ruiTextArray

	var rebootRui = RuiCreate( $"ui/helmet_reboot.rpak", clGlobal.topoFullScreen, RUI_DRAW_HUD, 0 )
	allRuis.append( rebootRui )

	var borderRui = CreateCockpitRui( $"ui/helmet_border.rpak", 100 )
	allRuis.append( borderRui )

	//make sure the screen isn't faded
	ScreenFade( player, 0, 0, 0, 0, 1, 1, FFADE_IN | FFADE_PURGE )

	//make sure the hud icons are hidden
	ServerCallback_HideHudIcons()

	// base
	hexSetStruct hexSet
	hexSet.lineNum = 0
	hexSet.msgFontSize = 18
	hexSet.msgColor = <0.1, 0.23, 0.4>
	hexSet.msgAlpha = 0.75

	for( int i=0; i<10; i++ )
	{
		var rui = CreateCockpitRui( $"ui/cockpit_console_text_top_left.rpak", 200 )
		RuiSetInt( rui, "maxLines", 30 )
		RuiSetInt( rui, "lineNum", i )
		RuiSetString( rui, "msgText", "#BLANK_TEXT" )
		RuiSetFloat( rui, "msgFontSize", 28.0 )
		//		RuiSetFloat( rui, "thicken", -1.0 )
		RuiSetFloat( rui, "msgAlpha", textAlpha )
		RuiSetFloat3( rui, "msgColor", textColor )
		RuiSetFloat2( rui, "msgPos", <110/fullWidth,110/fullHeight,0> )
		ruiTextArray.append(rui)
	}
	allRuis.extend( ruiTextArray )

	wait 1.5

	// top right
	hexSet.maxLines = 12
	hexSet.colums = 6
	hexSet.alignment = 1
	hexSet.msgPos = <1810/fullWidth, 110/fullHeight, 0> //1810
	thread HexDump( clone hexSet, 2.0 )

	// bottom right
	hexSet.maxLines = 5
	hexSet.colums = 8
	hexSet.alignment = 1
	hexSet.msgPos = <1800/fullWidth, 850/fullHeight, 0>
	thread HexDump( clone hexSet, 3.0 )

	wait 0.5

	// top left
	hexSet.maxLines = 12
	hexSet.colums = 6
	hexSet.alignment = 0
	hexSet.msgPos = <110/fullWidth, 110/fullHeight, 0>
	waitthread HexDump( clone hexSet, 1.0 )

	RuiSetString( ruiTextArray[0], "msgText", "#WILDS_HELMET_REBOOT_NEW_USER" )
	EmitSoundOnEntity( player, "Wilds_Scr_HelmetHUDText_BlipsNewUser" )
	waitthread FlickerRui( ruiTextArray[0], textAlpha, 0.0, 2, 3 )

	wait 1.66

	int lineNum = 0
	waitthread HelmetBootUpAddLine( ruiTextArray, lineNum++, "#WILDS_HELMET_REBOOT_FIRST_NAME" )
	waitthread HelmetBootUpAddLine( ruiTextArray, lineNum++, "#WILDS_HELMET_REBOOT_LAST_NAME" )
	waitthread HelmetBootUpAddLine( ruiTextArray, lineNum++, "#WILDS_HELMET_REBOOT_SERIAL" )
	lineNum++
	waitthread HelmetBootUpAddLine( ruiTextArray, lineNum++, "#WILDS_HELMET_REBOOT_BLOOD_TYPE" )
	waitthread HelmetBootUpAddLine( ruiTextArray, lineNum++, "#WILDS_HELMET_REBOOT_BIRTH_DATE" )
	waitthread HelmetBootUpAddLine( ruiTextArray, lineNum++, "#WILDS_HELMET_REBOOT_UNIT" )
	lineNum++
	waitthread HelmetBootUpAddLine( ruiTextArray, lineNum++, "#WILDS_HELMET_REBOOT_RANK" )

	wait 4

	thread FlickerRuiArray( ruiTextArray, 0.0, textAlpha, 0.0 )
	EmitSoundOnEntity( player, "Wilds_Scr_HelmetHUDText_Blips" )
	wait 0.5

	RuiSetString( ruiTextArray[0], "msgText", "#WILDS_HELMET_REBOOT_COMBAT_SYSTEMS" )
	waitthread FlickerRui( ruiTextArray[0], textAlpha, 0.0, 2, 3 )

	// lower left new
	hexSet.maxLines = 20
	hexSet.colums = 8
	hexSet.alignment = 0
	hexSet.msgPos = <270/fullWidth, 700/fullHeight, 0>
	thread HexDump( clone hexSet, 1.0 )

	wait 2.0

	waitthread HelmetBootUpAddLine( ruiTextArray, 2, "#WILDS_HELMET_REBOOT_TACTICAL" )
	thread AnimateDots( ruiTextArray[2], "#WILDS_HELMET_REBOOT_TACTICAL", "msgText", 2.5, "#WILDS_HELMET_REBOOT_OK" )
	thread RevealHudIconsThread( 0, OFFHAND_LEFT )
	EmitSoundOnEntity( player, "Wilds_Scr_HelmetHUD_KitAbilityInitialize" )
	wait 1.5
	RuiSetGameTime( borderRui, "tacticalHintTime", Time() )
	wait 1.5
	waitthread HelmetBootUpAddLine( ruiTextArray, 3, "#WILDS_HELMET_REBOOT_ORDNANCE" )
	thread AnimateDots( ruiTextArray[3], "#WILDS_HELMET_REBOOT_ORDNANCE", "msgText", 2.5, "#WILDS_HELMET_REBOOT_OK" )
	thread RevealHudIconsThread( 0, OFFHAND_RIGHT )
	EmitSoundOnEntity( player, "Wilds_Scr_HelmetHUD_OrdnanceInitialize" )
	wait 1.5
	RuiSetGameTime( borderRui, "ordnanceHintTime", Time() )
	wait 1.5
	waitthread HelmetBootUpAddLine( ruiTextArray, 4, "#WILDS_HELMET_REBOOT_WEAPON" )
	thread AnimateDots( ruiTextArray[4], "#WILDS_HELMET_REBOOT_WEAPON", "msgText", 2.5, "#WILDS_HELMET_REBOOT_OK" )
	thread RevealHudIconsThread( 0, 3 ) // MAIN WEAPON
	EmitSoundOnEntity( player, "Wilds_Scr_HelmetHUD_PrimaryWeaponInitialize" )
	wait 1.5
	RuiSetGameTime( borderRui, "weaponHintTime", Time() )
	clGlobal.levelEnt.Signal( "end_fade_over_time" )

	wait 1
	player.ClientCommand( "HelmetBootUpComplete" )

	wait 4
	// don't destroy the ruis right away. the flicker script might still be running for a frame or two
	clGlobal.levelEnt.Signal( "end_flicker" ) // make sure no flickering is going on
	foreach( rui in allRuis )
	{
		RuiDestroyIfAlive( rui )
	}
}

void function HelmetBootUpAddLine( array<var> ruiArray, int lineNum, string msgText )
{
	entity player = GetLocalClientPlayer()
	var rui = ruiArray[ lineNum ]

	EmitSoundOnEntity( player, "Wilds_Scr_HelmetHUDText_Print" )

	RuiSetString( rui, "msgText", msgText )
	waitthread FlickerRui( rui, textAlpha, 0.0, 0.25, 20 )
	wait 0.25

	StopSoundOnEntity( player, "Wilds_Scr_HelmetHUDText_Print" )
}

void function BuddyTitanFlyout( entity player, entity buddyTitan )
{
	var flyoutRui = RuiCreate( $"ui/buddy_titan_low_power.rpak", clGlobal.topoFullScreen, RUI_DRAW_HUD, 0 )

	RuiSetResolutionToScreenSize( flyoutRui )
	RuiSetGameTime( flyoutRui, "startTime", Time() )
	RuiTrackFloat3( flyoutRui, "pos", buddyTitan, RUI_TRACK_POINT_FOLLOW, buddyTitan.LookupAttachment( "HATCH_HEAD" ) )
	RuiSetString( flyoutRui, "titleText", "#WILD_POWER_LEVEL_FLYOUT_TITLE" )
	RuiSetBool( flyoutRui, "isVisible", true )

	wait 1
	RuiSetString( flyoutRui, "descriptionText", "#WILD_POWER_LEVEL_FLYOUT_DESCRIPTON" )
	// <- sound for power level critical
	EmitSoundOnEntity( player, "Wilds_Scr_HelmetHUDText_BlipsFast" )
	waitthread FlickerRui( flyoutRui, 1.0, 0.0, 2, 5 )

	wait 2
	RuiSetString( flyoutRui, "descriptionText", "#BLANK_TEXT" )

	wait 1.0
	player.ClientCommand( "BuddyTitanFlyoutComplete" )

	RuiSetString( flyoutRui, "descriptionText", "#WILD_POWER_LEVEL_FLYOUT_SCANNING" )
	EmitSoundOnEntity( player, "Wilds_Scr_HelmetHUDText_BlipsFast" )
	thread AnimateDots( flyoutRui, "#WILD_POWER_LEVEL_FLYOUT_SCANNING", "descriptionText" )
	EmitSoundOnEntity( player, "Wilds_Scr_HelmetHud_ScanForPowerSources" )
	waitthread FlickerRui( flyoutRui, 1.0, 0.0, 2, 5 )

	FlagWait( "power_source_found" )
	StopAnimateDots()

	RuiSetString( flyoutRui, "descriptionText", "#WILD_POWER_LEVEL_FLYOUT_TOPO" )
	EmitSoundOnEntity( player, "Wilds_Scr_HelmetHUDText_BlipsFast" )
	thread AnimateDots( flyoutRui, "#WILD_POWER_LEVEL_FLYOUT_TOPO", "descriptionText" )
	waitthread FlickerRui( flyoutRui, 1.0, 0.0, 2, 5 )
	wait 2
	StopAnimateDots()

	RuiSetString( flyoutRui, "descriptionText", "#WILD_POWER_LEVEL_FLYOUT_ROUTE" )
	// <- sound for route
	EmitSoundOnEntity( player, "Wilds_Scr_HelmetHUDText_BlipsFast" )
	waitthread FlickerRui( flyoutRui, 1.0, 0.0, 2, 5 )
	wait 2

	RuiDestroyIfAlive( flyoutRui )
}

void function BuddyTitanFlyoutNag( entity player, entity buddyTitan )
{
	var flyoutRui = RuiCreate( $"ui/buddy_titan_low_power.rpak", clGlobal.topoFullScreen, RUI_DRAW_HUD, 0 )

	RuiSetResolutionToScreenSize( flyoutRui )
	RuiSetGameTime( flyoutRui, "startTime", Time() )
	RuiTrackFloat3( flyoutRui, "pos", buddyTitan, RUI_TRACK_POINT_FOLLOW, buddyTitan.LookupAttachment( "HATCH_HEAD" ) )
	RuiSetString( flyoutRui, "titleText", "#WILD_POWER_LEVEL_FLYOUT_TITLE" )
	RuiSetBool( flyoutRui, "isVisible", true )

	RuiSetString( flyoutRui, "descriptionText", "#WILD_POWER_LEVEL_FLYOUT_DESCRIPTON" )
	// <- sound for power level critical (nag)
	EmitSoundOnEntity( player, "Wilds_Scr_HelmetHUDText_BlipsFast" )
	waitthread FlickerRui( flyoutRui, 1.0, 0.0, 2, 5 )

	wait 3

	RuiDestroyIfAlive( flyoutRui )
}

void function ServerCallback_GraveShadowsAndDOF( bool active )
{
	printt( "ServerCallback_GraveShadowsAndDOF", active )
	if ( active )
	{
		DoF_SetFarDepth( 700, 10000 )
//		DoF_SetNearDepth( 0, 350 )
		SetMapSetting_CsmTexelScale( 0.15, 0.5 )
	}
	else
	{
		printt( "TURN OFF ServerCallback_GraveShadowsAndDOF" )
		DoF_LerpFarDepthToDefault( 4.0 )
//		DoF_LerpNearDepthToDefault( 4.0 )
		SetMapSetting_CsmTexelScale( 1.0, 1.0 )
	}
}

void function ServerCallback_FieldPromotionShadows( bool active )
{
	printt( "ServerCallback_FieldPromotionShadows", active )
	if ( active )
	{
//		DoF_SetFarDepth( 700, 10000 )
//		DoF_SetNearDepth( 0, 350 )
		SetMapSetting_CsmTexelScale( 0.25, 0.25 )
	}
	else
	{
//		DoF_LerpFarDepthToDefault( 4.0 )
//		DoF_LerpNearDepthToDefault( 4.0 )
		SetMapSetting_CsmTexelScale( 1.0, 1.0 )
	}
}

//        ## ##     ## ##     ## ########     ##    ## #### ########
//        ## ##     ## ###   ### ##     ##    ##   ##   ##     ##
//        ## ##     ## #### #### ##     ##    ##  ##    ##     ##
//        ## ##     ## ## ### ## ########     #####     ##     ##
//  ##    ## ##     ## ##     ## ##           ##  ##    ##     ##
//  ##    ## ##     ## ##     ## ##           ##   ##   ##     ##
//   ######   #######  ##     ## ##           ##    ## ####    ##

void function ServerCallback_JumpKitCalibrationStart( int stepIndex )
{
	entity player = GetLocalClientPlayer()

	Assert( player.GetPlayerNetInt( "jumpKitCalibrationStep" ) == stepIndex )
	file.newStepIndex = stepIndex

	JumpKitCalibrationRuiCreate()

	Assert( stepIndex >= 0 )
	if ( stepIndex == 0 )
		thread JumpKitCalibrationStart( player )
	else
		thread JumpKitCalibrationSteps( player )
}

void function ServerCallback_JumpKitCalibrationStep( int stepIndex )
{
	file.nextAllowHintTime = Time() + 6

	entity player = GetLocalClientPlayer()
	Assert( player.GetPlayerNetInt( "jumpKitCalibrationStep" ) == stepIndex )

	if ( stepIndex == -1 )
	{
		FlagSet( "double_jump_confirmed" )
	}
	else
	{
		file.newStepIndex = stepIndex
		player.Signal( "next_calibration_step" )
	}
}

void function JumpKitCalibrationRuiCreate()
{
	var titleRui = CreateCockpitRui( $"ui/cockpit_console_text_top_left.rpak", 0 )
	RuiSetInt( titleRui, "maxLines", 3 )
	RuiSetInt( titleRui, "lineNum", 0 )
	RuiSetString( titleRui, "msgText", "#BLANK_TEXT" )
	RuiSetFloat( titleRui, "msgFontSize", 30.0 )
	RuiSetFloat( titleRui, "msgAlpha", 0.0 )
	RuiSetFloat3( titleRui, "msgColor", <0,0,0> )
	RuiSetFloat2( titleRui, "msgPos", <xOffset, yOffset, 0.0> )
	file.jumpKitRuiArray.append( titleRui )

	var line1Rui = CreateCockpitRui( $"ui/cockpit_console_text_top_left.rpak", 0 )
	RuiSetInt( line1Rui, "maxLines", 3 )
	RuiSetInt( line1Rui, "lineNum", 2 )
	RuiSetString( line1Rui, "msgText", "#BLANK_TEXT" )
	RuiSetFloat( line1Rui, "msgFontSize", 24.0 )
	RuiSetFloat( titleRui, "msgAlpha", 1.0 )
	RuiSetFloat3( titleRui, "msgColor", <0,0,0> )
	RuiSetFloat2( line1Rui, "msgPos", <xOffset, yOffset, 0.0> )
	file.jumpKitRuiArray.append( line1Rui )

	var line2Rui = CreateCockpitRui( $"ui/cockpit_console_text_top_left.rpak", 0 )
	RuiSetInt( line2Rui, "maxLines", 3 )
	RuiSetInt( line2Rui, "lineNum", 3 )
	RuiSetString( line2Rui, "msgText", "#BLANK_TEXT" )
	RuiSetFloat( line2Rui, "msgFontSize", 24.0 )
	RuiSetFloat( titleRui, "msgAlpha", 1.0 )
	RuiSetFloat3( titleRui, "msgColor", <0,0,0> )
	RuiSetFloat2( line2Rui, "msgPos", <xOffset, yOffset, 0.0> )
	file.jumpKitRuiArray.append( line2Rui )
}

void function JumpKitCalibrationStart( entity player )
{
	player.EndSignal( "OnDeath" )

	var titleRui = file.jumpKitRuiArray[0]
	var line1Rui = file.jumpKitRuiArray[1]
	var line2Rui = file.jumpKitRuiArray[2]

	RuiSetInt( titleRui, "maxLines", 3 )
	RuiSetInt( titleRui, "lineNum", 0 )
	RuiSetString( titleRui, "msgText", "#WILDS_CALIBRATION_TITLE_NEW_USER" )
	RuiSetFloat( titleRui, "msgFontSize", 30.0 )
	RuiSetFloat( titleRui, "msgAlpha", titleAlpha )
	RuiSetFloat3( titleRui, "msgColor", textColor ) // <0.8,0,0> )
	RuiSetFloat2( titleRui, "msgPos", <xOffset, yOffset, 0.0> )
	EmitSoundOnEntity( player, "Wilds_Scr_HelmetHUDText_Blip" )
	waitthread FlickerRui( titleRui, titleAlpha, 2.5 )

	hexSetStruct hexSet
	waitthread HexDump( hexSet, 1.0 )

	RuiSetInt( line1Rui, "maxLines", 3 )
	RuiSetInt( line1Rui, "lineNum", 2 )
	RuiSetString( line1Rui, "msgText", Localize( "#WILDS_CALIBRATION_USER_MASS" ) )
	RuiSetFloat( line1Rui, "msgFontSize", 24.0 )
	RuiSetFloat( line1Rui, "msgAlpha", textAlpha )
	RuiSetFloat3( line1Rui, "msgColor", textColor )
	RuiSetFloat2( line1Rui, "msgPos", <xOffset, yOffset, 0.0> )

	RuiSetInt( line2Rui, "maxLines", 3 )
	RuiSetInt( line2Rui, "lineNum", 3 )
	RuiSetString( line2Rui, "msgText", Localize( "#WILDS_CALIBRATION_RECALIBRATING", "" ) )
	RuiSetFloat( line2Rui, "msgFontSize", 24.0 )
	RuiSetFloat( line2Rui, "msgAlpha", textAlpha )
	RuiSetFloat3( line2Rui, "msgColor", textColor )
	RuiSetFloat2( line2Rui, "msgPos", <xOffset, yOffset, 0.0> )

	thread AnimateDots( line2Rui, "#WILDS_CALIBRATION_RECALIBRATING" )

	wait 5
	StopAnimateDots()

	RuiSetString( titleRui, "msgText", "#WILDS_CALIBRATION_TITLE_NEW_USER" )

	RuiSetFloat( line1Rui, "msgAlpha", 0.0 )
	RuiSetFloat( line2Rui, "msgAlpha", 0.0 )
	RuiSetString( line2Rui, "msgText", Localize( "#BLANK_TEXT" ) )

	JumpKitCalibrationSteps( player )
}

void function JumpKitCalibrationSteps( entity player )
{
	player.EndSignal( "OnDeath" )

	array<string> calibrationStepArray
	calibrationStepArray.append( "#WILDS_CALIBRATION_STEP_1" )
	calibrationStepArray.append( "#WILDS_CALIBRATION_STEP_2" )
	calibrationStepArray.append( "#WILDS_CALIBRATION_STEP_3" )
	calibrationStepArray.append( "#WILDS_CALIBRATION_STEP_4" )
	calibrationStepArray.append( "#WILDS_CALIBRATION_STEP_5" )
	calibrationStepArray.append( "#WILDS_CALIBRATION_STEP_6" )
	calibrationStepArray.append( "#WILDS_CALIBRATION_STEP_7" )
	calibrationStepArray.append( "#WILDS_CALIBRATION_STEP_8" )
	calibrationStepArray.append( "#WILDS_CALIBRATION_STEP_9" )
	calibrationStepArray.append( "#WILDS_CALIBRATION_STEP_10" )
	calibrationStepArray.append( "#WILDS_CALIBRATION_STEP_11" )
	calibrationStepArray.append( "#WILDS_CALIBRATION_STEP_12" )
	calibrationStepArray.append( "#WILDS_CALIBRATION_STEP_13" )
	calibrationStepArray.append( "#WILDS_CALIBRATION_STEP_14" )

	var titleRui = file.jumpKitRuiArray[0]
	var line1Rui = file.jumpKitRuiArray[1]
	var line2Rui = file.jumpKitRuiArray[2]

	int stepIndex = file.newStepIndex
	hexSetStruct hexSet

	printt( "stepIndex", stepIndex )

	RuiSetString( titleRui, "msgText", Localize( "#WILDS_CALIBRATION_TITLE_JUMPKIT_STATUS" ) )
	RuiSetFloat3( titleRui, "msgColor", textColor )
	EmitSoundOnEntity( player, "Wilds_Scr_HelmetHUDText_BlipsFast_7" )
	waitthread FlickerRui( titleRui, titleAlpha, 0.0, 2.5, 5 )

	table result
	while( stepIndex < calibrationStepArray.len()  )
	{
		if ( !("signal" in result) || result.signal == "player_doublejump" )
		{
			RuiSetString( titleRui, "msgText", Localize( "#WILDS_CALIBRATION_TITLE_JUMPKIT_OFFLINE" ) )
			EmitSoundOnEntity( player, "Wilds_Scr_HelmetHUDText_BlipsFaster" )
			waitthread FlickerRui( titleRui, titleAlpha, 0.0, 1, 10 )
			wait 2
			RuiSetString( titleRui, "msgText", Localize( "#WILDS_CALIBRATION_TITLE_JUMPKIT_OFFLINE_ALT" ) )
			EmitSoundOnEntity( player, "Wilds_Scr_HelmetHUDText_Blips_2" )
			waitthread FlickerRui( titleRui, titleAlpha, 0.0, 1, 3 )
		}
		else
		{
			RuiSetString( titleRui, "msgText", Localize( "#WILDS_CALIBRATION_TITLE_JUMPKIT_OFFLINE_ALT" ) )
			EmitSoundOnEntity( player, "Wilds_Scr_HelmetHUDText_BlipsFaster_Alt" )
			waitthread FlickerRui( titleRui, titleAlpha, 0.0, 1.5, 10 )
		}

		string calibrationStr = calibrationStepArray[ stepIndex ]
		RuiSetFloat( line1Rui, "msgAlpha", 0.0 )
		waitthread HexDump( hexSet, 1.0 )

		RuiSetString( line1Rui, "msgText", Localize( calibrationStr, "" ) )
		RuiSetFloat3( line1Rui, "msgColor", textColor )
		RuiSetFloat( line1Rui, "msgAlpha", textAlpha )
		thread AnimateDots( line1Rui, calibrationStr )

		if ( stepIndex < calibrationStepArray.len() - 1 )
			thread HideAfterTime( file.jumpKitRuiArray, 3.0 )

		if ( file.newStepIndex < calibrationStepArray.len() )	// always wait unless we got to the end
			result = WaitSignal( player, "next_calibration_step", "player_doublejump" )

		stepIndex = file.newStepIndex
		clGlobal.levelEnt.Signal( "end_hide_after_time" )
		clGlobal.levelEnt.Signal( "end_fade_over_time" )
		StopAnimateDots()
	}
	// these shouldn't be needed but still
	clGlobal.levelEnt.Signal( "end_hide_after_time" )
	clGlobal.levelEnt.Signal( "end_fade_over_time" )

	RuiSetFloat( line1Rui, "msgAlpha", 0.0 )
	RuiSetString( titleRui, "msgText", Localize( "#WILDS_CALIBRATION_TITLE_JUMPKIT_ONLINE" ) )
	RuiSetFloat3( titleRui, "msgColor", <0.0, 0.4, 1> )
	thread FlickerRui( titleRui, 0.0, titleAlpha, 1000 )

	wait 0.5
	EmitSoundOnEntity( player, "Wilds_Scr_HelmetHUD_PowerSourceValid" )
	wait 0.5
	EmitSoundOnEntity( player, "Wilds_Scr_HelmetHUD_PowerSourceValid" )
	wait 0.5
	EmitSoundOnEntity( player, "Wilds_Scr_HelmetHUD_PowerSourceValid" )
	wait 0.5
	EmitSoundOnEntity( player, "Wilds_Scr_HelmetHUD_PowerSourceValid" )

	FlagWait( "double_jump_confirmed" )
	clGlobal.levelEnt.Signal( "end_flicker" )
	waitthread FlickerRui( titleRui, 0.0, titleAlpha, 1, 20 )

	wait 5

	clGlobal.levelEnt.Signal( "end_flicker" ) // make sure no flickering is going on
	foreach( rui in file.jumpKitRuiArray )
		RuiDestroyIfAlive( rui )
}

void function HideAfterTime( array<var> ruiArray, float delay = 5.0 )
{
	clGlobal.levelEnt.EndSignal( "end_hide_after_time" )
	wait 5.0

	foreach( rui in ruiArray )
	{
		thread FadeRuiOverTime( rui, textAlpha, 0.0, 0.75 )
		// RuiSetFloat( rui, "msgAlpha", 0.0 )
	}
}

void function FadeRuiArrayOverTime( array<var> ruiArray, float startAlpha, float endAlpha, float duration )
{
	clGlobal.levelEnt.EndSignal( "end_fade_over_time" )

	foreach ( rui in ruiArray )
	{
		thread FadeRuiOverTime( rui, startAlpha, endAlpha, duration )
	}
	wait duration
}

void function FadeRuiOverTime( var rui, float startAlpha, float endAlpha, float duration )
{
	clGlobal.levelEnt.EndSignal( "end_fade_over_time" )

	OnThreadEnd(
		function() : ( rui, endAlpha )
		{
			RuiSetFloat( rui, "msgAlpha", endAlpha )
		}
	)

	float startTime = Time()
	while( Time() < startTime + duration )
	{
		float elapsedTime = Time() - startTime
		float alpha = GraphCapped( elapsedTime, 0, duration, startAlpha, endAlpha )
		RuiSetFloat( rui, "msgAlpha", alpha )
		wait IntervalPerTick()
	}
}

void function FlickerRuiArray( array<var> ruiArray, float baseAlpha = 1.0, float altAlpha = 0.0, float duration = 2, int speed = 5 )
{
	clGlobal.levelEnt.EndSignal( "end_flicker" )

	foreach ( rui in ruiArray )
	{
		thread FlickerRui( rui, baseAlpha, altAlpha, duration, speed )
	}
	wait duration
}

void function FlickerRui( var rui, float baseAlpha = 1.0, float altAlpha = 0.0, float duration = 2, int speed = 5 )
{
	clGlobal.levelEnt.EndSignal( "end_flicker" )

	OnThreadEnd(
		function() : ( rui, baseAlpha )
		{
			RuiSetFloat( rui, "msgAlpha", baseAlpha )
		}
	)

	float endTime = Time() + duration
	bool flicker = true

	while( Time() < endTime )
	{
		if ( !flicker )
			RuiSetFloat( rui, "msgAlpha", altAlpha )
		else
			RuiSetFloat( rui, "msgAlpha", baseAlpha )

		flicker = !flicker
		wait 1.0 / speed
	}
}

void function AnimateDots( var rui, string msgText, string varName = "msgText", float duration = 999999, string capString = "" )
{
	clGlobal.levelEnt.EndSignal( "stop_animate_dots" )

	OnThreadEnd(
		function() : ( rui, varName, msgText, capString )
		{
			RuiSetString( rui, varName, Localize( msgText, Localize( capString ) ) )
		}
	)

	float endTime = Time() + duration

	array<string> dotArr = ["",".","..","..."]
	int index = 0
	while( Time() < endTime )
	{
		RuiSetString( rui, varName, Localize( msgText, dotArr[index] ) )
		wait 0.25
		index = (index + 1) % dotArr.len()
	}
}

void function StopAnimateDots()
{
	clGlobal.levelEnt.Signal( "stop_animate_dots" )
}


void function HexDump( hexSetStruct hexSet, float duration = 1.0 )
{
	entity player = GetLocalClientPlayer()
	Assert( IsValid( player ) )
	player.EndSignal( "OnDestroy" )

	EmitSoundOnEntity( player, "Wilds_Scr_HelmetHUDText_Print" )

	float endTime = Time() + duration
	while( Time() < endTime )
	{
		CreateCockpitHex( hexSet )
		wait 0.05
	}

	StopSoundOnEntity( player, "Wilds_Scr_HelmetHUDText_Print" )
	EmitSoundOnEntity( player, "Wilds_Scr_HelmetHUDText_Finish" )
}

void function CreateCockpitHex( hexSetStruct hexSet )
{
	var rui
	switch( hexSet.alignment )
	{
		case 1: //right
			rui = CreateCockpitRui( $"ui/cockpit_console_text_top_right.rpak", 0 )
			break
		case 2: //center
			rui = CreateCockpitRui( $"ui/cockpit_console_text_center.rpak", 0 )
			break
		default: //left
			rui = CreateCockpitRui( $"ui/cockpit_console_text_top_left.rpak", 0 )
			break

	}

	string hex = GenerateHexString( 4 )
	for ( int i=0; i < hexSet.colums - 1; i++ )
	{
		hex += " " + GenerateHexString( 4 )
	}

	RuiSetInt( rui, "maxLines", hexSet.maxLines )
	RuiSetString( rui, "msgText", hex )
	RuiSetFloat( rui, "msgFontSize", hexSet.msgFontSize )
	RuiSetInt( rui, "lineNum", hexSet.lineNum )
	RuiSetFloat( rui, "lineHoldtime", hexSet.lineHoldtime )
	RuiSetFloat( rui, "msgAlpha", hexSet.msgAlpha )
	RuiSetFloat3( rui, "msgColor", hexSet.msgColor )
	RuiSetFloat2( rui, "msgPos", hexSet.msgPos )
	RuiSetBool( rui, "autoMove", true )
}

string function GenerateHexString( int digits )
{
	int baseValue = RandomIntRange( 0, pow(10,digits-1) )
	string baseString = string( baseValue )
	for ( int i=digits-1; i>0; i-- )
	{
		if ( baseValue < pow(10,i) )
		{
			baseString = "0" + baseString
		}
	}
	return "0x" + baseString
}

//  ########   #######  ##     ## ########  ##       ########          ## ##     ## ##     ## ########
//  ##     ## ##     ## ##     ## ##     ## ##       ##                ## ##     ## ###   ### ##     ##
//  ##     ## ##     ## ##     ## ##     ## ##       ##                ## ##     ## #### #### ##     ##
//  ##     ## ##     ## ##     ## ########  ##       ######            ## ##     ## ## ### ## ########
//  ##     ## ##     ## ##     ## ##     ## ##       ##          ##    ## ##     ## ##     ## ##
//  ##     ## ##     ## ##     ## ##     ## ##       ##          ##    ## ##     ## ##     ## ##
//  ########   #######   #######  ########  ######## ########     ######   #######  ##     ## ##

void function DoubleJumpDisabledWarning( entity player )
{
	thread DoubleJumpDisabledWarning_thread( player )
}

void function DoubleJumpDisabledWarning_thread( entity player )
{
	player.EndSignal( "OnDeath" )

	// delay needed so the server can set lastJumpTime
	wait 0.15

	if ( !PlayerIsInMidAir( player ) )
		return

	if ( !GetGlobalNetBool( "doubleJumpDisabled" ) )
		return

	if ( player.GetPlayerNetInt( "jumpKitCalibrationStep" ) < 0 )
		return

	if ( Time() <= file.nextAllowHintTime )
		return

	// display message

	EmitSoundOnEntity( player, "Menu.Deny" )
	player.Signal( "player_doublejump" )
	file.nextAllowHintTime = Time() + 10.0
}

bool function EnemiesClose( entity player )
{
	array<entity> npcArray = GetNPCArrayEx( "any", -1, TEAM_MILITIA, player.GetOrigin(), 1024 )
	return npcArray.len() > 0
}

bool function PlayerIsInMidAir( entity player )
{
	if ( player.IsOnGround() )
		return false

	if ( player.IsWallRunning() )
		return false

	float time = GetGlobalNetTime( "lastJumpTime" )

	return ((Time() - time) > 0.2)
}


//	##     ## ####  ######   ######
//	###   ###  ##  ##    ## ##    ##
//	#### ####  ##  ##       ##
//	## ### ##  ##   ######  ##
//	##     ##  ##        ## ##
//	##     ##  ##  ##    ## ##    ##
//	##     ## ####  ######   ######

entity function ServerCallback_RumblePlay( int rumbleIndex )
{
	switch( rumbleIndex )
	{
		case 0:
			Rumble_Play( "wilds_debris_crash", {} )
			break
		default:
	}
}

float function QuadEaseIn( float frac )
{
	return 1 * frac * frac
}

float function QuadEaseInOut( float frac )
{
	frac /= 0.5;
	if (frac < 1)
		return 0.5 * frac * frac
	frac--
	return -0.5 * ( frac * ( frac - 2 ) - 1 )
}

WorldPos function GetRefLocationInSkyBox( entity animRef, entity skyCam )
{
	WorldPos loc
	vector origin = animRef.GetOrigin()
	vector angles = animRef.GetAngles()

	loc.origin = skyCam.GetOrigin() + ( origin * 0.001 )
	loc.angles = angles + skyCam.GetAngles()

	printt( loc.origin )
	return loc
}

void function ServerCallback_HideHudIcons()
{
	entity player = GetLocalClientPlayer()

	ClWeaponStatus_SetOffhandVisible( OFFHAND_LEFT, false )
	ClWeaponStatus_SetOffhandVisible( OFFHAND_RIGHT, false )
	ClWeaponStatus_SetOffhandVisible( OFFHAND_INVENTORY, false )
	if ( player.IsTitan() )
		ClWeaponStatus_SetOffhandVisible( OFFHAND_TITAN_CENTER, false )
	ClWeaponStatus_SetWeaponVisible( false )
}

void function ServerCallback_ShowHudIcon( int index )
{
	// 0 = OFFHAND_LEFT
	// 1 = OFFHAND_RIGHT
	// 2 = OFFHAND_TITAN_CENTER
	// 3 = MAIN WEAPON
	// 4 = OFFHAND_INVENTORY
	thread RevealHudIconsThread( 0.0, index )
}

void function RevealHudIconsThread( float startDelay, int index )
{
	wait startDelay

	entity player = GetLocalClientPlayer()
	player.EndSignal( "OnDestroy" )

	const float flickerTime = 1.5
	const float flickerGapmultiplier = 1.1
	float flickerGap = 0.016
	float startTime = Time()
	bool visible = false

	while( Time() < startTime + flickerTime )
	{
		visible = !visible
		switch ( index )
		{
			case OFFHAND_RIGHT:
				ClWeaponStatus_SetOffhandVisible( OFFHAND_RIGHT, visible )
				break
			case OFFHAND_LEFT:
				ClWeaponStatus_SetOffhandVisible( OFFHAND_LEFT, visible )
				break
			case OFFHAND_INVENTORY:
				ClWeaponStatus_SetOffhandVisible( OFFHAND_INVENTORY, visible )
				break
			case 3:
				ClWeaponStatus_SetWeaponVisible( visible )
				break
			case OFFHAND_TITAN_CENTER:
				if ( player.IsTitan() )
					ClWeaponStatus_SetOffhandVisible( OFFHAND_TITAN_CENTER, visible )
				break
		}
		wait flickerGap
		flickerGap *= flickerGapmultiplier
	}

	wait flickerGap
	switch ( index )
	{
		case OFFHAND_RIGHT:
			ClWeaponStatus_SetOffhandVisible( OFFHAND_RIGHT, true )
			break
		case OFFHAND_LEFT:
			ClWeaponStatus_SetOffhandVisible( OFFHAND_LEFT, true )
			break
		case OFFHAND_INVENTORY:
			ClWeaponStatus_SetOffhandVisible( OFFHAND_INVENTORY, true )
			break
		case 3:
			ClWeaponStatus_SetWeaponVisible( true )
			break
		case OFFHAND_TITAN_CENTER:
			if ( player.IsTitan() )
				ClWeaponStatus_SetOffhandVisible( OFFHAND_TITAN_CENTER, true )
			break
	}
}