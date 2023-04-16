global function singleNav_thread
global function SquadNav_Thread
global function droneNav_thread
global function getRoute
global function Dev_MarkRoute



void function singleNav_thread( entity npc, string routeName, int nodesToSkip = 1, float nextDistance = -1.0, bool shouldLoop = false )
{
	npc.EndSignal( "OnDeath" )
	npc.EndSignal( "OnDestroy" )

	if( !npc.IsNPC() )
		return
	if ( nextDistance == -1 )
		nextDistance = npc.GetMinGoalRadius()

	npc.AssaultSetGoalHeight( 512 )
	string npcName = npc.GetTargetName()

	WaitFrame()

	entity targetNode
	if ( routeName == "" )
	{
		float dist = 65535
		foreach ( entity node in routeNodes )
		{
			if( !node.HasKey( "route_name" ) )
				continue
			if ( Distance( npc.GetOrigin(), node.GetOrigin() ) < dist )
			{
				dist = Distance( npc.GetOrigin(), node.GetOrigin() )
				targetNode = node
			}
		}
		
		printt("Entity had no route defined: using nearest node: " + targetNode.kv.route_name)
	}
	else
	{
		targetNode = GetRouteStart( routeName )
	}

	// skip nodes
	for ( int i = 0; i < nodesToSkip; i++ )
	{
		targetNode = targetNode.GetLinkEnt()
	}

	//Do not make Ticks ignore potential targets just to charge at the Harvester
	//Arc Titans apparently also stops to fight players on place rather that fiercely push forward
	if ( npc.GetClassName() == "npc_frag_drone" || npcName == "npc_titan_stryder_leadwall_arc" )
		npc.AssaultSetFightRadius( expect int( npc.Dev_GetAISettingByKeyField( "LookDistDefault_Combat" ) ) )
	else
		npc.AssaultSetFightRadius( 0 )
	
	int FailCount = 0
	while ( targetNode != null )
	{
		if( !IsHarvesterAlive( fd_harvester.harvester ) )
			return
		npc.AssaultPointClamped( targetNode.GetOrigin() )
		npc.AssaultSetGoalRadius( nextDistance )
		
		table result = npc.WaitSignal( "OnFinishedAssault", "OnEnterGoalRadius", "OnFailedToPath" )
		
		targetNode = targetNode.GetLinkEnt()
	}

	if ( ( npc.GetClassName() == "npc_frag_drone" || npc.GetClassName() == "npc_stalker" ) && IsHarvesterAlive( fd_harvester.harvester ) )
	{
		npc.AssaultPointClamped( fd_harvester.harvester.GetOrigin() + < 0, 0, 16 > )
		npc.AssaultSetGoalRadius( 64 )
	}

	npc.Signal( "FD_ReachedHarvester" )
	
	while ( IsAlive( npc ) && !npc.IsTitan() ) //Track if AI is properly pathing, otherwise after one minute, it will suicide to prevent softlocking
	{
		table result = npc.WaitSignal( "OnSeeEnemy", "OnFinishedAssault", "OnEnterGoalRadius", "OnFailedToPath" )
		if( result.signal == "OnFailedToPath" )
		{
			if( FailCount == 60 )
				npc.Die()
			FailCount++
		}
		else
			FailCount = 0

		wait 1
	}
}

