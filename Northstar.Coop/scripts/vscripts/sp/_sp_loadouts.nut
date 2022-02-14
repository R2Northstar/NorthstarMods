global function GetPilotLoadoutForCurrentMapSP
global function GetTitanLoadoutForCurrentMap
global function SpInitLoadouts
global function SPTitanLoadout_RemoveOwnedLoadoutPickupsInLevel
global function GetNPCDefaultWeaponForLevel
global function SetDefaultWeapons_Spectre
global function SetDefaultWeapons_Stalker
global function SetDefaultWeapons_SoldierRifle
global function SetDefaultWeapons_SoldierSmg
global function SetDefaultWeapons_SoldierSniper
global function SetDefaultWeapons_SoldierShotgun
global function SetDefaultWeapons_Specialist
global function PopulateLevelTransWithLoadouts
global function GetNPCDefaultWeapons
global function GetWeaponModsForCurrentLevel
global function AddOffhandWeaponMod_IfPlayerHas
global function RemoveOffhandWeaponMod_IfPlayerHas
global function GetAllPrecachedSPWeapons
global function PopulatePilotLoadoutFromLevelTrans
global function SPTitanLoadout_SetupForLevelStart

global function NotifyUI_ShowTitanLoadout
global function NotifyUI_HideTitanLoadout

global function UI_NotifySPTitanLoadoutChange
global function SPTitanLoadout_SpawnAtCrosshairDEV
global function CodeCallback_WeaponLoadoutPickup
global function GetWeaponCooldownsForTitanLoadoutSwitch
global function SetWeaponCooldownsForTitanLoadoutSwitch
global function AssignDefaultNPCSidearm

const float LOADOUT_SWITCH_COOLDOWN_PENALTY = 5.0  // 5 second penalty

struct WeaponCooldownData
{
	float timeStored
	float severity
}

struct
{
	table< string, table< string, array<NPCDefaultWeapon> > > npcDefaultWeapons
	table< string, array<string> > npcDefaultWeaponMods

	table< string, WeaponCooldownData > cooldownData
} file

