global function SetTitanAsElite
global function SetEliteTitanPostSpawn
global function EliteTitanExecutionCheck
global function SetTitanWeaponSkin
global function EliteTitans_Init



/*
███████╗██╗     ██╗████████╗███████╗    ████████╗██╗████████╗ █████╗ ███╗   ██╗███████╗    ██╗      ██████╗  ██████╗ ██╗ ██████╗
██╔════╝██║     ██║╚══██╔══╝██╔════╝    ╚══██╔══╝██║╚══██╔══╝██╔══██╗████╗  ██║██╔════╝    ██║     ██╔═══██╗██╔════╝ ██║██╔════╝
█████╗  ██║     ██║   ██║   █████╗         ██║   ██║   ██║   ███████║██╔██╗ ██║███████╗    ██║     ██║   ██║██║  ███╗██║██║     
██╔══╝  ██║     ██║   ██║   ██╔══╝         ██║   ██║   ██║   ██╔══██║██║╚██╗██║╚════██║    ██║     ██║   ██║██║   ██║██║██║     
███████╗███████╗██║   ██║   ███████╗       ██║   ██║   ██║   ██║  ██║██║ ╚████║███████║    ███████╗╚██████╔╝╚██████╔╝██║╚██████╗
╚══════╝╚══════╝╚═╝   ╚═╝   ╚══════╝       ╚═╝   ╚═╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝    ╚══════╝ ╚═════╝  ╚═════╝ ╚═╝ ╚═════╝

This file handles most of the bulk required to make an NPC Titan become an Elite Titan, however some functions needs to be called when spawning in the
local script file (i.e SetSpawnOption_AISettings).
*/






void function EliteTitans_Init()
{
	AddOnRodeoStartedCallback( PilotStartRodeoOnEliteTitan )
	AddCallback_OnTitanDoomed( Elite_NuclearPayload_DoomCallback )
}

void function PilotStartRodeoOnEliteTitan( entity pilot, entity titan )
{
	if ( !PlayerHasPassive( pilot, ePassives.PAS_STEALTH_MOVEMENT ) )
	{
		if( titan.IsNPC() && titan.GetTeam() != pilot.GetTeam() )
		{
			if( titan.ai.bossTitanType == TITAN_MERC )
				thread EliteTitanElectricSmoke( titan )
		}
	}
}

void function EliteTitanExecutionCheck( entity ent, var damageInfo )
{
	int damageType = DamageInfo_GetCustomDamageType( damageInfo )
	entity attacker = DamageInfo_GetAttacker( damageInfo )

	if ( !IsAlive( ent ) || !attacker || ent.GetTeam() == attacker.GetTeam() || attacker == ent || !ent.IsTitan() )
		return
	
	entity soul = ent.GetTitanSoul()
	if( attacker.IsNPC() && attacker.IsTitan() )
	{
		if( IsValid( soul ) && attacker.ai.bossTitanType == TITAN_MERC && ( damageType & DF_MELEE ) )
		{
			if( CodeCallback_IsValidMeleeExecutionTarget( attacker, ent ) && !GetDoomedState( attacker ) ) //Doomed Elites cannot execute
			{
				//If the player is already doomed, then just execute, if the next melee damage brings it to Doom state, wait to execute
				if( GetDoomedState( ent ) && ( !SoulHasPassive( soul, ePassives.PAS_RONIN_AUTOSHIFT ) || !SoulHasPassive( soul, ePassives.PAS_AUTO_EJECT ) || !ent.IsPhaseShifted() ) )
				{
					thread PlayerTriesSyncedMelee( attacker, ent )
					ent.SetNoTarget( true ) //Prevents other nearby AI Titans from Moshing the victim
				}
				else
					thread EliteExecutionDelayed( attacker, ent ) //Execute in next frame
			}
		}
	}
}

void function EliteExecutionDelayed( entity attacker, entity ent )
{
	Assert( IsValid( attacker ) && attacker.IsTitan(), "Executioner is not an Elite Titan: " + attacker )
	attacker.EndSignal( "OnDestroy" )
	attacker.EndSignal( "OnDeath" )
	
	Assert( IsValid( ent ) && ent.IsTitan(), "Victim is not a Titan: " + ent )
	entity soul = ent.GetTitanSoul()
	
	soul.EndSignal( "OnDestroy" )
	soul.EndSignal( "OnDeath" )
	
	wait 0.1
	
	if( CodeCallback_IsValidMeleeExecutionTarget( attacker, ent ) && ent.IsTitan() && IsValid( soul ) && !GetDoomedState( attacker ) )
	{
		if( GetDoomedState( ent ) && ( !SoulHasPassive( soul, ePassives.PAS_RONIN_AUTOSHIFT ) || !SoulHasPassive( soul, ePassives.PAS_AUTO_EJECT ) || !ent.IsPhaseShifted() ) )
		{
			thread PlayerTriesSyncedMelee( attacker, ent )
			ent.SetNoTarget( true ) //Again, no Moshing against the victim
		}
	}
}

