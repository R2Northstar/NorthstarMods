untyped //->effect.Fire only exists at runtime

global const asset DROPSHIP_FLYING_MODEL 	= $"models/vehicle/goblin_dropship/goblin_dropship_flying_static.mdl"
global const asset CROW_FLYING_MODEL = $"models/vehicles_r2/aircraft/dropship_crow/crow_dropship_flying_gutted.mdl"
global const asset CROW_MODEL = $"models/vehicle/crow_dropship/crow_dropship.mdl"

const asset GOBLIN_ENGINE_FAILURE	= $"P_s2s_engine_failure_smoke"
const asset GOBLIN_ENGINE_DAMAGE	= $"P_s2s_engine_damage_smoke"
const asset GOBLIN_ENGINE_BLOW 		= $"P_exp_flak_s2s_light"
global const asset GOBLIN_DEATH_FX_S2S 		= $"P_veh_exp_goblin_HS"
global const asset CROW_DEATH_FX_S2S 		= $"P_veh_exp_crow_HS"
global const asset CROW_HERO_MODEL = $"models/vehicle/crow_dropship/crow_dropship_hero.mdl"
global const asset DROPSHIP_HERO_MODEL = $"models/vehicle/goblin_dropship/goblin_dropship_hero.mdl"

const float GOBLIN_HEALTH = 1500

global function S2S_DropshipInit
global function SpawnGoblin
global function SpawnCrow
global function SpawnDSCombatTest
global function SpawnGoblinLight
global function SpawnCrowLight
global function GetActiveGoblins
global function DropshipAnimateClose
global function DropshipAnimateOpen
global function AddZiplineDeployNodes
global function ChangeLightDropshipToReal
global function ChangeRealDropshipToLight
global function ExplodeGoblin
global function GoblinDeathFx

global function GetShipCrew
global function GoblinRiderAnimate

struct
{
	array<ShipStruct> goblinTemplates
	array<ShipStruct> crowTemplates
}file

void function S2S_DropshipInit()
{
	RegisterSignal( "StopZipMovement" )
	RegisterSignal( "customDeployDetach" )
	RegisterSignal( "BeginZipline" )
	RegisterSignal( "not_solid" ) // from qc
	RegisterSignal( "OverDamaged" )

	PrecacheModel( DROPSHIP_HERO_MODEL )
	PrecacheModel( CROW_HERO_MODEL )
	PrecacheModel( DROPSHIP_FLYING_MODEL )
	PrecacheModel( CROW_FLYING_MODEL )
	PrecacheModel( DROPSHIP_MODEL )
	PrecacheModel( CROW_MODEL )
	PrecacheModel( CROW_FLYING_MODEL )

	PrecacheParticleSystem( GOBLIN_ENGINE_BLOW )
	PrecacheParticleSystem( GOBLIN_ENGINE_FAILURE )
	PrecacheParticleSystem( GOBLIN_ENGINE_DAMAGE )
	PrecacheParticleSystem( GOBLIN_DEATH_FX_S2S )
	PrecacheParticleSystem( CROW_DEATH_FX_S2S )

	AddCallback_EntitiesDidLoad( EntitiesDidLoad )
}

void function EntitiesDidLoad()
{
	array<entity> templates = GetEntArrayByScriptName( "GoblinTemplate" )
	foreach ( entity template in templates )
	{
		template.SetModel( DROPSHIP_HERO_MODEL )
		ShipStruct ship = DropshipDefaultSetup( template, <0,0,98> )
		file.goblinTemplates.append( ship )
	}

	templates = GetEntArrayByScriptName( "CrowTemplate" )
	foreach ( entity template in templates )
	{
		template.SetModel( CROW_HERO_MODEL )
		ShipStruct ship = DropshipDefaultSetup( template, <0,0,100> )
		Highlight_SetFriendlyHighlight( ship.model, "sp_s2s_crow_outline" )
		file.crowTemplates.append( ship )
	}
}

ShipStruct function DropshipDefaultSetup( entity template, vector offset )
{
	template.kv.CollisionGroup = TRACE_COLLISION_GROUP_BLOCK_WEAPONS//this makes the goblin shootable but not have phys collision
	template.SetMaxHealth( GOBLIN_HEALTH )
	template.SetTouchTriggers( false )
	AddEntityCallback_OnDamaged( template, GoblinOnDamaged )

	ShipStruct ship = ShipTemplateSetup( template, offset, GoblinSetupLinks )
	DropshipDefaultDataSettings( ship )

	return ship
}

void function DropshipDefaultDataSettings( ShipStruct ship )
{
	ship.defaultBehaviorFunc 	= DefaultBehavior_Goblin
	ship.defaultEventFunc 		= DefaultEventCallbacks_Goblin
	ship.DEV_hullSize 			= <350, 400, 180>
	ship.DEV_hullOffset 		= <0, 0, 110>
	ship.defAccMax 				= 100	//350
	ship.defSpeedMax 			= 500	//500
	ship.defRollMax 			= 37
	ship.defPitchMax 			= 37
}

array<ShipStruct> function GetActiveGoblins()
{
	return file.goblinTemplates
}

float function GetBankMagnitudeGoblin( float dist )
{
	return GraphCapped( dist, 100, 1000, 0.0, 1.0 )
}

array<entity> function GetShipCrew( ShipStruct ship )
{
	array<entity> guys = []
	foreach ( guy in ship.guys )
	{
		if ( IsAlive( guy ) )
			guys.append( guy )
	}

	return guys
}

/************************************************************************************************\

███████╗███████╗████████╗██╗   ██╗██████╗
██╔════╝██╔════╝╚══██╔══╝██║   ██║██╔══██╗
███████╗█████╗     ██║   ██║   ██║██████╔╝
╚════██║██╔══╝     ██║   ██║   ██║██╔═══╝
███████║███████╗   ██║   ╚██████╔╝██║
╚══════╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝

\************************************************************************************************/
ShipStruct function SpawnGoblin( LocalVec ornull origin = null, vector angles = CONVOYDIR, array<entity> ornull spawners = null )
{
	return SpawnDropShip( origin, angles, spawners, TEAM_IMC )
}

ShipStruct function SpawnCrow( LocalVec ornull origin = null, vector angles = CONVOYDIR, array<entity> ornull spawners = null )
{
	return SpawnDropShip( origin, angles, spawners, TEAM_MILITIA )
}

ShipStruct function SpawnDropShip( LocalVec ornull origin = null, vector angles = CONVOYDIR, array<entity> ornull spawners = null, int team = 0 )
{
	if ( origin == null )
		origin = CLVec( <0,0,0> )
	expect LocalVec( origin )

	ShipStruct ship

	if ( team == TEAM_IMC )
		ship = GetFreeTemplate( file.goblinTemplates )
	else if ( team == TEAM_MILITIA )
		ship = GetFreeTemplate( file.crowTemplates )
	else
		Assert( 0, "Team: " + team + " not valid" )

	entity mover = ship.mover
	SetOriginLocal( mover, origin )
	mover.SetAngles( angles )

	ResetGoblinTemplate( ship )
	Assert( IsAlive( ship.model ) )
	thread PlayAnim( ship.model, "dropship_closed_idle_alt", mover )
	SpawnGoblinRiders( ship, spawners, team )

	if ( IsValid( ship.cockpit ) )
		thread GoblinCockpitDamageThink( ship )
	thread GoblinEngineFailureThink( ship )

	//common
	thread ShipCommonFuncs( ship )
	ship.bug_reproNum = 10
	FakeNPCSettings( ship )
	return ship
}

ShipStruct function SpawnDSCombatTest( LocalVec ornull origin = null, vector angles = CONVOYDIR )
{
	if ( origin == null )
		origin = CLVec( <0,0,0> )
	expect LocalVec( origin )

	ShipStruct ship = GetFreeTemplate( file.crowTemplates )
	int team = TEAM_IMC

	entity mover = ship.mover
	SetOriginLocal( mover, origin )
	mover.SetAngles( angles )

	ResetGoblinTemplate( ship )
	Assert( IsAlive( ship.model ) )
	thread PlayAnim( ship.model, "dropship_closed_idle_alt", mover )
	SpawnGoblinRiders( ship, null, team )

	if ( IsValid( ship.cockpit ) )
		thread GoblinCockpitDamageThink( ship )
	thread GoblinEngineFailureThink( ship )

	//common
	thread ShipCommonFuncs( ship )
	ship.bug_reproNum = 10
	return ship
}

ShipStruct function SpawnGoblinLight( LocalVec ornull origin = null, vector angles = CONVOYDIR, bool animating = false )
{
	return SpawnDropShipLight( origin, angles, TEAM_IMC, animating )
}

ShipStruct function SpawnCrowLight( LocalVec ornull origin = null, vector angles = CONVOYDIR, bool animating = false )
{
	return SpawnDropShipLight( origin, angles, TEAM_MILITIA, animating )
}

