global function init_genocide_thoughts

void function init_genocide_thoughts()
{
    thread BtMarvnTarget()
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