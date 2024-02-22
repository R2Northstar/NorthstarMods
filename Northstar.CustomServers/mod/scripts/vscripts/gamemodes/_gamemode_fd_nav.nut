global function singleNav_thread
global function droneNav_thread
global function Dev_ShowRoute
global function NPCStuckTracker

/*
███╗   ██╗██████╗  ██████╗    ███╗   ██╗ █████╗ ██╗   ██╗██╗ ██████╗  █████╗ ████████╗██╗ ██████╗ ███╗   ██╗
████╗  ██║██╔══██╗██╔════╝    ████╗  ██║██╔══██╗██║   ██║██║██╔════╝ ██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║
██╔██╗ ██║██████╔╝██║         ██╔██╗ ██║███████║██║   ██║██║██║  ███╗███████║   ██║   ██║██║   ██║██╔██╗ ██║
██║╚██╗██║██╔═══╝ ██║         ██║╚██╗██║██╔══██║╚██╗ ██╔╝██║██║   ██║██╔══██║   ██║   ██║██║   ██║██║╚██╗██║
██║ ╚████║██║     ╚██████╗    ██║ ╚████║██║  ██║ ╚████╔╝ ██║╚██████╔╝██║  ██║   ██║   ██║╚██████╔╝██║ ╚████║
╚═╝  ╚═══╝╚═╝      ╚═════╝    ╚═╝  ╚═══╝╚═╝  ╚═╝  ╚═══╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝
*/

