global function _GamemodeSpd_init

global bool runnersActive = false

struct 
{
    table<int, entity> teams
} file

void function _GamemodeSpd_init()
{
	SetSpawnpointGamemodeOverride( TEAM_DEATHMATCH )

    SetShouldUseRoundWinningKillReplay( true )
	Riff_ForceTitanAvailability( eTitanAvailability.Never )
    Riff_ForceBoostAvailability( eBoostAvailability.Disabled )
    AddCallback_OnPlayerKilled( SpdOnPlayerKilled )

    AddCallback_GameStateEnter( eGameState.Playing, SelectFirstRunners )
    AddCallback_GameStateEnter( eGameState.Playing, RunnerSpeedScoring )
    AddCallback_OnPlayerRespawned( PlayerRespawned )
    AddCallback_GameStateEnter( eGameState.WinnerDetermined, OnWinnerDetermined )

}

void function PlayerRespawned( entity player )
{
    Sv_SPDSpeedometer_SetWeaponIcon( player )
    thread PlayerRespawned_Threaded( player )
}

void function Sv_SPDSpeedometer_SetWeaponIcon( entity player )
{
    Remote_CallFunction_Replay( player, "ServerCallback_SpdSpeedometer_SetWeaponIcon")
} // unfortunately since we cant pass strings here, and phase shift doesnt have a damageID, i have to do some bullshit to get the icon changing :/

void function PlayerRespawned_Threaded( entity player )
{
    WaitFrame() 
	if ( IsValid( player ) )
		PlayerEarnMeter_SetMode( player, eEarnMeterMode.DISABLED )
}

void function SpdOnPlayerKilled( entity victim, entity attacker, var damageInfo )
{

    if (attacker.IsPlayer() && attacker != victim)
    {
        // increase runner kills for attacker by 1 (if player and not suicide)
        attacker.AddToPlayerGameStat( PGS_KILLS, 1)
        attacker.AddToPlayerGameStat( PGS_PILOT_KILLS, 1)
    }    
    
    if ( file.teams[victim.GetTeam()] == victim )
    {
        // find new runner for team
        thread SelectNewRunnerForTeam(victim)
    }
    
    
}

void function SelectFirstRunners()
{
    thread SelectFirstRunners_Delayed()
}

void function SelectFirstRunners_Delayed() // TODO: add remote function callback to notify players 3 seconds before runner is chosen
{
    wait 5.0 
    
    for (int team = 1; team < 20; ++team ) // start at 1, because TEAM_UNASSIGNED should be ignored
    {
        
        array<entity> players = GetPlayerArrayOfTeam( team )
        if ( players.len() != 0 ) // if there are players on the team
        {
            
	        entity runner = players[ RandomInt( players.len() ) ] // randomly select runner from team
            int teamNum = team
            file.teams[teamNum] <- runner
            printt(teamNum + " " + runner)
            AlertTeam_NextRunner(runner)
        }
    }

    foreach (int teamNum, entity runner in file.teams)
    {
        thread NextRunnerCountdown(teamNum, runner, 5) // first runners
    }
}

void function SelectNewRunnerForTeam( entity player )
{
    wait 3
    int team = player.GetTeam()
    array<entity> players = GetPlayerArrayOfTeam( team )
    if ( players.len() != 0 ) // if there are players on the team
    {
        
	    entity runner = players[ RandomInt( players.len() ) ] // randomly select runner from team
        if ( players.len() != 1 && runner == player)
        {
            runner = players[ RandomInt( players.len() ) ] // reroll once
        }

        file.teams[team] <- runner
        printt(team + " " + runner)
        AlertTeam_NextRunner(runner)
        NextRunnerCountdown(team, runner, 5) // subsequent runners have a 5 second timer

    
    }


}

void function AlertTeam_NextRunner(entity runner)
{
    foreach (entity player in GetPlayerArrayOfTeam(runner.GetTeam()))
    {
        if (player == runner)
        {
            Remote_CallFunction_NonReplay( player, "ServerCallback_Spd_Runner_You_Next")
        }
        else
        {
            Remote_CallFunction_NonReplay( player, "ServerCallback_Spd_Runner_Teammate_Next")
        }
    }
}