ShipStruct function SpawnDropShipLight( LocalVec ornull origin = null, vector angles = CONVOYDIR, int team = 0, bool animating = false )
{
	Assert( team != 0, "Team: " + team + " not valid" )

	if ( origin == null )
		origin = CLVec( <0,0,0> )
	expect LocalVec( origin )

	ShipStruct ship
	asset shipModel
	if ( team == TEAM_IMC )
	{
		shipModel = DROPSHIP_FLYING_MODEL
		if( animating )
			shipModel = DROPSHIP_MODEL
	}
	else
	{
		Assert( team == TEAM_MILITIA )
		shipModel = CROW_FLYING_MODEL
		if( animating )
			shipModel = CROW_MODEL
	}

	entity mover
	if ( !animating )
		mover = CreateScriptMoverModel( shipModel, LocalToWorldOrigin( origin ), angles, 6, 100000 )
	else
		mover = CreateExpensiveScriptMoverModel( shipModel, LocalToWorldOrigin( origin ), angles, 6, 100000 )

	ship.model = mover
	ship.mover = mover
	SetTeam( mover, team )

	mover.DisableHibernation()

	SetOriginLocal( mover, origin )
	mover.SetAngles( angles )

	if ( animating )
	{
		Assert( IsAlive( ship.model ) )
		thread PlayAnim( ship.model, "dropship_closed_idle_alt", mover )
		int eHandle = ship.model.GetEncodedEHandle()
		Remote_CallFunction_NonReplay( GetPlayerArray()[0], "ServerCallback_DisableDropshipLights", eHandle )
	}
//	CreateFakeRiders( ship, team )

	DropshipDefaultDataSettings( ship )

	ship.engineDamage = false

	ship.model.SetTakeDamageType( DAMAGE_YES )
	ship.model.SetDamageNotifications( true )
	ship.model.SetMaxHealth( GOBLIN_HEALTH )
	ship.model.SetHealth( ship.model.GetMaxHealth() )
	AddEntityCallback_OnDamaged( ship.model, GoblinOnDamaged )

	ship.FuncGetBankMagnitude 	= GetBankMagnitudeGoblin


	ship.localVelocity.v = <0,0,0>
	ship.goalRadius = SHIPGOALRADIUS
	ship.boundsMinRatio = 0.5

	ResetAllEventCallbacksToDefault( ship )
	ResetAllBehaviorsToDefault( ship )
	ship.behavior 		= eBehavior.IDLE
	ship.prevBehavior 	= [ eBehavior.IDLE ]
	ship.doorState 		= eDoorState.CLOSED
	ship.free 			= false

	thread GoblinEngineFailureThink( ship )
	thread RunBehaviorFiniteStateMachine( ship )

	ResetMaxSpeed( ship )
	ResetMaxAcc( ship )
	ResetMaxRoll( ship )
	ResetMaxPitch( ship )
	ResetBankTime( ship )
	FakeNPCSettings( ship, animating )

	ship.bug_reproNum = 10

	return ship
}

void function FakeNPCSettings( ShipStruct ship, bool animating = true )
{
	ship.model.SetNoTarget( false )
	ship.model.SetNoTargetSmartAmmo( false )

	if ( ship.model.GetTeam() == TEAM_IMC )
		SetCustomSmartAmmoTarget( ship.model, true )

	ship.model.SetArmorType( ARMOR_TYPE_HEAVY )

	if ( animating )
	{
		int eHandle = ship.model.GetEncodedEHandle()
		Remote_CallFunction_NonReplay( GetPlayerArray()[0], "ServerCallback_DisableDropshipDamage", eHandle )
	}
}

ShipStruct function ChangeLightDropshipToReal( ShipStruct lightweight, array<entity> ornull spawners = null )
{
	ShipStruct ship = SpawnDropShip( GetOriginLocal( lightweight.mover ), lightweight.mover.GetAngles(), spawners, lightweight.mover.GetTeam() )
	ship.localVelocity.v = lightweight.localVelocity.v
	SetChaseEnemy( ship, lightweight.chaseEnemy )

	ship.doorState = lightweight.doorState

	lightweight.mover.Destroy()
	Signal( lightweight, "FakeDestroy" )

	return ship
}

ShipStruct function ChangeRealDropshipToLight( ShipStruct ship, bool animating = true )
{
	ShipStruct lightweight = SpawnDropShipLight( GetOriginLocal( ship.mover ), ship.mover.GetAngles(), ship.mover.GetTeam(), animating )
	lightweight.localVelocity.v = ship.localVelocity.v
	SetChaseEnemy( lightweight, ship.chaseEnemy )

	lightweight.doorState = ship.doorState

	if ( animating )
	{
		switch( lightweight.doorState )
		{
			case eDoorState.OPEN_L:
				thread PlayAnim( lightweight.model, "dropship_open_doorL_idle", lightweight.mover )
				break

			case eDoorState.OPEN_R:
				thread PlayAnim( lightweight.model, "dropship_open_doorR_idle", lightweight.mover )
				break
		}
	}

	FakeDestroy( ship )
	return lightweight
}

void function GoblinSetupLinks( ShipStruct ship, entity mover, entity ent )
{
	entity model = ship.model
	switch( ent.kv.script_noteworthy )
	{
		case "Cockpit":
			ship.cockpit = ent
			ent.SetTakeDamageType( DAMAGE_NO )
			ent.SetDamageNotifications( false )
			ent.SetMaxHealth( MAXHEALTH )
			ent.SetHealth( MAXHEALTH )
			ent.Hide()
			break

		case "npcClip":
			ship.npcClip = ent
			break

		case "InteriorDoorL":
			ship.interiorDoorL = ent
			ent.SetParent( model, "ATTACH_L_DOOR", true )
			break

		case "InteriorDoorR":
			ship.interiorDoorR = ent
			ent.SetParent( model, "ATTACH_R_DOOR", true )
			break

		default:
			Assert( 0, "linked template ent missing valid script_noteworthy" )
			break
	}
}

void function SpawnGoblinRiders( ShipStruct ship, array<entity> ornull spawners, int team )
{
	#if DEV
		foreach( entity guy in ship.guys )
			Assert( !IsAlive( guy ) )
		Assert( !IsAlive( ship.pilot ) )
	#endif

	string riderTag = "RESCUE"
	string[4] weaponNames = [ "mp_weapon_lstar",
							"mp_weapon_dmr",
							"mp_weapon_lstar",
							"mp_weapon_lstar" ]

	for( int i = 0; i < 4; i++ )
	{
		entity guy
		if ( spawners == null )
		{
			guy = CreateSoldier( team, ship.model.GetOrigin(), ship.model.GetAngles() )
			SetSpawnOption_Weapon( guy, weaponNames[ i ] )
			SetSpawnOption_Alert( guy )
			DispatchSpawn( guy )
		}
		else
		{
			expect array<entity>( spawners )
			if ( spawners[ i ].IsNPC() )
				guy = spawners[ i ]
			else
			{
				guy = spawners[ i ].SpawnEntity()
				DispatchSpawn( guy )
			}
		}

		//guy.DisableHibernation()
		GoblinRiderAnimate( guy, ship.model, i, riderTag )
		AddEntityCallback_OnDamaged( guy, GoblinRiderOnDamaged )
		if ( ship.guys.len() > i )
			ship.guys[i] = guy
		else
			ship.guys.append( guy )
	}

	thread SignalOnCrewDead( ship )

	/*
	entity guy = CreateSoldier( team, ship.model.GetOrigin(), ship.model.GetAngles() )
	DispatchSpawn( guy )
	thread GoblinPilotAnimate( guy, ship )
	ship.pilot = guy
	*/
}

void function CreateFakeRiders( ShipStruct ship, int team )
{
	string riderTag = "RESCUE"
	string[4] weaponNames = [ "mp_weapon_lstar",
							"mp_weapon_dmr",
							"mp_weapon_lstar",
							"mp_weapon_lstar" ]
	asset[4] imcModels 	= [ TEAM_IMC_GRUNT_MODEL_LMG,
							TEAM_IMC_GRUNT_MODEL_RIFLE,
							TEAM_IMC_GRUNT_MODEL_SHOTGUN,
							TEAM_IMC_GRUNT_MODEL_SMG ]
	asset[4] milModels 	= [ TEAM_MIL_GRUNT_MODEL,
							TEAM_MIL_GRUNT_MODEL,
							TEAM_MIL_GRUNT_MODEL,
							TEAM_MIL_GRUNT_MODEL ]
	table<int, asset[4]> models = {}
	models[ TEAM_MILITIA ] <- milModels
	models[ TEAM_IMC ] <- imcModels

	for( int i = 0; i < 4; i++ )
	{
		entity guy = CreatePropDynamic( models[ team ][ i ] )
		guy.MarkAsNonMovingAttachment()
		entity gun = CreatePropDynamic( GetWeaponInfoFileKeyFieldAsset_Global( weaponNames[i], "playermodel" ) )
		gun.SetParent( guy, "PROPGUN")
		guy.MarkAsNonMovingAttachment()

		GoblinRiderAnimate( guy, ship.model, i, riderTag )
		ship.guys[i] = guy
	}
}

void function SignalOnCrewDead( ShipStruct ship )
{
	EndSignal( ship, "FakeDestroy" )
	EndSignal( ship, "deploy" )

	array<entity> guys
	foreach ( entity ent in ship.guys )
		guys.append( ent )

	waitthread WaitUntilAllDead( guys )
	Signal( ship, "crewDead" )
}

void function ResetGoblinTemplate( ShipStruct ship )
{
	ship.doorState = eDoorState.CLOSED
	ship.behavior = eBehavior.NONE

	ship.engineDamage = false

	if ( IsValid( ship.cockpit ) )
	{
		ship.cockpit.SetHealth( MAXHEALTH )
		ship.cockpit.SetTakeDamageType( DAMAGE_YES )
		ship.cockpit.SetDamageNotifications( true )
	}

	ship.model.SetTakeDamageType( DAMAGE_YES )
	ship.model.SetDamageNotifications( true )
	if ( ship.model.GetClassName() != "script_mover" )
		ship.model.SetHealth( ship.model.GetMaxHealth() )

	ship.npcClip.Solid()

	if ( IsValid( ship.cabinTriggerInterior ) )
		ship.cabinTriggerInterior.Enable()
	ship.triggerTop.Enable()

	ship.FuncGetBankMagnitude 	= GetBankMagnitudeGoblin
}

