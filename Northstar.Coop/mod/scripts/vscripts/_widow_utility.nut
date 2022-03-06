//actually useful stuff
global function CheckpointShipInit


//stuff
global function CreateWidow
global function CloseDoorL
global function CloseDoorR
global function OpenDoorL
global function OpenDoorR
global function doorCycle
global function TravelOnX
global function TravelOnY
global function TravelOnZ
global function TeleportWidow
global function WarpOutThenDestroyShip
global function FollowOnX
global function FollowOnY
global function FollowOnZ
global function SpawnFollowingShip

const vector OffsetFloor = < -200,0,100 >
const vector OffsetCeiling = < -200,0,380 >
const vector OffsetDoorR = < -200,100,200 >
const vector OffsetDoorL = < -200,-100,200 >
const vector OffsetBack = < -250,0,200 >
const vector OffsetFront = < 300,0,200 >
const int BOTHCLOSED = 0
const int RIGHTOPEN = 1
const int LEFTOPEN = 2
const int BOTHOPEN = 3
const float HullSize = 150000.0

global struct WidowStruct
{
	entity ship
    array<entity> doorL
    array<entity> doorR
    int DOORSTATE = BOTHCLOSED
    bool following = false
}

/*
██╗███╗   ██╗██╗████████╗
██║████╗  ██║██║╚══██╔══╝
██║██╔██╗ ██║██║   ██║   
██║██║╚██╗██║██║   ██║   
██║██║ ╚████║██║   ██║   
╚═╝╚═╝  ╚═══╝╚═╝   ╚═╝
*/


void function CheckpointShipInit()
{
    PrecacheModel( $"models/humans/heroes/mlt_hero_sarah.mdl" )

	if ( "sp_s2s" == GetMapName() )
	{
		for(;;){
			if( GetPlayerArray().len() > 0 )
				break
			WaitFrame()
		}
		SetShip( CreateWidow( GetPlayerArray()[0], GetPlayerArray()[0].GetOrigin() + <0,0,500>, <0,90,0> ) )
		wait( 5 )
		TeleportWidow( GetShip(), GetPlayerArray()[0].GetOrigin() + <0,0,500>, <0,90,0> )
		// OpenDoorR( GetShip() )
		// OpenDoorL( GetShip() )


	}
}


/*
███████╗███████╗████████╗██╗   ██╗██████╗ 
██╔════╝██╔════╝╚══██╔══╝██║   ██║██╔══██╗
███████╗█████╗     ██║   ██║   ██║██████╔╝
╚════██║██╔══╝     ██║   ██║   ██║██╔═══╝ 
███████║███████╗   ██║   ╚██████╔╝██║     
╚══════╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝     
                                          
*/

WidowStruct function CreateWidow( entity player, vector origin, vector angles )
{
    WidowStruct ship

    ship.ship = CreateEntity( "prop_dynamic" )
    
	ship.ship.SetValueForModelKey( $"models/vehicle/widow/widow.mdl" )
	ship.ship.kv.solid = SOLID_VPHYSICS
    ship.ship.kv.CollisionGroup = TRACE_COLLISION_GROUP_BLOCK_WEAPONS //  TRACE_COLLISION_GROUP_PLAYER
    ship.ship.kv.rendercolor = "81 130 151"
	ship.ship.SetOrigin( origin )
	ship.ship.SetAngles( angles )

	ship.ship.SetBlocksRadiusDamage( true )
	DispatchSpawn( ship.ship )
    SetTeam( ship.ship, player.GetTeam() )

    ship.ship.Anim_Play( "wd_doors_closed_idle" )

    _CreateFloor( ship )
    _CreateCeiling( ship )
    _CreateDoorR( ship )
    _CreateDoorL( ship )
    _CreateFront( ship )
    _CreateBack( ship )

    return ship
}

