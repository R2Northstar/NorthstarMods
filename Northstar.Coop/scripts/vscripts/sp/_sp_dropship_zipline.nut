untyped

global function SPDropship_Zipline_Init
global function InitSPDropShipZiplineSpawner
global function SpawnZiplineDropship

const ZIPLINE_SPEED = 300
const ZIPLINE_MAX_LENGTH = 3000

const DEBUG_LINES = false

struct DropShipZipLineGuy
{
	entity guy
	entity ship
	string idleAnim
	string deployAnim
	string attachTag
	entity ropeStart
	entity ropeMid
	entity ropeEnd
	vector deployPos
	bool deployed
}

struct
{
	array<table> animInfoDeployLeft = [
		{ idle = "pt_dropship_rider_L_A_idle", attach = "RopeAttachLeftA" },
		{ idle = "pt_dropship_rider_L_C_idle", attach = "RopeAttachLeftC" },
		{ idle = "pt_dropship_rider_L_B_idle", attach = "RopeAttachLeftB" }
	]

	array<table> animInfoDeployRight = [
		{ idle = "pt_dropship_rider_R_A_idle", attach = "RopeAttachRightA" },
		{ idle = "pt_dropship_rider_R_C_idle", attach = "RopeAttachRightC" },
		{ idle = "pt_dropship_rider_R_B_idle", attach = "RopeAttachRightB" }
	]

	array<string> zipLineLandingAnimations = [
		"pt_zipline_dismount_standF",
		"pt_zipline_dismount_crouchF",
		"pt_zipline_dismount_crouch180",
		"pt_zipline_dismount_breakright",
		"pt_zipline_land"
		"pt_zipline_land"
		"pt_zipline_land"
		"pt_zipline_land"
		"pt_zipline_land"
		"pt_zipline_land"
	]
	array<DropShipZipLineGuy> zipLineGuys
} file

function SPDropship_Zipline_Init()
{
	PrecacheImpactEffectTable( "dropship_dust" )

	RegisterSignal( "ropesout" )

	PrecacheModel( TEAM_IMC_GRUNT_MODEL )
}

void function InitSPDropShipZiplineSpawner( DropShipSpawnerData data )
{
	var spawnerKeyValues = data.spawner.GetSpawnEntityKeyValues()

	// For zipline dropships we have to specify the exact number of deploy positions in leveled
	Assert( data.deployEntsLeft.len() == data.riderSpawnersLeft.len(), "npc_dropship_soldiers at " + spawnerKeyValues.origin + " doesn't have same number of info_dropship_deploy_position entities for the number of grunt spawners it has." )
	Assert( data.deployEntsRight.len() == data.riderSpawnersRight.len(), "npc_dropship_soldiers at " + spawnerKeyValues.origin + " doesn't have same number of info_dropship_deploy_position entities for the number of grunt spawners it has." )
}

void function SpawnZiplineDropship( entity shipSpawner, SPDropshipStruct spDropship )
{
	AddEntityCallback_OnKilled( spDropship.dropship, OnDropshipKilled )

	int leftIndex = 0
	int rightIndex = 0
	int numRiders = spDropship.ridersLeft.len() + spDropship.ridersRight.len()

	for ( int i = 0 ; i < numRiders ; i++ )
	{
		bool leftSide = i < spDropship.ridersLeft.len()

		DropShipZipLineGuy dropShipZipLiner
		dropShipZipLiner.ship = spDropship.dropship
		dropShipZipLiner.guy = leftSide ? spDropship.ridersLeft[i] : spDropship.ridersRight[ i - spDropship.ridersLeft.len() ]

		if ( leftSide )
		{
			dropShipZipLiner.idleAnim = string( file.animInfoDeployLeft[leftIndex].idle )
			dropShipZipLiner.attachTag = string( file.animInfoDeployLeft[leftIndex].attach )
			dropShipZipLiner.deployPos = spDropship.deployEntsLeft[leftIndex].GetOrigin()
			leftIndex++
		}
		else
		{
			dropShipZipLiner.idleAnim = string( file.animInfoDeployRight[rightIndex].idle )
			dropShipZipLiner.attachTag = string( file.animInfoDeployRight[rightIndex].attach )
			dropShipZipLiner.deployPos = spDropship.deployEntsRight[rightIndex].GetOrigin()
			rightIndex++
		}
		dropShipZipLiner.deployAnim = file.zipLineLandingAnimations.getrandom()

		file.zipLineGuys.append( dropShipZipLiner )

		// Make the guy ride in the dropship and deploy
		thread GuyRidesDropshipAndDeploys( dropShipZipLiner )
	}
}

