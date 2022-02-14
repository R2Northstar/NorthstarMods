untyped

global function PredatorCommand
global function Predator

void function PredatorCommand()
{
	#if SERVER
	AddClientCommandCallback("predator", PredatorCMD);
	AddClientCommandCallback("pred", PredatorCMD);
	/* AddClientCommandCallback("uv", UnPredatorCMD);
	AddClientCommandCallback("unvanish", UnPredatorCMD); */
    thread PredatorMain()
	#endif
}

struct {
    array<entity> Predators
} files

bool function PredatorCMD(entity player, array<string> args)
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
	if (args.len() == 0)
	{
		print("Give a valid argument.");
		print("Example: vanish/v <playername> <playername2> <playername3> ... / imc / militia / all");
		// print every single player's name and their id
		int i = 0;
		foreach (entity p in GetPlayerArray())
		{
			string playername = p.GetPlayerName();
			print("[" + i.tostring() + "] " + playername);
			i++
		}
		return true;
	}

	switch (args[0])
	{
		case ("all"):
			foreach (entity p in GetPlayerArray())
			{
				if (p != null)
					Predator(p)
			}
		break;

		case ("imc"):
			foreach (entity p in GetPlayerArrayOfTeam( TEAM_IMC ))
			{
				if (p != null)
					Predator(p)
			}
		break;

		case ("militia"):
			foreach (entity p in GetPlayerArrayOfTeam( TEAM_MILITIA ))
			{
				if (p != null)
					Predator(p)
			}
		break;

		default:
            CheckPlayerName(args[0])
				foreach (entity p in successfulnames)
                    Predator(p)
		break;
	}
	if (args.len() > 1) {
		array<string> playersname = args.slice(1);
		foreach (string playerId in playersname)
		{
            CheckPlayerName(playerId)
				foreach (entity p in successfulnames)
                    Predator(p)
		}
	}

	#endif
	return true;
}

void function Predator(entity player)
{
#if SERVER
	try {
		if (files.Predators.find(player) != -1)
        {
            files.Predators.remove(files.Predators.find(player))
            DisableCloakForever(player)
            player.kv.VisibilityFlags = ENTITY_VISIBLE_TO_EVERYONE
        }
        else
        {
            files.Predators.append(player)
            EnableCloakForever(player)
        }
		return;
	} catch(e)
	{
		print("Unable to vanish " + player.GetPlayerName() + ". Could be unalive lol.")
	}
#endif
}

/* bool function UnPredatorCMD(entity player, array<string> args)
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
	if (args.len() == 0)
	{
		print("Give a valid argument.");
		print("Example: unvanish/uv <playername> <playername2> <playername3> ... / imc / militia / all");
		// print every single player's name and their id
		int i = 0;
		foreach (entity p in GetPlayerArray())
		{
			string playername = p.GetPlayerName();
			print("[" + i.tostring() + "] " + playername);
			i++
		}
		return true;
	}

	switch (args[0])
	{
		case ("all"):
			foreach (entity p in GetPlayerArray())
			{
				if (p != null)
					UnPredator(p)
			}
		break;

		case ("imc"):
			foreach (entity p in GetPlayerArrayOfTeam( TEAM_IMC ))
			{
				if (p != null)
					UnPredator(p)
			}
		break;

		case ("militia"):
			foreach (entity p in GetPlayerArrayOfTeam( TEAM_MILITIA ))
			{
				if (p != null)
					UnPredator(p)
			}
		break;

		default:
            CheckPlayerName(args[0])
				foreach (entity p in successfulnames)
                    UnPredator(p)
		break;
	}
	if (args.len() > 1) {
		array<string> playersname = args.slice(1);
		foreach (string playerId in playersname)
		{
            CheckPlayerName(playerId)
				foreach (entity p in successfulnames)
                    UnPredator(p)
		}
	}

	#endif
	return true;
}

void function UnPredator(entity player)
{
#if SERVER
	try {
		player.kv.VisibilityFlags = ENTITY_VISIBLE_TO_EVERYONE
		return;
	} catch(e)
	{
		print("Unable to unvanish " + player.GetPlayerName() + ". Could be unalive lol.")
	}
#endif
} */

void function PredatorMain()
{
    while (true) {
        WaitFrame()
        if(!IsLobby())
        {
            foreach (entity player in files.Predators)
            {
                if (player == null || !IsValid(player) || !IsAlive(player))
                    continue
                vector playerVelV = player.GetVelocity()
                float playerVel
                playerVel = sqrt(playerVelV.x * playerVelV.x + playerVelV.y * playerVelV.y + playerVelV.z * playerVelV.z)
                float playerVelNormal = playerVel * 0.068544
                if (playerVel/300 < 1.3)
                {
                    player.SetCloakFlicker(0, 0)
                    player.kv.VisibilityFlags = 0
                }
                else
                {
                    player.SetCloakFlicker(0.2 , 1 )
                    player.kv.VisibilityFlags = 0
                    float waittime = RandomFloat(0.5)
                    wait waittime
                    player.kv.VisibilityFlags = ENTITY_VISIBLE_TO_EVERYONE
                }
            }
        }
    }
}