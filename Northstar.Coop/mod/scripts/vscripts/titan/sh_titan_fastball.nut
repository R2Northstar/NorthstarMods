untyped
// TODO: Make this with _event.gnut functions

global function TitanFastball_Init
#if SERVER
	global function SetCustomFastBallAimModeFunc
	global function ScriptedTitanFastball
	global function ClientCommand_FastballLaunch
	global function ClientCommand_FastballCancel
	global function SetFastballAnims
	global function SetFastballVars
	global function GetScriptedFastBallVelocity
#endif
#if CLIENT
	global function ButtonCallback_FastballLaunch
	global function ButtonCallback_FastballCancelLaunch
#endif

const FASTBALL_THROW_SPEED_MIN = 300
const FASTBALL_THROW_SPEED_MAX = 1500
const FASTBALL_FLY_TIME_MIN = 0.9
const FASTBALL_FLY_TIME_MAX = 3.5
const FASTBALL_VERTICAL_OFFSET_START = -2

struct {
	void functionref(entity,entity) fastBallAimModeFunc
	string[5] fastballAnims = [ "bt_beacon_fastball_throw_start",
								"bt_beacon_fastball_throw_idle",
								"bt_beacon_fastball_throw_end",
								"ptpov_beacon_fastball_throw_end",
								"pt_beacon_fastball_throw_end" ]

	entity fastballAnimRef 		= null
	vector functionref( entity, entity) fastballVelocityFunc = null
}file

void function TitanFastball_Init()
{
	#if SERVER
		AddSpawnCallback( "npc_titan", FastballTitanSpawned )
		AddClientCommandCallback( "FastballLaunch", ClientCommand_FastballLaunch )
		AddClientCommandCallback( "FastballCancel", ClientCommand_FastballCancel )
		AddClientCommandCallback( "FastballActivate", ClientCommand_FastballActivate )
		AddClientCommandCallback( "FastballDeactivate", ClientCommand_FastballDeactivate )
		RegisterSignal( "FastballCancel" )
		RegisterSignal( "FastballLaunch" )
		RegisterSignal( "ReadyForFastball" )
		RegisterSignal( "FastballStarting" )
		RegisterSignal( "fastball_start_throw" )
		RegisterSignal( "fastball_release" )
		FlagInit( "FastballEnabled" )
		file.fastBallAimModeFunc = Fastball_PlayerAndTitanEnterAimingMode

		// For leveled placed scripted throws
		AddTriggerEditorClassFunc( "trigger_fastball", ScriptedFastballTriggerThink )

	#endif
	#if CLIENT
		RegisterEntityVarChangeCallback( "player", "drawFastballHud", DrawFastballHudChanged )
		RegisterButtonPressedCallback( BUTTON_TRIGGER_RIGHT, ButtonCallback_FastballLaunch )
		RegisterButtonPressedCallback( MOUSE_LEFT, ButtonCallback_FastballLaunch )
		RegisterButtonPressedCallback( BUTTON_B, ButtonCallback_FastballCancelLaunch )
		RegisterButtonPressedCallback( BUTTON_Y, ButtonCallback_FastballPressedActivate )
		RegisterConCommandTriggeredCallback( "+melee", ButtonCallback_FastballPressedActivatePC )
		RegisterButtonReleasedCallback( BUTTON_Y, ButtonCallback_FastballReleasedActivate )
		RegisterSignal( "ActivateButtonReleased" )
	#endif
	RegisterSignal( "FastballHudDisable" )
}

vector function Fastball_GetThrowVelocity( entity player )
{
	// viewFwd.z: -1 = looking straight down, 1 = looking straight up
	vector viewFwd = player.GetViewVector()
	float throwSpeed = GraphCapped( viewFwd.z, 0.95, 0.1, FASTBALL_THROW_SPEED_MIN, FASTBALL_THROW_SPEED_MAX )
	float flyTime = GraphCapped( viewFwd.z, -0.2, 0.7, FASTBALL_FLY_TIME_MIN, FASTBALL_FLY_TIME_MAX )
	vector throwVelocity = GetPlayerVelocityForDestOverTime( player.GetOrigin(), ( Fastball_GetThrowStartPos( player ) + ( player.GetViewVector() * throwSpeed ) ), flyTime )
	return throwVelocity
}

vector function Fastball_GetThrowStartPos( entity player )
{
	return player.EyePosition() + Vector( 0, 0, FASTBALL_VERTICAL_OFFSET_START )
}

