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

	AddMenuFooterOption( file.menu, BUTTON_X, "%[X_BUTTON|]%" + Localize( "#RELOAD_MODS" ), "#RELOAD_MODS", void function( var button ) { thread void function() { ClientCommand( "disconnect" ); WaitFrame(); AdvanceMenu( GetMenu( "ModListMenu" ) ) }() } )
	AddMenuFooterOption( file.menu, BUTTON_SHOULDER_LEFT, "#PRIVATE_MATCH_PAGE_PREV", "#PRIVATE_MATCH_PAGE_PREV", CycleModsBack )
	AddMenuFooterOption( file.menu, BUTTON_SHOULDER_RIGHT, "#PRIVATE_MATCH_PAGE_NEXT", "#PRIVATE_MATCH_PAGE_NEXT", CycleModsForward )
}

void function OnOpenModListMenu()
{
	// Get every mod that is required on the server and not installed on client
	file.missingMods = []
	for ( int i; i < NSGetServerRequiredModsCount( lastSelectedServer ); i++ )
	{
		if ( !NSGetModNames().contains( NSGetServerRequiredModName( lastSelectedServer, i ) ) )
		{
			modInfo m;
			m.name = NSGetServerRequiredModName( lastSelectedServer, i )
			m.version = NSGetServerRequiredModVersion( lastSelectedServer, i )
			string link = NSGetServerRequiredModDownloadLink(lastSelectedServer,i)
			if ( link.len() > 0 /* If no link is provided, don't add a protocol so the link stays empty */
				&& link.find( "http://" ) != 0 && link.find( "https://" ) != 0 )
				// for some reason links that don't have the http or https protocol launch in the origin browser
				// defaulting to http in case someone hosts their mod on a http server. Most servers redirect to https anyways so it doesn't really matter this way.
				link = "http://" + link
			m.downloadLink = link
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
		// Used buttons will be enabled later
		Hud_SetEnabled( button, false )
		Hud_SetVisible( button, false )
	}

	for ( int i; i < MODS_PER_PAGE; i++ )
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

	if ( !modInfo.downloadLink.len() )
	{
		// This is to restore the default after a mod with a link has been deselected
		Hud_SetVisible( Hud_GetChild( file.menu, "FocusModHint" ), false )
		Hud_SetColor( focusModDownloadLink, 251, 120, 5, 255 )
		Hud_SetText( focusModDownloadLink, "The mod author has not specified where the mod is available for download. Ask the server administrator for more information" )

	}
	else
	{
		Hud_SetVisible( Hud_GetChild( file.menu, "FocusModHint" ), true )
		Hud_SetColor( focusModDownloadLink, 141, 197, 84, 255 )
		Hud_SetText( focusModDownloadLink, modInfo.downloadLink )
	}
}

void function ModButton_Click( var button )
{
	string link = file.missingMods[ int( Hud_GetScriptID( button ) ) + ( file.currentModPage * MODS_PER_PAGE ) ].downloadLink
	if ( link.len() ) // Make sure a link has been provided
		LaunchExternalWebBrowser( link, WEBBROWSER_FLAG_FORCEEXTERNAL )
}

void function CycleModsBack( var button )
{
	if ( file.currentModPage == 0 )
		return

	file.currentModPage--
	UpdateVisibleMods()
}

void function CycleModsForward( var button )
{
	if ( ( file.currentModPage + 1 ) * MODS_PER_PAGE >= file.missingMods.len() )
		return

	file.currentModPage++
	UpdateVisibleMods()
}