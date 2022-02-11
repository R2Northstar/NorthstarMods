untyped


global function MenuMapSelect_Init

global function InitMapsMenu


const int BUTTONS_PER_PAGE = 4


struct {
	int deltaX = 0
	int deltaY = 0
} mouseDeltaBuffer

struct {
	int mapsPerPage = 21
	int currentMapPage
	
	array< var > gridButtons
	array< string > mapsArrayFiltered
	
	int scrollOffset = 0
	
	var menu
} file


// note: this does have a scrolling system in vanilla, but it's honestly really weird and jank and i don't like it
// so for parity with menu_mode_select i'm removing it in favour of a page system
// fuck you respawn, too lazy to make a good menu or what ^

// Important: 
// ClientCommand( "SetCustomMap " + mapName )
// CloseActiveMenu()

void function MenuMapSelect_Init()
{
	RegisterSignal( "OnCloseMapsMenu" )
}

void function InitMapsMenu()
{
	file.menu = GetMenu( "MapsMenu" )
	
	AddMouseMovementCaptureHandler( file.menu, UpdateMouseDeltaBuffer )
	

	AddMenuEventHandler( file.menu, eUIEvent.MENU_CLOSE, OnCloseMapsMenu )
	AddMenuEventHandler( file.menu, eUIEvent.MENU_OPEN, OnOpenMapsMenu )

	//AddEventHandlerToButtonClass( menu, "MapButtonClass", UIE_GET_FOCUS, MapButton_Focused )
	//AddEventHandlerToButtonClass( menu, "MapButtonClass", UIE_LOSE_FOCUS, MapButton_LostFocus )
	//AddEventHandlerToButtonClass( menu, "MapButtonClass", UIE_CLICK, MapButton_Activate )

	AddMenuFooterOption( file.menu, BUTTON_A, "#A_BUTTON_SELECT" )
	AddMenuFooterOption( file.menu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )
	
	AddButtonEventHandler( Hud_GetChild( file.menu, "BtnMapGridUpArrow"), UIE_CLICK, OnUpArrowSelected )
	AddButtonEventHandler( Hud_GetChild( file.menu, "BtnMapGridDownArrow"), UIE_CLICK, OnDownArrowSelected )
	
	//AddButtonEventHandler( Hud_GetChild( file.menu, "BtnFiltersClear"), UIE_CLICK, OnBtnFiltersClear_Activate )
	
	RuiSetString( Hud_GetRui( Hud_GetChild( file.menu, "SwtBtnShowMaps")), "buttonText", "")
	
	file.gridButtons = GetElementsByClassname( file.menu, "MapGridButtons" )
	
	
	FilterMapsArray()
}


// https://youtu.be/VHi2wKBKBc4

void function OnCloseMapsMenu()
{
	Signal( uiGlobal.signalDummy, "OnCloseMapsMenu" )
}

void function OnOpenMapsMenu()
{
	file.scrollOffset = 0
	FilterMapsArray()
	UpdateMapsGrid()
	UpdateMapsInfo()
	UpdateListSliderHeight()
	UpdateListSliderPosition()
	UpdateNextMapInfo()
}

void function UpdateMapsInfo()
{
	RuiSetImage( Hud_GetRui( Hud_GetChild( file.menu, "NextMapImage" ) ), "basicImage", GetMapImageForMapName( "mp_forwardbase_kodai" ) )
}

void function UpdateNextMapInfo()
{
	array< string > mapsArray = file.mapsArrayFiltered
	
	var nextMapName = Hud_GetChild( file.menu, "NextMapName" )
	Hud_SetText( nextMapName, GetMapDisplayName( mapsArray[ 0 ] ) )
}

void function UpdateMapsGrid()
{	
	HideAllMapButtons()
	
	array< string > mapsArray = file.mapsArrayFiltered
	
	
	int trueOffset = file.scrollOffset * 3
	
	foreach ( int _index,  var element in file.gridButtons )
	{
		if ( ( _index + trueOffset ) >= mapsArray.len() ) return
		
		var mapImage = Hud_GetChild( element, "MapImage" )
		var mapName = Hud_GetChild( element, "MapName" )
		
		RuiSetImage( Hud_GetRui( mapImage ), "basicImage", GetMapImageForMapName( mapsArray[ _index + trueOffset ] ) )
		Hud_SetText( mapName, GetMapDisplayName( mapsArray[ _index + trueOffset ] ) )
		
		MakeMapButtonVisible( element )
	}
}

void function FilterMapsArray()
{
	file.mapsArrayFiltered.clear()
	
	foreach ( string map in GetPrivateMatchMaps() )
		file.mapsArrayFiltered.append( map )
	
}

void function HideAllMapButtons()
{
	foreach ( var element in file.gridButtons )
		Hud_SetVisible( element, false )
}