void function SetTitanAsElite( entity npc )
{
	if( GetGameState() != eGameState.Playing )
		return
	
	Assert( IsValid( npc ) && npc.IsTitan(), "Entity is not a Titan to set as Elite: " + npc )
	if ( npc.IsTitan() )
	{
		SetSpawnOption_NPCTitan( npc, TITAN_MERC )
		SetSpawnOption_TitanSoulPassive1( npc, "pas_enhanced_titan_ai" )
		SetSpawnOption_TitanSoulPassive2( npc, "pas_defensive_core" )
		SetSpawnOption_TitanSoulPassive3( npc, "pas_assault_reactor" )
		SetSpawnflags( npc, SF_TITAN_SOUL_NO_DOOMED_EVASSIVE_COMBAT )
	}
}

void function SetEliteTitanPostSpawn( entity npc )
{
	if( GetGameState() != eGameState.Playing )
		return
	
	Assert( IsValid( npc ) && npc.IsTitan(), "Entity is not a Titan to set as Elite: " + npc )
	if ( npc.IsTitan() )
	{
		npc.EnableNPCFlag( NPC_NO_PAIN | NPC_NO_GESTURE_PAIN | NPC_NEW_ENEMY_FROM_SOUND | NPC_DIRECTIONAL_MELEE | NPC_IGNORE_FRIENDLY_SOUND ) //NPC_AIM_DIRECT_AT_ENEMY
		npc.EnableNPCMoveFlag( NPCMF_PREFER_SPRINT | NPCMF_DISABLE_MOVE_TRANSITIONS )
		npc.DisableNPCFlag( NPC_PAIN_IN_SCRIPTED_ANIM | NPC_ALLOW_FLEE | NPC_USE_SHOOTING_COVER )
		npc.DisableNPCMoveFlag( NPCMF_WALK_NONCOMBAT )
		npc.SetCapabilityFlag( bits_CAP_NO_HIT_SQUADMATES, false )
		npc.SetDefaultSchedule( "SCHED_COMBAT_WALK" )
		npc.kv.AccuracyMultiplier = 5.0
		npc.kv.WeaponProficiency = eWeaponProficiency.PERFECT
		npc.SetTargetInfoIcon( GetTitanCoreIcon( GetTitanCharacterName( npc ) ) )
		npc.AssaultSetFightRadius( 2000 )
		npc.SetEngagementDistVsWeak( 0, 800 )
		npc.SetEngagementDistVsStrong( 0, 800 )
		SetTitanWeaponSkin( npc )
		HideCrit( npc )
		npc.SetTitle( npc.GetSettingTitle() )
		ShowName( npc )
		
		entity soul = npc.GetTitanSoul()
		if( IsValid( soul ) )
		{
			soul.SetPreventCrits( true )
			soul.SetShieldHealthMax( 8000 )
			soul.SetShieldHealth( soul.GetShieldHealthMax() )
		}
		
		if( GetTitanCharacterName( npc ) == "vanguard" ) //Monarchs never use their core, but can track their shields to simulate a player-like behavior
			thread MonitorEliteMonarchShield( npc )
		else
			thread MonitorEliteTitanCore( npc )
	}
}

