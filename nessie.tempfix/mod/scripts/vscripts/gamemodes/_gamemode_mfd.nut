untyped
global function GamemodeMfd_Init

global function Modded_Gamemode_Zombie_Mfd_Init

struct {
	entity imcLastMark
	entity militiaLastMark
	bool isMfdPro

	bool isZombieMfd = false
	float zombieHealthRegenDelay = 1.0
	float zombieHealthRegenRate = 50
} file

void function Modded_Gamemode_Zombie_Mfd_Init()
{
	file.isZombieMfd = true
}

void function GamemodeMfd_Init()
{
	GamemodeMfdShared_Init()
		
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

	if( file.isZombieMfd )
	{
		RegisterSignal( "StartZombieSounds" )
		RegisterSignal( "EndZombieSounds" )
		RegisterSignal( "ZMfdHealthRegenThink" )
		AddCallback_OnClientConnected( SetupZMFDPlayer )
		AddCallback_GameStateEnter( eGameState.Prematch, SetupZMfdIntro )
		SetPlayerDeathsHidden( true ) // no sounds for deaths
		SetWeaponDropsEnabled( false )
		SetLoadoutGracePeriodEnabled( false )
		AddCallback_OnPlayerRespawned( SetupZombieLoadoutForRespawn ) // don't use GetsNewPilotLoadout() since we need it to give VIPs loadout
		AddCallback_GameStateEnter( eGameState.Playing, SetupZombieLoadoutForIntro )
	}
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

	if( file.isZombieMfd )
	{
		foreach ( entity player in GetPlayerArray() )
		{
			if( player == imcMark || player == militiaMark )
				MakePlayerVIP( player )
		}
	}
		
	// wait until mark dies
	entity deadMark = expect entity( svGlobal.levelEnt.WaitSignal( "MarkKilled" ).mark )
	
	// award points
	entity livingMark = GetMarked( GetOtherTeam( deadMark.GetTeam() ) )
	livingMark.SetPlayerGameStat( PGS_DEFENSE_SCORE, livingMark.GetPlayerGameStat( PGS_DEFENSE_SCORE ) + 1 )
	PlayFactionDialogueToTeamExceptPlayer( "mfd_markDownEnemy", livingMark.GetTeam(), livingMark )
	PlayFactionDialogueToTeam( "mfd_markDownFriendly", deadMark.GetTeam() )
	PlayFactionDialogueToPlayer( "mfd_youOutlastedEnemy", livingMark )
	if( file.isZombieMfd )
	{
		if( IsAlive( livingMark ) )
			MakePlayerZombie( livingMark )
	}

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
		svGlobal.levelEnt.Signal( "MarkKilled", { mark = victim } )
		
		if ( attacker.IsPlayer() )
		{
			PlayFactionDialogueToPlayer( "mfd_youKilledMark", attacker )
			attacker.SetPlayerGameStat( PGS_ASSAULT_SCORE, attacker.GetPlayerGameStat( PGS_ASSAULT_SCORE ) + 1 )
		}
	}
}

// zombie mfd
void function SetupZMFDPlayer( entity player )
{
	player.s.isZombie <- false
	player.s.damagedHealth <- 0
	AddEntityCallback_OnDamaged( player, OnZMfdPlayerDamaged )
	SendModeRulesToPlayer( player )
}

void function SetupZombieLoadoutForRespawn( entity player )
{
	if( GetGameState() == eGameState.Prematch )
		return
	SetupZombieLoadout( player )
}

void function SetupZombieLoadout( entity player )
{
	thread DisableBoostBar( player )
	MakePlayerZombie( player )
	player.Signal( "StopHealthRegenThink" )
	thread ZMfdHealthRegenThink( player )
}

void function SetupZombieLoadoutForIntro()
{
	foreach( entity player in GetPlayerArray() )
	{
		if( IsAlive( player ) )
			SetupZombieLoadout( player )
	}
}

void function MakePlayerVIP( entity player )
{
	player.s.isZombie = false // for health regen
	player.s.damagedHealth = 0
	EndlessStimEnd( player ) // stop stim
	player.Signal( "EndZombieSounds" )
	Loadouts_TryGivePilotLoadout( player )
	player.TakeWeaponNow( player.GetOffhandWeapon( OFFHAND_MELEE ).GetWeaponClassName() )
	thread GiveAirAccel( player, 500 )

	// set camo to white
	player.SetSkin( 1 )
	player.SetCamo( 31 )

	player.SetMaxHealth( 100 )
	player.SetHealth( 100 )
}

void function MakePlayerZombie( entity player )
{
	player.s.isZombie = true // for health regen
	player.s.damagedHealth = 0
	// set camo to pond scum
	player.SetSkin( 1 )
	player.SetCamo( 110 )

	// if human, remove helmet bodygroup, human models have some weird bloody white thing underneath their helmet that works well for this, imo
	if ( !player.IsMechanical() )
		player.SetBodygroup( player.FindBodyGroup( "head" ), 1 )

	// stats for infected
	EndlessStimBegin( player, 0.25 )
	thread DelayedClearStimSound( player )

	player.SetMaxHealth( 50 )
	player.SetHealth( 50 )

	// set loadout
	foreach ( entity weapon in player.GetMainWeapons() )
		player.TakeWeaponNow( weapon.GetWeaponClassName() )

	foreach ( entity weapon in player.GetOffhandWeapons() )
		player.TakeWeaponNow( weapon.GetWeaponClassName() )

	// TEMP: give archer so player so player has a weapon which lets them use offhands
	// need to replace this with a custom empty weapon at some point
	//player.GiveWeapon( "mp_weapon_rocket_launcher" )
	player.GiveWeapon( "mp_weapon_gunship_missile", ["melee_convertor"] )
	player.GiveOffhandWeapon( "melee_pilot_emptyhanded", OFFHAND_MELEE, ["apex_melee", "zombie_craw"] )
	player.GiveOffhandWeapon( "mp_weapon_grenade_sonar", OFFHAND_SPECIAL, ["kunai", "zombie_knife"] )
	//player.GiveOffhandWeapon( "mp_weapon_grenade_gravity", OFFHAND_ORDNANCE, ["shuriken"] )
	player.GiveOffhandWeapon( "mp_weapon_grenade_emp", OFFHAND_ORDNANCE, ["impulse_grenade"] )

	thread GiveAirAccel( player, 1000 )
	thread PlayInfectedSounds( player )
}

