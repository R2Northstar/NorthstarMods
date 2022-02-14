untyped

global function SPDropship_Init
global function InitDropshipSpawnerCommon
global function IsDropshipSpawner
global function SpawnFromDropship
global function GetOriginForEntOrSpawner
global function GetAttachOrderForDropshipType

global const DROPSHIP_DEBUG_LINES	= false
const DROPSHIP_FLY_SPEED 			= 2500
const DROPSHIP_HEALTH 				= 7800

// HACK/TODO: At some point, the rotation exported from LevelEd changed causing node-following dropships to rotate incorrectly as they fly from node to node.
// Node-following dropships are only used once in Sewers so compensate for it here and investigate a better fix for next game.
// Every other level uses a custom deploy animation and is unaffected.
const vector REF_ANGLE_OFFSET 		= < 0, -90, 0 >

global struct SPDropshipStruct
{
	entity dropship
	entity spawner
	array<entity> enterNodes
	array<entity> exitNodes
	vector deployPos
	vector deployAng
	array<entity> ridersLeft
	array<entity> ridersRight
	array<entity> deployEntsLeft
	array<entity> deployEntsRight
	bool useDeployAnim
	string deployAnim
	bool deleteSoldiers
}

global struct DropShipSpawnerData
{
	entity spawner
	array<entity> enterNodes
	array<entity> exitNodes
	vector deployPos
	vector deployAng
	array<entity> riderSpawnersLeft
	array<entity> riderSpawnersRight
	array<entity> deployEntsLeft
	array<entity> deployEntsRight
	bool useDeployAnim
	string deployAnim
	bool deleteSoldiers
}

struct
{
	table<entity,DropShipSpawnerData> dropShipSpawnerData
	array<SPDropshipStruct> dropshipStructs
	} file

void function SPDropship_Init()
{
	RegisterSignal( "deploy" )
	RegisterSignal( "OnSpawned" )

	SPDropship_Zipline_Init()
	SPDropship_Widow_Init()

	AddCallback_EntitiesDidLoad( SPDropship_EntitiesDidLoad )
}

void function SPDropship_EntitiesDidLoad()
{
	array<entity> dropshipSpawners = GetSpawnerArrayByClassName( "npc_dropship" )
	foreach( entity spawner in dropshipSpawners )
	{
		if ( !IsDropshipSpawner( spawner ) )
			continue

		table spawnerKeyValues = spawner.GetSpawnEntityKeyValues()
		if ( !( "editorclass" in spawnerKeyValues ) )
			continue

		DropShipSpawnerData data = InitDropshipSpawnerCommon( spawner )

		switch( string( spawnerKeyValues.editorclass ) )
		{
			case "npc_dropship_soldiers":
				thread InitSPDropShipZiplineSpawner( data )
				break
			case "npc_dropship_widow":
				thread InitSPDropShipWidowSpawner( data )
				break
		}
	}
}

