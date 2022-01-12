#if SERVER
untyped
#endif

const float CUSTOM_SONAR_GRENADE_RADIUS = 3500.0

global function OnProjectileIgnite_weapon_grenade_sonar_pilot

const asset FLASHEFFECT = $"wpn_grenade_sonar_impact"

void function OnProjectileIgnite_weapon_grenade_sonar_pilot( entity projectile )
{
	#if SERVER
		thread SonarGrenadeThink( projectile )
	#endif

	SetObjectCanBeMeleed( projectile, true )

	StartParticleEffectOnEntity( projectile, GetParticleSystemIndex( FLASHEFFECT ), FX_PATTACH_ABSORIGIN_FOLLOW, -1 )
	projectile.SetDoesExplode( false )
}

#if SERVER
void function SonarGrenadeThink( entity projectile )
{
	projectile.EndSignal( "OnDestroy" )

	entity weaponOwner = projectile.GetOwner()

	int team = projectile.GetTeam()
	vector pulseOrigin = projectile.GetOrigin()
	array<entity> ents = []

	entity trigger = CreateTriggerRadiusMultiple( pulseOrigin, CUSTOM_SONAR_GRENADE_RADIUS, ents, TRIG_FLAG_START_DISABLED | TRIG_FLAG_NO_PHASE_SHIFT )
	SetTeam( trigger, team )
	trigger.SetOwner( projectile.GetOwner() )

	IncrementSonarPerTeam( team )

	entity owner = projectile.GetThrower()
	if ( IsValid( owner ) && owner.IsPlayer() )
	{
		array<entity> offhandWeapons = owner.GetOffhandWeapons()
		foreach ( weapon in offhandWeapons )
		{
			//if ( weapon.GetWeaponClassName() == grenade.GetWeaponClassName() ) // function doesn't exist for grenade entities
			if ( weapon.GetWeaponClassName() == "mp_weapon_grenade_sonar" )
			{
				float duration = weapon.GetWeaponSettingFloat( eWeaponVar.grenade_ignition_time ) + 0.75 // buffer cause these don't line up
				StatusEffect_AddTimed( weapon, eStatusEffect.simple_timer, 1.0, duration, duration )
				break
			}
		}
	}


	OnThreadEnd(
		function() : ( projectile, trigger, team )
		{
			DecrementSonarPerTeam( team )
			trigger.Destroy()
			if ( IsValid( projectile ) )
				projectile.Destroy()
		}
	)

	AddCallback_ScriptTriggerEnter( trigger, OnSonarTriggerEnter )
	AddCallback_ScriptTriggerLeave( trigger, OnSonarTriggerLeave )

	ScriptTriggerSetEnabled( trigger, true )

	if ( IsValid( weaponOwner ) && weaponOwner.IsPlayer() )
	{
		EmitSoundOnEntityExceptToPlayer( projectile, weaponOwner, "Pilot_PulseBlade_Activated_3P" )
		EmitSoundOnEntityOnlyToPlayer( projectile, weaponOwner, "Pilot_PulseBlade_Activated_1P" )
	}
	else
	{
		EmitSoundOnEntity( projectile, "Pilot_PulseBlade_Activated_3P" )
	}

	while ( IsValid( projectile ) )
	{
		pulseOrigin = projectile.GetOrigin()
		trigger.SetOrigin( pulseOrigin )

		array<entity> players = GetPlayerArrayOfTeam( team )

		foreach ( player in players )
		{
			Remote_CallFunction_Replay( player, "ServerCallback_SonarPulseFromPosition", pulseOrigin.x, pulseOrigin.y, pulseOrigin.z, CUSTOM_SONAR_GRENADE_RADIUS )
		}

		wait 1.3333
		if ( IsValid( projectile ) )
		{
			if ( IsValid( weaponOwner ) && weaponOwner.IsPlayer() )
			{
				EmitSoundOnEntityExceptToPlayer( projectile, weaponOwner, "Pilot_PulseBlade_Sonar_Pulse_3P" )
				EmitSoundOnEntityOnlyToPlayer( projectile, weaponOwner, "Pilot_PulseBlade_Sonar_Pulse_1P" )
			}
			else
			{
				EmitSoundOnEntity( projectile, "Pilot_PulseBlade_Sonar_Pulse_3P" )
			}
		}
	}
}

