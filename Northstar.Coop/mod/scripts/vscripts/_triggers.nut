untyped
global function NewSaveLocation
global function TeleportAllExpectOne
global function TriggerManualCheckPoint
global function TriggerSilentCheckPoint
global function Init_triggers
global function GetSaveLocation
global function GetCheckPointInfo
global function SetPlayer0
global function GetPlayer0

// global trigger function
global function OnTeleportTriggered

global struct CheckPointInfo
{
	vector pos
	bool RsPilot = true
	entity player0
}

struct
{
	array<bool> nextCheckpointAsPilot = []
	int currentPilotBoolId = 0

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
			// CreateTeleportTrigger( < 9670,6809,784 >, 500.0, 1000.0, 100.0, true ) // the button closign door
			CreateTeleportTrigger( < -891,1345,288.031 >, 1000.0, 1000.0, 100.0, true ) // the door clsoing when you help militia grunts
			CreateTeleportTrigger( < -7815, 1971, 1936.2 >, 1500.0, 1000.0, 100.0, true ) // the switch
			// CreateTeleportTrigger( < -6384, -6723, 2900 > , 1000.0, 1000.0, 1000.0, false ) // kane's party
			break

		// case "sp_boomtown_start":
		// case "sp_boomtown":
		// case "sp_boomtown_end":
		// 	return eSPLevel.BOOM_TOWN

		case "sp_hub_timeshift":
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
	entity trigger = _CreateScriptCylinderTriggerInternal( origin, radius, TRIG_FLAG_PLAYERONLY  | TRIG_FLAG_ONCE, ents, top, bottom )

	AddCallback_ScriptTriggerEnter( trigger, OnTeleportTriggered )
	// AddCallback_ScriptTriggerLeave( trigger, OnTeleportTriggered )

	save.nextCheckpointAsPilot.append( TpAsPilot )
}

void function OnTeleportTriggered( entity trigger, entity player )
{
	thread OnTeleportTriggeredThreaded( trigger, player )
}

void function OnTeleportTriggeredThreaded( entity trigger, entity player )
{
	printl("=========================================")
	printl("New checkpoint :" + trigger.GetOrigin())
	printl("=========================================")
	
	vector destination = trigger.GetOrigin()
	waitthread TeleportAllExpectOne( destination, player )
	wait 0.1
	
	// super broken
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

	save.lastSave = destination
	save.currentPilotBoolId += 1
}

void function CreateMapChangeTrigger( vector origin, float radius, float top, float bottom)
{
	array<entity> ents = []
	entity trigger = _CreateScriptCylinderTriggerInternal( origin, radius, TRIG_FLAG_PLAYERONLY | TRIG_FLAG_PLAYERONLY  | TRIG_FLAG_ONCE, ents, top, bottom )

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

void function CreateGauntletTeleportBackTrigger()
{
	array<entity> ents = []
	entity trigger = _CreateScriptCylinderTriggerInternal( < 2263,7538,304 >, 150.0, TRIG_FLAG_PLAYERONLY, ents, 100.0, 100.0 )

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
				MakeInvincible( player )
				entity mover = CreateOwnedScriptMover( player )
				player.SetParent( mover )
				mover.MoveTo( destination, 0.5, 0, 0 )
				PhaseShift( player, 0.1, 1 )

				player.SetHealth( player.GetMaxHealth() )
				if ( display_notification )
					Chat_ServerPrivateMessage( player, "You are being moved to the next checkpoint", false )
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
			}
			catch( exception ){}
		}
	}
}

void function TriggerManualCheckPoint( entity ornull player, vector origin, bool IsPilotSpawn )
{
	NewSaveLocation( origin )
	waitthread TeleportAllExpectOne( origin, player )
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
	
	// save.currentPilotBoolId += 1
	save.lastCheckpointWasAsPilot = IsPilotSpawn
	// save.nextCheckpointAsPilot.insert( save.currentPilotBoolId, IsPilotSpawn )
}

void function TriggerSilentCheckPoint( vector origin, bool IsPilotSpawn )
{
	NewSaveLocation( origin )
	// save.currentPilotBoolId += 1
	save.lastCheckpointWasAsPilot = IsPilotSpawn
	// save.nextCheckpointAsPilot.insert( save.currentPilotBoolId, IsPilotSpawn )
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
    save.player0 = player
}

entity function GetPlayer0()
{
    return save.player0
}