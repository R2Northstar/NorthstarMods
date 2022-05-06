untyped

global function CaptureTheFlag_Init
global function RateSpawnpoints_CTF

const int CTF_TEAMCOUNT = 2

struct {
	table< int, array<entity> > captureAssists
} file

void function CaptureTheFlag_Init()
{
	PrecacheModel( CTF_FLAG_MODEL )
	PrecacheModel( CTF_FLAG_BASE_MODEL )
	
	RegisterSignal( "PlayerFlagReturnOver" )
	RegisterSignal( "FlagPickedUp" )
	RegisterSignal( "FlagReset" )
	RegisterSignal( "FlagDropped" )
	
	CaptureTheFlagShared_Init()
	SetSwitchSidesBased( true )
	SetSuddenDeathBased( true )
	SetShouldUseRoundWinningKillReplay( true )
	SetRoundWinningKillReplayKillClasses( false, false ) // make these fully manual
	
	AddCallback_OnClientConnected( InitCTFPlayer )
	AddCallback_OnPlayerKilled( OnPlayerKilled )
	
	AddSpawnCallback( "info_spawnpoint_flag", FlagSpawnpointCreated )
	AddCallback_OnTouchHealthKit( "item_flag", FlagCollectedByPlayer )
	
	AddCallback_GameStateEnter( eGameState.Prematch, CTFStartGame )
	
	// setup score event earnmeter values
	ScoreEvent_SetEarnMeterValues( "KillPilot", 0.05, 0.20 )
	ScoreEvent_SetEarnMeterValues( "Headshot", 0.0, 0.02 )
	ScoreEvent_SetEarnMeterValues( "FirstStrike", 0.0, 0.05 )
	ScoreEvent_SetEarnMeterValues( "KillTitan", 0.0, 0.25 )
	ScoreEvent_SetEarnMeterValues( "PilotBatteryStolen", 0.0, 0.35 )
	
	ScoreEvent_SetEarnMeterValues( "FlagCarrierKill", 0.0, 0.20 )
	ScoreEvent_SetEarnMeterValues( "FlagTaken", 0.0, 0.10 )
	ScoreEvent_SetEarnMeterValues( "FlagCapture", 0.0, 0.30 )
	ScoreEvent_SetEarnMeterValues( "FlagCaptureAssist", 0.0, 0.20 )
	ScoreEvent_SetEarnMeterValues( "FlagReturn", 0.0, 0.20 )
}

const bool CTF_SPAWN_DEBUG = false