// :trol:
void function MakeMapButtonVisible( var element )
{
	Hud_SetVisible( element, true )
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
	if ( file.mapsArrayFiltered.len() <= BUTTONS_PER_PAGE )
	{
		FlushMouseDeltaBuffer()
		return
	}

	var sliderButton = Hud_GetChild( file.menu , "BtnMapGridSlider" )
	var sliderPanel = Hud_GetChild( file.menu , "BtnMapGridSliderPanel" )
	var movementCapture = Hud_GetChild( file.menu , "MouseMovementCapture" )

	Hud_SetFocused(sliderButton)

	float minYPos = -40.0 * (GetScreenSize()[1] / 1080.0)
	float maxHeight = 584.0  * (GetScreenSize()[1] / 1080.0)
	float maxYPos = minYPos - (maxHeight - Hud_GetHeight( sliderPanel ))
	float useableSpace = ( maxHeight - Hud_GetHeight( sliderPanel ))

	float jump = minYPos - ( useableSpace / (  file.mapsArrayFiltered.len() / 3 + 1 ))

	// got local from official respaw scripts, without untyped throws an error
	local pos =	Hud_GetPos(sliderButton)[1]
	local newPos = pos - mouseDeltaBuffer.deltaY
	FlushMouseDeltaBuffer()

	if ( newPos < maxYPos ) newPos = maxYPos
	if ( newPos > minYPos ) newPos = minYPos

	Hud_SetPos( sliderButton , 2, newPos )
	Hud_SetPos( sliderPanel , 2, newPos )
	Hud_SetPos( movementCapture , 2, newPos )

	file.scrollOffset = -int( ( (newPos - minYPos) / useableSpace ) * ( file.mapsArrayFiltered.len() / 3 + 1 - BUTTONS_PER_PAGE) )
	UpdateMapsGrid()
}

void function UpdateListSliderHeight()
{
	var sliderButton = Hud_GetChild( file.menu , "BtnMapGridSlider" )
	var sliderPanel = Hud_GetChild( file.menu , "BtnMapGridSliderPanel" )
	var movementCapture = Hud_GetChild( file.menu , "MouseMovementCapture" )
	
	float maps = float ( file.mapsArrayFiltered.len() / 3 )

	float maxHeight = 584.0 * (GetScreenSize()[1] / 1080.0)
	float minHeight = 80.0 * (GetScreenSize()[1] / 1080.0)

	float height = maxHeight * ( float( BUTTONS_PER_PAGE ) / maps )

	if ( height > maxHeight ) height = maxHeight
	if ( height < minHeight ) height = minHeight

	Hud_SetHeight( sliderButton , height )
	Hud_SetHeight( sliderPanel , height )
	Hud_SetHeight( movementCapture , height )
}


void function UpdateListSliderPosition()
{
	var sliderButton = Hud_GetChild( file.menu , "BtnMapGridSlider" )
	var sliderPanel = Hud_GetChild( file.menu , "BtnMapGridSliderPanel" )
	var movementCapture = Hud_GetChild( file.menu , "MouseMovementCapture" )
	
	float maps = float ( file.mapsArrayFiltered.len() / 3 + 1 )

	float minYPos = -40.0 * (GetScreenSize()[1] / 1080.0)
	float useableSpace = (584.0 * (GetScreenSize()[1] / 1080.0) - Hud_GetHeight( sliderPanel ))

	float jump = minYPos - ( useableSpace / ( maps - float( BUTTONS_PER_PAGE ) ) * file.scrollOffset )

	//jump = jump * (GetScreenSize()[1] / 1080.0)

	if ( jump > minYPos ) jump = minYPos

	Hud_SetPos( sliderButton , 2, jump )
	Hud_SetPos( sliderPanel , 2, jump )
	Hud_SetPos( movementCapture , 2, jump )
}

void function OnDownArrowSelected( var button )
{
	if ( file.mapsArrayFiltered.len() <= BUTTONS_PER_PAGE ) return
	file.scrollOffset += 1
	if ((file.scrollOffset + BUTTONS_PER_PAGE) * 3 > file.mapsArrayFiltered.len()) {
		file.scrollOffset = (file.mapsArrayFiltered.len() - BUTTONS_PER_PAGE * 3) / 3 + 1
	}
	UpdateMapsGrid()
	UpdateListSliderPosition()
	printt(file.scrollOffset)
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
	if ( file.mapsArrayFiltered.len() <= BUTTONS_PER_PAGE ) return
	file.scrollOffset += 5
	if (file.scrollOffset + BUTTONS_PER_PAGE > file.mapsArrayFiltered.len()) {
		file.scrollOffset = file.mapsArrayFiltered.len() - BUTTONS_PER_PAGE
	}
	UpdateMapsGrid()
	UpdateListSliderPosition()
}

void function OnScrollUp( var button )
{
	file.scrollOffset -= 5
	if (file.scrollOffset < 0) {
		file.scrollOffset = 0
	}
	UpdateMapsGrid()
	UpdateListSliderPosition()
}