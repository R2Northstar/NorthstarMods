untyped

global function ShuffleTeamsCommand

void function ShuffleTeamsCommand()
{
	#if SERVER
	AddClientCommandCallback("shuffleteam", ShuffleTeamsCMD);
	AddClientCommandCallback("shuffleteams", ShuffleTeamsCMD);
	#endif
}

bool function ShuffleTeamsCMD(entity player, array<string> args)
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
		array<entity> picked = [];
        foreach (entity player in GetPlayerArray()) {
			if (picked.find(player) == -1 && player != null) {
       			int i = RandomInt(9)
            	if (i % 2 == 0)
                	SetTeam(player, TEAM_IMC)
            	else
                	SetTeam(player, TEAM_MILITIA)
				picked.append(player)
			}
        }
		return true;
	}

    if (args.len () > 0)
        print("No argument required.")
	#endif
	return true;
}
