// this script only exists to add more features about fd
global function SHGamemodeFD_Custom_Init

void function SHGamemodeFD_Custom_Init()
{
	AddPrivateMatchModeSettingEnum( "#PL_fd", "fd_reaper_indicator", [ "#SETTING_DISABLED", "#SETTING_ENABLED" ], "0" )
}