global function S2S_FlightInit

//designer utility
global function ShipFlyToPos
global function ShipFlyToRelativePos
global function ShipIdleAtTargetEnt
global function ShipIdleAtTargetEnt_Method2
global function ShipIdleAtTargetPos
global function ShipIdleUnderTargetEnt
global function EnableHullCrossing
global function DisableHullCrossing
global function SetChaseEnemy
global function SetMaxSpeed
global function SetMaxAcc
global function ResetMaxSpeed
global function ResetMaxAcc
global function SetMaxRoll
global function SetMaxPitch
global function ResetMaxRoll
global function ResetMaxPitch
global function SetBankTime
global function ResetBankTime
global function SetFlyBounds
global function SetFlyOffset
global function SetSeekAhead
global function GetCurrentTrajectoryAtFullDeceleration
global function GetStopDistanceAtFullDeceleration

//behavior utilities
global function __ShipFlyAlongEdge
global function __ShipFollowShip
global function __ShipIdleAtTarget
global function __ShipIdleAtTarget_Method2
global function __ShipFlyToPosInternal
global function __ShipIdleUnderTarget
global function GetBestSideFromEvent
global function GetBestEdgeData
global function CanGetEdgeData


const float DONOTCHECK = -999
const float MINGOALDIST = 50.0
const float MINGOALDISTSQR = pow( MINGOALDIST, 2 )
const int GOAL_UNREACHED = 0
const int GOAL_AT_RADIUS = 1
const int GOAL_AT_FINAL = 2


struct FollowFlightStruct
{
	float timeApplyGoal

	vector newOffset = < 0,0,0 >
	vector goalOffset = < 0,0,0 >
	LocalVec prevOrigin
	LocalVec goalPos
}

void function S2S_FlightInit()
{
	RegisterSignal( "NewFlyStyle" )
}

/************************************************************************************************\

 ██████╗ ██████╗ ██████╗ ███████╗    ██╗      ██████╗  ██████╗ ██╗ ██████╗
██╔════╝██╔═══██╗██╔══██╗██╔════╝    ██║     ██╔═══██╗██╔════╝ ██║██╔════╝
██║     ██║   ██║██████╔╝█████╗      ██║     ██║   ██║██║  ███╗██║██║
██║     ██║   ██║██╔══██╗██╔══╝      ██║     ██║   ██║██║   ██║██║██║
╚██████╗╚██████╔╝██║  ██║███████╗    ███████╗╚██████╔╝╚██████╔╝██║╚██████╗
 ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝    ╚══════╝ ╚═════╝  ╚═════╝ ╚═╝ ╚═════╝

\************************************************************************************************/
LocalVec function MoveToPosWithEase( ShipStruct ship, entity mover, LocalVec goalOrigin, LocalVec goalVelocity, LocalVec currVel, float acc, float maxSpeed )
{
	//KEY THAT EVERY ORIGIN INSIDE THIS FUNCTION IS LOCAL SPACE
	float dec = acc //higher dec doesn't actually work - because it calculates and says i can keep acc because my dec is so high
	LocalVec moverOrigin = GetOriginLocal( mover )
	vector dirToGoal = goalOrigin.v - moverOrigin.v
	float distToGoal = Length( dirToGoal )

	vector relStartVel = currVel.v - goalVelocity.v

	dirToGoal = Normalize( dirToGoal )

	vector newVel

	float thisRelStartVel = DotProduct( relStartVel, dirToGoal )
	{
		float decerateDist = pow( thisRelStartVel, 2 ) / (2 * dec)
		decerateDist += thisRelStartVel * FRAME_INTERVAL // decelerate early to account for per-frame error

		float thisNewVel
		if ( distToGoal <= decerateDist && thisRelStartVel > 0.0 )
		{
			thisNewVel = thisRelStartVel - dec * FRAME_INTERVAL
		}
		else
		{
			float maxDesiredVel = distToGoal / FRAME_INTERVAL

			thisNewVel = min( thisRelStartVel + acc * FRAME_INTERVAL, maxDesiredVel )
		}

		newVel = thisNewVel * dirToGoal
	}

	vector perpRelStartVel = relStartVel - ( thisRelStartVel * dirToGoal )
	{
		float perpVelLen = Length( perpRelStartVel )
		float newPerpVelLen = perpVelLen - dec * FRAME_INTERVAL
		if ( newPerpVelLen > 0.0 )
			newVel += perpRelStartVel * (newPerpVelLen / perpVelLen)
	}

	newVel += goalVelocity.v

	if ( Length( newVel ) > maxSpeed )
	 	newVel = Normalize( newVel ) * maxSpeed

	LocalVec nextFramePos = CLVec( moverOrigin.v + ( newVel * FRAME_INTERVAL * 1.5 ) )
	mover.l.lastMoveToTime = Time()
	NonPhysicsMoveToLocal( mover, nextFramePos, FRAME_INTERVAL * 1.5, 0, 0 )
	//mover.l.localSpaceOrigin.v = CLVec( moverOrigin.v + ( newVel * FRAME_INTERVAL ) ).v

	return CLVec( newVel )
}

FollowFlightStruct function FollowFlight_Movement( ShipStruct ship, FollowFlightStruct flightData, LocalVec baseOrigin, vector baseAngles, vector followBounds, entity targetEnt, bool method2 = false )
{
	//KEY THAT EVERY ORIGIN INSIDE THIS FUNCTION IS LOCAL SPACE
	float currTime 	= Time()
	entity mover 	= ship.mover
	float dec 		= -ship.accMax

	vector newOffset = flightData.newOffset
	LocalVec finalGoal 	= CLVec( baseOrigin.v + flightData.newOffset )
	LocalVec trajectory = GetCurrentTrajectoryAtFullDeceleration( mover, dec )

	//Get extra dist from the velocity of the target
	vector targetVec = <0,0,0>
	if ( targetEnt != null && targetEnt != WORLD_CENTER )
	{
		vector targetVel = GetVelocityLocal( targetEnt ).v
		vector velocity = GetVelocityLocal( mover ).v

		if ( method2 )
		{
			velocity 		= < velocity.x, velocity.y - targetVel.y, velocity.z >
			trajectory = GetCurrentTrajectoryAtFullDeceleration( mover, dec, velocity )
		}

		float speed 	= velocity.Length()
		float stopTime 	= GetStopTimeAtFullDeceleration( speed, dec )
		targetVec 		= targetVel * stopTime
	}

	vector PF = finalGoal.v + targetVec - GetOriginLocal( mover ).v
	vector TF = finalGoal.v - trajectory.v
	float dot = DotProduct( PF, TF )
	float distSqr = DistanceSqr( finalGoal.v, trajectory.v )

	//will our current trajectory take us past our goal?
	if ( distSqr <= 50 || dot < 0 )
	{
		#if DEV
			if ( ( DEV_DRAWCHASELOGIC || DEV_DRAWMOVETOPOS ) && GetBugReproNum() == ship.bug_reproNum )
			{
				float stopTime = ( GetVelocityLocal( mover ).v.Length() / ship.accMax )
				DebugDrawCircle( LocalToWorldOrigin( finalGoal ), <90,0,0>, 8, 255, 0, 0, true, stopTime + 0.25, 4 )
				DebugDrawCircle( LocalToWorldOrigin( trajectory ), <90,0,0>, 16, 0, 0, 255, true, FRAME_INTERVAL, 4 )
			}
		#endif

		//if so find a new goal
		flightData.newOffset = CalculateGoalOffset( followBounds, flightData.goalOffset, ship.boundsMinRatio )
		flightData.timeApplyGoal = currTime + FRAME_INTERVAL
	}

	//find the velocity we want, then send it to the function that actually calculates how to move us
	LocalVec goalOrigin = CLVec( baseOrigin.v + flightData.goalOffset )
	LocalVec goalVelocity = CLVec( ( goalOrigin.v - flightData.prevOrigin.v ) / FRAME_INTERVAL )

	#if DEV
		if ( ( DEV_DRAWCHASELOGIC || DEV_DRAWMOVETOPOS ) && GetBugReproNum() == ship.bug_reproNum && method2 )
		{
			DebugDrawText( mover.GetOrigin() + <0,0,90>, "METHOD 2", true, FRAME_INTERVAL )
			//printt( "goalOrigin: " + goalOrigin.v.y + ", prevOrigin: " + flightData.prevOrigin.v.y + ", delta: " + goalVelocity.v.y+ )
			//DebugDrawCircle( LocalToWorldOrigin( goalOrigin ), <90,90,0>, 64, 0, 0, 255, true, FRAME_INTERVAL * 4, 4 )
			//DebugDrawCircle( mover.GetOrigin(), <90,90,0>, 64, 0, 0, 255, true, FRAME_INTERVAL * 20, 4 )
		}
	#endif

	ship.localVelocity.v = MoveToPosWithEase( ship, mover, goalOrigin, goalVelocity, ship.localVelocity, ship.accMax, ship.speedMax ).v
	flightData.prevOrigin.v = goalOrigin.v

	float timeScale = 1.0

	//don't apply the new goal until it's time
	if ( flightData.timeApplyGoal != DONOTCHECK )
	{
		float rotDelay = ship.fullBankTime * 0.66
		timeScale = GetBankTimeScale( flightData.timeApplyGoal - currTime, rotDelay )

		if ( currTime >= flightData.timeApplyGoal )
		{
			flightData.goalOffset = flightData.newOffset
			flightData.timeApplyGoal = DONOTCHECK
		}
	}

	if ( newOffset == flightData.newOffset ) //stops the jerkiness that happens when it can't find a good new offset
		flightData.goalPos.v = CLVec( baseOrigin.v + flightData.newOffset ).v

	BankShip( ship, flightData.goalPos, mover, baseAngles, targetEnt, timeScale )

	newOffset = flightData.newOffset
	return flightData
}

