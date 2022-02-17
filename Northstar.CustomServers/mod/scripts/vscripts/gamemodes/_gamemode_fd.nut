global function GamemodeFD_Init
global function RateSpawnpoints_FD
global function useHarvesterShieldBoost


struct HarvesterStruct {
	entity harvester
	entity particleBeam
	entity particleShield
	entity rings
	float lastDamage
	bool shieldBoost
	
}

struct {
	array<entity> aiSpawnpoints
	array<entity> smokePoints
	array<entity> routeNodes
	HarvesterStruct harvester
	table<string,float> harvesterDamageSource
	bool haversterWasDamaged
}file

void function GamemodeFD_Init()
{
	PrecacheModel( MODEL_ATTRITION_BANK )
	AddCallback_EntitiesDidLoad(LoadEntities)
	AddDamageCallback("prop_script",OnDamagedPropScript)
}

void function RateSpawnpoints_FD(int _0, array<entity> _1, int _2, entity _3)
{

}

bool function useHarvesterShieldBoost() //returns true when acturally used
{
	if(file.harvester.harvester.GetShieldHealth()<file.harvester.harvester.GetShieldHealthMax())
	{
		thread useHarvesterShieldBoost_threaded()
		return true
	}
	return false
}
bool function useHarvesterShieldBoost_threaded()
{
	file.harvester.shieldBoost = true
	wait 5
	file.Harvester.shieldBoost = false
}

void function spawnSmokes()
{
	
}


array<entity> function getRoute(string routeName)
{
	foreach(entity node in file.routeNodes)
	{
		if(!node.HasKey("route_name"))
			continue
		if(node.kv.route_name==routeName)
			return node.GetLinkEntArray()
	}
	printt("Route not found")
	return []
}

vector function getShopPosition() 
{
	switch(GetMapName())
	{
		case"mp_forwardbase_kodai":
			return < -3862.13, 1267.69, 1060.06>
		default:
			return <0,0,0>
	}
	unreachable

}

void function waveStart()
{
	file.haversterWasDamaged = false
}


void function OnDamagedPropScript(entity prop,var damageInfo)
{	
	
	if(!IsValid(file.harvester.harvester))
		return
	
	if(!IsValid(prop))
		return
	
	if(file.harvester.harvester!=prop)
		return
	
	if(structHarvester.shieldBoost)
	{
		harvester.SetShieldHealth(harvester.GetShieldHealthMax())
		return
	}

	int damageSourceID = DamageInfo_GetDamageSourceIdentifier( damageInfo )
	entity attacker = DamageInfo_GetAttacker( damageInfo )
	float damageAmount = DamageInfo_GetDamage( damageInfo )
	
	if ( !damageSourceID )
		return

	if ( !damageAmount )
		return

	if ( !attacker )
		return
	//TODO Log damage source for round lose screen
	file.harvester.lastDamage = Time()
	if(prop.GetShieldHealth()==0)
	{
		float newHealth = prop.GetHealth()-damageAmount
		if(newHealth<0)
		{
			newHealth=0
			file.harvester.rings.Destroy()
		}
			

		prop.SetHealth(newHealth)
		file.haversterWasDamaged = true
	}

	
	
}