// =================================
// ========== SERVER ONLY ==========
// =================================
#if SERVER
void function FastballTitanSpawned( entity titan )
{
	thread FastballTitanThink( titan )
}

void function SetCustomFastBallAimModeFunc( void functionref(entity,entity) func )
{
	file.fastBallAimModeFunc = func
}

void function FastballTitanThink( entity titan )
{
	EndSignal( titan, "OnDeath" )

	entity player

	while( true )
	{
		FlagWait( "FastballEnabled" )

		wait 0.1

		player = titan.GetBossPlayer()
		if ( !IsValid( player ) || !IsAlive( player ) )
			continue

		if ( player.IsNoclipping() )
			continue

		if ( player.p.pilotEjecting )
			continue

		if ( !player.p.fastballActivatePressed )
			continue

		if ( player.ContextAction_IsActive() )
			continue

		if ( IsPlayerEmbarking( player ) )
			continue

		waitthread file.fastBallAimModeFunc( player, titan )
		wait 1.5 // extra debounce
	}
}

void function Fastball_PlayerAndTitanEnterAimingMode( entity player, entity titan )
{
	// EndSignal( player, "OnDeath" ) // huh I think it won't break anything
	EndSignal( titan, "OnDestroy" )
	EndSignal( player, "player_embarks_titan" )
	EndSignal( player, "FastballCancel" )

	int ogTitanMode = player.GetPetTitanMode()
	vector ogTitanOrg = titan.GetOrigin()
	vector playerViewVector = player.GetViewVector()
	float playerYaw = VectorToAngles( playerViewVector ).y

	titan.SetAngles( Vector( 0, playerYaw, 0 ) )
	entity mover = CreateOwnedScriptMover( titan )
	mover.SetAngles( Vector( 0, titan.GetAngles().y, 0 ) )
	titan.SetParent( mover )
	
	thread PlayAnim( titan, "bt_FastBall_Pose", mover, "REF" )

	int attachID = titan.LookupAttachment( "FASTBALL" )
	vector tagAngles = titan.GetAttachmentAngles( attachID )

	foreach( entity p in GetPlayerArray() )
	{
		
		p.SetParent( titan, "FASTBALL", false )

		p.PlayerCone_SetSpecific( AnglesToForward( tagAngles ) )
		p.PlayerCone_SetMinYaw( 0 )
		p.PlayerCone_SetMaxYaw( 0 )
		p.PlayerCone_SetMinPitch( 0 )
		p.PlayerCone_SetMaxPitch( 0 )
		wait 0.3
		p.PlayerCone_SetMinYaw( -180 )
		p.PlayerCone_SetMaxYaw( 180 )
		p.PlayerCone_SetMinPitch( -50 )
		p.PlayerCone_SetMaxPitch( 50 )
	}

	OnThreadEnd(
		function() : ( player, titan, mover, ogTitanMode, ogTitanOrg )
		{
			foreach( entity p in GetPlayerArray() )
			{
				p.ClearParent()
				p.SetLocalAngles( p.EyeAngles() )
				p.PlayerCone_Disable()
				p.DeployWeapon()
				p.nv.drawFastballHud = false

				// clear help message
				Dev_PrintMessage( p, "", "", 0.1 )
			}

			if ( IsValid( player ) )
			{
				player.SetPetTitanMode( ogTitanMode )  // HACK he forgets about guard mode after anim stops
			}

			if ( IsValid( titan ) )
			{
				titan.ClearParent()
				titan.Anim_Stop()

				// Watch the player as he flies
				if ( IsValid( player ) && IsAlive( titan ) )
				{

					thread AssaultOrigin( titan, ogTitanOrg )
				}
			}
			
			if ( IsValid( mover ) )
			{
				wait 5
				mover.ClearParent()
				mover.Destroy()
			}
		}
	)
	
	foreach( entity p in GetPlayerArray() )
	{
		if ( !( "helpShown_THROW" in p.s ) )
		{
			Dev_PrintMessage( p, "", "Aim where you want to be thrown, then pull the trigger." )
			p.s.helpShown_THROW <- true
		}

		// Draw the hud
		p.nv.drawFastballHud = true

		// Disable weapon
		p.DisableWeaponWithSlowHolster()
	}

	if ( GetBugReproNum() == 110567 )
		thread TitanRotateForAiming( mover, titan, player )

	// Wait till player is thrown. Then this thread will end and the think function will resume
	WaitSignal( player, "FastballLaunch" )
	thread FastballThrowPlayer( player )
}