void function OnSonarTriggerEnter( entity trigger, entity ent )
{
	if ( !IsEnemyTeam( trigger.GetTeam(), ent.GetTeam() ) )
		return

	if ( ent.e.sonarTriggers.contains( trigger ) )
		return

	ent.e.sonarTriggers.append( trigger )
	SonarStart( ent, trigger.GetOrigin(), trigger.GetTeam(), trigger.GetOwner() )
}

void function OnSonarTriggerLeave( entity trigger, entity ent )
{
	int triggerTeam = trigger.GetTeam()
	if ( !IsEnemyTeam( triggerTeam, ent.GetTeam() ) )
		return

	OnSonarTriggerLeaveInternal( trigger, ent )
}
#endif

#if CLIENT


void function EntitySonarDetectedEnabled( entity ent, int statusEffect, bool actuallyChanged )
{
	if ( ent == GetLocalViewPlayer() )
	{
		// player is already lockon highlighted
		if ( statusEffect == eStatusEffect.sonar_detected && StatusEffect_Get( ent, eStatusEffect.lockon_detected ) )
			return

		entity viewModelEntity = ent.GetViewModelEntity()
		entity firstPersonProxy = ent.GetFirstPersonProxy()
		entity predictedFirstPersonProxy = ent.GetPredictedFirstPersonProxy()

		vector highlightColor = statusEffect == eStatusEffect.sonar_detected ? HIGHLIGHT_COLOR_ENEMY : <1, 0, 0>

		if ( IsValid( viewModelEntity ) )
			SonarViewModelHighlight( viewModelEntity, highlightColor )

		if ( IsValid( firstPersonProxy ) )
			SonarViewModelHighlight( firstPersonProxy, highlightColor )

		if ( IsValid( predictedFirstPersonProxy ) )
			SonarViewModelHighlight( predictedFirstPersonProxy, highlightColor )

		thread PlayLoopingSonarSound( ent )
	}
	else
	{
		ClInitHighlight( ent )
	}
}

void function EntitySonarDetectedDisabled( entity ent, int statusEffect, bool actuallyChanged )
{
	if ( ent == GetLocalViewPlayer() )
	{
		// player should have lockon highlighted
		if ( statusEffect == eStatusEffect.sonar_detected && StatusEffect_Get( ent, eStatusEffect.lockon_detected ) )
		{
			return
		}
		else if ( statusEffect == eStatusEffect.lockon_detected && StatusEffect_Get( ent, eStatusEffect.sonar_detected ) )
		{
			// restore sonar after lockon wears off
			EntitySonarDetectedEnabled( ent, eStatusEffect.sonar_detected, true )
			return
		}

		entity viewModelEntity = ent.GetViewModelEntity()
		entity firstPersonProxy = ent.GetFirstPersonProxy()
		entity predictedFirstPersonProxy = ent.GetPredictedFirstPersonProxy()

		if ( IsValid( viewModelEntity ) )
			SonarViewModelClearHighlight( viewModelEntity )

		if ( IsValid( firstPersonProxy ) )
			SonarViewModelClearHighlight( firstPersonProxy )

		if ( IsValid( predictedFirstPersonProxy ) )
			SonarViewModelClearHighlight( predictedFirstPersonProxy )

		ent.Signal( "EntitySonarDetectedDisabled" )
	}
	else
	{
		ClInitHighlight( ent )
	}
}

void function PlayLoopingSonarSound( entity ent )
{
	EmitSoundOnEntity( ent, "HUD_MP_EnemySonarTag_Activated_1P" )

	ent.EndSignal( "EntitySonarDetectedDisabled" )
	ent.EndSignal( "OnDeath" )

	while( true )
	{
		wait 1.5
		EmitSoundOnEntity( ent, "HUD_MP_EnemySonarTag_Flashed_1P" )
	}

}
#endif