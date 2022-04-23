untyped
global function StartSpawn
global function RespawnPlayer
global function AddMakeSpecifcRespawns
global function CodeCallback_OnPlayerKilled
global function RestartMapWithDelay
global function MakePlayerPilot
global function MakePlayerTitan
global function AddFunctionForMapRespawn


struct {
    table< string, void functionref( entity ) > CustomMapRespawns
	table< string, void functionref( entity ) > CustomMapRespawnsFunction
} file


void function AddMakeSpecifcRespawns()
{
    file.CustomMapRespawns["sp_s2s"] <- s2sRespawn
}


void function StartSpawn( entity player )
{
    // Player was already positioned at info_player_start in SpPlayerConnecting.
	// Don't reposition him, in case movers have already pushed him.
	// No, will
	
	CheckPointInfo info = GetCheckPointInfo()

	Chat_ServerPrivateMessage( player, "use 'say smth' in the console to chat ", false )

	if ( "sp_s2s" == GetMapName() && info.player0 != player && GetPlayerArray().len() != 1 )
	{
		thread file.CustomMapRespawns["sp_s2s"]( player )
		return
	}
	else if ( info.pos != <0,0,0> )
	{
		player.SetOrigin( info.pos )

		if ( info.RsPilot )
			thread MakePlayerTitan( player, info.pos )
	}

	OnTimeShiftGiveGlove( player )

	player.kv.CollisionGroup = TRACE_COLLISION_GROUP_BLOCK_WEAPONS // remove collision between players
	DoRespawnPlayer( player, null )
	AddPlayerMovementEventCallback( player, ePlayerMovementEvents.BEGIN_WALLRUN, Callback_WallrunBegin )
}

void function RespawnPlayer( entity player )
{
	// WaitSignal( player, "RespawnNow" )

	wait( 1 )

	if ( !IsAlive( player ) )
    {
        printl("Respawning player:" + player.GetPlayerName() )

		if ( GetPlayerArray().len() == 1 )
            thread RestartMapWithDelay()
        else if ( GetMapName() in file.CustomMapRespawns )
            thread file.CustomMapRespawns[GetMapName()]( player )
        else
            thread GenericRespawn( player )
	}
}

void function RestartMapWithDelay()
{
    wait(1)
    GameRules_ChangeMap( GetMapName() , GAMETYPE )
}

void function BasicRespawnLogic( entity player )
{
	player.kv.CollisionGroup = TRACE_COLLISION_GROUP_BLOCK_WEAPONS // remove collision between players
    player.s.inPostDeath = false
    player.s.respawnSelectionDone = true
    DoRespawnPlayer( player, null )
    ClientCommand(player,"script_client thread MainHud_TurnOn_RUI( true )")
    ScreenFadeFromBlack( player, 0.0, 0.0 )

    PilotLoadoutDef loadout = GetPilotLoadoutForCurrentMapSP()
	GivePilotLoadout( player, loadout )
}

void function GenericRespawn( entity player )
{        
    wait( 1 )
    while( !IsAlive( player ) ) 
    {
        foreach( p in GetPlayerArray() )
        {
            if (p != player && p.IsOnGround() )
            {
                try
                {
                    BasicRespawnLogic( player )
                    player.SetOrigin( p.GetOrigin() )

                    if ( p.IsTitan() )
                    {
                        thread MakePlayerTitan( player, p.GetOrigin() )
                    }
                    OnTimeShiftGiveGlove( player )
                }
                catch( exception ){
                    return
                }	
            }
        }
        wait(0.5)
    }
}

void function s2sRespawn( entity player )
{
	wait 1
	if ( "sp_s2s" in file.CustomMapRespawnsFunction )
		thread file.CustomMapRespawnsFunction["sp_s2s"]( player )

	wait 2

	if ( !IsAlive( player ) && IsValid( player ) )
    {
        thread GenericRespawn( player )
    }
}

// long functions
void function DoHudDisplayForDeadPlayerThenReloadServer( entity player )
{
	// printl("DoHudDisplayForDeadPlayerThenReloadServer Called!")

	// array<entity> players = GetPlayerArray()
	// string Coop_Dead_Player = player.GetPlayerName()
	// 	foreach (entity p in players){
	// 			if (p != null){
	// 			SendHudMessage( p , Coop_Dead_Player + "Fucked up, laugh at them." , -1, 0.4, 255, 255, 0, 0, 0.15, 6, 0.15 )
	// 			//ClientCommand( p , "RespawnNowSP" )
	// 			}
	//		}
	//wait 3.0
	//ServerCommand( "reload" )
	//player.Signal( "OnRespawned" )
	//player.EndSignal( "OnDestroy" )


	//player.RespawnPlayer(null)
	// player.WaitSignal("RespawnNow")
	// RespawnPlayer(player)

	// CodeCallback_OnPlayerRespawned(player)
	//player.EndSignal( "RespawnNow" )
	//player.EndSignal( "OnRespawned" )
	//player.EndSignal( "RespawnNow" )
}

