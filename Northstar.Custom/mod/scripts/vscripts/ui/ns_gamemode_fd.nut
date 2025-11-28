global function EliteIconSettings_Init
void function EliteIconSettings_Init()
{
    ModSettings_AddModTitle( "Experimental Frontier Defense" )
	
	ModSettings_AddModCategory( "Elite Titan Icon Settings" )
	ModSettings_AddEnumSetting( "ns_fd_elite_overhead_icontype", "Overhead Icon Type", ["No Change","Elite Icon","Class Grayscale"] )
	ModSettings_AddEnumSetting( "ns_fd_elite_minimap_icontype", "Minimap Icon Type", ["No Change","Elite Icon","Class Grayscale"] )
}