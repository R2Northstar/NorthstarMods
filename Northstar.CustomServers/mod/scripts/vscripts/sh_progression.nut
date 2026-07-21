global function Progression_Init
global function ProgressionEnabledForPlayer
#if CLIENT || UI
	global function Progression_SetPreference
	global function Progression_GetPreference
	global function UpdateCachedLoadouts_Delayed
#endif

#if SP // literally just stub the global functions and call it a day

	void function Progression_Init()
	{
	}
	bool function ProgressionEnabledForPlayer( entity player )
	{
		return false
	}
	#if CLIENT || UI
		void function Progression_SetPreference( bool enabled )
		{
		}
		bool function Progression_GetPreference()
		{
			return false
		}
		void function UpdateCachedLoadouts_Delayed()
		{
		}
	#endif // CLIENT || UI

#else // MP || UI basically

	// SO FOR SOME GOD DAMN REASON, PUTTING THESE INTO ONE STRUCT
	// AND PUTTING THE #if STUFF AROUND THE VARS CAUSES A COMPILE
	// ERROR, SO I HAVE TO DO THIS AWFULNESS

	#if SERVER
		struct
		{
			table<entity, bool> progressionEnabled
		} file
	#else // UI || CLIENT
		struct
		{
			bool isUpdatingCachedLoadouts = false
		} file
	#endif

	void function Progression_Init()
	{
		#if SERVER
			AddCallback_OnClientDisconnected( OnClientDisconnected )
			AddClientCommandCallback( "ns_progression", ClientCommand_SetProgression )
			AddClientCommandCallback( "ns_resettitanaegis", ClientCommand_ResetTitanAegis )
			delaythread( 0.0001 ) SetUIVar( level, "penalizeDisconnect", false ) // don't show "you will lose merits" thing
		#elseif CLIENT
			AddCallback_OnClientScriptInit( OnClientScriptInit )
		#endif
	}

	bool function ProgressionEnabledForPlayer( entity player )
	{
		#if SERVER
			if ( player in file.progressionEnabled )
				return file.progressionEnabled[ player ]

			return false
		#else // CLIENT || UI
			return GetConVarBool( "ns_progression_enabled" )
		#endif
	}

	#if SERVER
		void function OnClientDisconnected( entity player )
		{
			// cleanup table when player leaves
			if ( player in file.progressionEnabled )
				delete file.progressionEnabled[ player ]
		}

		bool function ClientCommand_SetProgression( entity player, array<string> args )
		{
			if ( args.len() != 1 )
				return false
			if ( args[ 0 ] != "0" && args[ 0 ] != "1" )
				return false

			file.progressionEnabled[ player ] <- args[ 0 ] == "1"

			// loadout validation when progression is turned on
			if ( file.progressionEnabled[ player ] )
				ValidateLoadout_OnClientConnecting( player, false )

			return true
		}

		// / Resets a specific Titan's Aegis rank back to `0`
		// / * `player` - The player entity to perform the action on
		// / * `args` - The arguments passed from the client command. `args[0]` should be a string corresponding to the chassis name of the Titan to reset.
		// / Valid chassis are: ion, tone, vanguard, northstar, ronin, legion, and scorch.
		// /
		// / Returns `true` on success and `false` on missing args.
		bool function ClientCommand_ResetTitanAegis( entity player, array<string> args )
		{
			if ( !args.len() )
				return false

			string titanRef = args[ 0 ].tolower()
			if ( !PersistenceEnumValueIsValid( "titanClasses", titanRef ) )
				return false

			int suitIndex = PersistenceGetEnumIndexForItemName( "titanClasses", titanRef )

			player.SetPersistentVar( "titanFDUnlockPoints[" + suitIndex + "]", 0 )
			player.SetPersistentVar( "previousFDUnlockPoints[" + suitIndex + "]", 0 )
			player.SetPersistentVar( "fdTitanXP[" + suitIndex + "]", 0 )
			player.SetPersistentVar( "fdPreviousTitanXP[" + suitIndex + "]", 0 )

			// Refresh Highest Aegis Titan since we might get all of them back to 1 if players wants
			RecalculateHighestTitanFDLevel( player )

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
			UpdateCachedLoadouts_Delayed()
		}
	#endif

	#if CLIENT || UI
		void function Progression_SetPreference( bool enabled )
		{
			SetConVarBool( "ns_progression_enabled", enabled )

			#if !VANILLA
				#if CLIENT
					GetLocalClientPlayer().ClientCommand( "ns_progression " + enabled.tointeger() )
				#else // UI
					ClientCommand( "ns_progression " + enabled.tointeger() )
				#endif
			#endif
		}

		bool function Progression_GetPreference()
		{
			#if VANILLA
				return true
			#else
				return GetConVarBool( "ns_progression_enabled" )
			#endif
		}

		void function UpdateCachedLoadouts_Delayed()
		{
			if ( file.isUpdatingCachedLoadouts )
				return

			file.isUpdatingCachedLoadouts = true

			#if UI
				RunClientScript( "UpdateCachedLoadouts_Delayed" ) // keep client and UI synced
			#else // CLIENT
				RunUIScript( "UpdateCachedLoadouts_Delayed" ) // keep client and UI synced
			#endif

			thread UpdateCachedLoadouts_Threaded()
		}

		void function UpdateCachedLoadouts_Threaded()
		{
			wait 1.0 // give the server time to network our new persistence

			UpdateCachedLoadouts()

			// below here is just making all the menu models update properly and such

			try
			{
				#if UI
					entity UIPlayer = GetUIPlayer()

					if ( !IsValid( UIPlayer ) )
						return

					uiGlobal.pilotSpawnLoadoutIndex = GetPersistentSpawnLoadoutIndex( UIPlayer, "pilot" )
					uiGlobal.titanSpawnLoadoutIndex = GetPersistentSpawnLoadoutIndex( UIPlayer, "titan" )
				#endif

				#if CLIENT
					entity player = GetLocalClientPlayer()
					ClearAllTitanPreview( player )
					ClearAllPilotPreview( player )
					UpdateTitanModel( player, GetPersistentSpawnLoadoutIndex( player, "titan" ) )
					UpdatePilotModel( player, GetPersistentSpawnLoadoutIndex( player, "pilot" ) )
				#endif
			}
			catch ( error )
			{
			}

			file.isUpdatingCachedLoadouts = false
		}
	#endif

#endif // MP
