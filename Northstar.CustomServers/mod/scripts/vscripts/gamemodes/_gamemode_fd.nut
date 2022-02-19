global function GamemodeFD_Init
global function RateSpawnpoints_FD
global function useHarvesterShieldBoost
global function spawnSmokes
global function waveStart
global function startHarvester

global HarvesterStruct harvesterStruct

struct {
	array<entity> aiSpawnpoints
	array<entity> smokePoints
	array<entity> routeNodes
	table<string,float> harvesterDamageSource
	bool haversterWasDamaged
}file

void function GamemodeFD_Init()
{
	PrecacheModel( MODEL_ATTRITION_BANK )
	PrecacheParticleSystem($"P_smokescreen_FD")
	AddCallback_EntitiesDidLoad(LoadEntities)
	AddDamageCallback("prop_script",OnDamagedPropScript)

}

void function RateSpawnpoints_FD(int _0, array<entity> _1, int _2, entity _3)
{

}

bool function useHarvesterShieldBoost() //returns true when acturally used
{
	if(harvesterStruct.harvester.GetShieldHealth()<harvesterStruct.harvester.GetShieldHealthMax())
	{
		thread useHarvesterShieldBoost_threaded()
			return true
	}
	return false
}
void function useHarvesterShieldBoost_threaded()
{
	harvesterStruct.shieldBoost = true
	wait 5
	harvesterStruct.shieldBoost = false
}

void function spawnSmokes()
{	
	entity owner = GetPlayerArray()[0]
	foreach(entity pos in file.smokePoints)
	{
		SmokescreenStruct smokescreen
		smokescreen.smokescreenFX = $"P_smokescreen_FD"
		smokescreen.ownerTeam = owner.GetTeam()
		smokescreen.damageSource = eDamageSourceId.mp_weapon_grenade_electric_smoke
		smokescreen.deploySound1p = "explo_electric_smoke_impact"
		smokescreen.deploySound3p = "explo_electric_smoke_impact"
		smokescreen.isElectric = false
		smokescreen.origin = pos.GetOrigin()+<0,0,150>
		smokescreen.angles = pos.GetAngles()
		smokescreen.lifetime = 30
		smokescreen.fxXYRadius = 150
		smokescreen.fxZRadius = 120
		smokescreen.fxOffsets = [ <120.0, 0.0, 0.0>,<0.0, 120.0, 0.0>, <0.0, 0.0, 0.0>,<0.0, -120.0, 0.0>,< -120.0, 0.0, 0.0>, <0.0, 100.0, 0.0>]
		Smokescreen(smokescreen)
	}
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
	array<int> enemys = [eFD_AITypeIDs.TITAN,eFD_AITypeIDs.GRUNT,-1,-1,-1,-1,-1,-1,-1]
	
	SetGlobalNetInt("FD_currentWave",2)
	SetGlobalNetBool("FD_waveActive",true)
	SetGlobalNetInt(FD_GetAINetIndex_byAITypeID( eFD_AITypeIDs.TITAN), 69)
	SetGlobalNetInt(FD_GetAINetIndex_byAITypeID( eFD_AITypeIDs.GRUNT), 420)

	foreach(entity player in GetPlayerArray())
	{
		
		Remote_CallFunction_NonReplay(player,"ServerCallback_FD_AnnouncePreParty",enemys[0],enemys[1],enemys[2],enemys[3],enemys[4],enemys[5],enemys[6],enemys[7],enemys[8])
	}


}


