global const int DEV_DRAWEDGENODES 	= 0
global const int DEV_DRAWEDGES 		= 0
global const int DEV_DRAWSHIPHULL	= 0

global const int DEV_DRAWCHASELOGIC	= 1
global const int DEV_DRAWMOVETOPOS	= 1
global const int DEV_DRAWGOALRADIUS = 1
global const int DEV_DRAWBANKING 	= 1

global const int DEV_PRINTSPEED		= 0
global const int DEV_PRINTONBOARD 	= 0
global const int DEV_PRINTBEHAVIOR 	= 1

global const int DEV_DRAWDEPLOY 	= 0
global const int DEV_DRAWWORLDEDGE 	= 1
global const int DEV_DRAWSKYRIG 	= 1

global const int DEV_SPHERE_SEGMENTS = 12

global function S2S_CommonInit
global function ShipTemplateSetup
global function ShipCommonFuncs
global function AddShipEventCallback
global function ShipEventExists
global function ClearShipEventCallback
global function ClearShipEventEntirely
global function ClearAllShipEventCallbacks
global function ResetEventCallbackToDefault
global function ResetAllEventCallbacksToDefault
global function RunShipEventCallbacks
global function PlayerSetNextShip
global function PlayerClearNextShip
global function PlayerGetNextShip

global function IsDoorClosedOrClosing
global function IsDoorOpenOrOpening
global function IsShipOnBattleField

//api
global function SetSpawnDelay
global function GetSpawnDelay
global function SetSquadDelay
global function GetSquadDelay
global function SetSquadSize
global function GetSquadSize
global function SetDeployPos
global function GetDeployPos
global function SetDeployShip
global function GetDeployShip
global function SetNPCDeployFunc
global function DeployFuncWrapper

//local space concepts
global function CLVec
global function GetOriginLocal
global function SetOriginLocal
global function NonPhysicsMoveToLocal
global function GetVelocityLocal
global function SetVelocityLocal
global function WorldToLocalOrigin
global function LocalToWorldOrigin
global function WorldToLocalVelocity
global function LocalToWorldVelocity
global function UpdatePosWithLocalSpace

//utility
global function ShipSetInvulnerable
global function ShipClearInvulnerable
global function ShipIsInvulnerable
global function ShipSetIgnoreMe
global function FakeDestroy
global function GetFreeTemplate
global function RecursivePropParenter
global function GetBestRightOfTargetForLeaving

global function DrawShipEdges
global function DrawShipEdgeNodes
global function DevPrints

global const int MAXHEALTH = 524000
global const float VOBUFFER = 10
global const int ONSHIPLISTMAX = 12
global const vector CONVOYDIR = <0,90,0>
global const float ROT_DELAY = 1.0

global const asset WIDOW_MODEL = $"models/vehicle/widow/widow.mdl"
global const float FRAME_INTERVAL = 0.1
global const vector INVALID_LOCALORIGIN = < 99999.9, 99999.9, 99999.9 >
global const float SHIPGOALRADIUS = 100.0



global enum eDoorState
{
	CLOSED
	OPEN
	OPEN_L
	OPEN_R
	OPENING
	OPENING_L
	OPENING_R
	CLOSING
	CLOSING_L
	CLOSING_R
}

global enum eShipEvents
{
	NONE

	PLAYER_ONHULL_START
	PLAYER_ONHULL_END
	PLAYER_INCABIN_START
	PLAYER_INCABIN_END

	SHIP_NEWENEMY
	SHIP_PREPNEWEDGE
	SHIP_ATNEWEDGE
	SHIP_ATDEPLOYPOS
	SHIP_ATDEPLOYPOSZIP
	SHIP_ONCLOSEDOOR
	SHIP_ONOPENDOOR
	SHIP_ENGINEFAILURE
	SHIP_PILOTKILLED
	SHIP_DEATH

	//always last one
	NUM_EVENTS
}

global enum eBehavior
{
	//standards
	DOPREVIOUS = -2
	INVALID
	NONE
	IDLE 				//1
	CUSTOM
	ENEMY_CHASE
	ENEMY_ONBOARD
	ENGINE_FAILURE 		//5
	DEPLOY
	DEPLOYZIP
	DEATH_ANIM
	CREW_DEAD
	CREW_DEPLOYED		//10
	LEAVING

	//always last one
	NUM_BEHAVIORS
}

global enum eLiftState
{
	LOCKED
	MOVING
	TOP
	BOTTOM
}

global struct LocalVec
{
	vector v = INVALID_LOCALORIGIN
}

global struct LiftStruct
{
	entity hatch
	entity clip
	entity separator
	entity lift
	entity useTrigger
	entity doorTopL
	entity doorTopR
	entity doorBotL
	entity doorBotR
	entity doorBotC
	entity doorBotS
	entity doorTopC
	entity doorTopS

	entity downPos
	entity upPos
	entity openTopL
	entity openTopR
	entity openBotL
	entity openBotR
	entity openBotC
	entity openBotS
	entity openTopC
	entity openTopS
	entity closeBotC
	entity closeBotS
	entity closeTopC
	entity closeTopS

	int liftState = eLiftState.LOCKED
	float travelTime
}