LocalVec function GetCurrentTrajectoryAtFullDeceleration( entity mover, float dec, vector ornull velocity = null )
{
	LocalVec currOrigin = GetOriginLocal( mover )
	if ( velocity == null )
		velocity = GetVelocityLocal( mover ).v
	expect vector( velocity )
	float speed 		= velocity.Length()

	//how much time will it take to stop us?
	float stopTime = GetStopTimeAtFullDeceleration( speed, dec )

	//how much distance can we cover in that time?
	float stopDist 	= speed * stopTime + ( 0.5 * dec * pow( stopTime, 2 ) )
	vector stopVec 	= stopDist * Normalize( velocity )

	//where will we stop if we start breaking now?
	LocalVec trajectory = CLVec( currOrigin.v + stopVec )

	return trajectory
}

float function GetStopDistanceAtFullDeceleration( entity mover, float dec )
{
	vector velocity 	= GetVelocityLocal( mover ).v
	float speed 		= velocity.Length()

	//how much time will it take to stop us?
	float stopTime = GetStopTimeAtFullDeceleration( speed, dec )

	//how much distance can we cover in that time?
	float stopDist 	= speed * stopTime + ( 0.5 * dec * pow( stopTime, 2 ) )

	return stopDist
}

float function GetStopTimeAtFullDeceleration( float speed, float dec )
{
	return fabs( speed / dec ) - FRAME_INTERVAL
}

/************************************************************************************************\

███████╗██╗  ██╗   ██╗    ███████╗████████╗██╗   ██╗██╗     ███████╗███████╗
██╔════╝██║  ╚██╗ ██╔╝    ██╔════╝╚══██╔══╝╚██╗ ██╔╝██║     ██╔════╝██╔════╝
█████╗  ██║   ╚████╔╝     ███████╗   ██║    ╚████╔╝ ██║     █████╗  ███████╗
██╔══╝  ██║    ╚██╔╝      ╚════██║   ██║     ╚██╔╝  ██║     ██╔══╝  ╚════██║
██║     ███████╗██║       ███████║   ██║      ██║   ███████╗███████╗███████║
╚═╝     ╚══════╝╚═╝       ╚══════╝   ╚═╝      ╚═╝   ╚══════╝╚══════╝╚══════╝

\************************************************************************************************/
void function __ShipFlyIdle( ShipStruct ship, vector followBounds, entity targetEnt, vector targetPos, vector followOffset, LocalVec functionref(entity, vector, vector, bool = 0) GetBaseOriginFunc, int eventGoalID, bool method2 = false )
{
	Signal( ship, "NewFlyStyle" )
	EndSignal( ship, "NewFlyStyle" )
	EndSignal( ship, "FakeDestroy" )

	entity mover 	= ship.mover
	mover.EndSignal( "OnDestroy" )
	if ( targetEnt != null )
		targetEnt.EndSignal( "OnDestroy" )

	if ( mover.l.lastMoveToTime == Time() )
		WaitFrame()

	vector baseAngles = CONVOYDIR

	/*****		INITIALIZATION		*****/
	FollowFlightStruct flightData = FlightDataInit( ship )

	float rotDelay = ship.fullBankTime * 0.66
	float timeStartMove = Time()
	if ( !method2 )
		timeStartMove+= rotDelay - FRAME_INTERVAL
	LocalVec goalPos = GetEaseOutGoalPos( ship, rotDelay )

	#if DEV
		if ( DEV_DRAWMOVETOPOS && GetBugReproNum() == ship.bug_reproNum )
		{
			LocalVec baseOrigin = GetBaseOriginFunc( targetEnt, targetPos, followOffset, true )
			DebugDrawLine( mover.GetOrigin(), LocalToWorldOrigin( goalPos ), 153, 153, 255, true, rotDelay )
			DebugDrawCircle( LocalToWorldOrigin( goalPos ), <0,0,0>, 8, 153, 153, 255, true, rotDelay, 4 )
			DebugDrawLine( LocalToWorldOrigin( goalPos ), LocalToWorldOrigin( baseOrigin ), 153, 153, 255, true, rotDelay )
			DebugDrawCircle( LocalToWorldOrigin( baseOrigin ), <0,0,0>, 8, 153, 153, 255, true, rotDelay, 4 )
		}
	#endif

	bool checkGoal = true
	while( 1 )
	{
		/******		MOVEMENT		*****/
		LocalVec baseOrigin = GetBaseOriginFunc( targetEnt, targetPos, followOffset, GetBugReproNum() == ship.bug_reproNum )
		Assert( typeof( baseOrigin.v ) == "vector" )

		if ( Time() >= timeStartMove )
			goalPos	= baseOrigin

		Assert( typeof( baseOrigin.v ) == "vector" )

		flightData = FollowFlight_Movement( ship, flightData, goalPos, baseAngles, followBounds, targetEnt, method2 )

		Assert( typeof( baseOrigin.v ) == "vector" )

		/******    GOAL REACH EVENTS    *****/
		LocalVec finalGoal = CLVec( baseOrigin.v + flightData.goalOffset )
		int atGoal = CheckAtGoal( ship, finalGoal )

		if ( eventGoalID != eShipEvents.NONE && checkGoal == true && atGoal )
		{
			RunShipEventCallbacks( ship, eventGoalID, ship.chaseEnemy )
			checkGoal = false
		}

		#if DEV
			if ( ( DEV_DRAWCHASELOGIC || DEV_DRAWMOVETOPOS ) && GetBugReproNum() == ship.bug_reproNum )
				DevDrawFlyEdgeLogic( ship, baseAngles, followBounds, followOffset, baseOrigin, mover, flightData.goalOffset, flightData.newOffset )
		#endif

		WaitFrame()
	}
}

