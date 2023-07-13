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
	thread UpdateCachedLoadouts_Threaded()
}

void function UpdateCachedLoadouts_Threaded()
{
	#if UI
	RunClientScript( "UpdateCachedLoadouts_Delayed" ) // keep client and UI synced
	#endif
	wait 1.0 // give the server time to network our new persistence

	#if UI
	UpdateCachedLoadouts()
	#else
	UpdateCachedLoadouts()
	#endif

	// below here is just making all the menu models update properly and such

	#if UI
	uiGlobal.pilotSpawnLoadoutIndex = GetPersistentSpawnLoadoutIndex( GetUIPlayer(), "pilot" )
	uiGlobal.titanSpawnLoadoutIndex = GetPersistentSpawnLoadoutIndex( GetUIPlayer(), "titan" )
	#endif

	#if CLIENT
	entity player = GetLocalClientPlayer()
	ClearAllTitanPreview( player )
	ClearAllPilotPreview( player )
	UpdateTitanModel( player, GetPersistentSpawnLoadoutIndex( player, "titan" ) )
	UpdatePilotModel( player, GetPersistentSpawnLoadoutIndex( player, "pilot" ) )
	#endif
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

	// patch
	CallsignIcon icon = PlayerCallsignIcon_GetActive( player )
	if ( IsItemLocked( player, icon.ref ) )
	{
		printt( "- BANNER PATCH IS LOCKED, RESETTING" )
		PlayerCallsignIcon_SetActiveByRef( player, "gc_icon_titanfall" ) // copied from _persistentdata.gnut
	}

	// faction
	int factionIndex = player.GetPersistentVarAsInt( "factionChoice" )
	string factionRef = PersistenceGetEnumItemNameForIndex( "faction", factionIndex )
	if ( IsItemLocked( player, factionRef ) )
	{
		printt( "- FACTION IS LOCKED, RESETTING" )
		player.SetPersistentVar( "factionChoice", "faction_marauder" ) // im so sorry that i am setting you to use sarah, you don't deserve this
	}

	// titan loadouts
	for ( int titanLoadoutIndex = 0; titanLoadoutIndex < NUM_PERSISTENT_TITAN_LOADOUTS; titanLoadoutIndex++ )
	{
		printt( "- VALIDATING TITAN LOADOUT: " + titanLoadoutIndex )

		bool isSelected = titanLoadoutIndex == player.GetPersistentVarAsInt( "titanSpawnLoadout.index" )
		TitanLoadoutDef loadout = GetTitanLoadout( player, titanLoadoutIndex )
		TitanLoadoutDef defaultLoadout = shGlobal.defaultTitanLoadouts[titanLoadoutIndex]

		printt( "  - CHASSIS: " + loadout.titanClass )

		// passive1 - "Titan Kit" (things like overcore)
		if ( loadout.passive1 != defaultLoadout.passive1 && IsSubItemLocked( player, loadout.passive1, loadout.titanClass ) )
		{
			printt( "  - TITAN KIT EQUIPPED WHEN LOCKED, RESETTING" )
			player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].passive1", defaultLoadout.passive1 )
		}

		// passive2 - "<chassis> Kit" (things like zero point tripwire)
		if ( loadout.passive2 != defaultLoadout.passive2 && IsSubItemLocked( player, loadout.passive2, loadout.titanClass ) )
		{
			printt( "  - CHASSIS KIT EQUIPPED WHEN LOCKED, RESETTING" )
			player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].passive2", defaultLoadout.passive2 )
		}

		// passive3 - "Titanfall Kit" (warpfall/dome shield)
		if ( loadout.passive3 != defaultLoadout.passive3 && IsSubItemLocked( player, loadout.passive3, loadout.titanClass ) )
		{
			printt( "  - TITANFALL KIT EQUIPPED WHEN LOCKED, RESETTING" )
			player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].passive3", defaultLoadout.passive3 )
		}

		// passive4 - monarch core 1
		if ( loadout.passive4 != defaultLoadout.passive4 && IsSubItemLocked( player, loadout.passive4, loadout.titanClass ) )
		{
			printt( "  - MONARCH CORE 1 KIT EQUIPPED WHEN LOCKED, RESETTING" )
			player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].passive4", defaultLoadout.passive4 )
		}

		// passive5 - monarch core 2
		if ( loadout.passive5 != defaultLoadout.passive5 && IsSubItemLocked( player, loadout.passive5, loadout.titanClass ) )
		{
			printt( "  - MONARCH CORE 2 KIT EQUIPPED WHEN LOCKED, RESETTING" )
			player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].passive5", defaultLoadout.passive5 )
		}

		// passive6 - monarch core 3
		if ( loadout.passive6 != defaultLoadout.passive6 && IsSubItemLocked( player, loadout.passive6, loadout.titanClass ) )
		{
			printt( "  - MONARCH CORE 3 KIT EQUIPPED WHEN LOCKED, RESETTING" )
			player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].passive6", defaultLoadout.passive6 )
		}

		// titanExecution
		if ( !IsRefValid( loadout.titanExecution ) || !IsValidTitanExecution( titanLoadoutIndex, "titanExecution", "", loadout.titanExecution ) )
		{
			printt( "  - TITAN EXECUTION IS INVALID FOR CHASSIS, RESETTING" )
			player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].titanExecution", defaultLoadout.titanExecution )
		}
		else if ( IsItemLocked( player, loadout.titanExecution ) )
		{
			printt( "  - TITAN EXECUTION EQUIPPED WHEN LOCKED, RESETTING" )
			player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].titanExecution", defaultLoadout.titanExecution )
		}
		else if ( GetItemData( loadout.titanExecution ).reqPrime && IsItemLocked( player, loadout.primeTitanRef ) )
		{
			printt( "  - PRIME TITAN EXECUTION EQUIPPED WHEN PRIME TITAN IS LOCKED, RESETTING" )
			player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].titanExecution", defaultLoadout.titanExecution )
		}

		// skinIndex
		// camoIndex
		if ( loadout.skinIndex == TITAN_SKIN_INDEX_CAMO )
		{
			array<ItemData> camoSkins = GetAllItemsOfType( eItemTypes.CAMO_SKIN )
			if ( loadout.camoIndex >= camoSkins.len() || loadout.camoIndex < 0 )
			{
				printt( "  - INVALID TITAN CAMO/SKIN, RESETTING" )
				player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].skinIndex", defaultLoadout.skinIndex )
				player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].camoIndex", defaultLoadout.camoIndex )
			}
			else
			{
				ItemData camoSkin = camoSkins[loadout.camoIndex]
				if ( IsSubItemLocked( player, camoSkin.ref, loadout.titanClass ) )
				{
					printt( "  - TITAN CAMO/SKIN EQUIPPED WHEN LOCKED, RESETTING" )
					player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].skinIndex", defaultLoadout.skinIndex )
					player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].camoIndex", defaultLoadout.camoIndex )
				}
			}
		}
		else if ( loadout.skinIndex == 0 )
		{
			if (loadout.camoIndex != 0 )
			{
				printt( "  - INVALID TITAN CAMO/SKIN, RESETTING" )
				player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].skinIndex", defaultLoadout.skinIndex )
				player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].camoIndex", defaultLoadout.camoIndex )
			}
		}
		else
		{
			string ref = GetSkinRefFromTitanClassAndPersistenceValue( loadout.titanClass, loadout.skinIndex )
			if ( ref == INVALID_REF )
			{
				printt( "  - INVALID TITAN WARPAINT, RESETTING" )
				player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].skinIndex", defaultLoadout.skinIndex )
				player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].camoIndex", defaultLoadout.camoIndex )
			}
			else if ( IsSubItemLocked( player, ref, loadout.titanClass ) )
			{
				printt( "  - TITAN WARPAINT EQUIPPED WHEN LOCKED, RESETTING" )
				player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].skinIndex", defaultLoadout.skinIndex )
				player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].camoIndex", defaultLoadout.camoIndex )
			}
		}

		// decalIndex
		string noseArtRef = GetNoseArtRefFromTitanClassAndPersistenceValue( loadout.titanClass, loadout.decalIndex )
		if ( loadout.decalIndex != defaultLoadout.decalIndex && IsSubItemLocked( player, noseArtRef, loadout.titanClass ) )
		{
			printt( "  - NOSE ART EQUIPPED WHEN LOCKED, RESETTING" )
			player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].decalIndex", defaultLoadout.decalIndex )
		}

		// primarySkinIndex
		// primaryCamoIndex
		if ( loadout.primarySkinIndex == WEAPON_SKIN_INDEX_CAMO )
		{
			array<ItemData> camoSkins = GetAllItemsOfType( eItemTypes.CAMO_SKIN )
			if ( loadout.primaryCamoIndex >= camoSkins.len() || loadout.primaryCamoIndex < 0 )
			{
				printt( "  - INVALID WEAPON CAMO/SKIN, RESETTING" )
				player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].primarySkinIndex", defaultLoadout.primarySkinIndex )
				player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].primaryCamoIndex", defaultLoadout.primaryCamoIndex )
			}
			else
			{
				ItemData camoSkin = camoSkins[loadout.primaryCamoIndex]
				if ( IsSubItemLocked( player, camoSkin.ref, loadout.titanClass ) )
				{
					printt( "  - WEAPON CAMO/SKIN EQUIPPED WHEN LOCKED, RESETTING" )
					player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].primarySkinIndex", defaultLoadout.primarySkinIndex )
					player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].primaryCamoIndex", defaultLoadout.primaryCamoIndex )
				}
			}
		}
		else if ( loadout.primarySkinIndex == 0 && loadout.primaryCamoIndex != 0 )
		{
			// titan weapons do not have skins, if we ever do add them lots of stuff will 
			//need a refactor outside of here so with that being said, i cannot be bothered
			printt( "  - INVALID WEAPON CAMO/SKIN, RESETTING" )
			player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].primarySkinIndex", defaultLoadout.primarySkinIndex )
			player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].primaryCamoIndex", defaultLoadout.primaryCamoIndex )
		}
		

		// isPrime
		if ( loadout.isPrime == "titan_is_prime" && IsItemLocked( player, loadout.primeTitanRef ) )
		{
			printt( "  - PRIME TITAN EQUIPPED WHEN LOCKED, RESETTING" )
			player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].isPrime", defaultLoadout.isPrime )
		}

		// primeSkinIndex
		// primeCamoIndex
		if ( loadout.primeSkinIndex == TITAN_SKIN_INDEX_CAMO )
		{
			array<ItemData> camoSkins = GetAllItemsOfType( eItemTypes.CAMO_SKIN )
			if ( loadout.primeCamoIndex >= camoSkins.len() || loadout.primeCamoIndex < 0 )
			{
				printt( "  - INVALID TITAN CAMO/SKIN, RESETTING" )
				player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].primeSkinIndex", defaultLoadout.primeSkinIndex )
				player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].primeCamoIndex", defaultLoadout.primeCamoIndex )
			}
			else
			{
				ItemData camoSkin = camoSkins[loadout.primeCamoIndex]
				if ( IsSubItemLocked( player, camoSkin.ref, loadout.titanClass ) )
				{
					printt( "  - TITAN CAMO/SKIN EQUIPPED WHEN LOCKED, RESETTING" )
					player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].primeSkinIndex", defaultLoadout.primeSkinIndex )
					player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].primeCamoIndex", defaultLoadout.primeCamoIndex )
				}
			}
		}
		else if ( loadout.primeSkinIndex == 0 )
		{
			if (loadout.primeCamoIndex != 0 )
			{
				printt( "  - INVALID TITAN CAMO/SKIN, RESETTING" )
				player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].primeSkinIndex", defaultLoadout.primeSkinIndex )
				player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].primeCamoIndex", defaultLoadout.primeCamoIndex )
			}
		}
		else
		{
			printt( "  - INVALID PRIME TITAN SKIN, RESETTING" )
			player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].primeSkinIndex", defaultLoadout.primeSkinIndex )
			player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].primeCamoIndex", defaultLoadout.primeCamoIndex )
		}

		// primeDecalIndex
		string primeNoseArtRef = GetNoseArtRefFromTitanClassAndPersistenceValue( loadout.titanClass, loadout.primeDecalIndex )
		if ( loadout.primeDecalIndex != defaultLoadout.primeDecalIndex && IsSubItemLocked( player, primeNoseArtRef, loadout.titanClass ) )
		{
			printt( "  - PRIME NOSE ART EQUIPPED WHEN LOCKED, RESETTING" )
			player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].primeDecalIndex", defaultLoadout.primeDecalIndex )
		}

		// showArmBadge - equipped and shouldnt be able to
		if ( loadout.showArmBadge && !CanEquipArmBadge( player, loadout.titanClass ) )
		{
			printt( "  - ARM BADGE EQUIPPED WHEN LOCKED, RESETTING" )
			player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].showArmBadge", defaultLoadout.showArmBadge )
		}

		// equipped titan loadout - equipped titan class is locked
		if ( isSelected && IsItemLocked( player, loadout.titanClass ) )
		{
			printt( "  - SELECTED TITAN CLASS IS LOCKED, RESETTING" )
			player.SetPersistentVar( "titanSpawnLoadout.index", 0 )
			Remote_CallFunction_NonReplay( player, "ServerCallback_UpdateTitanModel", 0 )
		}
	}

	Remote_CallFunction_NonReplay( player, "ServerCallback_UpdateTitanModel", player.GetPersistentVarAsInt( "titanSpawnLoadout.index" ) )

	// pilot loadouts
	for ( int pilotLoadoutIndex = 0; pilotLoadoutIndex < NUM_PERSISTENT_PILOT_LOADOUTS; pilotLoadoutIndex++ )
	{
		printt( "- VALIDATING PILOT LOADOUT: " + pilotLoadoutIndex )

		bool isSelected = pilotLoadoutIndex == player.GetPersistentVarAsInt( "pilotSpawnLoadout.index" )
		PilotLoadoutDef loadout = GetPilotLoadout( player, pilotLoadoutIndex )
		PilotLoadoutDef defaultLoadout = shGlobal.defaultPilotLoadouts[pilotLoadoutIndex]

		// so much to do oh my god
		
		// equipped pilot loadout
		if ( isSelected && IsItemLocked( player, "pilot_loadout_" + ( pilotLoadoutIndex + 1 ) ) )
		{
			printt( "  - SELECTED PILOT LOADOUT IS LOCKED, RESETTING" )
			player.SetPersistentVar( "pilotSpawnLoadout.index", 0 )
			Remote_CallFunction_NonReplay( player, "ServerCallback_UpdatePilotModel", 0 )
		}
	}

	Remote_CallFunction_NonReplay( player, "ServerCallback_UpdatePilotModel", player.GetPersistentVarAsInt( "pilotSpawnLoadout.index" ) )

	printt( "ITEM VALIDATION COMPLETE FOR PLAYER: " + player.GetPlayerName() )
}

