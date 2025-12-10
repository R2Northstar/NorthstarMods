global function GamemodeFDPlaylistvars_Init

void function GamemodeFDPlaylistvars_Init()
{
	foreach ( string difficulty in [ "#PL_fd_easy", "#PL_fd_normal", "#PL_fd_hard", "#PL_fd_master", "#PL_fd_insane" ] )
	{
		// AddPrivateMatchModeSettingEnum( difficulty, "fd_allow_elite_titans", [ "#SETTING_DISABLED", "#SETTING_ENABLED" ], "#SETTING_DISABLED" )
		// AddPrivateMatchModeSettingEnum( difficulty, "fd_allow_titanfall_block", [ "#SETTING_DISABLED", "#SETTING_ENABLED" ], "#SETTING_DISABLED" )
		// AddPrivateMatchModeSettingEnum( difficulty, "fd_arc_titans_uses_arc_cannon", [ "#SETTING_DISABLED", "#SETTING_ENABLED" ], "#SETTING_DISABLED" )
		// AddPrivateMatchModeSettingArbitrary( difficulty, "fd_grunt_shield_captains", "0" )
		// AddPrivateMatchModeSettingEnum( difficulty, "fd_campaign_shield_captains", [ "#SETTING_DISABLED", "#SETTING_ENABLED" ], "#SETTING_DISABLED" )
		// AddPrivateMatchModeSettingEnum( difficulty, "fd_campaign_ticks", [ "#SETTING_DISABLED", "#SETTING_ENABLED" ], "#SETTING_DISABLED" )
		// AddPrivateMatchModeSettingEnum( difficulty, "fd_grunts_uses_grenades", [ "#SETTING_DISABLED", "#SETTING_ENABLED" ], "#SETTING_DISABLED" )
		// AddPrivateMatchModeSettingEnum( difficulty, "fd_visible_drop_points", [ "#SETTING_DISABLED", "#SETTING_ENABLED" ], "#SETTING_DISABLED" )
		// AddPrivateMatchModeSettingEnum( difficulty, "fd_epilogue_enabled", [ "#SETTING_DISABLED", "#SETTING_ENABLED" ], "#SETTING_DISABLED" )
		AddPrivateMatchModeSettingArbitrary( difficulty, "fd_money_per_round", FD_MONEY_PER_ROUND.tostring() )
		AddPrivateMatchModeSettingEnum( difficulty, "fd_money_flyouts", [ "#SETTING_DISABLED", "#SETTING_ENABLED" ], "#SETTING_DISABLED" )
		AddPrivateMatchModeSettingArbitrary( difficulty, "fd_killcredit_grunt", "5" )
		AddPrivateMatchModeSettingArbitrary( difficulty, "fd_killcredit_drone", "10" )
		AddPrivateMatchModeSettingArbitrary( difficulty, "fd_killcredit_spectre", "10" )
		AddPrivateMatchModeSettingArbitrary( difficulty, "fd_killcredit_stalker", "15" )
		AddPrivateMatchModeSettingArbitrary( difficulty, "fd_killcredit_reaper", "20" )
	}

	// AddPrivateMatchModeSettingEnum( "#PL_fd_easy", "fd_smart_pistol_easy_mode", [ "#SETTING_DISABLED", "#SETTING_ENABLED" ], "#SETTING_DISABLED" )
}