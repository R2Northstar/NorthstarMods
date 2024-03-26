untyped


global function SB_MenuMapSelect_Init

global function SB_InitMapsMenu

const int GRID_COLUMN_NUMBER = 4
const int GRID_ROW_NUMBER = 5

const int MAPS_PER_PAGE = GRID_COLUMN_NUMBER * GRID_ROW_NUMBER


struct {
	int deltaX = 0
	int deltaY = 0
} mouseDeltaBuffer

struct {
	array< var > gridInfos
	array< var > gridButtons
	
	array< string > mapsArray
	
	int scrollOffset = 0
	
	int lastSelectedID
	
	var menu
} file





void function SB_MenuMapSelect_Init()
{
	RegisterSignal( "OnCloseMapsMenu" )
}

void function SB_InitMapsMenu()
{
	file.menu = GetMenu( "SB_MapsMenu" )
	
	AddMouseMovementCaptureHandler( Hud_GetChild(file.menu, "MouseMovementCapture"), UpdateMouseDeltaBuffer )
	

	AddMenuEventHandler( file.menu, eUIEvent.MENU_CLOSE, OnCloseMapsMenu )
	AddMenuEventHandler( file.menu, eUIEvent.MENU_OPEN, OnOpenMapsMenu )

	

	AddMenuFooterOption( file.menu, BUTTON_A, "#A_BUTTON_SELECT" )
	AddMenuFooterOption( file.menu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )
	
	AddButtonEventHandler( Hud_GetChild( file.menu, "BtnMapGridUpArrow"), UIE_CLICK, OnUpArrowSelected )
	AddButtonEventHandler( Hud_GetChild( file.menu, "BtnMapGridDownArrow"), UIE_CLICK, OnDownArrowSelected )
	
	file.gridInfos = GetElementsByClassname( file.menu, "MapGridInfo" )
	
	file.gridButtons = GetElementsByClassname( file.menu, "MapGridButtons" )
	
	AddButtonEventHandler( Hud_GetChild( Hud_GetChild( file.menu , "MapsGridPanel" ), "DummyTop" ), UIE_GET_FOCUS, OnHitDummyTop )
	AddButtonEventHandler( Hud_GetChild( Hud_GetChild( file.menu , "MapsGridPanel" ), "DummyBottom" ), UIE_GET_FOCUS, OnHitDummyBottom )
	
	// uhh
	foreach ( var button in file.gridButtons )
	{
		AddButtonEventHandler( button, UIE_CLICK, MapButton_Activate )
		AddButtonEventHandler( button, UIE_GET_FOCUS, MapButton_Focus )
	}
}


// https://youtu.be/VHi2wKBKBc4 // WTF is this ??

void function OnCloseMapsMenu()
{
	Signal( uiGlobal.signalDummy, "OnCloseMapsMenu" )
	
	try
	{
		DeregisterButtonPressedCallback(MOUSE_WHEEL_UP , OnScrollUp)
		DeregisterButtonPressedCallback(MOUSE_WHEEL_DOWN , OnScrollDown)
	}
	catch ( ex ) {}
}

void function OnOpenMapsMenu()
{	
	file.mapsArray = GetPrivateMatchMaps()
	
	RefreshList()
	
	Hud_SetFocused( file.gridButtons[0] )
	
	RegisterButtonPressedCallback(MOUSE_WHEEL_UP , OnScrollUp)
	RegisterButtonPressedCallback(MOUSE_WHEEL_DOWN , OnScrollDown)
}

void function OnHitDummyTop( var button )
{
	if( file.scrollOffset == 0 )
	{
		Hud_SetFocused( file.gridButtons[ file.lastSelectedID ] )
		return
	}
	
	file.scrollOffset--
	
	UpdateMapsGrid()
	UpdateListSliderPosition()
	UpdateNextMapInfo()
	
	Hud_SetFocused( file.gridButtons[ file.lastSelectedID ] )
}

void function OnHitDummyBottom( var button )
{
	if ( file.mapsArray.len() <= GRID_ROW_NUMBER || file.mapsArray.len() <= MAPS_PER_PAGE ) // 12
		return
		
	file.scrollOffset += 1
	
	int compensate = 0
	if ( file.mapsArray.len() % GRID_COLUMN_NUMBER != 0 )
		compensate = 1
	
	if ((file.scrollOffset + GRID_ROW_NUMBER) * GRID_COLUMN_NUMBER > file.mapsArray.len())
		file.scrollOffset = (file.mapsArray.len() - GRID_ROW_NUMBER * GRID_COLUMN_NUMBER) / GRID_COLUMN_NUMBER + compensate
	
	UpdateMapsGrid()
	UpdateListSliderPosition()
	UpdateNextMapInfo()
	
	int scriptID = file.lastSelectedID
	
	if( scriptID > file.mapsArray.len() - 1 - file.scrollOffset * GRID_COLUMN_NUMBER )
		scriptID = file.mapsArray.len() - file.scrollOffset * GRID_COLUMN_NUMBER - 1
	
	
	var lastButton = file.gridButtons[ scriptID ]
	
	Hud_SetFocused( lastButton )
}

