untyped
global function StartSpawn
global function RespawnPlayer
global function AddMapSpecifcRespawnsInit
global function AddMapSpecifcRespawns
global function CodeCallback_OnPlayerKilled
global function RestartMapWithDelay
global function MakePlayerPilot
global function MakePlayerTitan
global function AddFunctionForMapRespawn
global function DisableOnePlayerRestart
global function EnableOnePlayerRestart


struct {
    table< string, void functionref( entity ) > CustomMapRespawns
	table< string, void functionref( entity ) > CustomMapRespawnsFunction
	bool RestartMap = true
} file


void function AddMapSpecifcRespawnsInit()
{
    AddMapSpecifcRespawns("sp_s2s", s2sRespawn )
}

void function AddMapSpecifcRespawns( string map, void functionref( entity ) func )
{
	file.CustomMapRespawns[map] <- func
}


void function StartSpawn( entity player )
{
    // Player was already positioned at info_player_start in SpPlayerConnecting.
	// Don't reposition him, in case movers have already pushed him.
	// No, I will

	// log their UID
	printt( format( "%s : %s", player.GetPlayerName(), player.GetUID() ) )
	
	CheckPointInfo info = GetCheckPointInfo()

	Chat_ServerPrivateMessage( player, "use 'say smth' in the console to chat ", false )

	// for events
	thread RunMiddleFunc( player )

	if ( GetMapName() in file.CustomMapRespawns )
	{
		thread file.CustomMapRespawns[ GetMapName() ]( player )
		return
	}

	else if ( info.pos != <0,0,0> )
	{
		player.SetOrigin( info.pos )
		
		if ( !info.RsPilot )
			thread MakePlayerTitan( player, info.pos )
	}

	DoRespawnPlayer( player, null )
	// do we need this?
	// AddPlayerMovementEventCallback( player, ePlayerMovementEvents.BEGIN_WALLRUN, Callback_WallrunBegin )
	
	// give them map specific items
	OnTimeShiftGiveGlove( player )
	if ( ( GetMapName() == "sp_beacon" || GetMapName() == "sp_beacon_spoke0" ) && Flag( "HasChargeTool" ) )
		GiveBatteryChargeToolSingle( player )

	// massive trol
	// for( int x = 1; x < achievements.MAX_ACHIVEMENTS; x++ )
	// 	UnlockAchievement( player, x )
	// no more D:
}

void function RespawnPlayer( entity player )
{
	// really dangerous to enable this
	// since everything is scripted
	// stuff exepects people to be alive
	// we need to respawn people fast 
	// WaitSignal( player, "RespawnNow" )

	wait 1 

	if ( !IsAlive( player ) && IsValid( player ) )
    {
		UpdateSpDifficulty( player )

        printl("Respawning player:" + player.GetPlayerName() )

		if ( GetPlayerArray().len() == 1 && file.RestartMap )
            thread RestartMapWithDelay()
        else if ( GetMapName() in file.CustomMapRespawns )
            waitthread file.CustomMapRespawns[ GetMapName() ]( player )
        else
            waitthread GenericRespawn( player )
	}
}

void function RestartMapWithDelay()
{
    wait 1
    Coop_ReloadCurrentMapFromStartPoint( GetCurrentStartPointIndex() )
}

void function BasicRespawnLogic( entity player )
{
	player.kv.CollisionGroup = TRACE_COLLISION_GROUP_BLOCK_WEAPONS // remove collision between players ( I don't think it works XD )
    player.s.inPostDeath = false
    player.s.respawnSelectionDone = true
    DoRespawnPlayer( player, null )
    ClientCommand( player,"script_client thread MainHud_TurnOn_RUI( true )" ) // TODO: can this help with no hud on dedi?
    ScreenFadeFromBlack( player, 0.0, 0.0 )

    PilotLoadoutDef loadout = GetPilotLoadoutForCurrentMapSP()
	GivePilotLoadout( player, loadout )
}

