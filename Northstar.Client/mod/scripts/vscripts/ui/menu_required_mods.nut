global function AddServerRequiredModLinkMenu

struct modInfo {
	string name
	string version
	string downloadLink
}

struct {
	int currentModPage
	var menu
	array<modInfo> missingMods
} file

const int MODS_PER_PAGE = 15

void function AddServerRequiredModLinkMenu()
{
	// This is just the menu_mode_select.nut with a few changes
	AddMenu( "ServerRequiredModsMenu", $"resource/ui/menus/required_mods.menu", InitServerRequiredModsMenu )
}

void function InitServerRequiredModsMenu()
{
	file.menu = GetMenu( "ServerRequiredModsMenu" )

	AddMenuEventHandler( file.menu, eUIEvent.MENU_OPEN, OnOpenModListMenu )

	AddEventHandlerToButtonClass( file.menu, "ModButton", UIE_GET_FOCUS, ModButton_GetFocus )
	AddEventHandlerToButtonClass( file.menu, "ModButton", UIE_CLICK, ModButton_Click )

	AddMenuFooterOption( file.menu, BUTTON_A, "#A_BUTTON_SELECT" )
	AddMenuFooterOption( file.menu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )

	AddMenuFooterOption( file.menu, BUTTON_SHOULDER_LEFT, "#PRIVATE_MATCH_PAGE_PREV", "#PRIVATE_MATCH_PAGE_PREV", CycleModesBack, IsNorthstarServer )
	AddMenuFooterOption( file.menu, BUTTON_SHOULDER_RIGHT, "#PRIVATE_MATCH_PAGE_NEXT", "#PRIVATE_MATCH_PAGE_NEXT", CycleModesForward, IsNorthstarServer )
}

void function OnOpenModListMenu()
{
	file.missingMods = []
	for ( int i = 0; i < NSGetServerRequiredModsCount( lastSelectedServer ); i++ )
	{
		if ( !NSGetModNames().contains( NSGetServerRequiredModName( lastSelectedServer, i ) ) )
		{
			modInfo m;
			m.name = NSGetServerRequiredModName( lastSelectedServer, i )
			m.version = NSGetServerRequiredModVersion( lastSelectedServer, i )
			m.downloadLink = NSGetServerRequiredModDownloadLink(lastSelectedServer,i)
			file.missingMods.append(m)
		}
	}
	UpdateVisibleMods()
	Hud_SetFocused( GetElementsByClassname( file.menu, "ModButton" )[ 0 ] )
}

void function UpdateVisibleMods()
{
	array<var> buttons = GetElementsByClassname( file.menu, "ModButton" )
	foreach ( var button in buttons )
	{
		Hud_SetEnabled( button, false )
		Hud_SetVisible( button, false )
	}

	for ( int i = 0; i < MODS_PER_PAGE; i++ )
	{
		if ( i + ( file.currentModPage * MODS_PER_PAGE ) >= file.missingMods.len() )
			break

		int modIndex = i + ( file.currentModPage * MODS_PER_PAGE )
		SetButtonRuiText( buttons[ i ], file.missingMods[ modIndex ].name )

		Hud_SetEnabled( buttons[ i ], true )
		Hud_SetVisible( buttons[ i ], true )
	}
}

void function ModButton_GetFocus( var button )
{
	var focusModName = Hud_GetChild( file.menu, "FocusModName" )
	var focusModVersion = Hud_GetChild( file.menu, "FocusModVersion" )
	var focusModDownloadLink = Hud_GetChild( file.menu, "FocusModDownloadLink" )

	modInfo modInfo = file.missingMods[ int( Hud_GetScriptID( button ) ) + ( file.currentModPage * MODS_PER_PAGE ) ]

	Hud_SetText( focusModName, modInfo.name )
	Hud_SetText( focusModVersion, modInfo.version )
	Hud_SetText( focusModDownloadLink, modInfo.downloadLink )
	Hud_SetColor( focusModDownloadLink, 141, 197, 84, 255 )

	if ( !modInfo.downloadLink.len() )
		Hud_SetVisible( Hud_GetChild( file.menu, "FocusModHint" ), false )
}

void function ModButton_Click( var button )
{
	string link = NSGetServerRequiredModDownloadLink( lastSelectedServer, int( Hud_GetScriptID( button ) ) + ( file.currentModPage * MODS_PER_PAGE ) )
	if ( link.len() )
		LaunchExternalWebBrowser( link, WEBBROWSER_FLAG_FORCEEXTERNAL )
}

void function CycleModesBack( var button )
{
	if ( file.currentModPage == 0 )
		return

	file.currentModPage--
	UpdateVisibleMods()
}

void function CycleModesForward( var button )
{
	if ( ( file.currentModPage + 1 ) * MODS_PER_PAGE >= file.missingMods.len() )
		return

	file.currentModPage++
	UpdateVisibleMods()
}