void function __ShipFlyToPosInternal( ShipStruct ship, entity followTarget, LocalVec pos, vector offset, vector baseAngles )
{
	Signal( ship, "NewFlyStyle" )
	EndSignal( ship, "NewFlyStyle" )
	EndSignal( ship, "FakeDestroy" )

	entity mover 	= ship.mover
	mover.EndSignal( "OnDestroy" )

	if ( mover.l.lastMoveToTime == Time() )
		WaitFrame()

	LocalVec goalVelocity = CLVec( <0,0,0> )
	float rotDelay = ship.fullBankTime * 0.66
	float timeStartMove = Time() + rotDelay - FRAME_INTERVAL
	LocalVec goalPos = GetEaseOutGoalPos( ship, rotDelay )
	LocalVec baseOrigin = pos

	#if DEV
			if ( DEV_DRAWMOVETOPOS && GetBugReproNum() == ship.bug_reproNum )
			{
				DebugDrawLine( mover.GetOrigin(), LocalToWorldOrigin( goalPos ), 153, 153, 255, true, rotDelay )
				DebugDrawCircle( LocalToWorldOrigin( goalPos ), <0,90,0>, 8, 153, 153, 255, true, rotDelay, 3 )
				DebugDrawLine( LocalToWorldOrigin( goalPos ), LocalToWorldOrigin( baseOrigin ), 153, 153, 255, true, rotDelay )
				DebugDrawCircle( LocalToWorldOrigin( baseOrigin ), <0,0,0>, 8, 153, 153, 255, true, rotDelay, 4 )
			}
	#endif

	while( 1 )
	{
		if ( followTarget != null )
			baseOrigin = GetBaseOrigin_FollowTarget( followTarget, pos.v, offset, GetBugReproNum() == ship.bug_reproNum )

		float currTime = Time()
		if ( currTime >= timeStartMove )
			goalPos = baseOrigin

		ship.localVelocity.v = MoveToPosWithEase( ship, mover, goalPos, goalVelocity, ship.localVelocity, ship.accMax, ship.speedMax ).v

		float timeScale = GetBankTimeScale( timeStartMove - currTime, rotDelay )
		BankShip( ship, baseOrigin, mover, baseAngles, null, timeScale )

		CheckAtGoal( ship, baseOrigin )

		#if DEV
			if ( DEV_DRAWMOVETOPOS && GetBugReproNum() == ship.bug_reproNum )
			{
				DebugDrawCircle( LocalToWorldOrigin( baseOrigin ), <0,0,0>, 4, 255, 100, 255, true, FRAME_INTERVAL, 4 )
				DebugDrawLine( LocalToWorldOrigin( baseOrigin ), mover.GetOrigin(), 255, 100, 255, true, FRAME_INTERVAL )
			}
		#endif

		WaitFrame()
	}
}

float function GetBankTimeScale( float deltaTime, float rotDelay )
{
	return GraphCapped( deltaTime, rotDelay, 0, 5, 1 )
}

const float UPDATEPLAYERPOSBUFFER = 4 //lag this much before updating player pos so ships don't look like they are attached
const float DOORCLOSEDURATION = 1.5 // wait for the door to close before moving
void function __ShipFlyAlongEdge( ShipStruct ship, vector followBounds, vector followOffset, float seekAhead, int eventGoalID )
{
	Signal( ship, "NewFlyStyle" )
	EndSignal( ship, "NewFlyStyle" )
	EndSignal( ship, "FakeDestroy" )

	entity mover 	= ship.mover
	mover.EndSignal( "OnDestroy" )

	if ( mover.l.lastMoveToTime == Time() )
		WaitFrame()

	/*****		INITIALIZATION		*****/
	EdgeData data, testData
	while( !CanGetEdgeData( ship, ship.chaseEnemy ) )
		wait 0.1
	data = GetBestEdgeData( ship, ship.chaseEnemy, mover.GetOrigin() )
	//so when we enter this function, if the enemy is not on the follow ship, we use this ship's origin as the anchor
	data.timeGetPlayerPos 	= -UPDATEPLAYERPOSBUFFER
	data.deltaLKP			= GetRelativeDelta( mover.GetOrigin(), data.onShip.model )

	float timeAllowNewEdge 	= -ship.crossHullBufferTime
	float timeStartNewEdge 	= DONOTCHECK
	float currTime 			= Time()

	FollowFlightStruct flightData = FlightDataInit( ship )

	entity enemy
	vector baseAngles 		= CONVOYDIR
	bool updateData  		= false
	bool preppingNewEdge 	= false
	vector newEdgeOffset 	= <0,0,0>
	float timeAtNewEdge 	= currTime + FRAME_INTERVAL

	while( 1 )
	{
		currTime 	= Time()
		enemy 		= ship.chaseEnemy
		updateData 	= false

		/******		EDGE DATA		*****/
		if ( CanGetEdgeData( ship, enemy ) )
		{
			if ( AllowNewEdgeData( ship, enemy, data, timeAllowNewEdge ) )
				testData = GetBestEdgeData( ship, enemy )
			else
				testData = data

			//do we need to cross to a new edge?
			if ( data.rightOfTarget != testData.rightOfTarget )
			{
				//is the door closed/closing yet?
				if ( !preppingNewEdge )
				{
					RunShipEventCallbacks( ship, eShipEvents.SHIP_PREPNEWEDGE, enemy )

					//make the ship start climbing while the doors are closing to cross the hull high
					newEdgeOffset 			= <0,0,ship.crossHullHeight> - < 0,0,followOffset.z >
					flightData.newOffset 	= newEdgeOffset
					flightData.timeApplyGoal = currTime + FRAME_INTERVAL

					timeStartNewEdge = 1
					preppingNewEdge = true
				}

				//is it time to move to a new edge yet?
				if ( timeStartNewEdge != DONOTCHECK && newEdgeOffset != flightData.newOffset )
				{
					//make the ship go high to the other edge
					newEdgeOffset 			= <0,0,ship.crossHullHeight> - < 0,0,followOffset.z >
					flightData.newOffset 	= newEdgeOffset
					flightData.timeApplyGoal = currTime + FRAME_INTERVAL

					timeStartNewEdge = DONOTCHECK
					timeAtNewEdge = currTime + FRAME_INTERVAL

					preppingNewEdge = false
					timeAllowNewEdge = currTime + ship.crossHullBufferTime
					updateData = true
				}
			}
			else
				updateData = true
		}

		//did the update happen?
		if ( updateData )
		{
			testData.deltaLKP = data.deltaLKP
			data = testData
		}

		/******		MOVEMENT		*****/
		LocalVec baseOrigin = CalculateChaseBaseOrigin( ship, data, enemy, followOffset, seekAhead )
		flightData = FollowFlight_Movement( ship, flightData, baseOrigin, baseAngles, followBounds, data.onShip.mover )

		ship.goalRadius = 1000
		LocalVec finalGoal = CLVec( baseOrigin.v + flightData.goalOffset )
		int atgoal = CheckAtGoal( ship, finalGoal )

		/******		DOORS OPEN		*****/
		if ( timeAtNewEdge != DONOTCHECK && atgoal )
		{
			RunShipEventCallbacks( ship, eventGoalID, enemy )
			timeAtNewEdge = DONOTCHECK
		}

		#if DEV
			if ( DEV_DRAWCHASELOGIC && GetBugReproNum() == ship.bug_reproNum )
				DevDrawFlyEdgeLogic( ship, CONVOYDIR, followBounds, followOffset, baseOrigin, mover, flightData.goalOffset, flightData.newOffset )
		#endif
		WaitFrame()
	}
}

int function CheckAtGoal( ShipStruct ship, LocalVec goalOrigin )
{
	Assert( ship.goalRadius >= MINGOALDIST, "ship.goalRadius needs to be greater than " + MINGOALDIST )
	Assert( GOAL_UNREACHED == 0, "GOAL_UNREACHED always needs to be zero" )

	float distSqr = DistanceSqr( GetOriginLocal( ship.mover ).v, goalOrigin.v )
	float goalDistSqr = pow( ship.goalRadius, 2 )
	if ( distSqr <= goalDistSqr )
	{
		Signal( ship, "Goal" )

		if ( distSqr <= MINGOALDISTSQR || Length( ship.localVelocity.v ) < 50 )
		{
			#if DEV
				if ( DEV_DRAWGOALRADIUS && GetBugReproNum() == ship.bug_reproNum )
				{
					DebugDrawSphere( LocalToWorldOrigin( goalOrigin ), ship.goalRadius, 255, 0, 0, true, FRAME_INTERVAL, DEV_SPHERE_SEGMENTS )
				}
			#endif

			return GOAL_AT_FINAL
		}
		else
		{
			#if DEV
				if ( DEV_DRAWGOALRADIUS && GetBugReproNum() == ship.bug_reproNum )
				{
					DebugDrawSphere( LocalToWorldOrigin( goalOrigin ), ship.goalRadius, 255, 180, 0, true, FRAME_INTERVAL, DEV_SPHERE_SEGMENTS )
				}
			#endif

			return GOAL_AT_RADIUS
		}
	}

	#if DEV
		if ( DEV_DRAWGOALRADIUS && GetBugReproNum() == ship.bug_reproNum )
		{
			DebugDrawSphere( LocalToWorldOrigin( goalOrigin ), ship.goalRadius, 255, 100, 255, true, FRAME_INTERVAL, DEV_SPHERE_SEGMENTS )

		}
	#endif

	return GOAL_UNREACHED
}