void function OnDamagedPropScript(entity prop,var damageInfo)
{	
	
	if(!IsValid(harvesterStruct.harvester))
		return
	
	if(!IsValid(prop))
		return
	
	if(harvesterStruct.harvester!=prop)
		return
	
	if(harvesterStruct.shieldBoost)
	{
		prop.SetShieldHealth(prop.GetShieldHealthMax())
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
	harvesterStruct.lastDamage = Time()
	if(prop.GetShieldHealth()==0)
	{
		float newHealth = prop.GetHealth()-damageAmount
		if(newHealth<0)
		{	
			EmitSoundAtPosition(TEAM_UNASSIGNED,harvesterStruct.harvester.GetOrigin(),"coop_generator_destroyed")
			newHealth=0
			harvesterStruct.rings.Destroy()
			
		}
			

		prop.SetHealth(newHealth)
		file.haversterWasDamaged = true
	}

	
	
}

void function HarvesterThink()
{	
	entity harvester = harvesterStruct.harvester

	
	EmitSoundOnEntity(harvester,"coop_generator_startup")
	float lastTime = Time()
	wait 4
	int lastShieldHealth = 6000
	HarvesterStruct temp = startHarvesterFX(harvesterStruct)
	harvesterStruct.particleBeam = temp.particleBeam
	harvesterStruct.particleShield = temp.particleShield
	wait 5
	EmitSoundOnEntity(harvester,"coop_generator_ambient_healthy")
	
	entity particleBeam = harvesterStruct.particleBeam
	entity particleShield = harvesterStruct.particleShield


	while(IsAlive(harvester)){
		float currentTime = Time()
		float deltaTime = currentTime -lastTime
		vector shieldColor = GraphCappedVector(harvester.GetShieldHealth(), 0, harvester.GetShieldHealthMax(),TEAM_COLOR_ENEMY, TEAM_COLOR_FRIENDLY)
		EffectSetControlPointVector( particleShield, 1, shieldColor )
		vector beamColor = GraphCappedVector(harvester.GetHealth(), 0, harvester.GetMaxHealth(), TEAM_COLOR_ENEMY, TEAM_COLOR_FRIENDLY)
		EffectSetControlPointVector( particleBeam, 1, beamColor )
		if(((currentTime-harvesterStruct.lastDamage)>=GENERATOR_SHIELD_REGEN_DELAY)&&(harvester.GetShieldHealth()<harvester.GetShieldHealthMax()))
		{	
			printt((currentTime-harvesterStruct.lastDamage))
			if(harvester.GetShieldHealth()==0)
				EmitSoundOnEntity(harvester,"coop_generator_shieldrecharge_start")
				EmitSoundOnEntity(harvester,"coop_generator_shieldrecharge_resume")
			float newShieldHealth = (harvester.GetShieldHealthMax()/GENERATOR_SHIELD_REGEN_TIME*deltaTime)+harvester.GetShieldHealth()
			if(newShieldHealth>=harvester.GetShieldHealthMax())
			{
				StopSoundOnEntity(harvester,"coop_generator_shieldrecharge_resume")
				harvester.SetShieldHealth(harvester.GetShieldHealthMax())
				EmitSoundOnEntity(harvester,"coop_generator_shieldrecharge_end")
				
			}
			else
			{
				harvester.SetShieldHealth(newShieldHealth)
			}
		}
		if((lastShieldHealth>0)&&(harvester.GetShieldHealth()==0))
			EmitSoundOnEntity(harvester,"coop_generator_shielddown")
		lastShieldHealth = harvester.GetShieldHealth()
		lastTime = currentTime
		WaitFrame()
	}
	
}
void function startHarvester(){
	
	thread HarvesterThink()
	thread HarvesterAlarm()

}


void function HarvesterAlarm()
{
	while(IsAlive(harvesterStruct.harvester))
	{
		if(harvesterStruct.harvester.GetShieldHealth()==0)
		{
			EmitSoundOnEntity(harvesterStruct.harvester,"coop_generator_underattack_alarm")
			wait 2.5
		}
		else
		{
			WaitFrame()
		}
	}
}

void function LoadEntities() 
{	
	SetGlobalNetInt("FD_totalWaves",5)
	SetGlobalNetInt("FD_restartsRemaining",2)
	CreateBoostStoreLocation(TEAM_MILITIA,getShopPosition(),<0,0,0>)
	OpenBoostStores()



	foreach ( entity info_target in GetEntArrayByClass_Expensive("info_target") )
	{
		
		if ( GameModeRemove( info_target ) )
			continue
		
		if(info_target.HasKey("editorclass")){
			switch(info_target.kv.editorclass){
				case"info_fd_harvester":
					HarvesterStruct ret = SpawnHarvester(info_target.GetOrigin(),info_target.GetAngles(),25000,6000,TEAM_IMC)
					harvesterStruct.harvester = ret.harvester
					harvesterStruct.rings = ret.rings
					harvesterStruct.lastDamage = ret.lastDamage
					
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