vector function _PositionBasedOnAngle( vector CurrentPosition, float angle, vector origin ) //////// aaaaaaaaaaaaaaaaaaaaaaaaa
{
	float X = CurrentPosition.x
	float Y = CurrentPosition.y
	float offset_X = origin.x
    float offset_Y = origin.y
    float radians = angle * 0.017453

    float adjusted_x = (X - offset_X)
    float adjusted_y = (Y - offset_Y)
    float cos_rad = cos(radians)
    float sin_rad = sin(radians)
    float qx = offset_X + cos_rad * adjusted_x + sin_rad * adjusted_y
    float qy = offset_Y + -sin_rad * adjusted_x + cos_rad * adjusted_y

    CurrentPosition.x = qx
    CurrentPosition.y = qy

    return CurrentPosition
}


void function _CreateFloor( WidowStruct widow )
{
    array<vector> OffsetArray = [ < 0,-50,0>, < 50,-50,0>, < 100,-50,0>, < 150,-50,0>, < 200,-50,0>, < 250,-50,0>, < 300,-50,0>, < 350,-50,0>, < 400,-50,0>, < 450,-50,0>, < 500,-50,0> ]
    OffsetArray.extend( [ < 0,0,0>, < 50,0,0>, < 100,0,0>, < 150,0,0>, < 200,0,0>, < 250,0,0>, < 300,0,0>, < 350,0,0>, < 400,0,0>, < 450,0,0>, < 500,0,0> ] )
    OffsetArray.extend( [ < 0,50,0>, < 50,50,0>, < 100,50,0>, < 150,50,0>, < 200,50,0>, < 250,50,0>, < 300,50,0>, < 350,50,0>, < 400,50,0>, < 450,50,0>, < 500,50,0> ] )
    
    foreach( vector Offset in OffsetArray )
    {
        vector NewOrigin = _PositionBasedOnAngle( widow.ship.GetOrigin() + OffsetFloor + Offset , widow.ship.GetAngles().y, widow.ship.GetOrigin() )
        _CreateSarahProp( widow, NewOrigin, <0,90,0> )
    }
}

void function _CreateCeiling( WidowStruct widow )
{
    array<vector> OffsetArray = [ < 0,-50,0>, < 50,-50,0>, < 100,-50,0>, < 150,-50,0>, < 200,-50,0>, < 250,-50,0>, < 300,-50,0>, < 350,-50,0>, < 400,-50,0>, < 450,-50,0>, < 500,-50,0> ]
    OffsetArray.extend( [ < 0,0,0>, < 50,0,0>, < 100,0,0>, < 150,0,0>, < 200,0,0>, < 250,0,0>, < 300,0,0>, < 350,0,0>, < 400,0,0>, < 450,0,0>, < 500,0,0> ] )
    OffsetArray.extend( [ < 0,50,0>, < 50,50,0>, < 100,50,0>, < 150,50,0>, < 200,50,0>, < 250,50,0>, < 300,50,0>, < 350,50,0>, < 400,50,0>, < 450,50,0>, < 500,50,0> ] )
    
    foreach( vector Offset in OffsetArray )
    {
        vector NewOrigin = _PositionBasedOnAngle( widow.ship.GetOrigin() + OffsetCeiling + Offset , widow.ship.GetAngles().y, widow.ship.GetOrigin() )
        _CreateSarahProp( widow, NewOrigin, <0,90,0> )
    }
}

void function _CreateFront( WidowStruct widow ) 
{
    array<vector> OffsetArray = [ < 0,-50,0>, < 0,-50,100>, <0,50,0>, <0,50,100>, <0,0,0>, <0,0,100> ]
    
    foreach( vector Offset in OffsetArray )
    {
        vector NewOrigin = _PositionBasedOnAngle( widow.ship.GetOrigin() + OffsetFront + Offset, widow.ship.GetAngles().y, widow.ship.GetOrigin() )
        _CreateSarahProp( widow, NewOrigin, <0,90,0> )
    }
}

void function _CreateBack( WidowStruct widow )
{
    array<vector> OffsetArray = [ < 0,-50,0>, < 0,-50,100>, <0,50,0>, <0,50,100>, <0,0,0>, <0,0,100> ]
    
    foreach( vector Offset in OffsetArray )
    {
        vector NewOrigin = _PositionBasedOnAngle( widow.ship.GetOrigin() + OffsetBack + Offset, widow.ship.GetAngles().y, widow.ship.GetOrigin() )
        _CreateSarahProp( widow, NewOrigin, <0,90,0> )
    }
}

