global function ClientCodeCallback_MapInit
global function ScriptCallback_SetupLookTargets
global function ScriptCallback_LookTargets_WaitForLookat
global function ScriptCallback_LookTargets_KillLights
global function ScriptCallback_ShowInvertCrosshair
global function ScriptCallback_SetWeaponHUDEnabled
global function ScriptCallback_TrainingGauntlet_ResultsDisplay_SetTip
global function ScriptCallback_SimPodShutdownScreen
global function ScriptCallback_LevelIntroText
global function ScriptCallback_PodTransition_PlayerScreenFX
global function ScriptCallback_PodGlitch_PlayerScreenFX
global function ScriptCallback_SimpleScreenShake
global function ScriptCallback_TitanfallGlitch_ExtraFlicker
global function ScriptCallback_ShowInstallProgress
global function ScriptCallback_DoF_SetNearDepth
global function ScriptCallback_DoF_SetFarDepth
global function ScriptCallback_DoF_SetNearDepthToDefault
global function ScriptCallback_DoF_SetFarDepthToDefault

#if DEV
global function testglitch
global function fakeinstallprogress
#endif

const asset POD_LIGHT_RED 					= $"panel_light_red"
const asset POD_LIGHT_BLUE 					= $"panel_light_blue"
const asset POD_TRANSITION_SCREENFX 		= $"P_training_teleport_FP"
const asset POD_GLITCH_SCREENFX 			= $"P_tpod_screen_distort"

struct TrainingPod_LookTarget
{
	entity ent
	string attachName
	int fxHandle = -1
	string clientCommand
}

struct
{
	entity trainingPod
	array<TrainingPod_LookTarget> trainingPodLookTargets

	int particleSystemIndex_POD_LIGHT_RED
	int particleSystemIndex_POD_LIGHT_BLUE

	var invertCrosshair
	var simpodShutdownScreenRUI

	var installProgressTopo
	var installProgressRUI

	table<int,string> trainingGauntletTips = {}
} file

void function ClientCodeCallback_MapInit()
{
	Training_SharedInit()

	RegisterConCommandTriggeredCallback( "+use", ScriptCallback_Training_PlayerPressedUse )
	RegisterConCommandTriggeredCallback( "+useandreload", ScriptCallback_Training_PlayerPressedUse )
	RegisterConCommandTriggeredCallback( "+useandreload", ScriptCallback_Training_PlayerPressedReload )
	RegisterConCommandTriggeredCallback( "+reload", ScriptCallback_Training_PlayerPressedReload )

	RegisterConCommandTriggeredCallback( "+scriptCommand2", Training_RequestedTitanfall )

	RegisterSignal( "StartWaitingForLookatTargets" )
	RegisterSignal( "DetectPlayerReload_Starting" )
	RegisterSignal( "SimPodShutdownScreen_Destroy" )

	#if DEV
	RegisterSignal( "fakeinstallstart" )
	RegisterSignal( "testglitch" )
	#endif

	file.particleSystemIndex_POD_LIGHT_RED = PrecacheParticleSystem( POD_LIGHT_RED )
	file.particleSystemIndex_POD_LIGHT_BLUE = PrecacheParticleSystem( POD_LIGHT_BLUE )
	PrecacheParticleSystem( POD_TRANSITION_SCREENFX )
	PrecacheParticleSystem( POD_GLITCH_SCREENFX )

	AddCallback_EntitiesDidLoad( EntitiesDidLoad )

	file.trainingGauntletTips[ file.trainingGauntletTips.len() ] <- "#TRAINING_GAUNTLET_TIP_0"
}

void function EntitiesDidLoad()
{
	file.trainingPod = GetEntByScriptName( "training_pod" )

	thread Training_ReportInputTypeChangesToServer()
}


void function ScriptCallback_SetupLookTargets()
{
	thread TrainingPod_SetupLookTargets()
}

