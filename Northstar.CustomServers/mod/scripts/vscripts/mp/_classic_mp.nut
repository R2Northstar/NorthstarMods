untyped
global function ClassicMp_Init
global function ClassicMP_TryDefaultIntroSetup

// intro setups
global function ClassicMP_SetLevelIntro
global function ClassicMP_SetCustomIntro
global function ClassicMP_SetupIntro

// intro funcs
global function ClassicMP_OnIntroStarted
global function ClassicMP_OnIntroFinished
global function ClassicMP_GetIntroLength

// epilogue setups
global function ClassicMP_ForceDisableEpilogue
global function ClassicMP_SetEpilogue
global function ClassicMP_SetupEpilogue

// epilogue checks
global function ClassicMP_ShouldRunEpilogue
global function ClassicMP_RunEpilogueWithDeadPlayers

global function GetClassicMPMode

struct
{
	// level intros have a lower priority than custom intros
	// level intros are used only if a custom intro was not specified
	void functionref() levelIntroSetupFunc
	float levelIntroLength

	void functionref() customIntroSetupFunc
	float customIntroLength

	bool epilogueForceDisabled = false
	bool shouldRunEpilogueInRoundBasedMode = false
	void functionref() epilogueSetupFunc

	// epilogue checks
	bool runEpilogueWithDeadPlayers = false
} file

void function ClassicMp_Init()
{
	// default level intros
	if ( IsFFAGame() || !GetCurrentPlaylistVarInt( "run_intro", 1 ) )
		ClassicMP_SetLevelIntro( ClassicMP_DefaultNoIntro_Setup, ClassicMP_DefaultNoIntro_GetLength() )
	else
		ClassicMP_SetLevelIntro( ClassicMP_DefaultDropshipIntro_Setup, DROPSHIP_INTRO_LENGTH )
}

// stub func, called in mp_sh_init
void function ClassicMP_TryDefaultIntroSetup()
{
}

void function ClassicMP_SetLevelIntro( void functionref() setupFunc, float introLength )
{
	file.levelIntroSetupFunc = setupFunc
	file.levelIntroLength = introLength
}

void function ClassicMP_SetCustomIntro( void functionref() setupFunc, float introLength )
{
	file.customIntroSetupFunc = setupFunc
	file.customIntroLength = introLength
}

void function ClassicMP_SetupIntro()
{
	if ( !GetCurrentPlaylistVarInt( "classic_mp", 1 ) )
		return

	if ( file.customIntroSetupFunc != null )
		file.customIntroSetupFunc()
	else
		file.levelIntroSetupFunc()
}

void function ClassicMP_OnIntroStarted()
{
	printt( "started intro!" )
}

void function ClassicMP_OnIntroFinished()
{
	printt( "intro finished!" )
}

float function ClassicMP_GetIntroLength()
{
	if ( file.customIntroSetupFunc != null )
		return file.customIntroLength

	return file.levelIntroLength
}

void function ClassicMP_ForceDisableEpilogue( bool disabled )
{
	file.epilogueForceDisabled = disabled
}

void function ClassicMP_SetEpilogue( void functionref() setupFunc )
{
	file.epilogueSetupFunc = setupFunc
}

void function ClassicMP_SetupEpilogue()
{
	if ( file.epilogueSetupFunc == null ) // default is evac
		ClassicMP_SetEpilogue( EvacEpilogueSetup )

	file.epilogueSetupFunc()
}

bool function GetClassicMPMode()
{
	return GetCurrentPlaylistVarInt( "classic_mp", 1 ) != 0
}

bool function ClassicMP_ShouldRunEpilogue()
{
	if ( IsFFAGame() )
		return false

	if ( !GetCurrentPlaylistVarInt( "run_evac", 0 ) )
	{
		int winningTeam = GetWinningTeam()

		if ( !IsIMCOrMilitiaTeam( winningTeam ) )
			return false

		if ( !file.runEpilogueWithDeadPlayers && IsPilotEliminationBased() && IsTeamEliminated( GetOtherTeam( winningTeam ) ) )
			return false

		// there needs to be atleast 1 player on each team before running epilogue
		if ( GetCurrentPlaylistVarInt( "max_teams", 2 ) != 1 )
		{
			int winningPlayers = 0
			int losingPlayers = 0

			foreach ( entity player in GetPlayerArray() )
			{
				if ( IsValidPlayer( player ) && !IsPrivateMatchSpectator( player ) )
				{
					if ( player.GetTeam() == winningTeam )
						winningPlayers++
					else
						losingPlayers++
				}
			}

			if ( !winningPlayers || !losingPlayers )
				return false
		}
	}

	return !file.epilogueForceDisabled && GetCurrentPlaylistVarInt( "run_epilogue", 1 ) != 0
}

void function ClassicMP_RunEpilogueWithDeadPlayers( bool enabled )
{
	file.runEpilogueWithDeadPlayers = enabled
}