global struct HullTurret
{
	entity turret
	entity downPos
	entity upPos
	entity shellEject
	int turretState = eDoorState.CLOSED
}

global struct ShipStruct
{
	/******************************\
				common
	\******************************/
	bool free = true
	entity model
	entity mover
	entity triggerTop
	entity cabinTriggerInterior
	entity exteriorClip
	vector templateOrigin
	entity triggerFallingDeath

	//DEV ONLY
	vector DEV_hullSize 	= <0,0,0>
	vector DEV_hullOffset 	= <0,0,0>
	int bug_reproNum = 1

	//behaviors
	table <int, void functionref( ShipStruct )> behaviorTable
	void functionref( ShipStruct, int ) defaultBehaviorFunc
	void functionref( ShipStruct ) customBehaviorFunc
	int behavior 				= eBehavior.IDLE
	array<int> prevBehavior 	= [ eBehavior.IDLE ]
	int doorState 				= eDoorState.CLOSED
	entity 	chaseEnemy
	vector[eBehavior.NUM_BEHAVIORS] flyBounds
	vector[eBehavior.NUM_BEHAVIORS] flyOffset
	float[eBehavior.NUM_BEHAVIORS] 	seekAhead
	float minChasePoint = -16384
	float maxChasePoint = 16384
	float boundsMinRatio
	entity customEnt
	vector customPos
	vector customAng

	//destination
	float 		goalRadius
	LocalVec 	goalPos

	//event callbacks
	table <int, array<void functionref( ShipStruct, entity, int )> > eventTable
	void functionref( ShipStruct, int ) defaultEventFunc

	//deploying troops
	vector deployPos
	ShipStruct ornull deployShip
	void functionref( entity ) ornull deployFunc = null
	float[eBehavior.NUM_BEHAVIORS] spawnMinDelay
	float[eBehavior.NUM_BEHAVIORS] spawnMaxDelay
	float[eBehavior.NUM_BEHAVIORS] squadMinDelay
	float[eBehavior.NUM_BEHAVIORS] squadMaxDelay
	int[eBehavior.NUM_BEHAVIORS] squadSize

	//movement
	bool allowCrossHull = true
	float crossHullHeight = 900
	float crossHullBufferTime = 35 //wait this long since the last new edge before looking for a better
	LocalVec localVelocity
	float rollMax
	float pitchMax
	float defRollMax
	float defPitchMax
	float fullBankTime
	float defBankTime = 1.5 //good for goblins and widows
	float accMax
	float defAccMax
	float speedMax
	float defSpeedMax
	float functionref( float ) FuncGetBankMagnitude

	/******************************\
			Goblin Specific
	\******************************/
	array<entity> guys
	entity pilot

	bool 	engineDamage = false
	string 	engineDamageTag = "R_exhaust_rear_2"
	bool 	allowShoot 	= true
	entity 	cockpit
	entity 	npcClip

	entity interiorDoorR
	entity interiorDoorL

	array<entity> zipLineNodes //hand picked nodes for ziplines

	/******************************\
			widow specific
	\******************************/
	array<entity> spectreRacksL
	array<entity> spectreRacksR

	/******************************\
			large ship specific
	\******************************/
	array<entity> leftEdge
	array<entity> rightEdge
	table<string, array<LiftStruct> > lifts
	entity skyboxModel
}

global struct EdgeData
{
	ShipStruct& onShip
	vector forward
	vector right
	vector up

	array<entity> edgeArray
	float rightOfTarget
	float timeGetPlayerPos
	vector deltaLKP
}

global entity WORLD_CENTER
global float S2S_VOtime
global struct EntityLevelStruct
{
	//
	float customZiplineDeployTime = 0.0
	float customZiplineRideTime = 0.0
	string customZiplineDeploySignal = ""

	//for the player ( maybe bt as well )
	ShipStruct ornull onShip = null
	ShipStruct ornull onNextShip = null
	ShipStruct ornull [ONSHIPLISTMAX] onShipList

	LocalVec localSpaceOrigin
	float 	lastMoveToTime = -1.0
	float 	skyboxScale = 1.0
	vector 	skyboxOffset = <0,0,0>
}

void function S2S_CommonInit()
{
	RegisterSignal( "FakeDeath" )
	RegisterSignal( "FakeDestroy" )
	RegisterSignal( "PlayerOnBoard" )
	RegisterSignal( "PlayerOffBoard" )
	RegisterSignal( "NewBehavior" )
	RegisterSignal( "engineFailure" )
	RegisterSignal( "returnToPrevBehavior" )
	RegisterSignal( "engineFailure_Complete" )
	RegisterSignal( "pilotDead" )
	RegisterSignal( "crewDead" )
	RegisterSignal( "crewDeployed" )
	RegisterSignal( "DoorsOpening" )
	RegisterSignal( "DoorsOpened" )
	RegisterSignal( "DoorsClosing" )
	RegisterSignal( "DoorsClosed" )
	RegisterSignal( "Goal" )
	RegisterSignal( "SetMaxSpeed" )
	RegisterSignal( "SetMaxAcc" )
	RegisterSignal( "SetMaxPitch" )
	RegisterSignal( "SetMaxRoll" )
	RegisterSignal( "SetBankTime" )
	RegisterSignal( "UpdateingLocalSpace" )

	AddCallback_EntitiesDidLoad( EntitiesDidLoad )
}