// basically just PopulateTitanLoadoutFromPersistentData but without validation, we are doing the validation in a better way
// that doesnt just kick the player and reset the entire loadout, since we want to only reset parts of the loadout that we need
TitanLoadoutDef function GetTitanLoadout( entity player, int loadoutIndex )
{
	TitanLoadoutDef loadout

	loadout.name 				= GetPersistentLoadoutValue( player, "titan", loadoutIndex, "name" )
	loadout.titanClass			= GetPersistentLoadoutValue( player, "titan", loadoutIndex, "titanClass" )
	loadout.primaryMod			= GetPersistentLoadoutValue( player, "titan", loadoutIndex, "primaryMod" )
	loadout.special 			= GetPersistentLoadoutValue( player, "titan", loadoutIndex, "special" )
	loadout.antirodeo 			= GetPersistentLoadoutValue( player, "titan", loadoutIndex, "antirodeo" )
	loadout.passive1 			= GetPersistentLoadoutValue( player, "titan", loadoutIndex, "passive1" )
	loadout.passive2 			= GetPersistentLoadoutValue( player, "titan", loadoutIndex, "passive2" )
	loadout.passive3 			= GetPersistentLoadoutValue( player, "titan", loadoutIndex, "passive3" )
	loadout.passive4 			= GetPersistentLoadoutValue( player, "titan", loadoutIndex, "passive4" )
	loadout.passive5 			= GetPersistentLoadoutValue( player, "titan", loadoutIndex, "passive5" )
	loadout.passive6 			= GetPersistentLoadoutValue( player, "titan", loadoutIndex, "passive6" )
	loadout.camoIndex			= GetPersistentLoadoutValueInt( player, "titan", loadoutIndex, "camoIndex" )
	loadout.skinIndex			= GetPersistentLoadoutValueInt( player, "titan", loadoutIndex, "skinIndex" ) //Important: Skin index needs to be gotten after camoIndex for loadout validation purposes
	loadout.decalIndex			= GetPersistentLoadoutValueInt( player, "titan", loadoutIndex, "decalIndex" )
	loadout.primaryCamoIndex	= GetPersistentLoadoutValueInt( player, "titan", loadoutIndex, "primaryCamoIndex" )
	loadout.primarySkinIndex	= GetPersistentLoadoutValueInt( player, "titan", loadoutIndex, "primarySkinIndex" ) //Important: Skin index needs to be gotten after camoIndex for loadout validation purposes
	loadout.titanExecution 		= GetPersistentLoadoutValue( player, "titan", loadoutIndex, "titanExecution" )
	loadout.showArmBadge		= GetPersistentLoadoutValueInt( player, "titan", loadoutIndex, "showArmBadge" )

	//Prime Titan related vars
	loadout.isPrime			= GetPersistentLoadoutValue( player, "titan", loadoutIndex, "isPrime" )
	loadout.primeCamoIndex	= GetPersistentLoadoutValueInt( player, "titan", loadoutIndex, "primeCamoIndex" )
	loadout.primeSkinIndex	= GetPersistentLoadoutValueInt( player, "titan", loadoutIndex, "primeSkinIndex" ) //Important: Skin index needs to be gotten after camoIndex for loadout validation purposes
	loadout.primeDecalIndex	= GetPersistentLoadoutValueInt( player, "titan", loadoutIndex, "primeDecalIndex" )

	UpdateDerivedTitanLoadoutData( loadout )
	OverwriteLoadoutWithDefaultsForSetFile( loadout )

	return loadout
}