function TitanRotateForAiming( entity mover, entity titan, entity player )
{
	EndSignal( player, "OnDeath" )
	EndSignal( titan, "OnDestroy" )
	EndSignal( mover, "OnDestroy" )
	EndSignal( player, "player_embarks_titan" )
	EndSignal( player, "FastballCancel" )
	EndSignal( player, "FastballLaunch" )

	while( true )
	{
		vector aimVec = FlattenVector( player.GetViewVector() )
		vector aimAngles = VectorToAngles( aimVec )
		//float angDiff = fabs( AngleDiff( mover.GetAngles().y, aimAngles.y ) )
		//if ( angDiff >= 20 )
			mover.NonPhysicsRotateTo( Vector( 0, aimAngles.y, 0 ), 0.4, 0.0, 0.0 )
		wait 0.2
	}
}

function FastballThrowPlayer( entity player )
{
	vector throwVelocity = Fastball_GetThrowVelocity( player )
	vector throwStartPos = Fastball_GetThrowStartPos( player )

	entity mover = player.GetParent()
	mover.ClearParent()
	mover.SetOrigin( player.GetOrigin() )
	mover.SetParent( player )

	player.ClearParent()
	player.SetVelocity( throwVelocity )
	player.SetOrigin( throwStartPos )

	WaitFrame()

	foreach( entity p in GetPlayerArray() )
	{
		WaitFrame()
		p.ClearParent()
		p.SetVelocity( Fastball_GetThrowVelocity( player ) )
		p.SetOrigin( throwStartPos )
		p.DeployWeapon()
	}

	wait 1

	foreach( entity p in GetPlayerArray() )
	{
		if ( p != player )
		{
			p.ClearParent()
			p.SetVelocity( player.GetVelocity() )
			p.SetOrigin( player.GetOrigin() )
		}
	}
}

bool function ClientCommand_FastballLaunch( entity player, array<string> args )
{
	Signal( player, "FastballLaunch" )
	return true
}

bool function ClientCommand_FastballCancel( entity player, array<string> args )
{
	Signal( player, "FastballCancel" )
	return true
}

bool function ClientCommand_FastballActivate( entity player, array<string> args )
{
	player.p.fastballActivatePressed = true
	return true
}

bool function ClientCommand_FastballDeactivate( entity player, array<string> args )
{
	player.p.fastballActivatePressed = false
	return true
}

void function ScriptedFastballTriggerThink( entity trigger )
{
	EndSignal( trigger, "OnDestroy" )
	entity titanNode = trigger.GetLinkEnt()
	Assert( IsValid( titanNode ) && titanNode.GetClassName() == "script_ref", "trigger_fastball must link to a script_ref" )
	entity throwTarget = titanNode.GetLinkEnt()
	Assert( IsValid( throwTarget ) && throwTarget.GetClassName() == "info_target", "trigger_fastball's script_ref must link to an info_target where the titan should throw you to" )

	for ( ;; )
	{
		table results = trigger.WaitSignal( "OnTrigger" )
		entity player = expect entity( results.activator )
		if ( !IsValid( player ) )
			continue
		if ( !player.IsPlayer() )
			continue
		entity titan = player.GetPetTitan()
		if ( !IsValid( titan ) )
			continue

		// Fastball
		waitthread ScriptedTitanFastball( player, titan, titanNode, throwTarget )
	}
}

void function SetFastballAnims( string startAnim, string loopAnim, string throwAnim, string fpvAnim, string thirdPersonAnim )
{
	file.fastballAnims[0] = startAnim
	file.fastballAnims[1] = loopAnim
	file.fastballAnims[2] = throwAnim
	file.fastballAnims[3] = fpvAnim
	file.fastballAnims[4] = thirdPersonAnim
}

void function SetFastballVars( entity ref = null, vector functionref( entity, entity) GetVelocityFunc = null )
{
	file.fastballAnimRef 		= ref
	file.fastballVelocityFunc	= GetVelocityFunc
}

