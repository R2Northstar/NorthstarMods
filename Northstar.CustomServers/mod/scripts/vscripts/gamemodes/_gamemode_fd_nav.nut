global function singleNav_thread
global function SquadNav_Thread
global function getRoute
global function CommonAIThink



//┌──────────────┐
//│              │◄──────────┐
//│  AI Pathing  │           │
//│              │    ┌──────┴───────┐   Basic outline of AI goal:
//└──────┬───────┘    │     Wait:    │   1. AI pathing
//       │            │ If no enemy, │      - feed nodes in current path one by one
//       │            │    resume.   │      - stop running if under attack and presuambly return flags like NPC_ALLOW_FLEE
//       │            └──────────────┘
//       │                   ▲           2. Attacked
//       │                   │              - Signal OnFailedToPath
//       │            ┌──────┴───────┐      - cause fallback function to run and not use route nodes anymore
//       │            │ Attacked:    │   3. Wait
//       ├───────────►│ Stop pathing │      - Let a few amount of seconds pass
//       │            │              │      - Check if enemy is still within dist or is still taking continuous damage
//       ▼            └──────────────┘      - If both checks is false, return the AI to pathing thread
//┌──────────────┐
//│              │
//│  Destination │
//│              │
//└──────────────┘

void function CommonAIThink (entity npc, string routeName)
{
	npc.EndSignal( "OnDeath" ) // if dead
	npc.EndSignal( "OnDestroy" ) // if dead
	npc.EndSignal( "OnSyncedMeleeVictim" ) // if getting executed
	npc.EndSignal( "OnFailedToPath" ) // if cant find path or get attacked (not yet implemented)

	waitthread singleNav_thread( npc, routeName )
	// OnFailedToPath would end this function, so assume they reached harvester

	waitthread CheckForInterruption( npc )
	// TODO: continue while(true) checks to see if they get attacked while attacking the harvester
}

void function OnFailedToPathFallback( entity npc )
{
	// ideally this function should run when they get attacked or after 10 seconds of not pathing to the correct spot
	npc.EndSignal( "OnDeath" )
	npc.EndSignal( "OnDestroy" )
	npc.EndSignal( "OnSyncedMeleeVictim" )
	npc.EndSignal( "FD_ReachedHarvester" )
	fd_harvester.harvester.EndSignal("OnDeath")
	fd_harvester.harvester.EndSignal("OnDestroy")
	// ^^^ stop keeping track of this function if they die or reached their goal
	// EndSignal( npc, "OnFailedToPath" ) // credit to @Spoon for telling me this
	print("running failed to path fallback")
	if (!IsAlive(npc))
		return

	waitthread CheckForInterruption( npc ) // first let's make sure they're not being attacked
	print("not being attacked lets keep going")
	// Nuke Titans have their own NukeTitanThink, need to update their pathing as well but for later
	if ( npc.GetTargetName() == "npc_titan_nuke" )
		return

	float checkRadiusSqr = 400 * 400
	float goalRadius = npc.GetMinGoalRadius()

	// we cant use previous route path since they might go back in reverse, so might as well try to figure out if they can go to the harvester manually
	array<vector> pos
	if (npc.IsTitan())
		pos = NavMesh_GetNeighborPositions( fd_harvester.harvester.GetOrigin(), HULL_TITAN, 20 )
	else
		pos = NavMesh_GetNeighborPositions( fd_harvester.harvester.GetOrigin(), HULL_HUMAN, 20 )
	pos = ArrayClosestVector( pos, npc.GetOrigin() )

	array<vector> validPos
	foreach ( point in pos )
	{
		if ( DistanceSqr( fd_harvester.harvester.GetOrigin(), point ) <= checkRadiusSqr && NavMesh_IsPosReachableForAI( npc, point ) )
		{
			validPos.append( point )
			//DebugDrawSphere( point, 32, 255, 0, 0, true, 60 )
		}
	}

	int posLen = validPos.len()

	npc.Signal("StartCounter")
	thread TimeCounter( npc ) // start counting in case of failing to path
	while( posLen >= 1 )
	{
		WaitFrame()
		npc.SetEnemy( fd_harvester.harvester )
		npc.AssaultSetFightRadius( goalRadius )
		thread AssaultOrigin( npc, validPos[0], goalRadius )

		wait 0.5

		if ( DistanceSqr( npc.GetOrigin(), fd_harvester.harvester.GetOrigin() ) > checkRadiusSqr )
			continue

		break
	}
	npc.Signal( "FD_ReachedHarvester" )
	print("titan reached harvester")
}