void function SpInitLoadouts()
{
	file.npcDefaultWeapons[ "npc_soldier" ] <- {}
	file.npcDefaultWeapons[ "npc_spectre" ] <- {}
	file.npcDefaultWeapons[ "npc_stalker" ] <- {}

	AddCallback_OnPlayerInventoryChanged( UI_NotifySPTitanLoadoutChange )
	AddClientCommandCallback( "bt_loadout_select", ClientCommand_bt_loadout_select )
	AddClientCommandCallback( "bt_loadout_mark_selected", ClientCommand_bt_loadout_mark_selected )

	switch ( GetMapName() )
	{

		case "sp_crashsite": //wilds
			SetDefaultWeapons_SoldierAntiTitan( 	"mp_weapon_rocket_launcher" )
			SetDefaultWeapons_SoldierPistol( 		"mp_weapon_semipistol" )
			SetDefaultWeapons_SoldierRifle( 		"mp_weapon_rspn101" )
			SetDefaultWeapons_SoldierRifle( 		"mp_weapon_hemlok", [ 			"hcog" ] )
			SetDefaultWeapons_SoldierShotgun( 		"mp_weapon_shotgun" )
			SetDefaultWeapons_SoldierSmg( 			"mp_weapon_car" )
			SetDefaultWeapons_SoldierSniper( 		"mp_weapon_dmr" )

			SetDefaultWeapons_Spectre( 				"mp_weapon_rspn101" )
			SetDefaultWeapons_SpectreAntiTitan( 	"mp_weapon_smr" )
			SetDefaultWeapons_SpectrePistol( 		"mp_weapon_semipistol" )
			SetDefaultWeapons_SpectreRifle( 		"mp_weapon_rspn101", [ 			"hcog" ] )
			SetDefaultWeapons_SpectreRifle( 		"mp_weapon_rspn101", [ 			"hcog" ] )	// dupe to increase usage
			SetDefaultWeapons_SpectreRifle( 		"mp_weapon_hemlok_smg", [ 		"holosight" ] )
			SetDefaultWeapons_SpectreShotgun( 		"mp_weapon_shotgun" )
			SetDefaultWeapons_SpectreSmg( 			"mp_weapon_car" )
			SetDefaultWeapons_SpectreSniper( 		"mp_weapon_dmr" )
			break

		case "sp_sewers1":
			SetDefaultWeapons_SoldierAntiTitan( 	"mp_weapon_rocket_launcher" )
			SetDefaultWeapons_SoldierPistol( 		"mp_weapon_semipistol" )
			SetDefaultWeapons_SoldierRifle( 		"mp_weapon_rspn101" )
			SetDefaultWeapons_SoldierRifle( 		"mp_weapon_rspn101", [ 			"hcog" ] )
			SetDefaultWeapons_SoldierShotgun( 		"mp_weapon_shotgun", [ 			"extended_ammo" ] )
			SetDefaultWeapons_SoldierSmg( 			"mp_weapon_r97", [ 				"holosight"] )
			SetDefaultWeapons_SoldierSmg( 			"mp_weapon_alternator_smg" )
			SetDefaultWeapons_SoldierSniper( 		"mp_weapon_sniper" )
			SetDefaultWeapons_Spectre( 				"mp_weapon_r97", [ 				"holosight"] )
			SetDefaultWeapons_Stalker( 				"mp_weapon_lstar" )
			break

		case "sp_boomtown_start":

			SetDefaultWeapons_SoldierRifle( 		"mp_weapon_vinson" )
			SetDefaultWeapons_SoldierRifle( 		"mp_weapon_vinson", [			"hcog"] )
			SetDefaultWeapons_SoldierRifle( 		"mp_weapon_lmg", [				"aog"] )
			SetDefaultWeapons_SoldierAntiTitan( 	"mp_weapon_mgl" )
			SetDefaultWeapons_SoldierPistol( 		"mp_weapon_semipistol" )
			SetDefaultWeapons_SoldierShotgun( 		"mp_weapon_shotgun_pistol" )

			SetDefaultWeapons_Stalker( 				"mp_weapon_lstar" )

			SetDefaultWeapons_Spectre( 				"mp_weapon_lmg", [				"holosight"] )
			SetDefaultWeapons_SpectreAntiTitan( 	"mp_weapon_mgl" )
			SetDefaultWeapons_SpectrePistol( 		"mp_weapon_semipistol" )
			SetDefaultWeapons_SpectreRifle( 		"mp_weapon_vinson" )
			SetDefaultWeapons_SpectreShotgun( 		"mp_weapon_shotgun_pistol" )
			break

		case "sp_boomtown":

			//SetDefaultWeapons_SoldierRifle( "mp_weapon_vinson", [ "hcog" ] )
			SetDefaultWeapons_SoldierRifle( 		"mp_weapon_lmg", [				"holosight"] )
			SetDefaultWeapons_SoldierSniper( 		"mp_weapon_g2", [ 				"hcog" ] )
			SetDefaultWeapons_SoldierSniper( 		"mp_weapon_g2" )
			SetDefaultWeapons_SoldierAntiTitan( 	"mp_weapon_epg" )
			SetDefaultWeapons_SoldierPistol( 		"mp_weapon_semipistol" )
			SetDefaultWeapons_SoldierShotgun( 		"mp_weapon_shotgun_pistol" )

			SetDefaultWeapons_Stalker( 				"mp_weapon_lstar" )

			SetDefaultWeapons_ShieldCaptain( 		"mp_weapon_lmg", [				"aog"] )

			SetDefaultWeapons_Spectre( 				"mp_weapon_vinson", [ 			"hcog" ] )
			SetDefaultWeapons_SpectreAntiTitan( 	"mp_weapon_mgl" )
			SetDefaultWeapons_SpectrePistol( 		"mp_weapon_semipistol" )
			SetDefaultWeapons_SpectreRifle( 		"mp_weapon_vinson", [ 			"hcog" ] )
			SetDefaultWeapons_SpectreRifle( 		"mp_weapon_vinson", [ 			"threat_scope" ] )
			SetDefaultWeapons_SpectreShotgun( 		"mp_weapon_shotgun_pistol" )
			break

		case "sp_tday":
			SetDefaultWeapons_SoldierAntiTitan( 	"mp_weapon_smr" )
			SetDefaultWeapons_SoldierPistol( 		"mp_weapon_semipistol" )
			SetDefaultWeapons_SoldierRifle( 		"mp_weapon_rspn101", [ 			"hcog"] )
			SetDefaultWeapons_SoldierRifle( 		"mp_weapon_car", [ 				"holosight" ] )
			SetDefaultWeapons_SoldierShotgun( 		"mp_weapon_shotgun", [ 			"extended_ammo" ] )
			SetDefaultWeapons_SoldierSmg( 			"mp_weapon_r97", [ 				"extended_ammo"] )
			SetDefaultWeapons_SoldierSmg( 			"mp_weapon_alternator_smg", [ 	"hcog" ] )
			SetDefaultWeapons_SoldierSniper( 		"mp_weapon_sniper" )
			SetDefaultWeapons_Spectre( 				"mp_weapon_r97", [ 				"extended_ammo"] )
			SetDefaultWeapons_Stalker( 				"mp_weapon_lstar" )
			break

		case "sp_s2s":
			SetDefaultWeapons_SoldierPistol( 	"mp_weapon_wingman" )
			SetDefaultWeapons_SoldierRifle( 	"mp_weapon_hemlok",		[ 			"hcog" ] )
			SetDefaultWeapons_SoldierShotgun( 	"mp_weapon_mastiff" )
			SetDefaultWeapons_SoldierSmg( 		"mp_weapon_hemlok_smg", [ 			"threat_scope" ] )
			SetDefaultWeapons_SoldierSniper( 	"mp_weapon_doubletake", [ 			"ricochet" ] )
			SetDefaultWeapons_Stalker(			"mp_weapon_lstar" )

			SetDefaultWeapons_SpectrePistol( 	"mp_weapon_wingman" )
			SetDefaultWeapons_Spectre( 			"mp_weapon_hemlok", 	[ 			"hcog" ] )
			SetDefaultWeapons_SpectreRifle( 	"mp_weapon_hemlok", 	[ 			"hcog" ] )
			SetDefaultWeapons_SpectreShotgun( 	"mp_weapon_mastiff" )
			SetDefaultWeapons_SpectreSmg( 		"mp_weapon_hemlok_smg", [ 			"threat_scope" ] )
			SetDefaultWeapons_SpectreSniper( 	"mp_weapon_doubletake", [ 			"ricochet" ] )
			break

		case "sp_grunt_chatter_test":
			SetDefaultWeapons_SoldierAntiTitan( "mp_weapon_rocket_launcher" )
			SetDefaultWeapons_SoldierPistol( 	"mp_weapon_autopistol" )
			SetDefaultWeapons_SoldierRifle( 	"mp_weapon_hemlok", [ 				"aog" ] )
			SetDefaultWeapons_SoldierRifle( 	"mp_weapon_rspn101", [ 				"hcog" ] )
			SetDefaultWeapons_SoldierShotgun( 	"mp_weapon_mastiff" )
			SetDefaultWeapons_SoldierSmg( 		"mp_weapon_alternator_smg", [ 		"hcog" ] )
			SetDefaultWeapons_SoldierSmg( 		"mp_weapon_r97", [ 					"iron_sights" ] )
			SetDefaultWeapons_SoldierSmg( 		"mp_weapon_car", [ 					"holosight" ] )
			SetDefaultWeapons_Spectre( 			"mp_weapon_hemlok_smg", [ 			"aog" ] )
			SetDefaultWeapons_SoldierSniper( 	"mp_weapon_sniper" )
			SetDefaultWeapons_Spectre( 			"mp_weapon_hemlok_smg", [ 			"aog" ] )
			SetDefaultWeapons_Stalker( 			"mp_weapon_lstar" )
			break
		case "sp_hub_timeshift":
		case "sp_timeshift_spoke02":
			SetDefaultWeapons_SoldierAntiTitan( "mp_weapon_rocket_launcher" )
			SetDefaultWeapons_SoldierPistol( 	"mp_weapon_wingman" )
			SetDefaultWeapons_SoldierRifle( 	"mp_weapon_vinson", [ 				"hcog" ] )
			SetDefaultWeapons_SoldierLMG( 		"mp_weapon_mastiff" )
			SetDefaultWeapons_SoldierShotgun( 	"mp_weapon_shotgun" )
			SetDefaultWeapons_SoldierSmg( 		"mp_weapon_car", [ 					"holosight"] )
			SetDefaultWeapons_SoldierSmg( 		"mp_weapon_car" )
			SetDefaultWeapons_SoldierSniper( 	"mp_weapon_sniper" )
			SetDefaultWeapons_Stalker( 			"mp_weapon_mgl" )

			SetDefaultWeapons_Spectre( 			"mp_weapon_vinson", [ 				"hcog" ] )
			SetDefaultWeapons_SpectreAntiTitan( "mp_weapon_rocket_launcher" )
			SetDefaultWeapons_SpectrePistol( 	"mp_weapon_wingman" )
			SetDefaultWeapons_SpectreLMG( 		"mp_weapon_mastiff" )
			SetDefaultWeapons_SpectreShotgun( 	"mp_weapon_shotgun" )
			SetDefaultWeapons_SpectreSmg( 		"mp_weapon_car", [ 					"holosight"] )
			SetDefaultWeapons_SpectreSmg( 		"mp_weapon_car" )
			SetDefaultWeapons_SpectreSniper( 	"mp_weapon_sniper" )
			break
		case "sp_beacon":
		case "sp_beacon_spoke2":
		case "sp_beacon_spoke0":
			SetDefaultWeapons_SoldierAntiTitan( "mp_weapon_rocket_launcher" )
			SetDefaultWeapons_SoldierPistol( 	"mp_weapon_semipistol" )
			SetDefaultWeapons_SoldierRifle( 	"mp_weapon_hemlok", [ 				"hcog" ] )
			SetDefaultWeapons_SoldierRifle( 	"mp_weapon_hemlok", [ 				"threat_scope" ] )
			SetDefaultWeapons_SoldierSmg( 		"mp_weapon_hemlok_smg", [			"holosight"] )
			SetDefaultWeapons_SoldierSmg( 		"mp_weapon_hemlok_smg" )
			SetDefaultWeapons_SoldierSniper( 	"mp_weapon_sniper" )
			SetDefaultWeapons_Stalker( 			"mp_weapon_lstar" )

			SetDefaultWeapons_Spectre( 			"mp_weapon_hemlok", [				"hcog"] )
			SetDefaultWeapons_SpectreAntiTitan( "mp_weapon_rocket_launcher" )
			SetDefaultWeapons_SpectrePistol( 	"mp_weapon_semipistol" )
			SetDefaultWeapons_SpectreRifle( 	"mp_weapon_hemlok", [ 				"hcog" ] )
			SetDefaultWeapons_SpectreRifle( 	"mp_weapon_hemlok", [ 				"threat_scope" ] )
			SetDefaultWeapons_SpectreSmg( 		"mp_weapon_hemlok_smg", [			"holosight"] )
			SetDefaultWeapons_SpectreSmg( 		"mp_weapon_hemlok_smg" )
			SetDefaultWeapons_SpectreSniper( 	"mp_weapon_sniper" )
			break

		case "sp_skyway_v1":
			SetDefaultWeapons_SoldierAntiTitan( "mp_weapon_rocket_launcher" )
			SetDefaultWeapons_SoldierPistol( 	"mp_weapon_hemlok" )
			SetDefaultWeapons_SoldierRifle( 	"mp_weapon_hemlok", [ 				"hcog" ] )
			SetDefaultWeapons_SoldierLMG( 		"mp_weapon_hemlok" )
			SetDefaultWeapons_SoldierShotgun( 	"mp_weapon_hemlok" )
			SetDefaultWeapons_SoldierSmg( 		"mp_weapon_lmg" )
			SetDefaultWeapons_SoldierSniper( 	"mp_weapon_hemlok" )
			SetDefaultWeapons_Stalker( 			"mp_weapon_hemlok" )

			SetDefaultWeapons_Spectre( 			"mp_weapon_hemlok" )
			SetDefaultWeapons_SpectreAntiTitan( "mp_weapon_rocket_launcher" )
			SetDefaultWeapons_SpectrePistol( 	"mp_weapon_hemlok" )
			SetDefaultWeapons_SpectreRifle( 	"mp_weapon_hemlok", [ 				"hcog" ] )
			SetDefaultWeapons_SpectreLMG( 		"mp_weapon_lmg" )
			SetDefaultWeapons_SpectreShotgun( 	"mp_weapon_hemlok" )
			SetDefaultWeapons_SpectreSmg( 		"mp_weapon_hemlok" )
			SetDefaultWeapons_SpectreSniper( 	"mp_weapon_hemlok" )
			break

		default:
			SetDefaultWeapons_SoldierAntiTitan( "mp_weapon_rocket_launcher" )
			SetDefaultWeapons_SoldierPistol( 	"mp_weapon_semipistol" )
			SetDefaultWeapons_SoldierRifle( 	"mp_weapon_hemlok", [ 				"hcog" ] )
			SetDefaultWeapons_SoldierLMG( 		"mp_weapon_lmg" )
			SetDefaultWeapons_SoldierShotgun( 	"mp_weapon_shotgun" )
			SetDefaultWeapons_SoldierSmg( 		"mp_weapon_hemlok_smg" )
			SetDefaultWeapons_SoldierSniper( 	"mp_weapon_sniper" )
			SetDefaultWeapons_Stalker( 			"mp_weapon_lstar" )

			SetDefaultWeapons_Spectre( 			"mp_weapon_hemlok" )
			SetDefaultWeapons_SpectreAntiTitan( "mp_weapon_rocket_launcher" )
			SetDefaultWeapons_SpectrePistol( 	"mp_weapon_semipistol" )
			SetDefaultWeapons_SpectreRifle( 	"mp_weapon_hemlok", [ 				"hcog" ] )
			SetDefaultWeapons_SpectreLMG( 		"mp_weapon_esaw" )
			SetDefaultWeapons_SpectreShotgun( 	"mp_weapon_shotgun" )
			SetDefaultWeapons_SpectreSmg( 		"mp_weapon_hemlok_smg" )
			SetDefaultWeapons_SpectreSniper( 	"mp_weapon_sniper" )
			break
	}


	// store off the weapons and mods so they can be put on weapons elsewhere
	foreach ( classname, weaponTable in file.npcDefaultWeapons )
	{
		foreach ( autoName, weaponArray in weaponTable )
		{
			foreach ( weaponAndMods in weaponArray )
			{
				if ( !( weaponAndMods.wep in file.npcDefaultWeaponMods ) )
					file.npcDefaultWeaponMods[ weaponAndMods.wep ] <- []

				foreach ( mod in weaponAndMods.mods )
				{
					if ( !file.npcDefaultWeaponMods[ weaponAndMods.wep ].contains( mod ) )
						file.npcDefaultWeaponMods[ weaponAndMods.wep ].append( mod )
				}
			}
		}
	}

	AddCallback_OnPilotBecomesTitan( NotifyUI_ShowTitanLoadout )
	AddCallback_OnTitanBecomesPilot( NotifyUI_HideTitanLoadout )

	AddCallback_OnPlayerRespawned( LoadoutsSP_OnPlayerRespawned )
}

