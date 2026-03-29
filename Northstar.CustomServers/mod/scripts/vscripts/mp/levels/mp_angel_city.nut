global function CodeCallback_MapInit

struct {
	int batteryIndex = 0
} file

const array<vector> BATTERY_SPAWNS = [
	< -1444.55, -1108.55, 127 >, // field
	< -730, 644, 121 >,          // mid
	< 535, 2657.67, 119 >        // bridge
]

void function CodeCallback_MapInit()
{
	AddEvacNode( CreateScriptRef( < 2527.889893, -2865.360107, 753.002991 >, < 0, -80.54, 0 > ) )
	AddEvacNode( CreateScriptRef( < 1253.530029, -554.075012, 811.125 >, < 0, 180, 0 > ) )
	AddEvacNode( CreateScriptRef( < 2446.989990, 809.364014, 576.0 >, < 0, 90.253, 0 > ) )
	AddEvacNode( CreateScriptRef( < -2027.430054, 960.395020, 609.007996 >, < 0, 179.604, 0 > ) )

	SetEvacSpaceNode( CreateScriptRef( < -1700, -5500, -7600 >, < -3.620642, 270.307129, 0 > ) )
	
	// Battery spawns (in LTS/Free Agents) are in old locations, so we move them to the proper locations
	AddSpawnCallbackEditorClass( "script_ref", "script_power_up_other", FixBatterySpawns )

	AddSpawnCallback( "sky_camera", FixSkycamFog )


	// Load Frontier Defense Data
	if( GameRules_GetGameMode() == FD )
		initFrontierDefenseData()

}

void function FixBatterySpawns( entity spawn )
{
	if ( GAMETYPE != LAST_TITAN_STANDING && GAMETYPE != FREE_AGENCY )
		return

	PowerUp powerupDef = GetPowerUpFromItemRef( expect string( spawn.kv.powerUpType ) )
	if ( powerupDef.spawnFunc() )
		spawn.SetOrigin( BATTERY_SPAWNS[file.batteryIndex++] )
}

void function FixSkycamFog( entity skycam )
{
	if ( skycam.GetTargetName() == "skybox_cam_level" )
		skycam.kv.useworldfog = 1
}