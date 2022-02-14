global function CheckPlayerName
global function CheckWeaponName
global function CheckWeaponMod

global array<entity> successfulnames = [];
global array<string> successfulweapons = [];
global array<string> successfulmods = [];

void function CheckPlayerName(string name)
{
    array<entity> players = GetPlayerArray()
    successfulnames = [];
    foreach (entity player in players)
    {
        if (player != null)
        {
            string playername = player.GetPlayerName()
            if (playername.tolower().find(name.tolower()) != null)
            {
                print("Detected " + playername + "!")
                successfulnames.append(player)
            }
        }
    }
    return;
}

void function CheckWeaponName(string name)
{
    successfulweapons = [];
    array<string> weapons = [];

    foreach (string blah in defensives)
    {
        weapons.append(blah)
    }
    foreach (string blah in tacticals)
    {
        weapons.append(blah)
    }
    foreach (string blah in cores)
    {
        weapons.append(blah)
    }
    foreach (string blah in melee)
    {
        weapons.append(blah)
    }

    foreach (string blah in customweapon)
    {
        weapons.append(blah)
    }

    array<string> literallyeveryweapon = GetAllWeaponsByType( [ eItemTypes.PILOT_PRIMARY, eItemTypes.PILOT_SECONDARY, eItemTypes.PILOT_SPECIAL, eItemTypes.PILOT_ORDNANCE, eItemTypes.TITAN_PRIMARY, eItemTypes.TITAN_ORDNANCE ] )
    foreach (string blah in literallyeveryweapon)
    {
        weapons.append(blah)
    }

    foreach (string weaponname in weapons)
    {
        if ( weaponname.tolower().find(name.tolower()) != null )
        {
            if ( weaponname.tolower() == name ) {
                print("Detected one " + weaponname + "!")
                successfulweapons = [];
                successfulweapons.append(weaponname)
                return;
            }
            print( "Detected " + weaponname + "!" )
            successfulweapons.append(weaponname)
        }
    }
}

void function CheckWeaponMod(string weaponId, array<string> mods)
{
    successfulmods = []
    array<string> amods
    amods = GetWeaponMods_Global( weaponId );
    foreach (modname in mods)
    {
        foreach (mod in amods)
        {
            if (mod.tolower().find(modname.tolower()) != null)
            {
                successfulmods.append(mod)
            }
        }
    }
}