array<string> function GetWeaponModsForCurrentLevel( string weaponName )
{
	if ( !( weaponName in file.npcDefaultWeaponMods ) )
		return []

	return file.npcDefaultWeaponMods[ weaponName ]
}

void function NotifyUI_HideTitanLoadout( entity player, entity npc_titan )
{
	Remote_CallFunction_UI( player, "ServerCallback_UI_HideTitanLoadout" )
}

void function NotifyUI_ShowTitanLoadout( entity player, entity npc_titan )
{
	string weaponName = "mp_titanweapon_xo16_shorty" // default

	if ( IsValid( player.p.lastPrimaryWeaponEnt ) )
		weaponName = player.p.lastPrimaryWeaponEnt.GetWeaponClassName()

	Remote_CallFunction_UI( player, "ServerCallback_UI_ShowTitanLoadout" )
	Remote_CallFunction_UI( player, "ServerCallback_GetNewLoadout", SPWeapons_GetWeaponID( weaponName ), false )
}

void function SetDefaultWeapons_ShieldCaptain( string weapon, array<string> mods = [] )
{
	NPCDefaultWeapon weaponAndMods
	weaponAndMods.wep = weapon
	weaponAndMods.mods = mods

	string className = "npc_soldier"
	if ( !( "auto_weapon_shield_captain" in file.npcDefaultWeapons[ className ] ) )
		file.npcDefaultWeapons[ className ][ "auto_weapon_shield_captain" ]	<- []
	file.npcDefaultWeapons[ className ][ "auto_weapon_shield_captain" ].append( weaponAndMods )
}

void function SetDefaultWeapons_Spectre( string weapon, array<string> mods = [] )
{
	NPCDefaultWeapon weaponAndMods
	weaponAndMods.wep = weapon
	weaponAndMods.mods = mods

	string className = "npc_spectre"
	if ( !( "auto_weapon" in file.npcDefaultWeapons[ className ] ) )
		file.npcDefaultWeapons[ className ][ "auto_weapon" ]	<- []
	file.npcDefaultWeapons[ className ][ "auto_weapon" ].append( weaponAndMods )
}

void function SetDefaultWeapons_SpectreRifle( string weapon, array<string> mods = [] )
{
	NPCDefaultWeapon weaponAndMods
	weaponAndMods.wep = weapon
	weaponAndMods.mods = mods

	string className = "npc_spectre"
	if ( !( "auto_weapon_rifle" in file.npcDefaultWeapons[ className ] ) )
		file.npcDefaultWeapons[ className ][ "auto_weapon_rifle" ]	<- []
	file.npcDefaultWeapons[ className ][ "auto_weapon_rifle" ].append( weaponAndMods )

	if ( !( "auto_weapon" in file.npcDefaultWeapons[ className ] ) )
		file.npcDefaultWeapons[ className ][ "auto_weapon" ]	<- []
	file.npcDefaultWeapons[ className ][ "auto_weapon" ].append( weaponAndMods )
}

void function SetDefaultWeapons_SpectreLMG( string weapon, array<string> mods = [] )
{
	NPCDefaultWeapon weaponAndMods
	weaponAndMods.wep = weapon
	weaponAndMods.mods = mods

	string className = "npc_spectre"
	if ( !( "auto_weapon_lmg" in file.npcDefaultWeapons[ className ] ) )
		file.npcDefaultWeapons[ className ][ "auto_weapon_lmg" ]	<- []
	file.npcDefaultWeapons[ className ][ "auto_weapon_lmg" ].append( weaponAndMods )
}

void function SetDefaultWeapons_SpectrePistol( string weapon, array<string> mods = [] )
{
	NPCDefaultWeapon weaponAndMods
	weaponAndMods.wep = weapon
	weaponAndMods.mods = mods

	string className = "npc_spectre"
	if ( !( "auto_weapon_sidearm" in file.npcDefaultWeapons[ className ] ) )
		file.npcDefaultWeapons[ className ][ "auto_weapon_sidearm" ]	<- []
	file.npcDefaultWeapons[ className ][ "auto_weapon_sidearm" ].append( weaponAndMods )
}

void function SetDefaultWeapons_SpectreSmg( string weapon, array<string> mods = [] )
{
	NPCDefaultWeapon weaponAndMods
	weaponAndMods.wep = weapon
	weaponAndMods.mods = mods

	string className = "npc_spectre"
	if ( !( "auto_weapon_smg" in file.npcDefaultWeapons[ className ] ) )
		file.npcDefaultWeapons[ className ][ "auto_weapon_smg" ]	<- []
	file.npcDefaultWeapons[ className ][ "auto_weapon_smg" ].append( weaponAndMods )
}

void function SetDefaultWeapons_SpectreAntiTitan( string weapon, array<string> mods = [] )
{
	NPCDefaultWeapon weaponAndMods
	weaponAndMods.wep = weapon
	weaponAndMods.mods = mods

	string className = "npc_spectre"
	if ( !( "auto_weapon_antititan" in file.npcDefaultWeapons[ className ] ) )
		file.npcDefaultWeapons[ className ][ "auto_weapon_antititan" ]	<- []
	file.npcDefaultWeapons[ className ][ "auto_weapon_antititan" ].append( weaponAndMods )
}

void function SetDefaultWeapons_SpectreSniper( string weapon, array<string> mods = [] )
{
	NPCDefaultWeapon weaponAndMods
	weaponAndMods.wep = weapon
	weaponAndMods.mods = mods

	string className = "npc_spectre"
	if ( !( "auto_weapon_sniper" in file.npcDefaultWeapons[ className ] ) )
		file.npcDefaultWeapons[ className ][ "auto_weapon_sniper" ]	<- []
	file.npcDefaultWeapons[ className ][ "auto_weapon_sniper" ].append( weaponAndMods )
}

void function SetDefaultWeapons_SpectreShotgun( string weapon, array<string> mods = [] )
{
	NPCDefaultWeapon weaponAndMods
	weaponAndMods.wep = weapon
	weaponAndMods.mods = mods

	string className = "npc_spectre"
	if ( !( "auto_weapon_shotgun" in file.npcDefaultWeapons[ className ] ) )
		file.npcDefaultWeapons[ className ][ "auto_weapon_shotgun" ]	<- []
	file.npcDefaultWeapons[ className ][ "auto_weapon_shotgun" ].append( weaponAndMods )
}

void function SetDefaultWeapons_Stalker( string weapon, array<string> mods = [] )
{
	NPCDefaultWeapon weaponAndMods
	weaponAndMods.wep = weapon
	weaponAndMods.mods = mods

	string className = "npc_stalker"
	if ( !( "auto_weapon" in file.npcDefaultWeapons[ className ] ) )
		file.npcDefaultWeapons[ className ][ "auto_weapon" ]	<- []
	file.npcDefaultWeapons[ className ][ "auto_weapon" ].append( weaponAndMods )
}