struct
{

}file

void function EntitiesDidLoad()
{
	WORLD_CENTER = CreateScriptMover( <0,0,0>, CONVOYDIR )
}

/************************************************************************************************\

███████╗███████╗████████╗██╗   ██╗██████╗
██╔════╝██╔════╝╚══██╔══╝██║   ██║██╔══██╗
███████╗█████╗     ██║   ██║   ██║██████╔╝
╚════██║██╔══╝     ██║   ██║   ██║██╔═══╝
███████║███████╗   ██║   ╚██████╔╝██║
╚══════╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝

\************************************************************************************************/
ShipStruct function ShipTemplateSetup( entity model, vector ornull hackOffset = null, void functionref( ShipStruct, entity, entity ) ornull linkFunc = null )
{
	//HACK: Must do this because depending on how the model is rigged -- if it has an ORIGIN attachment, where that ORIGIN attachment is
	//		in relation to the origin of the export from maya, etc -- it shows up differently in game than it does in levelED
	if ( hackOffset == null )
		hackOffset = <0,0,0>
	expect vector( hackOffset )
	model.SetOrigin( model.GetOrigin() + hackOffset )

	ShipStruct ship
	ship.model = model
	if ( model.GetTeam() != TEAM_MILITIA )
		SetTeam( model, TEAM_IMC )

	entity mover
	if ( model.GetClassName() != "script_mover" )
	{
		mover = CreateScriptMover( model.GetOrigin(), model.GetAngles() )
		ship.mover = mover
		ship.model.SetParent( mover )
	}
	else
	{
		mover = model
		ship.mover = model
	}

	mover.DisableHibernation()

	ship.templateOrigin = mover.GetOrigin()
	ship.model.Hide()

	//various parts
	array<entity> linkedEnts = model.GetLinkEntArray()

	foreach( entity ent in linkedEnts )
	{
		SetTeam( ent, TEAM_IMC )
		ent.SetParent( model, "ORIGIN", true )
		ent.DontIncludeParentBbox()
		ent.MarkAsNonMovingAttachment()

		switch( ent.kv.script_noteworthy )
		{
			case "parent":
				//do nothing...already parented
				break

			case "levelEdRotator":
				//HACK -> why do I have to do this???
				thread ScriptedRotatorRotate( ent.GetAngles() + Vector(0,-90,0), ent )
				break

			case "clip":
				ship.exteriorClip = ent
				break

			case "TriggerTop":
				ship.triggerTop = ent
				break

			case "CabinTriggerInterior":
				ship.cabinTriggerInterior = ent
				break

			case "prop":
			case "solidprop":
				RecursivePropParenter( model, ent )
				break

			case "ship_edge":
				CapitalShipTemplateBuildEdge( ship, ent )
				break

			case "fallingDeathTrigger":
				ship.triggerFallingDeath = ent
				thread EndFrameDisable( ent )
				break

			default:
				if ( !IsValid( linkFunc ) )
					Assert( 0, "linked template ent missing valid script_noteworthy" )

				expect void functionref( ShipStruct, entity, entity )( linkFunc )
				linkFunc( ship, mover, ent )
				break
		}
	}

	mover.SetPusher( true )
	return ship
}

//hack - for whatever reason triggers get enabled on the first frame
void function EndFrameDisable( entity ent )
{
	WaitEndFrame()
	ent.Disable()
}

void function RecursivePropParenter( entity model, entity prop )
{
	//prop.SetPusher( false )

	array<entity> linkedEnts = prop.GetLinkEntArray()
	foreach( entity ent in linkedEnts )
	{
		SetTeam( ent, TEAM_IMC )
		ent.SetParent( model, "", true )
		ent.MarkAsNonMovingAttachment()
		RecursivePropParenter( model, ent )
	}
}

void function CapitalShipTemplateBuildEdge( ShipStruct ship, entity edgeNode )
{
	edgeNode.SetParent( ship.model, "", true )

	vector dir 		= edgeNode.GetOrigin() - ship.model.GetOrigin()
	vector right 	= ship.model.GetRightVector()

	bool new = false
	if ( DotProduct( dir, right ) > 0 )
	{
		if ( !ship.rightEdge.contains( edgeNode ) )
		{
			ship.rightEdge.append( edgeNode )
			new = true
		}
	}
	else if ( !ship.leftEdge.contains( edgeNode ) )
	{
		ship.leftEdge.append( edgeNode )
		new = true
	}

	if ( !new )
		return

	array<entity> linkedEnts = edgeNode.GetLinkEntArray()
	foreach( entity ent in linkedEnts )
		CapitalShipTemplateBuildEdge( ship, ent )
}

