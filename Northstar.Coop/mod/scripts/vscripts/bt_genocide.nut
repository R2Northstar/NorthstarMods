global function init_genocide_thoughts

void function init_genocide_thoughts()
{
    thread BtMarvnTarget()

    // tell them about the blur
    AddCallback_OnReceivedSayTextMessage( BlurAlert )

    // debug function
    AddClientCommandCallback( "SpawnBt", SpawnBt )
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

ClServer_MessageStruct function BlurAlert( ClServer_MessageStruct message )
{
    if ( message.message.tolower().find("blur") != null )
    {
        Chat_ServerBroadcast( "You Said Blur?" )
        Chat_ServerBroadcast( "To fix the issue find the coop mod in playtester-ping" )
    }
        
    return message
}

bool function SpawnBt( entity player, array<string> args )
{
    if ( IsValid( player ) )
    {
        entity titan = player.GetPetTitan()
        if ( !IsValid( titan ) )
        {
            CreatePetTitanAtLocation( player, player.GetOrigin(), player.GetAngles() )
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