void function DefaultBehavior_Goblin( ShipStruct ship, int behavior )
{
	switch ( behavior )
	{
		case eBehavior.ENEMY_CHASE:
			AddShipBehavior( ship, behavior, Behavior_ChaseEnemy )
			//right, forward, up
			SetFlyOffset( ship, behavior, < 950, 0, 350 > )
			SetFlyBounds( ship, behavior, < 500, 500, 225 > )
			SetSeekAhead( ship, behavior, 700 )
			break

		case eBehavior.DEPLOY:
			AddShipBehavior( ship, behavior, Behavior_Deploy )
			//right, forward, up
			SetFlyOffset( ship, behavior, < 0, 0, 100 > )
			SetFlyBounds( ship, behavior, < 100, 20, 8 > )
			break

		case eBehavior.DEPLOYZIP:
			AddShipBehavior( ship, behavior, Behavior_DeployZip )
			//right, forward, up
			SetFlyOffset( ship, behavior, < 1000, 0, 650 > )
			SetFlyBounds( ship, behavior, < 250, 200, 150 > )
			break

	/*	case eBehavior.ENEMY_ONBOARD:
			AddShipBehavior( ship, behavior, Behavior_EnemyOnboard )
			//right, forward, up
			SetFlyOffset( ship, behavior, < 350, -100, 300 > )
			SetFlyBounds( ship, behavior, < 250, 300, 60 > )
			SetSeekAhead( ship, behavior, 0 )
			break*/

		case eBehavior.ENGINE_FAILURE:
			AddShipBehavior( ship, behavior, Behavior_EngineFailure )
			//right, forward, up
			SetFlyOffset( ship, behavior, < 300, 0, 16 > )
			SetFlyBounds( ship, behavior, < 50, 300, 32 > )
			SetSeekAhead( ship, behavior, 50 )
			break

		case eBehavior.DEATH_ANIM:
			AddShipBehavior( ship, behavior, Behavior_DeathAnim )
			break
	}
}

void function DefaultEventCallbacks_Goblin( ShipStruct ship, int event )
{
	switch ( event )
	{
		case eShipEvents.PLAYER_INCABIN_START:
			AddShipEventCallback( ship, event, Event_PlayerInGoblinCabinStart )
			break

		case eShipEvents.PLAYER_INCABIN_END:
			AddShipEventCallback( ship, event, Event_PlayerInGoblinCabinEnd )
			break

		case eShipEvents.PLAYER_ONHULL_START:
			AddShipEventCallback( ship, event, Event_PlayerOnGoblinHullStart )
			break

		case eShipEvents.SHIP_ENGINEFAILURE:
			AddShipEventCallback( ship, event, Event_GoblinEngineFailure )
			break

		case eShipEvents.SHIP_ONCLOSEDOOR:
			AddShipEventCallback( ship, event, Event_GoblinOnCloseDoor )
			break

		case eShipEvents.SHIP_ONOPENDOOR:
			AddShipEventCallback( ship, event, Event_GoblinOnOpenDoor )
			break

		case eShipEvents.SHIP_PREPNEWEDGE:
			AddShipEventCallback( ship, event, Event_GoblinAnimCloseDoor )
			break

		case eShipEvents.SHIP_ATNEWEDGE:
			AddShipEventCallback( ship, event, Event_GoblinAnimOpenDoor )
			break

		case eShipEvents.SHIP_ATDEPLOYPOS:
			AddShipEventCallback( ship, event, Event_GoblinAnimOpenDoor )
			AddShipEventCallback( ship, event, Event_GoblinDeploy )
			break

		case eShipEvents.SHIP_ATDEPLOYPOSZIP:
			AddShipEventCallback( ship, event, Event_GoblinAnimOpenDoor )
			AddShipEventCallback( ship, event, Event_GoblinDeployZip )
			break
	}
}

/************************************************************************************************\

███████╗███╗   ██╗ ██████╗ ██╗███╗   ██╗███████╗███████╗
██╔════╝████╗  ██║██╔════╝ ██║████╗  ██║██╔════╝██╔════╝
█████╗  ██╔██╗ ██║██║  ███╗██║██╔██╗ ██║█████╗  ███████╗
██╔══╝  ██║╚██╗██║██║   ██║██║██║╚██╗██║██╔══╝  ╚════██║
███████╗██║ ╚████║╚██████╔╝██║██║ ╚████║███████╗███████║
╚══════╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝╚═╝  ╚═══╝╚══════╝╚══════╝

\************************************************************************************************/
void function GoblinOnDamaged( entity ent, var damageInfo )
{
	float damage = DamageInfo_GetDamage( damageInfo )
	entity inflictor = DamageInfo_GetInflictor( damageInfo )
	entity attacker = DamageInfo_GetAttacker( damageInfo )
	vector pos = DamageInfo_GetDamagePosition( damageInfo )

	string damageTag = "L_exhaust_rear_2"
	if ( DotProduct( pos - ent.GetOrigin(), ent.GetRightVector() ) > 1.0 )
		damageTag = "R_exhaust_rear_2"

	if ( IsValid( attacker ) && attacker.IsPlayer() && attacker.IsTitan() )
	{
		float score = max( damage * 0.25, 100 )
		AddCreditToTitanCoreBuilderForTitanDamageInflicted( attacker, score )
	}

	if ( IsValid( inflictor ) && inflictor.GetTeam() == ent.GetTeam() )
		DamageInfo_SetDamage( damageInfo, 0 )

	//make sure this entity NEVER dies
	if ( damage >= ent.GetHealth() )
	{
		bool OverDamaged = false
		if ( fabs( ent.GetHealth() - damage ) > 200 )
			OverDamaged = true

		DamageInfo_SetDamage( damageInfo, 0 )
		ent.SetHealth( 1 )

		if ( OverDamaged )
			Signal( ent, "OverDamaged" )
		else
			Signal( ent, "OnDamaged", { engineDamageTag = damageTag } )
	}
	else
		Signal( ent, "OnDamaged", { engineDamageTag = damageTag } )
}

void function GoblinEngineFailureThink( ShipStruct ship )
{
	ship.model.EndSignal( "OnDestroy" )
	EndSignal( ship, "FakeDestroy" )

	entity model = ship.model
	table e

	OnThreadEnd(
	function() : ( ship, model, e )
		{
			model.SetTakeDamageType( DAMAGE_NO )
			model.SetDamageNotifications( false )

			if ( IsValid( e.fx ) )
				e.fx.Destroy()

			Signal( ship, "FakeDestroy" )
		}
	)

	e.fx <- null
	array<float> damageStates = [ 0.6, 0.3, 0.0 ]
	foreach( damageRatio in damageStates )
	{
		while( 1 )
		{
			table result = WaitSignal( model, "OnDamaged", "OverDamaged" )
			if ( expect string( result.signal ) == "OverDamaged" )
			{
				Signal( ship, "engineFailure_Complete" )
				wait 0.1

				ship.engineDamage = true
			//	ship.model.SetNoTarget( true )
			//	ship.model.SetNoTargetSmartAmmo( true )
				return
			}

			if ( "engineDamageTag" in result )
				ship.engineDamageTag = expect string( result.engineDamageTag )

			if ( model.GetHealth() <= 1 )
				break

			if ( model.GetHealth().tofloat() / model.GetMaxHealth().tofloat() > damageRatio )
				continue

			break
		}

		if ( model.GetHealth() <= 1 )
			break

		int attachID = ship.model.LookupAttachment( ship.engineDamageTag )
		int fxID = GetParticleSystemIndex( GOBLIN_ENGINE_FAILURE )
		
		if ( !NSIsDedicated() )
		{
			entity effect = StartParticleEffectOnEntity_ReturnEntity( ship.model, fxID, FX_PATTACH_POINT_FOLLOW, attachID )
			effect.Fire( "Kill", "", 0.25 )
		}

		if ( IsValid( e.fx ) )
			e.fx.Destroy()
		fxID = GetParticleSystemIndex( GOBLIN_ENGINE_DAMAGE )

		if ( !NSIsDedicated() )
			e.fx = StartParticleEffectOnEntity_ReturnEntity( ship.model, fxID, FX_PATTACH_POINT_FOLLOW, attachID )
	}

	if ( IsValid( e.fx ) )
		e.fx.Destroy()

	ship.engineDamage = true
	Signal( ship, "engineFailure_Complete" )
	ship.model.SetNoTarget( true )
	ship.model.SetNoTargetSmartAmmo( true )

	wait 0.25

	WaitSignal( model, "OverDamaged" )
}

void function Event_GoblinEngineFailure( ShipStruct ship, entity player, int eventID )
{
	if ( !IsValid( player ) || !player.IsPlayer() )
		return

	if ( Time() < S2S_VOtime )
		return
	S2S_VOtime = Time() + VOBUFFER

	array<string> text = [	"Engine one is down! We're losing altitude",
							"Mayday, Mayday, Engine one is down!" ]
	//Dev_PrintMessage( player, "", text.getrandom(), 5 )//hack
}

/************************************************************************************************\

 ██████╗ █████╗ ██████╗ ██╗███╗   ██╗
██╔════╝██╔══██╗██╔══██╗██║████╗  ██║
██║     ███████║██████╔╝██║██╔██╗ ██║
██║     ██╔══██║██╔══██╗██║██║╚██╗██║
╚██████╗██║  ██║██████╔╝██║██║ ╚████║
 ╚═════╝╚═╝  ╚═╝╚═════╝ ╚═╝╚═╝  ╚═══╝

\************************************************************************************************/
void function Event_PlayerInGoblinCabinStart( ShipStruct ship, entity player, int eventID )
{
	foreach( entity guy in ship.guys )
	{
		if ( !IsAlive( guy ) )
			continue
		guy.ClearParent()
		guy.Anim_Stop()
	}
}

void function Event_PlayerInGoblinCabinEnd( ShipStruct ship, entity player, int eventID )
{
	string riderTag
	switch( ship.doorState )
	{
		case eDoorState.OPENING_L:
		case eDoorState.OPEN_L:
			riderTag = "ORIGIN"
			break

		case eDoorState.OPENING_R:
		case eDoorState.OPEN_R:
			riderTag = "RESCUE"
			break
	}

	foreach( int index, entity guy in ship.guys )
	{
		if ( !IsAlive( guy ) )
			continue

		GoblinRiderAnimate( guy, ship.model, index, riderTag )
	}
}