void function SetDefaultWeapons_SoldierRifle( string weapon, array<string> mods = [] )
{
	NPCDefaultWeapon weaponAndMods
	weaponAndMods.wep = weapon
	weaponAndMods.mods = mods

	string className = "npc_soldier"
	if ( !( "auto_weapon_rifle" in file.npcDefaultWeapons[ className ] ) )
		file.npcDefaultWeapons[ className ][ "auto_weapon_rifle" ]	<- []
	file.npcDefaultWeapons[ className ][ "auto_weapon_rifle" ].append( weaponAndMods )

	if ( !( "auto_weapon" in file.npcDefaultWeapons[ className ] ) )
		file.npcDefaultWeapons[ className ][ "auto_weapon" ]	<- []
	file.npcDefaultWeapons[ className ][ "auto_weapon" ].append( weaponAndMods )
}

void function SetDefaultWeapons_SoldierLMG( string weapon, array<string> mods = [] )
{
	NPCDefaultWeapon weaponAndMods
	weaponAndMods.wep = weapon
	weaponAndMods.mods = mods

	string className = "npc_soldier"
	if ( !( "auto_weapon_lmg" in file.npcDefaultWeapons[ className ] ) )
		file.npcDefaultWeapons[ className ][ "auto_weapon_lmg" ]	<- []
	file.npcDefaultWeapons[ className ][ "auto_weapon_lmg" ].append( weaponAndMods )
}

void function SetDefaultWeapons_SoldierPistol( string weapon, array<string> mods = [] )
{
	NPCDefaultWeapon weaponAndMods
	weaponAndMods.wep = weapon
	weaponAndMods.mods = mods

	string className = "npc_soldier"
	if ( !( "auto_weapon_sidearm" in file.npcDefaultWeapons[ className ] ) )
		file.npcDefaultWeapons[ className ][ "auto_weapon_sidearm" ]	<- []
	file.npcDefaultWeapons[ className ][ "auto_weapon_sidearm" ].append( weaponAndMods )
}

void function SetDefaultWeapons_SoldierSmg( string weapon, array<string> mods = [] )
{
	NPCDefaultWeapon weaponAndMods
	weaponAndMods.wep = weapon
	weaponAndMods.mods = mods

	string className = "npc_soldier"
	if ( !( "auto_weapon_smg" in file.npcDefaultWeapons[ className ] ) )
		file.npcDefaultWeapons[ className ][ "auto_weapon_smg" ]	<- []
	file.npcDefaultWeapons[ className ][ "auto_weapon_smg" ].append( weaponAndMods )
}

void function SetDefaultWeapons_SoldierAntiTitan( string weapon, array<string> mods = [] )
{
	NPCDefaultWeapon weaponAndMods
	weaponAndMods.wep = weapon
	weaponAndMods.mods = mods

	string className = "npc_soldier"
	if ( !( "auto_weapon_antititan" in file.npcDefaultWeapons[ className ] ) )
		file.npcDefaultWeapons[ className ][ "auto_weapon_antititan" ]	<- []
	file.npcDefaultWeapons[ className ][ "auto_weapon_antititan" ].append( weaponAndMods )
}

void function SetDefaultWeapons_SoldierSniper( string weapon, array<string> mods = [] )
{
	NPCDefaultWeapon weaponAndMods
	weaponAndMods.wep = weapon
	weaponAndMods.mods = mods

	string className = "npc_soldier"
	if ( !( "auto_weapon_sniper" in file.npcDefaultWeapons[ className ] ) )
		file.npcDefaultWeapons[ className ][ "auto_weapon_sniper" ]	<- []
	file.npcDefaultWeapons[ className ][ "auto_weapon_sniper" ].append( weaponAndMods )
}

void function SetDefaultWeapons_SoldierShotgun( string weapon, array<string> mods = [] )
{
	NPCDefaultWeapon weaponAndMods
	weaponAndMods.wep = weapon
	weaponAndMods.mods = mods

	string className = "npc_soldier"
	if ( !( "auto_weapon_shotgun" in file.npcDefaultWeapons[ className ] ) )
		file.npcDefaultWeapons[ className ][ "auto_weapon_shotgun" ]	<- []
	file.npcDefaultWeapons[ className ][ "auto_weapon_shotgun" ].append( weaponAndMods )
}

void function SetDefaultWeapons_Specialist( string weapon, array<string> mods = [] )
{
	NPCDefaultWeapon weaponAndMods
	weaponAndMods.wep = weapon
	weaponAndMods.mods = mods

	string className = "npc_soldier"
	if ( !( "auto_weapon_specialist" in file.npcDefaultWeapons[ className ] ) )
		file.npcDefaultWeapons[ className ][ "auto_weapon_specialist" ]	<- []
	file.npcDefaultWeapons[ className ][ "auto_weapon_specialist" ].append( weaponAndMods )
}

NPCDefaultWeapon ornull function GetNPCDefaultWeaponForLevel( entity npc )
{
	string weapon
	string className = npc.GetClassName()
	if ( !( className in file.npcDefaultWeapons ) )
		return null

	string equipment = expect string( npc.kv.additionalequipment )

	if ( equipment in file.npcDefaultWeapons[ className ] )
		return file.npcDefaultWeapons[ className][ equipment ].getrandom()

	return null
}

array<string> function GetNPCDefaultWeapons()
{
	array<string> weapons

	foreach ( classWeapons in file.npcDefaultWeapons )
	{
		foreach ( classWeaponArray in classWeapons )
		{
			foreach ( classWeapon in classWeaponArray )
			{
				weapons.append( classWeapon.wep )
			}
		}
	}

	return weapons
}