void function ScriptedTitanFastball( entity player, entity titan, entity titanNode, entity throwTarget, string setFlagWhenGrabbed = "" )
{
	EndSignal( player, "OnDeath" )
	EndSignal( titan, "OnDeath" )

	entity ref = file.fastballAnimRef
	if ( !IsValid( ref ) )
		ref = CreateOwnedScriptMover( titanNode )
	if ( file.fastballVelocityFunc == null )
		file.fastballVelocityFunc = GetScriptedFastBallVelocity

	OnThreadEnd(
		function() : ( ref, player, titan )
		{
			if ( IsValid( titan ) )
			{
				titan.ClearParent()
				titan.Anim_Stop()
			}
			if ( IsValid( ref ) )
			{
				if ( IsValid( player ) && player.GetParent() == ref )
					player.ClearParent()
				ref.Destroy()
			}

			file.fastballAnimRef 		= null
			file.fastballVelocityFunc	= null
		}
	)

	// Send the titan to the throw position
	//RunToAnimStartForced_Deprecated( titan, file.fastballAnims[0], ref )

	titan.SetParent( ref )

	// Assert( file.fastballAnims[0] != "" )
	Assert( file.fastballAnims[1] != "" )
	Assert( file.fastballAnims[2] != "" )

	// Play the anim to get into throw pose
	if ( file.fastballAnims[0] != "" )
		waitthread PlayAnim( titan, file.fastballAnims[0], ref, "REF" )

	// Get into looping anim to wait for the player
	thread PlayAnim( titan, file.fastballAnims[1], ref, "REF" )

	Signal( titan, "ReadyForFastball" )

	// Wait for player to be near the hand
	int attachID = titan.LookupAttachment( "FASTBALL_R" )
	vector tagOrigin = titan.GetAttachmentOrigin( attachID )
	vector tagAngles = titan.GetAttachmentAngles( attachID )

	while( Distance( player.GetOrigin(), tagOrigin ) > 150 )//|| IsConversationPlaying() )
	{
		WaitFrame()
		tagOrigin = titan.GetAttachmentOrigin( attachID )
	}

	HideName( titan )

	Signal( titan, "FastballStarting" )
	if ( setFlagWhenGrabbed != "" )
		FlagSet( setFlagWhenGrabbed )
	
	foreach( entity p in GetPlayerArray() )
	{
		p.DisableWeaponWithSlowHolster()
	}

	// Titan and player animate together for throw
	thread PlayAnim( titan, file.fastballAnims[2], ref, "REF" )
	titan.Anim_AdvanceCycleEveryFrame( true )
	thread PlayerScriptedFastballAnim( player, titan, ref )

	WaitSignal( titan, "fastball_release" )

	// Throw the player
	vector throwVelocity = file.fastballVelocityFunc( player, throwTarget )
	vector throwStartPos = Fastball_GetThrowStartPos( player )
	
	// player.ClearParent()
	// player.SetVelocity( throwVelocity )
	// player.SetOrigin( throwStartPos )
	// player.DeployWeapon()

	WaitFrame()

	foreach( entity p in GetPlayerArray() )
	{
		WaitFrame()
		p.ClearParent()
		p.SetVelocity( throwVelocity )
		p.SetOrigin( throwStartPos )
		p.DeployWeapon()
	}
	EmitSoundOnEntity( player, "bt_beacon_fastball_Whoosh" )

	// Make titan stop animating
	WaittillAnimDone( titan )

	ShowName( titan )
}

vector function GetScriptedFastBallVelocity( entity player, entity throwTarget )
{
	float throwDist = Distance( player.GetOrigin(), throwTarget.GetOrigin() )
	float throwDuration = throwDist / 1200
	vector throwVelocity = GetPlayerVelocityForDestOverTime( player.GetOrigin(), throwTarget.GetOrigin(), throwDuration )

	return throwVelocity
}

void function PlayerScriptedFastballAnim( entity player, entity titan, entity ref )
{
	player.EndSignal( "OnDeath" )
	titan.EndSignal( "OnDeath" )

	OnThreadEnd(
		function() : ( player )
		{
			foreach( player in GetPlayerArray() )
			{
				if ( IsValid( player ) )
				{
					player.Anim_Stop()
					player.ClearParent()
					ClearPlayerAnimViewEntity( player )
					if ( player.ContextAction_IsFastball() )
						player.ContextAction_ClearFastball()
				}
			}
		}
	)

	if ( !player.ContextAction_IsFastball() )
		player.ContextAction_SetFastball()
	
	foreach( entity p in GetPlayerArray() )
		p.ForceStand()
	
	FirstPersonSequenceStruct sequence
	sequence.attachment = "REF"
	sequence.useAnimatedRefAttachment = true
	sequence.hideProxy = true
	sequence.firstPersonAnim = file.fastballAnims[3]
	sequence.thirdPersonAnim = file.fastballAnims[4]
	sequence.viewConeFunction = ViewConeFastball
	sequence.firstPersonBlendOutTime = 0.0
	
	foreach( entity p in GetPlayerArray() )
	{
		if ( p.GetModelName() != $"humans/pilots/pilot_medium_reaper_f.mdl" )
			thread FirstPersonSequence( sequence, p, ref )
	}

	WaitSignal( titan, "fastball_release" )
	foreach( entity p in GetPlayerArray() )
		p.UnforceStand()
}

