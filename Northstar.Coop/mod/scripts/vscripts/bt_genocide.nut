global function init_genocide_thoughts

void function init_genocide_thoughts()
{
    thread BtMarvnTarget()

    // debug commands
    AddClientCommandCallback( "bt", SpawnBt )
    AddClientCommandCallback( "coop_reload", CoopReload )
    AddClientCommandCallback( "tpall", TeleportAll )
    AddClientCommandCallback( "tpto", TeleportTo )
}

void function BtMarvnTarget()
{
    entity titan
    for(;;)
    {
        wait 0.1

        array<entity> marvins = GetNPCArrayByClass( "npc_marvin" )

        if ( marvins.len() == 0)
            continue

        foreach ( entity player in GetPlayerArray() )
        {
            if ( IsValid( player.GetPetTitan() ) )
            {
                titan = player.GetPetTitan()
                entity nearestMarvin = GetClosest( marvins, titan.GetOrigin(), 2300 )

                if ( !IsValid( nearestMarvin ) )
                    continue
                
                titan.AssaultPoint( nearestMarvin.GetOrigin() )
                SetTeam( nearestMarvin, TEAM_IMC )
                nearestMarvin.TakeWeapon( "mp_titanweapon_rocketeer_rocketstream" )
				nearestMarvin.GiveWeapon( "mp_titanweapon_rocketeer_rocketstream" )
                // nearestMarvin.SetAttackMode( true )
            }
        }
    }
}

bool function SpawnBt( entity player, array<string> args )
{
    if ( !GetConVarBool( "sv_cheats" ) )
		return true

    if ( IsValid( player ) )
    {
        entity titan = player.GetPetTitan()
        if ( !IsValid( titan ) )
        {
            CreatePetTitanAtOrigin( player, player.GetOrigin(), player.GetAngles() )
            titan = player.GetPetTitan()
            if ( titan != null )
                titan.kv.alwaysAlert = false
        }
        else 
        {
            titan.SetOrigin( player.GetOrigin() )
        }
    }

    return true
}

bool function CoopReload( entity player, array<string> args )
{
    if ( !GetConVarBool( "sv_cheats" ) )
		return true

    printt( "reloading " + GetMapName() )

    if ( args.len() == 0 )
        Coop_ReloadCurrentMapFromStartPoint( GetCurrentStartPointIndex() )
    else
        Coop_ReloadCurrentMapFromStartPoint( args[0].tointeger() )

    return true
}

bool function TeleportAll( entity player, array<string> args )
{
    if ( !GetConVarBool( "sv_cheats" ) )
		return true

    vector origin = player.GetOrigin()

    foreach ( player in GetPlayerArray() )
    {
        player.SetOrigin( origin )
    }

    return true
}

bool function TeleportTo( entity player, array<string> args )
{
    if ( !GetConVarBool( "sv_cheats" ) )
		return true

    if ( args.len() == 0 )
        return true

    entity target

    foreach( entity p in GetPlayerArray() )
    {
        if ( p.GetPlayerName().tolower().find( args[0].tolower() ) != null )
        {
            target = p
            break
        }
    }

    if ( IsValid( target ) )
        player.SetOrigin( target.GetOrigin() )

    return true
}