PilotLoadoutDef function GetPilotLoadoutForCurrentMapSP()
{
	PilotLoadoutDef pilotLoadout

	pilotLoadout.name = GetMapName()
	pilotLoadout.setFile = DEFAULT_PILOT_SETTINGS
	pilotLoadout.melee   = "melee_pilot_emptyhanded"
	pilotLoadout.special = "mp_ability_cloak"

	switch ( GetMapName() )
	{
		case "sp_training":
			pilotLoadout.setFile				= "pilot_solo_training"
			pilotLoadout.primary 				= "mp_weapon_semipistol"
			pilotLoadout.primaryMods 			= [ "training_low_ammo_disable" ]
			pilotLoadout.special 				= ""

			break

		case "sp_crashsite": //Wilds
			pilotLoadout.setFile				= "civilian_solo"
			pilotLoadout.primary 				= "mp_weapon_vinson"
			pilotLoadout.primaryMods 			= [ "hcog" ]
			pilotLoadout.secondary 				= "mp_weapon_semipistol"
			pilotLoadout.melee					= "melee_pilot_emptyhanded"
			pilotLoadout.ordnance 				= "mp_weapon_frag_grenade"
			pilotLoadout.special 				= ""
			break

		case "sp_sewers1": // Reclamation
			pilotLoadout.primary 				= "mp_weapon_r97"
			pilotLoadout.secondary 				= "mp_weapon_autopistol"
			pilotLoadout.ordnance 				= "mp_weapon_frag_grenade"
			pilotLoadout.special 				= "mp_ability_cloak"
			break

		case "sp_boomtown":
			switch ( GetStartPoint() )
			{
				default:
					pilotLoadout.primary 				= "mp_weapon_vinson"
					pilotLoadout.primaryMods 			= [ "hcog" ]
					pilotLoadout.secondary 				= "mp_weapon_shotgun_pistol"
					pilotLoadout.special 				= "mp_ability_cloak"
					pilotLoadout.ordnance 				= "mp_weapon_frag_grenade"
					break
			}

			break

		case "sp_boomtown_start":
		case "sp_boomtown_end":
			pilotLoadout.primary 				= "mp_weapon_vinson"
			pilotLoadout.primaryMods 			= [ "hcog" ]
			pilotLoadout.secondary 				= "mp_weapon_shotgun_pistol"
			pilotLoadout.special 				= "mp_ability_cloak"
			pilotLoadout.ordnance 				= "mp_weapon_frag_grenade"
			break

		case "sp_hub_timeshift":
		case "sp_timeshift_spoke02":
			pilotLoadout.primary 				= "mp_weapon_car"
			pilotLoadout.primaryMods 			= [ "holosight" ]
			pilotLoadout.secondary 				= "mp_weapon_semipistol"
			pilotLoadout.ordnance 				= "mp_weapon_frag_grenade"
			pilotLoadout.special 				= "mp_ability_cloak"
			break

		case "sp_beacon":
		case "sp_beacon_spoke0":
		case "sp_beacon_spoke2":
			pilotLoadout.primary 				= "mp_weapon_hemlok"
			pilotLoadout.primaryMods 			= [ "hcog" ]
			pilotLoadout.secondary 				= "mp_weapon_mgl"
			pilotLoadout.ordnance 				= "mp_weapon_thermite_grenade"
			pilotLoadout.special 				= "mp_ability_cloak"
			break

		case "sp_tday":
			pilotLoadout.primary 				= "mp_weapon_rspn101"
			pilotLoadout.secondary 				= "mp_weapon_smr"
			pilotLoadout.ordnance 				= "mp_weapon_grenade_emp"
			pilotLoadout.special 				= "mp_ability_cloak"
			break

		case "sp_ship_01":
		case "sp_ship_02":
		case "sp_ship_03":
		case "sp_ship_04":
		case "sp_ship_05":
		case "sp_s2s":
			pilotLoadout.ordnance 				= "mp_weapon_frag_grenade"
			pilotLoadout.special 				= "mp_ability_cloak"
			//primary weapons reset for better gameplay

			/*pilotLoadout.primary 				= "mp_weapon_lmg"
			pilotLoadout.primaryMods 			= [ "holosight" ]
			pilotLoadout.secondary 				= "mp_weapon_doubletake"
			pilotLoadout.secondaryMods 			= [ "ricochet" ]*/

			pilotLoadout.primary 				= "mp_weapon_rocket_launcher"
			pilotLoadout.primaryMods 			= [ "sp_s2s_settings" ]
			pilotLoadout.secondary 				= "mp_weapon_lmg"
			pilotLoadout.secondaryMods 			= [ "holosight" ]

			break

		case "sp_skyway_v1":
			switch ( GetStartPoint() )
			{
				case "Level Start":
				case "Torture Room B":
				case "Smart Pistol Run":
				case "Bridge Fight":
				case "BT Reunion":
					pilotLoadout.primary 				= "mp_weapon_smart_pistol_og"
					break
				default:
					pilotLoadout.primary 				= "mp_weapon_smart_pistol"
					break
			}
			pilotLoadout.primaryMods 			= [ "og_pilot" ]
			pilotLoadout.secondary 				= ""
			//pilotLoadout.melee					= "melee_pilot_sword"
			pilotLoadout.ordnance 				= ""
			pilotLoadout.special 				= ""
			break

// Test Maps

		case "sp_ab_melee_takedown":
			pilotLoadout.primary 				= "mp_weapon_rspn101"
			pilotLoadout.melee					= "melee_pilot_sword"
			pilotLoadout.meleeMods				= [ "SlowMo" ]
			pilotLoadout.ordnance 				= "mp_weapon_frag_grenade"
			break

		case "sp_skyway": //Test Map
			pilotLoadout.primary 				= "mp_weapon_smart_pistol"
			pilotLoadout.melee					= "melee_pilot_sword"
			pilotLoadout.ordnance 				= "mp_weapon_frag_grenade"
			break

		case "sp_enemies":
			pilotLoadout.primary 				= "mp_weapon_rspn101"
			pilotLoadout.primaryMods 			= [ "hcog" ]
			pilotLoadout.secondary 				= "mp_weapon_smr"
			pilotLoadout.ordnance 				= "mp_weapon_frag_grenade"
			break

		case "sp_grunt_chatter_test":
			pilotLoadout.primary 				= "mp_weapon_rspn101"
			pilotLoadout.primaryMods 			= [ "hcog" ]
			pilotLoadout.secondary 				= "mp_weapon_autopistol"
			pilotLoadout.special 				= "mp_ability_cloak"
			pilotLoadout.ordnance 				= "mp_weapon_thermite_grenade"
			break

		case "sp_grunt_battle":
			pilotLoadout.primary 				= "mp_weapon_rspn101"
			pilotLoadout.primaryMods 			= [ "hcog" ]
			pilotLoadout.secondary 				= "mp_weapon_semipistol"
//			pilotLoadout.special 				= "mp_ability_heal"
			pilotLoadout.special 				= "mp_ability_cloak"
			pilotLoadout.ordnance 				= "mp_weapon_frag_grenade"
			break

		default:
			pilotLoadout.primary 				= "mp_weapon_rspn101"
			pilotLoadout.primaryMods 			= [ "hcog" ]
			pilotLoadout.secondary 				= "mp_weapon_smr"
			pilotLoadout.special 				= "mp_ability_cloak"
			pilotLoadout.ordnance 				= "mp_weapon_grenade_emp"
			break

	}

	return pilotLoadout
}

struct TitanLevelLoadoutDefaults
{
	string setFile = "titan_buddy"
	string primaryWeaponName
	array<string> unlockedWeaponNames
	string titanExecution
}

TitanLevelLoadoutDefaults function GetTitanLevelLoadoutDefaultsForMapname( string mapName )
{
	TitanLevelLoadoutDefaults result

	// All loadouts:
	result.unlockedWeaponNames		= ["mp_titanweapon_xo16_shorty", "mp_titanweapon_sticky_40mm", "mp_titanweapon_meteor", "mp_titanweapon_leadwall", "mp_titanweapon_rocketeer_rocketstream", "mp_titanweapon_particle_accelerator", "mp_titanweapon_sniper", "mp_titanweapon_predator_cannon" ]

	switch ( mapName )
	{
		case "sp_training":
		case "sp_crashsite": // Wilds
		case "sp_wilds_anim_test":
			result.primaryWeaponName		= "mp_titanweapon_xo16_shorty"
			result.unlockedWeaponNames		= ["mp_titanweapon_xo16_shorty" ]
			break

		case "sp_sewers1": // Reclamation
			result.primaryWeaponName		= "mp_titanweapon_xo16_shorty"
			result.unlockedWeaponNames		= ["mp_titanweapon_xo16_shorty" ]
			result.titanExecution           = "execution_bt_kickshoot"
			break

		case "sp_boomtown_start":
			result.primaryWeaponName		= "mp_titanweapon_sticky_40mm"
			result.unlockedWeaponNames		= ["mp_titanweapon_xo16_shorty", "mp_titanweapon_sticky_40mm", ]
			break

		case "sp_boomtown":
			result.primaryWeaponName		= "mp_titanweapon_sticky_40mm"
			result.unlockedWeaponNames		= ["mp_titanweapon_xo16_shorty", "mp_titanweapon_sticky_40mm", "mp_titanweapon_meteor", "mp_titanweapon_rocketeer_rocketstream" ]
			break

		case "sp_boomtown_end":
			result.primaryWeaponName		= "mp_titanweapon_sticky_40mm"
			result.unlockedWeaponNames		= ["mp_titanweapon_xo16_shorty", "mp_titanweapon_sticky_40mm", "mp_titanweapon_meteor", "mp_titanweapon_rocketeer_rocketstream" ]
			result.titanExecution           = "execution_bt_pilotrip"
			break

		case "sp_hub_timeshift":
		case "sp_timeshift_spoke02":
			result.primaryWeaponName		= "mp_titanweapon_sticky_40mm"
			result.unlockedWeaponNames		= ["mp_titanweapon_xo16_shorty", "mp_titanweapon_sticky_40mm", "mp_titanweapon_meteor", "mp_titanweapon_rocketeer_rocketstream" ]
			break

		case "sp_beacon":
		case "sp_beacon_spoke0":
		case "sp_beacon_spoke2":
			result.primaryWeaponName		= "mp_titanweapon_particle_accelerator"
			result.unlockedWeaponNames		= ["mp_titanweapon_xo16_shorty", "mp_titanweapon_sticky_40mm", "mp_titanweapon_meteor", "mp_titanweapon_rocketeer_rocketstream", "mp_titanweapon_particle_accelerator" ]
			result.titanExecution           = "execution_bt_flip"
			break

		case "sp_tday":
			result.primaryWeaponName 		= "mp_titanweapon_xo16_shorty"
			result.unlockedWeaponNames		= ["mp_titanweapon_xo16_shorty", "mp_titanweapon_sticky_40mm", "mp_titanweapon_meteor", "mp_titanweapon_leadwall", "mp_titanweapon_rocketeer_rocketstream", "mp_titanweapon_particle_accelerator" ]
			break

		case "sp_s2s":
			result.primaryWeaponName 		= "mp_titanweapon_sticky_40mm"
			result.unlockedWeaponNames		= ["mp_titanweapon_xo16_shorty", "mp_titanweapon_sticky_40mm", "mp_titanweapon_meteor", "mp_titanweapon_leadwall", "mp_titanweapon_rocketeer_rocketstream", "mp_titanweapon_particle_accelerator", "mp_titanweapon_sniper" ]
			break

		case "sp_skyway_v1":
			result.setFile 					= "titan_buddy_spare"
			result.primaryWeaponName		= "mp_titanweapon_predator_cannon"
			result.unlockedWeaponNames		= ["mp_titanweapon_xo16_shorty", "mp_titanweapon_sticky_40mm", "mp_titanweapon_meteor", "mp_titanweapon_leadwall", "mp_titanweapon_rocketeer_rocketstream", "mp_titanweapon_particle_accelerator", "mp_titanweapon_sniper", "mp_titanweapon_predator_cannon" ]
			result.titanExecution           = "execution_bt_kickshoot"
			break

		default:
			result.primaryWeaponName		= "mp_titanweapon_rocketeer_rocketstream"
			result.titanExecution           = "execution_bt_flip"
			// All loadouts unlocked.
	}

	return result
}