void function RefreshList()
{
	file.scrollOffset = 0
	UpdateMapsGrid()
	if ( file.mapsArray.len() != 0 )
		UpdateMapsInfo( file.mapsArray[0] )
	UpdateListSliderHeight()
	UpdateListSliderPosition()
	UpdateNextMapInfo()
}

void function MapButton_Activate( var button )
{
	if ( !AmIPartyLeader() && GetPartySize() > 1 )
		return

	int mapID = int( Hud_GetScriptID(  button  ) )
	string mapName = file.mapsArray[ mapID + file.scrollOffset * GRID_COLUMN_NUMBER ]
	
	printt( mapName, mapID )

	UpdateMapsInfo( mapName )
	SetConVarString("filter_map", mapName)
	CloseActiveMenu()
}

void function MapButton_Focus( var button )
{
	int mapID = int( Hud_GetScriptID(  button  ) )
	string mapName = file.mapsArray[ mapID + file.scrollOffset * GRID_COLUMN_NUMBER ]
	
	file.lastSelectedID = mapID
	
	UpdateMapsInfo( mapName )
}

void function OnBtnFiltersClear_Activate( var button )
{
	Hud_SetText( Hud_GetChild( file.menu, "BtnMapsSearch" ), "" )

	SetConVarInt( "filter_map_hide_locked", 0 )
	
	RefreshList()
}

void function UpdateMapsInfo( string map )
{
	RuiSetImage( Hud_GetRui( Hud_GetChild( file.menu, "NextMapImage" ) ), "basicImage", GetMapImageForMapName( map ) )
	Hud_SetText( Hud_GetChild( file.menu, "NextMapDescription" ), GetMapDisplayDesc( map ) )
	Hud_SetText( Hud_GetChild( file.menu, "NextMapName" ), GetMapDisplayName( map ) )
}

void function UpdateNextMapInfo()
{
	array< string > mapsArray = file.mapsArray
	
	if( !mapsArray.len() )
		return
	
	var nextMapName = Hud_GetChild( file.menu, "NextMapName" )
	Hud_SetText( nextMapName, GetMapDisplayName( mapsArray[ 0 ] ) )
}

void function UpdateMapsGrid()
{	
	HideAllMapButtons()
	
	array< string > mapsArray = file.mapsArray
	
	printt(file.scrollOffset)
	
	int trueOffset = file.scrollOffset * GRID_COLUMN_NUMBER
	
	foreach ( int _index,  var element in file.gridInfos )
	{
		if ( ( _index + trueOffset ) >= mapsArray.len() ) return
		
		var mapImage = Hud_GetChild( element, "MapImage" )
		var mapName = Hud_GetChild( element, "MapName" )
		
		string name = mapsArray[ _index + trueOffset ]
		
		RuiSetImage( Hud_GetRui( mapImage ), "basicImage", GetMapImageForMapName( name ) )
		Hud_SetText( mapName, GetMapDisplayName( name ) )
		
		Hud_SetVisible( file.gridButtons[ _index ], true )
		MakeMapButtonVisible( element )
	}
}

void function HideAllMapButtons()
{
	foreach ( _index, var element in file.gridInfos )
	{
		Hud_SetVisible( element, false )
		
		var mapButton = file.gridButtons[ _index ]
		var mapFG = Hud_GetChild( element, "MapNameLockedForeground" )
		
		Hud_SetLocked( mapButton, false )
		Hud_SetVisible( mapButton, false )
		Hud_SetVisible( mapFG, false )
	}
}

// :trol:
void function MakeMapButtonVisible( var element )
{
	Hud_SetVisible( element, true )
}

void function LockMapButton( var element )
{
	var mapFG = Hud_GetChild( element, "MapNameLockedForeground" )
	
	Hud_SetVisible( mapFG, true )
}

//////////////////////////////
// Slider
//////////////////////////////
void function UpdateMouseDeltaBuffer(int x, int y)
{
	mouseDeltaBuffer.deltaX += x
	mouseDeltaBuffer.deltaY += y

	SliderBarUpdate()
}

void function FlushMouseDeltaBuffer()
{
	mouseDeltaBuffer.deltaX = 0
	mouseDeltaBuffer.deltaY = 0
}


