global function InitSharedStartPoints
global function GetStartPointsForMap
global function MapHasStartPoint
global function GetStartPointsFromCSV
global function GetStartPointIndexFromName
global function GetStartPointNameFromIndex
global function GetStartPointLoadImageIndex
global function StartPointHasDetente
global function ExecuteLoadingClientCommands_SetStartPoint
global function GetLoadingClientCommands
global function ExecuteClientCommands
global function Dev_GetStartCommandLine
global function GetStartPointToLastGameplayLegalStartPoint

global const int DETENT_FORCE_ENABLE = 1
global const int DETENT_FROM_STARTPOINT = 0
global const int DETENT_FORCE_DISABLE = -1

global const bool COOPERS_LOG_FROM_STARTPOINT = true
global const bool COOPERS_LOG_FORCE_DISABLED = false

global const STARTPOINT_DEV_STRING = "-startpoint"

global struct StartPointCSV
{
	string name
	int loadScreenIndex
	bool hasDetente
	string spLog
	string spLogTitle
	bool isLeft
}

struct
{
	table<string, array<StartPointCSV> > startPointStrings
} file

void function AddStartPoints( string map, array<StartPointCSV> startPoints )
{
	Assert( !( map in file.startPointStrings ) )
	file.startPointStrings[ map ] <- startPoints
}

array<StartPointCSV> function GetStartPointsForMap( string map )
{
	if ( !( map in file.startPointStrings ) )
		return []

	return file.startPointStrings[ map ]
}

int function GetStartPointLoadImageIndex( string map, string startpoint )
{
	Assert( map in file.startPointStrings )
	array<StartPointCSV> startPoints = file.startPointStrings[ map ]
	foreach ( StartPointCSV startPointCSV in startPoints )
	{
		if ( startPointCSV.name == startpoint )
			return startPointCSV.loadScreenIndex
	}
	unreachable
}

string function GetStartPointSpLog( string map, string startpoint )
{
	Assert( map in file.startPointStrings )
	array<StartPointCSV> startPoints = file.startPointStrings[ map ]
	foreach ( StartPointCSV startPointCSV in startPoints )
	{
		if ( startPointCSV.name == startpoint )
			return startPointCSV.spLog
	}
	unreachable
}

string function GetStartPointSpLogTitle( string map, string startpoint )
{
	Assert( map in file.startPointStrings )
	array<StartPointCSV> startPoints = file.startPointStrings[ map ]
	foreach ( StartPointCSV startPointCSV in startPoints )
	{
		if ( startPointCSV.name == startpoint )
			return startPointCSV.spLogTitle
	}
	unreachable
}

bool function StartPointSPLogIsLeft( string map, string startpoint )
{
	Assert( map in file.startPointStrings )
	array<StartPointCSV> startPoints = file.startPointStrings[ map ]
	foreach ( StartPointCSV startPointCSV in startPoints )
	{
		if ( startPointCSV.name == startpoint )
			return startPointCSV.isLeft
	}
	unreachable
}

bool function StartPointHasDetente( string map, string startpoint )
{
	Assert( map in file.startPointStrings )
	array<StartPointCSV> startPoints = file.startPointStrings[ map ]
	foreach ( StartPointCSV startPointCSV in startPoints )
	{
		if ( startPointCSV.name == startpoint )
			return startPointCSV.hasDetente
	}
	unreachable
}

bool function MapHasStartPoint( string map, string startPoint )
{
	array<StartPointCSV> startPoints = GetStartPointsForMap( map )
	foreach( StartPointCSV _startPoint in startPoints )
	{
		if ( _startPoint.name == startPoint )
			return true
	}
	return false
}

int function GetStartPointIndexFromName( string map, string startpoint )
{
	array<StartPointCSV> startPointsForMap = GetStartPointsForMap( map )

	foreach ( int index, StartPointCSV startpointname in startPointsForMap )
	{
		if ( startpointname.name == startpoint )
			return index
	}
	return 0
}

