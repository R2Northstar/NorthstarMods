untyped

global function SPDropship_Widow_Init
global function InitSPDropShipWidowSpawner
global function SpawnWidowDropship

const DROPSHIP_HEALTH = 7800
const WIDOW_SPECTRE_RACK_MODEL = $"models/commercial/rack_spectre_wall.mdl"
const WIDOW_DEPLOY_LAND_GROUND_HEIGHT = 128 * 128

struct WidowTag
{
	string tagName
	int deployPosIndex
}

struct WidowDeployNPC
{
	entity ship
	entity npc
	entity animRef
	string animAttachment
	string idleAnim
	vector landingPos
}

function SPDropship_Widow_Init()
{
	PrecacheModel( WIDOW_SPECTRE_RACK_MODEL )
}

void function InitSPDropShipWidowSpawner( DropShipSpawnerData data )
{
}

void function SpawnWidowDropship( entity shipSpawner, SPDropshipStruct spDropship )
{
	entity widow = spDropship.dropship

	//AddEntityCallback_OnKilled( spDropship.dropship, OnDropshipKilled )

	thread TempWidowDoorOpenAnim( widow )

	//#########################
	// Set up attachments info
	//#########################

	array<WidowTag> widowTagDataLeft
	array<WidowTag> widowTagDataRight
	for( int i = 1 ; i < 9 ; i++ )
	{
		WidowTag data1
		data1.tagName = "ATTACH_L_BOT_SEAT_" + i
		data1.deployPosIndex = widowTagDataLeft.len()
		widowTagDataLeft.append( data1 )

		WidowTag data2
		data2.tagName = "ATTACH_L_TOP_SEAT_" + i
		data2.deployPosIndex = widowTagDataLeft.len()
		widowTagDataLeft.append( data2 )

		WidowTag data3
		data3.tagName = "ATTACH_R_BOT_SEAT_" + i
		data3.deployPosIndex = widowTagDataRight.len()
		widowTagDataRight.append( data3 )

		WidowTag data4
		data4.tagName = "ATTACH_R_TOP_SEAT_" + i
		data4.deployPosIndex = widowTagDataRight.len()
		widowTagDataRight.append( data4 )
	}

	//############################
	// Calculate deploy positions
	//############################

	float maxRadius = 400
	vector forward = AnglesToForward( spDropship.deployAng )
	vector right = AnglesToRight( spDropship.deployAng )
	vector groundOrigin = OriginToGround( widow.GetOrigin() + <0,0,1> )
	vector groundOriginLeft = groundOrigin + ( right * -550 )
	vector groundOriginRight = groundOrigin + ( right * 550 )

	array<vector> randomSpotsLeft = NavMesh_RandomPositions( groundOriginLeft, HULL_HUMAN, widowTagDataLeft.len(), 0, maxRadius )
	Assert( randomSpotsLeft.len() == widowTagDataLeft.len() )
	array<vector> randomSpotsRight = NavMesh_RandomPositions( groundOriginRight, HULL_HUMAN, widowTagDataRight.len(), 0, maxRadius )
	Assert( randomSpotsRight.len() == widowTagDataRight.len() )

	randomSpotsLeft = SortVectorsByFarthestForward( groundOrigin, forward, randomSpotsLeft )
	randomSpotsRight = SortVectorsByFarthestForward( groundOrigin, forward, randomSpotsRight )

	if ( DROPSHIP_DEBUG_LINES )
	{
		DebugDrawCircle( groundOriginLeft, <0,0,0>, maxRadius, 255, 255, 0, true, 20.0 )
		DebugDrawCircle( groundOriginRight, <0,0,0>, maxRadius, 0, 255, 255, true, 20.0 )

		foreach( int i, vector spot in randomSpotsLeft )
			DebugDrawText( spot, i.tostring(), true, 30.0 )
		foreach( int i, vector spot in randomSpotsRight )
			DebugDrawText( spot, i.tostring(), true, 30.0 )
	}

	//##############
	// Set up racks
	//##############

	array<entity> racksLeft
	array<entity> racksRight
	for ( int i = 0 ; i < widowTagDataLeft.len() + widowTagDataRight.len() ; i++ )
	{
		string tag
		if ( i < widowTagDataLeft.len() )
			tag = widowTagDataLeft[i].tagName
		else
			tag = widowTagDataRight[i - widowTagDataLeft.len()].tagName

		int attachID = widow.LookupAttachment( tag )
		vector pos = widow.GetAttachmentOrigin( attachID )
		vector ang = widow.GetAttachmentAngles( attachID )

		entity rack = CreatePropDynamic( WIDOW_SPECTRE_RACK_MODEL, spDropship.deployPos, spDropship.deployAng )
		rack.SetParent( widow, tag, false )

		if ( i < widowTagDataLeft.len() )
			racksLeft.append( rack )
		else
			racksRight.append( rack )
	}

	array<int> attachOrder = GetAttachOrderForDropshipType( spDropship.spawner )
	int nextTagIndexLeft = 0
	int nextTagIndexRight = 0

	for ( int i = 0 ; i < spDropship.ridersLeft.len() + spDropship.ridersRight.len() ; i++ )
	{
		entity guy
		string tag
		vector landingPos

		if ( i < spDropship.ridersLeft.len() )
		{
			int tagIndex = attachOrder[ nextTagIndexLeft ]
			nextTagIndexLeft++

			guy = spDropship.ridersLeft[ i ]
			tag = widowTagDataLeft[tagIndex].tagName
			landingPos = randomSpotsLeft[ widowTagDataLeft[tagIndex].deployPosIndex ]
		}
		else
		{
			int tagIndex = attachOrder[ nextTagIndexRight ]
			nextTagIndexRight++

			guy = spDropship.ridersRight[ i - spDropship.ridersLeft.len() ]
			tag = widowTagDataRight[tagIndex].tagName
			landingPos = randomSpotsRight[ widowTagDataRight[tagIndex].deployPosIndex ]
		}

		int attachID = widow.LookupAttachment( tag )
		vector pos = widow.GetAttachmentOrigin( attachID )
		vector ang = widow.GetAttachmentAngles( attachID )

		guy.SetParent( widow, tag, false )

		WidowDeployNPC deployData
		deployData.ship = widow
		deployData.npc = guy
		deployData.animAttachment = tag
		deployData.idleAnim = "st_widow_spawner_rackidle"
		deployData.landingPos = landingPos

		//if ( DROPSHIP_DEBUG_LINES )
		//{
			//DebugDrawText( pos, deployPosIndex.tostring(), true, 20.0 )
			//DebugDrawLine( pos, deployPos, 255, 0, 0, true, 20.0 )
		//}

		thread WidowNPCThink( deployData )
	}
}

