global function EliteIconSettings_Init
void function EliteIconSettings_Init()
{
    ModSettings_AddModTitle( "Experimental Frontier Defense" )
	
	ModSettings_AddModCategory( "Gameplay Options" )
	ModSettings_AddEnumSetting( "ns_fd_allow_elite_titans", "Allow Elite Titans", ["Disabled","Enabled"] )
	ModSettings_AddEnumSetting( "ns_fd_allow_titanfall_block", "Allow Titanfall Block", ["Disabled","Enabled"] )
	ModSettings_AddEnumSetting( "ns_fd_allow_true_shield_captains", "Allow Campaign Shield Captains", ["Disabled","Enabled"] )
	ModSettings_AddEnumSetting( "ns_fd_arc_titans_uses_arc_cannon", "Arc Titans Uses Arc Cannon", ["No","Yes"] )
	ModSettings_AddEnumSetting( "ns_fd_differentiate_ticks", "Wave Ticks are Campaign Ticks", ["No","Yes"] )
	ModSettings_AddEnumSetting( "ns_fd_disable_respawn_dropship", "Disable Respawn Dropship", ["No","Yes"] )
	ModSettings_AddEnumSetting( "ns_reaper_warpfall_kill", "Reaper Kills on Warpfall", ["No","Yes"] )
	ModSettings_AddEnumSetting( "ns_fd_easymode_smartpistol", "Smart Pistol on Easy Mode", ["Disabled","Enabled"] )
	ModSettings_AddEnumSetting( "ns_fd_rodeo_highlight", "Green Rodeo Highlight", ["Disabled","Enabled"] )
	ModSettings_AddEnumSetting( "ns_fd_show_drop_points", "Show Enemy Drop Points", ["Disabled","Enabled"] )
	
	ModSettings_AddModCategory( "Elite Titan Icon Settings" )
	ModSettings_AddEnumSetting( "ns_fd_elite_overhead_icontype", "Overhead Icon Type", ["No Change","Elite Icon","Class Grayscale"] )
	ModSettings_AddEnumSetting( "ns_fd_elite_minimap_icontype", "Minimap Icon Type", ["No Change","Elite Icon","Class Grayscale"] )
}