void function ShipCommonFuncs( ShipStruct ship )
{
	ship.free = false
	ship.model.Show()
	ship.localVelocity.v = <0,0,0>
	ship.goalRadius = SHIPGOALRADIUS
	ship.boundsMinRatio = 0.5

	ResetAllEventCallbacksToDefault( ship )
	ResetAllBehaviorsToDefault( ship )
	ship.behavior 		= eBehavior.IDLE
	ship.prevBehavior 	= [ eBehavior.IDLE ]
	ship.doorState 		= eDoorState.CLOSED
	ship.deployShip 	= null
	ship.deployFunc 	= null
	ship.allowCrossHull = true
	ship.zipLineNodes	= []

	thread ShipTopTriggerThink( ship )
	if ( IsValid( ship.cabinTriggerInterior ) )
		thread ShipCabinInteriorThink( ship )
	thread RunBehaviorFiniteStateMachine( ship )

	ResetMaxSpeed( ship )
	ResetMaxAcc( ship )
	ResetMaxRoll( ship )
	ResetMaxPitch( ship )
	ResetBankTime( ship )

	#if DEV
		if ( DEV_DRAWEDGES && GetBugReproNum() == ship.bug_reproNum )
			thread DrawShipEdges( ship )
		if ( DEV_DRAWEDGENODES && GetBugReproNum() == ship.bug_reproNum )
			thread DrawShipEdgeNodes( ship )
		if ( GetBugReproNum() == ship.bug_reproNum )
			thread DevPrints( ship )
	#endif
}

/************************************************************************************************\

███████╗██╗   ██╗███████╗███╗   ██╗████████╗     ██████╗ █████╗ ██╗     ██╗     ██████╗  █████╗  ██████╗██╗  ██╗███████╗
██╔════╝██║   ██║██╔════╝████╗  ██║╚══██╔══╝    ██╔════╝██╔══██╗██║     ██║     ██╔══██╗██╔══██╗██╔════╝██║ ██╔╝██╔════╝
█████╗  ██║   ██║█████╗  ██╔██╗ ██║   ██║       ██║     ███████║██║     ██║     ██████╔╝███████║██║     █████╔╝ ███████╗
██╔══╝  ╚██╗ ██╔╝██╔══╝  ██║╚██╗██║   ██║       ██║     ██╔══██║██║     ██║     ██╔══██╗██╔══██║██║     ██╔═██╗ ╚════██║
███████╗ ╚████╔╝ ███████╗██║ ╚████║   ██║       ╚██████╗██║  ██║███████╗███████╗██████╔╝██║  ██║╚██████╗██║  ██╗███████║
╚══════╝  ╚═══╝  ╚══════╝╚═╝  ╚═══╝   ╚═╝        ╚═════╝╚═╝  ╚═╝╚══════╝╚══════╝╚═════╝ ╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚══════╝

\************************************************************************************************/
void function AddShipEventCallback( ShipStruct ship, int eventID, void functionref( ShipStruct, entity, int ) callbackFunc )
{
	table <int, array<void functionref( ShipStruct, entity, int )> > eventTable = ship.eventTable

	if ( ! ( eventID in eventTable ) )
		eventTable[ eventID ] <- []

	Assert( !eventTable[ eventID ].contains( callbackFunc ), "Already added " + string( callbackFunc ) + " with AddShipEventCallback for ship " + ship.model )
	eventTable[ eventID ].append( callbackFunc )
}

void function ClearShipEventCallback( ShipStruct ship, int eventID, void functionref( ShipStruct, entity, int ) callbackFunc )
{
	table <int, array<void functionref( ShipStruct, entity, int )> > eventTable = ship.eventTable

	Assert( eventID in eventTable, "Event " + eventID + " does not exist for ship " + ship.model )
	Assert( eventTable[ eventID ].contains( callbackFunc ), "function " + string( callbackFunc ) + " does not exist for ship " + ship.model )

	int index = -1
	foreach ( int idx, void functionref( ShipStruct, entity, int ) func in eventTable[ eventID ] )
	{
		if ( func == callbackFunc )
		{
			index = idx
			break
		}
	}

	if ( index != -1 )
		eventTable[ eventID ].remove( index )
}

void function ClearShipEventEntirely( ShipStruct ship, int eventID )
{
	table <int, array<void functionref( ShipStruct, entity, int )> > eventTable = ship.eventTable

	Assert( eventID in eventTable, "Event " + eventID + " does not exist for ship " + ship.model )

	delete eventTable[ eventID ]
}

bool function ShipEventExists( ShipStruct ship, int eventID )
{
	table <int, array<void functionref( ShipStruct, entity, int )> > eventTable = ship.eventTable

	return ( eventID in eventTable )
}

void function ClearAllShipEventCallbacks( ShipStruct ship )
{
	ship.eventTable = {}
}

void function ResetEventCallbackToDefault( ShipStruct ship, int eventID )
{
	if ( ShipEventExists( ship, eventID ) )
		ClearShipEventEntirely( ship, eventID )

	ship.defaultEventFunc( ship, eventID )
}

void function ResetAllEventCallbacksToDefault( ShipStruct ship )
{
	ClearAllShipEventCallbacks( ship )

	for ( int eventID = 0; eventID < eShipEvents.NUM_EVENTS; eventID++ )
		ResetEventCallbackToDefault( ship, eventID )
}

void function RunShipEventCallbacks( ShipStruct ship, int eventID, entity player = null )
{
	table <int, array<void functionref( ShipStruct, entity, int )> > eventTable = ship.eventTable
	if ( ! ( eventID in eventTable ) )
		return

	foreach ( void functionref( ShipStruct, entity, int ) callbackfunc in eventTable[ eventID ] )
		thread callbackfunc( ship, player, eventID )
}

