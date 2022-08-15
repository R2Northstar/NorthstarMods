global function GamemodeTbag_Init
global function CreateBattery

struct {
	table<entity, float> players // needed for detecting if tbag grace period exceeded 3 seconds
	table<entity, array<entity> > trigger // needed for detecting individual batteries
	table<entity, int> tbag // needed for detecting tbag counter
	int floatingDuration // how long it takes for the battery to disappear
	int teabagCounter // how many times do you need to teabag
} file

void function GamemodeTbag_Init()
{
	SetShouldUseRoundWinningKillReplay( true )
	Riff_ForceTitanAvailability( eTitanAvailability.Never )
	ClassicMP_ForceDisableEpilogue( true )

	AddCallback_OnClientConnected( TbagInitPlayer )
	AddCallback_OnPlayerKilled( TbagOnPlayerKilled )
	AddCallback_OnClientDisconnected( TbagCleanupClient )
	AddCallback_GameStateEnter( eGameState.WinnerDetermined, OnWinnerDetermined )

	SetTimeoutWinnerDecisionFunc( CheckScoreForDraw )

	file.floatingDuration = GetCurrentPlaylistVarInt( "floatingduration", 30 )
	file.teabagCounter = GetCurrentPlaylistVarInt( "teabagcounter", 4 )
}

void function TbagInitPlayer( entity player )
{
	file.players[player] <- Time() // start beginning countdown
	file.tbag[player] <- 0 // newslot this so the tbag counter starts at 0
	AddCrouchButtonInputCallback( player )
	AddToggleCrouchButtonInputCallback( player )
}

void function TbagCleanupClient( entity player )
{
	// remove all saved tables of this player when they disconnect.
	if (player in file.players)
		delete file.players[player]

	if (player in file.trigger)
		delete file.trigger[player]

	if (player in file.tbag)
		delete file.tbag[player]
}

void function TbagOnPlayerKilled( entity victim, entity attacker, var damageInfo )
{
	if ( !victim.IsPlayer() || GetGameState() != eGameState.Playing || attacker == victim)
		return

	if ( attacker.IsPlayer() )
    {
		CreateBattery( victim )
		SetRoundWinningKillReplayAttacker( attacker )
    }
}

void function OnWinnerDetermined()
{
	SetRespawnsEnabled( false )
	SetKillcamsEnabled( false )
}

int function CheckScoreForDraw()
{
	if (GameRules_GetTeamScore(TEAM_IMC) > GameRules_GetTeamScore(TEAM_MILITIA))
		return TEAM_IMC
	else if (GameRules_GetTeamScore(TEAM_MILITIA) > GameRules_GetTeamScore(TEAM_IMC))
		return TEAM_MILITIA

	return TEAM_UNASSIGNED
}

void function AddCrouchButtonInputCallback( entity player )
{
	AddButtonPressedPlayerInputCallback( player, IN_DUCK, Crouching )
}

void function AddToggleCrouchButtonInputCallback( entity player )
{
	AddButtonPressedPlayerInputCallback( player, IN_DUCKTOGGLE, ToggleCrouching ) // toggle crouch requires x2 the input
}

// ========================================================================================================
//
// BATTERY STUFF
//
// ========================================================================================================

void function CreateBattery( entity player )
{
	entity batteryPack = CreateEntity( "prop_dynamic" )
	batteryPack.SetValueForModelKey( RODEO_BATTERY_MODEL ) // ideally I would want the Helmet collectible from the campaign :/
	batteryPack.kv.fadedist = 10000

	// trace origins to the floor so it spawns on the floor instead of being midair
	array ignoreArray = [] // no idea what this array requires
	TraceResults downTrace = TraceLine( player.EyePosition(), player.GetOrigin() + <0.0, 0.0, -1000.0>, ignoreArray, TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_BLOCK_WEAPONS )

	batteryPack.SetOrigin( downTrace.endPos )

	entity flyer = CreateEntity( "script_mover" )
    flyer.kv.SpawnAsPhysicsMover = false
    flyer.SetValueForModelKey( $"models/dev/empty_model.mdl" )
	flyer.SetOrigin( batteryPack.GetOrigin() )
    flyer.kv.solid = SOLID_HITBOXES
    flyer.kv.DisableBoneFollowers = 1
    flyer.kv.fadedist = 10000
	batteryPack.SetParent(flyer)
    DispatchSpawn( flyer )

	DispatchSpawn( batteryPack )
	batteryPack.SetModel( RODEO_BATTERY_MODEL )
	Battery_StartFX( batteryPack )
	Highlight_SetFriendlyHighlight( batteryPack, "sp_friendly_pilot" )
	Highlight_SetNeutralHighlight( batteryPack, "enemy_player" )
	Highlight_SetEnemyHighlight( batteryPack, "enemy_player" )
	batteryPack.SetVelocity( < 0, 0, 1 > )

	SetTeam( batteryPack, player.GetTeam() )

	thread StartAnimating( flyer )
	thread CreateBatteryTrigger( batteryPack )
	thread DestroyBattery( flyer, file.floatingDuration )
}