void function RateSpawnpoints_CTF( int checkClass, array<entity> spawnpoints, int team, entity player ) 
{
	// get the player's frontline and try to spawn them there, then give less good ratings as we get away from the frontline in the direction of the player's base
	Frontline frontline = GetFrontline( player.GetTeam() )

	vector ourFlag = GetFlagSpawnOriginForTeam( player.GetTeam() )
	vector theirFlag = GetFlagSpawnOriginForTeam( GetOtherTeam( player.GetTeam() ) )
	float flagDist = Distance2D( ourFlag, theirFlag )
	
	// weight the frontline position to be closer to friendly base
	// this is mainly done to avoid issues with frontline position being way too aggressive when people push enemy bases and that, making it pretty unfair for defending team
	vector weightedFrontline = frontline.origin
	{
		const float FRONTLINE_WEIGHT_THRESHOLD = 0.325
	
		float frontlineAngle = atan2( frontline.origin.y - ourFlag.y, frontline.origin.x - ourFlag.x ) * ( 180 / PI )
		float frontlineDistFrac = Distance2D( ourFlag, frontline.origin ) / flagDist
		if ( frontlineDistFrac > FRONTLINE_WEIGHT_THRESHOLD )
		{
			float fracAboveThreshold = frontlineDistFrac - FRONTLINE_WEIGHT_THRESHOLD
			fracAboveThreshold *= fracAboveThreshold * 0.4
			frontlineDistFrac = FRONTLINE_WEIGHT_THRESHOLD + fracAboveThreshold
		}
		
		weightedFrontline = ourFlag + AnglesToForward( < 0, frontlineAngle, 0 > ) * ( frontlineDistFrac * flagDist )
		
		#if CTF_SPAWN_DEBUG
			DebugDrawSphere( frontline.origin, 100, 0, 0, 255, false, 30.0, 16 )
			DebugDrawSphere( weightedFrontline, 100, 0, 255, 0, false, 30.0, 16 )
		#endif
	}
	
	float frontlineDistReal = Distance2D( ourFlag, frontline.origin )
	float frontlineDist = Distance2D( ourFlag, weightedFrontline )
	float frontlineAngleReal = atan2( frontline.origin.y - ourFlag.y, frontline.origin.x - ourFlag.x ) * ( 180 / PI )
	float frontlineAngle = atan2( weightedFrontline.y - ourFlag.y, weightedFrontline.x - ourFlag.x ) * ( 180 / PI )
	
	// dividing dist between flags by 3ish gives a good radius for the initial circle
	// should this be based on the distance to the frontline? unsure, it probably should be based more on map size than spawn pos anyway
	float initialRatingRad = flagDist / 3.25 / 2	
		
	foreach ( entity spawnpoint in spawnpoints )
	{
		float rating
				
		// assume 150 is the max possible rating, with a range of 50-150 if within the initial rating radius, and 0-50 outside of it
		float dist = Distance2D( spawnpoint.GetOrigin(), weightedFrontline )
		if ( dist <= initialRatingRad )
		{
			rating = 50 + ( dist / initialRatingRad ) * 100
			#if CTF_SPAWN_DEBUG
				DebugDrawSphere( spawnpoint.GetOrigin(), 50, 255, 0, 0, false, 30.0, 16 )
			#endif
		}
		else
		{
			// calc angle between our spawnpoint and frontline	
			float angleReal = ( atan2( frontline.origin.y - spawnpoint.GetOrigin().y, frontline.origin.x - spawnpoint.GetOrigin().x ) * ( 180 / PI ) ) - frontlineAngleReal
			float angle = ( atan2( weightedFrontline.y - spawnpoint.GetOrigin().y, weightedFrontline.x - spawnpoint.GetOrigin().x ) * ( 180 / PI ) ) - frontlineAngle			

			// if it's <=1/3 of the distance between frontline and spawn, ensure it's within 65deg
			// otherwise, just make sure its on the same side of the map
			float frontlineSpawnDist = Distance2D( spawnpoint.GetOrigin(), weightedFrontline )
			
			if ( ( angleReal <= 50 && angleReal >= -50 ) || ( angle <= 110 && angle >= -110 && frontlineSpawnDist <= frontlineDistReal / 3 ) && frontlineSpawnDist < frontlineDist )
			{
				// max out at flagDist, rate better as we get closer
				rating = ( ( 1 - ( Distance2D( spawnpoint.GetOrigin(), weightedFrontline ) / frontlineDist ) ) * 50 )
				#if CTF_SPAWN_DEBUG
					DebugDrawSphere( spawnpoint.GetOrigin(), 50, 255, 200, 255 - int( ( rating / 50 ) * 255 ), false, 30.0, 16 )
				#endif
			}
		}
		
		spawnpoint.CalculateRating( checkClass, player.GetTeam(), rating, rating > 0 ? rating * 0.25 : rating )
	}
}


// flag funcs
void function FlagSpawnpointCreated( entity spawnpoint )
{
	svGlobal.flagSpawnPoints[ spawnpoint.GetTeam() ] = spawnpoint
}

bool function PlayerCanInteractWithFlag( entity player )
{
	return player.IsPlayer() && IsAlive( player ) && !player.IsTitan() && !player.IsPhaseShifted()
}

bool function FlagCollectedByPlayer( entity player, entity flag )
{
	// only run if the flag isn't being held and we can interact with it
	if ( !PlayerCanInteractWithFlag( player ) || IsValid( flag.GetParent() ) )
		return false
	
	// if flags and player are on different teams, player tries to grab the flag
	// else, they try to cap with the flag they're already holding if they have one
	if ( player.GetTeam() != flag.GetTeam() )
		Flag_GiveToPlayer( flag, player )
	else if ( IsFlagHome( flag ) && PlayerHasEnemyFlag( player ) )
		Flag_CapturedByPlayer( GetFlagForTeam( GetOtherTeam( flag.GetTeam() ) ), player )
	
	return false
}

void function FlagLifetime( entity flag )
{
	flag.EndSignal( "OnDestroy" )
	
	// run every frame while the flag exists
	while ( true )
	{
		// this is a bit of a hack, it seems parenting the return trigger to the flag actually sets the pickup radius of the flag to be the same as the trigger
		// this isn't wanted since only pickups should use that additional radius
		flag.s.returnTrigger.SetOrigin( flag.GetOrigin() )
		
		WaitFrame()
	}
}

void function FlagLifetimeHeld( entity flag, entity player )
{
	flag.EndSignal( "OnDestroy" )
	flag.EndSignal( "FlagReset" )
	flag.EndSignal( "FlagDropped" )
	
	player.EndSignal( "OnChangedPlayerClass" )
	player.EndSignal( "StartPhaseShift" )
	
	OnThreadEnd( function() : ( flag, player )
	{
		// if the flag is still held (i.e. thread is ending due to becoming titan, phase etc), drop it
		if ( flag.GetParent() == player )
			Flag_DroppedByPlayer( player )
	})
	
	// run every frame while the flag is held by a player
	while ( IsValid( flag.GetParent() ) )
		WaitFrame()
}

