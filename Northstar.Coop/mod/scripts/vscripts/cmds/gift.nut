untyped

global function GiftCommand
global function KGiveWeapon
global function KGiveOffhandWeapon
global function KGiveGrenade
global function KGiveTitanDefensive
global function KGiveTitanTactical
global function KGiveCore
global function CheckWeaponId

// a lot of this is from Icepick's code so big props to them

void function GiftCommand()
{
	#if SERVER
	AddClientCommandCallback("gift", Gift);
	AddClientCommandCallback("fgift", ForceGift);
	AddClientCommandCallback("forcegift", ForceGift);
	#endif
}

bool function ForceGift(entity player, array<string> args)
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
	// if player typed "gift correctId" with no further arguments
	if (args.len() == 1)
	{
		print("Example: gift <weaponId> <playerId> <mod>");
		print("If you want to give yourself the weapon, put 0 as the playerId.");
		return true;
	}

	// if player typed "gift correctId somethinghere"
	switch (args[1])
	{
		case ("all"):
			foreach (entity p in GetPlayerArray())
			{
				if (p != null)
				CheckWeaponId(p, weaponId);

				if (args.len() > 2) {
					array<string> mods = args.slice(2);
					bypassPerms = true;
					thread GiveWM(p, mods);
				}
			}
		break;

		case ("imc"):
			foreach (entity p in GetPlayerArrayOfTeam( TEAM_IMC ))
			{
				if (p != null)
					CheckWeaponId(p, weaponId)

				if (args.len() > 2) {
					array<string> mods = args.slice(2);
					bypassPerms = true;
					thread GiveWM(p, mods);
				}
			}
		break;

		case ("militia"):
			foreach (entity p in GetPlayerArrayOfTeam( TEAM_MILITIA ))
			{
				if (p != null)
					CheckWeaponId(p, weaponId)

				if (args.len() > 2) {
					array<string> mods = args.slice(2);
					bypassPerms = true;
					thread GiveWM(p, mods);
				}
			}
		break;

		default:
            CheckPlayerName(args[1])
			 	foreach (entity p in successfulnames)
                	CheckWeaponId(p, weaponId);

			if (args.len() > 2) {
				array<string> mods = args.slice(2);
				bypassPerms = true;
				CheckPlayerName(args[1])
				foreach (entity p in successfulnames)
					thread GiveWM(p, mods);
			}
		break;
	}
	#endif
	return true;
}

bool function Gift(entity player, array<string> args)
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
		print("Example: gift <weaponId> <playerId>");
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
	// if player typed "gift somethinghere"
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
			} else if (successfulweapons.len() == 1)
			{
				print("Weapon ID is " + successfulweapons[0])
				weaponId = successfulweapons[0]
			} else if (successfulweapons.len() == 0)
			{
				print("Unable to detect weapon. Please try forcegift/fgift instead.")
				return true;
			}
		break;
	}
	// if player typed "gift correctId" with no further arguments
	if (args.len() == 1)
	{
		print("Example: gift <weaponId> <playerId> <mod>");
		print("If you want to give yourself the weapon, put 0 as the playerId.");
		return true;
	}
	array<entity> playerstogift
	// if player typed "gift correctId somethinghere"
	switch (args[1])
	{
		case ("all"):
			foreach (entity p in GetPlayerArray())
			{
				if (p != null)
					playerstogift.append(p)
			}
		break;

		case ("imc"):
			foreach (entity p in GetPlayerArrayOfTeam( TEAM_IMC ))
			{
				if (p != null)
					playerstogift.append(p)
			}
		break;

		case ("militia"):
			foreach (entity p in GetPlayerArrayOfTeam( TEAM_MILITIA ))
			{
				if (p != null)
					playerstogift.append(p)
			}
		break;

		default:
            CheckPlayerName(args[1])
			 	foreach (entity p in successfulnames)
                	playerstogift.append(p)
		break;
	}
	array<string> mods
	if (args.len() > 2)
	{
		mods = args.slice(2);
	}
	foreach(entity p in playerstogift)
		CheckWeaponId(p, weaponId, mods)
	#endif
	return true;
}

void function KGiveWeapon( entity player, string weaponId , array<string> mods = [])
{
	#if SERVER
	array<entity> weapons = player.GetMainWeapons()
	bool hasWeapon = false;
	string weaponToSwitch = "";

	if (player.GetLatestPrimaryWeapon() != null)
	{
		weaponToSwitch = player.GetLatestPrimaryWeapon().GetWeaponClassName();

		if ( player.GetActiveWeapon() != player.GetAntiTitanWeapon() )
		{
			foreach ( entity weapon in weapons )
			{
				if (weapon == null) {
					return;
				}
				string weaponClassName = weapon.GetWeaponClassName()
				if ( weaponClassName == weaponId )
				{
					weaponToSwitch = weaponClassName
					print(weaponToSwitch)
					bool hasWeapon = true;
					break
				}
			}
		}
	} else
	{
		hasWeapon = false;
	}
	if (hasWeapon || weaponToSwitch != "")
		player.TakeWeaponNow( weaponToSwitch )

	CheckWeaponMod(weaponId, mods)
	try
	{
		player.GiveWeapon( weaponId , successfulmods )
		player.SetActiveWeaponByName( weaponId )
		string playername = player.GetPlayerName();
		print("Giving " + playername + " the selected weapon.");
	} catch(exception)
	{
		print(weaponId + " is not a valid weapon.");
	}
#endif
}