void function SquadNav_Thread( array<entity> npcs, string routeName, int nodesToSkip = 0, float nextDistance = 64.0 )
{
	//TODO this function wont stop when noone alive anymore also it only works half of the time
	
	/* This function actually is not working AT ALL, all what it actually does is pick the entire chain of nodes of a route send everyone directly to the
	last node, apparently it is also the function responsible for not allowing Grunts and Stalkers to execute their Drop Pod exit animation. The reason of
	that is solely because SquadAssaultOrigin is a chained function which leads to SendAIToAssaultPoint which has guy.Anim_Stop(), so basically that is
	the problem. */
	
	/*
	array<entity> routeArray = getRoute(routeName)
	WaitFrame()//so other code setting up what happens on signals is run before this
	if(routeArray.len()==0)
		return
	int nodeIndex = 0
	foreach(entity node in routeArray)
	{
		if(!IsHarvesterAlive(fd_harvester.harvester))
			return
		if(nodeIndex++ < nodesToSkip)
			continue
		
		SquadAssaultOrigin(npcs,node.GetOrigin(),nextDistance)
	}*/
	// NEW STUFF
	WaitFrame() // so other code setting up what happens on signals is run before this

	entity targetNode
	if ( routeName == "" )
	{
		float dist = 65535
		foreach ( entity node in routeNodes )
		{
			if( !node.HasKey( "route_name" ) )
				continue
			if ( Distance( npcs[0].GetOrigin(), node.GetOrigin() ) < dist )
			{
				dist = Distance( npcs[0].GetOrigin(), node.GetOrigin() )
				targetNode = node
			}
		}
		printt("Entity had no route defined: using nearest node: " + targetNode.kv.route_name)
	}
	else
	{
		targetNode = GetRouteStart( routeName )
	}

	// skip nodes
	for ( int i = 0; i < nodesToSkip; i++ )
	{
		targetNode = targetNode.GetLinkEnt()
	}
	
	while ( targetNode != null && npcs.len() > 0 )
	{
		if( !IsHarvesterAlive( fd_harvester.harvester ) )
			return
		
		SquadAssaultOrigin( npcs, targetNode.GetOrigin() , nextDistance )
		
		targetNode = targetNode.GetLinkEnt()
	}
}

void function droneNav_thread( entity npc, string routeName, int nodesToSkip= 0, float nextDistance = 64.0, bool shouldLoop = false )
{
	npc.EndSignal( "OnDeath" )
	npc.EndSignal( "OnDestroy" )

	if( !npc.IsNPC() )
		return


	// NEW STUFF
	WaitFrame() // so other code setting up what happens on signals is run before this

	entity targetNode
	entity firstNode
	if ( routeName == "" )
	{
		float dist = 65535
		foreach ( entity node in routeNodes )
		{
			if( !node.HasKey( "route_name" ) )
				continue
			if ( Distance( npc.GetOrigin(), node.GetOrigin() ) < dist )
			{
				dist = Distance( npc.GetOrigin(), node.GetOrigin() )
				targetNode = node
				firstNode = node
			}
		}
		printt( "Entity had no route defined: using nearest node: " + targetNode.kv.route_name )
	}
	else
	{
		targetNode = GetRouteStart( routeName )
	}

	// skip nodes
	for ( int i = 0; i < nodesToSkip; i++ )
	{
		targetNode = targetNode.GetLinkEnt()
		firstNode = targetNode.GetLinkEnt()
	}

	
	while ( targetNode != null )
	{
		if( !IsHarvesterAlive( fd_harvester.harvester ) )
			return
		npc.AssaultPoint( targetNode.GetOrigin() + <0, 0, 300> )
		npc.AssaultSetGoalRadius( nextDistance )
		npc.AssaultSetGoalHeight( 100 )
		npc.AssaultSetFightRadius( 0 )
		
		table result = npc.WaitSignal( "OnFinishedAssault", "OnEnterGoalRadius", "OnFailedToPath" )
		
		targetNode = targetNode.GetLinkEnt()
		if ( targetNode == null )
			printt( "drone finished pathing" )
		if ( targetNode == null && shouldLoop )
		{
			printt( "drone reached end of loop, looping" )
			targetNode = firstNode
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
		{
			return node
		}
	}
}

array<entity> function getRoute( string routeName )
{
	array<entity> ret
	array<entity> currentNode = []
	foreach(entity node in routeNodes)
	{
		if( !node.HasKey( "route_name" ) )
			continue
		if( node.kv.route_name == routeName )
		{
			currentNode =  [node]
			break
		}

	}
	if( currentNode.len() == 0 )
	{
		printt( "Route not found" )
		return []
	}
	while( currentNode.len() != 0 )
	{
		ret.append( currentNode[0] )
		currentNode = currentNode[0].GetLinkEntArray()
	}
	return ret
}

void function Dev_MarkRoute( string routename )
{
	foreach( entity e in getRoute( routename ) )
	{
		DebugDrawSphere( e.GetOrigin(), 30.0, 255, 0, 255, false, 40 )
	}
}