void function GenericRespawn( entity player )
{        
	EndSignal( player, "OnDestroy" )
	EndSignal( player, "InternalPlayerRespawned" )

    wait 1

    while( !IsAlive( player ) )
    {
        foreach( p in GetPlayerArray() )
        {
            if ( IsValid( p ) && IsAlive( p ) && p != player && p.IsOnGround() && !p.IsWallRunning() && !p.IsWallHanging() )
            {
                    BasicRespawnLogic( player )
                    player.SetOrigin( p.GetOrigin() )

                    if ( p.IsTitan() )
                        thread MakePlayerTitan( player, p.GetOrigin() )
        
                    OnTimeShiftGiveGlove( player )
					if ( ( GetMapName() == "sp_beacon" || GetMapName() == "sp_beacon_spoke0" ) && Flag( "HasChargeTool" ) )
						GiveBatteryChargeToolSingle( player )
					
					player.Signal( "InternalPlayerRespawned" )
            }
        }
        wait 0.5
    }
}

void function s2sRespawn( entity player )
{
	EndSignal( player, "InternalPlayerRespawned" )
	EndSignal( player, "OnDestroy" )

	wait 1
	if ( "sp_s2s" in file.CustomMapRespawnsFunction && IsPlayingCoop() )
		thread file.CustomMapRespawnsFunction["sp_s2s"]( player )

	wait 1

	if ( !IsAlive( player ) && IsValid( player ) )
        thread GenericRespawn( player )

	wait 1
	
	if ( !IsAlive( player ) && IsValid( player ) )
		DoRespawnPlayer( player, null )
}

void function CodeCallback_OnPlayerKilled( entity player, var damageInfo )
{
	thread PostDeathThread_SP( player, damageInfo )
}

function PostDeathThread_SP( entity player, damageInfo )
{
	printl("PostDeathThread_SP Called!")
	array<entity> players = GetPlayerArray()
	string Coop_Dead_Player = player.GetPlayerName()
	foreach (entity p in players)
	{
		if (p != null )
		{
			SendHudMessage( p , Coop_Dead_Player + " Fucked up, laugh at them." , -1, 0.4, 255, 255, 0, 0, 0.15, 6, 0.15 )
		}
	}
	if ( player.p.watchingPetTitanKillReplay )
		return
	
	thread RespawnPlayer( player )

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
	printl("AfterShowDeathHint "+showedDeathHint)

	CodeCallback_OnPlayerRespawned( player )

	int damageSource = DamageInfo_GetDamageSourceIdentifier( damageInfo )
	if ( damageSource != eDamageSourceId.fall )
	{
		player.StartObserverMode( OBS_MODE_DEATHCAM )
		if ( ShouldSetObserverTarget( attacker ) )
			player.SetObserverTarget( attacker )
		else
			player.SetObserverTarget( null )
	}
}


void function MakePlayerTitan( entity player, vector destination )
{
	EndSignal( player, "OnDeath" )
	EndSignal( player, "OnDestroy" )

	while( IsPlayerDisembarking( player ) || IsPlayerEmbarking( player ) )
	{
		WaitFrame()
	}

	entity titan = player.GetPetTitan()
	if ( !IsValid( titan ) )
	{
		CreatePetTitanAtOrigin( player, player.GetOrigin(), player.GetAngles() )
		titan = player.GetPetTitan()
		if ( titan != null )
			titan.kv.alwaysAlert = false
	}
	if ( !player.IsTitan() && IsValid( player.GetPetTitan() ) )
	{
		titan.SetOrigin( player.GetOrigin() )

		WaitFrame()
		waitthread PilotBecomesTitan( player, titan )
		WaitFrame()

		titan.Destroy()
		player.SetOrigin( destination )
	}
}

void function MakePlayerPilot( entity player, vector destination  )
{
	EndSignal( player, "OnDeath" )
	EndSignal( player, "OnDestroy" )

	while( IsPlayerDisembarking( player ) || IsPlayerEmbarking( player ) )
	{
		WaitFrame()
	}

	entity titan = GetTitanFromPlayer( player )
	if ( player.IsTitan() && IsValid( titan ) )
	{
		entity t = CreateAutoTitanForPlayer_ForTitanBecomesPilot( player )
			
		TitanBecomesPilot( player, t )
		
		t.Destroy()
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

void function EnableOnePlayerRestart()
{
	file.RestartMap = true
}

void function DisableOnePlayerRestart()
{
	file.RestartMap = false
}