void function TrainingPod_SetupLookTargets()
{
	if ( !file.trainingPodLookTargets.len() )
	{
		array<table<string, string > > targInfos
		targInfos.append( { attachName = "fx_lookat_top", clientCommand = "topTarget" } )  // dots are different when the lights are this close to the player
		targInfos.append( { attachName = "fx_lookat_bot", clientCommand = "bottomTarget" } )

		foreach ( table<string,string> targInfo in targInfos )
		{
			string attachName = targInfo.attachName

			int attachID = file.trainingPod.LookupAttachment( attachName )
			vector attachOrg = file.trainingPod.GetAttachmentOrigin( attachID )
			vector attachAng = file.trainingPod.GetAttachmentAngles( attachID )

			entity lookTargetEnt = CreateClientsideScriptMover( EMPTY_MODEL, attachOrg, attachAng )
			lookTargetEnt.SetOrigin( attachOrg )
			lookTargetEnt.SetAngles( attachAng )
			lookTargetEnt.SetParent( file.trainingPod, attachName )

			TrainingPod_LookTarget lookTarget
			lookTarget.ent 				= lookTargetEnt
			lookTarget.attachName 		= attachName
			lookTarget.clientCommand 	= targInfo.clientCommand

			file.trainingPodLookTargets.append( lookTarget )
		}
	}
	else
	{
		foreach ( lookTarget in file.trainingPodLookTargets )
		{
			LookTarget_KillClientFX( lookTarget )
		}
	}

	foreach ( lookTarget in file.trainingPodLookTargets )
		LookTarget_ChangeFX( lookTarget, file.particleSystemIndex_POD_LIGHT_RED )
}

void function ScriptCallback_LookTargets_KillLights()
{
	if ( !file.trainingPodLookTargets.len() )
		return

	foreach ( lookTarget in file.trainingPodLookTargets )
	{
		if ( lookTarget.fxHandle == -1 )
			continue

		LookTarget_KillClientFX( lookTarget )
	}
}

void function ScriptCallback_LookTargets_WaitForLookat()
{
	entity player = GetLocalViewPlayer()

	player.Signal( "StartWaitingForLookatTargets" )

	foreach ( lookTarget in file.trainingPodLookTargets )
		thread TrainingPod_LookTarget_WaitForLookat_Think( lookTarget )
}

void function TrainingPod_LookTarget_WaitForLookat_Think( TrainingPod_LookTarget lookTarget )
{
	entity player = GetLocalViewPlayer()

	player.EndSignal( "OnDestroy" )
	player.EndSignal( "StartWaitingForLookatTargets" )

	float reqDist = 130
	float reqLookTime = 0.5
	float blinkFreq = 0.1
	float tickRate = 0.05

	float dist
	while ( 1 )
	{
		dist = GetDistFromLookTarget( player, lookTarget )

		while ( dist > reqDist )
		{
			wait tickRate
			dist = GetDistFromLookTarget( player, lookTarget )
		}

		float okEndTime = Time() + reqLookTime
		float nextBlinkTime = Time() + blinkFreq
		bool blinkOn = false
		while ( dist <= reqDist && Time() < okEndTime )
		{
			wait tickRate

			if ( Time() >= nextBlinkTime )
			{
				if ( blinkOn )
				{
					LookTarget_ChangeFX( lookTarget, file.particleSystemIndex_POD_LIGHT_RED )
					EmitSoundOnEntity( player, "NPE_Scr_PodLightOn" )
					blinkOn = false
				}
				else
				{
					LookTarget_ChangeFX( lookTarget, file.particleSystemIndex_POD_LIGHT_BLUE )
					EmitSoundOnEntity( player, "NPE_Scr_PodLightOn" )
					blinkOn = true
				}

				nextBlinkTime = Time() + blinkFreq
			}

			dist = GetDistFromLookTarget( player, lookTarget )
		}

		// we waited long enough, break out
		if ( Time() >= okEndTime )
			break

		// otherwise set color back to incomplete
		LookTarget_ChangeFX( lookTarget, file.particleSystemIndex_POD_LIGHT_RED )
	}

	EmitSoundOnEntity( player, "NPE_Player_VerticalLookSucceed" )

	LookTarget_ChangeFX( lookTarget, file.particleSystemIndex_POD_LIGHT_BLUE )

	printt( "Look target acquired, sending client command:", lookTarget.clientCommand )
	player.ClientCommand( lookTarget.clientCommand )
}

float function GetDistFromLookTarget( entity player, TrainingPod_LookTarget lookTarget )
{
	float[2] screenSize = GetScreenSize()
	array<float> screenCenter
	screenCenter.append( screenSize[0] * 0.5 ) // x
	screenCenter.append( screenSize[1] * 0.5 ) // y

	int padding = 0
	EntityScreenSpaceBounds lightScreenPos = player.GetEntScreenSpaceBounds( lookTarget.ent, padding )

	float xOffset = fabs( screenCenter[0] - lightScreenPos.x0 )
	float yOffset = fabs( screenCenter[1] - lightScreenPos.y0 )
	float dist = sqrt( ( xOffset * xOffset ) + ( yOffset * yOffset ) )
	return dist
}

