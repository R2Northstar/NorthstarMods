untyped
global function GamemodeMfd_Init

struct {
	entity imcLastMark
	entity militiaLastMark
	bool isMfdPro
} file

void function GamemodeMfd_Init()
{
	GamemodeMfdShared_Init()
		
	SetShouldPlayDefaultMusic( false )

	RegisterSignal( "MarkKilled" )
	ScoreEvent_SetupEarnMeterValuesForMixedModes()
	
	// todo
	if ( GAMETYPE == MARKED_FOR_DEATH_PRO )
	{
		file.isMfdPro = true
		SetRespawnsEnabled( true )
		SetRoundBased( true )
		SetShouldUseRoundWinningKillReplay( true )
		Riff_ForceSetEliminationMode( eEliminationMode.Pilots )
	}
	
	AddCallback_OnClientConnected( SetupMFDPlayer )
	AddCallback_OnPlayerKilled( UpdateMarksForKill )
	AddCallback_GameStateEnter( eGameState.Playing, CreateInitialMarks )
}

void function SetupMFDPlayer( entity player )
{
	player.s.roundsSincePicked <- 0
}

void function CreateInitialMarks()
{
	entity imcMark = CreateEntity( MARKER_ENT_CLASSNAME )
	imcMark.kv.spawnflags = SF_INFOTARGET_ALWAYS_TRANSMIT_TO_CLIENT
	SetTeam( imcMark, TEAM_IMC )
	SetTargetName( imcMark, MARKET_ENT_MARKED_NAME ) // why is it market_ent lol
	DispatchSpawn( imcMark )
	FillMFDMarkers( imcMark )
	
	entity imcPendingMark = CreateEntity( MARKER_ENT_CLASSNAME )
	imcPendingMark.kv.spawnflags = SF_INFOTARGET_ALWAYS_TRANSMIT_TO_CLIENT
	SetTeam( imcPendingMark, TEAM_IMC )
	SetTargetName( imcPendingMark, MARKET_ENT_PENDING_MARKED_NAME )
	DispatchSpawn( imcPendingMark )
	FillMFDMarkers( imcPendingMark )
	
	entity militiaMark = CreateEntity( MARKER_ENT_CLASSNAME )
	militiaMark.kv.spawnflags = SF_INFOTARGET_ALWAYS_TRANSMIT_TO_CLIENT
	SetTeam( militiaMark, TEAM_MILITIA )
	SetTargetName( militiaMark, MARKET_ENT_MARKED_NAME )
	DispatchSpawn( militiaMark )
	FillMFDMarkers( militiaMark )
	
	entity militiaPendingMark = CreateEntity( MARKER_ENT_CLASSNAME )
	militiaPendingMark.kv.spawnflags = SF_INFOTARGET_ALWAYS_TRANSMIT_TO_CLIENT
	SetTeam( militiaPendingMark, TEAM_MILITIA )
	SetTargetName( militiaPendingMark, MARKET_ENT_PENDING_MARKED_NAME )
	DispatchSpawn( militiaPendingMark )
	FillMFDMarkers( militiaPendingMark )

	thread MFDThink()
}

void function MFDThink()
{
	svGlobal.levelEnt.EndSignal( "GameStateChanged" )
	
	entity imcMark
	entity militiaMark
	
	while ( true )
	{	
		if ( !TargetsMarkedImmediately() )
			wait MFD_BETWEEN_MARKS_TIME
	
		// wait for enough players to spawn
		while ( GetPlayerArrayOfTeam( TEAM_IMC ).len() == 0 || GetPlayerArrayOfTeam( TEAM_MILITIA ).len() == 0 )
			WaitFrame()
		
		imcMark = PickTeamMark( TEAM_IMC )
		militiaMark = PickTeamMark( TEAM_MILITIA )
		
		level.mfdPendingMarkedPlayerEnt[ TEAM_IMC ].SetOwner( imcMark )
		level.mfdPendingMarkedPlayerEnt[ TEAM_MILITIA ].SetOwner( militiaMark )
		
		foreach ( entity player in GetPlayerArray() )
		{
			Remote_CallFunction_NonReplay( player, "SCB_MarkedChanged" )
			Remote_CallFunction_NonReplay( player, "ServerCallback_MFD_StartNewMarkCountdown", Time() + MFD_COUNTDOWN_TIME )
			PlayFactionDialogueToPlayer( "mfd_markCountdown", player )
		}
		
		// reset if mark leaves
		bool shouldReset
		float endTime = Time() + MFD_COUNTDOWN_TIME
		while ( endTime > Time() || ( !IsAlive( imcMark ) || !IsAlive( militiaMark ) ) )
		{
			if ( !IsValid( imcMark ) || !IsValid( militiaMark ) )
			{
				shouldReset = true
				MessageToAll( eEventNotifications.MarkedForDeathMarkedDisconnected )
				break
			}
				
			WaitFrame()
		}
		
		if ( shouldReset )
			continue
		
		waitthread MarkPlayers( imcMark, militiaMark )
	}
}

entity function PickTeamMark( int team )
{
	array<entity> possibleMarks

	int maxRounds
	foreach ( entity player in GetPlayerArrayOfTeam( team ) )
	{
		if ( maxRounds < player.s.roundsSincePicked )
		{
			maxRounds = expect int( player.s.roundsSincePicked )
			possibleMarks = [ player ]
		}
		else if ( maxRounds == player.s.roundsSincePicked )
			possibleMarks.append( player )
	}
	
	entity mark = possibleMarks.getrandom()
	foreach ( entity player in GetPlayerArrayOfTeam( team ) )
		if ( player != mark )
			player.s.roundsSincePicked++
	
	return mark
}