DropShipSpawnerData function InitDropshipSpawnerCommon( entity spawner )
{
	var spawnerKeyValues = spawner.GetSpawnEntityKeyValues()

	//#############################
	// Init used flags
	//#############################

	if ( "deploy_flag_wait" in spawnerKeyValues && spawnerKeyValues.deploy_flag_wait != "" )
		FlagInit( string( spawnerKeyValues.deploy_flag_wait ) )

	//#############################
	// Get all associated entities
	//#############################

	array<entity> linkParentEnts = spawner.GetLinkParentArray()
	array<entity> linkedEnts = spawner.GetLinkEntArray()
	array<entity> riderSpawners
	array<entity> deployEnts
	array<entity> enterNodes
	array<entity> exitNodes

	foreach( entity linkEnt in linkedEnts )
	{
		if ( IsSpawner( linkEnt ) )
			riderSpawners.append( linkEnt )
		else if ( GetEditorClass( linkEnt ) == "info_dropship_deploy_position" )
			deployEnts.append( linkEnt )
		else if ( linkEnt.GetClassName() == "info_target" )
		{
			entity node = linkEnt
			while( IsValid( node ) && node.GetClassName() == "info_target" )
			{
				exitNodes.append( node )
				node = node.GetLinkEnt()
			}
		}
	}
	foreach( entity linkParent in linkParentEnts )
	{
		if ( linkParent.GetClassName() == "info_target" )
		{
			entity node = linkParent
			while( IsValid( node ) && node.GetClassName() == "info_target" )
			{
				enterNodes.insert( 0, node )
				node = node.GetLinkParent()
			}
			break
		}
	}

	vector shipDeployPos = StringToVector( string ( spawnerKeyValues.origin ) )
	vector shipDeployAng = StringToVector( string( spawnerKeyValues.angles ) )

	//##########################################
	// Assign deploy entities to side and index
	//##########################################

	array<entity> deployEntsLeft
	array<entity> deployEntsRight
	CalculateDeployPositions( spawner, shipDeployPos, shipDeployAng, deployEnts, deployEntsLeft, deployEntsRight )

	array<entity> riderSpawnersLeft
	array<entity> riderSpawnersRight
	CalculateDeployPositions( spawner, shipDeployPos, shipDeployAng, riderSpawners, riderSpawnersLeft, riderSpawnersRight )

	Assert( riderSpawnersLeft.len() + riderSpawnersRight.len() == riderSpawners.len() )
	Assert( riderSpawnersLeft.len() + riderSpawnersRight.len() > 0, "npc_dropship_soldiers at " + spawnerKeyValues.origin + " doesn't target any npcs." )

	//############################################################
	// Create the dropship data struct and fill in all the fields
	//############################################################

	DropShipSpawnerData data
	data.spawner = spawner
	data.enterNodes = enterNodes
	data.exitNodes = exitNodes
	data.deployPos = shipDeployPos
	data.deployAng = shipDeployAng
	data.riderSpawnersLeft = riderSpawnersLeft
	data.riderSpawnersRight = riderSpawnersRight
	data.deployEntsLeft = deployEntsLeft
	data.deployEntsRight = deployEntsRight
	data.deployAnim = string( spawnerKeyValues.deploy_anim )
	data.useDeployAnim = spawnerKeyValues.useDeployAnim == "1" && data.deployAnim != ""
	data.deleteSoldiers = ( "DeleteSoldiers" in spawnerKeyValues && spawnerKeyValues.DeleteSoldiers == "1" )

	Assert( !( spawner in file.dropShipSpawnerData ) )
	file.dropShipSpawnerData[ spawner ] <- data

	// Make sure that is we specify to use leveled node flight path that the dropship has flight nodes to use
	if ( !data.useDeployAnim )
	{
		Assert( data.exitNodes.len() > 0, "npc_dropship_soldiers at " + shipDeployPos + " doesn't have any nodes to fly away. Target the ship to info_target chain or set a deploy_anim" )
		Assert( data.enterNodes.len() > 0, "npc_dropship_soldiers at " + shipDeployPos + " doesn't have any nodes to fly in. Target some info_targets to the ship or set a deploy_anim" )
	}

	// Debug lines
	if ( DROPSHIP_DEBUG_LINES )
	{
		wait 1

		// Draw ship deploy position and angles
		DebugDrawAngles( shipDeployPos, shipDeployAng, 9999 )

		// Draw line from ship to spawners
		foreach( entity spawner in riderSpawners )
		{
			var spawnerKVs = spawner.GetSpawnEntityKeyValues()
			vector spawnerPos = StringToVector( string ( spawnerKVs.origin ) )
			DebugDrawLine( shipDeployPos, spawnerPos, 200, 200, 200, true, 9999 )
			DebugDrawText( spawnerPos, spawner.GetSpawnEntityClassName().tostring(), true, 9999 )
		}

		// Draw flight path in
		for ( int i = 0 ; i < enterNodes.len() ; i++ )
		{
			vector end = i + 1 >= enterNodes.len() ? shipDeployPos : enterNodes[i + 1].GetOrigin()
			DebugDrawLine( enterNodes[i].GetOrigin(), end, 0, 255, 0, true, 9999 )
			DebugDrawAngles( enterNodes[i].GetOrigin(), enterNodes[i].GetAngles(), 9999 )
		}

		// Draw flight path out
		for ( int i = 0 ; i < exitNodes.len() ; i++ )
		{
			vector start = i <= 0 ? shipDeployPos : exitNodes[i - 1].GetOrigin()
			DebugDrawLine( start, exitNodes[i].GetOrigin(), 255, 0, 0, true, 9999 )
			if ( i >= 0 )
				DebugDrawAngles( exitNodes[i].GetOrigin(), exitNodes[i].GetAngles(), 9999 )
		}

		// Draw deploy positions
		foreach( int i, entity node in deployEntsLeft )
		{
			DebugDrawLine( shipDeployPos, node.GetOrigin(), 200, 200, 0, true, 9999)
			DebugDrawText( node.GetOrigin(), "L-" + i, true, 9999 )
		}

		foreach( int i, entity node in deployEntsRight )
		{
			DebugDrawLine( shipDeployPos, node.GetOrigin(), 0, 200, 200, true, 9999)
			DebugDrawText( node.GetOrigin(), "R-" + i, true, 9999 )
		}

		// Draw line from spawners to deploy entity assigned to that spawner
		foreach( int i, entity spawner in riderSpawnersLeft )
		{
			if ( i >= deployEntsLeft.len() )
				continue
			DebugDrawLine( GetOriginForEntOrSpawner( spawner ), deployEntsLeft[i].GetOrigin(), 0, 200, 200, true, 9999 )
			DebugDrawText( GetOriginForEntOrSpawner( spawner ), "L-" + i, true, 9999 )
		}
		foreach( int i, entity spawner in riderSpawnersRight )
		{
			if ( i >= deployEntsRight.len() )
				continue
			DebugDrawLine( GetOriginForEntOrSpawner( spawner ), deployEntsRight[i].GetOrigin(), 0, 200, 200, true, 9999 )
			DebugDrawText( GetOriginForEntOrSpawner( spawner ), "R-" + i, true, 9999 )
		}
	}

	return data
}