void function WidowNPCThink( WidowDeployNPC deployData )
{
	EndSignal( deployData.npc, "OnDeath" )
	EndSignal( deployData.ship, "OnDeath" )

	//DebugDrawLine( deployData.npc.GetOrigin(), deployData.landingPos, 255, 0, 0, true, 100 )

	// Ride in the ship
	thread PlayAnimTeleport( deployData.npc, deployData.idleAnim, deployData.ship, deployData.animAttachment )

	// Wait for deploy
	WaitSignal( deployData.ship, "deploy" )

	// Random scatter deploy times
	wait RandomFloatRange( 0.0, 1.0 )

	//float jumpDist = Distance( FlattenVector( deployData.npc.GetOrigin() ), FlattenVector( deployData.landingPos ) )

	// Jump out of the ship
	deployData.npc.ClearParent()
	PlayAnimTeleport( deployData.npc, "st_widow_spawner_leap_short", deployData.ship, deployData.animAttachment )

	/*
	string deployAnim = "st_widow_spawner_leap"
	if ( jumpDist > 400 )
		deployAnim = "st_widow_spawner_leap_long"
	*/

	deployData.npc.Anim_Stop()
	deployData.npc.ClearParent()

	// Calculate jump velocity
	float jumpDist = Distance( FlattenVector( deployData.npc.GetOrigin() ), FlattenVector( deployData.landingPos ) )
	float distToLanding = Distance( deployData.npc.GetOrigin(), deployData.landingPos )
	float fallDuration = distToLanding / 600
	vector jumpVelocity = GetVelocityForDestOverTime( deployData.npc.GetOrigin(), deployData.landingPos, fallDuration )

	// Once jump anim is done we loop a fall idle and push the NPC towards it's landing position
	thread PlayAnimGravity( deployData.npc, "st_widow_spawner_fall" )
	deployData.npc.SetVelocity( jumpVelocity )

	while( true )
	{
		if ( deployData.npc.IsOnGround() )
			break
		if ( DistanceSqr( deployData.npc.GetOrigin(), OriginToGround( deployData.npc.GetOrigin() + <0,0,1> ) ) <= WIDOW_DEPLOY_LAND_GROUND_HEIGHT )
			break
		WaitFrame()
	}

	// Land anim
	//deployData.npc.Anim_Stop()
	//deployData.npc.ClearParent()
	PlayAnimGravity( deployData.npc, "st_widow_spawner_land" )
	deployData.npc.SetVelocity( <0,0,-200> )
}

void function TempWidowDoorOpenAnim( entity widow )
{
	EndSignal( widow, "OnDeath" )

	widow.Anim_Play( "wd_flying_idle" )
	WaitSignal( widow, "deploy" )
	widow.Anim_Play( "wd_doors_open_idle" )
}

array<vector> function SortVectorsByFarthestForward( vector origin, vector forward, array<vector> sortVecs )
{
	array<vector> sortedVecs
	array<vector> vecsToSort = clone sortVecs

	vector ornull farthestVec
	while( vecsToSort.len() > 0 )
	{
		farthestVec = null
		float farthestDist
		foreach( vector vec in vecsToSort )
		{
			float distanceForward = DistanceAlongVector( vec, origin, forward )
			if ( distanceForward > farthestDist || farthestVec == null )
			{
				farthestVec = vec
				farthestDist = distanceForward
			}
		}
		Assert( farthestVec != null )
		sortedVecs.append( expect vector( farthestVec ) )
		vecsToSort.fastremovebyvalue( farthestVec )
	}
	Assert( vecsToSort.len() == 0 )
	Assert( sortedVecs.len() == sortVecs.len() )

	return sortedVecs
}