/************************************************************************************************\

███╗   ██╗██████╗  ██████╗    ███████╗████████╗██╗   ██╗███████╗███████╗
████╗  ██║██╔══██╗██╔════╝    ██╔════╝╚══██╔══╝██║   ██║██╔════╝██╔════╝
██╔██╗ ██║██████╔╝██║         ███████╗   ██║   ██║   ██║█████╗  █████╗
██║╚██╗██║██╔═══╝ ██║         ╚════██║   ██║   ██║   ██║██╔══╝  ██╔══╝
██║ ╚████║██║     ╚██████╗    ███████║   ██║   ╚██████╔╝██║     ██║
╚═╝  ╚═══╝╚═╝      ╚═════╝    ╚══════╝   ╚═╝    ╚═════╝ ╚═╝     ╚═╝

\************************************************************************************************/
void function SetSpawnDelay( ShipStruct ship, int behavior, float spawnMinDelay, float spawnMaxDelay = -1 )
{
	ship.spawnMinDelay[ behavior ] = spawnMinDelay
	ship.spawnMaxDelay[ behavior ] = spawnMaxDelay
}

float function GetSpawnDelay( ShipStruct ship, int behavior )
{
	if ( ship.spawnMaxDelay[ behavior ] == -1 )
		return ship.spawnMinDelay[ behavior ]

	return RandomFloatRange( ship.spawnMinDelay[ behavior ], ship.spawnMaxDelay[ behavior ] )
}

void function SetSquadDelay( ShipStruct ship, int behavior, float squadMinDelay, float squadMaxDelay = -1 )
{
	ship.squadMinDelay[ behavior ] = squadMinDelay
	ship.squadMaxDelay[ behavior ] = squadMaxDelay
}

float function GetSquadDelay( ShipStruct ship, int behavior )
{
	if ( ship.squadMaxDelay[ behavior ] == -1 )
		return ship.squadMinDelay[ behavior ]

	return RandomFloatRange( ship.squadMinDelay[ behavior ], ship.squadMaxDelay[ behavior ] )
}

void function SetSquadSize( ShipStruct ship, int behavior, int squadSize )
{
	ship.squadSize[ behavior ] = squadSize
}

int function GetSquadSize( ShipStruct ship, int behavior )
{
	return ship.squadSize[ behavior ]
}

void function SetDeployPos( ShipStruct ship, vector pos )
{
	ship.deployPos = pos
}

vector function GetDeployPos( ShipStruct ship )
{
	return ship.deployPos
}

void function SetDeployShip( ShipStruct ship, ShipStruct deployShip )
{
	ship.deployShip = deployShip
}

ShipStruct ornull function GetDeployShip( ShipStruct ship )
{
	return ship.deployShip
}

void function SetNPCDeployFunc( ShipStruct ship, void functionref( entity ) deployFunc )
{
	ship.deployFunc = deployFunc
}

void function DeployFuncWrapper( ShipStruct ship, entity guy )
{
	void functionref( entity ) ornull deployFunc = ship.deployFunc
	if ( !IsValid( deployFunc ) )
		return

	expect void functionref( entity )( deployFunc )
	thread deployFunc( guy )
}

/************************************************************************************************\

 ██████╗ ███╗   ██╗██████╗  ██████╗  █████╗ ██████╗ ██████╗
██╔═══██╗████╗  ██║██╔══██╗██╔═══██╗██╔══██╗██╔══██╗██╔══██╗
██║   ██║██╔██╗ ██║██████╔╝██║   ██║███████║██████╔╝██║  ██║
██║   ██║██║╚██╗██║██╔══██╗██║   ██║██╔══██║██╔══██╗██║  ██║
╚██████╔╝██║ ╚████║██████╔╝╚██████╔╝██║  ██║██║  ██║██████╔╝
 ╚═════╝ ╚═╝  ╚═══╝╚═════╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝

\************************************************************************************************/
void function ShipTopTriggerThink( ShipStruct ship )
{
	ship.model.EndSignal( "OnDestroy" )
	EndSignal( ship, "FakeDestroy" )

	entity player
	entity mover = ship.mover
	entity trigger = ship.triggerTop
	trigger.Enable()

	table result
	while( 1 )
	{
		if ( !trigger.IsTouched() )
		{
			result = trigger.WaitSignal( "OnStartTouch" )
			player = expect entity( result.activator )
		}
		else
		{
			player = trigger.GetTouchingEntities()[0]
		}

		Assert( player.IsPlayer() )

		PlayerOnShip( player, ship, ship.cabinTriggerInterior )

		RunShipEventCallbacks( ship, eShipEvents.PLAYER_ONHULL_START, player )

		while ( trigger.IsTouched() )
		{
			trigger.WaitSignal( "OnEndTouchAll" )
			wait 0.5 //make sure
		}

		PlayerOffShip( player, ship, ship.cabinTriggerInterior )

		RunShipEventCallbacks( ship, eShipEvents.PLAYER_ONHULL_END, player )
	}
}