void function SliderBarUpdate()
{
	if ( file.mapsArray.len() <= GRID_ROW_NUMBER || file.mapsArray.len() <= MAPS_PER_PAGE )
	{
		FlushMouseDeltaBuffer()
		return
	}

	var sliderButton = Hud_GetChild( file.menu , "BtnMapGridSlider" )
	var sliderPanel = Hud_GetChild( file.menu , "BtnMapGridSliderPanel" )
	var movementCapture = Hud_GetChild( file.menu , "MouseMovementCapture" )

	Hud_SetFocused(sliderButton)

	float minYPos = -42.0 * (GetScreenSize()[1] / 1080.0)
	float maxHeight = 749.0  * (GetScreenSize()[1] / 1080.0) // 582
	float maxYPos = minYPos - (maxHeight - Hud_GetHeight( sliderPanel ))
	float useableSpace = ( maxHeight - Hud_GetHeight( sliderPanel ))

	float jump = minYPos - ( useableSpace / (  file.mapsArray.len() / GRID_COLUMN_NUMBER + 1 ))

	// got local from official respaw scripts, without untyped throws an error
	local pos =	Hud_GetPos(sliderButton)[1]
	local newPos = pos - mouseDeltaBuffer.deltaY
	FlushMouseDeltaBuffer()

	if ( newPos < maxYPos ) newPos = maxYPos
	if ( newPos > minYPos ) newPos = minYPos

	Hud_SetPos( sliderButton , 2, newPos )
	Hud_SetPos( sliderPanel , 2, newPos )
	Hud_SetPos( movementCapture , 2, newPos )

	int compensate = 0
	if ( file.mapsArray.len() % GRID_COLUMN_NUMBER != 0 )
		compensate = 1

	file.scrollOffset = -int( ( (newPos - minYPos) / useableSpace ) * ( file.mapsArray.len() / GRID_COLUMN_NUMBER + compensate - GRID_ROW_NUMBER) )
	UpdateMapsGrid()
}

void function UpdateListSliderHeight()
{
	var sliderButton = Hud_GetChild( file.menu , "BtnMapGridSlider" )
	var sliderPanel = Hud_GetChild( file.menu , "BtnMapGridSliderPanel" )
	var movementCapture = Hud_GetChild( file.menu , "MouseMovementCapture" )
	
	float maps = file.mapsArray.len() / float( GRID_COLUMN_NUMBER ) 

	float maxHeight = 749.0 * (GetScreenSize()[1] / 1080.0) // 582
	float minHeight = 80.0 * (GetScreenSize()[1] / 1080.0)

	float height = maxHeight * ( float( GRID_ROW_NUMBER ) / maps )

	printt(file.mapsArray.len())
	printt(maps)
	printt(maxHeight)
	printt(height)

	if ( height > maxHeight ) height = maxHeight
	if ( height < minHeight ) height = minHeight

	Hud_SetHeight( sliderButton , height )
	Hud_SetHeight( sliderPanel , height )
	Hud_SetHeight( movementCapture , height )
}


void function UpdateListSliderPosition()
{
	if ( file.mapsArray.len() == MAPS_PER_PAGE ) // 12
		return
	
	var sliderButton = Hud_GetChild( file.menu , "BtnMapGridSlider" )
	var sliderPanel = Hud_GetChild( file.menu , "BtnMapGridSliderPanel" )
	var movementCapture = Hud_GetChild( file.menu , "MouseMovementCapture" )
	
	int compensate = 0
	if ( file.mapsArray.len() % GRID_COLUMN_NUMBER != 0 )
		compensate = 1
	
	float maps = float ( file.mapsArray.len() / GRID_COLUMN_NUMBER + compensate )

	float minYPos = -42.0 * (GetScreenSize()[1] / 1080.0)
	float useableSpace = (749.0 * (GetScreenSize()[1] / 1080.0) - Hud_GetHeight( sliderPanel )) // 582

	float jump = minYPos - ( useableSpace / ( maps - float( GRID_ROW_NUMBER ) ) * file.scrollOffset )

	if ( jump > minYPos ) jump = minYPos

	Hud_SetPos( sliderButton , 2, jump )
	Hud_SetPos( sliderPanel , 2, jump )
	Hud_SetPos( movementCapture , 2, jump )
}

void function OnDownArrowSelected( var button )
{
	if(file.scrollOffset * GRID_COLUMN_NUMBER + GRID_ROW_NUMBER * GRID_COLUMN_NUMBER >= file.mapsArray.len()) return
	
	file.scrollOffset += 1

	UpdateMapsGrid()
	UpdateListSliderPosition()
}


void function OnUpArrowSelected( var button )
{
	file.scrollOffset -= 1
	if (file.scrollOffset < 0) {
		file.scrollOffset = 0
	}
	UpdateMapsGrid()
	UpdateListSliderPosition()
}

void function OnScrollDown( var button )
{
	if(file.scrollOffset * GRID_COLUMN_NUMBER + GRID_ROW_NUMBER * GRID_COLUMN_NUMBER >= file.mapsArray.len()) return
	file.scrollOffset += 1

	UpdateMapsGrid()
	UpdateListSliderPosition()
}

void function OnScrollUp( var button )
{
	file.scrollOffset -= 1
	if (file.scrollOffset < 0) {
		file.scrollOffset = 0
	}
	UpdateMapsGrid()
	UpdateListSliderPosition()
}