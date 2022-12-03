untyped
global function NewSaveLocation
global function TeleportAllExceptOne
global function TeleportAllExceptOneInstant
global function TriggerManualCheckPoint
global function TriggerSilentCheckPoint
global function Init_triggers
global function GetSaveLocation
global function GetCheckPointInfo
global function SetPlayer0
global function GetPlayer0

global struct CheckPointInfo
{
	vector pos
	bool RsPilot = true
	entity player0
}

struct
{
	bool lastCheckpointWasAsPilot = true
	vector lastSave = <0,0,0>

	entity player0
} save

/*
██╗███╗   ██╗██╗████████╗
██║████╗  ██║██║╚══██╔══╝
██║██╔██╗ ██║██║   ██║   
██║██║╚██╗██║██║   ██║   
██║██║ ╚████║██║   ██║   
╚═╝╚═╝  ╚═══╝╚═╝   ╚═╝
*/

void function Init_triggers()
{
	thread Init_triggersThreaded()
}

void function Init_triggersThreaded()
{
	switch ( GetMapName() )
	{
		case "sp_training":
			CreateGauntletTeleportBackTrigger()
			break

		case "sp_sewers1":
			// we kinda need this
			CreateTeleportTrigger( < 9468,1125,216.1 >, 1500.0, 2000.0, 100.0, false ) // the first time you enter the sewers as titan
			// CreateTeleportTrigger( < 9670,6809,784 >, 500.0, 1000.0, 100.0, true ) // the button closign door
			CreateTeleportTrigger( < -891,1345,288.031 >, 1000.0, 1000.0, 100.0, true ) // the door clsoing when you help militia grunts
			CreateTeleportTrigger( < -7815, 1971, 1936.2 >, 1500.0, 1000.0, 100.0, true ) // the switch
			// CreateTeleportTrigger( < -6384, -6723, 2900 > , 1000.0, 1000.0, 1000.0, false ) // kane's party
			break

		case "sp_beacon":
			// CreateTeleportTrigger( <11637, -2451, -204>, 300.0, 200.0, 100.0, true ) // door closing you off from the control room :(
			break
		case "sp_beacon_spoke0":
			CreateTeleportTrigger( <2689, 10284, 417>, 500.0, 2000.0, 100.0, true ) // door closing aftr the first major fight
			break
	}
}


/*
████████╗██████╗ ██╗ ██████╗  ██████╗ ███████╗██████╗ ███████╗
╚══██╔══╝██╔══██╗██║██╔════╝ ██╔════╝ ██╔════╝██╔══██╗██╔════╝
   ██║   ██████╔╝██║██║  ███╗██║  ███╗█████╗  ██████╔╝███████╗
   ██║   ██╔══██╗██║██║   ██║██║   ██║██╔══╝  ██╔══██╗╚════██║
   ██║   ██║  ██║██║╚██████╔╝╚██████╔╝███████╗██║  ██║███████║
   ╚═╝   ╚═╝  ╚═╝╚═╝ ╚═════╝  ╚═════╝ ╚══════╝╚═╝  ╚═╝╚══════╝
*/

void function CreateTeleportTrigger( vector origin, float radius, float top, float bottom, bool TpAsPilot )
{
	printl("=========================================")
	printl(" created Teleport trigger " + origin)
	printl("=========================================")

	array<entity> ents = []
	entity trigger = _CreateScriptCylinderTriggerInternal( origin, radius, TRIG_FLAG_PLAYERONLY  | TRIG_FLAG_ONCE, ents, top, bottom )
	
	if ( TpAsPilot )
		AddCallback_ScriptTriggerEnter( trigger, OnTeleportPilotTriggered )
	else
		AddCallback_ScriptTriggerEnter( trigger, OnTeleportTitanTriggered )
}

void function OnTeleportPilotTriggered( entity trigger, entity player )
{
	thread OnTeleportPilotTriggeredThreaded( trigger, player )
}

void function OnTeleportPilotTriggeredThreaded( entity trigger, entity player )
{
	printl("=========================================")
	printl("New checkpoint :" + trigger.GetOrigin())
	printl("=========================================")
	
	vector destination = trigger.GetOrigin()
	waitthread TeleportAllExceptOne( destination, player )
	wait 0.1

	foreach( entity p in GetPlayerArray() )
	{
		if ( p != player )
			thread MakePlayerPilot( p, destination )
	}

	save.lastSave = destination
	save.lastCheckpointWasAsPilot = true
}

void function OnTeleportTitanTriggered( entity trigger, entity player )
{
	thread OnTeleportTitanTriggeredThreaded( trigger, player )
}

void function OnTeleportTitanTriggeredThreaded( entity trigger, entity player )
{
	printl("=========================================")
	printl("New checkpoint :" + trigger.GetOrigin())
	printl("=========================================")
	
	vector destination = trigger.GetOrigin()
	waitthread TeleportAllExceptOne( destination, player )
	wait 0.1
	
	foreach( entity p in GetPlayerArray() )
	{
		if ( p != player )
			thread MakePlayerTitan( p, destination )
	}

	save.lastSave = destination
	save.lastCheckpointWasAsPilot = false
}