LocalVec function GetEaseOutGoalPos( ShipStruct ship, float rotDelay )
{
	entity mover 	= ship.mover
	vector dir = Normalize( ship.localVelocity.v )
	vector delta = ( ship.localVelocity.v * rotDelay ) - ( dir * ( 0.5 * ship.accMax * pow( rotDelay, 2 ) ) )
	LocalVec goalPos = CLVec( GetOriginLocal( mover ).v + delta )
	return goalPos
}

/************************************************************************************************\

██████╗ ███████╗██╗  ██╗ █████╗ ██╗   ██╗██╗ ██████╗ ██████╗     ██╗   ██╗████████╗██╗██╗     ██╗████████╗██╗   ██╗
██╔══██╗██╔════╝██║  ██║██╔══██╗██║   ██║██║██╔═══██╗██╔══██╗    ██║   ██║╚══██╔══╝██║██║     ██║╚══██╔══╝╚██╗ ██╔╝
██████╔╝█████╗  ███████║███████║██║   ██║██║██║   ██║██████╔╝    ██║   ██║   ██║   ██║██║     ██║   ██║    ╚████╔╝
██╔══██╗██╔══╝  ██╔══██║██╔══██║╚██╗ ██╔╝██║██║   ██║██╔══██╗    ██║   ██║   ██║   ██║██║     ██║   ██║     ╚██╔╝
██████╔╝███████╗██║  ██║██║  ██║ ╚████╔╝ ██║╚██████╔╝██║  ██║    ╚██████╔╝   ██║   ██║███████╗██║   ██║      ██║
╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝  ╚═══╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝     ╚═════╝    ╚═╝   ╚═╝╚══════╝╚═╝   ╚═╝      ╚═╝

\************************************************************************************************/
void function __ShipFollowShip( ShipStruct ship, entity targetEnt, vector targetPos, vector followBounds, vector followOffset, int eventGoalID = eShipEvents.NONE )
{
	__ShipFlyIdle( ship, followBounds, targetEnt, targetPos, followOffset, GetBaseOrigin_FollowTarget, eventGoalID )
}

void function __ShipIdleAtTarget( ShipStruct ship, entity targetEnt, vector targetPos, vector followBounds, vector followOffset, int eventGoalID = eShipEvents.NONE )
{
	__ShipFlyIdle( ship, followBounds, targetEnt, targetPos, followOffset, GetBaseOrigin_IdleAtTarget, eventGoalID )
}

void function __ShipIdleAtTarget_Method2( ShipStruct ship, entity targetEnt, vector targetPos, vector followBounds, vector followOffset, int eventGoalID = eShipEvents.NONE )
{
	bool method2 = true
	__ShipFlyIdle( ship, followBounds, targetEnt, targetPos, followOffset, GetBaseOrigin_IdleAtTarget, eventGoalID, method2 )
}

void function __ShipIdleUnderTarget( ShipStruct ship, entity targetEnt, vector targetPos, vector followBounds, int eventGoalID = eShipEvents.NONE )
{
	vector followOffset = <0,0,0>
	vector baseZ = GetOriginLocal( targetEnt ).v + targetPos
	__ShipFlyIdle( ship, followBounds, targetEnt, baseZ, followOffset, GetBaseOrigin_IdleUnderTarget, eventGoalID )
}

LocalVec function GetBaseOrigin_IdleAtTarget( entity targetEnt, vector targetPos, vector followOffset, bool devDraw = false )
{
	if ( IsValid(targetEnt) )
	{
		if ( !IsValid(targetEnt) )
			return CLVec( targetPos )
		
		vector r = targetEnt.GetRightVector()
		vector f = targetEnt.GetForwardVector()
		vector u = targetEnt.GetUpVector()
		LocalVec moveOrigin = GetOriginLocal( targetEnt )

		vector x =  r * targetPos.x
		vector y =  f * targetPos.y
		vector z =  u * targetPos.z
		vector deployOrigin = x + y + z

		LocalVec baseOrigin = CLVec( moveOrigin.v + deployOrigin + followOffset )

		#if DEV
			if ( DEV_DRAWMOVETOPOS && devDraw )
			{
				vector ox = <followOffset.x,0,0>
				vector oy = <0,followOffset.y,0>
				vector oz = <0,0,followOffset.z>
				DevDrawOffset( targetEnt, baseOrigin, x, y, z, ox, oy, oz, followOffset )
			}
		#endif

		return baseOrigin
	}
	else
		return CLVec( targetPos )

	return CLVec( targetPos )
}

LocalVec function GetBaseOrigin_IdleUnderTarget( entity targetEnt, vector baseZ, vector followOffset, bool devDraw = false )
{
	LocalVec pos = GetOriginLocal( targetEnt )
	return CLVec( < pos.v.x, pos.v.y, baseZ.z > )
}

LocalVec function GetBaseOrigin_FollowTarget( entity followMover, vector pos, vector followOffset, bool devDraw = false )
{
	vector r = followMover.GetRightVector()
	vector f = followMover.GetForwardVector()
	vector u = followMover.GetUpVector()
	LocalVec moveOrigin = GetOriginLocal( followMover )

	vector x =  r * pos.x
	vector y =  f * pos.y
	vector z =  u * pos.z
	vector deployOrigin = x + y + z

	float rightOfTarget = -1.0
	if ( DotProduct( deployOrigin, r ) > 0 )
		rightOfTarget = 1.0

	vector ox =  r * followOffset.x * rightOfTarget
	vector oy =  f * followOffset.y
	vector oz =  u * followOffset.z
	vector deployOffset = ox + oy + oz

	LocalVec baseOrigin = CLVec( moveOrigin.v + deployOrigin + deployOffset )

	#if DEV
		if ( DEV_DRAWCHASELOGIC && devDraw )
		{
			DevDrawOffset( followMover, baseOrigin, x, y, z, ox, oy, oz, followOffset )
		}
	#endif

	return baseOrigin
}

void function DevDrawOffset( entity followMover, LocalVec baseOrigin, vector x, vector y, vector z, vector ox, vector oy, vector oz, vector followOffset )
{
	vector txtVec = Vector( 0,0,3 )
	vector nPos = LocalToWorldOrigin( GetOriginLocal( followMover ) )  + x + y + z
	DebugDrawCircle( LocalToWorldOrigin( baseOrigin ), Vector(0,0,0), 	4, 255, 0, 0, true, FRAME_INTERVAL, 4 )
	DebugDrawCircle( nPos, Vector(0,90,0), 		4, 0, 0, 255, true, FRAME_INTERVAL, 5 )
	DebugDrawText( nPos - txtVec, "Pos", true, FRAME_INTERVAL )

	DebugDrawLine( nPos, nPos + ox, 255, 0, 0, true, FRAME_INTERVAL )
	DebugDrawLine( nPos + ox, nPos + ox + oy, 255, 0, 0, true, FRAME_INTERVAL )
	DebugDrawLine( nPos + ox + oy, nPos + ox + oy + oz, 255, 0, 0, true, FRAME_INTERVAL )
	DebugDrawText( nPos + ox + oy + oz, "Base", true, FRAME_INTERVAL )

	if ( fabs( followOffset.x ) > 32 )
		DebugDrawText( nPos + ( ox * 0.5 ), string( followOffset.x ), true, FRAME_INTERVAL )
	if ( fabs( followOffset.y ) > 32 )
		DebugDrawText( nPos + ox + ( oy * 0.5 ), string( followOffset.y ), true, FRAME_INTERVAL )
	if ( fabs( followOffset.z ) > 32 )
		DebugDrawText( nPos + ox + oy + ( oz * 0.5 ), string( followOffset.z ), true, FRAME_INTERVAL )
}

FollowFlightStruct function FlightDataInit( ShipStruct ship )
{
	FollowFlightStruct flightData
	flightData.timeApplyGoal 	= Time()
	flightData.prevOrigin.v 	= GetOriginLocal( ship.mover ).v
	flightData.goalPos.v 	 	= flightData.prevOrigin.v

	return flightData
}