void function MarkPlayers( entity imcMark, entity militiaMark )
{
	imcMark.EndSignal( "OnDestroy" )
	imcMark.EndSignal( "Disconnected" )
	
	militiaMark.EndSignal( "OnDestroy" )
	militiaMark.EndSignal( "Disconnected" )
	
	OnThreadEnd( function() : ( imcMark, militiaMark ) 
	{
		// clear marks
		level.mfdActiveMarkedPlayerEnt[ TEAM_IMC ].SetOwner( null )
		level.mfdActiveMarkedPlayerEnt[ TEAM_MILITIA ].SetOwner( null )
		imcMark.Minimap_Hide( TEAM_MILITIA, null )
		militiaMark.Minimap_Hide( TEAM_IMC, null )

		if( !IsValid( imcMark ) || !IsValid( militiaMark ) ) // considering this as disconnected
			MessageToAll( eEventNotifications.MarkedForDeathMarkedDisconnected )
		foreach ( entity player in GetPlayerArray() )
			Remote_CallFunction_NonReplay( player, "SCB_MarkedChanged" )
	})
	
	// clear pending marks
	level.mfdPendingMarkedPlayerEnt[ TEAM_IMC ].SetOwner( null )
	level.mfdPendingMarkedPlayerEnt[ TEAM_MILITIA ].SetOwner( null )
	
	// set marks
	level.mfdActiveMarkedPlayerEnt[ TEAM_IMC ].SetOwner( imcMark )
	level.mfdActiveMarkedPlayerEnt[ TEAM_MILITIA ].SetOwner( militiaMark )
	AddPlayerScore( imcMark, "MFDMarked", imcMark )
	AddPlayerScore( militiaMark, "MFDMarked", militiaMark )
	imcMark.Minimap_AlwaysShow( TEAM_MILITIA, null )
	militiaMark.Minimap_AlwaysShow( TEAM_IMC, null )

	string dialogueName = "mfd_targetsMarkedLong"
	if( CoinFlip() )
		dialogueName = "mfd_targetsMarkedShort"

	PlayFactionDialogueToTeamExceptPlayer( dialogueName, TEAM_IMC, imcMark )
	PlayFactionDialogueToPlayer( "mfd_youAreMarked", imcMark )
	PlayFactionDialogueToTeamExceptPlayer( dialogueName, TEAM_MILITIA, militiaMark )
	PlayFactionDialogueToPlayer( "mfd_youAreMarked", militiaMark )
	
	foreach ( entity player in GetPlayerArray() )
		Remote_CallFunction_NonReplay( player, "SCB_MarkedChanged" )
		
	// wait until mark dies
	table result = svGlobal.levelEnt.WaitSignal( "MarkKilled" )
	entity deadMark = expect entity( result.mark )
	entity markKiller = expect entity( result.killer )

	// award points
	entity livingMark = GetMarked( GetOtherTeam( deadMark.GetTeam() ) )
	livingMark.SetPlayerGameStat( PGS_DEFENSE_SCORE, livingMark.GetPlayerGameStat( PGS_DEFENSE_SCORE ) + 1 )
	
	// score events and dialogues
	// friendlies
	PlayFactionDialogueToTeamExceptPlayer( "mfd_markDownEnemy", livingMark.GetTeam(), livingMark )
	if( markKiller == livingMark ) // marked killed enemy mark!
	{
		AddPlayerScore( livingMark, "MarkedKilledMarked", livingMark )
	}
	else
	{
		//AddPlayerScore( livingMark, "MarkedSurvival" )
		AddPlayerScore( livingMark, "MarkedOutlastedEnemyMarked", livingMark )
		PlayFactionDialogueToPlayer( "mfd_youOutlastedEnemy", livingMark )
	}
	// enemies
	PlayFactionDialogueToTeam( "mfd_markDownFriendly", deadMark.GetTeam() )

	// thread this so we don't kill our own thread
	thread AddTeamScore( livingMark.GetTeam(), 1 )
}

void function UpdateMarksForKill( entity victim, entity attacker, var damageInfo )
{
	if ( victim == GetMarked( victim.GetTeam() ) )
	{
		if( attacker.IsNPC() || attacker.IsPlayer() ) // sometimes worldSpawn killing a mark will crash all clients, since wolrdSpawn entity don't have a .GetPlayerName() function
		{
			if( victim.GetParent() != null ) // when victim having a parent, client code sometimes get their's parent's .GetPlayerName() and It will cause a crash if parent not proper entity!
				victim.ClearParent()
			MessageToAll( eEventNotifications.MarkedForDeathKill, null, victim, attacker.GetEncodedEHandle() )
		}
		svGlobal.levelEnt.Signal( "MarkKilled", { mark = victim, killer = attacker } )
		
		if ( attacker.IsPlayer() )
		{
			if( GetMarked( attacker.GetTeam() ) != attacker ) // if marked killed marked, it's handle in the upper function
				AddPlayerScore( attacker, "MarkedTargetKilled" )
			PlayFactionDialogueToPlayer( "mfd_youKilledMark", attacker )
			attacker.SetPlayerGameStat( PGS_ASSAULT_SCORE, attacker.GetPlayerGameStat( PGS_ASSAULT_SCORE ) + 1 )
		}
	}
	else
	{
		entity friendlyMark = GetMarked( attacker.GetTeam() )
		if( IsValid( friendlyMark ) )
		{
			if( Distance( friendlyMark, victim ) <= 750 ) // close enough! you saved the mark!
				AddPlayerScore( attacker, "MarkedEscort" )
		}
	}
}