#endif //SERVER



// =================================
// ========== CLIENT ONLY ==========
// =================================
#if CLIENT
function DrawFastballHudChanged( player )
{
	expect entity( player )

	Signal( player, "FastballHudDisable" )
	if ( !player.nv.drawFastballHud )
		return

	thread FastballHudThink( player )
}

void function FastballHudThink( entity player )
{
	EndSignal( player, "FastballHudDisable" )
	EndSignal( player, "OnDeath" )

	while( true )
	{
		vector throwVelocity = Fastball_GetThrowVelocity( player )
		vector arcStart = Fastball_GetThrowStartPos( player )
		vector parentVelocity = < 0, 0, 0 >
		float timeLimit = FASTBALL_FLY_TIME_MAX

		bool drawPath = true
		float drawPathDuration = 0.02
		array pathColor = [ 255, 255, 0 ]
		GravityLandData data = GetGravityLandData( arcStart, parentVelocity, throwVelocity, timeLimit, false, drawPathDuration, pathColor )
		//printt( "data points:", data.points.len())

		// draw the lines on the sides
		vector viewRight = player.GetViewRight()
		vector arcStartRight = arcStart + ( viewRight * 1.5 )
		vector arcStartRight2 = arcStart + ( viewRight * 3 )
		vector arcStartLeft = arcStart + ( (viewRight*-1) * 1.5 )
		vector arcStartLeft2 = arcStart + ( (viewRight*-1) * 3 )

		thread GetGravityLandData( arcStartRight, parentVelocity, throwVelocity, timeLimit, drawPath, drawPathDuration, pathColor )
		thread GetGravityLandData( arcStartRight2, parentVelocity, throwVelocity, timeLimit, drawPath, drawPathDuration, pathColor )
		thread GetGravityLandData( arcStartLeft, parentVelocity, throwVelocity, timeLimit, drawPath, drawPathDuration, pathColor )
		thread GetGravityLandData( arcStartLeft2, parentVelocity, throwVelocity, timeLimit, drawPath, drawPathDuration, pathColor )


		WaitFrame()
	}
}

function ButtonCallback_FastballLaunch( player )
{
	player.ClientCommand( "FastballLaunch" )
}

function ButtonCallback_FastballCancelLaunch( player )
{
	player.ClientCommand( "FastballCancel" )
}

function ButtonCallback_FastballPressedActivate( player )
{
	thread ActivateFastballThink( expect entity( player ) )
}

function ButtonCallback_FastballPressedActivatePC( player )
{
	thread FastballPCButtonActivate( player )
}

function FastballPCButtonActivate( player )
{
	EndSignal( player, "OnDeath" )
	EndSignal( player, "OnDestroy" )
	thread ActivateFastballThink( expect entity( player ) )
	wait 1
	ButtonCallback_FastballReleasedActivate( player )
}

function ButtonCallback_FastballReleasedActivate( player )
{
	Signal( player, "ActivateButtonReleased" )
	player.ClientCommand( "FastballDeactivate" )
}

void function ActivateFastballThink( entity player )
{
	EndSignal( player, "OnDeath" )
	EndSignal( player, "OnDestroy" )
	EndSignal( player, "ActivateButtonReleased" )
	bool w = false
	while( true )
	{
		if ( w ) // dont wait on the first loop, makes button more responsive
			WaitFrame()
		w = true

		if ( !player.HasUsePrompt() )
			continue

		entity petTitan = player.GetPetTitan()
		if ( !IsValid( petTitan ) )
			continue

		if ( player.GetUsePromptEntity() != petTitan )
			continue

		break
	}
	player.ClientCommand( "FastballActivate" )
}

#endif //CLIENT