void function GuyRidesDropshipAndDeploys( DropShipZipLineGuy zipLiner )
{
	// Make guy less expensive and not have a name above his head
	if ( zipLiner.guy.IsNPC() )
	{
		zipLiner.guy.SetEfficientMode( true )
		HideName( zipLiner.guy )
	}

	// Attach guy to the dropship and idle
	int attachIndex = zipLiner.ship.LookupAttachment( zipLiner.attachTag )
	zipLiner.guy.SetParent( zipLiner.ship, zipLiner.attachTag, false, 0 )
	thread PlayAnim( zipLiner.guy, zipLiner.idleAnim, zipLiner.ship, zipLiner.attachTag )

	EndSignal( zipLiner.guy, "OnDeath" )

	// Wait until the dropship is in deploy position
	var results = WaitSignal( zipLiner.ship, "deploy", "ropesout" )

	if ( results.signal == "ropesout" )
		waitthread GuyDeploysToGround_Zipline( zipLiner, true )
	else
		waitthread GuyDeploysToGround_Zipline( zipLiner, false )

	zipLiner.deployed = true

	file.zipLineGuys.fastremovebyvalue( zipLiner )

	// Put AI back to normal AI and name above his head
	if ( IsValid( zipLiner.guy ) && zipLiner.guy.IsNPC() )
	{
		zipLiner.guy.SetEfficientMode( false )
		ShowName( zipLiner.guy )
	}
}

void function GuyDeploysToGround_Zipline( DropShipZipLineGuy zipLiner, bool waitForDeploySignal )
{

	EndSignal( zipLiner.guy, "OnDeath" )
	EndSignal( zipLiner.guy, "OnDestroy" )
	EndSignal( zipLiner.ship, "OnDestroy" )

	// Calculate mover start point
	int attachIndex = zipLiner.ship.LookupAttachment( zipLiner.attachTag )
	vector attachPos = zipLiner.ship.GetAttachmentOrigin( attachIndex )
	vector attachAng = zipLiner.ship.GetAttachmentAngles( attachIndex )

	// Calculate deploy node position and angle
	vector deployPos = zipLiner.deployPos
	vector deployAng = FlattenAngles( VectorToAngles( deployPos - attachPos ) )

	// Figure out where the zipline dismount should happen, based on the dismount animation hand position relative to the final node
	zipLiner.guy.ClearParent() // can't do this calculation while parented
	Attachment attachment = zipLiner.guy.Anim_GetAttachmentAtTime( zipLiner.deployAnim, "L_HAND", 0.0 )
	vector originOffset = attachment.position - zipLiner.guy.GetOrigin()
	float angDiff = AngleDiff( zipLiner.guy.GetAngles().y, deployAng.y )
	vector ziplineAnimEndPos = deployPos + VectorRotate( originOffset, < 0, angDiff, 0 > )
	if ( DEBUG_LINES )
		DebugDrawAngles( ziplineAnimEndPos, deployAng, 30.0 )
	zipLiner.guy.SetParent( zipLiner.ship, zipLiner.attachTag, false, 0 ) // reparent now that calculation is complete

	// Trace to see where the end of the zipline should be. We add some Z height above the dismount location so we can create bend in the line as the rider uses it.
	vector ziplineAnimEndPosTall = ziplineAnimEndPos + < 0, 0, 100 >
	vector traceEnd = attachPos + ( Normalize( ziplineAnimEndPosTall - attachPos ) * ZIPLINE_MAX_LENGTH )
	TraceResults zipLineTrace = TraceLine( attachPos, traceEnd, [ zipLiner.ship, zipLiner.guy ], TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_NONE )
	vector zipLineEnd = zipLineTrace.endPos

	if ( DEBUG_LINES )
	{
		DebugDrawLine( attachPos, zipLineEnd, 255, 255, 0, true, 30.0 )
		DebugDrawAngles( deployPos, deployAng, 30.0 )
	}

	// Figure out zipline move durations
	float zipDuration = Distance( attachPos, ziplineAnimEndPos ) / ZIPLINE_SPEED
	float zipAccel = min( 1.0, zipDuration )
	float zipRotateDuration = min( 0.2, zipDuration )

	// Create the zip line for the guy
	CreateDropshipZipLine( zipLiner )
	LaunchZipline( zipLiner, zipLineEnd )

	if ( waitForDeploySignal )
		WaitSignal( zipLiner.ship, "deploy" )

	// Make them not all deploy at the exact same time
	wait RandomFloatRange( 0.0, 0.5 )

	entity mover

	OnThreadEnd(
		function() : ( mover, zipLiner )
		{
			thread RetractZipLine( zipLiner )
			if ( IsValid( zipLiner.guy ) )
				zipLiner.guy.ClearParent()
			if ( IsValid( mover ) )
				mover.Destroy()
		}
	)

	// Get into position to zipline
	waitthread PlayAnim( zipLiner.guy, "pt_zipline_ready2slide", zipLiner.ship )

	// Update attach pos and ang now that time has passed and ship has moved around a bit
	attachPos = zipLiner.ship.GetAttachmentOrigin( attachIndex )
	attachAng = zipLiner.ship.GetAttachmentAngles( attachIndex )

	// Create the mover to make the zipline motion
	mover = CreateScriptMover( attachPos, attachAng )

	// Parent to the mover for the zipline and do zipline anim
	zipLiner.guy.SetParent( mover, "", true )
	if ( zipLiner.guy.IsNPC() )
		zipLiner.guy.Anim_ScriptedPlay( "pt_zipline_slide_idle" )
	else
		zipLiner.guy.Anim_Play( "pt_zipline_slide_idle" )

	// Move the zipline mover
	mover.NonPhysicsMoveTo( ziplineAnimEndPos, zipDuration, zipAccel, 0.0 )
	mover.NonPhysicsRotateTo( deployAng, zipRotateDuration, zipRotateDuration, 0.0 )

	thread ZiplineWaitMoveAndLand( zipLiner, zipDuration, deployPos, deployAng )
	wait zipDuration
	thread RetractZipLine( zipLiner )
}