void function PlayerOnShip( entity player, ShipStruct ship, entity trigger )
{
	ShipSetIgnoreMe( ship, true )

	if ( IsValid( trigger ) )
		trigger.Disable()

	player.l.onShip = ship
	if ( IsValid( player.l.onNextShip ) && expect ShipStruct( player.l.onNextShip ) == ship )
		player.l.onNextShip = null

	ShipStruct ornull prevShip = player.l.onShipList[0]

	if ( IsValid( prevShip ) )
	{
		expect ShipStruct( prevShip )
		if ( prevShip != ship )
			Signal( prevShip, "PlayerOffBoard" )
	}
	#if DEV
		if( DEV_PRINTONBOARD && GetBugReproNum() == ship.bug_reproNum )
		{
			if ( IsValid( prevShip ) )
				printt( "player On: " + ship.model + ", prev onShip = " + expect ShipStruct( prevShip ).model )
			else
				printt( "player On: " + ship.model + ", prev onShip = NULL" )
		}
	#endif
	PushShipList( player, ship )
	Signal( ship, "PlayerOnBoard" )
}

void function PlayerOffShip( entity player, ShipStruct ship, entity trigger )
{
	ShipSetIgnoreMe( ship, false )

	if ( player.l.onShip == ship )
		player.l.onShip = null

	#if DEV
		if( DEV_PRINTONBOARD && GetBugReproNum() == ship.bug_reproNum )
		{
			if ( IsValid( player.l.onShip ) )
				printt( "player OFF: " + ship.model + ", player.l.onShip = " + expect ShipStruct( player.l.onShip ).model )
			else
				printt( "player OFF: " + ship.model + ", player.l.onShip = NULL" )
		}
	#endif
	//Signal( ship, "PlayerOffBoard" )

	if ( IsValid( trigger ) )
		trigger.Enable()
}

void function ShipCabinInteriorThink( ShipStruct ship )
{
	ship.model.EndSignal( "OnDestroy" )
	EndSignal( ship, "FakeDestroy" )

	entity player
	entity mover = ship.mover
	entity trigger = ship.cabinTriggerInterior

	table result
	while( 1 )
	{
		if ( !trigger.IsTouched() )
		{
			result = trigger.WaitSignal( "OnStartTouch" )
			player = expect entity( result.activator )
			Assert( player.IsPlayer() )
		}

		PlayerOnShip( player, ship, ship.triggerTop )
		RunShipEventCallbacks( ship, eShipEvents.PLAYER_INCABIN_START, player )

		while ( trigger.IsTouched() )
		{
			trigger.WaitSignal( "OnEndTouchAll" )
			wait 0.5 //make sure
		}

		PlayerOffShip( player, ship, ship.triggerTop )

		RunShipEventCallbacks( ship, eShipEvents.PLAYER_INCABIN_END, player )
	}
}



/************************************************************************************************\

██████╗ ███████╗██╗   ██╗
██╔══██╗██╔════╝██║   ██║
██║  ██║█████╗  ██║   ██║
██║  ██║██╔══╝  ╚██╗ ██╔╝
██████╔╝███████╗ ╚████╔╝
╚═════╝ ╚══════╝  ╚═══╝

\************************************************************************************************/
struct devLine
{
	entity a
	entity b
}

void function DrawShipEdges( ShipStruct ship )
{
	if ( !ship.rightEdge.len() )
		return

	EndSignal( ship, "FakeDestroy" )

	array<devLine> lines

	CreateEdgeDrawingList( lines, ship.rightEdge[0] )
	CreateEdgeDrawingList( lines, ship.leftEdge[0] )

	while( 1 )
	{
		DrawEdgeLine( lines )
		wait 0.1
	}
}

void function DrawShipEdgeNodes( ShipStruct ship )
{
	if ( !ship.rightEdge.len() )
		return

	EndSignal( ship, "FakeDestroy" )

	while( 1 )
	{
		DrawEdgeNodes( ship.rightEdge )
		DrawEdgeNodes( ship.leftEdge )
		wait 0.1
	}
}

void function CreateEdgeDrawingList( array<devLine> lines, entity node )
{
	array<entity> linkedEnts = node.GetLinkEntArray()
	foreach ( entity ent in linkedEnts )
	{
		devLine newLine
		newLine.a = node
		newLine.b = ent
		lines.append( newLine )
		CreateEdgeDrawingList( lines, ent )
	}
}

void function DrawEdgeLine( array<devLine> lines )
{
	foreach ( devLine line in lines )
		DebugDrawLine( line.a.GetOrigin(), line.b.GetOrigin(), 0, 255, 0, true, FRAME_INTERVAL )
}

void function DrawEdgeNodes( array<entity> edgeArray )
{
	for ( int i = 0; i < edgeArray.len(); i++ )
		DebugDrawCircle( edgeArray[ i ].GetOrigin(), Vector(0,0,0), 16, 0, 255, 0, true, FRAME_INTERVAL )
}

void function DevPrints( ShipStruct ship )
{
	EndSignal( ship, "FakeDestroy" )

	entity mover = ship.mover
	mover.EndSignal( "OnDestroy" )

	while( 1 )
	{
		if ( DEV_PRINTSPEED )
			DebugDrawText( mover.GetOrigin() + < 0,0,128>, "Speed: " + Length( ship.localVelocity.v ), true, FRAME_INTERVAL )
		if ( DEV_PRINTBEHAVIOR )
			DevBehaviorPrint( ship, mover )
		wait FRAME_INTERVAL - 0.001
	}
}