bool function IsDropshipSpawner( entity ent )
{
	if ( !IsSpawner( ent ) )
		return false

	table spawnerKeyValues = ent.GetSpawnEntityKeyValues()

	if ( !( "editorclass" in spawnerKeyValues ) )
		return false

	switch( spawnerKeyValues.editorclass )
	{
		case "npc_dropship_soldiers":
		case "npc_dropship_widow":
			return true
	}
	return false
}

void function SpawnFromDropship( entity shipSpawner )
{
	Assert( IsNewThread(), "Must be threaded off." )
	Assert( shipSpawner in file.dropShipSpawnerData )

	shipSpawner.EndSignal( "OnDestroy" )
	// Get the struct for this spawner
	DropShipSpawnerData spawnData = file.dropShipSpawnerData[ shipSpawner ]

	//######################################
	// Transfer data to the dropship struct
	//######################################

	SPDropshipStruct spDropship
	spDropship.spawner = shipSpawner
	spDropship.enterNodes = spawnData.enterNodes
	spDropship.exitNodes = spawnData.exitNodes
	spDropship.deployPos = spawnData.deployPos
	spDropship.deployAng = spawnData.deployAng
	spDropship.deployEntsLeft = spawnData.deployEntsLeft
	spDropship.deployEntsRight = spawnData.deployEntsRight
	spDropship.useDeployAnim = spawnData.useDeployAnim
	spDropship.deployAnim = spawnData.deployAnim
	spDropship.deleteSoldiers = spawnData.deleteSoldiers

	//################
	// Warp in effect
	//################

	if ( spDropship.useDeployAnim )
	{
		waitthread WarpinEffect( DROPSHIP_MODEL, spDropship.deployAnim, spDropship.deployPos, spDropship.deployAng )
	}
	else
	{
		vector warpPos = spDropship.enterNodes[0].GetOrigin()
		vector warpAng
		if ( spDropship.enterNodes.len() > 1 )
			warpAng = VectorToAngles( spDropship.enterNodes[1].GetOrigin() - spDropship.enterNodes[0].GetOrigin() )
		else
			warpAng = VectorToAngles( spDropship.deployPos - spDropship.enterNodes[0].GetOrigin() )
		waitthread __WarpInEffectShared( warpPos, warpAng, "" )
	}

	//####################
	// Spawn the dropship
	//#####################

	spDropship.dropship = shipSpawner.SpawnEntity()
	DispatchSpawn( spDropship.dropship )
	spDropship.dropship.EndSignal( "OnDeath" )
	spDropship.dropship.SetModel( shipSpawner.GetSpawnerModelName() )
	spDropship.dropship.SetHealth( DROPSHIP_HEALTH )
	spDropship.dropship.SetMaxHealth( DROPSHIP_HEALTH )

	//################
	// Spawn the guys
	//################

	int numSpawners = spawnData.riderSpawnersLeft.len() + spawnData.riderSpawnersRight.len()
	for ( int i = 0 ; i < numSpawners ; i++ )
	{
		bool left = i < spawnData.riderSpawnersLeft.len()
		entity npcSpawner = left ? spawnData.riderSpawnersLeft[i] : spawnData.riderSpawnersRight[i - spawnData.riderSpawnersLeft.len()]
		if ( !IsValid( npcSpawner ) )
			continue
		entity guy
		if ( spDropship.deleteSoldiers )
		{
			guy = CreatePropDynamic( TEAM_IMC_GRUNT_MODEL )
		}
		else
		{
			//printt( "npcSpawner.GetLinkEntArray().len()", npcSpawner.GetLinkEntArray().len() )
			//printt( "npcSpawner.GetLinkParentArray().len()", npcSpawner.GetLinkParentArray().len() )

			guy = npcSpawner.SpawnEntity()

			//printt( "guy.GetLinkEntArray().len()", guy.GetLinkEntArray().len() )
			//printt( "guy.GetLinkParentArray().len()", guy.GetLinkParentArray().len() )

			DispatchSpawn( guy )
		}

		if ( left )
			spDropship.ridersLeft.append( guy )
		else
			spDropship.ridersRight.append( guy )
	}

	//##################################
	// Do class specific spawn function
	//##################################

	table spawnerKeyValues = shipSpawner.GetSpawnEntityKeyValues()
	Assert( "editorclass" in spawnerKeyValues )

	switch( spawnerKeyValues.editorclass )
	{
		case "npc_dropship_soldiers":
			waitthread SpawnZiplineDropship( shipSpawner, spDropship )
			break
		case "npc_dropship_widow":
			waitthread SpawnWidowDropship( shipSpawner, spDropship )
			break
		default:
			Assert(0, "Not a handled type of dropship spawner" )
	}

	//######################################################################
	// Signal that the dropship spawned and pass along info to the scripter
	//######################################################################

	table signalData
	signalData.dropship <- spDropship.dropship
	signalData.riders <- []
	foreach( guy in spDropship.ridersLeft )
		signalData.riders.append( guy )
	foreach( guy in spDropship.ridersRight )
		signalData.riders.append( guy )
	Signal( shipSpawner, "OnSpawned", signalData )

	//##################################################################
	// Add the dropship struct to a global list and remove it when gone
	//##################################################################

	file.dropshipStructs.append( spDropship )
	OnThreadEnd(
	function() : ( spDropship )
		{
			file.dropshipStructs.fastremovebyvalue( spDropship )
		}
	)

	if ( spDropship.dropship.HasKey( "script_sound" ) && spDropship.dropship.kv.script_sound != "" )
		EmitSoundOnEntity( spDropship.dropship, string( spDropship.dropship.kv.script_sound ) )

	//##################################################
	// Dropship flies in, signals deploy, and flies out
	//##################################################

	// Make dropship fly in, deploy, fly out
	string deployAnim = string( spDropship.dropship.kv.deploy_anim )
	bool useDeployAnim = spDropship.dropship.kv.useDeployAnim == "1"
	if ( useDeployAnim && deployAnim != "" )
	{
		// Do anim
		waitthread DropshipFlyAnimPathAndDeploy( spDropship.dropship, deployAnim, spDropship.deployPos, spDropship.deployAng )
	}
	else
	{
		waitthread DropshipFlyNodePathAndDeploy( spDropship )
	}
}