void function TrackFlagDropTimeout( entity flag )
{
	flag.EndSignal( "OnDestroy" )
	flag.EndSignal( "FlagPickedUp" )
	flag.EndSignal( "FlagReset" )
	
	// if the flag isnt touched at all before this timeout is up, reset it
	wait CTF_GetDropTimeout()
	Flag_Reset( flag )
}

void function PlayerTriesToReturnFlag( entity player, entity flag )
{
	float returnTime = CTF_GetFlagReturnTime()

	// start return progress bar ui on client
	Remote_CallFunction_NonReplay( player, "ServerCallback_CTF_StartReturnFlagProgressBar", Time() + returnTime )
	EmitSoundOnEntityOnlyToPlayer( player, player, "UI_CTF_1P_FlagReturnMeter" )

	OnThreadEnd( function() : ( player )
	{
		// cleanup ui
		Remote_CallFunction_NonReplay( player, "ServerCallback_CTF_StopReturnFlagProgressBar" )
		StopSoundOnEntity( player, "UI_CTF_1P_FlagReturnMeter" )
	})

	player.EndSignal( "PlayerFlagReturnOver" )
	player.EndSignal( "OnDeath" )
	flag.EndSignal( "OnDestroy" )
	
	// wait for flag return to complete
	wait returnTime
	
	// flag return completed without any interruptions!
	Flag_Reset( flag )
	
	// notify players of the return
	MessageToPlayer( player, eEventNotifications.YouReturnedFriendlyFlag )
	AddPlayerScore( player, "FlagReturn", player )
	player.AddToPlayerGameStat( PGS_DEFENSE_SCORE, 1 )
	
	int friendlyTeam = flag.GetTeam()
	MessageToTeam( friendlyTeam, eEventNotifications.PlayerReturnedFriendlyFlag, null, player )
	EmitSoundOnEntityToTeam( flag, "UI_CTF_3P_TeamReturnsFlag", friendlyTeam )
	PlayFactionDialogueToTeam( "ctf_flagReturnedFriendly", friendlyTeam )
	
	int enemyTeam = GetOtherTeam( friendlyTeam )
	MessageToTeam( enemyTeam, eEventNotifications.PlayerReturnedEnemyFlag, null, player )
	EmitSoundOnEntityToTeam( flag, "UI_CTF_3P_EnemyReturnsFlag", enemyTeam )
	PlayFactionDialogueToTeam( "ctf_flagReturnedEnemy", enemyTeam )
}

void function SetFlagStateForTeam( int team, int state )
{
	string flagVarStr = team == TEAM_IMC ? "imcFlag" : "milFlag"
	string flagStateVarStr = team == TEAM_IMC ? "imcFlagState" : "milFlagState"

	if ( state == eFlagState.Away ) // we tell the client the flag is the player carrying it if they're carrying it
		SetGlobalNetEnt( flagVarStr, GetFlagForTeam( team ).GetParent() )
	else
		SetGlobalNetEnt( flagVarStr, GetFlagForTeam( team ) )

	SetGlobalNetInt( flagStateVarStr, state )
}

void function Flag_Reset( entity flag, bool clearAssists = true )
{
	// drop the flag
	flag.ClearParent()
	flag.s.returnTrigger.Enable()
	
	// reset pos
	flag.SetOrigin( flag.s.base.GetOrigin() ) 
	flag.SetAngles( < 0, 0, 0 > )
	
	// clear assists if not being handled by other code
	if ( clearAssists )
		file.captureAssists[ GetOtherTeam( flag.GetTeam() ) ].clear()
		
	// set flag state
	SetFlagStateForTeam( flag.GetTeam(), eFlagState.None ) // used for home
	flag.Signal( "FlagReset" )
}