void function DestroyBattery( entity batteryPack, int duration )
{
	batteryPack.EndSignal( "OnDestroy" )
	OnThreadEnd(
		function () : ( batteryPack )
		{
			if ( IsValid( batteryPack ) )
			{
				batteryPack.Destroy()
			}
		}
	)
	int lastDuration = ( duration - (duration - 5) )
	wait duration - 5
	thread FlickeringOnTimeout(batteryPack)
	wait lastDuration
}

void function FlickeringOnTimeout( entity bruh )
{
	batteryPack.EndSignal( "OnDestroy" )
	while (IsValid(bruh))
	{
		try
		{
			wait 0.2
			bruh.kv.VisibilityFlags = ENTITY_VISIBLE_TO_EVERYONE
			wait 0.2
			bruh.kv.VisibilityFlags = 0
		} catch (why)
		{}
		WaitFrame()
	}
}

void function CreateBatteryTrigger( entity batteryPack )
{
	entity trigger = CreateEntity( "trigger_cylinder" )
	trigger.SetRadius( 100 )
	trigger.SetAboveHeight( 100 )
	trigger.SetBelowHeight( 100 )
	trigger.SetOrigin( batteryPack.GetOrigin() )
	trigger.SetParent( batteryPack )
	trigger.kv.triggerFilterNpc = "none"
	DispatchSpawn( trigger )
	SetTeam( trigger, batteryPack.GetTeam() )
	trigger.SetEnterCallback( BatteryTrigger_Enter )
	trigger.SetLeaveCallback( BatteryTrigger_Leave )
}

void function BatteryTrigger_Enter( entity trigger, entity player )
{
	if ( trigger != null && IsValid(player) && player.IsPlayer() )
	{
		if ( !( player in file.trigger ) )
		{
			file.trigger[player] <- [] // create a new fucking array if there hasn't been one before
			file.trigger[player].append(trigger)
		} else {
			file.trigger[player].append(trigger) // since there's already an array, append this entity trigger to it.
		}
	}
}

void function BatteryTrigger_Leave( entity trigger, entity player )
{
	if ( trigger != null )
	{
		if ( player in file.trigger )
		{
			foreach( triggerbaby in file.trigger[player] )
			{
				if (file.trigger[player].find(trigger) != -1)
					file.trigger[player].remove( file.trigger[player].find(trigger) )
			}
		}
	}
}

void function Crouching( entity player )
{
	if ( !(player in file.players) )
		return

	if ( !(player in file.trigger) )
		return

	if ( Time() - file.players[player] > 3.0 ) // if they exceeded the grace period, demolish their counter
	{
		file.tbag[player] = 0
		file.players[player] = Time()
	}

	if ( Time() - file.players[player] <= 3.0 ) // oh hey they do be tbaging, add one to the counter
	{
		int i = file.tbag[player]
		i++
		file.tbag[player] = i
		file.players[player] = Time()
	}

	if ( file.tbag[player] >= file.teabagCounter ) // they tbag alot, so time to do stuff
	{
		foreach ( triggerbaby in file.trigger[player] )
		{
			if ( triggerbaby.GetTeam() != player.GetTeam() )
			{
				AddTeamScore( player.GetTeam(), 1 ) // add score if tbag'd an enemy's corpse
				entity batteryPack = triggerbaby.GetParent()
				entity mover = batteryPack.GetParent()
				if ( IsValid( mover ) )
				{
					ClearChildren( batteryPack )
					mover.Destroy()
				}
				if ( IsValid( triggerbaby ) )
				{
					file.trigger[player].remove( file.trigger[player].find(triggerbaby) )
					triggerbaby.Destroy()
				}
				Remote_CallFunction_NonReplay( player, "ServerCallback_TeabagConfirmed" )
				player.AddToPlayerGameStat( PGS_TITAN_KILLS, 1 )
			} else // remove it to deny enemy from tbagging
			{
				entity batteryPack = triggerbaby.GetParent()
				entity mover = batteryPack.GetParent()
				if ( IsValid( mover ) )
				{
					ClearChildren( batteryPack )
					mover.Destroy()
				}
				if ( IsValid(triggerbaby) )
				{
					file.trigger[player].remove( file.trigger[player].find(triggerbaby) )
					triggerbaby.Destroy()
				}
				Remote_CallFunction_NonReplay( player, "ServerCallback_TeabagDenied" )
				player.AddToPlayerGameStat( PGS_DEFENSE_SCORE, 1 )
			}
		}
	}
	return
}