void function DelayedClearStimSound( entity player )
{
	wait 0.1
	if( IsValid( player ) )
	{
		StopSoundOnEntity( player, "pilot_stimpack_loop_1P" ) // better don't use this, this will turn up all volumes
		StopSoundOnEntity( player, "pilot_stimpack_loop_3P" )
	}
}

void function GiveAirAccel( entity player, float amount )
{
	WaitFrame()
	if( IsValid( player ) )
		player.kv.airAcceleration = amount
}

void function PlayInfectedSounds( entity player )
{
	player.Signal( "StartZombieSounds" )
	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "StartZombieSounds" )
	player.EndSignal( "EndZombieSounds" )

	float nextRandomSound
	while ( true )
	{
		wait max( 2.5, RandomFloat( 12.0 ) ) // wait goes first so player won't hear this till they able to running around
		string selectedSound
		if ( CoinFlip() )
			selectedSound = "prowler_vocal_attack"
		else
			selectedSound = "prowler_vocal_attackmiss"

		bool canSeeEnemy
		foreach ( entity survivor in GetPlayerArrayOfEnemies_Alive( player.GetTeam() ) )
			if ( TraceLineSimple( player.GetOrigin(), survivor.GetOrigin(), survivor ) == 1.0 )
				canSeeEnemy = true

		// _int sounds are less agressive so only play them if we aren't in some sorta fight
		if ( player.GetHealth() == player.GetMaxHealth() || !canSeeEnemy )
			selectedSound += "_int"

		EmitSoundOnEntity( player, selectedSound )
	}
}

void function OnZMfdPlayerDamaged( entity victim, var damageInfo )
{
	entity attacker = DamageInfo_GetAttacker( damageInfo )
	if( IsValid( attacker ) )
	{
		if( attacker.IsPlayer() )
		{
			if( attacker.s.isZombie && !victim.s.isZombie && attacker != victim )
				victim.s.damagedHealth += DamageInfo_GetDamage( damageInfo )
			else if( attacker.s.isZombie && victim.s.isZombie && DamageInfo_GetDamage( damageInfo ) >= 20 ) // hardcoded for now
				DamageInfo_SetDamage( damageInfo, 999 ) // melee or knives instant kills a zombie
		}
	}
}

void function ZMfdHealthRegenThink( entity player )
{
	player.EndSignal( "OnDestroy" )
	player.Signal( "ZMfdHealthRegenThink" )
	player.EndSignal( "ZMfdHealthRegenThink" )
	player.EndSignal( "StopHealthRegenThink" ) // modify for having different health regen function for each player

	while ( IsValid( player ) )
	{
		wait( HEALTH_REGEN_TICK_TIME )

		if ( !IsAlive( player ) )
			continue

		if ( !IsPilot( player ) )
			continue

		if ( shGlobal.proto_pilotHealthRegenDisabled )
			continue

		float healthRegenStartDelay = 2.5
		if( player.s.isZombie )
			healthRegenStartDelay = file.zombieHealthRegenDelay

		float healthRegenRate = 6.0 	// health regen per tick
		if( player.s.isZombie )
			healthRegenRate = file.zombieHealthRegenRate

		if ( player.GetHealth() == player.GetMaxHealth() - player.s.damagedHealth )
			continue

		// No regen during phase shift
		if ( player.IsPhaseShifted() )
			continue

		else if ( Time() - player.p.lastDamageTime < healthRegenStartDelay )
		{
			continue
		}

		player.SetHealth( min( player.GetMaxHealth() - player.s.damagedHealth, player.GetHealth() + healthRegenRate ) )
		
		if ( player.GetHealth() == player.GetMaxHealth() )
		{
			ClearRecentDamageHistory( player )
			ClearLastAttacker( player )
		}
	}
}

void function DisableBoostBar( entity player )
{
	WaitFrame()
	if( IsValid( player ) )
		PlayerEarnMeter_SetMode( player, eEarnMeterMode.DISABLED )
}

void function SetupZMfdIntro()
{
	SendModeRulesToAllPlayers()
	foreach( entity player in GetPlayerArray() )
	{
		StopSoundOnEntity( player, "music_mp_mfd_intro_flyin" )
		EmitSoundOnEntityOnlyToPlayer( player, player, "music_beacon_8a_jumpingsuccess" )
	}
}

void function SendModeRulesToAllPlayers()
{
	foreach( entity player in GetPlayerArray() )
		SendModeRulesToPlayer( player )
}

void function SendModeRulesToPlayer( entity player )
{
	thread SendModeRulesToPlayer_Threaded( player )
}

void function SendModeRulesToPlayer_Threaded( entity player )
{
	wait 1
	if( IsValid( player ) )
		SendHudMessage( player, "僵尸猎杀标记:\n只有被标记者为人类玩家, 其余玩家作为僵尸配合人类尝试消灭敌方标记", -1, 0.35, 255, 200, 0, 0, 0.15, 10, 0.15 )
}