void function _CreateDoorR( WidowStruct widow )
{
    array<vector> OffsetArray = [ < 0,0,0>, < 50,0,0>, < 100,0,0>, < 150,0,0>, < 200,0,0>, < 250,0,0>, < 300,0,0>, < 350,0,0>, < 400,0,0>, < 450,0,0>, < 500,0,0> ]
    OffsetArray.extend( [ < 0,0,100>, < 50,0,100>, < 100,0,100>, < 150,0,100>, < 200,0,100>, < 250,0,100>, < 300,0,100>, < 350,0,100>, < 400,0,100>, < 450,0,100>, < 500,0,100> ] )
    
    foreach( vector Offset in OffsetArray )
    {
        vector NewOrigin = _PositionBasedOnAngle( widow.ship.GetOrigin() + OffsetDoorR + Offset, widow.ship.GetAngles().y, widow.ship.GetOrigin() )
        widow.doorR.append( _CreateSarahProp( widow, NewOrigin, <0,90,0> ) )
    }
}

void function _CreateDoorL( WidowStruct widow )
{
    array<vector> OffsetArray = [ < 0,0,0>, < 50,0,0>, < 100,0,0>, < 150,0,0>, < 200,0,0>, < 250,0,0>, < 300,0,0>, < 350,0,0>, < 400,0,0>, < 450,0,0>, < 500,0,0> ]
    OffsetArray.extend( [ < 0,0,100>, < 50,0,100>, < 100,0,100>, < 150,0,100>, < 200,0,100>, < 250,0,100>, < 300,0,100>, < 350,0,100>, < 400,0,100>, < 450,0,100>, < 500,0,100> ] )
    
    foreach( vector Offset in OffsetArray )
    {
        vector NewOrigin = _PositionBasedOnAngle( widow.ship.GetOrigin() + OffsetDoorL + Offset, widow.ship.GetAngles().y, widow.ship.GetOrigin() )
        widow.doorL.append( _CreateSarahProp( widow, NewOrigin, <0,90,0> ) )
    }
}

void function _DestroyDoorR( WidowStruct widow )
{
    foreach( entity door in widow.doorR )
    {
        door.Destroy()
    }
    widow.doorR.clear()
}

void function _DestroyDoorL( WidowStruct widow )
{
    foreach( entity door in widow.doorL )
    {
        door.Destroy()
    }
    widow.doorL.clear()
}

entity function _CreateSarahProp( WidowStruct widow, vector origin, vector angles )
{
    entity Prop = CreateEntity( "prop_dynamic" )
    
	Prop.SetValueForModelKey( $"models/humans/heroes/mlt_hero_sarah.mdl" )
	Prop.kv.solid = SOLID_BBOX
    Prop.kv.rendercolor = "81 130 151"
	Prop.SetOrigin( origin )
	Prop.SetAngles( angles )
    Prop.SetParent( widow.ship )

	Prop.SetBlocksRadiusDamage( true )
	DispatchSpawn( Prop )

    Prop.Hide()

    return Prop
}



/*
██╗   ██╗████████╗██╗██╗     ██╗████████╗██╗███████╗███████╗
██║   ██║╚══██╔══╝██║██║     ██║╚══██╔══╝██║██╔════╝██╔════╝
██║   ██║   ██║   ██║██║     ██║   ██║   ██║█████╗  ███████╗
██║   ██║   ██║   ██║██║     ██║   ██║   ██║██╔══╝  ╚════██║
╚██████╔╝   ██║   ██║███████╗██║   ██║   ██║███████╗███████║
 ╚═════╝    ╚═╝   ╚═╝╚══════╝╚═╝   ╚═╝   ╚═╝╚══════╝╚══════╝
                                                                                                
*/

void function SpawnFollowingShip( entity player )
{
    WidowStruct widow = CreateWidow( player, <0,0,500> + player.GetOrigin(), <0,90,0> )

    thread FollowOnX( widow, player )
}