void function ZiplineWaitMoveAndLand( DropShipZipLineGuy zipLiner, float zipDuration, vector deployPos, vector deployAng )
{
	EndSignal( zipLiner.guy, "OnDeath" )
	EndSignal( zipLiner.guy, "OnDestroy" )

	wait zipDuration

	// Guy is at the bottom of the zip line, play the deploy animation
	zipLiner.guy.ClearParent()
	if ( zipLiner.guy.IsNPC() )
		zipLiner.guy.Anim_ScriptedPlayWithRefPoint( zipLiner.deployAnim, deployPos, deployAng, 0.5 )
	else
		zipLiner.guy.Anim_PlayWithRefPoint( zipLiner.deployAnim, deployPos, deployAng, 0.5 )
	WaittillAnimDone( zipLiner.guy )

	if ( !zipLiner.guy.IsNPC() )
		zipLiner.guy.Destroy()
}

void function CreateDropshipZipLine( DropShipZipLineGuy zipLiner )
{
	local subdivisions = 0 // 25
	local slack = 0//100 // 25
	string midpointName = UniqueString( "rope_midpoint" )
	string endpointName = UniqueString( "rope_endpoint" )

	entity rope_start = CreateEntity( "move_rope" )
	rope_start.kv.NextKey = midpointName
	rope_start.kv.MoveSpeed = 0//64
	rope_start.kv.Slack = slack
	rope_start.kv.Subdiv = subdivisions
	rope_start.kv.Width = "2"
	rope_start.kv.TextureScale = "1"
	rope_start.kv.RopeMaterial = "cable/cable.vmt"
	rope_start.kv.PositionInterpolator = 2
	rope_start.DisableHibernation()

	entity rope_mid = CreateEntity( "keyframe_rope" )
	SetTargetName( rope_mid, midpointName )
	rope_mid.kv.NextKey = endpointName
	rope_mid.kv.MoveSpeed = 0//64
	rope_mid.kv.Slack = slack
	rope_mid.kv.Subdiv = subdivisions
	rope_mid.kv.Width = "2"
	rope_mid.kv.TextureScale = "1"
	rope_mid.kv.RopeMaterial = "cable/cable.vmt"
	rope_mid.DisableHibernation()

	entity rope_end = CreateEntity( "keyframe_rope" )
	SetTargetName( rope_end, endpointName )
	rope_end.kv.MoveSpeed = 0//64
	rope_end.kv.Slack = slack
	rope_end.kv.Subdiv = subdivisions
	rope_end.kv.Width = "2"
	rope_end.kv.TextureScale = "1"
	rope_end.kv.RopeMaterial = "cable/cable.vmt"
	rope_end.DisableHibernation()

	// Put the parts at the start, so the rope is tight on spawn
	int attachIndex = zipLiner.ship.LookupAttachment( zipLiner.attachTag )
	vector attachPos = zipLiner.ship.GetAttachmentOrigin( attachIndex )

	rope_start.SetParent( zipLiner.ship, zipLiner.attachTag )
	rope_mid.SetOrigin( attachPos )
	rope_end.SetOrigin( attachPos )

	// Dispatch spawn entities
	DispatchSpawn( rope_start )
	DispatchSpawn( rope_mid )
	DispatchSpawn( rope_end )

	// Now put the end in the right spot so it's stretched, and we put the mid on the guys hand so it moves with him
	rope_mid.SetParent( zipLiner.guy, "L_HAND" )

	zipLiner.ropeStart = rope_start
	zipLiner.ropeMid = rope_mid
	zipLiner.ropeEnd = rope_end
}