void function KGiveGrenade(entity player, string abilityId , array<string> mods = [])
{
#if SERVER
	entity weapon = player.GetOffhandWeapon( OFFHAND_ORDNANCE );
	if (weapon != null)
	{
		if( weapon.GetWeaponClassName() != abilityId )
		{
			player.TakeWeaponNow( weapon.GetWeaponClassName() );
			CheckWeaponMod(weapon.GetWeaponClassName(), mods)
			player.GiveOffhandWeapon( abilityId, OFFHAND_ORDNANCE , successfulmods );
		}
		else if( weapon.GetWeaponPrimaryClipCount() < weapon.GetWeaponPrimaryClipCountMax() )
		{
			weapon.SetWeaponPrimaryClipCount( weapon.GetWeaponPrimaryClipCount() + 1 );
		}
	}
	string playername = player.GetPlayerName();
	print("Giving " + playername + " the selected ordnance.");
#endif
}

void function KGiveOffhandWeapon( entity player, string abilityId , array<string> mods = [])
{
#if SERVER
	entity weapon = player.GetOffhandWeapon( OFFHAND_MELEE );
	if (weapon != null)
		player.TakeWeaponNow( weapon.GetWeaponClassName() );

	CheckWeaponMod(abilityId, mods)
	player.GiveOffhandWeapon( abilityId, OFFHAND_MELEE , successfulmods );
	string playername = player.GetPlayerName();
	print("Giving " + playername + " the selected melee.");
#endif
}

void function KGiveTitanDefensive( entity player, string abilityId , array<string> mods = [])
{
#if SERVER
	entity weapon = player.GetOffhandWeapon( OFFHAND_SPECIAL );
	if (weapon != null)
		player.TakeWeaponNow( weapon.GetWeaponClassName() );

	CheckWeaponMod(abilityId, mods)
	player.GiveOffhandWeapon( abilityId, OFFHAND_SPECIAL , successfulmods );
	string playername = player.GetPlayerName();
	print("Giving " + playername + " the selected defensive.");
#endif
}

void function KGiveTitanTactical( entity player, string abilityId , array<string> mods = [])
{
#if SERVER
	entity weapon = player.GetOffhandWeapon( OFFHAND_TITAN_CENTER );
	if (!player.IsTitan()) {
		KGiveGrenade(player, abilityId);
		return;
	}
	if (weapon != null)
		player.TakeWeaponNow( weapon.GetWeaponClassName() );

	CheckWeaponMod(abilityId, mods)
	player.GiveOffhandWeapon( abilityId, OFFHAND_TITAN_CENTER , successfulmods );
	string playername = player.GetPlayerName();
	print("Giving " + playername + " the selected tactical.");
#endif
}

void function KGiveCore( entity player, string abilityId )
{
#if SERVER
	entity titan = null;
	if (player.IsTitan())
		titan = player
	else
		titan = player.GetPetTitan();

	if (titan == null)
		return;

	entity weapon = titan.GetOffhandWeapon( OFFHAND_EQUIPMENT );
	if (weapon != null)
		titan.TakeWeaponNow( weapon.GetWeaponClassName() );
	titan.GiveOffhandWeapon( abilityId, OFFHAND_EQUIPMENT );
	string playername = player.GetPlayerName();
	entity soul = titan.GetTitanSoul();
	SoulTitanCore_SetNextAvailableTime( soul, 100.0 );
	print("Giving " + playername + " the selected core.");

	// CoreActivate( player );
#endif
}

void function KGiveAbility( entity player, string abilityId , array<string> mods = [])
{
#if SERVER
	entity weapon = player.GetOffhandWeapon( OFFHAND_SPECIAL );
	if (weapon != null)
		player.TakeWeaponNow( weapon.GetWeaponClassName() );

	CheckWeaponMod(abilityId, mods)
	player.GiveOffhandWeapon( abilityId, OFFHAND_SPECIAL , successfulmods );
	string playername = player.GetPlayerName();
	print("Giving " + playername + " the selected ability.");
#endif
}

void function CheckWeaponId(entity player, string weaponId, array<string> mods = [])
{
	#if SERVER
	foreach (string p in kabilities)
	{
		if (weaponId == p)
		{
			KGiveAbility(player, weaponId, mods);
			return;
		}
	}

	foreach (string p in ordnances)
	{
		if (weaponId == p)
		{
			KGiveGrenade(player, weaponId, mods);
			return;
		}
	}

	foreach (string p in defensives)
	{
		if (weaponId == p)
		{
			KGiveTitanDefensive(player, weaponId, mods);
			return;
		}
	}

	foreach (string p in tacticals)
	{
		if (weaponId == p)
		{
			KGiveTitanTactical(player, weaponId, mods);
			return;
		}
	}

	foreach (string p in cores)
	{
		if (weaponId == p)
		{
			KGiveCore(player, weaponId);
			return;
		}
	}

	foreach (string p in melee)
	{
		if (weaponId == p)
		{
			KGiveOffhandWeapon(player, weaponId, mods);
			return;
		}
	}

	KGiveWeapon(player, weaponId , mods);
	return;

	#endif
}