vector function GetOriginForEntOrSpawner( entity ent )
{
	if ( IsSpawner( ent ) )
	{
		table spawnerKeyValues = ent.GetSpawnEntityKeyValues()
		return StringToVector( string( spawnerKeyValues.origin ) )
	}
	else
	{
		return ent.GetOrigin()
	}
	unreachable
}

void function DropshipFlyAnimPathAndDeploy( entity dropship, string deployAnim, vector refPos, vector refAng )
{
	// Spawn a ref
	entity ref = CreateEntity( "info_target" )
	ref.SetOrigin( refPos )
	ref.SetAngles( refAng )
	DispatchSpawn( ref )

	waitthread PlayAnimTeleport( dropship, deployAnim, ref, 0 )

	if ( IsValid( ref ) )
		ref.Destroy()
}

void function DropshipFlyNodePathAndDeploy( SPDropshipStruct dropshipStruct )
{
	dropshipStruct.dropship.ClearParent()
	EndSignal( dropshipStruct.dropship, "OnDeath" )
	EndSignal( dropshipStruct.dropship, "OnDestroy" )

	entity mover = CreateOwnedScriptMover( dropshipStruct.dropship )

	mover.SetOrigin( dropshipStruct.enterNodes[0].GetOrigin() )
	mover.SetAngles( dropshipStruct.enterNodes[0].GetAngles() + REF_ANGLE_OFFSET )

 	dropshipStruct.dropship.SetOrigin( dropshipStruct.enterNodes[0].GetOrigin() )
 	dropshipStruct.dropship.SetAngles( dropshipStruct.enterNodes[0].GetAngles() + REF_ANGLE_OFFSET )

	thread PlayAnim( dropshipStruct.dropship, "dropship_VTOL_evac_idle" )

	dropshipStruct.dropship.SetParent( mover, "REF", true )

	// Fly in
	for( int i = 1 ; i <= dropshipStruct.enterNodes.len() ; i++ )
	{
		vector pos
		vector ang
		bool easeOut = false
		if ( i < dropshipStruct.enterNodes.len() )
		{
			pos = dropshipStruct.enterNodes[i].GetOrigin()
			ang = dropshipStruct.enterNodes[i].GetAngles() + REF_ANGLE_OFFSET
		}
		else
		{
			pos = dropshipStruct.deployPos
			ang = dropshipStruct.deployAng
			easeOut = true
		}

		float moveTime = Distance( mover.GetOrigin(), pos ) / DROPSHIP_FLY_SPEED
		if ( moveTime <= 0 )
			continue

		float easeTime = 0.0
		if ( easeOut )
		{
			moveTime *= 2.0
			easeTime = moveTime
		}

		mover.NonPhysicsMoveTo( pos, moveTime, 0.0, easeTime )
	//	mover.NonPhysicsRotateTo( ang, moveTime, 0.0, easeTime )
		wait moveTime
	}

	// Deploy
	if ( dropshipStruct.dropship.HasKey( "deploy_flag_wait" ) && dropshipStruct.dropship.kv.deploy_flag_wait != "" && !Flag( string( dropshipStruct.dropship.kv.deploy_flag_wait ) ) )
	{
		Signal( dropshipStruct.dropship, "ropesout" )
		FlagWait( string( dropshipStruct.dropship.kv.deploy_flag_wait ) )
	}

	Signal( dropshipStruct.dropship, "deploy" )
	wait 5

	// Fly Out
	foreach( int i, entity node in dropshipStruct.exitNodes )
	{
		vector pos = node.GetOrigin()
		vector ang = node.GetAngles() + REF_ANGLE_OFFSET

		float moveTime = Distance( mover.GetOrigin(), pos ) / DROPSHIP_FLY_SPEED
		if ( moveTime <= 0 )
			continue

		float easeTime = 0.0
		if ( i == 0 )
		{
			moveTime *= 2.0
			easeTime = moveTime
		}

		mover.NonPhysicsMoveTo( pos, moveTime, easeTime, 0.0 )
		mover.NonPhysicsRotateTo( ang, moveTime, easeTime, 0.0 )
		wait moveTime
	}

	// Warp out
	WarpoutEffect( dropshipStruct.dropship )
}

