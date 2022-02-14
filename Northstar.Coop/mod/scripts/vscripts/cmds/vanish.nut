

global function VanishCommand
global function Vanish

void function VanishCommand()
{
	#if SERVER
	AddClientCommandCallback("vanish", VanishCMD);
	AddClientCommandCallback("v", VanishCMD);
	AddClientCommandCallback("uv", UnVanishCMD);
	AddClientCommandCallback("unvanish", UnVanishCMD);
	#endif
}

bool function VanishCMD(entity player, array<string> args)
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
					Vanish(p)
			}
		break;

		case ("imc"):
			foreach (entity p in GetPlayerArrayOfTeam( TEAM_IMC ))
			{
				if (p != null)
					Vanish(p)
			}
		break;

		case ("militia"):
			foreach (entity p in GetPlayerArrayOfTeam( TEAM_MILITIA ))
			{
				if (p != null)
					Vanish(p)
			}
		break;

		default:
            CheckPlayerName(args[0])
				foreach (entity p in successfulnames)
                    Vanish(p)
		break;
	}
	if (args.len() > 1) {
		array<string> playersname = args.slice(1);
		foreach (string playerId in playersname)
		{
            CheckPlayerName(playerId)
				foreach (entity p in successfulnames)
                    Vanish(p)
		}
	}

	#endif
	return true;
}

void function Vanish(entity player)
{
#if SERVER
	try {
		player.kv.VisibilityFlags = 0
		return;
	} catch(e)
	{
		print("Unable to vanish " + player.GetPlayerName() + ". Could be unalive lol.")
	}
#endif
}

bool function UnVanishCMD(entity player, array<string> args)
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
					UnVanish(p)
			}
		break;

		case ("imc"):
			foreach (entity p in GetPlayerArrayOfTeam( TEAM_IMC ))
			{
				if (p != null)
					UnVanish(p)
			}
		break;

		case ("militia"):
			foreach (entity p in GetPlayerArrayOfTeam( TEAM_MILITIA ))
			{
				if (p != null)
					UnVanish(p)
			}
		break;

		default:
            CheckPlayerName(args[0])
				foreach (entity p in successfulnames)
                    UnVanish(p)
		break;
	}
	if (args.len() > 1) {
		array<string> playersname = args.slice(1);
		foreach (string playerId in playersname)
		{
            CheckPlayerName(playerId)
				foreach (entity p in successfulnames)
                    UnVanish(p)
		}
	}

	#endif
	return true;
}

void function UnVanish(entity player)
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
}