string function GetBestSideFromEvent( ShipStruct ship, entity player, int eventID )
{
	string side = ""
	switch ( eventID )
	{
		case eShipEvents.SHIP_ATNEWEDGE:
			ShipStruct ornull onShip = GetBestFollowShip( ship, player )
			while( !IsValid( onShip ) )
			{
				wait 0.1
				onShip = GetBestFollowShip( ship, player )
			}
			expect ShipStruct( onShip )

			float rightOfTarget = DotProduct( ship.model.GetOrigin() - onShip.model.GetOrigin(), onShip.model.GetRightVector() )
			side = ( rightOfTarget < 0 ) ? "right" : "left"
			break

		case eShipEvents.SHIP_ATDEPLOYPOS:
		case eShipEvents.SHIP_ATDEPLOYPOSZIP:
			ShipStruct ornull onShip = GetDeployShip( ship )
			Assert( IsValid( onShip ) )
			expect ShipStruct( onShip )

			vector pos 		= GetDeployPos( ship )
			int behavior 	= ship.behavior
			vector offset 	= ship.flyOffset[ behavior ]
			entity followMover = onShip.mover
			bool devDraw 		= GetBugReproNum() == ship.bug_reproNum
			LocalVec baseOrigin = GetBaseOrigin_FollowTarget( followMover, pos, offset, devDraw )

			float rightOfTarget = DotProduct( onShip.model.GetOrigin() - LocalToWorldOrigin( baseOrigin ), onShip.model.GetRightVector() )
			side = ( rightOfTarget < 0 ) ? "left" : "right"

			break

		default:
			Assert( 0, "event not setup" )
			break
	}

	return side
}

/************************************************************************************************\

███╗   ███╗ █████╗ ████████╗██╗  ██╗        ██╗     ██████╗ ██████╗ ██████╗ ███████╗
████╗ ████║██╔══██╗╚══██╔══╝██║  ██║       ██╔╝    ██╔════╝██╔═══██╗██╔══██╗██╔════╝
██╔████╔██║███████║   ██║   ███████║      ██╔╝     ██║     ██║   ██║██║  ██║█████╗
██║╚██╔╝██║██╔══██║   ██║   ██╔══██║     ██╔╝      ██║     ██║   ██║██║  ██║██╔══╝
██║ ╚═╝ ██║██║  ██║   ██║   ██║  ██║    ██╔╝       ╚██████╗╚██████╔╝██████╔╝███████╗
╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝    ╚═╝         ╚═════╝ ╚═════╝ ╚═════╝ ╚══════╝

\************************************************************************************************/
void function BankShip( ShipStruct ship, LocalVec goalPos, entity mover, vector baseAngles, entity targetEnt = null, float timeScale = 1.0 )
{
	vector newang = GetNewBankAngle( ship, goalPos, mover, baseAngles, targetEnt )
	mover.NonPhysicsRotateTo( newang, ship.fullBankTime * timeScale, 0, 0 )
}

vector function GetNewBankAngle( ShipStruct ship, LocalVec goalPos, entity mover, vector baseAngles, entity targetEnt = null )
{
	float rmax = ship.rollMax
	float pmax = ship.pitchMax
	LocalVec moverOrigin = GetOriginLocal( mover )

	vector targetVec = <0,0,0>
	if ( targetEnt != null && targetEnt != WORLD_CENTER )
		targetVec = GetVelocityLocal( targetEnt ).v

	vector combinedOrigin = goalPos.v + targetVec
	//record
	ship.goalPos.v = CLVec( combinedOrigin ).v

	vector dir = Normalize( combinedOrigin - moverOrigin.v )

	float pitch = pmax * dir.Dot( AnglesToUp( baseAngles ) )
//	float pitchF = -pmax * 0.5 * dir.Dot( AnglesToForward( baseAngles ) )
//	if ( fabs ( pitch + pitchF ) > fabs( pitch ) )
//		pitch = pitch + pitchF
//	if ( fabs( pitchF ) > fabs( pitch ) )
//		pitch = pitchF

	float roll 	= rmax * dir.Dot( AnglesToRight( baseAngles ) )

	vector additive = Vector( -pitch, 0, roll )
	float dist = Distance( combinedOrigin, moverOrigin.v )
	float magnitude = ship.FuncGetBankMagnitude( dist )
	additive *= magnitude

	vector newang 	= baseAngles + additive

	#if DEV
		if ( DEV_DRAWBANKING && GetBugReproNum() == ship.bug_reproNum )
		{
			vector up = mover.GetUpVector() * 50
			DebugDrawText( mover.GetOrigin() + up, "roll:" + mover.GetAngles().z, true, FRAME_INTERVAL )
			DebugDrawLine( mover.GetOrigin() + up, mover.GetOrigin() + up + (dir * dist), 255, 200, 0, true, FRAME_INTERVAL )
			DebugDrawCircle( mover.GetOrigin() + up + (dir * dist), <90,0,0>, 32, 255, 200, 0, true, FRAME_INTERVAL, 6 )
			DebugDrawCircle( mover.GetOrigin() + up, <0,90,0>, 16, 255, 200, 0, true, FRAME_INTERVAL, 3 )
		}
	#endif

	return newang
}

bool function AllowNewEdgeData( ShipStruct ship, entity enemy, EdgeData oldData, float timeAllowNewEdge )
{
	bool standardTest = ( Time() >= timeAllowNewEdge ) && !ship.engineDamage && ship.allowCrossHull

	ShipStruct ornull onShip = enemy.l.onShip

	//not on the same ship as before
	if ( onShip != oldData.onShip && onShip != ship )
	{
		if ( !IsValid( onShip ) )
			return standardTest
		expect ShipStruct( onShip )

		//if we're damaged, check to see if we have to cross the hull?
		if ( ship.engineDamage || !ship.allowCrossHull )
		{
			vector dirOfShip = ship.model.GetOrigin() - oldData.onShip.model.GetOrigin()
			vector dirOfTravel = onShip.model.GetOrigin() - ship.model.GetOrigin()
			if ( DotProduct( dirOfShip, dirOfTravel ) < 0 )
				return standardTest
		}

		return true
	}

	return standardTest
}

LocalVec function CalculateChaseBaseOrigin( ShipStruct ship, EdgeData data, entity enemy, vector baseOffset, float seekAhead )
{
	EdgeDataUpdateVectors( data )

	vector chasePos
	float currTime = Time()

	//is the player's position valid? or should we get lkp?
	if ( IsValid( enemy ) && enemy.l.onShip == data.onShip && currTime >= data.timeGetPlayerPos )
	{
		data.timeGetPlayerPos = currTime + UPDATEPLAYERPOSBUFFER
		chasePos 		= enemy.GetOrigin()
		data.deltaLKP 	= GetRelativeDelta( chasePos, data.onShip.model )
	}
	else
	{
		vector lkpOffset = ( data.right * data.deltaLKP.x ) + ( data.forward * data.deltaLKP.y ) + ( data.up * data.deltaLKP.z )
		chasePos = data.onShip.model.GetOrigin() + lkpOffset
	}

	if ( ship.minChasePoint != -16384 || ship.maxChasePoint != 16384 )
	{
		vector relativeDelta = GetRelativeDelta( chasePos, data.onShip.model )
		float adjustY = min( relativeDelta.y, ship.maxChasePoint )
		adjustY = max( adjustY, ship.minChasePoint )
		vector adjustedDelta = < relativeDelta.x, adjustY, relativeDelta.z >
		chasePos = GetWorldOriginFromRelativeDelta( adjustedDelta, data.onShip.model )
	}

	bool devDraw 		= GetBugReproNum() == ship.bug_reproNum
	vector edgePos 		= GetEdgePosition( chasePos, data, seekAhead, devDraw )
	vector offset 		= CalculateMoveNodeOffset( ship, data, baseOffset )
	LocalVec baseOrigin = WorldToLocalOrigin( edgePos + offset )

	#if DEV
		if ( DEV_DRAWCHASELOGIC && GetBugReproNum() == ship.bug_reproNum )
		{
			vector txtVec = Vector( 0,0,3 )
			DebugDrawCircle( chasePos, Vector(0,90,0), 			8, 255, 150, 0, true, FRAME_INTERVAL, 5 )
			DebugDrawText( chasePos + txtVec, "LKP", true, FRAME_INTERVAL )
			DebugDrawCircle( LocalToWorldOrigin( baseOrigin ), <0,0,0>, 4, 255, 0, 0, true, FRAME_INTERVAL, 4 )
			DebugDrawCircle( edgePos, Vector(0,90,0), 		4, 0, 0, 255, true, FRAME_INTERVAL, 3 )
			DebugDrawText( edgePos - txtVec, "Edge", true, FRAME_INTERVAL )

			vector devO = baseOffset
			vector devA = CONVOYDIR
			vector devR = AnglesToRight( devA )
			vector devF = AnglesToForward( devA )
			vector devU = Vector( 0,0, 1 )
			/*vector devR = data.right
			vector devF = data.forward
			vector devU = data.up*/
			vector devX = devR * devO.x * data.rightOfTarget
			vector devY = devF * devO.y
			vector devZ = devU * devO.z

			DebugDrawLine( edgePos, edgePos + devX, 255, 0, 0, true, FRAME_INTERVAL )
			DebugDrawLine( edgePos + devX, edgePos + devX + devY, 255, 0, 0, true, FRAME_INTERVAL )
			DebugDrawLine( edgePos + devX + devY, edgePos + devX + devY + devZ, 255, 0, 0, true, FRAME_INTERVAL )
			DebugDrawText( edgePos + devX + devY + devZ, "Base", true, FRAME_INTERVAL )

			if ( fabs( devO.x ) > 32 )
				DebugDrawText( edgePos + Vector( devO.x * data.rightOfTarget * 0.5, 0,0 ), string( devO.x ), true, FRAME_INTERVAL )
			if ( fabs( devO.y ) > 32 )
				DebugDrawText( edgePos + Vector( devO.x * data.rightOfTarget, devO.y * 0.5,0 ), string( devO.y ), true, FRAME_INTERVAL )
			if ( fabs( devO.z ) > 32 )
				DebugDrawText( edgePos + Vector( devO.x * data.rightOfTarget, devO.y, devO.z * 0.5 ), string( devO.z ), true, FRAME_INTERVAL )
		}
	#endif

	return baseOrigin
}