void function HarvesterThink(HarvesterStruct structHarvester)
{	
	entity harvester = structHarvester.harvester
	entity particleBeam = structHarvester.particleBeam
	entity particleShield = structHarvester.particleShield
	

	float lastTime = Time()
	WaitFrame()

	

	while(IsAlive(harvester)){
		float currentTime = Time()
		float deltaTime = currentTime -lastTime
		vector shieldColor = GraphCappedVector(harvester.GetShieldHealth(), 0, harvester.GetShieldHealthMax(),TEAM_COLOR_ENEMY, TEAM_COLOR_FRIENDLY)
		EffectSetControlPointVector( particleShield, 1, shieldColor )
		vector beamColor = GraphCappedVector(harvester.GetHealth(), 0, harvester.GetMaxHealth(), TEAM_COLOR_ENEMY, TEAM_COLOR_FRIENDLY)
		EffectSetControlPointVector( particleBeam, 1, beamColor )
		if(((currentTime-structHarvester.lastDamage)>=GENERATOR_SHIELD_REGEN_DELAY)&&(harvester.GetShieldHealth()<harvester.GetShieldHealthMax()))
		{	
			printt((currentTime-structHarvester.lastDamage))
			float newShieldHealth = (harvester.GetShieldHealthMax()/GENERATOR_SHIELD_REGEN_TIME*deltaTime)+harvester.GetShieldHealth()
			if(newShieldHealth>=harvester.GetShieldHealthMax())
			{
				harvester.SetShieldHealth(harvester.GetShieldHealthMax())
			}
			else
			{
				harvester.SetShieldHealth(newShieldHealth)
			}
		}
		lastTime = currentTime
		WaitFrame()
	}
	
}

void function LoadEntities() 
{	
	CreateBoostStoreLocation(TEAM_MILITIA,getShopPosition(),<0,0,0>)
	OpenBoostStores()



	foreach ( entity info_target in GetEntArrayByClass_Expensive("info_target") )
	{
		
		if ( GameModeRemove( info_target ) )
			continue
		
		if(info_target.HasKey("editorclass")){
			switch(info_target.kv.editorclass){
				case"info_fd_harvester":
					entity harvester = CreateEntity( "prop_script" )
					harvester.SetValueForModelKey( $"models/props/generator_coop/generator_coop.mdl" )
					harvester.SetOrigin( info_target.GetOrigin() )
					harvester.SetAngles( info_target.GetAngles() )
					harvester.kv.solid = SOLID_VPHYSICS
					
					harvester.SetMaxHealth(25000)
					harvester.SetHealth(25000)
					harvester.SetShieldHealthMax(6000)
					harvester.SetShieldHealth(6000)
					SetTeam(harvester,TEAM_IMC)
					DispatchSpawn( harvester )
					
					SetGlobalNetEnt("FD_activeHarvester",harvester)
					
					// entity blackbox = CreatePropDynamic(MODEL_HARVESTER_TOWER_COLLISION,info_target.GetOrigin(),info_target.GetAngles(),6)
					// blackbox.Hide()
					// blackbox.kv.CollisionGroup = TRACE_COLLISION_GROUP_PLAYER					
					
					entity rings = CreatePropDynamic(MODEL_HARVESTER_TOWER_RINGS,info_target.GetOrigin(),info_target.GetAngles(),6)
					thread PlayAnim( rings, "generator_cycle_fast" )
					
					entity Harvester_Beam = StartParticleEffectOnEntity_ReturnEntity(harvester,GetParticleSystemIndex(FX_HARVESTER_BEAM),FX_PATTACH_ABSORIGIN_FOLLOW,0)
					EffectSetControlPointVector( Harvester_Beam, 1, < 126.0, 188.0, 236.0 > )
					entity Harvester_Shield = StartParticleEffectOnEntity_ReturnEntity(harvester,GetParticleSystemIndex(FX_HARVESTER_OVERSHIELD),FX_PATTACH_ABSORIGIN_FOLLOW,0)
					EffectSetControlPointVector( Harvester_Shield, 1, < 126.0, 188.0, 236.0 > )

					file.harvester.harvester = harvester
					file.harvester.particleBeam = Harvester_Beam
					file.harvester.particleShield = Harvester_Shield
					file.harvester.lastDamage = Time()
					file.harvester.rings = rings
					thread HarvesterThink(file.harvester)
					break
				case"info_fd_mode_model":
					entity prop = CreatePropDynamic( info_target.GetModelName(), info_target.GetOrigin(), info_target.GetAngles(), 6 )
					break
				case"info_fd_ai_position":
					file.aiSpawnpoints.append(info_target)
					break
				case"info_fd_route_node":
					file.routeNodes.append(info_target)
					break
				case"info_fd_smoke_screen":
					file.smokePoints.append(info_target)
					break
			}
			
			
			
		}

		


	}
	
}