global function GamemodeFD_Init
global function RateSpawnpoints_FD


struct {
	array<entity> aiSpawnpoints
	array<entity> smokePoints
	array<entity> routeNodes
}file

void function GamemodeFD_Init()
{
	PrecacheModel( MODEL_ATTRITION_BANK )
	AddCallback_EntitiesDidLoad(LoadEntities)
}

void function RateSpawnpoints_FD(int _0, array<entity> _1, int _2, entity _3)
{

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



void function LoadEntities() 
{	
	CreateBoostStoreLocation(TEAM_MILITIA,getShopPosition(),<0,0,0>)
	



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