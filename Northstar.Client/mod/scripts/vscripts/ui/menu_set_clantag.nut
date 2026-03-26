global function InitSetClanTagMenu
global function OnSetClantagButton_Activate

struct
{
	var menu
	var editBox
	var confirmButton
	var blackground
	var titleLabel
	var activateButton
	bool lostFocus = false
} file

void function InitSetClanTagMenu()
{
	file.menu = GetMenu( "LobbyMenu" )
	file.editBox = Hud_GetChild( file.menu, "ClanTagEditBox" )
	file.confirmButton = Hud_GetChild( file.menu, "ConfirmButton" )
	file.blackground = Hud_GetChild( file.menu, "DialogBackground" )
	file.titleLabel = Hud_GetChild( file.menu, "TitleLabel" )

	AddButtonEventHandler( file.confirmButton, UIE_CLICK, OnConfirmClanTag )
}

void function OnSetClantagButton_Activate( var button )
{
	file.activateButton = button
	file.lostFocus = false

	RegisterButtonPressedCallback( KEY_ENTER, OnConfirmClanTag )

	Hud_Show( file.titleLabel )
	Hud_Show( file.blackground )
	Hud_SetEnabled( file.editBox, true )
	Hud_SetVisible( file.editBox, true )
	Hud_SetEnabled( file.confirmButton, true )
	Hud_SetVisible( file.confirmButton, true )

	Hud_SetText( file.titleLabel, "#COMMUNITY_CLANTAG_LABEL" )
	Hud_SetText( file.confirmButton, "#CHALLENGE_BUTTON_COMPLETE" )
	Hud_SetText( file.editBox, "" )
	Hud_SetFocused( file.editBox )

	Hud_SetEnabled( file.activateButton, false )
	
	thread WaitForClanTagMenuClose()
}

void function OnConfirmClanTag( var button )
{
	bool success = NSSetLocalPlayerClanTag( Hud_GetUTF8Text( file.editBox ) )
	string message = success ? "#SKYWAY_HUD_MESSAGE_14" : Localize( "#DURANGO_UNEXPECTED_ERROR" )
	asset image = success ? $"ui/menu/common/dialog_announcement_1" : $"ui/menu/common/dialog_error"
	string header = Localize( "#GAUNTLET_TIP_TITLE" )

	DialogData dialogData
	
	dialogData.header = header
	dialogData.message = message
	dialogData.image = image

	AddDialogButton( dialogData, "#DISMISS" )

	dialogData.noChoiceWithNavigateBack = true
	OpenDialog( dialogData )

	file.lostFocus = true
}

void function WaitForClanTagMenuClose()
{
	while ( true )
	{
		if ( Hud_GetHudName( uiGlobal.activeMenu ) != "menu_LobbyMenu" || file.lostFocus )
		{
			Hud_Hide( file.titleLabel )
			Hud_Hide( file.blackground )
			Hud_SetEnabled( file.editBox, false )
			Hud_SetVisible( file.editBox, false )
			Hud_SetEnabled( file.confirmButton, false )
			Hud_SetVisible( file.confirmButton, false )
			Hud_SetEnabled( file.activateButton, true )
			DeregisterButtonPressedCallback( KEY_ENTER, OnConfirmClanTag )
			break
		}
		WaitFrame()
	}
}