void function CodeCallback_OnPlayerKilled( entity player, var damageInfo )
{
	// thread DoHudDisplayForDeadPlayerThenReloadServer( player )
	thread PostDeathThread_SP( player, damageInfo )

}

function PostDeathThread_SP( entity player, damageInfo )
{
	printl("PostDeathThread_SP Called!")
	array<entity> players = GetPlayerArray()
	string Coop_Dead_Player = player.GetPlayerName()
	foreach (entity p in players){
		if (p != null){
			SendHudMessage( p , Coop_Dead_Player + " Fucked up, laugh at them." , -1, 0.4, 255, 255, 0, 0, 0.15, 6, 0.15 )
		}
	}
	if ( player.p.watchingPetTitanKillReplay )
		return
	
	thread RespawnPlayer(player)

	float timeOfDeath = Time()
	player.p.postDeathThreadStartTime = Time()

	Assert( IsValid( player ), "Not a valid player" )
	printl("PreSignal:Ondestroy")
	player.EndSignal( "OnDestroy" )
	printl("AfterSignal:Ondestroy")
	printl("PreSignal:OnRespawned")
	player.EndSignal( "OnRespawned" )
	printl("AfterSignal:OnRespawned")

	player.p.deathOrigin = player.GetOrigin()
	player.p.deathAngles = player.GetAngles()

	player.s.inPostDeath = true
	player.s.respawnSelectionDone = false

	player.cloakedForever = false
	player.stimmedForever = false
	player.SetNoTarget( false )
	player.SetNoTargetSmartAmmo( false )
	player.ClearExtraWeaponMods()

	entity attacker = DamageInfo_GetAttacker( damageInfo )
	int methodOfDeath = DamageInfo_GetDamageSourceIdentifier( damageInfo )

	player.p.rematchOrigin = player.p.deathOrigin
	if ( IsValid( attacker ) && methodOfDeath == eDamageSourceId.titan_execution )
	{
		// execution can throw you out of the map
		player.p.rematchOrigin = attacker.GetOrigin()
	}

	int attackerViewIndex = attacker.GetIndexForEntity()

	player.SetPredictionEnabled( false )
	player.Signal( "RodeoOver" )
	printl("AfterSignal:RodeoOver")
	player.ClearParent()
	printl("ClearParent")

	bool showedDeathHint = ShowDeathHintSP( player, damageInfo )
	printl("AfterShowDeathHint"+showedDeathHint)
	CodeCallback_OnPlayerRespawned(player)
	int damageSource = DamageInfo_GetDamageSourceIdentifier( damageInfo )
	if ( damageSource != eDamageSourceId.fall )
	{
		player.StartObserverMode( OBS_MODE_DEATHCAM )
		if ( ShouldSetObserverTarget( attacker ) )
			player.SetObserverTarget( attacker )
		else
			player.SetObserverTarget( null )
	}




	//ReloadForMissionFailure( reloadExtraDelay )
	// ClientCommand(player,"CC_RespawnPlayer")
	// player.RespawnPlayer(null)
	// DoHudDisplayForDeadPlayerThenReloadServer( player )
	//ScreenFadeFromBlack( player, 1.0, 0.75 )

}


void function MakePlayerTitan( entity player, vector destination )
{
	entity soul = GetSoulFromPlayer( player )
	entity titan
	if ( !IsValid( soul ) )
	{
		CreatePetTitanAtLocation( player, player.GetOrigin(), player.GetAngles() )
		titan = player.GetPetTitan()
		if ( titan != null )
			titan.kv.alwaysAlert = false
	}
	if ( player.IsTitan() )
	{
		titan = soul.GetTitan()
		titan.SetOrigin( player.GetOrigin() )
		WaitFrame()
		waitthread PilotBecomesTitan( player, titan )
		titan.Destroy()
		WaitFrame()
		player.SetOrigin( destination )
	}
}

void function MakePlayerPilot( entity player, vector destination  )
{
	entity soul = GetSoulFromPlayer( player )
	if ( IsValid( soul ) && !player.IsTitan() )
	{		
		waitthread TitanBecomesPilot( player, player.GetPetTitan() )
		WaitFrame()
		player.SetOrigin( destination )
	}
}


void function AddFunctionForMapRespawn( string map, void functionref( entity ) func )
{
	if ( map in file.CustomMapRespawnsFunction )
		file.CustomMapRespawnsFunction[map] = func
	else
		file.CustomMapRespawnsFunction[map] <- func
}