void function CalculateDeployPositions( entity spawner, vector shipDeployPos, vector shipDeployAng, array<entity> ents, array<entity> leftEnts, array<entity> rightEnts )
{
	if ( ents.len() == 0 )
		return

	Assert( leftEnts.len() == 0 )
	Assert( rightEnts.len() == 0 )

	vector shipForward = AnglesToForward( shipDeployAng )
	vector shipRight = AnglesToRight( shipDeployAng )

	array<entity> tempEntsLeft
	array<entity> tempEntsRight

	foreach( entity ent in ents )
	{
		vector vecToDeploy = Normalize( GetOriginForEntOrSpawner( ent ) - shipDeployPos )
		if ( DotProduct( shipRight, vecToDeploy ) > 0 )
			tempEntsRight.append( ent )
		else
			tempEntsLeft.append( ent )
	}

	// Sort by furthest forward
	tempEntsLeft = SortEntsByFarthestForward( shipDeployPos, shipForward, tempEntsLeft )
	tempEntsRight = SortEntsByFarthestForward( shipDeployPos, shipForward, tempEntsRight )

	array<int> attachOrder = GetAttachOrderForDropshipType( spawner )
	foreach( int i in attachOrder )
	{
		if ( i < tempEntsLeft.len() )
			leftEnts.append( tempEntsLeft[ i ] )
		if ( i < tempEntsRight.len() )
			rightEnts.append( tempEntsRight[ i ] )
	}
}