void function CloseDoorL( WidowStruct widow )
{
    switch ( widow.DOORSTATE )
    {
        case BOTHCLOSED:
            _CreateDoorL( widow )
            break
		case RIGHTOPEN:
            _CreateDoorL( widow )
            break
        case LEFTOPEN:
            _CreateDoorL( widow )
            widow.ship.Anim_Play( "wd_doors_closing" )
            widow.DOORSTATE = BOTHCLOSED
            break
        case BOTHOPEN:
            _CreateDoorL( widow )
            widow.ship.Anim_Play( "wd_doors_closing_L" )
            widow.ship.Anim_Play( "wd_doors_opening_R" )
            widow.DOORSTATE = RIGHTOPEN
            break
    }
}

void function OpenDoorL( WidowStruct widow )
{
    switch ( widow.DOORSTATE )
    {
        case BOTHCLOSED:
            _DestroyDoorL( widow )
            widow.ship.Anim_Play( "wd_doors_opening_L" )
            widow.DOORSTATE = LEFTOPEN
            break
		case RIGHTOPEN:
            _DestroyDoorL( widow )
            widow.ship.Anim_Play( "wd_doors_opening" )
            widow.DOORSTATE = BOTHOPEN
            break
        case LEFTOPEN:
            break
        case BOTHOPEN:
            break
    }
}

void function CloseDoorR( WidowStruct widow )
{
    switch ( widow.DOORSTATE )
    {
        case BOTHCLOSED:
            _CreateDoorR( widow )
            break
		case RIGHTOPEN:
            _CreateDoorR( widow )
            widow.ship.Anim_Play( "wd_doors_closing" )
            widow.DOORSTATE = BOTHCLOSED
            break
        case LEFTOPEN:
            _CreateDoorR( widow )
            break
        case BOTHOPEN:
            _CreateDoorR( widow )
            widow.ship.Anim_Play( "wd_doors_closing_R" )
            widow.ship.Anim_Play( "wd_doors_opening_L" )
            widow.DOORSTATE = LEFTOPEN
            break
    }
}

void function OpenDoorR( WidowStruct widow )
{
    switch ( widow.DOORSTATE )
    {
        case BOTHCLOSED:
            _DestroyDoorR( widow )
            widow.ship.Anim_Play( "wd_doors_opening_R" )
            widow.DOORSTATE = RIGHTOPEN
            break
		case RIGHTOPEN:
            break
        case LEFTOPEN:
            _DestroyDoorR( widow )
            widow.ship.Anim_Play( "wd_doors_opening" )
            widow.DOORSTATE = BOTHOPEN
            break
        case BOTHOPEN:
            break
    }
}

void function doorCycle( WidowStruct widow, float Time )
{
    for( int x=0; x<50 ; x++ )
    {
        wait( Time )
        if ( x % 2 == 0 ){
            OpenDoorL( widow )
        }
        else{
            CloseDoorL( widow )
        }
    }
}

void function FollowOnX( WidowStruct widow, entity Target )
{
    widow.following = true
    float TDistance
    for(;;)
    {
        if ( !widow.following )
            break
            
        TDistance = Target.GetOrigin().x - widow.ship.GetOrigin().x
        widow.ship.SetOrigin( widow.ship.GetOrigin() + Vector(TDistance,0,0) )
        
        foreach( player in GetPlayerArray() )
        {
            if ( DistanceSqr( player.GetOrigin(), widow.ship.GetOrigin() ) <= HullSize )
            {
                player.SetOrigin( player.GetOrigin() + Vector(TDistance,0,0) )
            }
        }

        WaitFrame()
    }
}
void function FollowOnY( WidowStruct widow, entity Target )
{
    widow.following = true
    float TDistance
    for(;;)
    {
        if ( !widow.following )
            break
            
        TDistance = Target.GetOrigin().y - widow.ship.GetOrigin().y
        widow.ship.SetOrigin( widow.ship.GetOrigin() + Vector(0,TDistance,0) )
        
        foreach( player in GetPlayerArray() )
        {
            if ( DistanceSqr( player.GetOrigin(), widow.ship.GetOrigin() ) <= HullSize )
            {
                player.SetOrigin( player.GetOrigin() + Vector(0,TDistance,0) )
            }
        }

        WaitFrame()
    }
}
void function FollowOnZ( WidowStruct widow, entity Target )
{
    widow.following = true
    float TDistance
    for(;;)
    {
        if ( !widow.following )
            break
            
        TDistance = Target.GetOrigin().z - widow.ship.GetOrigin().z
        widow.ship.SetOrigin( widow.ship.GetOrigin() + Vector(0,0,TDistance) )
        
        foreach( player in GetPlayerArray() )
        {
            if ( DistanceSqr( player.GetOrigin(), widow.ship.GetOrigin() ) <= HullSize )
            {
                player.SetOrigin( player.GetOrigin() + Vector(0,0,TDistance) )
            }
        }

        WaitFrame()
    }
}

