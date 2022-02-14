global function GetMod
global function GetWM

void function GetMod()
{
	#if SERVER
	AddClientCommandCallback("getmods", GetWM);
	AddClientCommandCallback("getmod", GetWM);
	AddClientCommandCallback("gm", GetWM);
	AddClientCommandCallback("fgm", ForceGetWM);
	AddClientCommandCallback("fgetmod", ForceGetWM);
	AddClientCommandCallback("fgetmods", ForceGetWM);
	#endif
}

bool function GetWM(entity player, array<string> args)
{
	#if SERVER
	if (player == null)
		return true;

	hadGift_Admin = false;
	CheckAdmin(player);
	if (hadGift_Admin != true)
	{
		print("Admin permission not detected.");
		return true;
	}
	string weaponId
	if (args.len() == 0)
	{
		print("getmod/getmods/gm <weaponId>")
		return true;
	}
	CheckWeaponName(args[0])
	if (successfulweapons.len() > 1)
	{
		print ("Multiple weapons found!")
		int i = 1;
		foreach (string weaponnames in successfulweapons)
		{
			print ("[" + i.tostring() + "] " + weaponnames)
			i++
		}
		return true;
	}
	else if (successfulweapons.len() == 1)
	{
		print("Weapon ID is " + successfulweapons[0])
		weaponId = successfulweapons[0]
	}
	else if (successfulweapons.len() == 0)
	{
		print("Unable to detect weapon.")
		return true;
	}

	array<string> amods = GetWeaponMods_Global( weaponId );
	string modId = "";

	if (args.len() == 1)
	{
		for( int i = 0; i < amods.len(); ++i )
		{
			string modId = amods[i]
			print("[" + i.tostring() + "] " + modId);
		}
		return true;
	}

	if (args.len() > 1)
	{
		print("Only 1 argument required.")
		return true;
	}
	return true;
	#endif
}

bool function ForceGetWM(entity player, array<string> args)
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

	// if player only typed "fgift"
	if (args.len() == 0)
	{
		print("Give a valid argument.");
		print("Example: fgift/forcegift <weaponId> <playerId>");
		print("You can check weaponId by typing give and pressing tab to scroll through the IDs.");
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
	// if player typed "fgift somethinghere"
	switch (args[0]) {
		case (""):
		print("Give a valid argument.");
		break;
		case ("pd"):
		weaponId = "mp_titanweapon_predator_cannon";
		break;
		case ("sword"):
		weaponId = "melee_titan_sword";
		break;
		case ("pr"):
		weaponId = "mp_titanweapon_sniper";
		break;
		case ("ld"):
		weaponId = "mp_titanweapon_leadwall";
		break;
		case ("40mm"):
		weaponId = "mp_titanweapon_sticky_40mm";
		break;
		case ("peacekraber"):
		weaponId = "mp_weapon_peacekraber";
		break;
		case ("kraber"):
		weaponId = "mp_weapon_sniper";
		break;

		default:
			weaponId = args[0]
			print("Weapon ID is " + weaponId)
		break;
	}

	string modId = "";

	if (args.len() == 1)
	{
		try
		{
			array<string> amods = GetWeaponMods_Global( weaponId );
			for( int i = 0; i < amods.len(); ++i )
			{
				string modId = amods[i]
				print("[" + i.tostring() + "] " + modId);
			}
			return true;
		} catch (exception)
		{
			print( "Couldn't fetch mods for " + weaponId + ". Are you sure its the correct ID?" );
			return true;
		}
	}

	if (args.len() > 1)
	{
		print("Only 1 argument required.")
		return true;
	}
	#endif
	return true;
}