void function Flag_GiveToPlayer( entity flag, entity player )
{
	flag.SetParent( player, "FLAG" )
	flag.s.returnTrigger.Disable()
	thread FlagLifetimeHeld( flag, player )
	
	// do notifications
	MessageToPlayer( player, eEventNotifications.YouHaveTheEnemyFlag )
	EmitSoundOnEntityOnlyToPlayer( player, player, "UI_CTF_1P_GrabFlag" )
	AddPlayerScore( player, "FlagTaken", player )
	PlayFactionDialogueToPlayer( "ctf_flagPickupYou", player )
	
	MessageToTeam( player.GetTeam(), eEventNotifications.PlayerHasEnemyFlag, player, player )
	EmitSoundOnEntityToTeamExceptPlayer( flag, "UI_CTF_3P_TeamGrabFlag", player.GetTeam(), player )
	PlayFactionDialogueToTeamExceptPlayer( "ctf_flagPickupFriendly", player.GetTeam(), player )
	
	MessageToTeam( flag.GetTeam(), eEventNotifications.PlayerHasFriendlyFlag, player, player )
	EmitSoundOnEntityToTeam( flag, "UI_CTF_EnemyGrabFlag", flag.GetTeam() )
	
	// set flag state
	SetFlagStateForTeam( flag.GetTeam(), eFlagState.Away )
	flag.Signal( "FlagPickedUp" )
}

void function Flag_CapturedByPlayer( entity flag, entity player )
{
	// reset the flag
	Flag_Reset( flag, false ) // false so we handle assists ourselves
	
	// score
	AddTeamScore( player.GetTeam(), 1 )
	player.AddToPlayerGameStat( PGS_ASSAULT_SCORE, 1 ) // add 1 to captures on scoreboard
	SetRoundWinningKillReplayAttacker( player ) // set attacker for last cap replay
	
	// cap assists
	foreach ( entity assistPlayer in file.captureAssists[ player.GetTeam() ] )
		if ( player != assistPlayer )
			AddPlayerScore( assistPlayer, "FlagCaptureAssist", player )
	
	file.captureAssists[ player.GetTeam() ].clear()
	
	// notifs
	MessageToPlayer( player, eEventNotifications.YouCapturedTheEnemyFlag )
	EmitSoundOnEntityOnlyToPlayer( player, player, "UI_CTF_1P_PlayerScore" )
	
	MessageToTeam( player.GetTeam(), eEventNotifications.PlayerCapturedEnemyFlag, player, player )
	EmitSoundOnEntityToTeamExceptPlayer( flag, "UI_CTF_3P_TeamScore", player.GetTeam(), player )
	
	MessageToTeam( GetOtherTeam( player.GetTeam() ), eEventNotifications.PlayerCapturedFriendlyFlag, player, player )
	EmitSoundOnEntityToTeam( flag, "UI_CTF_3P_EnemyScore", flag.GetTeam() )
	
	if ( GameRules_GetTeamScore( player.GetTeam() ) == GameMode_GetRoundScoreLimit( GAMETYPE ) - 1 )
	{
		PlayFactionDialogueToTeam( "ctf_notifyWin1more", player.GetTeam() )
		PlayFactionDialogueToTeam( "ctf_notifyLose1more", GetOtherTeam( player.GetTeam() ) )
	}
}

void function Flag_DroppedByPlayer( entity player )
{
	entity flag = GetFlagForTeam( GetOtherTeam( player.GetTeam() ) )
	
	if ( flag.GetParent() != player )
	{
		print( "flag.GetParent() != player in Flag_DroppedByPlayer?????" )
		return
	}

	// drop the flag
	flag.ClearParent()
	flag.SetAngles( < 0, 0, 0 > )
	flag.SetVelocity( < 0, 0, 0 > )
	flag.s.returnTrigger.Enable()
	
	// start drop timeout countdown
	thread TrackFlagDropTimeout( flag )
	
	// do capture assists
	file.captureAssists[ player.GetTeam() ].append( player )
	
	// do notifs
	MessageToPlayer( player, eEventNotifications.YouDroppedTheEnemyFlag )
	EmitSoundOnEntityOnlyToPlayer( player, player, "UI_CTF_1P_FlagDrop" )
	
	MessageToTeam( player.GetTeam(), eEventNotifications.PlayerDroppedEnemyFlag, player, player )
	// todo need a sound here maybe
	
	MessageToTeam( GetOtherTeam( player.GetTeam() ), eEventNotifications.PlayerDroppedFriendlyFlag, player, player )
	// todo need a sound here maybe
	
	// set flag state
	SetFlagStateForTeam( flag.GetTeam(), eFlagState.Home ) // used for return prompt
	flag.Signal( "FlagDropped" )
}

// flag trigger funcs
void function OnPlayerEntersFlagReturnTrigger( entity trigger, entity player )
{
	entity flag = GetFlagForTeam( trigger.GetTeam() )
	
	if ( !PlayerCanInteractWithFlag( player ) || player.GetTeam() != flag.GetTeam() || IsFlagHome( flag ) )
		return
	
	thread PlayerTriesToReturnFlag( player, flag )
}