void function LookTarget_KillClientFX( TrainingPod_LookTarget lookTarget )
{
	int fxHandle = lookTarget.fxHandle
	if ( fxHandle == -1 )
		return

	if ( EffectDoesExist( fxHandle ) )
	{
		EffectStop( fxHandle, true, false )
	}

	lookTarget.fxHandle = -1
}

void function LookTarget_ChangeFX( TrainingPod_LookTarget lookTarget, int particleSystemIndex )
{
	if ( lookTarget.fxHandle != -1 )
	{
		LookTarget_KillClientFX( lookTarget )
	}

	lookTarget.fxHandle = StartParticleEffectOnEntity( lookTarget.ent, particleSystemIndex, FX_PATTACH_ROOTBONE_FOLLOW, -1 )
}

void function ScriptCallback_ShowInvertCrosshair( bool doShow )
{
	DestroyInvertCrosshair()

	if ( doShow )
	{
		file.invertCrosshair = RuiCreate( $"ui/crosshair_circle2.rpak", clGlobal.topoFullScreen, RUI_DRAW_HUD, 0 )
		RuiSetFloat3( file.invertCrosshair, "teamColor", <0.9, 0.9, 0.9> )
		RuiSetFloat( file.invertCrosshair, "adjustedSpread", 4.0 )
	}
}

void function DestroyInvertCrosshair()
{
	if ( file.invertCrosshair == null )
		return

	RuiDestroyIfAlive( file.invertCrosshair )
	file.invertCrosshair = null
}

void function Training_ReportInputTypeChangesToServer()
{
	entity player = GetLocalClientPlayer()
	EndSignal( player, "OnDestroy" )

	int lastInputType = -1

	while ( 1 )
	{
		wait 0.1  // server can't receive faster than this

		int inputType = INPUT_TYPE_KBM
		if ( IsControllerModeActive() )
			inputType = INPUT_TYPE_CONTROLLER

		if ( inputType == lastInputType )
			continue

		//printt( "client input type changed:", inputType )
		player.ClientCommand( "Training_SetInputType " + inputType )

		lastInputType = inputType
	}
}

void function ScriptCallback_Training_PlayerPressedUse( entity player )
{
	player.ClientCommand( "Training_PlayerPressedUse" )
}

void function ScriptCallback_Training_PlayerPressedReload( entity player )
{
	thread DetectPlayerReload_Think( player )
}

void function DetectPlayerReload_Think( entity player )
{
	player.EndSignal( "OnDestroy" )
	player.Signal( "DetectPlayerReload_Starting" )
	player.EndSignal( "DetectPlayerReload_Starting" )

	entity weapon = player.GetActiveWeapon()

	if ( !weapon )
		return

	if ( player.GetWeaponAmmoLoaded( weapon ) == player.GetWeaponAmmoMaxLoaded( weapon ) )
		return

	// HACK make sure code actually reloaded the weapon after the button press
	float endGracetime = Time() + 0.25
	while ( Time() < endGracetime && weapon == player.GetActiveWeapon() )
	{
		if ( weapon.IsReloading() )
			break

		wait 0.05
	}

	// he switched weapons instead
	if ( weapon != player.GetActiveWeapon() )
		return

	player.ClientCommand( "Training_PlayerReloaded" )
}

void function ScriptCallback_SetWeaponHUDEnabled( bool setEnabled )
{
	ClWeaponStatus_SetWeaponVisible( setEnabled )
}

void function ScriptCallback_TrainingGauntlet_ResultsDisplay_SetTip( int gauntletID, int trainingTipIdx )
{
	string tip = file.trainingGauntletTips[ trainingTipIdx ]

	// hacky, but flexible in case we want to add more training gauntlet specific tips
	if ( trainingTipIdx == 0 )
	{
		StopwatchDisplayStrings strings = GetStopwatchDisplayStrings( TRAINING_GAUNTLET_MAX_TIME_TO_PROGRESS )
		tip = Localize( tip, strings.mins, strings.secs, strings.ms )
	}

	GauntletInfo gauntlet = GetGauntletByID( gauntletID )

	Gauntlet_SetResultsDisplayTip( gauntlet, tip )
}

void function ScriptCallback_SimPodShutdownScreen( float totalDisplayTime )
{
	thread SimPodShutdownScreen_Think( totalDisplayTime )
}

