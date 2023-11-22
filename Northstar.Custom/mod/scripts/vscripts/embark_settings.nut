untyped
global function EmbarkSettings_Init


void function EmbarkSettings_Init(){
    #if UI
    ModSettings_AddModTitle( "Embark Settings", 2)
    ModSettings_AddModCategory("General")
    ModSettings_AddEnumSetting( "embark_style", "Titan Embark", ["Default", "First Person"], 2)
    #endif
}
