// -------------------------------------------------------------------------------------------------------------------------
//
// ███████╗███████╗██╗    ██╗███████╗██████╗      ██████╗ ██████╗ ███╗   ███╗███╗   ███╗ ██████╗ ███╗   ██╗
// ██╔════╝██╔════╝██║    ██║██╔════╝██╔══██╗    ██╔════╝██╔═══██╗████╗ ████║████╗ ████║██╔═══██╗████╗  ██║
// ███████╗█████╗  ██║ █╗ ██║█████╗  ██████╔╝    ██║     ██║   ██║██╔████╔██║██╔████╔██║██║   ██║██╔██╗ ██║
// ╚════██║██╔══╝  ██║███╗██║██╔══╝  ██╔══██╗    ██║     ██║   ██║██║╚██╔╝██║██║╚██╔╝██║██║   ██║██║╚██╗██║
// ███████║███████╗╚███╔███╔╝███████╗██║  ██║    ╚██████╗╚██████╔╝██║ ╚═╝ ██║██║ ╚═╝ ██║╚██████╔╝██║ ╚████║
// ╚══════╝╚══════╝ ╚══╝╚══╝ ╚══════╝╚═╝  ╚═╝     ╚═════╝ ╚═════╝ ╚═╝     ╚═╝╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═══╝
//
// -------------------------------------------------------------------------------------------------------------------------
untyped

global function SewerCommon_Init
global function PlayerTitan_StayPut

const float TOXIC_WASTE_DMG_MIN_PILOT = 35.0
const float TOXIC_WASTE_DMG_MIN_TITAN = 0.0
const float TOXIC_WASTE_DMG_MAX_TITAN = 350.0
const float TOXIC_AREA_NEARBY_DIST = 256.0  // how close to the edge of the trigger the geiger counter will start warning the player
const float TOXIC_WASTE_DMG_DEBOUNCE_TIME = 1.0

struct
{
	array<entity> toxicWasteTrigs
} file;


void function SewerCommon_Init()
{
	AddCallback_EntitiesDidLoad( SewerCommon_EntitiesDidLoad )

	AddCallback_OnPlayerRespawned( SewerCommon_PlayerDidRespawn )

	AddDamageCallback( "player", Sewer_PlayerTookDamage )

	AddCallback_OnTitanBecomesPilot( SewersCommon_TitanBecomesPilot )

	RegisterSignal( "ToxicWasteGeigerCounter_Stop" )

	TimerInit( "Nag_BTTakingToxicDamage", 10.0 )
	TimerInit( "Nag_PlayerTitanTakingToxicDamage", 5.0 )
	TimerInit( "Nag_PlayerPilotInToxicWaste", 5.0 )
	TimerInit( "ToxicWasteDamage", TOXIC_WASTE_DMG_DEBOUNCE_TIME )
}


void function SewerCommon_EntitiesDidLoad()
{
	ToxicTriggersSetup()
}


void function SewerCommon_PlayerDidRespawn( entity player )
{
	thread ToxicWaste_GeigerCounter_AndPlayerEffects( player )
}


void function SewersCommon_TitanBecomesPilot( entity pilot, entity titan )
{
	Assert( pilot.IsPlayer() )
	PlayerTitan_StayPut( pilot )
}


void function ToxicTriggersSetup()
{
	array<entity> hurtTrigs = GetEntArrayByClass_Expensive( "trigger_hurt" )

	foreach ( trig in hurtTrigs )
	{
		string trigName = trig.GetScriptName()

		if ( trigName.find( "trig_toxic_waste" ) != null )
		{
			file.toxicWasteTrigs.append( trig )
			trig.SetNearbyRadius( TOXIC_AREA_NEARBY_DIST )
		}

		if ( trigName.find( "SewerArena_sludge_wall_hurt_trigger" ) != null )
		{
			file.toxicWasteTrigs.append( trig )
			trig.SetNearbyRadius( TOXIC_AREA_NEARBY_DIST )
		}
	}
}