table< string,array<StartPointCSV> > function GetStartPointsFromCSV()
{
	table< string,array<StartPointCSV> > results
	var dataTable = GetDataTable( $"datatable/startpoints.rpak" )

	for ( int row = 0;; row++ )
	{
		string mapName = GetDataTableString( dataTable, row, 0 )
		string startPointName = GetDataTableString( dataTable, row, 1 )

		if ( mapName == "" )
			continue

		if ( mapName == "eof" )
			break

		if ( !( mapName in results ) )
		{
			results[ mapName ] <- []
		}

		StartPointCSV startPoint
		startPoint.name = startPointName
		startPoint.loadScreenIndex = GetDataTableInt( dataTable, row, 2 )
		startPoint.hasDetente = GetDataTableBool( dataTable, row, 3 )
		startPoint.spLog = GetDataTableString( dataTable, row, 4 )
		startPoint.spLogTitle = GetDataTableString( dataTable, row, 5 )
		startPoint.isLeft = GetDataTableBool( dataTable, row, 6 )

		results[ mapName ].append( startPoint )
	} // TODO: add a function to set these
	results[ "sp_box" ] <- [ CreateStartPointStruct() ]
	results[ "sp_amongus" ] <- [ CreateStartPointStruct() ]
	results[ "sp_skyway_v2" ] <- [ CreateStartPointStruct( "Level Start", 1 ), CreateStartPointStruct( "Rock Jumping", 2 ), CreateStartPointStruct( "Drone Fight", 3 ), CreateStartPointStruct( "Platform Fall", 3 ), CreateStartPointStruct( "Boss Battle", 4 ) ]

	return results
}

StartPointCSV function CreateStartPointStruct( string name = "Level Start", int loadScreenIndex = 0 )
{
	StartPointCSV startPoint
	startPoint.name = name
	startPoint.loadScreenIndex = 0
	startPoint.hasDetente = false
	startPoint.spLog = ""
	startPoint.spLogTitle = ""
	startPoint.isLeft = true

	return startPoint
}

void function InitSharedStartPoints()
{
	#if SERVER
		if ( IsMultiplayer() )
			return
	#endif // SERVER

	table< string,array<StartPointCSV> > startPointsFromCSV = GetStartPointsFromCSV()
	foreach ( mapName, startPoints in startPointsFromCSV )
	{
		AddStartPoints( mapName, startPoints )
	}
}


string function GetStartPointNameFromIndex( string map, int index )
{
	array<StartPointCSV> startPointsForMap = GetStartPointsForMap( map )
	return startPointsForMap[index].name
}

void function ExecuteLoadingClientCommands_SetStartPoint( string mapName, int startPointIndex = 0, int detent = DETENT_FROM_STARTPOINT, bool coopersLog = COOPERS_LOG_FROM_STARTPOINT )
{
	printt( "ExecuteLoadingClientCommands_SetStartPoint " + mapName + " " + startPointIndex )

	SetConVarInt( "sp_startpoint", startPointIndex )

	array<string> clientCommands = GetLoadingClientCommands( mapName, startPointIndex, detent, coopersLog )
	ExecuteClientCommands( clientCommands )
}

string function Dev_GetStartCommandLine( string map )
{
	if ( !Dev_CommandLineHasParm( STARTPOINT_DEV_STRING ) )
		return ""

	string commandLineValue = Dev_CommandLineParmValue( STARTPOINT_DEV_STRING )
	if ( commandLineValue == "" )
		return ""

	array<StartPointCSV> startPointsForMap = GetStartPointsForMap( map )

	int startPointIndex = commandLineValue.tointeger()
	if ( startPointIndex < 0 || startPointIndex > startPointsForMap.len() )
		return ""

	return startPointsForMap[ startPointIndex ].name

	return ""
}

int function GetLoadScreenIndexForStartPoint( string mapName, int startPointIndex )
{
	if ( startPointIndex == 0 )
	{
		// if we are starting the level from the beginning then force the default
		// load screen, so the scripters don't have to create an empty start point
		// for the sake of the first mid-level load image
		return 0
	}

	string startpoint = GetStartPointNameFromIndex( mapName, startPointIndex )
	return GetStartPointLoadImageIndex( mapName, startpoint )
}