void function SimPodShutdownScreen_Think( float totalDisplayTime )
{
	SimPodShutdownScreen_Destroy()

	entity player = GetLocalViewPlayer()
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "SimPodShutdownScreen_Destroy" )

	int sorting = RUI_SORT_SCREENFADE + 1  // draw over screen fades
	file.simpodShutdownScreenRUI = RuiCreate( $"ui/training_simpod_shutdown_screen.rpak", clGlobal.topoFullScreen, RUI_DRAW_HUD, sorting )

	float startTime = Time()
	float endTime = startTime + totalDisplayTime

	wait endTime - Time()

	SimPodShutdownScreen_Destroy()
}

void function SimPodShutdownScreen_Destroy()
{
	entity player = GetLocalViewPlayer()

	if ( file.simpodShutdownScreenRUI != null )
		RuiDestroyIfAlive( file.simpodShutdownScreenRUI )

	file.simpodShutdownScreenRUI = null
	player.Signal( "SimPodShutdownScreen_Destroy" )
}

void function ScriptCallback_LevelIntroText()
{
	thread LevelIntroText_Think()
}

void function LevelIntroText_Think()
{
	entity player = GetLocalViewPlayer()
	player.EndSignal( "OnDestroy" )

	wait 1.5

	var infoText = RuiCreate( $"ui/sp_level_title.rpak", clGlobal.topoFullScreen, RUI_DRAW_HUD, RUI_SORT_SCREENFADE + 100 )
	RuiSetGameTime( infoText, "startTime", Time() )
	RuiSetString( infoText, "txtLine1", "#TRAINING_INTRO_TEXT_LINE1" )
	RuiSetString( infoText, "txtLine2", "#TRAINING_INTRO_TEXT_LINE2" )
	RuiSetString( infoText, "txtLine3", "#TRAINING_INTRO_TEXT_LINE3" )

	wait 12.7

	var infoText2 = RuiCreate( $"ui/sp_level_title.rpak", clGlobal.topoFullScreen, RUI_DRAW_HUD, RUI_SORT_SCREENFADE + 100 )
	RuiSetGameTime( infoText2, "startTime", Time() )
	RuiSetString( infoText2, "txtLine1", " " )
	RuiSetString( infoText2, "txtLine2", "#TRAINING_INTRO_TEXT_LINE4" )
	RuiSetString( infoText2, "txtLine3", "#TRAINING_INTRO_TEXT_LINE5" )
}


void function Training_RequestedTitanfall( entity player )
{
	if ( !IsAlive( player ) )
		return

	if ( !GetGlobalNetBool( "trainingTitanfallEnabled" ) )
		return

	player.ClientCommand( "ClientCommand_TrainingRequestedTitanfall" )

	if ( clGlobal.isAnnouncementActive && clGlobal.activeAnnouncement.messageText == "#HUD_TITAN_READY" )
	{
		clGlobal.levelEnt.Signal( "AnnoucementPurge" )
	}

	//PlayMusic( "Music_FR_Militia_TitanFall1" )
	EmitSoundOnEntity( player, "titan_callin" )
	return
}


const float GLITCH_FLICKER_WAIT_MIN = 0.02
const float GLITCH_FLICKER_WAIT_MAX = 0.08

void function ScriptCallback_TitanfallGlitch_ExtraFlicker( int titanHandle,bool isTwin = false )
{
	entity titan = GetEntityFromEncodedEHandle( titanHandle )
	thread TitanfallGlitchFX_Think( titan, isTwin )
}

