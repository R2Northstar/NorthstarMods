global function GamemodePilot_Init


void function GamemodePilot_Init()
{
	SetShouldUseRoundWinningKillReplay( true )
	SetLoadoutGracePeriodEnabled( false ) // prevent modifying loadouts with grace period
	SetWeaponDropsEnabled( false )
	SetRespawnsEnabled( false )
	Riff_ForceTitanAvailability( eTitanAvailability.Never )
	Riff_ForceBoostAvailability( eBoostAvailability.Disabled )
	Riff_ForceSetEliminationMode( eEliminationMode.Pilots )

	ClassicMP_SetCustomIntro( ClassicMP_DefaultNoIntro_Setup, ClassicMP_DefaultNoIntro_GetLength() )
	ClassicMP_ForceDisableEpilogue( true )

	AddCallback_OnClientConnected( PilotInitPlayer )
	AddCallback_OnPlayerKilled( PilotOnPlayerKilled )
	AddCallback_GameStateEnter( eGameState.Playing, SelectFirstPilot )
	AddCallback_GameStateEnter( eGameState.Postmatch, RemovePilot )
	SetTimeoutWinnerDecisionFunc( TimeoutCheckSurvivors )
	

	thread PredatorMain()

}

void function PilotInitPlayer( entity player )
{
	SetTeam( player, TEAM_MILITIA )
	AddEntityCallback_OnDamaged( player, CheckHealth )
}

void function SelectFirstPilot()
{
	thread SelectFirstPilotDelayed()
}

void function SelectFirstPilotDelayed()
{
	wait 8.0 + RandomFloat( 8.0 )

	array<entity> players = GetPlayerArray()
	entity Pilot = players[ RandomInt( players.len() ) ]

	if (Pilot != null || IsAlive(Pilot))
		MakePlayerPilot( Pilot ) // randomly selected player becomes Pilot

	foreach ( entity otherPlayer in GetPlayerArray() )
			if ( Pilot != otherPlayer )
				Remote_CallFunction_NonReplay( otherPlayer, "ServerCallback_AnnouncePilot", Pilot.GetEncodedEHandle() )

	PlayMusicToAll( eMusicPieceID.GAMEMODE_1 )

	thread UpdateSurvivorsLoadout()
}

void function UpdateSurvivorsLoadout()
{
	foreach (entity player in GetPlayerArray())
	{	

		if (player.GetTeam() != TEAM_MILITIA || !IsAlive(player) || player == null)
			continue;
		
		player.SetPlayerSettingsWithMods( player.GetPlayerSettings(), [ "disable_wallrun", "disable_doublejump"])

		foreach ( entity weapon in player.GetMainWeapons() )
			player.TakeWeaponNow( weapon.GetWeaponClassName() )

		foreach ( entity weapon in player.GetOffhandWeapons() )
			player.TakeWeaponNow( weapon.GetWeaponClassName() )

		try {
			player.GiveWeapon( "mp_weapon_rspn101")
			player.GiveOffhandWeapon("mp_weapon_grenade_emp", OFFHAND_ORDNANCE )
			player.GiveOffhandWeapon( "mp_weapon_semipistol", OFFHAND_RIGHT )
		} catch (ex) {}
	}
}

void function MakePlayerPilot(entity player)
{
	if (player == null)
		return;

	SetTeam( player, TEAM_IMC )
	player.SetPlayerGameStat( PGS_ASSAULT_SCORE, 0 ) // reset kills
	RespawnPilot( player )
	Remote_CallFunction_NonReplay( player, "ServerCallback_YouArePilot" )
}

void function RespawnPilot(entity player)
{
	if (player.GetTeam() != TEAM_IMC )
		return

	// scale health of the Pilot, with 50 as base health
	player.SetMaxHealth( 100 + ( (GetPlayerArrayOfTeam( TEAM_MILITIA ).len() + 1 ) * 30) )
	player.SetHealth( 100 + ( (GetPlayerArrayOfTeam( TEAM_MILITIA ).len() + 1 ) * 30) )

	print(player.GetMaxHealth())

	if ( !player.IsMechanical() )
		player.SetBodygroup( player.FindBodyGroup( "head" ), 1 )

	// set loadout
	foreach ( entity weapon in player.GetMainWeapons() )
		player.TakeWeaponNow( weapon.GetWeaponClassName() )

	foreach ( entity weapon in player.GetOffhandWeapons() )
		player.TakeWeaponNow( weapon.GetWeaponClassName() )

	player.GiveWeapon("mp_weapon_wingman_n")
	player.GiveOffhandWeapon( "melee_pilot_emptyhanded", OFFHAND_MELEE )
	player.GiveOffhandWeapon( "mp_weapon_grenade_sonar", OFFHAND_SPECIAL )
	player.GiveOffhandWeapon( "mp_ability_grapple", OFFHAND_RIGHT )
	thread UpdateLoadout(player)
	thread GiveArcGrenade(player)
}