void function OnPlayerExitsFlagReturnTrigger( entity trigger, entity player )
{
	// no point in checking validity here, fire and forget
	player.Signal( "PlayerFlagReturnOver" )
}


// player funcs
void function InitCTFPlayer( entity player )
{
	if ( !GameHasFlags() )
		return
	
	vector imcSpawn = GetFlagSpawnOriginForTeam( TEAM_IMC )
	Remote_CallFunction_NonReplay( player, "ServerCallback_SetFlagHomeOrigin", TEAM_IMC, imcSpawn.x, imcSpawn.y, imcSpawn.z )
	
	vector militiaSpawn = GetFlagSpawnOriginForTeam( TEAM_MILITIA )
	Remote_CallFunction_NonReplay( player, "ServerCallback_SetFlagHomeOrigin", TEAM_MILITIA, militiaSpawn.x, militiaSpawn.y, militiaSpawn.z )
}

void function OnPlayerKilled( entity victim, entity attacker, var damageInfo )
{
	if ( !GameHasFlags() )
		return
	
	if ( PlayerHasEnemyFlag( victim ) )
	{
		if ( victim != attacker && attacker.IsPlayer() )
			AddPlayerScore( attacker, "FlagCarrierKill", victim )
		
		Flag_DroppedByPlayer( victim )
	}
}


// gamestate funcs
void function CTFStartGame()
{
	// setup stuff for the functions in shared gamemode scripts
	// have to do this here so GameHasFlags() works fine
	level.teamFlags <- {}

	int team = TEAM_IMC
	for ( int i = 0; i < CTF_TEAMCOUNT; i++, team++ )
	{
		int spawnTeam = HasSwitchedSides() ? GetOtherTeam( team ) : team
		
		// create flag base
		entity flagBase = CreatePropDynamic( CTF_FLAG_BASE_MODEL, svGlobal.flagSpawnPoints[ team ].GetOrigin(), svGlobal.flagSpawnPoints[ team ].GetAngles(), 0 )
		SetTeam( flagBase, spawnTeam )
		
		// create the flag's return trigger
		entity flagReturnTrigger = CreateEntity( "trigger_cylinder" )
		SetTeam( flagReturnTrigger, spawnTeam )
		
		flagReturnTrigger.SetRadius( CTF_GetFlagReturnRadius() )
		flagReturnTrigger.SetAboveHeight( CTF_GetFlagReturnRadius() )
		flagReturnTrigger.SetBelowHeight( CTF_GetFlagReturnRadius() )
		
		flagReturnTrigger.SetEnterCallback( OnPlayerEntersFlagReturnTrigger )
		flagReturnTrigger.SetLeaveCallback( OnPlayerExitsFlagReturnTrigger )
		DispatchSpawn( flagReturnTrigger )
		flagReturnTrigger.Enable()

		// create actual flag ent
		entity flag = CreateEntity( "item_flag" )
		flag.SetValueForModelKey( CTF_FLAG_MODEL )
		flag.MarkAsNonMovingAttachment()
		SetTeam( flag, spawnTeam )
		DispatchSpawn( flag )
		flag.SetModel( CTF_FLAG_MODEL )
		
		flag.s.base <- flagBase
		flag.s.returnTrigger <- flagReturnTrigger
		level.teamFlags[ spawnTeam ] <- flag
		Flag_Reset( flag, false )
		thread FlagLifetime( flag )
		
		// init and clear assists
		file.captureAssists[ team ] <- []
		
		SetGlobalNetEnt( team == TEAM_IMC ? "imcFlagHome" : "milFlagHome", flagBase )
		SetFlagStateForTeam( spawnTeam, eFlagState.None )
	}
	
	// init all players
	foreach ( entity player in GetPlayerArray() )
		InitCTFPlayer( player )
	
	// start the game thread
	thread CTFGamePlaying()
}

void function CTFGamePlaying()
{
	// wait for game to start
	while ( !GamePlayingOrSuddenDeath() )
		svGlobal.levelEnt.WaitSignal( "GameStateChanged" )
	
	OnThreadEnd( function() : () 
	{
		if ( GameHasFlags() )
		{
			int team = TEAM_IMC
			for ( int i = 0; i < CTF_TEAMCOUNT; i++, team++ )
			{
				entity flag = GetFlagForTeam( team )
			
				// clean up both team's flags
				flag.s.returnTrigger.Destroy()
				flag.s.base.Destroy()
				flag.Destroy()
			}
			
			// delete level.teamFlags so GameHasFlags() == false
			delete level.teamFlags
		}
	})
	
	// wait for game to end
	while ( GamePlayingOrSuddenDeath() )
		svGlobal.levelEnt.WaitSignal( "GameStateChanged" )
}