TitanLoadoutDef function GetTitanLoadoutForCurrentMap()
{
	string mapName = GetMapName()

	TitanLoadoutDef result
	result = GetAllowedTitanLoadouts().getrandom()
	result.setFile = "titan_buddy"

	TitanLevelLoadoutDefaults levelDef = GetTitanLevelLoadoutDefaultsForMapname( mapName )
	Assert( GetTitanLoadoutForPrimary( levelDef.primaryWeaponName ) != null, "Level loadout tried to specify '" + levelDef.primaryWeaponName + "' for BT, but that weapon is not in titan_properties.csv" )

	int bitIndex = GetTitanLoadoutIndex( levelDef.primaryWeaponName )

	// fall back to xo16 if not unlocked yet
	if ( !IsBTLoadoutUnlocked( bitIndex ) )
		levelDef.primaryWeaponName = "mp_titanweapon_xo16_shorty"

	result = expect TitanLoadoutDef( GetTitanLoadoutForPrimary( levelDef.primaryWeaponName ) )
	result.setFile = levelDef.setFile
	result.name = mapName
	result.titanExecution = levelDef.titanExecution

	PopulateTitanLoadoutFromLevelTrans( result )
	return result
}

void function PopulatePilotLoadoutFromLevelTrans( PilotLoadoutDef pilotLoadout )
{
	LevelTransitionStruct ornull trans = GetLevelTransitionStruct()

	if ( trans == null )
		return

	expect LevelTransitionStruct( trans )

	if ( trans.pilot_mainWeapons[0] >= 0 )
	{
		string primary = SPWeapons_GetWeaponFromID( trans.pilot_mainWeapons[0] )
		if ( primary != "" && WeaponIsPrecached( primary ) )
		{
			pilotLoadout.primary = primary
			pilotLoadout.primaryMods 			= []
			pilotLoadout.primaryModsBitfield	= trans.pilot_weaponMods[0]
		}
	}
	if ( trans.pilot_mainWeapons[1] >= 0 )
	{
		string secondary = SPWeapons_GetWeaponFromID( trans.pilot_mainWeapons[1] )
		if ( secondary != "" && WeaponIsPrecached( secondary ) )
		{
			pilotLoadout.secondary = secondary
			pilotLoadout.secondaryMods 			= []
			pilotLoadout.secondaryModsBitfield	= trans.pilot_weaponMods[1]
		}
	}

	if ( trans.pilot_offhandWeapons[0] >= 0 )
	{
		string ordnance = SPWeapons_GetWeaponFromID( trans.pilot_offhandWeapons[0] )
		if ( ordnance != "" && WeaponIsPrecached( ordnance ) )
		{
			pilotLoadout.ordnance =  ordnance
			pilotLoadout.ordnanceAmmo = trans.pilot_ordnanceAmmo
		}
	}

	if ( trans.pilot_offhandWeapons[1] >= 0 )
	{
		string special = SPWeapons_GetWeaponFromID( trans.pilot_offhandWeapons[1] )
		if ( special != "" && WeaponIsPrecached( special ) )
			pilotLoadout.special =  special
	}
}

void function PopulateTitanLoadoutFromLevelTrans( TitanLoadoutDef titanLoadout )
{
	LevelTransitionStruct ornull trans = GetLevelTransitionStruct()

	if ( trans == null )
		return

	expect LevelTransitionStruct( trans )

	if ( trans.titan_mainWeapon >= 0 )
	{
		string primary = SPWeapons_GetWeaponFromID( trans.titan_mainWeapon )
		TitanLoadoutDef ornull newLoadout = GetTitanLoadoutForPrimary( primary )

		if ( newLoadout == null )
			return

		expect TitanLoadoutDef( newLoadout )
		titanLoadout.primary = newLoadout.primary
		titanLoadout.ordnance = newLoadout.ordnance
		titanLoadout.special = newLoadout.special
		titanLoadout.antirodeo = newLoadout.antirodeo
		titanLoadout.coreAbility = newLoadout.coreAbility
		titanLoadout.melee = newLoadout.melee
	}
}

void function PopulateLevelTransWithLoadouts( entity player, LevelTransitionStruct trans )
{
	if ( !IsAlive( player ) )
		return

	array<string> mainWeapons = []
	if ( player.IsTitan() )
	{
		int i = 0
		foreach ( storedWeapon in player.p.storedWeapons )
		{
			if ( storedWeapon.weaponType == eStoredWeaponType.main )
			{
				mainWeapons.append( storedWeapon.name )
				trans.pilot_weaponMods[i] = storedWeapon.modBitfield
				i++
			}
		}
	}
	else
	{
		if ( PlayerHasBattery( player ) )
			trans.pilotHasBattery = true

		array<entity> weapons = player.GetMainWeapons()
		for ( int i=0; i<weapons.len() && i<trans.pilot_mainWeapons.len(); i++ )
		{
			mainWeapons.append( weapons[i].GetWeaponClassName() )
			trans.pilot_weaponMods[i] = weapons[i].GetModBitField()
		}
	}

	for ( int i=0; i<trans.pilot_mainWeapons.len(); i++ )
	{
		if ( i < mainWeapons.len() )
		{
			string weapon = mainWeapons[i]
			trans.pilot_mainWeapons[i] = SPWeapons_GetWeaponID( weapon )
		}
		else
		{
			trans.pilot_mainWeapons[i] = -1
		}
	}

	// switch loadout spots
	if ( mainWeapons.len() > 1 && player.GetActiveWeapon() != null && mainWeapons[1] == player.GetActiveWeapon().GetWeaponClassName() )
	{
		int tempVar1 = trans.pilot_mainWeapons[1]
		int ornull tempVar2 = trans.pilot_weaponMods[1]
		trans.pilot_mainWeapons[1] = trans.pilot_mainWeapons[0]
		trans.pilot_weaponMods[1] = trans.pilot_weaponMods[0]
		trans.pilot_mainWeapons[0] = tempVar1
		trans.pilot_weaponMods[0] = tempVar2
	}

	array<string> offhandWeapons = [ "", "" ]
	if ( player.IsTitan() )
	{
		foreach ( storedWeapon in player.p.storedWeapons )
		{
			if ( storedWeapon.weaponType == eStoredWeaponType.offhand && storedWeapon.inventoryIndex < trans.pilot_offhandWeapons.len() )
			{
				offhandWeapons[storedWeapon.inventoryIndex] = storedWeapon.name
			}
		}
	}
	else
	{
		for ( int i=0; i<trans.pilot_offhandWeapons.len(); i++ )
		{
			entity weapon = player.GetOffhandWeapon( i )
			if ( weapon != null )
			{
				offhandWeapons[i] = weapon.GetWeaponClassName()
				if ( i == 0 )
					trans.pilot_ordnanceAmmo = weapon.GetWeaponPrimaryClipCount()
			}
		}
	}

	for ( int i=0; i<trans.pilot_offhandWeapons.len(); i++ )
	{
		if ( i < offhandWeapons.len() && offhandWeapons[i] != "" )
		{
			string weapon = offhandWeapons[i]
			trans.pilot_offhandWeapons[i] = SPWeapons_GetWeaponID( weapon )
		}
		else
		{
			trans.pilot_offhandWeapons[i] = -1
		}
	}

	entity titan = GetTitanFromPlayer( player )
	if ( titan != null )
	{
		if ( titan.GetActiveWeapon() != null )
			trans.titan_mainWeapon = SPWeapons_GetWeaponID( titan.GetActiveWeapon().GetWeaponClassName() )
	}
	else
	{
		TitanLoadoutDef loadout = GetTitanLoadoutForCurrentMap()
		trans.titan_mainWeapon = SPWeapons_GetWeaponID( loadout.primary )
	}
}

///////////
void function UI_NotifySPTitanLoadoutChange( entity player )
{
	if ( !player.IsTitan() )
		return

	if ( !IsValid( player.p.lastPrimaryWeaponEnt ) )
		return

	int loadoutIndex = GetSPTitanLoadoutIndexForWeapon( player.p.lastPrimaryWeaponEnt.GetWeaponClassName() )
	Remote_CallFunction_UI( player, "ServerCallback_ActiveSPTitanLoadout", loadoutIndex )
	Remote_CallFunction_NonReplay( player, "ServerCallback_ActiveSPTitanLoadout", loadoutIndex )
}

void function SPTitanLoadout_SetupForLevelStart()
{
	// Coming from prev level:
	LevelTransitionStruct ornull trans = GetLevelTransitionStruct()
	if ( trans != null )
	{
		expect LevelTransitionStruct( trans )
		if ( trans.titan_unlocksBitfield != 0 )
			SetBTLoadoutsUnlockedBitfield( trans.titan_unlocksBitfield )

		return
	}

	// Starting on map:
	string mapName = GetMapName()
	TitanLevelLoadoutDefaults levelDef = GetTitanLevelLoadoutDefaultsForMapname( mapName )
	foreach ( weaponName in levelDef.unlockedWeaponNames )
	{
		int loadoutIndex = GetSPTitanLoadoutIndexForWeapon( weaponName )
		SetBTLoadoutUnlocked( loadoutIndex )
	}
}

