untyped
global function NewSaveLocation
global function TeleportAllExpectOne
global function Init_triggers
global function GetSaveLocation
global function GetCheckPointInfo
global function SetPlayer0
global function GetPlayer0

global struct CheckPointInfo
{
	vector pos
	bool RsPilot
	entity player0
}

struct
{
	array<bool> nextCheckpointAsPilot = []
	int currentPilotBoolId = 0

	bool lastCheckpointWasAsPilot

	bool BreakTriggers = false

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
			CreateTeleportTrigger( < -6130,-11703,-255 >, 100.0, 600.0, 100.0, true ) // the tp out of the sim pod 
			CreateTeleportTrigger( < -7465,314,144 >, 1000.0, 500.0, 100.0, true ) // the armory
			CreateTeleportTrigger( < 1311,74,-2522.6 >, 500.0, 500.0, 100.0, true ) // fs titan call
			CreateTeleportTrigger( < 10563,-10234.8,-6026.91 >, 500.0, 500.0, 100.0, true ) // the last time we see the sim pod
			break

		case "sp_crashsite":
			CreateTeleportTrigger( < -295,-419,45.03 >, 600.0, 100.0, 100.0, true ) // the tp to the next phase of the map
			break

		case "sp_sewers1":
			CreateTeleportTrigger( < 9468,1125,216.1 >, 1500.0, 2000.0, 100.0, false ) // the first time you enter the sewers as titan
			CreateTeleportTrigger( < 9670,6809,784 >, 500.0, 1000.0, 100.0, true ) // the button closign door
			CreateTeleportTrigger( < -891,1345,288.031 >, 500.0, 1000.0, 100.0, true ) // the door clsoing when you help militia grunts
			break

		// case "sp_boomtown_start":
		// case "sp_boomtown":
		// case "sp_boomtown_end":
		// 	return eSPLevel.BOOM_TOWN

		case "sp_hub_timeshift":
			CreatePlayerLockTrigger(  < 877,-7128,896.3 >, 500.0, 2000.0, 100.0 ) // locks them in the start location
			CreatePlayerLockBreakerTrigger( < -1838,-6758,430.17 >, 500.0, 2000.0, 100.0 ) // remove the players lock
			CreateTeleportTrigger( < -1838,-6758,430.17 >, 400.0, 2000.0, 100.0, true) // teleports people to window
			CreateTeleportTrigger( < -1123,-1306,-1353.1 >, 500.0, 2000.0, 100.0, false) // teleports people to the rope
			CreateMapChangeTrigger( < 598,-3347,-471 >, 500.0, 2000.0, 100.0) // changes map
			break
		// case "sp_timeshift_spoke02":
		// 	break

		// case "sp_beacon":
		// case "sp_beacon_spoke0":
		// 	return eSPLevel.BEACON

		case "sp_tday":
			CreateMapChangeTrigger( < 6683,12750,2432 >, 5000.0, 2000.0, 100.0) // change map trigger
			CreateTeleportTrigger( < 1585,-3711,227.6 >, 1000.0, 2000.0, 100.0, true ) // the door
			CreateTeleportTrigger( < -6622,3890,1920.6 >, 2000.0, 2000.0, 100.0, true ) // the elevator exit
			CreateTeleportTrigger( < -6631,14697,2560.4 >, 2000.0, 2000.0, 100.0, true ) // the last run to the ship
			break

		// case "sp_s2s":
		// 	return eSPLevel.SHIP2SHIP

		// case "sp_skyway_v1":
		// 	return eSPLevel.SKYWAY

		// default:
			
	}
	
	// its here because when I do from the start the game crashes
	wait( 10 )
	save.lastSave = GetEnt( "info_player_start" ).GetOrigin()
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
	entity trigger = _CreateScriptCylinderTriggerInternal( origin, radius, TRIG_FLAG_PLAYERONLY, ents, top, bottom )

	AddCallback_ScriptTriggerEnter( trigger, OnTeleportTriggered )
	// AddCallback_ScriptTriggerLeave( trigger, OnTeleportTriggered )

	save.nextCheckpointAsPilot.append( TpAsPilot )
}

void function OnTeleportTriggered( entity trigger, entity player )
{
	printl("=========================================")
	printl("New checkpoint :" + trigger.GetOrigin())
	printl("=========================================")

	thread TeleportAllExpectOne( trigger.GetOrigin(), player )
	vector destination = trigger.GetOrigin()

	foreach( entity p in GetPlayerArray() )
	{
		if ( p != player )
		{
			if ( save.nextCheckpointAsPilot[ save.currentPilotBoolId ] )
				thread MakePlayerPilot( p, destination )
			else
				thread MakePlayerTitan( p, destination )
		}
	}
	
	save.lastSave = trigger.GetOrigin()
	save.currentPilotBoolId += 1

	trigger.Destroy()
}