/************************************************************************************************\

██████╗  ██████╗  ██████╗ ███████╗
██╔══██╗██╔═══██╗██╔═══██╗██╔════╝
██████╔╝██║   ██║██║   ██║█████╗
██╔══██╗██║   ██║██║   ██║██╔══╝
██║  ██║╚██████╔╝╚██████╔╝██║
╚═╝  ╚═╝ ╚═════╝  ╚═════╝ ╚═╝

\************************************************************************************************/
void function GoblinCockpitDamageThink( ShipStruct ship )
{
	ship.model.EndSignal( "OnDestroy" )
	EndSignal( ship, "FakeDestroy" )

	OnThreadEnd(
	function() : ( ship )
		{
			ship.cockpit.SetTakeDamageType( DAMAGE_NO )
			ship.cockpit.SetDamageNotifications( false )
			ship.cockpit.SetHealth( MAXHEALTH )
		}
	)

	int damageState1 = 5 * 50 //num shots * r101 damage
	while( 1 )
	{
		table result = WaitSignal( ship.cockpit, "OnDamaged" )
		entity player = expect entity( result.activator )
		if ( !player.IsPlayer() )
			continue

		vector pos = player.EyePosition()
		vector dir = player.GetViewVector()
		float dist = Distance( pos, ship.cockpit.GetOrigin() ) - 16
		vector start = pos + ( dir * dist )
		vector end = start + ( dir * 100 )
		//DebugDrawLine( start, end, 255, 0, 0, true, 0.5 )

		entity weapon = player.GetActiveWeapon()
		bool isSolid = ship.model.IsSolid()
		ship.model.NotSolid()
		weapon.FireWeaponBullet( start, dir, 1, damageTypes.bullet )//HACK
		if ( isSolid )
			ship.model.Solid()
	}
}

void function Event_PlayerOnGoblinHullStart( ShipStruct ship, entity player, int eventID )
{
	if ( !IsValid( player ) || !player.IsPlayer() )
		return

	array<string> text = [	"He's on the hull! Shake him off!",
							"Holy shit! He's on the roof!",
							"Where he go?! Up there! Up there!",
							"He just jumped on the roof! Holy shit!",
							"How'd he get up there? I don't know!?" ]
	//Dev_PrintMessage( player, "", text.getrandom(), 5 )//hack
}

/************************************************************************************************\

██████╗ ███████╗██╗  ██╗ █████╗ ██╗   ██╗██╗ ██████╗ ██████╗
██╔══██╗██╔════╝██║  ██║██╔══██╗██║   ██║██║██╔═══██╗██╔══██╗
██████╔╝█████╗  ███████║███████║██║   ██║██║██║   ██║██████╔╝
██╔══██╗██╔══╝  ██╔══██║██╔══██║╚██╗ ██╔╝██║██║   ██║██╔══██╗
██████╔╝███████╗██║  ██║██║  ██║ ╚████╔╝ ██║╚██████╔╝██║  ██║
╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝  ╚═══╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝

\************************************************************************************************/
void function Behavior_ChaseEnemy( ShipStruct ship )
{
	entity enemy 	= ship.chaseEnemy
	thread GoblinChaseVO( ship, enemy )

	int behavior 	= ship.behavior
	vector bounds 	= ship.flyBounds[ behavior ]
	vector offset 	= ship.flyOffset[ behavior ]
	float seekAhead = ship.seekAhead[ behavior ]
	__ShipFlyAlongEdge( ship, bounds, offset, seekAhead, eShipEvents.SHIP_ATNEWEDGE )
}

void function Behavior_Deploy( ShipStruct ship )
{
	ShipStruct ornull followShip = GetDeployShip( ship )
	expect ShipStruct( followShip )
	entity targetEnt = followShip.mover
	vector pos 		= GetDeployPos( ship )
	int behavior 	= ship.behavior
	vector offset 	= ship.flyOffset[ behavior ]
	vector bounds 	= ship.flyBounds[ behavior ]

	__ShipFollowShip( ship, targetEnt, pos, bounds, offset, eShipEvents.SHIP_ATDEPLOYPOS )
}

void function Behavior_DeployZip( ShipStruct ship )
{
	ShipStruct ornull followShip = GetDeployShip( ship )
	expect ShipStruct( followShip )
	entity targetEnt = followShip.mover
	vector pos 		= GetDeployPos( ship )
	int behavior 	= ship.behavior
	vector offset 	= ship.flyOffset[ behavior ]
	vector bounds 	= ship.flyBounds[ behavior ]

	__ShipFollowShip( ship, targetEnt, pos, bounds, offset, eShipEvents.SHIP_ATDEPLOYPOSZIP )
}

void function Behavior_EnemyOnboard( ShipStruct ship )
{
	//what was our prev behavior?
	switch( ship.prevBehavior[0] )
	{
		case eBehavior.ENEMY_CHASE:
			int behavior 	= ship.behavior
			vector bounds 	= ship.flyBounds[ behavior ]
			vector offset 	= ship.flyOffset[ behavior ]
			float seekAhead = ship.seekAhead[ behavior ]
			__ShipFlyAlongEdge( ship, bounds, offset, seekAhead, eShipEvents.NONE )
			break

		default:
			DoPreviousBehavior( ship )
			break
	}
}

void function Behavior_EngineFailure( ShipStruct ship )
{
	ship.accMax 			= 200

	//what was our prev behavior?
	switch( ship.prevBehavior[0] )
	{
		case eBehavior.ENEMY_CHASE:
			int behavior 	= ship.behavior
			vector bounds 	= ship.flyBounds[ behavior ]
			vector offset 	= ship.flyOffset[ behavior ]
			float seekAhead = ship.seekAhead[ behavior ]
			__ShipFlyAlongEdge( ship, bounds, offset, seekAhead, eShipEvents.SHIP_ATNEWEDGE )
			break

		default:
			DoPreviousBehavior( ship )
			break
	}
}

void function GoblinChaseVO( ShipStruct ship, entity player )
{
	if ( !IsValid( player ) || !player.IsPlayer() )
			return

	EndSignal( ship, "NewBehavior" )
	EndSignal( ship, "FakeDeath" )

	while( 1 )
	{
		wait 2
		if ( Time() < S2S_VOtime )
			continue

		S2S_VOtime = Time() + RandomFloatRange( VOBUFFER * 1.5, VOBUFFER * 2 )

		array<string> text = [	"He's moving too fast!",
								"Do you see him? Where is he?",
								"Clear to engage! Open fire!",
								"He's moving across the hull of that ship!",
								"He's right there! He's right there!" ]
		//Dev_PrintMessage( player, "", text.getrandom(), 5 )//hack
	}
}

/*
	array<string> text = [	"Contact in sight. Moving into position.",
							"I see him! Moving to pursue",
							"There he is! Moving in along side him!",
							"Vector 3-4 in pursuit of target!",
							"Tracking target! Moving to engage!" ]
	Dev_PrintMessage( ship.chaseEnemy, "", text.getrandom(), 5 )//hack
*/

/************************************************************************************************\

██████╗ ███████╗ █████╗ ████████╗██╗  ██╗
██╔══██╗██╔════╝██╔══██╗╚══██╔══╝██║  ██║
██║  ██║█████╗  ███████║   ██║   ███████║
██║  ██║██╔══╝  ██╔══██║   ██║   ██╔══██║
██████╔╝███████╗██║  ██║   ██║   ██║  ██║
╚═════╝ ╚══════╝╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝

\************************************************************************************************/
void function Behavior_DeathAnim( ShipStruct ship )
{
	thread Behavior_DeathAnimThread( ship )
}

void function Behavior_DeathAnimThread( ShipStruct ship )
{
	Signal( ship, "FakeDeath" )
	EndSignal( ship, "FakeDestroy" )

	entity mover 	= ship.mover
	mover.EndSignal( "OnDestroy" )
	entity enemy = ship.chaseEnemy

	entity fxRef = GoblinDeathFx( ship )

	OnThreadEnd(
	function() : ( ship, fxRef )
		{
			if ( IsValid( fxRef ) )
				fxRef.Destroy()

			ExplodeGoblin( ship )

			if ( IsValid( ship.model ) )
				SetCustomSmartAmmoTarget( ship.model, false )
		}
	)

	SetMaxSpeed( ship, ship.defSpeedMax * 3, 1.5 )
	SetMaxAcc( ship, ship.defAccMax * 3, 1.5 )

	entity noFollowTarget = null

	float x = 6000
	float y = 2000
	float z = -9000

	float rightOfTarget = GetBestRightOfTargetForLeaving( ship )
	LocalVec pos = CLVec( GetOriginLocal( mover ).v + < x * rightOfTarget, y, z > )
	vector offset = <0,0,0>
	thread __ShipFlyToPosInternal( ship, noFollowTarget, pos, offset, CONVOYDIR )

	ship.goalRadius = RandomFloatRange( 3000, 8500 )
	WaitSignal( ship, "Goal" )
}

entity function GoblinDeathFx( ShipStruct ship )
{
	EmitSoundOnEntity( ship.model, "s2s_goblin_explode" )

	if ( NSIsDedicated() )
		return CreateScriptMover()

	int attachID = ship.model.LookupAttachment( ship.engineDamageTag )
	int fxID = GetParticleSystemIndex( GOBLIN_ENGINE_FAILURE )
	int fxID2 = GetParticleSystemIndex( GOBLIN_ENGINE_BLOW )
	entity fxRef = StartParticleEffectOnEntity_ReturnEntity( ship.model, fxID, FX_PATTACH_POINT_FOLLOW, attachID )
	StartParticleEffectOnEntity_ReturnEntity( ship.model, fxID2, FX_PATTACH_POINT_FOLLOW, attachID )

	return fxRef
}

void function ExplodeGoblin( ShipStruct ship )
{
	int fxID = GetParticleSystemIndex( GOBLIN_DEATH_FX_S2S )

	//is it a real ship? or light?
	if ( IsValid( ship.model ) )
	{
		if ( ship.model.GetTeam() == TEAM_MILITIA )
			fxID = GetParticleSystemIndex( CROW_DEATH_FX_S2S )

		EmitSoundAtPosition( TEAM_ANY, ship.model.GetOrigin(), "s2s_goblin_blow_up" )

		if ( ship.model.IsNPC() )
			thread FakeDestroy( ship )
		else
			ship.mover.Destroy()
	}

	StartParticleEffectInWorld( fxID, ship.model.GetOrigin(), CONVOYDIR )
}