void function singleNav_thread( entity npc, string routeName, int nodesToSkip = 1, float nextDistance = -1.0, bool shouldLoop = false )
{
	npc.EndSignal( "OnDeath" )
	npc.EndSignal( "OnDestroy" )
	npc.EndSignal( "OnLeeched" )

	Assert( IsValid( npc ) && npc.IsNPC(), "AI Navigation function called in non-NPC entity: " + npc )
	
	if ( nextDistance == -1 && ( npc.IsTitan() || IsSpectre( npc ) ) )
		nextDistance = npc.GetMinGoalRadius()
	else if ( nextDistance == -1 )
		nextDistance = 160

	string npcName = npc.GetTargetName()

	WaitFrame()
	float dist = 65535
	entity targetNode
	string routetaken
	string routeCompare
	string GuySquadName = expect string( npc.kv.squadname )
	array<entity> squad
	if ( GuySquadName != "" )
		squad = GetNPCArrayBySquad( GuySquadName )
	
	if( !npc.IsTitan() )
		thread NPCStuckTracker( npc )
	
	if( !useCustomFDLoad )
	{
		if ( routeName == "" )
		{
			foreach ( entity node in routeNodes )
			{
				if( !node.HasKey( "route_name" ) )
					continue
				
				routeCompare = expect string( node.kv.route_name ).tolower()
				if( routeCompare.find( "drone" ) && !IsAirDrone( npc ) ) //Non-Drones skips
					continue
				
				if( routeCompare.find( "infantry" ) && !(IsMinion( npc ) || IsStalker( npc )) ) //Non-Grunt, Spectres, Stalker skips
					continue
				
				if( routeCompare.find( "reaper" ) && !IsSuperSpectre( npc ) ) //Non-Reapers skips
					continue
				
				if( routeCompare.find( "tick" ) && !IsFragDrone( npc ) ) //Non-Ticks skip (War Games uses this mostly)
					continue
				
				if( squad.len() > 0 )
				{
					if ( Distance( squad[0].GetOrigin(), node.GetOrigin() ) < dist )
					{
						dist = Distance( squad[0].GetOrigin(), node.GetOrigin() )
						targetNode = node
					}
				}
				else if ( Distance( npc.GetOrigin(), node.GetOrigin() ) < dist )
				{
					dist = Distance( npc.GetOrigin(), node.GetOrigin() )
					targetNode = node
				}
			}
			#if SERVER && DEV
			if( squad.len() > 0 )
			{
				if( npc == squad[0] )
					printt( "Squad entities had no route defined, using nearest node: " + targetNode.kv.route_name )
			}
			else
				printt( "Single entity had no route defined, using nearest node: " + targetNode.kv.route_name )
			#endif
		}
		else
			targetNode = GetRouteStart( routeName )

		// skip nodes
		for ( int i = 0; i < nodesToSkip; i++ )
			targetNode = targetNode.GetLinkEnt()
	}
	else
	{
		if ( routeName == "" )
		{
			foreach ( routename, routeamount in routes )
			{
				routeCompare = routename.tolower()
				if( routeCompare.find( "drone" ) && !IsAirDrone( npc ) ) //Non-Drones skips
					continue
				
				if( routeCompare.find( "infantry" ) && !(IsMinion( npc ) || IsStalker( npc )) ) //Non-Grunt, Spectres, Stalker skips
					continue
				
				if( routeCompare.find( "reaper" ) && !IsSuperSpectre( npc ) ) //Non-Reapers skips
					continue
				
				if( routeCompare.find( "tick" ) && !IsFragDrone( npc ) ) //Non-Ticks skip (War Games uses this mostly)
					continue
				
				if( squad.len() > 0 )
				{
					if ( Distance( squad[0].GetOrigin(), routeamount[0] ) < dist )
					{
						dist = Distance( squad[0].GetOrigin(), routeamount[0] )
						routetaken = routename
					}
				}
				else if ( Distance( npc.GetOrigin(), routeamount[0] ) < dist )
				{
					dist = Distance( npc.GetOrigin(), routeamount[0] )
					routetaken = routename
				}
			}
			#if SERVER && DEV
			if( squad.len() > 0 )
			{
				if( npc == squad[0] )
					printt( "Squad entities had no route defined, using nearest node: " + routetaken )
			}
			else
				printt( "Single entity had no route defined, using nearest node: " + routetaken )
			#endif
		}
		else
			routetaken = routeName
	}

	//Ticks, Arc Titans, Combat Reapers and Elite Titans have their own Fight Radii defined in spawn code
	if ( npc.GetClassName() != "npc_frag_drone" && npcName != "empTitan" && !IsSuperSpectre( npc ) && npc.ai.bossTitanType != TITAN_MERC )
		npc.AssaultSetFightRadius( 0 )
	
	if( !useCustomFDLoad )
	{
		while ( targetNode != null )
		{
			if( !IsHarvesterAlive( fd_harvester.harvester ) )
				return
			npc.AssaultPointClamped( targetNode.GetOrigin() )
			npc.AssaultSetGoalRadius( nextDistance )
			
			table result = npc.WaitSignal( "OnFinishedAssault", "OnEnterGoalRadius", "OnFailedToPath" )
			
			/*
			if( result.signal == "OnFailedToPath" && !npc.IsTitan() && !IsSuperSpectre( npc ) )
			{
				entity enemy = npc.GetEnemy()
				if( EntityInSolid( npc ) && enemy == null )
				{
					vector ornull clampedPos = NavMesh_ClampPointForAIWithExtents( targetNode.GetOrigin(), npc, < 80, 80, 256 > )
					if ( clampedPos != null && Distance2D( npc.GetOrigin(), expect vector( clampedPos ) ) < 512 )
						npc.SetOrigin( expect vector( clampedPos ) )
				}
			}
			*/
			
			targetNode = targetNode.GetLinkEnt()
		}
	}
	
	else
	{
		int routeindex = nodesToSkip
		vector routepoint = routes[routetaken][routeindex]
		while ( true )
		{
			if( !IsHarvesterAlive( fd_harvester.harvester ) )
				return
			npc.AssaultPointClamped( routepoint )
			npc.AssaultSetGoalRadius( nextDistance )
			
			table result = npc.WaitSignal( "OnFinishedAssault", "OnEnterGoalRadius", "OnFailedToPath" )
			/*
			if( result.signal == "OnFailedToPath" && !npc.IsTitan() && !IsSuperSpectre( npc ) )
			{
				entity enemy = npc.GetEnemy()
				if( EntityInSolid( npc ) && enemy != null )
				{
					vector ornull clampedPos = NavMesh_ClampPointForAIWithExtents( npc.GetOrigin(), npc, < 80, 80, 250 > )
					if ( clampedPos != null )
						npc.SetOrigin( expect vector( clampedPos ) )
				}
				else
				{
					vector ornull clampedPos = NavMesh_ClampPointForAIWithExtents( routepoint, npc, < 80, 80, 80 > )
					if ( clampedPos != null && Distance2D( npc.GetOrigin(), expect vector( clampedPos ) ) < 512 )
						npc.SetOrigin( expect vector( clampedPos ) )
				}
			}
			*/
			routeindex++
			if( routeindex < routes[routetaken].len() )
				routepoint = routes[routetaken][routeindex]
			else
				break
		}
	}

	if ( ( npc.GetClassName() == "npc_frag_drone" || npc.GetClassName() == "npc_stalker" ) && IsHarvesterAlive( fd_harvester.harvester ) )
	{
		npc.AssaultPointClamped( fd_harvester.harvester.GetOrigin() + < 0, 0, 16 > )
		npc.AssaultSetGoalRadius( 128 )
	}

	npc.Signal( "FD_ReachedHarvester" )
}