void function LaunchZipline( DropShipZipLineGuy zipLiner, vector endPos )
{
	entity mover = CreateOwnedScriptMover( zipLiner.ropeEnd )
	zipLiner.ropeEnd.SetParent( mover )

	float launchDuration = Distance( zipLiner.ropeStart.GetOrigin(), endPos ) / 1500
	if ( launchDuration > 0.0 )
		mover.NonPhysicsMoveTo( endPos, launchDuration, 0.0, launchDuration * 0.5 )
	else
		mover.SetOrigin( endPos )
	wait launchDuration
	zipLiner.ropeEnd.ClearParent()
	zipLiner.ropeEnd.SetOrigin( endPos )
	mover.Destroy()
}

void function RetractZipLine( DropShipZipLineGuy zipLiner )
{
	if ( IsValid( zipLiner.ropeStart ) && IsValid( zipLiner.ropeMid ) && IsValid( zipLiner.ropeEnd ) )
	{
		entity moverMid = CreateOwnedScriptMover( zipLiner.ropeMid )
		zipLiner.ropeMid.SetParent( moverMid )

		entity moverEnd = CreateOwnedScriptMover( zipLiner.ropeEnd )
		zipLiner.ropeEnd.SetParent( moverEnd )

		float duration = Distance( moverEnd.GetOrigin(), zipLiner.ropeStart.GetOrigin() ) / 3500
		moverMid.NonPhysicsMoveTo( zipLiner.ropeStart.GetOrigin(), duration * 0.5, 0.0, 0.0 )
		moverEnd.NonPhysicsMoveTo( zipLiner.ropeStart.GetOrigin(), duration, 0.0, 0.0 )

		wait duration

		moverMid.Destroy()
		moverEnd.Destroy()
	}

	if ( IsValid( zipLiner.ropeStart ) )
		zipLiner.ropeStart.Destroy()
	if ( IsValid( zipLiner.ropeMid ) )
		zipLiner.ropeMid.Destroy()
	if ( IsValid( zipLiner.ropeEnd ) )
		zipLiner.ropeEnd.Destroy()
}

void function OnDropshipKilled( entity dropship, var damageInfo )
{
	foreach( DropShipZipLineGuy zipLiner in file.zipLineGuys )
	{
		if ( zipLiner.ship == dropship && !zipLiner.deployed )
		{
			if ( IsValid( zipLiner.guy ) && IsAlive( zipLiner.guy ) )
				zipLiner.guy.TakeDamage( zipLiner.guy.GetMaxHealth() + 1, DamageInfo_GetAttacker( damageInfo ), DamageInfo_GetAttacker( damageInfo ), { weapon = DamageInfo_GetWeapon( damageInfo ), origin = DamageInfo_GetDamagePosition( damageInfo ), force = DamageInfo_GetDamageForce( damageInfo ), scriptType = DamageInfo_GetCustomDamageType( damageInfo ), damageSourceId = DamageInfo_GetDamageSourceIdentifier( damageInfo ) } )
		}
	}
}