global function MenuMapSelect_Init

global function InitMapsMenu

struct {
	int mapsPerPage = 21
	int currentMapPage
	
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

	AddMenuEventHandler( file.menu, eUIEvent.MENU_CLOSE, OnCloseMapsMenu )

	//AddEventHandlerToButtonClass( menu, "MapButtonClass", UIE_GET_FOCUS, MapButton_Focused )
	//AddEventHandlerToButtonClass( menu, "MapButtonClass", UIE_LOSE_FOCUS, MapButton_LostFocus )
	//AddEventHandlerToButtonClass( menu, "MapButtonClass", UIE_CLICK, MapButton_Activate )

	AddMenuFooterOption( file.menu, BUTTON_A, "#A_BUTTON_SELECT" )
	AddMenuFooterOption( file.menu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )
	
	//RuiSetImage( Hud_GetRui( Hud_GetChild( menu, "NextMapImage" ) ), "basicImage", GetMapImageForMapName( "mp_forwardbase_kodai" ) )
	GetMapButtonMenu()
}


// https://youtu.be/VHi2wKBKBc4

void function OnCloseMapsMenu()
{
	Signal( uiGlobal.signalDummy, "OnCloseMapsMenu" )
}


void function GetMapButtonMenu()
{	
	array< var > GridButtons = GetElementsByClassname( file.menu, "MapGridButtons" )
	
	foreach ( var element in GridButtons )
	{
		var mapImage = Hud_GetChild( element, "MapImage" )
		RuiSetImage( Hud_GetRui( mapImage ), "basicImage", GetMapImageForMapName( "mp_forwardbase_kodai" ) )
	}
}
