untyped

global function Init_Peacekraber

void function Init_Peacekraber()
{
	AddCallback_OnRegisterCustomItems( AddPeacekraberData )
	#if SERVER
		//getconsttable()[ "eDamageSourceId" ][ "mp_weapon_peacekraber" ] <- "#TITAN"
	#endif
}

void function AddPeacekraberData()
{
	CreateWeaponData(PersistenceGetEnumIndexForItemName( "moddedPilotWeaponsAndOffhands", "mp_weapon_peacekraber" ), 0, false, "mp_weapon_peacekraber", false, 0, true )
	//int dataTableIndex, int itemType, bool hidden, string ref, bool isDamageSource, int cost = 0, bool isModded = false
	InitUnlock( "mp_weapon_peacekraber", "", eUnlockType.PLAYER_LEVEL, 33, 100 )
	
	WeaponSetXPPerLevelType("mp_weapon_peacekraber", "default")
	// default, sniper, pistol, or antititan are valid here

	// MOD SLOTS
	CreateGenericSubItemData( eItemTypes.WEAPON_FEATURE, "mp_weapon_peacekraber", "primarymod2", 0 )
	CreateGenericSubItemData( eItemTypes.WEAPON_FEATURE, "mp_weapon_peacekraber", "primarymod3", 0 )

	// MODS
	CreateModData( eItemTypes.PILOT_PRIMARY_MOD, "mp_weapon_peacekraber", "pas_fast_reload" )
	// int itemType, string parentRef, string modRef, int cost = 0, int statDamage = 0, int statAccuracy = 0, int statRange = 0, int statFireRate = 0, int statClipSize = 0 
	InitUnlock( "pas_fast_reload", "mp_weapon_peacekraber", eUnlockType.WEAPON_LEVEL, 5 )
	// string ref, string parentRef, int unlockType, int unlockLevel, int cost = 0, string additionalRef = ""
	
	CreateModData( eItemTypes.PILOT_PRIMARY_MOD, "mp_weapon_peacekraber", "pas_fast_swap" )
	InitUnlock( "pas_fast_swap", "mp_weapon_peacekraber", eUnlockType.WEAPON_LEVEL, 10 )

	CreateModData( eItemTypes.PILOT_PRIMARY_MOD, "mp_weapon_peacekraber", "pas_fast_ads" )
	InitUnlock( "pas_fast_ads", "mp_weapon_peacekraber", eUnlockType.WEAPON_LEVEL, 15 )

	CreateModData( eItemTypes.PILOT_PRIMARY_MOD, "mp_weapon_peacekraber", "tactical_cdr_on_kill" )
	InitUnlock( "tactical_cdr_on_kill", "mp_weapon_peacekraber", eUnlockType.WEAPON_LEVEL, 35 )

	CreateModData( eItemTypes.PILOT_PRIMARY_MOD, "mp_weapon_peacekraber", "extended_ammo" )
	InitUnlock( "extended_ammo", "mp_weapon_peacekraber", eUnlockType.WEAPON_LEVEL, 25 )

	// SIGHTS - BROKEN FOR PEACEKRABER (it doesnt have mdl stuff for the optics i want to use)
	//CreateModData( eItemTypes.PILOT_PRIMARY_ATTACHMENT, "mp_weapon_peacekraber", "redline_sight" )
	//InitUnlock( "redline_sight", "mp_weapon_peacekraber", eUnlockType.WEAPON_LEVEL, 30 )

	//CreateModData( eItemTypes.PILOT_PRIMARY_ATTACHMENT, "mp_weapon_peacekraber", "holosight" )
	//InitUnlock( "holosight", "mp_weapon_peacekraber", eUnlockType.WEAPON_LEVEL, 20 )

	// PRO SCREEN
	CreateModData( 7, "mp_weapon_peacekraber", "pro_screen" )

	InitUnlock( "pro_screen", "mp_weapon_peacekraber", eUnlockType.WEAPON_LEVEL, 40 )

	var camoSkinsDataTable = GetDataTable( $"datatable/camo_skins.rpak" )
	for ( int camoRow = 0; camoRow < GetDatatableRowCount( camoSkinsDataTable ); camoRow++ )
	{
		string camoRef = GetDataTableString( camoSkinsDataTable, camoRow, GetDataTableColumnByName( camoSkinsDataTable, CAMO_REF_COLUMN_NAME ) )
		int weaponCamoCost = GetDataTableInt( camoSkinsDataTable, camoRow, GetDataTableColumnByName( camoSkinsDataTable, CAMO_PILOT_WEAPON_COST_COLUMN_NAME ) )
		int categoryId = GetDataTableInt( camoSkinsDataTable, camoRow, GetDataTableColumnByName( camoSkinsDataTable, CAMO_CATEGORY_COLUMN_NAME ) )

		CreateGenericSubItemData( eItemTypes.CAMO_SKIN, "mp_weapon_peacekraber", camoRef, weaponCamoCost, { categoryId = categoryId } )
		InitUnlockAsEntitlement( camoRef, "mp_weapon_peacekraber", ET_DELUXE_EDITION )
	}

	// why must respawn hardcode this :pain:
	// i have to do all this because it determines the order of things in the camo selection screen

	InitUnlockForStatInt( "camo_skin67", "mp_weapon_peacekraber", 100, "weapon_kill_stats", "pilots", "mp_weapon_peacekraber" )
	InitUnlockForStatInt( "camo_skin65", "mp_weapon_peacekraber", 250,  "weapon_kill_stats", "pilots", "mp_weapon_peacekraber" )
	InitUnlockForStatInt( "camo_skin66", "mp_weapon_peacekraber", 500, "weapon_kill_stats", "pilots", "mp_weapon_peacekraber" )
	InitUnlockForStatInt( "camo_skin64", "mp_weapon_peacekraber", 1000, "weapon_kill_stats", "pilots", "mp_weapon_peacekraber" )
	InitUnlockForStatInt( "camo_skin63", "mp_weapon_peacekraber", 2500, "weapon_kill_stats", "pilots", "mp_weapon_peacekraber" )

	InitUnlockForStatInt( "camo_skin56", "mp_weapon_peacekraber", 10, "weapon_stats", "shotsHit", "mp_weapon_peacekraber" )
	InitUnlockForStatInt( "camo_skin58", "mp_weapon_peacekraber", 100, "weapon_stats", "shotsHit", "mp_weapon_peacekraber" )
	InitUnlockForStatInt( "camo_skin55", "mp_weapon_peacekraber", 500, "weapon_stats", "shotsHit", "mp_weapon_peacekraber" )
	InitUnlockForStatInt( "camo_skin57", "mp_weapon_peacekraber", 1000, "weapon_stats", "shotsHit", "mp_weapon_peacekraber" )
	InitUnlockForStatInt( "camo_skin91", "mp_weapon_peacekraber", 2500, "weapon_stats", "shotsHit", "mp_weapon_peacekraber" )

	InitUnlockForStatInt( "camo_skin93", "mp_weapon_peacekraber", 2, "weapon_kill_stats", "killingSprees", "mp_weapon_peacekraber" )
	InitUnlockForStatInt( "camo_skin94", "mp_weapon_peacekraber", 5, "weapon_kill_stats", "killingSprees", "mp_weapon_peacekraber" )
	InitUnlockForStatInt( "camo_skin13", "mp_weapon_peacekraber", 10, "weapon_kill_stats", "killingSprees", "mp_weapon_peacekraber" )
	InitUnlockForStatInt( "camo_skin07", "mp_weapon_peacekraber", 25, "weapon_kill_stats", "killingSprees", "mp_weapon_peacekraber" )
	InitUnlockForStatInt( "camo_skin85", "mp_weapon_peacekraber", 50, "weapon_kill_stats", "killingSprees", "mp_weapon_peacekraber" )

	InitUnlockForStatInt( "camo_skin60", "mp_weapon_peacekraber", 10, "weapon_stats", "headshots", "mp_weapon_peacekraber" )
	InitUnlockForStatInt( "camo_skin61", "mp_weapon_peacekraber", 25, "weapon_stats", "headshots", "mp_weapon_peacekraber" )
	InitUnlockForStatInt( "camo_skin62", "mp_weapon_peacekraber", 50, "weapon_stats", "headshots", "mp_weapon_peacekraber" )
	InitUnlockForStatInt( "camo_skin59", "mp_weapon_peacekraber", 100, "weapon_stats", "headshots", "mp_weapon_peacekraber" )
	InitUnlockForStatInt( "camo_skin87", "mp_weapon_peacekraber", 250, "weapon_stats", "headshots", "mp_weapon_peacekraber" )

	InitUnlockAsEntitlement( "skin_kraber_masterwork", "mp_weapon_peacekraber", ET_DLC8_KRABER_WARPAINT, "StoreMenu_WeaponSkins" )

	InitUnlockAsEntitlement( "camo_skin10", "mp_weapon_peacekraber", ET_DELUXE_EDITION )
	InitUnlockAsEntitlement( "camo_skin92", "mp_weapon_peacekraber", ET_DELUXE_EDITION )

	
	// levelling up rewards
	var dataTable = GetDataTable( $"datatable/unlocks_weapon_level_pilot.rpak" )
	int numRows = GetDatatableRowCount( dataTable )
	int column = 1
	while ( GetDataTableString( dataTable, 0, column ) != "mp_weapon_sniper" )
	{
		column++
	}
	string weaponRef = "mp_weapon_peacekraber"
	

	for ( int row = 1; row < numRows; row++ )
	{
		string unlockField = GetDataTableString( dataTable, row, column )
		array<string> unlockArray = SplitAndStripUnlockField( unlockField )

		foreach ( unlock in unlockArray )
		{
			if ( unlock != "" )
			try
			{
				InitUnlock( unlock, weaponRef, eUnlockType.WEAPON_LEVEL, row )
			}
			catch (ex)
			{
				// index doesnt exist, too bad!
			}
		}
	}

	
}