void function AlertTeam_NewRunner(entity runner)
{
    foreach (entity player in GetPlayerArrayOfTeam(runner.GetTeam()))
    {
        if (player == runner)
        {
            Remote_CallFunction_NonReplay( player, "ServerCallback_Spd_Runner_You")
        }
        else
        {
            Remote_CallFunction_NonReplay( player, "ServerCallback_Spd_Runner_Teammate")
        }
    }
}



void function NextRunnerCountdown( int team, entity runner, int countdownLength )
{
    array<entity> players = GetPlayerArrayOfTeam(team)

    while ( countdownLength > 0 )
    {
        wait 1.0 // wait a second
        // send tick noise to players
        foreach ( entity player in players )
        {
            if ( player == runner )
            {
                EmitSoundOnEntityOnlyToPlayer( player, player, "HUD_match_start_timer_5_seconds_1P" ) // unsure if this will play in third person
            }
            else
            {
                EmitSoundOnEntityOnlyToPlayer( player, player, "HUD_match_start_timer_tick_1P" ) // unsure if this will play in third person in game, needs testing
            }
        }

        countdownLength--
    }
    // countdown is done
    AlertTeam_NewRunner( runner )

    
    wait countdownLength
    SetRunnerForTeam( team, runner)
    

}

void function SetRunnerForTeam( int team, entity runner )
{
    file.teams[team] <- runner
    Highlight_SetEnemyHighlight( runner, "enemy_boss_bounty" )
}

array<entity> function GetRunnerArray()
{
    array<entity> runners
    foreach (int team, entity runner in file.teams)
    {
        runners.append(runner)
    }
    return runners
}

void function RunnerSpeedScoring()
{
    
    thread RunnerSpeedScoring_Thread()
}

void function RunnerSpeedScoring_Thread()
{
    wait 10
    runnersActive = true;
    
    while (runnersActive)
    {
        wait 1
        array<entity> runners = GetRunnerArray()

        float fastestSpeed = 300
        entity fastestRunner
        // iterate through the runners to find the fastest
        foreach (entity runner in runners)
        {
            if (IsAlive(runner))
                {
                vector velocity = runner.GetVelocity()
                float velocityScalar = sqrt( fabs(velocity.z) /* * velocity.z*/ + velocity.x * velocity.x + velocity.y * velocity.y ) //respawn's speedometer hates vertical velocity
                if (fastestSpeed < velocityScalar)
                {
                    fastestSpeed = velocityScalar
                    fastestRunner = runner
                }
                if (velocityScalar * (0.274176/3) > runner.GetPlayerGameStat( PGS_DEFENSE_SCORE ))
                    runner.SetPlayerGameStat( PGS_DEFENSE_SCORE, floor(velocityScalar * (0.274176/3)) )
            }
        }
        
        if (fastestRunner != null)
        {
            fastestRunner.AddToPlayerGameStat( PGS_ASSAULT_SCORE, 1 ) // fastest runner get 1 point per second TODO: change so that runners get 1 point per second for each runner that they are faster than
            AddTeamScore( fastestRunner.GetTeam(), 1 )
        }
        foreach (entity runner in runners)
        {
            if (fastestSpeed == 0)
            {
                Sv_GGEarnMeter_SetPercentage(runner, 0)
            }
            else
            {
                vector velocity = runner.GetVelocity()
                float velocityScalar = sqrt( fabs(velocity.z) /* * velocity.z*/ + velocity.x * velocity.x + velocity.y * velocity.y ) //respawn's speedometer hates vertical velocity

                Sv_GGEarnMeter_SetPercentage(runner, (velocityScalar / fastestSpeed) - 0.01)
            }

            
        }
        // TODO: make algorithm to rank runners, and give them +1 score per second for each runner that they are faster than
    }
    
}

void function OnWinnerDetermined()
{
    SetRespawnsEnabled( false )
	SetKillcamsEnabled( false )
    runnersActive = false
}