global function FreezeCommand
global function Freeze

void function FreezeCommand() {
    #if SERVER
    AddClientCommandCallback("freeze", FreezeCMD);
    AddClientCommandCallback("unfreeze", unFreezeCMD);
    #endif
}

bool function FreezeCMD(entity player, array < string > args) {
    #if SERVER
	array<entity> players = GetPlayerArray()
    hadGift_Admin = false;
    CheckAdmin(player);
    if (hadGift_Admin != true) {
        print("Admin permission not detected.");
        return true;
    }

    // if player only typed "health"
    if (args.len() == 0) {
        print("Give a valid argument.");
        print("Example: freeze <playerId>, playerId = imc / militia / all");
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

    if (args.len() > 1 )
	{
		print("Only 1 arguments required.")
		return true;
	}

    thread Freeze(sheep1)
    #endif
    return true;
}

bool function unFreezeCMD(entity player, array < string > args) {
    #if SERVER
	array<entity> players = GetPlayerArray()
    hadGift_Admin = false;
    CheckAdmin(player);
    if (hadGift_Admin != true) {
        print("Admin permission not detected.");
        return true;
    }

    // if player only typed "health"
    if (args.len() == 0) {
        print("Give a valid argument.");
        print("Example: unfreeze <playerId>, playerId = imc / militia / all");
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

    if (args.len() > 1 )
	{
		print("Only 1 arguments required.")
		return true;
	}

    thread unFreeze(sheep1)
    #endif
    return true;
}

void function Freeze(array < entity > player) {
    #if SERVER
    foreach(entity localPlayer in player)
	{
        localPlayer.MovementDisable()
        localPlayer.ConsumeDoubleJump()
        localPlayer.DisableWeaponViewModel()
    }
    #endif
}

void function unFreeze(array < entity > player) {
    #if SERVER
    foreach(entity localPlayer in player)
	{
        localPlayer.MovementEnable()
        localPlayer.EnableWeaponViewModel()
    }
    #endif
}