void function ExecuteClientCommands( array<string> clientCommands )
{
	#if SERVER
	foreach ( player in GetPlayerArray() )
	{
		printt( "Executing client commands for " + player + ":" )
		foreach ( command in clientCommands )
		{
			printt( command )
			ClientCommand( player, command )
		}
	}
	#endif

	#if UI
	printt( "Executing client commands:" )
	foreach ( command in clientCommands )
	{
		printt( command )
		ClientCommand( command )
	}
	#endif
}

array<string> function GetLoadingClientCommands( string mapName, int startPointIndex, int detent, bool coopersLog )
{
	array< array<string> functionref( string, int ) > commands

	commands.append( GetLoadingClientCommands_LoadImage )

	switch ( detent )
	{
		case DETENT_FORCE_ENABLE:
			commands.append( GetLoadingClientCommands_SetDetent )
			break

		case DETENT_FROM_STARTPOINT:
			commands.append( GetLoadingClientCommands_DetentForStartPoint )
			break

		case DETENT_FORCE_DISABLE:
			commands.append( GetLoadingClientCommands_ClearDetent )
			break

		default:
			Assert( 0, "Unknown detent setting " + detent )
	}

	if ( coopersLog )
		commands.append( GetLoadingClientCommands_SetCoopersLog )
	else
		commands.append( GetLoadingClientCommands_ClearCoopersLog )

	array<string> clientCommands = [ "mp_gamemode solo" ]

	foreach ( command in commands )
	{
		clientCommands.extend( command( mapName, startPointIndex ) )
	}

	return clientCommands
}

array<string> function GetLoadingClientCommands_DetentForStartPoint( string mapName, int startPointIndex )
{
	string startpoint = GetStartPointNameFromIndex( mapName, startPointIndex )
	if ( StartPointHasDetente( mapName, startpoint ) )
		return GetLoadingClientCommands_SetDetent( mapName, startPointIndex )

	return GetLoadingClientCommands_ClearDetent( mapName, startPointIndex )
}

array<string> function GetLoadingClientCommands_SetDetent( string mapName, int startPointIndex )
{
	return [ "set_loading_progress_detente #INTROSCREEN_HINT_PC #INTROSCREEN_HINT_CONSOLE" ]
}

array<string> function GetLoadingClientCommands_ClearDetent( string mapName, int startPointIndex )
{
	return [ "clear_loading_progress_detente" ]
}

array<string> function GetLoadingClientCommands_LoadImage( string mapName, int startPointIndex )
{
	int loadScreenIndex = GetLoadScreenIndexForStartPoint( mapName, startPointIndex )

	return [ "set_loading_progress_background " + loadScreenIndex, "set_loading_progress_fadeout_enabled 1" ]
}

array<string> function GetLoadingClientCommands_SetCoopersLog( string mapName, int startPointIndex )
{
	int loadScreenIndex = GetLoadScreenIndexForStartPoint( mapName, startPointIndex )
	string startpoint = GetStartPointNameFromIndex( mapName, startPointIndex )
	string logText = GetStartPointSpLog( mapName, startpoint )

	if ( logText == "" )
		return [ "clear_loading_progress_sp_text" ]

	// Make sure trial mode doesn't reveal any spoilers!
	if ( Script_IsRunningTrialVersion() )
		return [ "clear_loading_progress_sp_text" ]

	string logTitle = GetStartPointSpLogTitle( mapName, startpoint )
	bool isLeft = StartPointSPLogIsLeft( mapName, startpoint )

	return [ "set_loading_progress_sp_text " + logText + " " + logTitle + " " + isLeft ]
}

array<string> function GetLoadingClientCommands_ClearCoopersLog( string mapName, int startPointIndex )
{
	return [ "clear_loading_progress_sp_text" ]
}

int function GetStartPointToLastGameplayLegalStartPoint( string mapName, int startPointIndex )
{
	for ( int i = startPointIndex; i > 0; i-- )
	{
		// some start points are game-play legal places to start from
		string startPointEnum = GetStartPointNameFromIndex( mapName, i )
		if ( StartPointHasDetente( mapName, startPointEnum ) )
		{
			return i
		}
	}

	// 0 is the first startpoint on all levels
	return 0
}