vector function CalculateMoveNodeOffset( ShipStruct ship, EdgeData data, vector offset )
{
	vector angles 	= CONVOYDIR
	vector forward 	= AnglesToForward( angles ) * offset.y
	vector right 	= AnglesToRight( angles ) * offset.x * data.rightOfTarget
	vector up 		= Vector( 0,0,offset.z )

	return forward + right + up
}

vector function CalculateGoalOffset( vector bounds, vector oldGoal, float minRatio )
{
	float x = RandomFloatRange( bounds.x * minRatio, bounds.x )
	float y = RandomFloatRange( bounds.y * minRatio, bounds.y )
	float z = RandomFloatRange( bounds.z * minRatio, bounds.z )

	if ( CoinFlip() )
		x *= -1.0
	if ( CoinFlip() )
		y *= -1.0
	if ( CoinFlip() )
		z *= -1.0

	bool xSame = ( x > 0.0 && oldGoal.x > 0.0 ) || ( x < 0.0 && oldGoal.x < 0.0 )
	if ( xSame )
		x *= -1.0

	return Vector( x, y, z )
}

bool function CanGetEdgeData( ShipStruct ship, entity player )
{
	if ( !IsValid( player ) )
		return false

	ShipStruct ornull onShip = GetBestFollowShip( ship, player )

	if ( !IsValid( onShip ) )
		return false

	Assert ( expect ShipStruct( onShip ) != ship )
	return true
}

bool function IsValidFollowShip( ShipStruct ornull ship )
{
	if ( !IsValid( ship ) )
		return false

	expect ShipStruct( ship )

	if ( !ship.leftEdge.len() )
		return false
	if ( !ship.rightEdge.len() )
		return false

	return true
}

ShipStruct ornull function GetBestFollowShip( ShipStruct ship, entity player )
{
	ShipStruct ornull nextShip = PlayerGetNextShip( player )

	if ( IsValid( player.l.onShip ) && player.l.onShip != ship )
		return player.l.onShip

	else if ( IsValid( nextShip ) )
	{
		expect ShipStruct( nextShip )
		Assert( nextShip.leftEdge.len() )
		Assert( nextShip.rightEdge.len() )
		return nextShip
	}

	else
	{
		for ( int i = 0; i < player.l.onShipList.len(); i++ )
		{
			ShipStruct ornull testShip = player.l.onShipList[ i ]

			if ( !IsValidFollowShip( testShip ) )
				continue

			expect ShipStruct( testShip )
			if ( testShip == ship )
				continue

			return testShip
		}
	}

	return null
}

EdgeData function GetBestEdgeData( ShipStruct ship, entity player, vector ornull arbitraryPos = null )
{
	ShipStruct ornull onShip = GetBestFollowShip( ship, player )
	Assert( onShip != null )
	expect ShipStruct( onShip )

	EdgeData data
	vector dir

	data.onShip = onShip
	EdgeDataUpdateVectors( data )

	if ( !ship.allowCrossHull )
		dir = ship.model.GetOrigin() - data.onShip.model.GetOrigin()
	else if( arbitraryPos != null )
		dir = expect vector( arbitraryPos ) - data.onShip.model.GetOrigin()
	else
		dir = player.GetOrigin() - data.onShip.model.GetOrigin()

	if ( dir.Dot( data.right ) > 0 )
	{
		data.rightOfTarget = 1.0
		data.edgeArray = data.onShip.rightEdge
	}
	else
	{
		data.rightOfTarget = -1.0
		data.edgeArray = data.onShip.leftEdge
	}

	return data
}

void function EdgeDataUpdateVectors( EdgeData data )
{
	data.forward 	= data.onShip.model.GetForwardVector()
	data.right 		= data.onShip.model.GetRightVector()
	data.up 		= data.onShip.model.GetUpVector()
}

vector function GetEdgePosition( vector position, EdgeData data, float seekAhead = 0, bool devDraw = false )
{
	vector P = position + ( data.forward * seekAhead )
	array<entity> edgeArray = ArrayClosest( data.edgeArray, P )

	vector A = edgeArray[0].GetOrigin()
	vector B = edgeArray[1].GetOrigin()
	vector C = edgeArray[2].GetOrigin()

	bool clampInside = true
	#if DEV
		if ( DEV_DRAWCHASELOGIC && devDraw )
		{
			vector offset = Vector( 0,0,3)

			DebugDrawLine( A + offset, B + offset, 0, 0, 255, true, FRAME_INTERVAL )
			DebugDrawLine( B + offset, C + offset, 0, 0, 255, true, FRAME_INTERVAL )
			DebugDrawLine( C + offset, A + offset, 0, 0, 255, true, FRAME_INTERVAL )
			DebugDrawText( A + offset, "A", true, FRAME_INTERVAL)
			DebugDrawText( B + offset, "B", true, FRAME_INTERVAL)
			DebugDrawText( C + offset, "C", true, FRAME_INTERVAL)
		}
	#endif
	return GetClosestPointOnPlane( A, B, C, P, clampInside )
}