void function droneNav_thread( entity npc, string routeName, int nodesToSkip = 0, float nextDistance = 160.0, bool shouldLoop = false )
{
	npc.EndSignal( "OnDeath" )
	npc.EndSignal( "OnDestroy" )
	npc.EndSignal( "OnLeeched" )

	Assert( IsValid( npc ) && npc.IsNPC(), "AI Navigation function called in non-NPC entity: " + npc )

	WaitFrame()
	float dist = 65535
	entity targetNode
	entity firstNode
	string routetaken
	string GuySquadName = expect string( npc.kv.squadname )
	array<entity> squad
	if ( GuySquadName != "" )
		squad = GetNPCArrayBySquad( GuySquadName )
	
	if( !npc.IsTitan() )
		thread NPCStuckTracker( npc )
	
	npc.AssaultSetGoalHeight( 128 )
	npc.AssaultSetFightRadius( 0 )
	
	if( !useCustomFDLoad )
	{
		if ( routeName == "" )
		{
			foreach ( entity node in routeNodes )
			{
				if( !node.HasKey( "route_name" ) )
					continue
				if( squad.len() > 0 )
				{
					if ( Distance( squad[0].GetOrigin(), node.GetOrigin() ) < dist )
					{
						dist = Distance( squad[0].GetOrigin(), node.GetOrigin() )
						targetNode = node
						firstNode = node
					}
				}
				else if ( Distance( npc.GetOrigin(), node.GetOrigin() ) < dist )
				{
					dist = Distance( npc.GetOrigin(), node.GetOrigin() )
					targetNode = node
					firstNode = node
				}
			}
			#if SERVER && DEV
			if( squad.len() > 0 )
			{
				if( npc == squad[0] )
					printt( "Squad entities had no route defined, using nearest node: " + targetNode.kv.route_name )
			}
			else
				printt( "Single entity had no route defined, using nearest node: " + targetNode.kv.route_name )
			#endif
		}
		else
			targetNode = GetRouteStart( routeName )

		// skip nodes
		for ( int i = 0; i < nodesToSkip; i++ )
		{
			targetNode = targetNode.GetLinkEnt()
			firstNode = targetNode.GetLinkEnt()
		}
	}
	else
	{
		if ( routeName == "" )
		{
			foreach ( routename, routeamount in routes )
			{
				if( squad.len() > 0 )
				{
					if ( Distance( squad[0].GetOrigin(), routeamount[0] ) < dist )
					{
						dist = Distance( squad[0].GetOrigin(), routeamount[0] )
						routetaken = routename
					}
				}
				else if ( Distance( npc.GetOrigin(), routeamount[0] ) < dist )
				{
					dist = Distance( npc.GetOrigin(), routeamount[0] )
					routetaken = routename
				}
			}
			#if SERVER && DEV
			if( squad.len() > 0 )
			{
				if( npc == squad[0] )
					printt( "Squad entities had no route defined, using nearest node: " + routetaken )
			}
			else
				printt( "Single entity had no route defined, using nearest node: " + routetaken )
			#endif
		}
		else
			routetaken = routeName
	}

	if( !useCustomFDLoad )
	{
		while ( targetNode != null )
		{
			if( !IsHarvesterAlive( fd_harvester.harvester ) )
				return
			npc.AssaultPoint( targetNode.GetOrigin() + < 0, 0, 192 > )
			npc.AssaultSetGoalRadius( nextDistance )
			
			table result = npc.WaitSignal( "OnFinishedAssault", "OnEnterGoalRadius", "OnFailedToPath" )
			
			targetNode = targetNode.GetLinkEnt()
			#if SERVER && DEV
			if ( targetNode == null )
				printt( "drone finished pathing" )
			#endif
			if ( targetNode == null && shouldLoop )
			{
				#if SERVER && DEV
				printt( "drone reached end of loop, looping" )
				#endif
				targetNode = firstNode
			}
		}
	}
	
	else
	{
		int routeindex = nodesToSkip
		vector routepoint = routes[routetaken][routeindex]
		while ( true )
		{
			if( !IsHarvesterAlive( fd_harvester.harvester ) )
				return
			npc.AssaultPoint( routepoint + < 0, 0, 192 > )
			npc.AssaultSetGoalRadius( nextDistance )
			
			table result = npc.WaitSignal( "OnFinishedAssault", "OnEnterGoalRadius", "OnFailedToPath" )
			
			routeindex++
			if( routeindex < routes[routetaken].len() )
				routepoint = routes[routetaken][routeindex]
			else
			{
				if( shouldLoop )
				{
					#if SERVER && DEV
					printt( "drone reached end of loop, looping" )
					#endif
					routeindex = 0
					routepoint = routes[routetaken][routeindex]
				}
				else
				{
					#if SERVER && DEV
					printt( "drone finished pathing" )
					#endif
					break
				}
			}
		}
	}

	npc.Signal( "FD_ReachedHarvester" )
}

