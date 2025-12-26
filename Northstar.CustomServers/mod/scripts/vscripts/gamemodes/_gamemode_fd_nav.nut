global function singleNav_thread
global function SquadNav_Thread
global function droneNav_thread
global function getRoute
global function Dev_MarkRoute



void function singleNav_thread( entity npc, string routeName, int nodesToSkip= 0, float nextDistance = -1.0, bool shouldLoop = false )
{
	npc.EndSignal( "OnDeath" )
	npc.EndSignal( "OnDestroy" )



	if( !npc.IsNPC() )
		return
	if ( nextDistance == -1 )
		nextDistance = npc.GetMinGoalRadius()


	/*array<entity> routeArray = getRoute(routeName)
	WaitFrame()//so other code setting up what happens on signals is run before this
	if(routeArray.len()==0)
	{

		npc.Signal("OnFailedToPath")
		return
	}
	int skippedNodes = 0
	foreach(entity node in routeArray)
	{
		if(!IsHarvesterAlive(fd_harvester.harvester))
			return
		if(skippedNodes < nodesToSkip)
		{
			skippedNodes++
			continue
		}
		npc.AssaultPoint(node.GetOrigin())
		npc.AssaultSetGoalRadius( 50 )
		int i = 0
		table result = npc.WaitSignal("OnFinishedAssault","OnFailedToPath")
		if(result.signal == "OnFailedToPath")
			break
	}*/

	// NEW STUFF
	WaitFrame() // so other code setting up what happens on signals is run before this

	entity targetNode
	if ( routeName == "" )
	{
		float dist = 1000000000
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

	
	while ( targetNode != null )
	{
		if( !IsHarvesterAlive( fd_harvester.harvester ) )
			return
		npc.AssaultPoint( targetNode.GetOrigin() )
		npc.AssaultSetGoalRadius( nextDistance )
		npc.AssaultSetFightRadius( 0 )
		
		table result = npc.WaitSignal( "OnFinishedAssault", "OnEnterGoalRadius", "OnFailedToPath" )
		
		targetNode = targetNode.GetLinkEnt()
	}

	npc.Signal( "FD_ReachedHarvester" )
}

void function SquadNav_Thread( array<entity> npcs, string routeName, int nodesToSkip = 0, float nextDistance = 200.0 )
{
	//TODO this function wont stop when noone alive anymore also it only works half of the time
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
		float dist = 1000000000
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
	
	while ( targetNode != null )
	{
		if( !IsHarvesterAlive( fd_harvester.harvester ) )
			return
		
		SquadAssaultOrigin( npcs, targetNode.GetOrigin(), nextDistance )
		
		targetNode = targetNode.GetLinkEnt()
	}

}

void function droneNav_thread( entity npc, string routeName,int nodesToSkip= 0,float nextDistance = 500.0, bool shouldLoop = false )
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
		float dist = 1000000000
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