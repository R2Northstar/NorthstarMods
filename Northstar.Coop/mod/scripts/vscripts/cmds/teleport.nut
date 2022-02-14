global function TeleportCommand
global function Teleport

void function TeleportCommand()
{
	#if SERVER
	AddClientCommandCallback("teleport", TeleportCMD);
	AddClientCommandCallback("tp", TeleportCMD);
	#endif
}

bool function TeleportCMD(entity player, array<string> args)
{
	#if SERVER
	entity weapon = null;
	string weaponId = ("");
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
		print("Example: teleport/tp <playerId1> <playerId2> / imc / militia / all / crosshair");
		print("Example: teleport/tp all 0, teleports everyone to you")
		print("Example: teleport/tp 4 crosshair, teleports 4 to your crosshair")
		print("Example: teleport/tp 0 all, doesn't work since I can't teleport you to multiple people")
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

	array<entity> sheep1 = [];
	entity sheep2 = null;

	// if player typed "Teleport somethinghere"
	switch (args[0])
	{
		case ("all"):
			foreach (entity p in GetPlayerArray())
			{
				if (p != null) {
					sheep1.append(p);
					print("Added " + p.GetPlayerName());
				}
			}
		break;

		case ("imc"):
			foreach (entity p in GetPlayerArrayOfTeam( TEAM_IMC ))
			{
				if (p != null)
					sheep1.append(p);
			}
		break;

		case ("militia"):
			foreach (entity p in GetPlayerArrayOfTeam( TEAM_MILITIA ))
			{
				if (p != null)
					sheep1.append(p);
			}
		break;

		case ("crosshair"):
			print("You're supposed to put crosshair in the second argument")
			return true;
		break;

		default:
            CheckPlayerName(args[0])
				foreach (entity p in successfulnames)
                    sheep1.append(p)
		break;
	}
	bool useCrosshair = false
	switch (args[1])
	{
		case ("all"):
			print("Bro you can't teleport everyone to teleport multiple people lmao.")
			return true;
		break;

		case ("imc"):
			print("Bro you can't teleport everyone to teleport multiple people lmao.")
			return true;

		break;

		case ("militia"):
			print("Bro you can't teleport everyone to teleport multiple people lmao.")
			return true;

		break;

		case ("crosshair"):
			useCrosshair = true;
			sheep2 = player
		break;

		default:
            CheckPlayerName(args[1])
				foreach (entity p in successfulnames)
            		sheep2 = p
		break;
	}
	if (args.len() > 2 )
	{
		print("Only 2 arguments required.")
		return true;
	}

	Teleport(sheep1, sheep2, useCrosshair)
	#endif
	return true;
}

void function Teleport( array<entity> player1 , entity player2 , bool useCrosshair )
{
	if (IsAlive(player2))
	{
		vector origin = GetPlayerCrosshairOrigin( player2 );
		vector angles = player2.EyeAngles();
		angles.x = 0;
		angles.z = 0;

	#if SERVER
	foreach (entity sheep in player1)
	{
			if (useCrosshair)
			{
				print("Moving " + sheep.GetPlayerName() + " to your crosshair.")

				vector spawnPos = origin;
				vector spawnAng = angles;

				sheep.SetOrigin(origin)
				sheep.SetAngles(spawnAng)
			}
			else {
			vector origin = player2.GetOrigin();
			vector angles = player2.EyeAngles();

			sheep.SetOrigin(origin)
			sheep.SetAngles(angles)
			print("Moving " + sheep.GetPlayerName() + " to " + player2.GetPlayerName() + ".")
			}
	}
	}
	return;
#endif
}