entity function GetRouteStart( string routeName )
{
	foreach( entity node in routeNodes )
	{
		if( !node.HasKey( "route_name" ) )
			continue
		if( expect string( node.kv.route_name ) == routeName )
			return node
	}
}

void function Dev_ShowRoute( bool includedrones = false )
{
	if( !useCustomFDLoad )
	{
		string routename
		foreach( entity node in routeNodes )
		{
			if( !node.HasKey( "route_name" ) )
				continue
				
			routename = expect string( node.kv.route_name )
			entity routetitle = CreatePointMessage( routename, node.GetOrigin() + < 0, 0, 32 >, 800 )
			if( routename.tolower().find( "drone" ) && includedrones )
				thread DroneTracksPathing( routename )
			else if( routename.tolower().find( "drone" ) || routename.tolower().find( "reaper" ) )
				continue
			else
				thread GruntTracksPathing( routename )
		}
	}
	else
	{
		foreach( routename, routeamount in routes )
		{
			entity routetitle = CreatePointMessage( routename, routeamount[0], 800 )
			if( includedrones && routename.tolower().find( "drone" ) )
				thread DroneTracksPathing( routename )
			else
				thread GruntTracksPathing( routename )
		}
	}
}

void function GruntTracksPathing( string route )
{
	vector routeorigin = < 0, 0, 0 >
	if( useCustomFDLoad )
		routeorigin = routes[route][0]
	else
		routeorigin = GetRouteStart( route ).GetOrigin()
	
	entity guy = CreateSoldier( TEAM_MILITIA, routeorigin, < 0, 0, 0 > )
	DispatchSpawn( guy )
	PlayLoopFXOnEntity( $"P_ar_holopilot_trail", guy, "CHESTFOCUS" )
	
	guy.NotSolid()
	guy.EnableNPCFlag( NPC_DISABLE_SENSING | NPC_IGNORE_ALL )
	guy.EnableNPCMoveFlag( NPCMF_PREFER_SPRINT )
	NPC_NoTarget( guy )
	
	WaitFrame()
	guy.SetTitle( route )
	while( IsAlive( guy ) )
	{
		thread singleNav_thread( guy, route )
		table result = guy.WaitSignal( "FD_ReachedHarvester" )
		wait 5.0
		if( IsValid( guy ) )
			guy.SetOrigin( routeorigin )
	}
}

void function DroneTracksPathing( string route )
{
	vector routeorigin = < 0, 0, 0 >
	if( useCustomFDLoad )
		routeorigin = routes[route][0]
	else
		routeorigin = GetRouteStart( route ).GetOrigin()
	
	entity guy = CreateGenericDrone( TEAM_MILITIA, routeorigin + < 0, 0, 32 >, < 0, 0, 0 > )
	SetSpawnOption_AISettings( guy, "npc_drone_plasma_fd" )
	DispatchSpawn( guy )
	PlayLoopFXOnEntity( $"P_ar_holopilot_trail", guy )
	
	guy.NotSolid()
	guy.EnableNPCFlag( NPC_DISABLE_SENSING | NPC_IGNORE_ALL )
	guy.EnableNPCMoveFlag( NPCMF_PREFER_SPRINT )
	NPC_NoTarget( guy )
	
	WaitFrame()
	guy.SetTitle( route )
	thread droneNav_thread( guy, route )
}

void function NPCStuckTracker( entity npc ) //Track if AI is properly pathing, otherwise after ten seconds, it will suicide to prevent softlocking
{
	npc.EndSignal( "OnDeath" )
	npc.EndSignal( "OnDestroy" )
	
	int FailCount = 0
	while ( IsAlive( npc ) )
	{
		table result = npc.WaitSignal( "OnSeeEnemy", "OnFinishedAssault", "OnEnterGoalRadius", "OnFailedToPath" )
		if( result.signal == "OnFailedToPath" )
		{
			if( FailCount == 10 )
				npc.Die()
			FailCount++
		}
		else
			FailCount = 0
			
		wait 1
	}
}