void function CreateMapChangeTrigger( vector origin, float radius, float top, float bottom)
{
	array<entity> ents = []
	entity trigger = _CreateScriptCylinderTriggerInternal( origin, radius, TRIG_FLAG_PLAYERONLY, ents, top, bottom )

	AddCallback_ScriptTriggerEnter( trigger, OnMapChangeTriggered )
}

void function OnMapChangeTriggered( entity trigger, entity player )
{
	printl("=========================================")
	printl("Map change :" + trigger.GetOrigin())
	printl("=========================================")

	thread TeleportAllExpectOne( trigger.GetOrigin(), player )

	foreach( p in GetPlayerArray() )
	{
		ScreenFadeToBlackForever( p, 1.7 )
	}

	wait( 3 )
	Coop_MapChange()
}

void function CreatePlayerLockTrigger(  vector origin, float radius, float top, float bottom )
{
	printl("=========================================")
	printl("New Player Lock added  :" + origin )
	printl("=========================================")

	array<entity> ents = []
	entity trigger = _CreateScriptCylinderTriggerInternal( origin, radius, TRIG_FLAG_PLAYERONLY, ents, top, bottom )

	AddCallback_ScriptTriggerLeave( trigger, OnPlayerLockTriggered )
	// AddCallback_ScriptTriggerEnter( trigger, OnPlayerLockTriggered )
}

void function OnPlayerLockTriggered( entity trigger, entity player )
{
	try{
	if ( player != GetPlayerArray()[0] && !save.BreakTriggers )
	{
		player.SetOrigin( trigger.GetOrigin() )
		SendHudMessage( player , "Stop leaving the area or else you might break the game!" , -1, 0.4, 255, 255, 0, 0, 0.15, 6, 0.15 )
	}
	if ( save.BreakTriggers ){
		printl("=========================================")
		printl("Lock trigger broken  :" + save.BreakTriggers )
		printl("=========================================")
		trigger.Destroy()
		save.BreakTriggers = false
	}
	}
	catch( exception ){}
		
}

void function CreatePlayerLockBreakerTrigger(  vector origin, float radius, float top, float bottom )
{
	printl("=========================================")
	printl("New Lock Breaker added  :" + origin )
	printl("=========================================")

	array<entity> ents = []
	entity trigger = _CreateScriptCylinderTriggerInternal( origin, radius, TRIG_FLAG_PLAYERONLY, ents, top, bottom )

	AddCallback_ScriptTriggerEnter( trigger, OnPlayerLockBreakerTriggered )
}

void function OnPlayerLockBreakerTriggered( entity trigger, entity player )
{
	try{
	printl("=========================================")
	printl("breaking lock trigger  :" + !save.BreakTriggers )
	printl("=========================================")
	save.BreakTriggers = true
	trigger.Destroy()
	}
	catch( exception ){}
}

void function CreateGauntletTeleportBackTrigger()
{
	array<entity> ents = []
	entity trigger = _CreateScriptCylinderTriggerInternal( < 2263,7538,304 >, 100.0, TRIG_FLAG_PLAYERONLY, ents, 100.0, 100.0 )

	AddCallback_ScriptTriggerEnter( trigger, OnTeleportBackTriggered )
}

void function OnTeleportBackTriggered( entity trigger, entity player )
{
	player.SetOrigin( < -5677,197,48 > )
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

void function TeleportAllExpectOne( vector destination, entity ornull ThisPlayer, bool display_notification = true )
{
	foreach( entity player in GetPlayerArray() )
	{
		if ( player != ThisPlayer )
		{
			WaitFrame()
			try
			{
				entity mover = CreateOwnedScriptMover( player )
				player.SetParent( mover )
				mover.MoveTo( destination, 0.5, 0, 0 )
				PhaseShift( player, 0.1, 1 )

				player.SetHealth( player.GetMaxHealth() )
				if ( display_notification )
					Chat_ServerPrivateMessage( player, "You are being moved the next checkpoint", false )
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
			}
			catch( exception ){}
		}
	}
}

CheckPointInfo function GetCheckPointInfo()
{
	CheckPointInfo Info

	if ( save.nextCheckpointAsPilot.len() != 0 )
		Info.RsPilot = save.nextCheckpointAsPilot[ save.currentPilotBoolId ]
	
	Info.pos = save.lastSave
	Info.player0 = save.player0
	return Info
}

void function SetPlayer0( entity player )
{
    save.player0 = player
}

entity function GetPlayer0()
{
    return save.player0
}