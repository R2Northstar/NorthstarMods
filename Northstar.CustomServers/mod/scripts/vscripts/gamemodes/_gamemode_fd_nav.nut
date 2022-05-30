global function singleNav_thread
global function SquadNav_Thread
global function getRoute



void function singleNav_thread(entity npc, string routeName,int nodesToScip= 0,float nextDistance = 500.0)
{
	npc.EndSignal( "OnDeath" )
	npc.EndSignal( "OnDestroy" )



	if(!npc.IsNPC()){
		return
	}
		


	array<entity> routeArray = getRoute(routeName)
	WaitFrame()//so other code setting up what happens on signals is run before this
	if(routeArray.len()==0)
	{

		npc.Signal("OnFailedToPath")
		return
	}
	int scippedNodes = 0
	foreach(entity node in routeArray)
	{
		if(!IsAlive(fd_harvester.harvester))
			return
		if(scippedNodes < nodesToScip)
		{
			scippedNodes++
			continue
		}
		npc.AssaultPoint(node.GetOrigin())
		npc.AssaultSetGoalRadius( 50 )
		int i = 0
		table result = npc.WaitSignal("OnFinishedAssault","OnFailedToPath")
		if(result.signal == "OnFailedToPath")
			break
	}
	npc.Signal("FD_ReachedHarvester")
}

void function SquadNav_Thread( array<entity> npcs ,string routeName,int nodesToScip = 0,float nextDistance = 200.0)
{
	//TODO this function wont stop when noone alive anymore also it only works half of the time

	array<entity> routeArray = getRoute(routeName)
	WaitFrame()//so other code setting up what happens on signals is run before this
	if(routeArray.len()==0)
		return

	int nodeIndex = 0
	foreach(entity node in routeArray)
	{
		if(!IsAlive(fd_harvester.harvester))
			return
		if(nodeIndex++ < nodesToScip)
			continue
		
		SquadAssaultOrigin(npcs,node.GetOrigin(),nextDistance)

	}

}

array<entity> function getRoute(string routeName)
{
	array<entity> ret
	array<entity> currentNode = []
	foreach(entity node in routeNodes)
	{
		if(!node.HasKey("route_name"))
			continue
		if(node.kv.route_name==routeName)
		{
			currentNode =  [node]
			break
		}

	}
	if(currentNode.len()==0)
	{
		printt("Route not found")
		return []
	}
	while(currentNode.len()!=0)
	{
		ret.append(currentNode[0])
		currentNode = currentNode[0].GetLinkEntArray()
	}
	return ret
}