array<entity> function SortEntsByFarthestForward( vector origin, vector forward, array<entity> sortEnts )
{
	array<entity> sortedEnts
	array<entity> entsToSort = clone sortEnts

	entity farthestEnt
	while( entsToSort.len() > 0 )
	{
		farthestEnt = null
		float farthestDist
		foreach( entity ent in entsToSort )
		{
			float distanceForward = DistanceAlongVector( GetOriginForEntOrSpawner( ent ), origin, forward )
			if ( distanceForward > farthestDist || !IsValid( farthestEnt ) )
			{
				farthestEnt = ent
				farthestDist = distanceForward
			}
		}
		Assert( IsValid( farthestEnt ) )
		sortedEnts.append( farthestEnt )
		entsToSort.fastremovebyvalue( farthestEnt )
	}
	Assert( entsToSort.len() == 0 )
	Assert( sortedEnts.len() == sortEnts.len() )

	return sortedEnts
}

array<int> function GetAttachOrderForDropshipType( entity spawner )
{
	array<int> attachOrder

	table spawnerKeyValues = spawner.GetSpawnEntityKeyValues()
	Assert( "editorclass" in spawnerKeyValues )

	switch( string( spawnerKeyValues.editorclass ) )
	{
		case "npc_dropship_soldiers":
			attachOrder = [ 0, 2, 1 ]
			break
		case "npc_dropship_widow":
			attachOrder = [ 2, 11, 5, 14, 0, 9, 4, 15, 7, 12, 1, 8, 6, 13, 3, 10 ]
			break
	}

	return attachOrder
}