/************************************************************************************************\

██╗   ██╗████████╗██╗██╗     ██╗████████╗██╗   ██╗
██║   ██║╚══██╔══╝██║██║     ██║╚══██╔══╝╚██╗ ██╔╝
██║   ██║   ██║   ██║██║     ██║   ██║    ╚████╔╝
██║   ██║   ██║   ██║██║     ██║   ██║     ╚██╔╝
╚██████╔╝   ██║   ██║███████╗██║   ██║      ██║
 ╚═════╝    ╚═╝   ╚═╝╚══════╝╚═╝   ╚═╝      ╚═╝

\************************************************************************************************/
void function FakeDestroy( ShipStruct ship )
{
	Signal( ship, "FakeDestroy" )
	if ( IsValid( ship.cockpit ) )
	{
		ship.cockpit.SetTakeDamageType( DAMAGE_NO )
		ship.cockpit.SetDamageNotifications( false )
	}

	ship.model.Hide()

	foreach ( entity guy in ship.guys )
	{
		if ( IsValid( guy ) && guy.GetParent() == ship.model )
			guy.Destroy()
	}

	if ( IsValid( ship.pilot ) )
		ship.pilot.Destroy()

	entity mover = ship.mover

	//not sure why this become invalid on map restarts
	if ( !IsValid( mover ) )
		return
	mover.NonPhysicsStop()
	mover.SetPusher( false )
	mover.SetOrigin( ship.templateOrigin )
	mover.SetPusher( true )
	mover.SetAngles( CONVOYDIR )
	ship.free = true
}

bool function IsDoorClosedOrClosing( ShipStruct ship )
{
	return ( 	ship.doorState == eDoorState.CLOSED ||
				ship.doorState == eDoorState.CLOSING_R ||
				ship.doorState == eDoorState.CLOSING_L )
}

bool function IsDoorOpenOrOpening( ShipStruct ship )
{
	return ( 	ship.doorState == eDoorState.OPEN_L ||
				ship.doorState == eDoorState.OPEN_R ||
				ship.doorState == eDoorState.OPENING_L ||
				ship.doorState == eDoorState.OPENING_R )
}

bool function IsShipOnBattleField( ShipStruct ship )
{
	if ( ship.free )
		return false

	if ( 	ship.behavior == eBehavior.DEATH_ANIM ||
			ship.behavior == eBehavior.CREW_DEAD ||
			ship.behavior == eBehavior.CREW_DEPLOYED ||
			ship.behavior == eBehavior.LEAVING )
		return false

	return true
}

void function PlayerSetNextShip( entity player, ShipStruct ship )
{
	player.l.onNextShip = ship
}

void function PlayerClearNextShip( entity player )
{
	player.l.onNextShip = null
}

ShipStruct ornull function PlayerGetNextShip( entity player )
{
	return player.l.onNextShip
}

void function PushShipList( entity player, ShipStruct ship )
{
	Assert( player.IsPlayer() )

	int existsInIndex = GetIndexInShipStructArray( player.l.onShipList, ship )
	if ( existsInIndex == 0 )
		return

	ShipStruct ornull [ONSHIPLISTMAX] newArray
	newArray[ 0 ] = ship
	int index = 1
	for ( int i = 0; i < player.l.onShipList.len(); i++ )
	{
		if ( existsInIndex == i )
			continue
		newArray[ index ] = player.l.onShipList[ i ]
		index++

		if ( index == newArray.len() )
			break
	}

	//copy it back into player's array
	for ( int i = 0; i < newArray.len(); i++ )
		player.l.onShipList[ i ] = newArray[ i ]
//	player.l.onShipList = newArray
}

int function GetIndexInShipStructArray( ShipStruct ornull [ONSHIPLISTMAX] Array, ShipStruct val )
{
	foreach( int i, ShipStruct v in Array )
	{
		if ( val == v )
			return i
	}

	return -1
}

void function ShipSetInvulnerable( ShipStruct ship )
{
	ship.model.SetInvulnerable()

	if ( IsValid( ship.cockpit ) )
		ship.cockpit.SetInvulnerable()
}

void function ShipClearInvulnerable( ShipStruct ship )
{
	ship.model.ClearInvulnerable()

	if ( IsValid( ship.cockpit ) )
			ship.cockpit.ClearInvulnerable()
}

void function ShipIsInvulnerable( ShipStruct ship )
{
	ship.model.IsInvulnerable()
}

void function ShipSetIgnoreMe( ShipStruct ship, bool value )
{
	ship.model.SetNoTarget( value )
	foreach ( guy in ship.guys )
	{
		if ( IsAlive( guy ) )
			guy.SetNoTarget( value )
	}
}

ShipStruct function GetFreeTemplate( array<ShipStruct> templates )
{
	foreach ( ShipStruct template in templates )
	{
		if ( template.free )
			return template
	}

	Assert( 0, "no free templates" )
	unreachable
}

LocalVec function CLVec( vector vec )
{
	LocalVec pos
	pos.v = vec
	return pos
}

