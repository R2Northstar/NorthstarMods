global function BubbleShield
global function BubbleShieldCommand

struct {
    table<entity, entity> shield
} file

void function BubbleShieldCommand()
{
	#if SERVER
	AddClientCommandCallback("bubbleshield", BubbleShieldCMD);
	AddClientCommandCallback("bs", BubbleShieldCMD);
	AddClientCommandCallback("unbubbleshield", UnBubbleShieldCMD);
	AddClientCommandCallback("unbs", UnBubbleShieldCMD);
	#endif
}

bool function BubbleShieldCMD(entity player, array<string> args)
{
	#if SERVER
	array<entity> players = GetPlayerArray();
	hadGift_Admin = false;
	CheckAdmin(player);
	if (hadGift_Admin != true)
	{
		print("Admin permission not detected.");
		return true;
	}

	// if player only typed "gift"
	if (args.len() == 0) {
        print("Give a valid argument.");
        print("Example: bs/bubbleshield <playerId> <duration> , playerId = imc / militia / all");
        // print every single player's name and their id
        int i = 0;
        foreach(entity p in GetPlayerArray()) {
            string playername = p.GetPlayerName();
            print("[" + i.tostring() + "] " + playername);
            i++
        }
        return true;
    }
	string playername = player.GetPlayerName()
    array < entity > sheep1 = [];
    // if player typed "health somethinghere"
    switch (args[0]) {
        case ("all"):
            foreach(entity p in GetPlayerArray()) {
                if (p != null)
                    sheep1.append(p)
            }
            break;

        case ("imc"):
            foreach(entity p in GetPlayerArrayOfTeam(TEAM_IMC)) {
                if (p != null)
                    sheep1.append(p)
            }
            break;

        case ("militia"):
            foreach(entity p in GetPlayerArrayOfTeam(TEAM_MILITIA)) {
                if (p != null)
                    sheep1.append(p)
            }
            break;

        default:
            CheckPlayerName(args[0])
                foreach (entity p in successfulnames)
                    sheep1.append(p)
            break;
    }

    // if player typed "gift correctId" with no further arguments
    if (args.len() == 1) {
        return true;
    }
    float value = 1;
     if (args.len() > 1) {
        value = args[1].tofloat()
    }

    if (args.len() > 2 )
	{
		print("Only 2 arguments required.")
		return true;
	}
    foreach (entity p in sheep1)
        thread BubbleShield(p, value)

	#endif
	return true;
}

bool function UnBubbleShieldCMD(entity player, array<string> args)
{
	#if SERVER
	array<entity> players = GetPlayerArray();
	hadGift_Admin = false;
	CheckAdmin(player);
	if (hadGift_Admin != true)
	{
		print("Admin permission not detected.");
		return true;
	}

	// if player only typed "gift"
	if (args.len() == 0) {
        print("Give a valid argument.");
        print("Example: bs/bubbleshield <playerId> <duration> , playerId = imc / militia / all");
        // print every single player's name and their id
        int i = 0;
        foreach(entity p in GetPlayerArray()) {
            string playername = p.GetPlayerName();
            print("[" + i.tostring() + "] " + playername);
            i++
        }
        return true;
    }
	string playername = player.GetPlayerName()
    array < entity > sheep1 = [];
    // if player typed "health somethinghere"
    switch (args[0]) {
        case ("all"):
            foreach(entity p in GetPlayerArray()) {
                if (p != null)
                    sheep1.append(p)
            }
            break;

        case ("imc"):
            foreach(entity p in GetPlayerArrayOfTeam(TEAM_IMC)) {
                if (p != null)
                    sheep1.append(p)
            }
            break;

        case ("militia"):
            foreach(entity p in GetPlayerArrayOfTeam(TEAM_MILITIA)) {
                if (p != null)
                    sheep1.append(p)
            }
            break;

        default:
            CheckPlayerName(args[0])
                foreach (entity p in successfulnames)
                    sheep1.append(p)
            break;
    }

    if (args.len() > 1 )
	{
		print("Only 1 arguments required.")
		return true;
	}
    foreach (entity p in sheep1) 
    {  
        if (p in file.shield)
        thread DestroyBubbleShield(file.shield[p])
    }
	#endif
	return true;
}