void function GiveArcGrenade(entity player)
{
	wait 45.0
	if (IsAlive(player) && player != null && player.GetTeam() != TEAM_IMC )
		player.GiveOffhandWeapon( "mp_weapon_grenade_emp", OFFHAND_ORDNANCE );
}

void function PilotOnPlayerKilled( entity victim, entity attacker, var damageInfo )
{
	if ( !victim.IsPlayer() || GetGameState() != eGameState.Playing )
		return

	if ( attacker.IsPlayer() )
	{
		// increase kills by 1
		attacker.SetPlayerGameStat( PGS_ASSAULT_SCORE, attacker.GetPlayerGameStat( PGS_ASSAULT_SCORE ) + 1 )
	}

}

void function UpdateLoadout( entity player )
{
	string smart = "mp_weapon_wingman_n"
	foreach ( entity weapon in player.GetMainWeapons() )
	{
		if (weapon.GetWeaponClassName() == smart)
		{
       		weapon.SetWeaponPrimaryAmmoCount(0)
        	weapon.SetWeaponPrimaryClipCount(0)
		}
	}
	WaitFrame()
	if ( IsValid( player ) )
		PlayerEarnMeter_SetMode( player, eEarnMeterMode.DISABLED )
}

void function RemovePilot()
{
	foreach (entity player in GetPlayerArray())
	{
		if (player.GetTeam() == TEAM_IMC && player != null)
			player.kv.VisibilityFlags = ENTITY_VISIBLE_TO_EVERYONE
	}
}

void function PredatorMain()
{
	while (true) 
	{
		WaitFrame()
		if(!IsLobby())
		{
			foreach (entity player in GetPlayerArray())
			{
				if (player == null || !IsValid(player) || !IsAlive(player) || player.GetTeam() != TEAM_IMC)
					continue
				vector playerVelV = player.GetVelocity()
				float playerVel
				playerVel = sqrt(playerVelV.x * playerVelV.x + playerVelV.y * playerVelV.y + playerVelV.z * playerVelV.z)
				float playerVelNormal = playerVel * 0.068544
				if (playerVel/300 < 1.3)
				{
					player.SetCloakFlicker(0, 0)
					player.kv.VisibilityFlags = 0
				}
				else
				{
					player.SetCloakFlicker(0.2 , 1 )
					player.kv.VisibilityFlags = 0
					float waittime = RandomFloat(0.5)
					wait waittime
					player.kv.VisibilityFlags = ENTITY_VISIBLE_TO_EVERYONE
				}
			}
			foreach (entity player in GetPlayerArray())
			{
				if (player.GetTeam() != TEAM_IMC || player == null || player.PlayerMelee_GetState() == PLAYER_MELEE_STATE_NONE)
					continue
				player.SetCloakFlicker(0.2 , 1 )
				player.kv.VisibilityFlags = 0
				float waittime = RandomFloat(0.5)
				wait waittime
				player.kv.VisibilityFlags = ENTITY_VISIBLE_TO_EVERYONE
			}
		}
	}
}

void function CheckHealth(entity player, var damageInfo)
{
	foreach (entity player in GetPlayerArray())
	{
		if (player.GetTeam() != TEAM_IMC || player == null || player.GetMaxHealth() == 50)
			continue

		float maxHealthCap = 50

    	float damage = DamageInfo_GetDamage( damageInfo )
   		float newMaxHealth = player.GetMaxHealth() - damage

    	player.SetMaxHealth( max( maxHealthCap, newMaxHealth ) )
		print(player.GetMaxHealth())
	}
}

int function TimeoutCheckSurvivors()
{
	if ( GetPlayerArrayOfTeam( TEAM_MILITIA ).len() > 0 )
		return TEAM_IMC

	return TEAM_MILITIA
}