void function MonitorEliteTitanCore( entity npc )
{
	Assert( IsValid( npc ) && npc.IsTitan(), "Entity is not a Titan to set as Elite: " + npc )
	entity soul = npc.GetTitanSoul()
	if ( !IsValid( soul ) )
		return
	
	soul.EndSignal( "OnDestroy" )
	soul.EndSignal( "OnDeath" )
	
	while( true )
	{
		SoulTitanCore_SetNextAvailableTime( soul, 1.0 )
		
		npc.WaitSignal( "CoreBegin" )
		
		if( soul.GetShieldHealth() < soul.GetShieldHealthMax() / 2 )
			soul.SetShieldHealth( soul.GetShieldHealthMax() / 2 )
		
		entity meleeWeapon = npc.GetMeleeWeapon()
		if( meleeWeapon.HasMod( "super_charged" ) || meleeWeapon.HasMod( "super_charged_SP" ) ) //Hack for Elite Ronin
		{
			npc.SetAISettings( "npc_titan_stryder_leadwall_shift_core_elite" )
			npc.SetNPCMoveSpeedScale( 1.15 ) //Compensate AI lacking doing dashes like players does
		}
		
		npc.WaitSignal( "CoreEnd" )
		npc.SetNPCMoveSpeedScale( 1.0 )
		
		switch ( difficultyLevel )
		{
			case eFDDifficultyLevel.EASY:
			case eFDDifficultyLevel.NORMAL:
			case eFDDifficultyLevel.HARD:
				wait RandomFloatRange( 20.0, 40.0 )
				break
			case eFDDifficultyLevel.MASTER:
			case eFDDifficultyLevel.INSANE:
				wait RandomFloatRange( 40.0, 60.0 )
				break
		}
	}
}

void function MonitorEliteMonarchShield( entity npc )
{
	Assert( IsValid( npc ) && npc.IsTitan() && GetTitanCharacterName( npc ) == "vanguard", "Entity is not a Elite Monarch Titan: " + npc )
	entity soul = npc.GetTitanSoul()
	if ( !IsValid( soul ) )
		return
	
	soul.EndSignal( "OnDestroy" )
	soul.EndSignal( "OnDeath" )
	
	float coretime = Time()
	
	while( true )
	{
		while( soul.GetShieldHealth() > soul.GetShieldHealthMax() * 0.1 )
			WaitFrame()
		
		while( npc.ContextAction_IsBusy() || npc.ContextAction_IsMeleeExecution() ) //Wait for Arc Traps stuns or other actions
			WaitFrame()
		
		wait RandomFloatRange( 1.0, 2.5 )
		
		while( npc.ContextAction_IsBusy() || npc.ContextAction_IsMeleeExecution() ) //Wait again just because yes, within 2.5 seconds might get Arc Trap Zapped again
			WaitFrame()
		
		if( coretime <= Time() )
		{
			entity coreEffect = CreateCoreEffect( npc, $"P_titan_core_atlas_blast" )
			EmitSoundOnEntity( npc, "Titan_Monarch_Smart_Core_Activated_3P" )
			soul.SetShieldHealth( soul.GetShieldHealthMax() )
			entity shake = CreateShake( npc.GetOrigin(), 16.0, 5.0, 2.5, 1500.0 )
			shake.SetParent( npc, "CHESTFOCUS" )
			wait 2.5
			shake.Destroy()
			coreEffect.Destroy()
			coretime = Time() + RandomFloatRange( 20.0, 40.0 )
		}
		else
		{
			thread EliteTitanElectricSmoke( npc )
			wait RandomFloatRange( 5.0, 10.0 ) //Wait a bit before repeating process to not get too spammy
		}
	}
}

void function EliteTitanElectricSmoke( entity titan )
{
	Assert( IsValid( titan ) && titan.IsTitan(), "Entity is not a Titan: " + titan )
	
	entity soul = titan.GetTitanSoul()
	soul.EndSignal( "OnDestroy" )
	soul.EndSignal( "OnDeath" )
	
	wait RandomFloatRange( 1.0, 2.0 )
	
	if( IsValid( titan ) && IsValid( soul ) && !titan.ContextAction_IsMeleeExecution() )
	{
		GiveOffhandElectricSmoke( titan )
		entity smokeinventory = titan.GetOffhandWeapon( OFFHAND_INVENTORY )
		if ( smokeinventory != null )
		{
			if( GetTitanCharacterName( titan ) == "vanguard" && !smokeinventory.HasMod( "maelstrom" ) )
				smokeinventory.AddMod( "maelstrom" )
			
			EliteTitanSmokescreen( titan, smokeinventory )
		}
	}
}