void function singleNav_thread(entity npc, string routeName,int nodesToScip= 0,float nextDistance = 500.0)
{
	npc.EndSignal( "OnDeath" )
	npc.EndSignal( "OnDestroy" )
	npc.EndSignal( "OnSyncedMeleeVictim" )
	fd_harvester.harvester.EndSignal("OnDeath")
	fd_harvester.harvester.EndSignal("OnDestroy")

	print( "start going through this route" )
	if(!npc.IsNPC())
		return

	bool canwalk = npc.GetNPCMoveFlag( NPCMF_WALK_ALWAYS )
	npc.EnableNPCMoveFlag( NPCMF_WALK_ALWAYS )
	npc.AssaultSetFightRadius( 0 ) // makes them keep moving instead of stopping to shoot you.

	OnThreadEnd(
		function() : ( npc, canwalk )
		{
			if ( !IsValid( npc ) )
				return

			npc.SetNPCMoveFlag( NPCMF_WALK_ALWAYS, canwalk )
		}
	)

	array<entity> routeArray = getRoute(routeName)
	WaitFrame()//so other code setting up what happens on signals is run before this
	if(routeArray.len()==0)
	{
		npc.Signal("OnFailedToPath")
		thread OnFailedToPathFallback(npc)
		print("no path in this route")
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
		if( Distance( node.GetOrigin(), fd_harvester.harvester.GetOrigin()) > Distance( npc.GetOrigin(), fd_harvester.harvester.GetOrigin() ))
		{
			print("node seems to go in reverse, ignoring...")
			continue
		}
		npc.Signal("StartCounter") // end any or previous counter
		thread TimeCounter( npc ) // start counting from 0 again
		npc.AssaultPoint(node.GetOrigin())
		npc.AssaultSetGoalRadius( npc.GetMinGoalRadius() )
		table result = npc.WaitSignal("OnFinishedAssault","OnFailedToPath", "OnEnterGoalRadius")
		string signal = expect string( result.signal )
		if (signal == "OnFailedToPath")
		{
			thread OnFailedToPathFallback( npc )
			print("they triggered on failed to path on their own?")
			return
		}
		print("moving to next node")
		// if finished assault they move to next node, if failed to path, this function ends itself and they use fallback function
	}
	print("titan reached harvester")
	npc.Signal("FD_ReachedHarvester")
}

void function TimeCounter( entity npc, int time = 30 )
{
	Assert(IsNewThread(), "Function is not threaded off.")
	npc.Signal("StartCounter") // make sure there's only 1 counter for this entity
	npc.EndSignal("StartCounter") // can be used to make sure only 1 counter or to end the counter
	npc.EndSignal( "OnDeath" )
	npc.EndSignal( "OnDestroy" )
	npc.EndSignal( "OnSyncedMeleeVictim" )
	npc.EndSignal( "FD_ReachedHarvester" )
	fd_harvester.harvester.EndSignal("OnDeath")
	fd_harvester.harvester.EndSignal("OnDestroy")
	int count = 0
	while (true)
	{
		if (count >= time)
		{
			print("countdown reached. assume failed to path")
			npc.Signal("OnFailedToPath")
			thread OnFailedToPathFallback( npc ) // enough time elapsed and this function hasn't stopped, assume failed to path
			return
		}

		wait 1
		count++
	}
}

void function CheckForInterruption( entity npc )
{
	// goal: check if there's enemy in the vincinity
	// if not, check if took more than 10% damage towards current health
	Assert( IsNewThread(), "Must be threaded off" )

	npc.EndSignal( "OnSyncedMeleeVictim" )
	npc.EndSignal( "OnDeath" )
	npc.EndSignal( "OnDestroy" )
	fd_harvester.harvester.EndSignal("OnDeath")
	fd_harvester.harvester.EndSignal("OnDestroy")

	entity soul
	if (npc.IsTitan())
	{
		soul = npc.GetTitanSoul()
		soul.EndSignal( "OnDestroy" )
	}

	float playerProximityDistSqr = pow( 256, 2 )
	float healthBreakOff
	if (npc.IsTitan())
		healthBreakOff = ( npc.GetHealth() + soul.GetShieldHealth() ) * 0.9
	else
		healthBreakOff = ( npc.GetHealth() * 0.9 )

	while( true )
	{
		if ( !IsEnemyWithinDist( npc, playerProximityDistSqr ) ) // if there's no enemy within proximity
		{
			if ( IsValid(soul) && ( npc.GetHealth() + soul.GetShieldHealth() ) > healthBreakOff ) // if we never loss more than 90% of our current health
			{
				break // continue pathing in fallback function or just attack harvester
			}
			else if ( npc.GetHealth() > healthBreakOff )
				break
		}
		if (npc.IsTitan())
			healthBreakOff = ( npc.GetHealth() + soul.GetShieldHealth() ) * 0.9
		else
			healthBreakOff = ( npc.GetHealth() * 0.9 )

		print("enemy nearby, waiting")
		wait 3
	}
}

bool function IsEnemyWithinDist( entity titan, float dist )
{
	vector origin = titan.GetOrigin()
	array<entity> players = GetPlayerArrayOfEnemies_Alive( titan.GetTeam() )

	foreach( player in players )
	{
		if ( DistanceSqr( player.GetOrigin(), origin ) < dist )
			return true
	}

	return false
}

void function SquadNav_Thread( array<entity> npcs ,string routeName,int nodesToScip = 0,float nextDistance = 200.0)
{
	//TODO this function wont stop when noone alive anymore also it only works half of the time

	foreach( npc in npcs )
		thread SquadNav_SingleThread(npc, routeName, nodesToScip, nextDistance)
}

void function SquadNav_SingleThread( entity npc, string routeName, int nodesToScip = 0, float nextDistance = 200.0)
{
	fd_harvester.harvester.EndSignal("OnDeath")
	fd_harvester.harvester.EndSignal("OnDestroy")
	npc.EndSignal("OnDeath")
	npc.EndSignal("OnDestroy")

	array<entity> routeArray = getRoute(routeName)
	WaitFrame()//so other code setting up what happens on signals is run before this
	if(routeArray.len()==0)
		return

	int nodeIndex = 0
	if (IsStalker(npc))
		routeArray.append( fd_harvester.harvester ) // really dumb fix so that they would run closer to the harvester lmao
	foreach(entity node in routeArray)
	{
		if(!IsAlive(fd_harvester.harvester))
			return
		if(nodeIndex++ < nodesToScip)
			continue

		thread AssaultOrigin(npc,node.GetOrigin(),nextDistance) // this will run thread AssaultOrigin, which waitthread SendAIToAssaultPoint for each separate npc, and if an npc dies, the next iteration in this foreach loop will continue
	}
	npc.Signal("FD_ReachedHarvester")
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