/************************************************************************************************\

██████╗ ███████╗██████╗ ██╗      ██████╗ ██╗   ██╗
██╔══██╗██╔════╝██╔══██╗██║     ██╔═══██╗╚██╗ ██╔╝
██║  ██║█████╗  ██████╔╝██║     ██║   ██║ ╚████╔╝
██║  ██║██╔══╝  ██╔═══╝ ██║     ██║   ██║  ╚██╔╝
██████╔╝███████╗██║     ███████╗╚██████╔╝   ██║
╚═════╝ ╚══════╝╚═╝     ╚══════╝ ╚═════╝    ╚═╝

\************************************************************************************************/
void function Event_GoblinDeploy( ShipStruct ship, entity player, int eventID )
{
	OnThreadEnd(
	function() : ( ship )
		{
			foreach ( index, value in ship.guys )
				ship.guys[ index ] = null
		}
	)

	string side = GetBestSideFromEvent( ship, player, eventID )

	ship.npcClip.NotSolid()
	table<string, int> deployTable
	deployTable.numGuys <- 0
	foreach ( index, guy in ship.guys )
	{
		if ( !IsAlive( guy ) )
			continue

		deployTable.numGuys++
		thread GoblinRiderDeploySide( guy, index, ship, side, deployTable )
	}

	if ( deployTable.numGuys )
		Signal( ship, "deploy" )
}

/************************************************************************************************\

██████╗ ███████╗██████╗ ██╗      ██████╗ ██╗   ██╗    ███████╗██╗██████╗
██╔══██╗██╔════╝██╔══██╗██║     ██╔═══██╗╚██╗ ██╔╝    ╚══███╔╝██║██╔══██╗
██║  ██║█████╗  ██████╔╝██║     ██║   ██║ ╚████╔╝       ███╔╝ ██║██████╔╝
██║  ██║██╔══╝  ██╔═══╝ ██║     ██║   ██║  ╚██╔╝       ███╔╝  ██║██╔═══╝
██████╔╝███████╗██║     ███████╗╚██████╔╝   ██║       ███████╗██║██║
╚═════╝ ╚══════╝╚═╝     ╚══════╝ ╚═════╝    ╚═╝       ╚══════╝╚═╝╚═╝

\************************************************************************************************/
const float MAXPINTIME = 0.6
void function Event_GoblinDeployZip( ShipStruct ship, entity player, int eventID )
{
	OnThreadEnd(
	function() : ( ship )
		{
			foreach ( index, value in ship.guys )
				ship.guys[ index ] = null
		}
	)

	string side = GetBestSideFromEvent( ship, player, eventID )
	array<entity> hullNodes = GetZipHullNodes( ship, side )
	array<entity> guys = []
	foreach ( guy in ship.guys )
	{
		if ( IsAlive( guy ) )
			guys.append( guy )
	}
	Assert( guys.len() <= 4 )

	table<string, int> deployTable
	deployTable.numGuys <- guys.len()

	if ( guys.len() == 4 )
	{
		Assert( IsAlive( guys[0]) )
		Assert( IsAlive( guys[1]) )
		Assert( IsAlive( guys[2]) )
		Assert( IsAlive( guys[3]) )
		array<entity> guys1 = [ guys[0], guys[2] ]
		array<table>	tables1 = [ S2SCreateDropshipAnimTable( ship.model, side, 0 ),
									S2SCreateDropshipAnimTable( ship.model, side, 2 )]
		tables1[0].hullNode <- hullNodes[ 0 ]
		tables1[1].hullNode <- hullNodes[ 0 ]

		array<entity> guys2 = [ guys[1], guys[3] ]
		array<table>	tables2 = [ S2SCreateDropshipAnimTable( ship.model, side, 1 ),
									S2SCreateDropshipAnimTable( ship.model, side, 3 )]
		tables2[0].hullNode <- hullNodes[ 1 ]
		tables2[1].hullNode <- hullNodes[ 1 ]

		int customTimes = 0
		foreach ( guy in guys )
		{
			if ( guy.l.customZiplineDeployTime )
				customTimes++
		}

		if ( customTimes )
		{
			Assert( customTimes == guys.len() )
			thread GoblinRiderDeployZipTandomCustom( guys1, ship, side, tables1, deployTable )
			thread GoblinRiderDeployZipTandomCustom( guys2, ship, side, tables2, deployTable )
		}
		else
		{
			thread GoblinRiderDeployZipTandom( guys1, ship, side, tables1, deployTable )
			thread GoblinRiderDeployZipTandom( guys2, ship, side, tables2, deployTable )
		}
	}
	else
	{
		foreach ( index, guy in guys )
		{
			Assert( index < 3 )
			Assert( IsAlive( guy ) )
			table Table = S2SCreateDropshipAnimTable( ship.model, side, index )
			Table.hullNode <- hullNodes[ index ]

			thread GoblinRiderDeployZip( guy, ship, side, Table, deployTable )
		}
	}

	if ( deployTable.numGuys )
		Signal( ship, "deploy" )

	wait 2.0
	int count = 0
	foreach ( guy in ship.guys )
	{
		if ( IsAlive( guy ) )
			count++
	}

	if ( count )
	{
		deployTable.numGuys = count
		ship.model.Signal( "deploy" )
	}
	else
	{
		Signal( ship, "crewDead" )
	}
}

void function GoblinRiderDeployZipTandom( array<entity> guys, ShipStruct ship, string side, array<table> Tables, table<string, int> deployTable )
{
	entity mover 	= CreateScriptMover()
	entity dropNode = expect entity( Tables[0].hullNode )

	ship.model.EndSignal( "OnDeath" )
	mover.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function() : ( mover, Tables, dropNode )
		{
			thread S2SZiplineRetracts( Tables[0], dropNode, mover )
		}
	)

	RiderIdlesForZipline( guys[0], ship.model, Tables[0] )
	RiderIdlesForZipline( guys[1], ship.model, Tables[1] )

	WaittillPlayDeployAnims( ship.model )
	wait RandomFloatRange( 0.1, 0.75 )

	// the zipline shoots out
	CreateZipLineForNode( guys[0], Tables[0], dropNode )
	if ( IsAlive( guys[0] ) )
	{
		waitthread TandomGuyZiplinesToHull( guys[0], ship, Tables[0], mover, dropNode, deployTable )
		wait RandomFloatRange( 0.0, 0.5 )
	}

	if ( IsAlive( guys[1] ) )
		waitthread TandomGuyZiplinesToHull( guys[1], ship, Tables[0], mover, dropNode, deployTable )
}

void function GoblinRiderDeployZipTandomCustom( array<entity> guys, ShipStruct ship, string side, array<table> Tables, table<string, int> deployTable )
{
	entity mover 	= CreateScriptMover()
	entity dropNode = expect entity( Tables[0].hullNode )

	ship.model.EndSignal( "OnDeath" )
	mover.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function() : ( mover, Tables, dropNode )
		{
			thread S2SZiplineRetracts( Tables[0], dropNode, mover )
		}
	)

	RiderIdlesForZipline( guys[0], ship.model, Tables[0] )
	RiderIdlesForZipline( guys[1], ship.model, Tables[1] )

	WaittillPlayDeployAnims( ship.model )

	float time1 = guys[ 0 ].l.customZiplineDeployTime
	float time2 = guys[ 1 ].l.customZiplineDeployTime
	float ropeTime = time1 - MAXPINTIME
	Assert( ropeTime >= 0 )

	if ( ropeTime > 0 )
		delaythread( ropeTime ) CreateZipLineForNode( guys[0], Tables[0], dropNode )
	else
		thread CreateZipLineForNode( guys[0], Tables[0], dropNode )

	// the zipline shoots out
	delaythread( time1 ) TandomGuyZiplinesToHull( guys[0], ship, Tables[0], mover, dropNode, deployTable )

	wait time2
	if ( guys[1].l.customZiplineDeploySignal != "" )
		guys[1].WaitSignal( guys[1].l.customZiplineDeploySignal )

	if ( IsAlive( guys[1] ) )
		waitthread TandomGuyZiplinesToHull( guys[1], ship, Tables[0], mover, dropNode, deployTable )
}

void function TandomGuyZiplinesToHull( entity guy, ShipStruct ship, table zipTable, entity mover, entity dropNode, table<string, int> deployTable  )
{
	if ( !IsAlive( guy ) )
		return

	table e 		= {} // Track the movement of the script mover that moves the guy to the ground
	thread TrackMoverDirection( mover, e )

	waitthread RiderZiplinesToHull( guy, ship.model, zipTable, mover )
	thread RiderDetachesOntoHull( guy, zipTable, dropNode, e, ship, deployTable )

}

void function ResetZipline( entity mover, table zipTable )
{
	//reset zipline
	mover.Signal( "StopZipMovement" )
	entity end = expect entity( zipTable.end )

	if ( !IsValid( end ) || !IsValid( mover ) )
		return

	mover.SetParent( end.GetParent(), "", false, 0.3 )
}

void function GoblinRiderDeployZip( entity guy, ShipStruct ship, string side, table Table, table<string, int> deployTable )
{
	entity mover 	= CreateScriptMover()
	table e 		= {} // Track the movement of the script mover that moves the guy to the ground
	entity dropNode = expect entity( Table.hullNode )
	thread TrackMoverDirection( mover, e )

	ship.model.EndSignal( "OnDeath" )
	mover.EndSignal( "OnDestroy" )
	guy.EndSignal( "OnDeath" )

	OnThreadEnd(
		function() : ( mover, Table, dropNode )
		{
			thread S2SZiplineRetracts( Table, dropNode, mover )
		}
	)

	RiderIdlesForZipline( guy, ship.model, Table )

	WaittillPlayDeployAnims( ship.model )
	wait RandomFloatRange( 0.1, 0.75 )

	// the zipline shoots out
	CreateZipLineForNode( guy, Table, dropNode )
	waitthread RiderZiplinesToHull( guy, ship.model, Table, mover )
	thread RiderDetachesOntoHull( guy, Table, dropNode, e, ship, deployTable )
}

