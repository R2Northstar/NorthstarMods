untyped
global function AddCallback_ApplyModWeaponVars
global function CodeCallback_ApplyModWeaponVars
#if SERVER
global function CodeCallback_DoWeaponModsForPlayer
#endif
#if CLIENT
global function CodeCallback_PredictWeaponMods
#endif

// doing overrides last 
global const int WEAPON_VAR_PRIORITY_OVERRIDE = 0
global const int WEAPON_VAR_PRIORITY_ADD = 100
global const int WEAPON_VAR_PRIORITY_MULT = 200

// these are utility global variables for easier setting of more "generic" things
// e.g. hipfire spread, ads spread

global const array<int> HIP_SPREAD_VARS = [eWeaponVar.spread_stand_hip, eWeaponVar.spread_stand_hip_run, eWeaponVar.spread_stand_hip_sprint,
    eWeaponVar.spread_crouch_hip, eWeaponVar.spread_air_hip, eWeaponVar.spread_kick_on_fire_air_hip, eWeaponVar.spread_kick_on_fire_stand_hip, 
    eWeaponVar.spread_kick_on_fire_crouch_hip, eWeaponVar.spread_max_kick_air_hip, eWeaponVar.spread_max_kick_stand_hip, 
    eWeaponVar.spread_max_kick_crouch_hip, eWeaponVar.spread_wallrunning, eWeaponVar.spread_wallhanging] // wallhanging is "ads" but aaplies spread on the level of hipfire? keeping it here.

global const array<int> ADS_SPREAD_VARS = [eWeaponVar.spread_stand_ads, eWeaponVar.spread_crouch_ads, eWeaponVar.spread_air_ads, 
    eWeaponVar.spread_kick_on_fire_air_ads, eWeaponVar.spread_kick_on_fire_stand_ads, eWeaponVar.spread_kick_on_fire_crouch_ads, 
    eWeaponVar.spread_max_kick_air_ads, eWeaponVar.spread_max_kick_stand_ads, eWeaponVar.spread_max_kick_crouch_ads]

global const array<int> RELOAD_TIME_VARS = [eWeaponVar.reload_time, eWeaponVar.reloadempty_time,
eWeaponVar.reload_time_late1, eWeaponVar.reload_time_late2, eWeaponVar.reload_time_late3, eWeaponVar.reload_time_late4, 
eWeaponVar.reload_time_late5, eWeaponVar.reloadempty_time_late1, eWeaponVar.reloadempty_time_late2, eWeaponVar.reloadempty_time_late3, 
eWeaponVar.reloadempty_time_late4, eWeaponVar.reloadempty_time_late5, eWeaponVar.reloadsegment_time_loop,
eWeaponVar.reloadsegment_time_end, eWeaponVar.reloadsegmentempty_time_end]

global enum WeaponVarType
{
    INTEGER = 1,
    FLOAT = 2,
    BOOLEAN = 3,
    STRING = 4,
    ASSET = 5,
    VECTOR = 6,
    SPECIAL
}

struct CallbackArray
{
    int priority
    array<void functionref( entity )> callbacks
}

struct
{
    array<CallbackArray> weaponVarCallbacks
} file

int function SortByPriority( CallbackArray a, CallbackArray b )
{
    if (a.priority > b.priority)
        return 1
    else if (a.priority < b.priority)
        return -1
    
    return 0
}

// because order matters when applying weapon vars,
void function AddCallback_ApplyModWeaponVars( int priority, void functionref( entity ) callback )
{
    foreach (CallbackArray arr in file.weaponVarCallbacks)
    {
        if (arr.priority == priority)
        {
            arr.callbacks.append(callback)
        }
    }

    CallbackArray arr
    arr.priority = priority
    arr.callbacks = [ callback ]
    file.weaponVarCallbacks.append(arr)
    file.weaponVarCallbacks.sort(SortByPriority)
}

// called whenever a weapon's variables are calculated
// can be done thru ModWeaponVars_CalculateWeaponMods
// or by chamging the mods of a weapon
void function CodeCallback_ApplyModWeaponVars( entity weapon )
{
    // when a weapon is equipped for the first frame
    // for some reason in prediction only ammo is -1
    // this can cause visual glitches when mods
    // rely on ammo to calculate values (specifically,
    // spread)
    if (weapon.GetWeaponPrimaryClipCount() == -1) 
    {
        return
    }

    // dont waste performance on weapons not
    // being used
    if (!IsValid(weapon.GetOwner()))
        return
    
    foreach (CallbackArray arr in file.weaponVarCallbacks)
    {
        foreach (void functionref( entity ) callback in arr.callbacks)
        {
            callback( weapon )
        }
    }
}

#if CLIENT
// called in prediction for some reason(?)
// done for every weapon the local player has
void function CodeCallback_PredictWeaponMods( entity weapon )
{
    if (!IsValid(weapon))
        return

    // avoids some visual glitches that happen if we set weaponmods
    // this is done here too to save performance
    if (weapon.GetWeaponPrimaryClipCount() == -1)
    {
        return
    }

    ModWeaponVars_CalculateWeaponMods( weapon )
}
#endif

#if SERVER
// called every TICK (NOT script frame) for every player.
// used for calculating a player's weaponvars for
// their active and selected (weapon being switched to)
// weapons.
void function CodeCallback_DoWeaponModsForPlayer( entity player )
{
    if (!IsValid(player))
        return
    if (!IsValid(player.GetActiveWeapon()))
        return
    
    // recalculating mods is slightly expensive - enough
    // that doing it for all weapons for all players
    // is a bad idea. so offloading mod recalculation
    // responsibility to the modder is better imo.
    // we do it for the active weapon to not cause mispredictions. 
    // However, client does it every frame for the all of their weapons.
    // (done in native, we arent in control of it.)
    ModWeaponVars_CalculateWeaponMods( player.GetActiveWeapon() )
    
    // the weapon the player is about to switch to
    if (IsValid(player.GetSelectedWeapon()))
    {
        ModWeaponVars_CalculateWeaponMods( player.GetSelectedWeapon() )
    }
}
#endif