global function AnnounceCommand
global function Announce

struct {
    int red = 255
    int green = 255
    int blue = 0
    array<string> colors
    string automessage
} file

void function AnnounceCommand() {
    #if SERVER
    AddClientCommandCallback("announce", AnnounceCMD);
    AddClientCommandCallback("a", AnnounceCMD);
    UpdateAnnounceColor()
    UpdateAutoAnnounceColor()
    AddCallback_GameStateEnter( eGameState.Playing, OnEnterPlaying )
    #endif
}

void function UpdateAnnounceColor()
{
	string cvar = GetConVarString( "announce_color" )

	file.colors = split( cvar, "," )
	foreach ( string admin in file.colors )
		StringReplace( admin, " ", "" )

    file.red = file.colors[0].tointeger()
    file.blue = file.colors[1].tointeger()
    file.green = file.colors[2].tointeger()
}

void function UpdateAutoAnnounceColor()
{
	string cvar = GetConVarString( "autoannounce_color" )

	file.colors = split( cvar, "," )
	foreach ( string admin in file.colors )
		StringReplace( admin, " ", "" )

    file.red = file.colors[0].tointeger()
    file.blue = file.colors[1].tointeger()
    file.green = file.colors[2].tointeger()

    file.automessage = GetConVarString("autoannounce")
}

void function OnEnterPlaying()
{
    UpdateAutoAnnounceColor()
    foreach(entity player in GetPlayerArray())
    {
        SendHudMessage( player, file.automessage, -1, 0.4, file.red, file.blue, file.green, 0, 0.15, 4, 0.15 )
    }
}

bool function AnnounceCMD(entity player, array < string > args) {
    #if SERVER
	array<entity> players = GetPlayerArray()
    hadGift_Admin = false;
    CheckAdmin(player);
    if (hadGift_Admin != true) {
        print("Admin permission not detected.");
        return true;
    }

    // if player only typed "gift"
    if (args.len() == 0) {
        print("Give a valid argument.");
        print("Example: announce/a <playerId> <text1> <text2> ... / imc / militia / all");
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
    // if player typed "announce somethinghere"
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
        print("Example: announce/a <playerId> <text>");
        return true;
    }

    string newString

    if (args.len() > 1) {
        array < string > playersname = args.slice(1);
        foreach(string text in playersname) {
            newString += (text.tostring() + " ");
        }
    }

    thread Announce(sheep1, newString)
    #endif
    return true;
}

void function Announce(array < entity > player, string text) {
    #if SERVER
    UpdateAnnounceColor()
    foreach(entity localPlayer in player)
	{
		SendHudMessage( localPlayer, text, -1, 0.4, file.red, file.blue, file.green, 0, 0.15, 4, 0.15 )
    }
    #endif
}