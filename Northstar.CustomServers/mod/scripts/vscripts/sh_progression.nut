global function Progression_Init
global function ProgressionEnabledForPlayer
#if SERVER
#else
global function Progression_SetPreference
global function Progression_GetPreference
global function UpdateCachedLoadouts_Delayed
#endif

#if SERVER
struct {
	table<entity, bool> progressionEnabled
} file
#endif


void function Progression_Init()
{
	#if SERVER
	AddCallback_OnClientDisconnected( OnClientDisconnected )
	AddClientCommandCallback( "ns_progression", ClientCommand_SetProgression )
	AddCallback_GameStateEnter( eGameState.Playing, OnPlaying )
	#elseif CLIENT
	AddCallback_OnClientScriptInit( OnClientScriptInit )
	#endif
}

bool function ProgressionEnabledForPlayer( entity player )
{
	#if SERVER
	if ( player in file.progressionEnabled )
		return file.progressionEnabled[player]
	
	return false
	#else
	return GetConVarBool( "ns_progression_enabled" )
	#endif
}

#if SERVER
void function OnPlaying()
{
	SetUIVar( level, "penalizeDisconnect", false ) // dont show the "you will lose merits thing"
	SetUIVar( level, "showGameSummary", true ) // show the EOG summary xp thing
}

void function OnClientDisconnected( entity player )
{
	// cleanup table when player leaves
	if ( player in file.progressionEnabled )
		delete file.progressionEnabled[player]
}

bool function ClientCommand_SetProgression( entity player, array<string> args )
{
	if ( args.len() != 1 )
		return false
	if ( args[0] != "0" && args[0] != "1" )
		return false
	
	file.progressionEnabled[player] <- args[0] == "1"

	// loadout validation when progression is turned on
	if ( file.progressionEnabled[player] )
		ValidateEquippedItems( player )

	return true
}
#endif

#if CLIENT
void function OnClientScriptInit( entity player )
{
	// unsure if this is needed, just being safe
	if ( player != GetLocalClientPlayer() )
		return

	Progression_SetPreference( GetConVarBool( "ns_progression_enabled" ) )
}
#endif

#if CLIENT || UI
void function Progression_SetPreference( bool enabled )
{
	SetConVarBool( "ns_progression_enabled", enabled )

	#if CLIENT
	GetLocalClientPlayer().ClientCommand( "ns_progression " + enabled.tointeger() )
	#elseif UI
	ClientCommand( "ns_progression " + enabled.tointeger() )
	#endif
}

bool function Progression_GetPreference()
{
	return GetConVarBool( "ns_progression_enabled" )
}

void function UpdateCachedLoadouts_Delayed()
{
	wait 1.0 // give the server time to network our new persistence
	#if UI
	RunClientScript( "UpdateCachedLoadouts" ) // keep client and UI synced
	#else
	RunUIScript( "UpdateCachedLoadouts" ) // keep client and UI synced
	#endif
	UpdateCachedLoadouts()
}
#endif

#if SERVER
void function ValidateEquippedItems( entity player )
{
	printt( "VALIDATING EQUIPPED ITEMS FOR PLAYER: " + player.GetPlayerName() )

	// banner
	CallingCard card = PlayerCallingCard_GetActive( player )
	if ( IsItemLocked( player, card.ref ) )
	{
		printt( "- BANNER CARD IS LOCKED, RESETTING" )
		PlayerCallingCard_SetActiveByRef( player, "callsign_16_col" ) // copied from _persistentdata.gnut
	}
	else
	{
		printt( "- BANNER CARD IS UNLOCKED" )
	}

	// patch
	CallsignIcon icon = PlayerCallsignIcon_GetActive( player )
	if ( IsItemLocked( player, icon.ref ) )
	{
		printt( "- BANNER PATCH IS LOCKED, RESETTING" )
		PlayerCallsignIcon_SetActiveByRef( player, "gc_icon_titanfall" ) // copied from _persistentdata.gnut
	}
	else
	{
		printt( "- BANNER PATCH IS UNLOCKED" )
	}

	// faction
	int factionIndex = player.GetPersistentVarAsInt( "factionChoice" )
	string factionRef = PersistenceGetEnumItemNameForIndex( "faction", factionIndex )
	if ( IsItemLocked( player, factionRef ) )
	{
		printt( "- FACTION IS LOCKED, RESETTING" )
		player.SetPersistentVar( "factionChoice", "faction_marauder" ) // im so sorry that i am setting you to use sarah
	}
	else
	{
		printt( "- FACTION IS UNLOCKED" )
	}

	// titan loadouts
	for ( int titanLoadoutIndex = 0; titanLoadoutIndex < NUM_PERSISTENT_TITAN_LOADOUTS; titanLoadoutIndex++ )
	{
		printt( "- VALIDATING TITAN LOADOUT: " + titanLoadoutIndex )

		bool hasChanged = false
		TitanLoadoutDef loadout = GetTitanLoadoutFromPersistentData( player, titanLoadoutIndex )
		TitanLoadoutDef defaultLoadout = shGlobal.defaultTitanLoadouts[titanLoadoutIndex]

		// titanClass
		// primaryMod
		// special
		// antirodeo
		// passive1
		// passive2
		// passive3
		// passive4
		// passive5
		// passive6
		// titanExecution
		// skinIndex
		// camoIndex
		// decalIndex
		// primarySkinIndex
		// primaryCamoIndex
		// isPrime
		// primeSkinIndex
		// primeCamoIndex
		// primeDecalIndex

		// showArmBadge - equipped and shouldnt be able to
		if ( loadout.showArmBadge && !CanEquipArmBadge( player, loadout.titanClass ) )
		{
			printt( "  - ARM BADGE EQUIPPED WHEN LOCKED, RESETTING" )
			player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].showArmBadge", defaultLoadout.showArmBadge )
			hasChanged = true
		}

		if ( hasChanged )
		{
			Remote_CallFunction_NonReplay( player, "ServerCallback_UpdateTitanModel", titanLoadoutIndex )
		}
		
	}
	Remote_CallFunction_NonReplay( player, "UpdateAllCachedTitanLoadouts" )

	// pilot loadouts
	for ( int pilotLoadoutIndex = 0; pilotLoadoutIndex < NUM_PERSISTENT_PILOT_LOADOUTS; pilotLoadoutIndex++ )
	{
		bool hasChanged = false
		if ( hasChanged )
		{
			Remote_CallFunction_NonReplay( player, "ServerCallback_UpdatePilotModel", pilotLoadoutIndex )
		}
	}
	Remote_CallFunction_NonReplay( player, "UpdateAllCachedPilotLoadouts" )


	printt( "ITEM VALIDATION COMPLETE FOR PLAYER: " + player.GetPlayerName() )
}

bool function CanEquipArmBadge( entity player, string titanClass )
{
	string skinRef
	switch ( titanClass )
	{
		case "ion":
			skinRef = "ion_skin_fd"
			break
		case "scorch":
			skinRef = "scorch_skin_fd"
			break
		case "northstar":
			skinRef = "northstar_skin_fd"
			break
		case "ronin":
			skinRef = "ronin_skin_fd"
			break
		case "tone":
			skinRef = "tone_skin_fd"
			break
		case "legion":
			skinRef = "legion_skin_fd"
			break
		case "vanguard":
			skinRef = "monarch_skin_fd"
			break
	}

	return !IsSubItemLocked( player, skinRef, titanClass )
}
#endif