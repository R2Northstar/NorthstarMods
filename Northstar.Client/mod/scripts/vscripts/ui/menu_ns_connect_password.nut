global function AddNorthstarConnectWithPasswordMenu

void function AddNorthstarConnectWithPasswordMenu()
{
	AddMenu( "ConnectWithPasswordMenu", $"resource/ui/menus/connect_password.menu", InitConnectWithPasswordMenu, "#MENU_CONNECT" )
}

void function InitConnectWithPasswordMenu()
{
	var menu = GetMenu( "ConnectWithPasswordMenu" )
	AddMenuEventHandler( menu , eUIEvent.MENU_OPEN, OnConnectWithPasswordMenuOpened )
	AddMenuFooterOption( menu , BUTTON_B, "#B_BUTTON_BACK", "#BACK" )

	AddButtonEventHandler( Hud_GetChild( menu , "ConnectButton" ), UIE_CLICK, ConnectWithPassword )

	// Add focus lost (enter) handler
	Hud_AddEventHandler( Hud_GetChild( menu , "EnterPasswordBox" ), UIE_LOSE_FOCUS, ConnectWithPassword )
}

void function OnConnectWithPasswordMenuOpened()
{
	UI_SetPresentationType( ePresentationType.KNOWLEDGEBASE_SUB )

	var menu = GetMenu( "ConnectWithPasswordMenu" )

	// set texts
	Hud_SetText( Hud_GetChild( menu, "Title" ), "#MENU_TITLE_CONNECT_PASSWORD" )
	Hud_SetText( Hud_GetChild( menu, "ConnectButton" ), "#MENU_CONNECT_MENU_CONNECT" )
	Hud_SetText( Hud_GetChild( menu, "EnterPasswordBox" ), "" )

	// Request focus on password menu
	Hud_SetFocused( Hud_GetChild( menu , "EnterPasswordBox" ) )
}

void function ConnectWithPassword( var button )
{
	if ( GetTopNonDialogMenu() == GetMenu( "ConnectWithPasswordMenu" ) )
		thread ThreadedAuthAndConnectToServer( Hud_GetUTF8Text( Hud_GetChild( GetMenu( "ConnectWithPasswordMenu" ), "EnterPasswordBox" ) ) )
}