void function TitanfallGlitchFX_Think( entity titan, bool isTwin = false )
{
	vector origin = titan.GetOrigin()
	vector angles = titan.GetAngles()

	entity titanProxy = CreateClientsideScriptMover( BUDDY_MODEL, origin, angles )
	titanProxy.EndSignal( "OnDestroy" )
	titan.EndSignal( "OnDestroy" )

	OnThreadEnd(
	function() : ( titanProxy )
		{
			if ( IsValid( titanProxy ) )
				titanProxy.Destroy()
		}
	)

	int playerIdx = 0
	int lastAnimIdx = 0
	int animIdx = 0
	float nextToggleTime = Time()

	// Play default animation
	string defaultIdleAnim = GetDefaultTitanfallGlitchAnim()
	titanProxy.Anim_Stop()
	thread PlayAnimTeleport( titanProxy, defaultIdleAnim, origin, angles )

	array<string> anims = GetTitanfallGlitchAnims()
	if ( isTwin )
		anims = GetTitanfallGlitchTwinAnims()

	// visual glitches
	bool isShowing = true
	float minWait = GLITCH_FLICKER_WAIT_MIN
	float maxWait = GLITCH_FLICKER_WAIT_MAX
	while ( IsValid( titanProxy ) )
	{
		WaitFrame()

		if ( !GetGlobalNetBool( "titanGlitch_extraFlicker" ) )
		{
			if ( isShowing )
			{
				titanProxy.SetInvisibleForLocalPlayer( playerIdx )
				isShowing = false
			}

			wait 0.05
			continue
		}

		animIdx = GetGlobalNetInt( "titanfallGlitchAnimIdx" )
		if ( animIdx != lastAnimIdx )
		{
			printt( "client changing glitch anim:", anims[animIdx] )
			titanProxy.Anim_Stop()
			thread PlayAnimTeleport( titanProxy, anims[animIdx], origin, angles )

			lastAnimIdx = animIdx
		}

		if ( Time() >= nextToggleTime )
		{
			if ( isShowing )
			{
				titanProxy.SetInvisibleForLocalPlayer( playerIdx )
				isShowing = false
			}
			else
			{
				titanProxy.SetVisibleForLocalPlayer( playerIdx )
				isShowing = true
			}

			nextToggleTime = Time() + RandomFloatRange( minWait, maxWait )
		}
	}
}

#if DEV
void function testglitch()
{
	entity player = GetLocalViewPlayer()
	player.Signal( "testglitch" )
	player.EndSignal( "testglitch" )

	vector origin = <1745, -3071, -299>
	vector angles = <0, 0, 0>

	entity titanProxy = CreateClientsideScriptMover( BUDDY_MODEL, origin, angles )
	titanProxy.EndSignal( "OnDestroy" )

	OnThreadEnd(
	function() : ( titanProxy )
		{
			if ( IsValid( titanProxy ) )
				titanProxy.Destroy()
		}
	)

	// titan freezes & glitches
	titanProxy.Anim_Stop()
	thread PlayAnimTeleport( titanProxy, "bt_hotdrop_glitch_freeze_idle", origin, angles )

	int playerIdx = 0

	// visual glitches
	bool isShowing = true
	float minWait = GLITCH_FLICKER_WAIT_MIN
	float maxWait = GLITCH_FLICKER_WAIT_MAX
	while ( IsValid( titanProxy ) )
	{
		if ( isShowing )
		{
			isShowing = false
			titanProxy.SetInvisibleForLocalPlayer( playerIdx )
		}
		else
		{
			isShowing = true
			titanProxy.SetVisibleForLocalPlayer( playerIdx )
		}

		wait RandomFloatRange( minWait, maxWait )
	}
}
#endif


void function ScriptCallback_PodTransition_PlayerScreenFX()
{
	thread PodTransition_PlayerScreenFX()
}

void function PodTransition_PlayerScreenFX()
{
	entity player = GetLocalViewPlayer()
	EndSignal( player, "OnDestroy" )

	entity cockpit = player.GetCockpit()
	if ( !IsValid( cockpit ) )
		return

	int particleIdx = GetParticleSystemIndex( POD_TRANSITION_SCREENFX )
	int screenFXHandle = StartParticleEffectOnEntity( player, particleIdx, FX_PATTACH_POINT_FOLLOW, player.GetCockpit().LookupAttachment( "CAMERA" ) )
	EffectSetIsWithCockpit( screenFXHandle, true )
}

void function ScriptCallback_PodGlitch_PlayerScreenFX( float duration )
{
	thread PodGlitch_PlayerScreenFX( duration )
}

void function PodGlitch_PlayerScreenFX( float duration )
{
	entity player = GetLocalViewPlayer()
	EndSignal( player, "OnDestroy" )

	entity cockpit = player.GetCockpit()
	if ( !IsValid( cockpit ) )
		return

	int particleIdx = GetParticleSystemIndex( POD_GLITCH_SCREENFX )
	int screenFXHandle = StartParticleEffectOnEntity( player, particleIdx, FX_PATTACH_POINT_FOLLOW, player.GetCockpit().LookupAttachment( "CAMERA" ) )
	EffectSetIsWithCockpit( screenFXHandle, true )

	OnThreadEnd(
	function() : ( screenFXHandle )
		{
			if ( screenFXHandle != -1 )
				EffectStop( screenFXHandle, true, false ) // stop particles, play end cap
		}
	)

	wait duration
}

void function ScriptCallback_SimpleScreenShake( float duration, float amplitude, float blurMaxIntensity )
{
	thread SimpleScreenShake( duration, amplitude, blurMaxIntensity )
}

