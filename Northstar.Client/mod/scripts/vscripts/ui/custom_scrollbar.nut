untyped
global function UseCustomScrollbars
global function RegisterScrollbar
global function RegisterScrollbarMoveCallback
global function SetScrollbarHeight
global function SetScrollbarWidth
global function SetScrollbarOriginalHeight
global function SetScrollbarOriginalWidth
global function SetScrollbarHorizontal

struct ScrollbarExt {
	array<void functionref( int x, int y )> callbacks
	int originalX
	int originalY
	int originalHeight
	int originalWidth
	var scrollbar
	var cover
	var movementCapture
	var button
	var panel
	bool horizontal
}

struct {
	array<ScrollbarExt> scrollbars
	array<var> covers
	var invisCover
} file

// * ###################
// * global functions ##
// * ###################

void function UseCustomScrollbars( var menu )
{
	foreach( var scrollbar in GetElementsByClassname( menu, "NS_Scrollbar" ) )
		RegisterScrollbar( scrollbar )
	foreach( var scrollbar in GetElementsByClassname( menu, "NS_Scrollbar_h" ) )
		RegisterScrollbar( scrollbar, true )

	AddMouseMovementCaptureHandler( menu, MouseMovementHandler )
}

void function RegisterScrollbarMoveCallback( int scrollbarIndex, void functionref( int x, int y ) f )
{
	file.scrollbars[ scrollbarIndex ].callbacks.append( f )
}

void function SetScrollbarHeight( int idx, int height )
{
	Hud_SetHeight( file.scrollbars[ idx ].cover, height)
	Hud_SetHeight( file.scrollbars[ idx ].movementCapture, height)
	Hud_SetHeight( file.scrollbars[ idx ].button, height)
	Hud_SetHeight( file.scrollbars[ idx ].panel, height)
}

void function SetScrollbarWidth( int idx, int width )
{
	Hud_SetWidth( file.scrollbars[ idx ].cover, width)
	Hud_SetWidth( file.scrollbars[ idx ].movementCapture, width)
	Hud_SetWidth( file.scrollbars[ idx ].button, width)
	Hud_SetWidth( file.scrollbars[ idx ].panel, width)
}

void function SetScrollbarOriginalHeight( int idx, int height )
{
	file.scrollbars[ idx ].originalHeight = height
}

void function SetScrollbarOriginalWidth( int idx, int width )
{
	file.scrollbars[ idx ].originalWidth = width
}

void function SetScrollbarHorizontal( int idx, bool horizontal )
{
	file.scrollbars[ idx ].horizontal = horizontal
}

void function RegisterScrollbar( var scrollbar, bool horizontal = false )
{
	var cover = Hud_GetChild( scrollbar, "SliderCover" )
	AddButtonEventHandler( cover, UIE_GET_FOCUS, CoverGetFocus )
	file.covers.append( cover )
	ScrollbarExt bar
	bar.originalX = expect int( Hud_GetPos( cover )[0] )
	bar.originalY = expect int( Hud_GetPos( cover )[1] )
	bar.originalHeight = Hud_GetHeight( scrollbar )
	bar.originalWidth = Hud_GetWidth( scrollbar )
	bar.scrollbar = scrollbar
	bar.cover = cover
	bar.movementCapture = Hud_GetChild( scrollbar, "MouseMovementCapture" )
	bar.button = Hud_GetChild( scrollbar, "SliderButton" )
	bar.panel = Hud_GetChild( scrollbar, "BtnModListSliderPanel" )
	bar.horizontal = horizontal
	file.scrollbars.append( bar )
}

// * #####################
// * internal functions ##
// * #####################

void function CoverGetFocus( var cover )
{
	Hud_SetVisible( cover, false )
	if( file.invisCover )
		Hud_SetVisible( file.invisCover, true )
	file.invisCover = cover

	ScrollbarExt s = file.scrollbars[ GetFocusedScrollbarIndex() ]
	Hud_SetFocused( s.button )
}

void function MouseMovementHandler( int x, int y )
{
	int idx = GetFocusedScrollbarIndex()
	Hud_SetFocused( Hud_GetChild( file.scrollbars[ idx ].scrollbar, "SliderButton" ) )
	if( idx < 0 )
		return
	foreach( void functionref( int x, int y ) callback in file.scrollbars[ idx ].callbacks)
	{
		callback( x, y )
	}

	if( file.scrollbars[ idx ].horizontal )
		RepositionScrollbar_Horizontal( file.scrollbars[ idx ], x, y )
	else
		RepositionScrollbar_Vertical( file.scrollbars[ idx ], x, y )
}

void function RepositionScrollbar_Horizontal( ScrollbarExt scrollbar, int x, int y )
{
	x = x * -1
	y = y * -1

	int minXPos = scrollbar.originalX
	int maxXPos = scrollbar.originalX + scrollbar.originalWidth - Hud_GetWidth( scrollbar.button )

	int pos = expect int( Hud_GetPos( scrollbar.button )[0] )
	int newPos = pos - x

	if ( newPos > maxXPos ) newPos = maxXPos
	if ( newPos < minXPos ) newPos = minXPos

	int yPos = expect int( Hud_GetPos( scrollbar.button )[1] )

	Hud_SetPos( scrollbar.cover , newPos, yPos )
	Hud_SetPos( scrollbar.movementCapture , newPos, yPos )
	Hud_SetPos( scrollbar.button , newPos, yPos )
	Hud_SetPos( scrollbar.panel , newPos, yPos )
}

void function RepositionScrollbar_Vertical( ScrollbarExt scrollbar, int x, int y )
{
	x = x * -1
	y = y * -1

	int[2] screenSize = GetScreenSize()
	var sliderPanel = scrollbar.panel

	int minYPos = scrollbar.originalY
	int maxYPos = scrollbar.originalY + scrollbar.originalHeight - Hud_GetHeight( scrollbar.button )

	int pos = expect int( Hud_GetPos( scrollbar.button )[1] )
	int newPos = pos - y

	if ( newPos > maxYPos ) newPos = maxYPos
	if ( newPos < minYPos ) newPos = minYPos

	int xPos = expect int( Hud_GetPos( scrollbar.button )[0] )

	Hud_SetPos( scrollbar.cover , xPos, newPos )
	Hud_SetPos( scrollbar.movementCapture , xPos, newPos )
	Hud_SetPos( scrollbar.button , xPos, newPos )
	Hud_SetPos( scrollbar.panel , xPos, newPos )
}

var function GetFocusedScrollbar()
{
	return file.scrollbars[ file.covers.find( file.invisCover ) ].scrollbar
}

int function GetFocusedScrollbarIndex()
{
	return file.covers.find( file.invisCover )
}