void function TravelOnX( WidowStruct widow, int XDistance, int SpeedPerFrame )
{
    int AbsDistance = abs(XDistance)
    for(;;)
    {
        if ( AbsDistance <= 0 )
            break
        AbsDistance -= abs(SpeedPerFrame)
        widow.ship.SetOrigin( widow.ship.GetOrigin() + Vector(SpeedPerFrame,0,0) )
        
        foreach( player in GetPlayerArray() )
        {
            if ( DistanceSqr( player.GetOrigin(), widow.ship.GetOrigin() ) <= HullSize )
            {
                player.SetOrigin( player.GetOrigin() + Vector(SpeedPerFrame,0,0) )
            }
        }

        WaitFrame()
    }
}
void function TravelOnY( WidowStruct widow, int YDistance, int SpeedPerFrame )
{
    int AbsDistance = abs(YDistance)
    for(;;)
    {
        if ( AbsDistance <= 0 )
            break
        AbsDistance -= abs(SpeedPerFrame)
        widow.ship.SetOrigin( widow.ship.GetOrigin() + Vector(0,SpeedPerFrame,0) )

        foreach( player in GetPlayerArray() )
        {
            if ( DistanceSqr( player.GetOrigin(), widow.ship.GetOrigin() ) <= HullSize )
            {
                player.SetOrigin( player.GetOrigin() + Vector(0,SpeedPerFrame,0) )
            }
        }

        WaitFrame()
    }
}
void function TravelOnZ( WidowStruct widow, int ZDistance, int SpeedPerFrame )
{
    int AbsDistance = abs(ZDistance)
    for(;;)
    {
        if ( AbsDistance <= 0 )
            break
        AbsDistance -= abs(SpeedPerFrame)
        widow.ship.SetOrigin( widow.ship.GetOrigin() + Vector(0,0,SpeedPerFrame) )
        
        foreach( player in GetPlayerArray() )
        {
            if ( DistanceSqr( player.GetOrigin(), widow.ship.GetOrigin() ) <= HullSize )
            {
                player.SetOrigin( player.GetOrigin() + Vector(0,0,SpeedPerFrame) )
            }
        }

        WaitFrame()
    }
}

void function TeleportWidow( WidowStruct widow, vector destination, vector angles )
{
    entity fx = PlayFX( FX_GUNSHIP_CRASH_EXPLOSION_EXIT, widow.ship.GetOrigin(), widow.ship.GetAngles() )
    fx.FXEnableRenderAlways()
    fx.DisableHibernation()

    foreach( player in GetPlayerArray() )
    {
       if ( DistanceSqr( player.GetOrigin(), widow.ship.GetOrigin() ) <= HullSize )
       {
           player.SetOrigin( destination + <0,0,200> )
       }
    //    print( player )
    //    print( DistanceSqr( player.GetOrigin(), widow.ship.GetOrigin() ) <= HullSize )
    }

    widow.ship.SetOrigin( destination )

    entity fx2 = PlayFX( FX_GUNSHIP_CRASH_EXPLOSION_ENTRANCE, widow.ship.GetOrigin(), widow.ship.GetAngles() )
    fx2.FXEnableRenderAlways()
    fx2.DisableHibernation()
}

void function WarpOutThenDestroyShip( WidowStruct widow )
{
    entity fx = PlayFX( FX_GUNSHIP_CRASH_EXPLOSION_EXIT, widow.ship.GetOrigin(), widow.ship.GetAngles() )
    fx.FXEnableRenderAlways()
    fx.DisableHibernation()

    CloseDoorL( widow )
    CloseDoorR( widow )
    widow.ship.Destroy()
}