void function EliteTitanSmokescreen( entity ent, entity weapon )
{
	SmokescreenStruct smokescreen
	array<entity> primaryWeapons = ent.GetMainWeapons()
	
	if( !primaryWeapons.len() )
		return
		
	entity maingun = primaryWeapons[0]
	if ( IsValid( maingun ) && maingun.HasMod( "fd_vanguard_utility_1" ) )
		smokescreen.smokescreenFX = FX_ELECTRIC_SMOKESCREEN_HEAL
	smokescreen.isElectric = true
	smokescreen.ownerTeam = ent.GetTeam()
	smokescreen.attacker = ent
	smokescreen.inflictor = ent
	smokescreen.weaponOrProjectile = weapon
	smokescreen.damageInnerRadius = 320.0
	smokescreen.damageOuterRadius = 375.0
	smokescreen.dangerousAreaRadius = 1.0
	if ( weapon.HasMod( "maelstrom" ) )
	{
		smokescreen.dpsPilot = 90
		smokescreen.dpsTitan = 1350
		smokescreen.deploySound1p = SFX_SMOKE_DEPLOY_BURN_1P
		smokescreen.deploySound3p = SFX_SMOKE_DEPLOY_BURN_3P
	}
	else
	{
		smokescreen.dpsPilot = 45
		smokescreen.dpsTitan = 450
	}
	smokescreen.damageDelay = 1.0
	smokescreen.blockLOS = false

	vector eyeAngles = <0.0, ent.EyeAngles().y, 0.0>
	smokescreen.angles = eyeAngles

	vector forward = AnglesToForward( eyeAngles )
	vector testPos = ent.GetOrigin() + forward * 240.0
	vector basePos = testPos

	float trace = TraceLineSimple( ent.EyePosition(), testPos, ent )
	if ( trace != 1.0 )
		basePos = ent.GetOrigin()

	float fxOffset = 200.0
	float fxHeightOffset = 148.0

	smokescreen.origin = basePos

	smokescreen.fxOffsets = [ < -fxOffset, 0.0, 20.0>,
							  <0.0, fxOffset, 20.0>,
							  <0.0, -fxOffset, 20.0>,
							  <0.0, 0.0, fxHeightOffset>,
							  < -fxOffset, 0.0, fxHeightOffset> ]

	Smokescreen( smokescreen )
}

void function SetTitanWeaponSkin( entity npc, int skinindex = 1, int camoindex = 31 )
{
	Assert( IsValid( npc ) && npc.IsTitan(), "Entity is not a Titan: " + npc )
	
	if ( npc.IsTitan() )
	{
		array<entity> primaryWeapons = npc.GetMainWeapons()
		entity weapon = primaryWeapons[0]
		weapon.SetSkin( skinindex )
		weapon.SetCamo( camoindex )
	}
}

void function Elite_NuclearPayload_DoomCallback( entity titan, var damageInfo )
{
	if ( !IsAlive( titan ) )
		return

	if ( DamageInfo_GetDamageSourceIdentifier( damageInfo ) == eDamageSourceId.titan_execution )
		return

	entity soul = titan.GetTitanSoul()
	if ( soul.IsEjecting() || GameRules_GetGameMode() != FD )
		return
	
	if( IsAlive( titan ) && titan.IsNPC() && titan.GetTeam() == TEAM_IMC && titan.ai.bossTitanType == TITAN_MERC )
		thread MonitorEliteDoomStateForEject( titan )
}

void function MonitorEliteDoomStateForEject( entity titan )
{
	entity soul = titan.GetTitanSoul()
	soul.EndSignal( "OnDestroy" )
	soul.EndSignal( "OnDeath" )
	soul.EndSignal( "TitanEjectionStarted" )
	
	while( IsAlive( titan ) )
	{
		wait 1 //Check every second and not less for a more relaxed opportunity to kill the Elite without it Nuke ejecting, this ability should not be a highlight one
		
		int enemyInRange = 0
		array< entity > surroundingEnemies = GetPlayerArrayEx( "any", TEAM_ANY, TEAM_ANY, titan.GetOrigin(), 640 )
		surroundingEnemies.extend( GetNPCArrayEx( "npc_titan", TEAM_ANY, TEAM_ANY, titan.GetOrigin(), 640 ) ) //Turrets and hacked Spectres used to be considered but that would trigger code way too often
		foreach ( entity enemy in surroundingEnemies )
		{
			if ( enemy.GetTeam() != titan.GetTeam() && IsAlive( enemy ) )
				enemyInRange++
		}

		if ( IsAlive( titan ) && NPC_GetNuclearPayload( titan ) == 0 && enemyInRange >= 2 && !titan.ContextAction_IsMeleeExecution() )
		{
			NPC_SetNuclearPayload( titan )
			thread TitanEjectPlayer( titan )
			return
		}
	}
}