void function Sewer_PlayerTookDamage( entity ent, var damageInfo )
{
	if ( !IsAlive( ent ) )
		return

	entity attacker = DamageInfo_GetAttacker( damageInfo )
	if ( attacker.GetClassName() != "trigger_hurt" )
		return

	// ---- Toxic Waste ----
	entity toxicWasteDamageTrig = null
	foreach ( trig in file.toxicWasteTrigs )
	{
		if ( attacker == trig )
		{
			toxicWasteDamageTrig = attacker
			break
		}
	}

	if ( toxicWasteDamageTrig != null )
	{
		if ( !TimerCheck( "ToxicWasteDamage" ) )
		{
			DamageInfo_SetDamage( damageInfo, 0 )
			return
		}

		if ( ent.IsPlayer() && ent.IsTitan() )
		{
			DamageInfo_SetDamage( damageInfo, 0 )
			return
		}

		DamageInfo_SetDamage( damageInfo, TOXIC_WASTE_DMG_MIN_PILOT )

		if ( ent.IsPlayer() && TimerCheck( "Nag_PlayerPilotInToxicWaste" ) )
		{
			Remote_CallFunction_NonReplay( ent, "ServerCallback_SewersToxicSludgeAlarmSeq" )
			TimerReset( "Nag_PlayerPilotInToxicWaste" )
		}

		TimerReset( "ToxicWasteDamage" )
	}
}


function ToxicWaste_GeigerCounter_AndPlayerEffects( entity player )
{
	if ( !IsAlive( player ) )
		return

	player.Signal( "ToxicWasteGeigerCounter_Stop" )
	player.EndSignal( "ToxicWasteGeigerCounter_Stop" )
	player.EndSignal( "OnDestroy" )

	string geigerSFX_1 = "Pilot_GeigerCounter_Warning_LV1"
	string geigerSFX_2 = "Pilot_GeigerCounter_Warning_LV2"
	string geigerSFX_3 = "Pilot_GeigerCounter_Warning_LV3"

	int lastGeigerLevel = 0
	string currSFX = ""

	OnThreadEnd(
	function() : ( player, geigerSFX_1, geigerSFX_2, geigerSFX_3 )
		{
			if ( IsValid( player ) )
			{
				// breaks the game
				try{
				player.StopSoundOnEntity( geigerSFX_1 )
				player.StopSoundOnEntity( geigerSFX_2 )
				player.StopSoundOnEntity( geigerSFX_3 )
				}
				catch( aaaaaaaaa )
				{
					print( aaaaaaaaa )
				}
			}
		}
	)

	while ( 1 )
	{
		wait 0.3

		if ( !IsAlive( player ) )
			continue

		if ( player.IsTitan() )
			continue

		int geigerLevel = 0

		foreach ( trig in file.toxicWasteTrigs )
		{
			if ( !IsValid( trig ) )
				continue

			if ( trig.IsTouching( player ) )
			{
				geigerLevel = 3

				if ( !player.IsTitan() )
					thread ToxicWaste_PlayerStatusEffects( player, trig )

				break
			}
			else if ( geigerLevel < 1 && trig.GetNearbyFraction( player ) > 0 )
			{
				geigerLevel = 1
			}
		}

		if ( geigerLevel == lastGeigerLevel )
			continue

		lastGeigerLevel = geigerLevel
		//printt( "NEW GEIGER LEVEL:", geigerLevel )

		if ( currSFX != "" )
			StopSoundOnEntity( player, currSFX )

		if ( geigerLevel == 0 )
		{
			currSFX = ""
			continue
		}

		string newSFX = ""
		switch ( geigerLevel )
		{
			case 1:
				newSFX = geigerSFX_1
				break

			case 2:
				newSFX = geigerSFX_2
				break

			case 3:
				newSFX = geigerSFX_3
				break
		}

		EmitSoundOnEntity( player, newSFX )
		currSFX = newSFX
	}
}


void function ToxicWaste_PlayerStatusEffects( entity player, entity trig )
{
	if ( !IsAlive( player ) )
		return

	player.EndSignal( "OnDeath" )
	player.EndSignal( "PlayerEmbarkedTitan" )
	trig.EndSignal( "OnDestroy" )

	if ( StatusEffect_Get( player, eStatusEffect.move_slow ) )
		return

	int handle_move_slow = StatusEffect_AddEndless( player, eStatusEffect.move_slow, 0.3 )

	OnThreadEnd(
	function() : ( player, handle_move_slow )
		{
			if ( IsValid( player ) )
			{
				StatusEffect_Stop( player, handle_move_slow )
			}
		}
	)

	while ( trig.IsTouching( player ) )
		wait 0.1
}


void function PlayerTitan_StayPut( entity player )
{
	if ( !IsAlive( player ) )
		return

	entity titan = GetPlayerTitanInMap( player )

	if ( !IsValid( titan ) )
	{
		printt( "WARNING: no player titan in map, can't tell it to stay put." )
		return
	}

	titan.AssaultPoint( titan.GetOrigin() )
	titan.AssaultSetGoalRadius( 128 )
	titan.AssaultSetAngles( titan.GetAngles(), true )
}