LocalVec function WorldToLocalOrigin( vector vec )
{
	LocalVec pos
	pos.v = vec - WORLD_CENTER.GetOrigin()
	return pos
}

vector function LocalToWorldOrigin( LocalVec vec )
{
	return vec.v + WORLD_CENTER.GetOrigin()
}

LocalVec function WorldToLocalVelocity( vector vel )
{
	LocalVec newVel
	newVel.v = vel - WORLD_CENTER.GetVelocity()
	return newVel
}

vector function LocalToWorldVelocity( LocalVec vel )
{
	return vel.v + WORLD_CENTER.GetVelocity()
}

LocalVec function GetOriginLocal( entity ent )
{
	Assert( ent.l.localSpaceOrigin.v != INVALID_LOCALORIGIN )
	return clone ent.l.localSpaceOrigin
}

void function SetOriginLocal( entity ent, LocalVec pos )
{
	Signal( ent, "UpdateingLocalSpace" )
	ent.l.localSpaceOrigin.v = pos.v

	vector finalPos = __GetFinalWorldPosForLocalSpaceEnt( ent, pos )
	ent.SetOrigin( finalPos )
}

void function NonPhysicsMoveToLocal( entity ent, LocalVec pos, float time, float accTime, float decTime )
{
	Signal( ent, "UpdateingLocalSpace" )
	if ( time <= FRAME_INTERVAL * 3 )
	{
		ent.l.localSpaceOrigin.v = pos.v
		vector finalPos = __GetFinalWorldPosForLocalSpaceEnt( ent, pos )
		ent.NonPhysicsMoveTo( finalPos, time, accTime, decTime )
	}
	else
	{
		Assert( ent.l.skyboxScale == 1.0 )
		thread __NonPhysicsMoveToUpdateLocalSpace( ent, pos, time, accTime, decTime )
	}
}

vector function __GetFinalWorldPosForLocalSpaceEnt( entity ent, LocalVec pos )
{
	vector finalPos = ( pos.v + WORLD_CENTER.GetOrigin() ) * ent.l.skyboxScale
	finalPos += ent.l.skyboxOffset

	return finalPos
}

void function UpdatePosWithLocalSpace( entity ent )
{
	Assert( IsNewThread(), "Must be threaded off." )

	if ( !IsValid( ent ) )
		return
	EndSignal( ent, "UpdateingLocalSpace" )
	EndSignal( ent, "OnDestroy" )

	vector oldpos = <999,999,999>
	while( 1 )
	{
		vector newpos = WORLD_CENTER.GetOrigin()
		if ( newpos != oldpos )
		{
			ent.NonPhysicsMoveTo( ent.l.localSpaceOrigin.v + newpos, FRAME_INTERVAL * 1.5, 0, 0 )
			oldpos = newpos
		}
		WaitFrame()
	}
}

void function __NonPhysicsMoveToUpdateLocalSpace( entity ent, LocalVec pos, float time, float accTime, float decTime )
{
	EndSignal( ent, "UpdateingLocalSpace" )
	EndSignal( ent, "OnDestroy" )

	entity animRef = CreateScriptMover( <0,0,0>, CONVOYDIR )
	OnThreadEnd(
	function() : ( animRef )
		{
			animRef.Destroy()
		}
	)

	float endTime = Time() + time + FRAME_INTERVAL * 2
	vector startLoc = ent.l.localSpaceOrigin.v
	vector delta = pos.v - startLoc

	animRef.NonPhysicsMoveTo( delta, time, accTime, decTime )

	while( endTime > Time() )
	{
		vector newLoc = startLoc + animRef.GetOrigin()
		ent.NonPhysicsMoveTo( newLoc + WORLD_CENTER.GetOrigin(), FRAME_INTERVAL * 1.5, 0, 0 )
		ent.l.localSpaceOrigin.v = newLoc
		WaitFrame()
	}

	Assert( ent.l.localSpaceOrigin.v == pos.v, ent.l.localSpaceOrigin.v + " should be equal to " + pos.v )
}

LocalVec function GetVelocityLocal( entity ent )
{
	LocalVec vel
	vel.v = <0,0,0>

	if ( !IsValid( ent ) || !IsValid( WORLD_CENTER ) )
		return vel

	vel.v = ent.GetVelocity() - WORLD_CENTER.GetVelocity()
	return vel
}

void function SetVelocityLocal( entity ent, LocalVec vel )
{
	ent.SetVelocity( vel.v + WORLD_CENTER.GetVelocity() )
}

float function GetBestRightOfTargetForLeaving( ShipStruct ship )
{
	float rightOfTarget = 1.0
	switch( ship.doorState )
	{
		case eDoorState.OPEN_L:
		case eDoorState.OPENING_L:
		case eDoorState.CLOSING_L:
			rightOfTarget = 1.0
			break

		case eDoorState.OPEN_R:
		case eDoorState.OPENING_R:
		case eDoorState.CLOSING_R:
			rightOfTarget = -1.0
			break

		default:
			if ( CanGetEdgeData( ship, ship.chaseEnemy ) )
			{
				EdgeData data = GetBestEdgeData( ship, ship.chaseEnemy, ship.mover.GetOrigin() )
				rightOfTarget = data.rightOfTarget
			}
			break
	}

	return rightOfTarget
}