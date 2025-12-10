global function GamemodeFDPlaylistvars_Init

void function GamemodeFDPlaylistvars_Init()
{
	foreach ( string difficulty in [ "#PL_fd_easy", "#PL_fd_normal", "#PL_fd_hard", "#PL_fd_master", "#PL_fd_insane" ] )
	{
		AddPrivateMatchModeSettingArbitrary( difficulty, "fd_money_per_round", FD_MONEY_PER_ROUND.tostring() )
		AddPrivateMatchModeSettingEnum( difficulty, "fd_money_flyouts", [ "#SETTING_DISABLED", "#SETTING_ENABLED" ], "#SETTING_DISABLED" )
		AddPrivateMatchModeSettingArbitrary( difficulty, "fd_killcredit_grunt", "5" )
		AddPrivateMatchModeSettingArbitrary( difficulty, "fd_killcredit_drone", "10" )
		AddPrivateMatchModeSettingArbitrary( difficulty, "fd_killcredit_spectre", "10" )
		AddPrivateMatchModeSettingArbitrary( difficulty, "fd_killcredit_stalker", "15" )
		AddPrivateMatchModeSettingArbitrary( difficulty, "fd_killcredit_reaper", "20" )
	}
}