void function ToggleCrouching( entity player )
{
	if ( !(player in file.players) )
		return

	if ( !(player in file.trigger) )
		return

	if ( Time() - file.players[player] > 3.0 )
	{
		file.tbag[player] = 0
		file.players[player] = Time()
	}

	if ( Time() - file.players[player] <= 3.0 )
	{
		int i = file.tbag[player]
		i++
		file.tbag[player] = i
		file.players[player] = Time()
	}

	if ( file.tbag[player] >= ( file.teabagCounter * 2 ) )
	{
		foreach ( triggerbaby in file.trigger[player] )
		{
			if ( triggerbaby.GetTeam() != player.GetTeam() )
			{
				AddTeamScore( player.GetTeam(), 1 )
				entity batteryPack = triggerbaby.GetParent()
				entity mover = batteryPack.GetParent()
				if ( IsValid( mover ) )
				{
					ClearChildren( batteryPack )
					mover.Destroy()
				}
				if ( IsValid( triggerbaby ) )
				{
					file.trigger[player].remove( file.trigger[player].find(triggerbaby) )
					triggerbaby.Destroy()
				}
				Remote_CallFunction_NonReplay( player, "ServerCallback_TeabagConfirmed" )
				player.AddToPlayerGameStat( PGS_TITAN_KILLS, 1 )
			} else
			{
				entity batteryPack = triggerbaby.GetParent()
				entity mover = batteryPack.GetParent()
				if ( IsValid( mover ) )
				{
					ClearChildren( batteryPack )
					mover.Destroy()
				}
				if ( IsValid(triggerbaby) )
				{
					file.trigger[player].remove( file.trigger[player].find(triggerbaby) )
					triggerbaby.Destroy()
				}
				Remote_CallFunction_NonReplay( player, "ServerCallback_TeabagDenied" )
				player.AddToPlayerGameStat( PGS_DEFENSE_SCORE, 1 )
			}
		}
	}
	return
}

// ========================================================================================================
// floating batteries that spins
// many thanks @Pebbers lol - karma
// ========================================================================================================

const float CYCLES = 3.0
const float RADIUS = 3.0
const float ANGLES = 45.0

void function StartAnimating( entity toAnimate ) {
    vector originalOrigin = toAnimate.GetOrigin()
    vector originalAngles = toAnimate.GetAngles()

    // this will go -RADIUS -> RADIUS
    // Ratio is abs(zOffset) / RADIUS
    float zOffset = 0.0
    float posOffset = 0.0
    float angleOffset = 0.0
    float currTime = Time()

    while ( IsValid( toAnimate ) )
	{
        // delta time since last frame so it isnt frame dependant lmao
        float delta = ( Time() - currTime ) // s since last frame
        float step = CYCLES * delta
        float ratio = fAbs( zOffset ) / RADIUS
        float smooth = sineEasing( ratio ) // how much it'll increment every second
        float angleStep = ANGLES * delta

        zOffset += step
        angleOffset += angleStep
		angleOffset = angleOffset % 360
        currTime = Time()
        posOffset = smooth * 2
		try
		{
        	//toAnimate.SetOrigin(originalOrigin + <0,0,posOffset>)
        	// toAnimate.SetAngles(originalAngles + <0,angleOffset,0>)
			toAnimate.NonPhysicsMoveTo( originalOrigin + <0,0,posOffset> , 0.5, 0.1, 0.1 )
			toAnimate.NonPhysicsRotateTo( originalAngles + <0,angleOffset,0> , 0.5, 0.1, 0.1 )
		} catch (ex)
		{
			print( ex )
		}

        WaitFrame()
    }
}
// Eases in via sine function from -1 to 1
// makes it look smooth
// math turned out to be useful wow
float function sineEasing( float x ) {
    return ( -( 2 * ( cos( PI * x ) - 1 ) / 2 ) ) - 1.0
}


//abs of a float
float function fAbs( float x ) {
    float res = 0.0;
    if ( x < 0 ) {
        res = -x
    } else {
        res = x;
    }
    return res
}