void function RiderIdlesForZipline( entity guy , entity model, table Table )
{
	string tag = expect string( Table.shipAttach )
	string anim = expect string( Table.idleAnim )

	guy.SetEfficientMode( true )
	guy.SetParent( model, tag )
	guy.Anim_ScriptedPlay( anim )
}

void function RiderDetachesOntoHull( entity guy, table Table, entity dropNode, table e, ShipStruct ship, table<string, int> deployTable )
{
	OnThreadEnd(
	function() : ( ship, deployTable )
		{
			deployTable.numGuys--
			if ( deployTable.numGuys == 0 )
				Signal( ship, "crewDeployed" )
		}
	)

	if ( guy.l.customZiplineDeployTime )
	{
		guy.WaitSignal( "npc_deployed" )
		return
	}

	if ( !IsAlive( guy ) )
		return
	if ( !guy.IsInterruptable() )
		return

	guy.EndSignal( "OnDeath" )

	LegacyTableForward( guy, Table, dropNode )

	// the guy detaches and falls to the ground
	guy.SetEfficientMode( false )
	guy.SetNameVisibleToOwner( true )
	vector vel = expect vector( e.currentOrigin ) - expect vector( e.oldOrigin )
	guy.SetVelocity( vel * 10 )
	thread AnimDoneStuckInSolidFailSafe( guy )

	string landingAnim = GetZiplineLandingAnims().getrandom()
	guy.Anim_ScriptedPlay( landingAnim )
	guy.Anim_EnablePlanting()

	guy.ClearParent()
	UpdateEnemyMemoryFromTeammates( guy )

	guy.Signal( "npc_deployed" )
}

const float ZipLineDetachDistSqr = pow( 350, 2 )
void function RiderZiplinesToHull( entity guy, entity model, table Table, entity mover )
{
	guy.EndSignal( "OnDeath" )
	model.EndSignal( "OnDeath" )
	mover.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function() : ( guy, model, mover, Table )
		{
			CleanupZiplineGuy( guy, model )
			ResetZipline( mover, Table )
		}
	)

	entity dropNode = expect entity( Table.hullNode )
	LegacyHookOrigin( guy, model, Table )

	mover.ClearParent()
	mover.SetOrigin( guy.GetOrigin() )
	mover.SetAngles( guy.GetAngles() )
	entity mid = expect entity( Table.mid )
	mid.SetParent( mover, "ref" )

	float rideTime = expect float( Table.rideTime )
	if ( guy.l.customZiplineRideTime )
		rideTime = guy.l.customZiplineRideTime

	thread MoverZipsToHull( Table, mover, rideTime )
	guy.SetParent( mover, "ref" )
	EmitSoundOnEntity( guy, "3p_zipline_attach" )

	if ( !guy.IsInterruptable() )
		return

	waitthread PlayAnim( guy, "pt_zipline_ready2slide", mover )
	EmitSoundOnEntity( guy, "3p_zipline_loop" )
	guy.Signal( "BeginZipline" )

	if ( !guy.IsInterruptable() )
		return

	thread PlayAnim( guy, ZIPLINE_IDLE_ANIM, mover, "ref" )

	if ( guy.l.customZiplineRideTime || guy.l.customZiplineDeployTime || guy.l.customZiplineDeploySignal != "" )
		guy.WaitSignal( "customDeployDetach" )
	else
	{
		while( DistanceSqr( mover.GetOrigin(), dropNode.GetOrigin() ) > ZipLineDetachDistSqr )
			WaitFrame()
	}

	//thread ZiplineStuckFailsafe( guy, dropNode.GetOrigin() )
}

void function MoverZipsToHull( table zipline, entity mover, float timeTotal )
{
	// this handles the start point moving.
	mover.EndSignal( "OnDestroy" )
	mover.EndSignal( "StopZipMovement" )
	entity ship = expect entity( zipline.ship )
	ship.EndSignal( "OnDestroy" )

	int attachIndex = expect int( zipline.attachIndex )
	vector origin = ship.GetAttachmentOrigin( attachIndex )
	vector angles = ship.GetAttachmentAngles( attachIndex )
	mover.SetOrigin( origin )
	mover.SetAngles( angles )

	entity zipStart = expect entity( zipline.start )
	entity zipEnd 	= expect entity( zipline.end )
	float endTime 	= Time() + timeTotal
	float maxOffset = -100

	while( Time() < endTime )
	{
		float timeLeft = endTime - Time()
		float fraction = timeLeft / timeTotal

		vector end = zipEnd.GetOrigin()// + GetVelocityLocal( zipEnd ).v
		vector start = zipStart.GetOrigin()// + GetVelocityLocal( zipStart ).v
		vector line = start - end
		angles = VectorToAngles( -line )
		angles.x = 0
		angles.z = 0

		float offsetZ = 0
		if ( fraction > 0.5 )
			offsetZ = GraphCapped( fraction, 1, 0.7, 0, maxOffset )
		else
			offsetZ = GraphCapped( fraction, 0.5, 0.1, maxOffset, 0 )

		line *= fraction
		end += line + <0,0,offsetZ>

		mover.NonPhysicsMoveTo( end, 0.1, 0, 0 )
		mover.NonPhysicsRotateTo( angles, 0.1, 0, 0 )

		#if DEV
			if ( DEV_DRAWDEPLOY && GetMoDevState() )
			{
				DebugDrawCircle( zipEnd.GetOrigin(), <0,0,0>, 4, 0, 202, 255, true, FRAME_INTERVAL )
				DebugDrawLine( zipEnd.GetOrigin(), zipStart.GetOrigin(), 0, 202, 255, true, FRAME_INTERVAL )
				DebugDrawCircle( end, <0,0,0>, 4, 255, 202, 0, true, FRAME_INTERVAL )
			}
		#endif

		WaitFrame()
	}
}

void function CreateZipLineForNode( entity guy, table Table, entity dropNode )
{
	entity ship 		= expect entity( Table.ship )
	string shipAttach 	= expect string( Table.shipAttach )
	float rideDist 		= Distance( guy.GetOrigin(), dropNode.GetOrigin() )
	Table.rideTime 		<- Graph( rideDist, 0, 1000, 0, 2.5 ) 	// how long it takes the rider to ride 1000 units
	float pinTime 		= Graph( rideDist, 0, 1000, 0, MAXPINTIME )	// how long it takes the zipline to travel 1000 units
	Table.pinTime 		<- pinTime
	Table.retractTime 	<- Graph( rideDist, 0, 1000, 0, 0.5 ) 	// how long it takes the zipline to retract,
	int attachIndex 	= ship.LookupAttachment( shipAttach )
	Table.attachIndex 	= attachIndex

	CreateS2SRopeEntities( Table )
	entity end 		= expect entity( Table.end )
	entity start 	= expect entity( Table.start )
	entity mid 		= expect entity( Table.mid )
	end.SetOrigin( ship.GetAttachmentOrigin( attachIndex ) )
	start.SetParent( ship, shipAttach )
	mid.SetParent( ship, shipAttach )

	SpawnZiplineEntities( Table )

	EmitSoundOnEntity( dropNode, "dropship_zipline_zipfire" )

	float len = Distance( start.GetOrigin(), end.GetOrigin() )
	float wiggleMagnitude = 1.0
	float wiggleSpeed = 5.0
	float wiggleLengthFrac = 0.99  // after rope reaches this fraction of the total length, stop wiggling
	// RopeWiggle( maxlen, wiggleMagnitude, wiggleSpeed, duration, fadeDuration )
	end.RopeWiggle( len * wiggleLengthFrac, wiggleMagnitude, wiggleSpeed, pinTime * wiggleLengthFrac, pinTime )

	ZiplineMoverRealTime( end, dropNode, pinTime )
	EmitSoundOnEntity( dropNode, "s2s_scr_zipline_attach_01" )

	wait pinTime
}

table function CreateS2SRopeEntities( table Table )
{
	int subdivisions = 8 // 25
	float slack = 5 // 25
	string midpointName = UniqueString( "rope_midpoint" )
	string endpointName = UniqueString( "rope_endpoint" )

	entity rope_start = CreateEntity( "move_rope" )
	rope_start.kv.NextKey = midpointName
	rope_start.kv.MoveSpeed = 64
	rope_start.kv.Slack = slack
	rope_start.kv.Subdiv = subdivisions
	rope_start.kv.Width = "2"
	rope_start.kv.TextureScale = "1"
	rope_start.kv.RopeMaterial = "cable/cable.vmt"
	rope_start.kv.PositionInterpolator = 2

	entity rope_mid = CreateEntity( "keyframe_rope" )
	rope_mid.kv.targetname = midpointName
	rope_mid.kv.NextKey = endpointName
	rope_mid.kv.MoveSpeed = 64
	rope_mid.kv.Slack = slack
	rope_mid.kv.Subdiv = subdivisions
	rope_mid.kv.Width = "2"
	rope_mid.kv.TextureScale = "1"
	rope_mid.kv.RopeMaterial = "cable/cable.vmt"

	entity rope_end = CreateEntity( "keyframe_rope" )
	rope_end.kv.targetname = endpointName
	rope_end.kv.MoveSpeed = 64
	rope_end.kv.Slack = slack
	rope_end.kv.Subdiv = subdivisions
	rope_end.kv.Width = "2"
	rope_end.kv.TextureScale = "1"
	rope_end.kv.RopeMaterial = "cable/cable.vmt"

	Table.start <- rope_start
	Table.mid <- rope_mid
	Table.end <- rope_end

	return Table
}

