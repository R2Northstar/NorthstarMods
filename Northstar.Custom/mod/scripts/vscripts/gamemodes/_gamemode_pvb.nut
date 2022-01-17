untyped
global function GamemodePVB_Init


void function GamemodePVB_Init()
{
	SetShouldUseRoundWinningKillReplay( true )
	SetLoadoutGracePeriodEnabled( false ) // prevent modifying loadouts with grace period
	SetWeaponDropsEnabled( false )
	SetRespawnsEnabled( true )
	SetKillcamsEnabled( false )
	Riff_ForceTitanAvailability( eTitanAvailability.Never )
	//Riff_ForceBoostAvailability( eBoostAvailability.Disabled )
	Riff_ForceSetEliminationMode( eEliminationMode.Pilots )

	ClassicMP_SetCustomIntro( ClassicMP_DefaultNoIntro_Setup, ClassicMP_DefaultNoIntro_GetLength() )
	ClassicMP_ForceDisableEpilogue( true )

	AddCallback_OnClientConnected( BossInitPlayer )
	AddCallback_OnPlayerKilled( BossOnPlayerKilled )
	AddCallback_GameStateEnter( eGameState.Playing, SelectFirstBoss )
	//AddCallback_GameStateEnter( eGameState.Postmatch, RemoveBoss )
	SetTimeoutWinnerDecisionFunc( TimeoutCheckBoss )
	TrackTitanDamageInPlayerGameStat( PGS_ASSAULT_SCORE )
}

void function BossInitPlayer( entity player )
{
	MakePlayer( player )
}

void function SelectFirstBoss()
{
	thread SelectFirstBossDelayed()
	thread SelectAmpedPlayer()
}

void function SelectAmpedPlayer()
{
	wait 10.0 + RandomFloat( 5.0 )
	array<entity> militia = GetPlayerArrayOfTeam( TEAM_MILITIA )
	if ( militia.len() == 0 )
		return
	entity ampd = militia[ RandomInt( militia.len() ) ]
	if (ampd != null || IsAlive(ampd))
		MakePlayerAmped( ampd )
	foreach ( entity otherPlayer in militia )
		if ( ampd != otherPlayer )
			Remote_CallFunction_NonReplay( otherPlayer, "ServerCallback_AnnounceAmped", ampd.GetEncodedEHandle() )
	foreach( entity player in GetPlayerArrayOfTeam( TEAM_IMC ))
		Remote_CallFunction_NonReplay( player, "ServerCallback_AnnounceAmpedToBoss", ampd.GetEncodedEHandle() )
}

void function SelectFirstBossDelayed()
{
	wait 5.0 + RandomFloat( 5.0 )

	array<entity> players = GetPlayerArray()
	entity boss = players[ RandomInt( players.len() ) ]

	if (boss != null || IsAlive(boss))
		MakePlayerBoss( boss )

	foreach( entity otherPlayer in GetPlayerArray() )
		if ( boss != otherPlayer )
			Remote_CallFunction_NonReplay( otherPlayer, "ServerCallback_AnnounceBoss", boss.GetEncodedEHandle() )

	PlayMusicToAll( eMusicPieceID.GAMEMODE_1 )
}

void function MakePlayerBoss(entity player)
{
	if (player == null)
		return;

	player.SetPlayerGameStat( PGS_ASSAULT_SCORE, 0 ) // reset kills
	RespawnBoss( player )
	Remote_CallFunction_NonReplay( player, "ServerCallback_YouAreBoss" )
}

void function MakePlayerAmped(entity player)
{
	if (player == null)
		return;

	player.SetPlayerGameStat( PGS_ASSAULT_SCORE, 0 ) // reset kills
	RespawnAmped( player )
	Remote_CallFunction_NonReplay( player, "ServerCallback_YouAreAmped" )
}

void function RespawnBoss(entity player)
{
	player.Die()
	SetTeam( player, TEAM_IMC )
	RespawnAsTitan( player, false )
	player.SetTitanDisembarkEnabled(false)
	player.SetMaxHealth(15000 * GetPlayerArray().len())
	player.SetHealth(15000 * GetPlayerArray().len())
}

void function RespawnAmped(entity player)
{
	//if ( GetPlayerArray().len() > 8 )
	//	SetTeam( player, TEAM_IMC )
	//if ( GetPlayerArray().len() > 14 )
	//	player.Die()
	//	wait 2.0
	//	RespawnAsTitan( player, false )
	//	wait 1.0
	foreach ( entity weapon in player.GetMainWeapons() )
		player.TakeWeaponNow( weapon.GetWeaponClassName() )
	player.GiveWeapon("mp_weapon_arena3")
	player.SetMaxHealth(500)
	player.SetHealth(500)
	Highlight_SetEnemyHighlight( player, "enemy_sonar" )
	StimPlayer( player, 9999.9 )
	player.kv.airAcceleration = 20000
}

void function MakePlayer( entity player )
{
	SetTeam( player, TEAM_MILITIA )
	player.SetPlayerGameStat( PGS_ASSAULT_SCORE, 0 ) // reset kills

	// check how many bosses there are
	//array<entity> bosses = GetPlayerArrayOfTeam( TEAM_IMC )
	foreach( entity player in GetPlayerArrayOfTeam( TEAM_IMC ))
		if ( (GameMode_GetTimeLimit( GAMETYPE ) * 60 ) - Time() < 30 )
			Highlight_SetEnemyHighlight( player, "enemy_sonar" )

	PlayMusicToAll( eMusicPieceID.GAMEMODE_1 )
}

void function BossOnPlayerKilled( entity victim, entity attacker, var damageInfo )
{
	if ( !victim.IsPlayer() || GetGameState() != eGameState.Playing )
		return

	if ( attacker.IsPlayer() )
	{
		// increase kills by 1
		attacker.SetPlayerGameStat( PGS_ASSAULT_SCORE, attacker.GetPlayerGameStat( PGS_ASSAULT_SCORE ) + 1 )
	}
	if ( victim.GetTeam() != TEAM_IMC )
		MakePlayer( victim )
}

int function TimeoutCheckBoss()
{
	if ( GetPlayerArrayOfTeam( TEAM_IMC ).len() > 0 )
	{
		SetRespawnsEnabled( false )
		SetRoundWinningKillReplayAttacker(GetPlayerArrayOfTeam( TEAM_IMC )[0])
		return TEAM_IMC
	}

	return TEAM_MILITIA
}