void function CreateGauntletTeleportBackTrigger()
{
	array<entity> ents = []
	entity trigger = _CreateScriptCylinderTriggerInternal( < 2263,7538,304 >, 150.0, TRIG_FLAG_PLAYERONLY, ents, 100.0, 100.0 )
	
	trigger.SetScriptName( "gauntlet_trigger" )
	AddCallback_ScriptTriggerEnter( trigger, OnTeleportBackTriggered )
}

void function OnTeleportBackTriggered( entity trigger, entity player )
{
	player.SetOrigin( < -5677,197,60 > )
}

/*
██╗   ██╗████████╗██╗██╗     ██╗████████╗██╗███████╗███████╗
██║   ██║╚══██╔══╝██║██║     ██║╚══██╔══╝██║██╔════╝██╔════╝
██║   ██║   ██║   ██║██║     ██║   ██║   ██║█████╗  ███████╗
██║   ██║   ██║   ██║██║     ██║   ██║   ██║██╔══╝  ╚════██║
╚██████╔╝   ██║   ██║███████╗██║   ██║   ██║███████╗███████║
 ╚═════╝    ╚═╝   ╚═╝╚══════╝╚═╝   ╚═╝   ╚═╝╚══════╝╚══════╝                                                                                              
*/

void function NewSaveLocation( vector origin )
{
	save.lastSave = origin
}

vector function GetSaveLocation()
{
	return save.lastSave
}

void function TeleportAllExceptOne( vector destination, entity ornull ThisPlayer, bool display_notification = true )
{
	array<entity> movers

	foreach( entity player in GetPlayerArray() )
	{
		if ( player != ThisPlayer )
		{
			WaitFrame()
			try
			{
				MakeInvincible( player )
				entity mover = CreateOwnedScriptMover( player )
				player.SetParent( mover )
				mover.MoveTo( destination, 0.5, 0, 0 )
				PhaseShift( player, 0.1, 1 )

				player.SetHealth( player.GetMaxHealth() )
				if ( display_notification )
					DisplayOnscreenHint( player, "move_hint" )
				
				movers.append( mover )
			}
			catch( exception ){}
		}
	}

	wait 0.6

	foreach( entity player in GetPlayerArray() )
	{
		if ( player != ThisPlayer )
		{
			WaitFrame()
			try
			{
				player.ClearParent()
				ClearInvincible( player )
				ClearOnscreenHint( player )
			}
			catch( exception ){}
		}
	}
	
	foreach( entity mover in movers )
	{
		if ( IsValid( mover ) )
			mover.Destroy()
	}
}

void function TeleportAllExceptOneInstant ( vector destination, entity ornull ThisPlayer, bool display_notification = true )
{

	foreach( entity player in GetPlayerArray() )
	{
		if ( player != ThisPlayer )
		{
			WaitFrame()
			try
			{
				player.SetOrigin( destination )
				if ( display_notification )
					DisplayOnscreenHint( player, "move_hint" )
			}
			catch( exception ){}
		}
	}

	wait 1

	foreach( entity player in GetPlayerArray() )
	{
		ClearOnscreenHint( player )
	}
}

void function TriggerManualCheckPoint( entity ornull player, vector origin, bool IsPilotSpawn )
{
	NewSaveLocation( origin )
	waitthread TeleportAllExceptOne( origin, player )
	wait 0.1
	
	foreach( entity p in GetPlayerArray() )
	{
		if ( p != player )
		{
			if ( !IsPilot( p ) && IsPilotSpawn )
				thread MakePlayerPilot( p, origin )
			else if ( IsPilot( p ) && !IsPilotSpawn )
				thread MakePlayerTitan( p, origin )
		}
	}
	save.lastCheckpointWasAsPilot = IsPilotSpawn
}

void function TriggerSilentCheckPoint( vector origin, bool IsPilotSpawn )
{
	NewSaveLocation( origin )
	save.lastCheckpointWasAsPilot = IsPilotSpawn
}

CheckPointInfo function GetCheckPointInfo()
{
	CheckPointInfo Info

	Info.RsPilot = save.lastCheckpointWasAsPilot
	
	Info.pos = save.lastSave
	Info.player0 = save.player0
	return Info
}

void function SetPlayer0( entity player )
{
	if ( IsValid( save.player0 ) )
		DisplayOnscreenHint( player, "player0_hint_2" )
	else
		DisplayOnscreenHint( player, "player0_hint_1" )
    save.player0 = player

	thread ClearPlayer0Hint( player )
}

void function ClearPlayer0Hint( entity player )
{
	EndSignal( player, "OnDeath" )

	OnThreadEnd(
	function() : ( player )
		{
			if ( IsValid( player ) )
				ClearOnscreenHint( player )
		}
	)

	wait 5
}

entity function GetPlayer0()
{
    return save.player0
}