void function ZiplineMoverRealTime( entity ent, entity end, float timeTotal )
{
	Assert( !IsThreadTop(), "This should not be waitthreaded off, it creates timing issues." )
	entity mover = CreateScriptMover( ent.GetOrigin(), ent.GetAngles() )
	ent.SetParent( mover )

	OnThreadEnd(
		function() : ( ent, mover )
		{
			if ( IsValid( mover ) )
				mover.Destroy()
		}
	)

	float endTime = Time() + timeTotal
	while( Time() < endTime )
	{
		float timeLeft = endTime - Time()
		mover.NonPhysicsMoveTo( end.GetOrigin(), timeLeft, 0, 0 )
		WaitFrame()
	}

	if ( IsValid( ent ) )
		ent.SetParent( end )
}

void function CleanupZiplineGuy( entity guy, entity model )
{
	if ( !IsValid( guy ) )
		return

	if ( model != null )
	{
		if ( !IsValid( model ) && IsAlive( guy ) )
		{
			// try to transfer the last attacker from the ship to the attached guys.
			entity attacker = null
			table sTable = expect table( model.s )
			if ( "lastAttacker" in sTable && IsValid( sTable.lastAttacker ) )
				attacker = expect entity( sTable.lastAttacker )

			guy.TakeDamage( 500, attacker, attacker, null )
		}
	}

	if ( guy.l.customZiplineDeployTime )
		return

	guy.ClearParent()
	StopSoundOnEntity( guy, "3p_zipline_loop" )
	EmitSoundOnEntity( guy, "3p_zipline_detach" )

	if ( !IsAlive( guy ) )
	{
		guy.Anim_Stop()
		guy.BecomeRagdoll( Vector(0,0,0), false )
	}
}

void function S2SZiplineRetracts( table zipline, entity dropNode, entity mover )
{
	if ( !( "start" in zipline ) )
		return
	entity eStart 	= expect entity( zipline.start )
	entity eMid 	= expect entity( zipline.mid )
	entity eEnd 	= expect entity( zipline.end )
	entity ship 	= expect entity( zipline.ship )
	float time  	= expect float( zipline.retractTime )
	if ( !IsValid( eStart ) )
		return
	if ( !IsValid( eMid ) )
		return
	if ( !IsValid( eEnd ) )
		return

	OnThreadEnd(
		function() : ( eStart, eMid, eEnd, dropNode, mover )
		{
			if ( IsValid( eStart ) )
				eStart.Destroy()

			if ( IsValid( eMid ) )
				eMid.Destroy()

			if ( IsValid( eEnd ) )
				eEnd.Destroy()

			if ( IsValid( dropNode ) )
				dropNode.Destroy()

			if ( IsValid( mover ) )
				mover.Destroy()
		}
	)

	// IsValid check succeeds, even if a delete brought us here.
	// IsValid should've failed.
	if ( !IsValid( ship ) )
		return

	ship.EndSignal( "OnDestroy" )
	eStart.EndSignal( "OnDestroy" )
	eMid.EndSignal( "OnDestroy" )
	eEnd.EndSignal( "OnDestroy" )

	float len = Distance( eStart.GetOrigin(), eEnd.GetOrigin() )
	float wiggleMagnitude = 0.08
	float wiggleSpeed = 5.0
	float wiggleLengthFrac = 0.99  // after rope reaches this fraction of the total length, stop wiggling
	// RopeWiggle( maxlen, wiggleMagnitude, wiggleSpeed, duration, fadeDuration )
	eStart.RopeWiggle( len * wiggleLengthFrac, wiggleMagnitude, wiggleSpeed, time * wiggleLengthFrac, time )

	ZiplineMoverRealTime( eStart, eEnd, time )
	wait time
}

void function LegacyHookOrigin( entity guy, entity model, table Table )
{
	entity dropNode = expect entity( Table.hullNode )

	vector attachOrigin = model.GetAttachmentOrigin( expect int( Table.attachIndex ) )
	var hookOrigin  	= GetHookOriginFromNode( guy.GetOrigin(), dropNode.GetOrigin(), attachOrigin )

	// couldn't find a place to hook it? This needs to be tested on precompile
	if ( !hookOrigin )
	{
		#if DEV
			printt( "WARNING! Bad zipline dropship position!" )
			if ( DEV_DRAWDEPLOY && GetMoDevState() )
			{
				DebugDrawLine( guy.GetOrigin(), dropNode.GetOrigin(), 255, 120, 0, true, 8.0 )
				DebugDrawCircle( dropNode.GetOrigin(), <0,0,0>, 4, 255, 120, 0, true, 8.0 )
				DebugDrawCircle( dropNode.GetOrigin(), <0,0,0>, 8, 255, 120, 0, true, 8.0 )
				DebugDrawCircle( dropNode.GetOrigin(), <0,0,0>, 12, 255, 120, 0, true, 8.0 )
				DebugDrawCircle( dropNode.GetOrigin(), <0,0,0>, 16, 255, 120, 0, true, 8.0 )
			}
		#endif
		WaitForever()
	}
	else
	{
		#if DEV
			if ( DEV_DRAWDEPLOY && GetMoDevState() )
			{
				DebugDrawLine( guy.GetOrigin(), dropNode.GetOrigin(), 0, 202, 255, true, 1.0 )
				DebugDrawCircle( dropNode.GetOrigin(), <0,0,0>, 4, 0, 202, 255, true, 1.0 )
			}
		#endif
	}

	Table.hookOrigin <- hookOrigin
}

void function LegacyTableForward( entity guy, table Table, entity dropNode )
{
	if ( "forward" in Table )
		return

	// the sequence ended before the guy reached the ground
	vector start = guy.GetOrigin()
	// this needs functionification
	vector end = dropNode.GetOrigin() + Vector( 0,0,-80 )
	TraceResults result = TraceLine( start, end, guy )
	vector angles = guy.GetAngles()
	Table.forward <- AnglesToForward( angles )
	Table.origin <- result.endPos
}

table function S2SCreateDropshipAnimTable( entity model, string side, int seat )
{
	table<string, array<table<string, string> > > anims
	anims[ "left" ] <- []
	anims[ "left" ].append( { idle = "pt_dropship_rider_L_A_idle", attach = "RopeAttachLeftA" } )
	anims[ "left" ].append( { idle = "pt_dropship_rider_L_C_idle", attach = "RopeAttachLeftC" } )
	anims[ "left" ].append( { idle = "pt_dropship_rider_L_B_idle", attach = "RopeAttachLeftB" } )
	anims[ "left" ].append( { idle = "pt_dropship_rider_L_A_idle", attach = "RopeAttachLeftA" } )

	anims[ "right" ] <- []
	anims[ "right" ].append( { idle = "pt_dropship_rider_R_A_idle", attach = "RopeAttachRightA" } )
	anims[ "right" ].append( { idle = "pt_dropship_rider_R_C_idle", attach = "RopeAttachRightC" } )
	anims[ "right" ].append( { idle = "pt_dropship_rider_R_B_idle", attach = "RopeAttachRightB" } )
	anims[ "right" ].append( { idle = "pt_dropship_rider_R_A_idle", attach = "RopeAttachRightA" } )

	table Table = {}

	Table.idleAnim			<- anims[ side ][ seat ].idle
	Table.deployAnim		<- "zipline"
	Table.shipAttach 		<- anims[ side ][ seat ].attach
	Table.attachIndex 		<- null
	Table.ship 				<- model
	Table.side				<- side
	Table.blendTime			<- DEFAULT_SCRIPTED_ANIMATION_BLEND_TIME

	return Table
}

void function AddZiplineDeployNodes( ShipStruct ship, array<entity> nodes )
{
	Assert( nodes.len() == 3 )
	ship.zipLineNodes = nodes
}

array<entity> function GetZipHullNodes( ShipStruct ship, string side )
{
	//check hand picked nodes
	if ( ship.zipLineNodes.len() )
		return ship.zipLineNodes

	ShipStruct ornull followShip = GetDeployShip( ship )
	expect ShipStruct( followShip )
	vector pos 		= GetDeployPos( ship )
	float range 	= 32
	float dist 		= 128
	vector anglesC 	= <0, ship.model.GetAngles().y, 0>
	vector anglesL, anglesR
	vector forward, back, offset, origin
	TraceResults result

	switch ( side )
	{
		case "left":
			anglesC = AnglesCompose( anglesC, <0,90,0> )
			anglesL = AnglesCompose( anglesL, <0,90,0> )
			anglesR = AnglesCompose( anglesR, <0,-90,0> )
			break

		case "right":
			anglesC = AnglesCompose( anglesC, <0,-90,0> )
			anglesL = AnglesCompose( anglesL, <0,90,0> )
			anglesR = AnglesCompose( anglesR, <0,-90,0> )
			break
	}

	forward  	= AnglesToForward( anglesC ) * dist
	back  		= AnglesToForward( anglesC ) * -dist * 0.5
	offset 		= < RandomFloatRange( -range, range ), RandomFloatRange( -range, range ), 0 >
	origin 		= LocalPosToWorldPos( pos + forward + back + offset, followShip.model )
	result 		= TraceLine( origin + Vector(0,0,500), origin - Vector(0,0,1000), [], TRACE_MASK_NPCSOLID, TRACE_COLLISION_GROUP_NPC )
	origin 		= result.endPos
	entity nodeC = CreateScriptMover( origin )
	nodeC.SetParent( followShip.model, "", true )

	forward  	= AnglesToForward( anglesL ) * dist
	offset 		= < RandomFloatRange( -range, range ), RandomFloatRange( -range, range ), 0 >
	origin 		= LocalPosToWorldPos( pos + forward + back + offset, followShip.model )
	result 		= TraceLine( origin + Vector(0,0,500), origin - Vector(0,0,1000), [], TRACE_MASK_NPCSOLID, TRACE_COLLISION_GROUP_NPC )
	origin 		= result.endPos
	entity nodeL = CreateScriptMover( origin )
	nodeL.SetParent( followShip.model, "", true )

	forward  	= AnglesToForward( anglesR ) * dist
	offset 		= < RandomFloatRange( -range, range ), RandomFloatRange( -range, range ), 0 >
	origin 		= LocalPosToWorldPos( pos + forward + back + offset, followShip.model )
	result 		= TraceLine( origin + Vector(0,0,500), origin - Vector(0,0,1000), [], TRACE_MASK_NPCSOLID, TRACE_COLLISION_GROUP_NPC )
	origin 		= result.endPos
	entity nodeR = CreateScriptMover( origin )
	nodeR.SetParent( followShip.model, "", true )

	array<entity> hullNodes = [ nodeL, nodeR, nodeC ]
	return hullNodes
}

