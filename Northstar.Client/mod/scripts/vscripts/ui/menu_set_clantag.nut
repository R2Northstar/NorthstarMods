global function InitSetClanTagMenu
global function OnSetClantagButton_Activate

struct
{
	var menu
	var EditBox
	var CheckButton
	var Blackground
	var TitleLabel
	var ActivateButton
	bool LostFocus = false
} file

void function InitSetClanTagMenu()
{
	file.menu = GetMenu( "LobbyMenu" )
	file.EditBox = Hud_GetChild( file.menu, "CustomClantagBox" )
	file.CheckButton = Hud_GetChild( file.menu, "CheckButton" )
	file.Blackground = Hud_GetChild( file.menu, "BlackBackground" )
	file.TitleLabel = Hud_GetChild( file.menu, "SettingLabel" )

	AddButtonEventHandler( file.CheckButton, UIE_CLICK, SetClantag )
}

void function OnSetClantagButton_Activate( var button )
{
	file.ActivateButton = button
	file.LostFocus = false

	RegisterButtonPressedCallback( KEY_ENTER, SetClantag )

	Hud_Show( file.TitleLabel )
	Hud_Show( file.Blackground )
	Hud_SetEnabled( file.EditBox, true )
	Hud_SetVisible( file.EditBox, true )
	Hud_SetEnabled( file.CheckButton, true )
	Hud_SetVisible( file.CheckButton, true )

	Hud_SetText( file.TitleLabel, "#COMMUNITY_CLANTAG_LABEL" )
	Hud_SetText( file.CheckButton, "#CHALLENGE_BUTTON_COMPLETE" )
	Hud_SetText( file.EditBox, "" )
	Hud_SetFocused( file.EditBox )

	Hud_SetEnabled( file.ActivateButton, false )
	
	thread OnTestLobbyMenu_Close()
}

void function SetClantag( var button )
{
	bool success = NSSetLocalPlayerClanTag( Hud_GetUTF8Text( Hud_GetChild( file.menu, "CustomClantagBox" ) ).toupper() )
	string message
	asset image
	string header = Localize( "#GAME" ) + Localize( "#GAUNTLET_TIP_TITLE" )

	if( success )
		message="#SKYWAY_HUD_MESSAGE_14"
	else
		message = Localize( "#OPERATOR_BUILD_LIMIT" ) + " 或 " + Localize( "#MATCHMAKING_SERVERERROR" )

	if( success )
	{
		image = $"ui/menu/common/dialog_announcement_1"
	}
	else
	{
		image =$"ui/menu/common/dialog_error"
	}

	DialogData dialogData
	
	dialogData.header = header
	dialogData.message= message
	dialogData.image = image

	if( success )
	{
		AddDialogButton( dialogData, "#MENU_BT_LOADOUT_TUTORIAL_EXIT_PROMPT_PC" )
	}
	else
	{
		AddDialogButton( dialogData, "#COOP_WAVE_TRY_AGAIN", Retry )
		AddDialogButton( dialogData, "#PATCH_8BALL" )
	}

	dialogData.noChoiceWithNavigateBack = true
	OpenDialog( dialogData )

	file.LostFocus = true
}

void function Retry()
{
	OnSetClantagButton_Activate( file.ActivateButton )
}

void function OnTestLobbyMenu_Close()
{
	while( true )
	{
		if( Hud_GetHudName( uiGlobal.activeMenu ) != "menu_LobbyMenu" || file.LostFocus )
		{
			Hud_Hide( file.TitleLabel )
			Hud_Hide( file.Blackground )
			Hud_SetEnabled( file.EditBox, false )
			Hud_SetVisible( file.EditBox, false )
			Hud_SetEnabled( file.CheckButton, false )
			Hud_SetVisible( file.CheckButton, false )
			Hud_SetEnabled( file.ActivateButton, true )
			DeregisterButtonPressedCallback( KEY_ENTER, SetClantag )
			break
		}
		WaitFrame()
	}
}