void function LoadoutsSP_OnPlayerRespawned( entity player )
{
	if ( !player.IsTitan() )
		NotifyUI_HideTitanLoadout( player, null )
}

bool function ClientCommand_bt_loadout_select( entity player, array<string> args )
{
	Assert( args.len() > 0 )
	if ( args.len() < 1 )
		return true

	int loadoutIndex = args[0].tointeger()
	if ( !IsBTLoadoutUnlocked( loadoutIndex ) )
	{
		CodeWarning( "Player does not have loadout #" + loadoutIndex + " unlocked." )
		return true
	}

	if ( !player.IsTitan() )
	{
		CodeWarning( "Player is not a titan." )
		return true
	}

	if ( TitanCoreInUse( player ) )
	{
		CodeWarning( "Titan core in use, aborting loadout switch." )
		return true
	}

	string newWeaponName = GetSPTitanLoadoutForIndex_PrimaryWeapon( loadoutIndex )
	array<entity> oldWeapons = player.GetMainWeapons()
	foreach ( oldWeapon in oldWeapons )
	{
		if ( oldWeapon.GetWeaponClassName() == newWeaponName )
		{
			CodeWarning( "Player already has weapon '" + newWeaponName + "' in inventory." )
			return true
		}
	}

	foreach ( oldWeapon in oldWeapons )
	{
		player.TakeWeaponNow( oldWeapon.GetWeaponClassName() )
	}

	SetConVarInt( "sp_titanLoadoutCurrent", loadoutIndex )
	player.p.lastSelectSPTitanLoadoutTime = Time()

	player.GiveWeapon( newWeaponName )
	EmitSoundOnEntity( player, "bt_weapon_draw" )
	StatusEffect_AddTimed( player, eStatusEffect.stim_visual_effect, 0.75, 0.4, 0.4 )
	CreateShakeRumbleOnly( player.GetOrigin(), 10, 150, 1.0 )

	return true
}

bool function ClientCommand_bt_loadout_mark_selected( entity player, array<string> args )
{
	Assert( args.len() > 0 )
	if ( args.len() < 1 )
		return true

	int loadoutIndex = args[0].tointeger()
	SetSPTitanLoadoutHasEverBeenSelected( loadoutIndex )

	return true
}

void function SPTitanLoadout_RemoveOwnedLoadoutPickupsInLevel( array<string> weaponNames )
{
	// The titan weapon pickups are not real weapon pickups. They are an info_target and a weapon model using a script trigger.
	// We need to find and delete both the info_target and the weapon model.
	array<entity> entsToDelete = []
	array<entity> potentialWeapons = GetEntArrayByClass_Expensive( "info_target" )

	array<asset> weaponModels
	foreach( weaponName in weaponNames )
	{
		asset weaponModel = GetWeaponInfoFileKeyFieldAsset_Global( weaponName, "playermodel" )
		weaponModels.append( weaponModel )
	}

	foreach( ent in potentialWeapons )
	{
		asset model = ent.GetModelName()
		foreach( weaponModel in weaponModels )
		{
			if ( model == weaponModel )
			{
				entsToDelete.append( ent )
				continue
			}
		}
	}

	foreach( ent in entsToDelete )
	{
		foreach( attachedEnt in ent.e.attachedEnts )  // The weapon model is an attachedEnt to the info_target
		{
			if ( IsValid ( attachedEnt ) )
				attachedEnt.Destroy()
		}

		if ( IsValid( ent ) )
			ent.Destroy()
	}
}


void function CodeCallback_WeaponLoadoutPickup( entity player, entity weapon )
{
  	// This needs threaded. Otherwise, the first weapon delete kills the thread and it don't delete them all as intended.
	thread SPTitanLoadout_UnlockLoadoutWithCeremony( player, weapon.GetWeaponClassName() )
}


void function SPTitanLoadout_SpawnAtCrosshairDEV( int loadoutIndex )
{
	if ( loadoutIndex < 0 )
	{
		for ( int idx = 0; idx < GetSPTitanLoadoutMax(); idx++ )
		{
			if ( !IsBTLoadoutUnlocked( idx ) )
			{
				loadoutIndex = idx
				break
			}
		}

		if ( loadoutIndex < 0 )
			return
	}

	string weaponName = GetSPTitanLoadoutForIndex_PrimaryWeapon( loadoutIndex )
	thread DEV_SpawnWeaponAtCrosshair( weaponName )
}

table<int,float> function GetWeaponCooldownsForTitanLoadoutSwitch( entity player )
{
	Assert( player.IsTitan() )

	entity coreWeapon = player.GetOffhandWeapon( OFFHAND_EQUIPMENT )
	entity meleeWeapon = player.GetMeleeWeapon()
	array<entity> offhandWeapons = player.GetOffhandWeapons()

	table<int,float> cooldowns = {}
	cooldowns[ OFFHAND_ORDNANCE ] <- 0.0
	cooldowns[ OFFHAND_SPECIAL ] <- 0.0
	cooldowns[ OFFHAND_ANTIRODEO ] <- 0.0

	foreach ( slot,severity in cooldowns )
	{
		entity offhand = player.GetOffhandWeapon( slot )

		if ( !IsValid( offhand ) )
			continue
		if ( offhand == meleeWeapon )
			continue
		if ( offhand == coreWeapon )
			continue

		switch( offhand.GetWeaponClassName() )
		{
			// Next attack time (burst fire):
			case "mp_titanweapon_salvo_rockets":
			{
				float cooldownTime = offhand.GetWeaponSettingFloat( eWeaponVar.burst_fire_delay )
				float nextAttackTime = offhand.GetNextAttackAllowedTime()
				float NAT = nextAttackTime - Time()

				if ( NAT >= 0 )
					cooldowns[slot] = NAT/cooldownTime
			}
			break


			// Set charge to 100%:
			case "mp_titanweapon_vortex_shield":
			case "mp_titanweapon_heat_shield":
			case "mp_titanweapon_shoulder_rockets":
			{
				cooldowns[slot] = 1.0 - offhand.GetWeaponChargeFraction()
			}
			break

			// Set clip ammo to 0:
			case "mp_titanability_smoke":
			case "mp_titanability_tether_trap":
			case "mp_titanability_phase_dash":
			case "mp_titanability_hover":
			case "mp_titanability_sonar_pulse":
			case "mp_titanability_particle_wall":
			case "mp_titanability_gun_shield":
			case "mp_titanweapon_flame_wall":
			case "mp_titanability_slow_trap":
			case "mp_titanweapon_arc_wave":
			case "mp_titanweapon_dumbfire_rockets":
			case "mp_titanability_power_shot":
			{
				if ( offhand.IsWeaponRegenDraining() )
				{
					cooldowns[slot] = 0.0
				}
				else
				{
					int maxClipAmmo = offhand.GetWeaponPrimaryClipCountMax()
					int currentAmmo = offhand.GetWeaponPrimaryClipCount()
					cooldowns[slot] = (float( currentAmmo ) / float( maxClipAmmo ))
				}
			}
			break

			// Do nothing:
			case "mp_titanweapon_laser_lite":		// shared energy
			case "mp_titanability_laser_trip":		// shared energy
			case "mp_titanweapon_vortex_shield_ion":// shared energy
			{
				cooldowns[slot] = float( player.GetSharedEnergyCount() ) / float( player.GetSharedEnergyTotal() )
			}
			break

			case "mp_titanability_basic_block":
			case "mp_titanweapon_tracker_rockets":
			case "mp_titanability_ammo_swap":
			{
				cooldowns[slot] = 1.0
			}
			break

			default:
			{
				CodeWarning( offhand.GetWeaponClassName() + " - not handled in GetWeaponCooldownsForTitanLoadoutSwitch()." )
			}
		}

		string weaponName = offhand.GetWeaponClassName()
		WeaponCooldownData data
		data.timeStored = Time()
		data.severity = cooldowns[slot]

		if ( !( weaponName in file.cooldownData ) )
			file.cooldownData[ weaponName ] <- data
		else
			file.cooldownData[ weaponName ] = data

		printt( "GET: " + slot + " " + offhand.GetWeaponClassName() + " - " + cooldowns[slot] )
	}

	return cooldowns
}