void function SimpleScreenShake( float duration, float amplitude, float blurMaxIntensity = 0.75 )
{
	entity player = GetLocalViewPlayer()
	EndSignal( player, "OnDestroy" )

	float frequency = 200
	ClientScreenShake( amplitude, frequency, duration, <0,0,0> )

	float blurFadeInTime = duration * 0.2
	float blurFadeOutTime = duration * 0.9

	SetScreenBlur( blurMaxIntensity, blurFadeInTime, EASING_SINE_IN )
	wait blurFadeInTime
	SetScreenBlur( 0, blurFadeOutTime, EASING_SINE_OUT )
}


void function ScriptCallback_ShowInstallProgress( bool doShow )
{
	if ( doShow )
		thread ShowInstallProgress()
	else
		StopShowingInstallProgress()
}

void function ShowInstallProgress()
{
	if ( file.installProgressRUI != null )
		StopShowingInstallProgress()

	if ( file.installProgressTopo == null )
	{
		float width 	= 72
		float height 	= 38

		vector org = < -5327, 690, 125 >
		vector ang = < 0, 119, 0 >

		// adjust so the RUI is drawn with the org as its center point
		org += ( (AnglesToRight( ang )*-1) * (width*0.5) )
		org += ( AnglesToUp( ang ) * (height*0.5) )

		// right and down vectors that get added to base org to create the display size
		vector right = ( AnglesToRight( ang ) * width )
		vector down = ( (AnglesToUp( ang )*-1) * height )

		//DebugDrawAngles( org, ang, 10000 )
		//DebugDrawAngles( org + right, ang, 10000 )
		//DebugDrawAngles( org + down, ang, 10000 )

		file.installProgressTopo = RuiTopology_CreatePlane( org, right, down, true )
	}

	entity player = GetLocalClientPlayer()

	file.installProgressRUI = RuiCreate( $"ui/training_install_progress.rpak", file.installProgressTopo, RUI_DRAW_WORLD, 0 )
	if ( INSTALL_DELAY_TEST )
	{
		#if DEV
			thread fakeinstallprogress( player )
		#endif
	}
	else
	{
		RuiTrackFloat( file.installProgressRUI, "installProgress", player, RUI_TRACK_GAME_FULLY_INSTALLED_PROGRESS )
	}
}

#if DEV
void function fakeinstallprogress( entity player )
{
	EndSignal( player, "OnDestroy" )

	Signal( player, "fakeinstallstart" )
	EndSignal( player, "fakeinstallstart" )

	float prog = 0.0
	float incMin = 0.01
	float incMax = 0.03
	float waitMin = 0.1
	float waitMax = 1.0

	while ( file.installProgressRUI != null )
	{
		RuiSetFloat( file.installProgressRUI, "installProgress", prog )

		if ( prog >= 1.0 )
			break

		wait ( RandomFloatRange( waitMin, waitMax ) )

		prog += RandomFloatRange( incMin, incMax )
		if ( prog > 1 )
			prog = 1
	}
}
#endif

void function StopShowingInstallProgress()
{
	if ( file.installProgressRUI == null )
		return

	RuiDestroyIfAlive( file.installProgressRUI )
	file.installProgressRUI = null
}

void function ScriptCallback_DoF_SetNearDepth( float nearStart, float nearEnd, float lerpDuration = 0.0 )
{
	if ( lerpDuration > 0 )
		DoF_LerpNearDepth( nearStart, nearEnd, lerpDuration )
	else
		DoF_SetNearDepth( nearStart, nearEnd )
}

void function ScriptCallback_DoF_SetFarDepth( float farStart, float farEnd, float lerpDuration = 0.0 )
{
	if ( lerpDuration > 0 )
		DoF_LerpFarDepth( farStart, farEnd, lerpDuration )
	else
		DoF_SetFarDepth( farStart, farEnd )
}

void function ScriptCallback_DoF_SetNearDepthToDefault( float lerpDuration = 0.0 )
{
	if ( lerpDuration > 0 )
		DoF_LerpNearDepthToDefault( lerpDuration )
	else
		DoF_SetNearDepthToDefault()
}

void function ScriptCallback_DoF_SetFarDepthToDefault( float lerpDuration = 0.0 )
{
	if ( lerpDuration > 0 )
		DoF_LerpFarDepthToDefault( lerpDuration )
	else
		DoF_SetFarDepthToDefault()
}