/************************************************************************************************\

██████╗ ███████╗██╗   ██╗
██╔══██╗██╔════╝██║   ██║
██║  ██║█████╗  ██║   ██║
██║  ██║██╔══╝  ╚██╗ ██╔╝
██████╔╝███████╗ ╚████╔╝
╚═════╝ ╚══════╝  ╚═══╝

\************************************************************************************************/
void function DevDrawFlyEdgeLogic( ShipStruct ship, vector baseAngles, vector followBounds, vector followOffset, LocalVec baseOrigin, entity mover, vector goalOffset, vector newOffset )
{
	vector bounds = followBounds
	vector devO = followOffset
	vector devA = baseAngles
	vector devR = AnglesToRight( devA )
	vector devF = AnglesToForward( devA )
	vector devU = Vector( 0,0, 1 )

	DebugDrawCircle( mover.GetOrigin(), <0,0,0>, 6, 255, 150, 0, true, FRAME_INTERVAL, 4 )
	DebugDrawText( mover.GetOrigin() + < 0,0,3>, "Mover", true, FRAME_INTERVAL )
	DebugDrawCircle( LocalToWorldOrigin( baseOrigin ) + goalOffset, <0,90,0>, 4, 255, 100, 255, true, FRAME_INTERVAL, 3 )
	DebugDrawCircle( LocalToWorldOrigin( baseOrigin ) + newOffset, <0,90,0>, 4, 255, 100, 255, true, FRAME_INTERVAL, 3 )
	DebugDrawLine( LocalToWorldOrigin( baseOrigin ) + goalOffset, mover.GetOrigin(), 255, 100, 255, true, FRAME_INTERVAL )
	DebugDrawLine( LocalToWorldOrigin( baseOrigin ) + goalOffset, LocalToWorldOrigin( baseOrigin ) + newOffset, 255, 100, 255, true, FRAME_INTERVAL )

	vector dev1 = LocalToWorldOrigin( baseOrigin ) + ( bounds.x * devR ) + ( bounds.y * devF ) + ( bounds.z * devU )
	vector dev2 = LocalToWorldOrigin( baseOrigin ) + ( -bounds.x * devR ) + ( bounds.y * devF ) + ( bounds.z * devU )
	vector dev3 = LocalToWorldOrigin( baseOrigin ) + ( bounds.x * devR ) + ( -bounds.y * devF ) + ( bounds.z * devU )
	vector dev4 = LocalToWorldOrigin( baseOrigin ) + ( bounds.x * devR ) + ( bounds.y * devF ) + ( -bounds.z * devU )
	vector dev5 = LocalToWorldOrigin( baseOrigin ) + ( -bounds.x * devR ) + ( -bounds.y * devF ) + ( -bounds.z * devU )
	vector dev6 = LocalToWorldOrigin( baseOrigin ) + ( bounds.x * devR ) + ( -bounds.y * devF ) + ( -bounds.z * devU )
	vector dev7 = LocalToWorldOrigin( baseOrigin ) + ( -bounds.x * devR ) + ( bounds.y * devF ) + ( -bounds.z * devU )
	vector dev8 = LocalToWorldOrigin( baseOrigin ) + ( -bounds.x * devR ) + ( -bounds.y * devF ) + ( bounds.z * devU )

	DebugDrawLine( dev1, dev2, 255, 0, 0, true, FRAME_INTERVAL )
	DebugDrawLine( dev1, dev3, 255, 0, 0, true, FRAME_INTERVAL )
	DebugDrawLine( dev1, dev4, 255, 0, 0, true, FRAME_INTERVAL )
	DebugDrawLine( dev5, dev6, 255, 0, 0, true, FRAME_INTERVAL )
	DebugDrawLine( dev5, dev7, 255, 0, 0, true, FRAME_INTERVAL )
	DebugDrawLine( dev5, dev8, 255, 0, 0, true, FRAME_INTERVAL )
	DebugDrawLine( dev8, dev2, 255, 0, 0, true, FRAME_INTERVAL )
	DebugDrawLine( dev8, dev3, 255, 0, 0, true, FRAME_INTERVAL )
	DebugDrawLine( dev4, dev6, 255, 0, 0, true, FRAME_INTERVAL )
	DebugDrawLine( dev4, dev7, 255, 0, 0, true, FRAME_INTERVAL )
	DebugDrawLine( dev3, dev6, 255, 0, 0, true, FRAME_INTERVAL )
	DebugDrawLine( dev2, dev7, 255, 0, 0, true, FRAME_INTERVAL )

	DebugDrawText( dev1 + ( devR * -bounds.x ), string( bounds.x * 2 ), true, FRAME_INTERVAL )
	DebugDrawText( dev1 + ( devF * -bounds.y ), string( bounds.y * 2 ), true, FRAME_INTERVAL )
	DebugDrawText( dev1 + ( devU * -bounds.z ), string( bounds.z * 2 ), true, FRAME_INTERVAL )

	//hull
	if ( DEV_DRAWSHIPHULL )
	{
		bounds = ship.DEV_hullSize
		dev1 += ( bounds.x * devR ) + ( bounds.y * devF ) + ( bounds.z * devU ) + ship.DEV_hullOffset
		dev2 += ( -bounds.x * devR ) + ( bounds.y * devF ) + ( bounds.z * devU ) + ship.DEV_hullOffset
		dev3 += ( bounds.x * devR ) + ( -bounds.y * devF ) + ( bounds.z * devU ) + ship.DEV_hullOffset
		dev4 += ( bounds.x * devR ) + ( bounds.y * devF ) + ( -bounds.z * devU ) + ship.DEV_hullOffset
		dev5 += ( -bounds.x * devR ) + ( -bounds.y * devF ) + ( -bounds.z * devU ) + ship.DEV_hullOffset
		dev6 += ( bounds.x * devR ) + ( -bounds.y * devF ) + ( -bounds.z * devU ) + ship.DEV_hullOffset
		dev7 += ( -bounds.x * devR ) + ( bounds.y * devF ) + ( -bounds.z * devU ) + ship.DEV_hullOffset
		dev8 += ( -bounds.x * devR ) + ( -bounds.y * devF ) + ( bounds.z * devU ) + ship.DEV_hullOffset

		DebugDrawLine( dev1, dev2, 255, 200, 0, true, FRAME_INTERVAL )
		DebugDrawLine( dev1, dev3, 255, 200, 0, true, FRAME_INTERVAL )
		DebugDrawLine( dev1, dev4, 255, 200, 0, true, FRAME_INTERVAL )
		DebugDrawLine( dev5, dev6, 255, 200, 0, true, FRAME_INTERVAL )
		DebugDrawLine( dev5, dev7, 255, 200, 0, true, FRAME_INTERVAL )
		DebugDrawLine( dev5, dev8, 255, 200, 0, true, FRAME_INTERVAL )
		DebugDrawLine( dev8, dev2, 255, 200, 0, true, FRAME_INTERVAL )
		DebugDrawLine( dev8, dev3, 255, 200, 0, true, FRAME_INTERVAL )
		DebugDrawLine( dev4, dev6, 255, 200, 0, true, FRAME_INTERVAL )
		DebugDrawLine( dev4, dev7, 255, 200, 0, true, FRAME_INTERVAL )
		DebugDrawLine( dev3, dev6, 255, 200, 0, true, FRAME_INTERVAL )
		DebugDrawLine( dev2, dev7, 255, 200, 0, true, FRAME_INTERVAL )

		vector moveOrigin = mover.GetOrigin()
		dev1 = moveOrigin + ship.DEV_hullOffset + ( bounds.x * devR ) + ( bounds.y * devF ) + ( bounds.z * devU )
		dev2 = moveOrigin + ship.DEV_hullOffset + ( -bounds.x * devR ) + ( bounds.y * devF ) + ( bounds.z * devU )
		dev3 = moveOrigin + ship.DEV_hullOffset + ( bounds.x * devR ) + ( -bounds.y * devF ) + ( bounds.z * devU )
		dev4 = moveOrigin + ship.DEV_hullOffset + ( bounds.x * devR ) + ( bounds.y * devF ) + ( -bounds.z * devU )
		dev5 = moveOrigin + ship.DEV_hullOffset + ( -bounds.x * devR ) + ( -bounds.y * devF ) + ( -bounds.z * devU )
		dev6 = moveOrigin + ship.DEV_hullOffset + ( bounds.x * devR ) + ( -bounds.y * devF ) + ( -bounds.z * devU )
		dev7 = moveOrigin + ship.DEV_hullOffset + ( -bounds.x * devR ) + ( bounds.y * devF ) + ( -bounds.z * devU )
		dev8 = moveOrigin + ship.DEV_hullOffset + ( -bounds.x * devR ) + ( -bounds.y * devF ) + ( bounds.z * devU )

		DebugDrawLine( dev1, dev2, 255, 200, 0, true, FRAME_INTERVAL )
		DebugDrawLine( dev1, dev3, 255, 200, 0, true, FRAME_INTERVAL )
		DebugDrawLine( dev1, dev4, 255, 200, 0, true, FRAME_INTERVAL )
		DebugDrawLine( dev5, dev6, 255, 200, 0, true, FRAME_INTERVAL )
		DebugDrawLine( dev5, dev7, 255, 200, 0, true, FRAME_INTERVAL )
		DebugDrawLine( dev5, dev8, 255, 200, 0, true, FRAME_INTERVAL )
		DebugDrawLine( dev8, dev2, 255, 200, 0, true, FRAME_INTERVAL )
		DebugDrawLine( dev8, dev3, 255, 200, 0, true, FRAME_INTERVAL )
		DebugDrawLine( dev4, dev6, 255, 200, 0, true, FRAME_INTERVAL )
		DebugDrawLine( dev4, dev7, 255, 200, 0, true, FRAME_INTERVAL )
		DebugDrawLine( dev3, dev6, 255, 200, 0, true, FRAME_INTERVAL )
		DebugDrawLine( dev2, dev7, 255, 200, 0, true, FRAME_INTERVAL )
	}
}


/************************************************************************************************\

██╗   ██╗████████╗██╗██╗     ██╗████████╗██╗   ██╗
██║   ██║╚══██╔══╝██║██║     ██║╚══██╔══╝╚██╗ ██╔╝
██║   ██║   ██║   ██║██║     ██║   ██║    ╚████╔╝
██║   ██║   ██║   ██║██║     ██║   ██║     ╚██╔╝
╚██████╔╝   ██║   ██║███████╗██║   ██║      ██║
 ╚═════╝    ╚═╝   ╚═╝╚══════╝╚═╝   ╚═╝      ╚═╝

\************************************************************************************************/
void function ShipFlyToPos( ShipStruct ship, LocalVec pos, vector baseAngles = CONVOYDIR )
{
	ship.customEnt = null
	ship.customPos = pos.v
	ship.customAng = baseAngles
	ship.flyOffset[ eBehavior.CUSTOM ] = <0,0,0>

	DoCustomBehavior( ship, Custom_FlyToPos )
}