void function BubbleShield(entity player, float duration)
{
#if SERVER
	entity bubbleShield = CreateEntity( "prop_dynamic" )
	bubbleShield.SetValueForModelKey( $"models/fx/xo_shield.mdl" )
	bubbleShield.kv.solid = SOLID_VPHYSICS
    bubbleShield.kv.rendercolor = "81 130 151"
    bubbleShield.kv.contents = (int(bubbleShield.kv.contents) | CONTENTS_NOGRAPPLE)
    vector angles = player.EyeAngles()
    angles.x = 0;
    angles.z = 0;
	bubbleShield.SetOrigin( player.GetOrigin() + Vector( 0, 0, 25 ))
	bubbleShield.SetAngles( angles )

     // Blocks bullets, projectiles but not players and not AI
	// bubbleShield.kv.CollisionGroup = TRACE_COLLISION_GROUP_BLOCK_WEAPONS
	bubbleShield.SetBlocksRadiusDamage( true )
	DispatchSpawn( bubbleShield )
    SetTeam( bubbleShield, player.GetTeam() )
    array<entity> bubbleShieldFXs
    int team = player.GetTeam()
	vector coloredFXOrigin = player.GetOrigin() + Vector( 0, 0, 25 )
	table bubbleShieldDotS = expect table( bubbleShield.s )
	if ( team == TEAM_UNASSIGNED )
	{
		entity neutralColoredFX = StartParticleEffectInWorld_ReturnEntity( BUBBLE_SHIELD_FX_PARTICLE_SYSTEM_INDEX, coloredFXOrigin, <0, 0, 0> )
		SetTeam( neutralColoredFX, team )

		bubbleShieldDotS.neutralColoredFX <- neutralColoredFX
		bubbleShieldFXs.append( neutralColoredFX )
	}
	else
	{
		//Create friendly and enemy colored particle systems
		entity friendlyColoredFX = StartParticleEffectInWorld_ReturnEntity( BUBBLE_SHIELD_FX_PARTICLE_SYSTEM_INDEX, coloredFXOrigin, <0, 0, 0> )
		SetTeam( friendlyColoredFX, team )
		friendlyColoredFX.kv.VisibilityFlags = ENTITY_VISIBLE_TO_FRIENDLY
		EffectSetControlPointVector(  friendlyColoredFX, 1, FRIENDLY_COLOR_FX )

		entity enemyColoredFX = StartParticleEffectInWorld_ReturnEntity( BUBBLE_SHIELD_FX_PARTICLE_SYSTEM_INDEX, coloredFXOrigin, <0, 0, 0> )
		SetTeam( enemyColoredFX, team )
		enemyColoredFX.kv.VisibilityFlags = ENTITY_VISIBLE_TO_ENEMY
		EffectSetControlPointVector(  enemyColoredFX, 1, ENEMY_COLOR_FX )

		bubbleShieldDotS.friendlyColoredFX <- friendlyColoredFX
		bubbleShieldDotS.enemyColoredFX <- enemyColoredFX
		bubbleShieldFXs.append( friendlyColoredFX )
		bubbleShieldFXs.append( enemyColoredFX )
	}
    file.shield[player] <- bubbleShield
    EmitSoundOnEntity( bubbleShield, "BubbleShield_Sustain_Loop" )
    thread CleanupBubbleShield( bubbleShield, bubbleShieldFXs, duration )
#endif
}

void function CleanupBubbleShield( entity bubbleShield, array<entity> bubbleShieldFXs, float fadeTime )
{
	bubbleShield.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function () : ( bubbleShield, bubbleShieldFXs )
		{
			if ( IsValid_ThisFrame( bubbleShield ) )
			{
				StopSoundOnEntity( bubbleShield, "BubbleShield_Sustain_Loop" )
				EmitSoundOnEntity( bubbleShield, "BubbleShield_End" )
				DestroyBubbleShield( bubbleShield )
			}

			foreach ( fx in bubbleShieldFXs )
			{
				if ( IsValid_ThisFrame( fx ) )
				{
					EffectStop( fx )
				}
			}
		}
	)

	wait fadeTime
}