void function SetWeaponCooldownsForTitanLoadoutSwitch( entity player, table<int,float> cooldowns )
{
	Assert( player.IsTitan() )

/*
	array<entity> weapons = GetPrimaryWeapons( player )
	foreach ( weapon in weapons )
	{
		if ( weapon.GetWeaponPrimaryClipCountMax() > 0 )
			weapon.SetWeaponPrimaryClipCount( 0 )
	}
*/

	entity coreWeapon = player.GetOffhandWeapon( OFFHAND_EQUIPMENT )
	entity meleeWeapon = player.GetMeleeWeapon()
	array<entity> offhandWeapons = player.GetOffhandWeapons()

	// 1 is fully available, 0 is used up

	float highestSeverity = 1.0

	foreach ( slot,severity in cooldowns )
	{
		entity offhand = player.GetOffhandWeapon( slot )

		if ( !IsValid( offhand ) )
			continue

		string offhandName = offhand.GetWeaponClassName()

		if ( offhandName in file.cooldownData )
		{
			float savedSeverity = CalculateCurrentWeaponCooldownFromStoredTime( player, offhand, file.cooldownData[ offhandName ] )
			severity = min( savedSeverity, severity )
		}

		highestSeverity = min( severity, highestSeverity )

		if ( offhand == meleeWeapon )
			continue
		if ( offhand == coreWeapon )
			continue

		printt( "SET: " + slot + " " + offhand.GetWeaponClassName() + " - " + severity )

		switch( offhandName )
		{
			// Next attack time (burst fire):
			case "mp_titanweapon_salvo_rockets":
			{
				float cooldownTime = offhand.GetWeaponSettingFloat( eWeaponVar.burst_fire_delay )
				offhand.SetNextAttackAllowedTime( Time() + (cooldownTime * severity) )
			}
			break

			// Set charge to 100%:
			case "mp_titanweapon_vortex_shield":
			case "mp_titanweapon_heat_shield":
			case "mp_titanweapon_shoulder_rockets":
			{
				offhand.SetWeaponChargeFractionForced( 1.0 - severity )
			}
			break

			// Set clip ammo to 0:
			case "mp_titanability_smoke":
			case "mp_titanability_tether_trap":
			case "mp_titanability_phase_dash":
			case "mp_titanability_hover":
			case "mp_titanability_sonar_pulse":
			case "mp_titanability_gun_shield":
			case "mp_titanability_particle_wall":
			case "mp_titanweapon_flame_wall":
			case "mp_titanability_slow_trap":
			case "mp_titanweapon_arc_wave":
			case "mp_titanweapon_dumbfire_rockets":
			case "mp_titanability_power_shot":
			{
				int maxClipAmmo = offhand.GetWeaponPrimaryClipCountMax()
				offhand.SetWeaponPrimaryClipCountAbsolute( maxClipAmmo * severity )
			}
			break

			// Do nothing:
			case "mp_titanability_basic_block":
			case "mp_titanweapon_tracker_rockets":
			case "mp_titanability_ammo_swap":
			case "mp_titanweapon_laser_lite":		// shared energy
			case "mp_titanability_laser_trip":		// shared energy
			case "mp_titanweapon_vortex_shield_ion":// shared energy
			{
			}
			break

			default:
			{
				CodeWarning( offhand.GetWeaponClassName() + " - not handled in SetWeaponCooldownsForTitanLoadoutSwitch()." )
			}
		}
	}

	printt( "highestSeverity: " + highestSeverity )
	int energy = player.GetSharedEnergyCount()
	int totalEnergy = player.GetSharedEnergyTotal()
	int idealEnergy = int( player.GetSharedEnergyTotal() * highestSeverity )
	if ( energy < idealEnergy )
		player.AddSharedEnergy( idealEnergy - energy )
	else
		player.TakeSharedEnergy( energy - idealEnergy )
}

float function CalculateCurrentWeaponCooldownFromStoredTime( entity player, entity offhand, WeaponCooldownData data )
{
	// if ( Time() - data.timeStored < 30.0 )
	// 	return data.severity

	// return 1.0

	float cooldownTime = 10.0
	switch( offhand.GetWeaponClassName() )
	{
		// Next attack time (burst fire):
		case "mp_titanweapon_salvo_rockets":
		{
			cooldownTime = offhand.GetWeaponSettingFloat( eWeaponVar.burst_fire_delay )
		}
		break

		// Set charge to 100%:
		case "mp_titanweapon_vortex_shield":
		case "mp_titanweapon_heat_shield":
		case "mp_titanweapon_shoulder_rockets":
		{
			cooldownTime = offhand.GetWeaponSettingFloat( eWeaponVar.charge_cooldown_time ) + offhand.GetWeaponSettingFloat( eWeaponVar.charge_cooldown_delay )
		}
		break

		// Set clip ammo to 0:
		case "mp_titanability_smoke":
		case "mp_titanability_tether_trap":
		case "mp_titanability_phase_dash":
		case "mp_titanability_hover":
		case "mp_titanability_sonar_pulse":
		case "mp_titanability_particle_wall":
		case "mp_titanability_gun_shield":
		case "mp_titanweapon_flame_wall":
		case "mp_titanability_slow_trap":
		case "mp_titanweapon_arc_wave":
		case "mp_titanweapon_dumbfire_rockets":
		case "mp_titanability_power_shot":
		{
			float maxClipAmmo = float( offhand.GetWeaponPrimaryClipCountMax() )
			float refillRate = offhand.GetWeaponSettingFloat( eWeaponVar.regen_ammo_refill_rate )

			bool ammo_drains = offhand.GetWeaponSettingBool( eWeaponVar.ammo_drains_to_empty_on_fire )

			float drainTime = 0.0
			if ( ammo_drains )
				drainTime = offhand.GetWeaponSettingFloat( eWeaponVar.fire_duration )

			cooldownTime = (maxClipAmmo / refillRate) + offhand.GetWeaponSettingFloat( eWeaponVar.regen_ammo_refill_start_delay ) + drainTime
		}
		break

		// Do nothing:
		case "mp_titanweapon_laser_lite":		// shared energy
		case "mp_titanability_laser_trip":		// shared energy
		case "mp_titanweapon_vortex_shield_ion":// shared energy
		{
			float maxEnergy = float( player.GetSharedEnergyTotal() )
			float refillRate = player.GetSharedEnergyRegenRate()

			cooldownTime = (maxEnergy / refillRate) + player.GetSharedEnergyRegenDelay()
		}
		break

		case "mp_titanability_basic_block":
		case "mp_titanweapon_tracker_rockets":
		case "mp_titanability_ammo_swap":
		{
			cooldownTime = 0.1
		}
		break

		default:
		{
			CodeWarning( offhand.GetWeaponClassName() + " - not handled in GetWeaponCooldownsForTitanLoadoutSwitch()." )
		}
	}

	float startTime = min( data.timeStored + LOADOUT_SWITCH_COOLDOWN_PENALTY, Time() )
	float elapsedTime = Time() - startTime

	float severity = elapsedTime / cooldownTime

	return clamp( severity + data.severity, 0, 1 )
}

///////////

array<string> function GetAllPilotTacticals()
{
	array<string> found
	array<string> weapons = GetAllSPWeapons()
	foreach ( weapon in weapons )
	{
		string weaponClass = expect string( GetWeaponInfoFileKeyField_GlobalNotNull( weapon, "weaponClass" ) )
		if ( weaponClass != "human" )
			continue
		if ( !GetWeaponInfoFileKeyField_Global( weapon, "leveled_pickup" ) )
			continue

		if ( GetWeaponInfoFileKeyField_Global( weapon, "offhand_default_inventory_slot" ) != OFFHAND_LEFT )
			continue

		found.append( weapon )
	}

	return found
}

void function AddOffhandWeaponMod_IfPlayerHas( entity player, int OFFHAND_INDEX, string weaponName, string weaponMod )
{
	entity weapon = player.GetOffhandWeapon( OFFHAND_INDEX )
	if ( !IsValid( weapon ) )
		return

	if ( weapon.GetWeaponClassName() != weaponName )
		return

	if ( weapon.HasMod( weaponMod ) )
		return

	array<string> mods = weapon.GetMods()
	mods.append( weaponMod )
	weapon.SetMods( mods )
}

void function RemoveOffhandWeaponMod_IfPlayerHas( entity player, int OFFHAND_INDEX, string weaponName, string weaponMod )
{
	entity weapon = player.GetOffhandWeapon( OFFHAND_INDEX )
	if ( !IsValid( weapon ) )
		return

	if ( weapon.GetWeaponClassName() != weaponName )
		return

	if ( weapon.HasMod( weaponMod ) )
		weapon.RemoveMod( weaponMod )
}

bool function AssignDefaultNPCSidearm( entity npc )
{
	string className = npc.GetClassName()
	if ( !( className in file.npcDefaultWeapons ) )
		return false
	if ( !( "auto_weapon_sidearm" in file.npcDefaultWeapons[ className ] ) )
		return false
	if ( !file.npcDefaultWeapons[ className ][ "auto_weapon_sidearm" ].len() )
		return false

	NPCDefaultWeapon weapon = file.npcDefaultWeapons[ className ][ "auto_weapon_sidearm" ].getrandom()
	npc.GiveWeapon( weapon.wep, weapon.mods )
	return true
}

array<string> function GetAllPrecachedSPWeapons()
{
	array<string> precachedWeapons
	foreach ( weapon in GetAllSPWeapons() )
	{
		if ( WeaponIsPrecached( weapon ) )
			precachedWeapons.append( weapon )
	}

	return precachedWeapons
}