void function ShipFlyToRelativePos( ShipStruct ship, entity target, vector delta, vector offset, vector baseAngles = CONVOYDIR )
{
	ship.customEnt = target
	ship.customPos = delta
	ship.customAng = baseAngles
	ship.flyOffset[ eBehavior.CUSTOM ] = offset

	DoCustomBehavior( ship, Custom_FlyToPos )
}

void function ShipIdleAtTargetPos( ShipStruct ship, LocalVec pos, vector bounds )
{
	SetFlyBounds( ship, eBehavior.CUSTOM, bounds )
	ship.customEnt = null
	ship.customPos = pos.v
	ship.flyOffset[ eBehavior.CUSTOM ] = <0,0,0>

	DoCustomBehavior( ship, Custom_IdleAtTarget )
}

void function ShipIdleAtTargetEnt( ShipStruct ship, entity target, vector bounds, vector pos = <0,0,0>, vector offset = <0,0,0> )
{
	SetFlyBounds( ship, eBehavior.CUSTOM, bounds )
	ship.customEnt = target
	ship.customPos = pos
	ship.flyOffset[ eBehavior.CUSTOM ] = offset

	DoCustomBehavior( ship, Custom_IdleAtTarget )
}

void function ShipIdleAtTargetEnt_Method2( ShipStruct ship, entity target, vector bounds, vector pos = <0,0,0>, vector offset = <0,0,0> )
{
	SetFlyBounds( ship, eBehavior.CUSTOM, bounds )
	ship.customEnt = target
	ship.customPos = pos
	ship.flyOffset[ eBehavior.CUSTOM ] = offset

	DoCustomBehavior( ship, Custom_IdleAtTarget_Method2 )
}

void function ShipIdleUnderTargetEnt( ShipStruct ship, entity target, vector bounds, float deltaZ )
{
	SetFlyBounds( ship, eBehavior.CUSTOM, bounds )
	ship.customEnt = target
	ship.customPos = <0,0,deltaZ>

	DoCustomBehavior( ship, Custom_IdleUnderTarget )
}

void function EnableHullCrossing( ShipStruct ship )
{
	ship.allowCrossHull = true
}

void function DisableHullCrossing( ShipStruct ship )
{
	ship.allowCrossHull = false
}

void function SetChaseEnemy( ShipStruct ship, entity enemy )
{
	ship.chaseEnemy = enemy
}

void function SetFlyBounds( ShipStruct ship, int behavior, vector bounds )
{
	ship.flyBounds[ behavior ] = bounds
}

void function SetFlyOffset( ShipStruct ship, int behavior, vector offset )
{
	ship.flyOffset[ behavior ] = offset
}

void function SetSeekAhead( ShipStruct ship, int behavior, float seekAhead )
{
	ship.seekAhead[ behavior ] = seekAhead
}

void function SetMaxSpeed( ShipStruct ship, float value, float time = 0 )
{
	if ( time > 0 )
		thread __LerpValue( ship, __GetMaxSpeed, __SetMaxSpeed, "SetMaxSpeed", value, time )
	else
	{
		Signal( ship, "SetMaxSpeed" )
		__SetMaxSpeed( ship, value )
	}
}

void function SetMaxAcc( ShipStruct ship, float value, float time = 0 )
{
	if ( time > 0 )
		thread __LerpValue( ship, __GetMaxAcc, __SetMaxAcc, "SetMaxAcc", value, time )
	else
	{
		Signal( ship, "SetMaxAcc" )
		__SetMaxAcc( ship, value )
	}
}

void function ResetMaxSpeed( ShipStruct ship, float time = 0 )
{
	if ( time > 0 )
		thread __LerpValue( ship, __GetMaxSpeed, __SetMaxSpeed, "SetMaxSpeed", ship.defSpeedMax, time )
	else
	{
		Signal( ship, "SetMaxSpeed" )
		__SetMaxSpeed( ship, ship.defSpeedMax )
	}
}

void function ResetMaxAcc( ShipStruct ship, float time = 0 )
{
	if ( time > 0 )
		thread __LerpValue( ship, __GetMaxAcc, __SetMaxAcc, "SetMaxAcc", ship.defAccMax, time )
	else
	{
		Signal( ship, "SetMaxAcc" )
		__SetMaxAcc( ship, ship.defAccMax )
	}
}

void function SetMaxRoll( ShipStruct ship, float value, float time = 0 )
{
	if ( time > 0 )
		thread __LerpValue( ship, __GetMaxRoll, __SetMaxRoll, "SetMaxRoll", value, time )
	else
	{
		Signal( ship, "SetMaxRoll" )
		__SetMaxRoll( ship, value )
	}
}

void function SetMaxPitch( ShipStruct ship, float value, float time = 0 )
{
	if ( time > 0 )
		thread __LerpValue( ship, __GetMaxPitch, __SetMaxPitch, "SetMaxPitch", value, time )
	else
	{
		Signal( ship, "SetMaxPitch" )
		__SetMaxPitch( ship, value )
	}
}

void function ResetMaxRoll( ShipStruct ship, float time = 0 )
{
	if ( time > 0 )
		thread __LerpValue( ship, __GetMaxRoll, __SetMaxRoll, "SetMaxRoll", ship.defRollMax, time )
	else
	{
		Signal( ship, "SetMaxRoll" )
		__SetMaxRoll( ship, ship.defRollMax )
	}
}

void function ResetMaxPitch( ShipStruct ship, float time = 0 )
{
	if ( time > 0 )
		thread __LerpValue( ship, __GetMaxPitch, __SetMaxPitch, "SetMaxPitch", ship.defPitchMax, time )
	else
	{
		Signal( ship, "SetMaxPitch" )
		__SetMaxPitch( ship, ship.defPitchMax )
	}
}

void function SetBankTime( ShipStruct ship, float value, float time = 0 )
{
	if ( time > 0 )
		thread __LerpValue( ship, __GetBankTime, __SetBankTime, "SetBankTime", value, time )
	else
	{
		Signal( ship, "SetBankTime" )
		__SetBankTime( ship, value )
	}
}

void function ResetBankTime( ShipStruct ship, float time = 0 )
{
	if ( time > 0 )
		thread __LerpValue( ship, __GetBankTime, __SetBankTime, "SetBankTime", ship.defBankTime, time )
	else
	{
		Signal( ship, "SetBankTime" )
		__SetBankTime( ship, ship.defBankTime )
	}
}

void function __SetMaxSpeed( ShipStruct ship, float value )
{
	ship.speedMax = value
}

float function __GetMaxSpeed( ShipStruct ship )
{
	return ship.speedMax
}

void function __SetMaxAcc( ShipStruct ship, float value )
{
	ship.accMax = value
}

float function __GetMaxAcc( ShipStruct ship )
{
	return ship.accMax
}

void function __SetMaxRoll( ShipStruct ship, float value )
{
	ship.rollMax = value
}

float function __GetMaxRoll( ShipStruct ship )
{
	return ship.rollMax
}

void function __SetMaxPitch( ShipStruct ship, float value )
{
	ship.pitchMax = value
}

float function __GetMaxPitch( ShipStruct ship )
{
	return ship.pitchMax
}

void function __SetBankTime( ShipStruct ship, float value )
{
	ship.fullBankTime = value
}

float function __GetBankTime( ShipStruct ship )
{
	return ship.fullBankTime
}

void function __LerpValue( 	ShipStruct ship, float functionref( ShipStruct ) GetValue, void functionref( ShipStruct,float ) SetValue, string ender, float value, float time )
{
	Signal( ship, ender )
	EndSignal( ship, ender )

	float start = GetValue( ship )
	float delta = value - start
	int cycles = ( time / FRAME_INTERVAL ).tointeger()

	for ( int i = 0; i < cycles; i++ )
	{
		float frac = ( i.tofloat() / cycles.tofloat() )
		SetValue( ship, start + ( delta * frac ) )
		WaitFrame()
	}

	SetValue( ship, value )
}