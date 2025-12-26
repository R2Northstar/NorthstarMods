global function DropBatteryCommand_Init

void function DropBatteryCommand_Init()
{
	AddPrivateMatchModeSettingEnum( "#MODE_SETTING_CATEGORY_RIFF", "drop_battery_command", [ "#SETTING_DISABLED", "#SETTING_ENABLED" ], "#SETTING_DISABLED" )

	#if SERVER
		AddClientCommandCallback( "dropbattery", ClientCommandCallbackDropBattery )
	#endif
}

#if SERVER
	bool function ClientCommandCallbackDropBattery( entity player, array<string> args )
	{
		if ( GetCurrentPlaylistVarInt( "drop_battery_command", 0 ) && !player.IsTitan() && PlayerHasBattery( player ) )
			Rodeo_PilotThrowsBattery( player )

		return true
	}
#endif