PilotLoadoutDef function GetPilotLoadout( entity player, int loadoutIndex )
{
	PilotLoadoutDef loadout

	loadout.name 				= GetValidatedPersistentLoadoutValue( player, "pilot", loadoutIndex, "name" )
	loadout.suit 				= GetValidatedPersistentLoadoutValue( player, "pilot", loadoutIndex, "suit" )
	loadout.race 				= GetValidatedPersistentLoadoutValue( player, "pilot", loadoutIndex, "race" )
	loadout.execution 			= GetValidatedPersistentLoadoutValue( player, "pilot", loadoutIndex, "execution" )
	loadout.primary 			= GetValidatedPersistentLoadoutValue( player, "pilot", loadoutIndex, "primary" )
	loadout.primaryAttachment	= GetValidatedPersistentLoadoutValue( player, "pilot", loadoutIndex, "primaryAttachment" )
	loadout.primaryMod1			= GetValidatedPersistentLoadoutValue( player, "pilot", loadoutIndex, "primaryMod1" )
	loadout.primaryMod2			= GetValidatedPersistentLoadoutValue( player, "pilot", loadoutIndex, "primaryMod2" )
	loadout.primaryMod3			= GetValidatedPersistentLoadoutValue( player, "pilot", loadoutIndex, "primaryMod3" )
	loadout.secondary 			= GetValidatedPersistentLoadoutValue( player, "pilot", loadoutIndex, "secondary" )
	loadout.secondaryMod1		= GetValidatedPersistentLoadoutValue( player, "pilot", loadoutIndex, "secondaryMod1" )
	loadout.secondaryMod2		= GetValidatedPersistentLoadoutValue( player, "pilot", loadoutIndex, "secondaryMod2" )
	loadout.secondaryMod3		= GetValidatedPersistentLoadoutValue( player, "pilot", loadoutIndex, "secondaryMod3" )
	loadout.weapon3 			= GetValidatedPersistentLoadoutValue( player, "pilot", loadoutIndex, "weapon3" )
	loadout.weapon3Mod1			= GetValidatedPersistentLoadoutValue( player, "pilot", loadoutIndex, "weapon3Mod1" )
	loadout.weapon3Mod2			= GetValidatedPersistentLoadoutValue( player, "pilot", loadoutIndex, "weapon3Mod2" )
	loadout.weapon3Mod3			= GetValidatedPersistentLoadoutValue( player, "pilot", loadoutIndex, "weapon3Mod3" )
	loadout.ordnance 			= GetValidatedPersistentLoadoutValue( player, "pilot", loadoutIndex, "ordnance" )
	loadout.passive1 			= GetValidatedPersistentLoadoutValue( player, "pilot", loadoutIndex, "passive1" )
	loadout.passive2 			= GetValidatedPersistentLoadoutValue( player, "pilot", loadoutIndex, "passive2" )
	loadout.camoIndex			= GetValidatedPersistentLoadoutValueInt( player, "pilot", loadoutIndex, "camoIndex" )
	loadout.skinIndex			= GetValidatedPersistentLoadoutValueInt( player, "pilot", loadoutIndex, "skinIndex" ) //Important: Skin index needs to be gotten after camoIndex for loadout validation purposes
	loadout.primaryCamoIndex	= GetValidatedPersistentLoadoutValueInt( player, "pilot", loadoutIndex, "primaryCamoIndex" )
	loadout.primarySkinIndex	= GetValidatedPersistentLoadoutValueInt( player, "pilot", loadoutIndex, "primarySkinIndex" ) //Important: Skin index needs to be gotten after camoIndex for loadout validation purposes
	loadout.secondaryCamoIndex	= GetValidatedPersistentLoadoutValueInt( player, "pilot", loadoutIndex, "secondaryCamoIndex" )
	loadout.secondarySkinIndex	= GetValidatedPersistentLoadoutValueInt( player, "pilot", loadoutIndex, "secondarySkinIndex" ) //Important: Skin index needs to be gotten after camoIndex for loadout validation purposes
	loadout.weapon3CamoIndex	= GetValidatedPersistentLoadoutValueInt( player, "pilot", loadoutIndex, "weapon3CamoIndex" )
	loadout.weapon3SkinIndex	= GetValidatedPersistentLoadoutValueInt( player, "pilot", loadoutIndex, "weapon3SkinIndex" ) //Important: Skin index needs to be gotten after camoIndex for loadout validation purposes

	UpdateDerivedPilotLoadoutData( loadout )

	return loadout
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