/************************************************************************************************\

██████╗  ██████╗  ██████╗ ██████╗ ███████╗
██╔══██╗██╔═══██╗██╔═══██╗██╔══██╗██╔════╝
██║  ██║██║   ██║██║   ██║██████╔╝███████╗
██║  ██║██║   ██║██║   ██║██╔══██╗╚════██║
██████╔╝╚██████╔╝╚██████╔╝██║  ██║███████║
╚═════╝  ╚═════╝  ╚═════╝ ╚═╝  ╚═╝╚══════╝

\************************************************************************************************/
void function Event_GoblinAnimOpenDoor( ShipStruct ship, entity player, int eventID )
{
	if ( IsDoorOpenOrOpening( ship ) )
		return

	string side = GetBestSideFromEvent( ship, player, eventID )
	DropshipAnimateOpen( ship, side )
}

void function DropshipAnimateOpen( ShipStruct ship, string side )
{
	entity mover = ship.mover

	ship.model.EndSignal( "OnDestroy" )
	EndSignal( ship, "FakeDeath" )
	mover.EndSignal( "OnDestroy" )

	int openingState, openState
	string riderTag, anim, idle
	switch( side )
	{
		case "left":
			openState = eDoorState.OPEN_L
			openingState = eDoorState.OPENING_L
			riderTag = "ORIGIN"
			anim = "dropship_open_doorL"
			idle = "dropship_open_doorL_idle"
			break

		case "right":
			openState = eDoorState.OPEN_R
			openingState = eDoorState.OPENING_R
			riderTag = "RESCUE"
			anim = "dropship_open_doorR"
			idle = "dropship_open_doorR_idle"
			break
	}

	foreach ( index, guy in ship.guys )
		GoblinRiderAnimate( guy, ship.model, index, riderTag )

	ship.doorState = openingState
	Signal( ship, "DoorsOpening" )
	EndSignal( ship, "DoorsClosing" )

	entity player = ship.chaseEnemy
	RunShipEventCallbacks( ship, eShipEvents.SHIP_ONOPENDOOR, player )

	waitthread PlayAnim( ship.model, anim, mover )
	ship.doorState = openState

	thread PlayAnim( ship.model, idle, mover )
}

void function Event_GoblinOnOpenDoor( ShipStruct ship, entity player, int eventID )
{
	if ( !IsValid( player ) || !player.IsPlayer() )
		return

	if ( Time() < S2S_VOtime )
		return
	S2S_VOtime = Time() + VOBUFFER

	array<string> text = [	"There he is! Open fire!",
							"Contact in sight! Weapons Clear!",
							"He's down there! Follow my tracers!",
							"I see him! I see him! Engaging!",
							"Where is he! There! There!" ]
	//Dev_PrintMessage( player, "", text.getrandom(), 5 )//hack
}

void function Event_GoblinAnimCloseDoor( ShipStruct ship, entity player, int eventID )
{
	if ( IsDoorClosedOrClosing( ship ) )
		return

	entity mover = ship.mover
	DropshipAnimateClose( ship, mover, "" )
}

void function DropshipAnimateClose( ShipStruct ship, entity mover, string side )
{
	ship.model.EndSignal( "OnDestroy" )
	EndSignal( ship, "FakeDeath" )
	mover.EndSignal( "OnDestroy" )

	int closingState, closeState
	string anim, idle

	if ( side == "" )
	{
		switch ( ship.doorState )
		{
			case eDoorState.OPEN_L:
			case eDoorState.OPENING_L:
				side = "left"
				break

			case eDoorState.OPEN_R:
			case eDoorState.OPENING_R:
				side = "right"
				break

			default:
				Assert( 0 )
				break
		}
	}

	switch( side )
	{
		case "left":
			closeState = eDoorState.CLOSED
			closingState = eDoorState.CLOSING_L
			anim = "dropship_close_doorL"
			idle = "dropship_closed_idle_alt"
			break

		case "right":
			closeState = eDoorState.CLOSED
			closingState = eDoorState.CLOSING_R
			anim = "dropship_close_doorR"
			idle = "dropship_closed_idle_alt"
			break

		default:
			Assert( 0 )
			break
	}

	ship.doorState = closingState
	Signal( ship, "DoorsClosing" )
	EndSignal( ship, "DoorsOpening" )

	entity player = ship.chaseEnemy
	RunShipEventCallbacks( ship, eShipEvents.SHIP_ONCLOSEDOOR, player )

	waitthread PlayAnim( ship.model, anim, mover )
	ship.doorState = closeState

	thread PlayAnim( ship.model, idle, mover )
}

void function Event_GoblinOnCloseDoor( ShipStruct ship, entity player, int eventID )
{
	if ( !IsValid( player ) || !player.IsPlayer() )
		return

	if ( Time() < S2S_VOtime )
		return
	S2S_VOtime = Time() + VOBUFFER

	array<string> text = [	"He switched sides, Hold on! In Pursuit!",
							"He's on the other side of the hull!",
							"We need to get closer, moving to engage!",
							"Can't get a clear shot! Shifting sides!",
							"Hold on! I'm bringing us in closer!" ]
	//Dev_PrintMessage( player, "", text.getrandom(), 5 )//hack
}

/************************************************************************************************\

██████╗ ██╗██████╗ ███████╗██████╗ ███████╗
██╔══██╗██║██╔══██╗██╔════╝██╔══██╗██╔════╝
██████╔╝██║██║  ██║█████╗  ██████╔╝███████╗
██╔══██╗██║██║  ██║██╔══╝  ██╔══██╗╚════██║
██║  ██║██║██████╔╝███████╗██║  ██║███████║
╚═╝  ╚═╝╚═╝╚═════╝ ╚══════╝╚═╝  ╚═╝╚══════╝

\************************************************************************************************/
void function GoblinRiderOnDamaged( entity guy, var damageInfo )
{
	entity inflictor = DamageInfo_GetInflictor( damageInfo )
	if ( IsValid( inflictor ) && inflictor.GetTeam() == guy.GetTeam() )
		DamageInfo_SetDamage( damageInfo, 0 )
}

void function ShipWaitSignalOrTimeout( ShipStruct ship, string signal, float timeout )
{
	EndSignal( ship, signal )
	wait timeout
}

void function GoblinRiderAnimate( entity guy, entity model, int index, string tag )
{
	if ( !IsValid( guy ) )
		return
	if ( guy.IsNPC() && !IsAlive( guy ) )
		return

	array<string> idles = [ "pt_S2S_crew_A_idle",
						"pt_S2S_crew_B_idle",
						"pt_S2S_crew_C_idle",
						"pt_S2S_crew_D_idle" ]

	if ( tag == "RESCUE" )
	{
		idles = [ 	"pt_S2S_crew_D_idle",
					"pt_S2S_crew_C_idle",
					"pt_S2S_crew_B_idle",
					"pt_S2S_crew_A_idle" ]
	}

	guy.SetParent( model, tag )
	thread PlayAnim( guy, idles[ index ], model, tag )
}

void function GoblinPilotAnimate( entity guy, ShipStruct ship )
{
	guy.EndSignal( "OnDestroy" )
	guy.EndSignal( "OnDeath" )
	EndSignal( ship, "FakeDestroy" )

	OnThreadEnd(
	function() : ( guy, ship )
		{
			if ( !IsAlive( guy ) )
				Signal( ship, "pilotDead" )
		}
	)

	guy.SetParent( ship.model, "ORIGIN" )

	thread PlayAnim( guy, "Militia_flyinA_idle_mac", ship.model, "ORIGIN")

	guy.WaitSignal( "OnDeath" )
}

void function GoblinRiderDeploySide( entity guy, int index, ShipStruct ship, string side, table<string, int> deployTable )
{
	guy.EndSignal( "OnDeath" )
	guy.Signal( "deploy" )

	OnThreadEnd(
	function() : ( ship, deployTable )
		{
			deployTable.numGuys--
			if ( deployTable.numGuys == 0 )
				Signal( ship, "crewDeployed" )
		}
	)

	string attach
	switch( side )
	{
		case "left":
			attach = "RESCUE"
			break

		case "right":
			attach = "ORIGIN"
			break
	}

	//init
	guy.SetParent( ship.model, attach )
	guy.SetEfficientMode( true )

	//deploy
	string[4] deployAnims = DropOffAISide_GetDeployAnims()
	float[4] seekTimes = DropOffAISide_GetSeekTimes()

	thread PlayAnimTeleport( guy, deployAnims[ index ], ship.model, attach )
	guy.Anim_SetInitialTime( seekTimes[ index ] + 2.0 )

	guy.WaitSignal( "not_solid" ) //HACK -> the ship crushes the guy when he unparents
	guy.NotSolid()

	WaittillAnimDone( guy )
	guy.Solid()

	guy.SetEfficientMode( false )

	//disperse
//	string[4] disperseAnims = DropOffAISide_GetDisperseAnims()
//	var origin = HackGetDeltaToRef( guy.GetOrigin(), guy.GetAngles(), guy, disperseAnims[ index ] ) + Vector( 0,0,2 )
//	expect vector( origin )

//	waitthread PlayAnimGravity( guy, disperseAnims[ index ], origin, guy.GetAngles() )
	DeployFuncWrapper( ship, guy )
}