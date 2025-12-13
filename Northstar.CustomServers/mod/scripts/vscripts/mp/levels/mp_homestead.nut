global function CodeCallback_MapInit

void function CodeCallback_MapInit()
{
	AddSpawnCallback( "sky_camera", FixSkycamFog )
	
	// Load Frontier Defense Data
	if( GameRules_GetGameMode() == FD )
		initFrontierDefenseData()
}

void function FixSkycamFog( entity skycam )
{
	if ( skycam.GetTargetName() == "skybox_cam_level" )
		skycam.kv.useworldfog = 1
}