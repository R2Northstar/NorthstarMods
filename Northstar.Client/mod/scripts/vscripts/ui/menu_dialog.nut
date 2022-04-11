untyped

global function InitDialogMenu
global function InitConnectingDialog
global function InitDataCenterDialogMenu
global function InitAnnouncementDialog
global function ServerCallback_OpenPilotLoadoutMenu
global function ServerCallback_GenericDialog
global function SCBUI_PlayerConnectedOrDisconnected
global function LeaveMatch
global function CancelPrivateMatchSearch
global function CancelMatchSearch
global function CancelRestartingMatchmaking
global function UpdateAnnouncementVersionSeen
global function UpdateDialogFooterVisibility

global function OpenDialog
global function OpenConnectingDialog
global function OpenDataCenterDialog
global function OpenAnnouncementDialog
global function ShowPrivateMatchConnectDialog
global function ShowMatchConnectDialog
global function LeaveDialog
global function Disconnect

global function AddDialogButton
global function AddDialogFooter
global function AddDialogPCBackButton

void function InitDialogCommon( var menu )
{
	uiGlobal.menuData[ menu ].isDialog = true

	array<var> msgElems = GetElementsByClassname( menu, "DialogMessageClass" )
	foreach ( elem in msgElems )
		Hud_EnableKeyBindingIcons( elem )

	Hud_EnableKeyBindingIcons( Hud_GetChild( menu, "DialogHeader" ) )

	AddEventHandlerToButtonClass( menu, "DialogButtonClass", UIE_GET_FOCUS, OnDialogButton_Focused )
	AddEventHandlerToButtonClass( menu, "DialogButtonClass", UIE_LOSE_FOCUS, OnDialogButton_FocusedLose )
	AddEventHandlerToButtonClass( menu, "DialogButtonClass", UIE_CLICK, OnDialogButton_Activate )

	InitDialogFooterButtons( menu )
}

void function InitDialogMenu()
{
	var menu = GetMenu( "Dialog" )

	InitDialogCommon( menu )
	uiGlobal.menuData[ menu ].isDynamicHeight = true
}

void function InitAnnouncementDialog()
{
	var menu = GetMenu( "AnnouncementDialog" )

	InitDialogCommon( menu )

	AddMenuEventHandler( menu, eUIEvent.MENU_NAVIGATE_BACK, OnAnnouncementDialog_NavigateBack )
}

void function OnAnnouncementDialog_NavigateBack()
{
	UpdateAnnouncementVersionSeen()
	CloseActiveMenu()
}

void function InitDataCenterDialogMenu()
{
	var menu = GetMenu( "DataCenterDialog" )

	InitDialogCommon( menu )
	AddEventHandlerToButton( menu, "ListDataCenters", UIE_CLICK, OnDataCenterButton_Activate )
}

void function InitConnectingDialog()
{
	var menu = GetMenu( "ConnectingDialog" )

	InitDialogCommon( menu )
	uiGlobal.menuData[ menu ].isDynamicHeight = true

	AddMenuEventHandler( menu, eUIEvent.MENU_NAVIGATE_BACK, OnConnectingDialog_NavigateBack )

	uiGlobal.ConfirmMenuMessage = Hud_GetChild( menu, "DialogMessage" )
	uiGlobal.ConfirmMenuErrorCode = Hud_GetChild( menu, "LblErrorCode" )
}

void function OnConnectingDialog_NavigateBack()
{
	CancelConnect()
	CloseActiveMenu()
}

void function InitDialogFooterButtons( var menu )
{
	var panel = Hud_GetChild( menu, "DialogFooterButtons" )
	var PCBackButton = Hud_GetChild( panel, "MouseBackFooterButton" )
	Hud_AddEventHandler( PCBackButton, UIE_CLICK, OnBtnBackPressed )
}

void function OnDialogButton_Focused( var button )
{
	int buttonID = int( Hud_GetScriptID( button ) )

	if ( uiGlobal.dialogButtonData[buttonID].focusMessage != "" )
	{
		var menu = Hud_GetParent( button )
		var messageElem = GetSingleElementByClassname( menu, "DialogMessageClass" )
		Hud_SetText( messageElem, uiGlobal.dialogButtonData[buttonID].focusMessage )
	}
}

void function OnDialogButton_FocusedLose( var button )
{
	//if ( !IsDialog( uiGlobal.activeMenu ) )
	//	return
}

void function OnDialogButton_Activate( var button )
{
	if ( Time() < uiGlobal.dialogInputEnableTime )
		return

	int buttonID = int( Hud_GetScriptID( button ) )

	CloseActiveMenu()

	Assert( uiGlobal.dialogButtonData.len() > 0 )

	if ( uiGlobal.dialogButtonData[buttonID].activateFunc != null )
		uiGlobal.dialogButtonData[buttonID].activateFunc.call( this )
}

void function OnDataCenterButton_Activate( var button )
{
	printt( "Chose a data center" )
	CloseActiveMenu()
}

void function RevertForcedMods() // re-enables/disables mods that have been changed to connect to a server
{
    array < string > changedMods = split( GetConVarString( "enabled_disabled_mods_pre_connect" ), ";" )
    foreach ( int idx, string rawChangedModsType in changedMods )
    {
        array < string > rawModIndexList = split( rawChangedModsType, "," )
        foreach ( string rawModIndex in rawModIndexList )
        {
            NSSetModEnabled( NSGetModNames()[ rawModIndex.tointeger() ], idx == 0 )
        }
    }
    if ( changedMods.len() )
    {
        ReloadMods()
        SetConVarString( "enabled_disabled_mods_pre_connect", "" )
    }
}

void function CancelConnect()
{
	Signal( uiGlobal.signalDummy, "OnCancelConnect" )

	MatchmakingCancel()
	ClientCommand( "party_leave" )

	if( GetLobbyType() == "party" )
		ClientCommand( "CancelPrivateMatchSearch" )
}

void function OpenConnectingDialog()
{
	CloseAllDialogs()

	Hud_Hide( uiGlobal.ConfirmMenuMessage )
	Hud_Hide( uiGlobal.ConfirmMenuErrorCode )

	DialogData dialogData
	dialogData.menu = GetMenu( "ConnectingDialog" )
	dialogData.header = "#MATCHMAKING_TITLE_CONNECTING"
	dialogData.showSpinner = true

#if PC_PROG
	AddDialogButton( dialogData, "#CANCEL", CancelConnect )

	AddDialogFooter( dialogData, "#A_BUTTON_SELECT" )
#endif // PC_PROG
	AddDialogFooter( dialogData, "#B_BUTTON_CANCEL" )

	OpenDialog( dialogData )
}

DialogButtonData function AddDialogButton( DialogData dialogData, string label, void functionref() activateFunc = null, string focusMessage = "", bool startFocused = false )
{
	DialogButtonData newButtonData
	newButtonData.label = label
	newButtonData.activateFunc = activateFunc
	newButtonData.focusMessage = focusMessage
	newButtonData.startFocused = startFocused

	dialogData.buttonData.append( newButtonData )
	return newButtonData
}

void function AddDialogFooter( DialogData dialogData, string label, void functionref() activateFunc = null )
{
	DialogFooterData newFooterData
	newFooterData.label = label
	newFooterData.activateFunc = activateFunc

	dialogData.footerData.append( newFooterData )
}

void function AddDialogPCBackButton( DialogData dialogData )
{
	dialogData.showPCBackButton = true
}

void function OpenDialog( DialogData dialogData )
{
	if ( dialogData.noChoice || dialogData.noChoiceWithNavigateBack )
		dialogData.forceChoice = false

	if ( dialogData.inputDisableTime > 0 )
		uiGlobal.dialogInputEnableTime = Time() + dialogData.inputDisableTime

	var menu = GetMenu( "Dialog" )
	if ( dialogData.menu != null )
		menu = dialogData.menu

	var frameElem = Hud_GetChild( menu, "DialogFrame" )
	RuiSetImage( Hud_GetRui( frameElem ), "basicImage", $"rui/menu/common/dialog_gradient" )
	RuiSetFloat3( Hud_GetRui( frameElem ), "basicImageColor", < 1, 1, 1 > )

	// TODO: Add support for string vars? Was 4 vars before.
	Hud_SetText( Hud_GetChild( menu, "DialogHeader" ), dialogData.header )

	int messageHeight = 0

	var messageElem = GetSingleElementByClassname( menu, "DialogMessageClass" )
	if ( messageElem )
	{
		Hud_SetText( messageElem, dialogData.message )
		messageElem.SetColor( dialogData.messageColor )

		if ( menu == GetMenu( "ConnectingDialog" ) )
			messageHeight = int( ContentScaledY( 28 ) )
		else if ( dialogData.message != "" )
			messageHeight = Hud_GetHeight( messageElem )
	}

	if ( Hud_HasChild( menu, "DarkenBackground" ) )
	{
		if ( dialogData.darkenBackground )
			Hud_Show( Hud_GetChild( menu, "DarkenBackground" ) )
		else
			Hud_Hide( Hud_GetChild( menu, "DarkenBackground" ) )
	}

	var messageRuiElem = GetSingleElementByClassname( menu, "DialogMessageRuiClass" )
	if ( messageRuiElem )
	{
		RuiSetString( Hud_GetRui( messageRuiElem ), "messageText", dialogData.ruiMessage.message )
		RuiSetFloat3( Hud_GetRui( messageRuiElem ), "style1Color", dialogData.ruiMessage.style1Color )
		RuiSetFloat3( Hud_GetRui( messageRuiElem ), "style2Color", dialogData.ruiMessage.style2Color )
		RuiSetFloat3( Hud_GetRui( messageRuiElem ), "style3Color", dialogData.ruiMessage.style3Color )

		RuiSetFloat( Hud_GetRui( messageRuiElem ), "style1FontScale", dialogData.ruiMessage.style1FontScale )
		RuiSetFloat( Hud_GetRui( messageRuiElem ), "style2FontScale", dialogData.ruiMessage.style2FontScale )
		RuiSetFloat( Hud_GetRui( messageRuiElem ), "style3FontScale", dialogData.ruiMessage.style3FontScale )

		var rightImageRuiElem = GetSingleElementByClassname( menu, "DialogRightImageClass" )
		if ( rightImageRuiElem )
		{
			RuiSetImage( Hud_GetRui( rightImageRuiElem ), "basicImage", dialogData.rightImage )
		}

		if ( dialogData.useFullMessageHeight )
			messageHeight = Hud_GetHeight( messageRuiElem )
	}

	var spinnerElem = GetSingleElementByClassname( menu, "DialogSpinnerClass" )
	if ( spinnerElem )
		Hud_SetVisible( spinnerElem, dialogData.showSpinner )

	array<DialogFooterData> footerData

	bool forceNoButtonsOnTheBottom = (dialogData.noChoice || dialogData.noChoiceWithNavigateBack)
	if ( !forceNoButtonsOnTheBottom )
	{
		DialogFooterData defaultFooter1
		defaultFooter1.label = "#A_BUTTON_SELECT"
		footerData.append( defaultFooter1 )

		DialogFooterData defaultFooter2
		defaultFooter2.label = "#B_BUTTON_CANCEL"
		footerData.append( defaultFooter2 )

		if ( dialogData.footerData.len() )
			footerData = dialogData.footerData
	}

	array<DialogButtonData> buttonData = dialogData.buttonData
	array<var> buttons = GetElementsByClassname( menu, "DialogButtonClass" )
	int numChoices = buttonData.len()
	int numButtons = buttons.len()
	Assert( numButtons >= numChoices, "OpenDialog: can't have " + numChoices + " choices for only " + numButtons + " buttons." )

	uiGlobal.dialogButtonData = buttonData

	int defaultButtonHeight = int( ContentScaledY( 40 ) )
	int buttonsHeight = defaultButtonHeight * numChoices

	// Setup each button: hide, or set text and show
	foreach ( index, button in buttons )
	{
		var ruiButton = Hud_GetRui( button )

		if ( index < numChoices )
		{
			RuiSetString( ruiButton, "buttonText", uiGlobal.dialogButtonData[ index ].label )
			if ( index in dialogData.coloredButton )
				RuiSetFloat3( ruiButton, "textColorOverride", <1.0,0.7,0.4> )
			else
				RuiSetFloat3( ruiButton, "textColorOverride", <1,1,1> )

			Hud_SetHeight( button, defaultButtonHeight )
			Hud_Show( button )

			if ( uiGlobal.dialogButtonData[ index ].startFocused )
				thread HACK_DelayedSetFocus_BecauseWhy( button )
		}
		else
		{
			Hud_Hide( button )
			Hud_SetHeight( button, 0 )
		}
	}

	// Get footer elems and fill in with footerData
	array<var> ruiFooterElems = GetElementsByClassname( menu, "RuiFooterButtonClass" )
	foreach ( elem in ruiFooterElems )
	{
		int index = int( Hud_GetScriptID( elem ) )

		if ( index < footerData.len() )
		{
			SetFooterText( menu, index, footerData[ index ].label )
		}
		else
		{
			Hud_Hide( elem )
		}
	}

	// someday this will be an array
	var dialogFooter = Hud_GetChild( menu, "DialogFooterButtons" )
	var PCBackButton = Hud_GetChild( dialogFooter, "MouseBackFooterButton" )
	if ( dialogData.showPCBackButton )
	{
		Hud_SetText( PCBackButton, "#BACK" )
		Hud_Show( PCBackButton )
	}
	else
	{
		Hud_SetText( PCBackButton, "" )
		Hud_Hide( PCBackButton )
	}

	var imageElem = GetSingleElementByClassname( menu, "DialogImageClass" )
	if ( imageElem )
	{
		if ( dialogData.image != $"" )
		{
			RuiSetImage( Hud_GetRui( imageElem ), "basicImage", dialogData.image )
			Hud_SetVisible( imageElem, true )
		}
		else
		{
			Hud_SetVisible( imageElem, false )
		}
	}

	if ( uiGlobal.menuData[ menu ].isDynamicHeight )
	{
		var dialogFrame = Hud_GetChild( menu, "DialogFrame" )
		int baseDialogHeight = int( ContentScaledY( 312 ) )
		int bottomButtonAdjust = forceNoButtonsOnTheBottom ? int( ContentScaledY( -(BOTTOM_BUTTON_AREA_HEIGHT - BOTTOM_BUTTON_AREA_HEIGHT_WHENDISABLED) ) ) : 0
		int adjustedDialogHeight = baseDialogHeight + messageHeight + buttonsHeight + bottomButtonAdjust
		Hud_SetHeight( dialogFrame, adjustedDialogHeight )
	}

	uiGlobal.menuData[ menu ].dialogData = dialogData
	UpdateDialogFooterVisibility( menu, IsControllerModeActive() )

	AdvanceMenu( menu )
}

const int BOTTOM_BUTTON_AREA_HEIGHT = 56
const int BOTTOM_BUTTON_AREA_HEIGHT_WHENDISABLED = 20

void function UpdateDialogFooterVisibility( var menu, bool isControllerModeActive )
{
	if ( ShouldUpdateMenuForDialogFooterVisibility( menu ) )
	{
		int defaultHeight = int( ContentScaledY( BOTTOM_BUTTON_AREA_HEIGHT ) )
		string footerButtonElement = "DialogFooterButtons"
		if ( menu == GetMenu( "EULADialog" ) )
			footerButtonElement = "FooterButtons"

		var dialogFooter = Hud_GetChild( menu, footerButtonElement )
		var PCBackButton = Hud_GetChild( dialogFooter, "MouseBackFooterButton" )
		bool isVisible = isControllerModeActive || Hud_IsVisible( PCBackButton )
		DialogData dialogData = uiGlobal.menuData[ menu ].dialogData
		bool forceNoButtonsOnTheBottom = (dialogData.noChoice || dialogData.noChoiceWithNavigateBack)

		int newHeight = defaultHeight
		if ( !isVisible || forceNoButtonsOnTheBottom )
			newHeight = int( ContentScaledY( BOTTOM_BUTTON_AREA_HEIGHT_WHENDISABLED ) )

		Hud_SetHeight( dialogFooter, newHeight )
	}
}

bool function ShouldUpdateMenuForDialogFooterVisibility( var menu )
{
	if ( menu == GetMenu( "Dialog" ) )
		return true

	if ( menu == GetMenu( "AnnouncementDialog" ) )
		return true

	if ( menu == GetMenu( "ConnectingDialog" ) )
		return true

	return false
}

function ServerCallback_OpenPilotLoadoutMenu()
{
	if ( uiGlobal.activeMenu == null)
	{
		AdvanceMenu( GetMenu( "PilotLoadoutsMenu" ) )
	}
}

function ServerCallback_GenericDialog( int headerId, int messageId, bool isError )
{
	var header = GetCurrentPlaylistVar( "generic_dialog_header_" + headerId )
	if ( type( header ) != "string" )
		return

	var message = GetCurrentPlaylistVar( "generic_dialog_message_" + messageId )
	if ( type( message ) != "string" )
		return

	DialogData dialogData
	dialogData.header = string( header )
	dialogData.message = string( message )
	if ( isError )
		dialogData.image = $"ui/menu/common/dialog_error"

	#if PC_PROG
		AddDialogButton( dialogData, "#DISMISS" )
	#endif // PC_PROG

	AddDialogFooter( dialogData, "#A_BUTTON_SELECT" )
	AddDialogFooter( dialogData, "#B_BUTTON_DISMISS_RUI" )

	OpenDialog( dialogData )
}

function SCBUI_PlayerConnectedOrDisconnected( joinSound )
{
	if ( joinSound )
	{
		EmitUISound( "PlayerJoinedLobby" )
	}

	local menu = uiGlobal.activeMenu
	if ( menu == null )
		return

	local menuName = menu.GetHudName()
	switch ( menuName )
	{
		default:
			break
	}
}

void function LeaveDialog()
{
	if ( !IsFullyConnected() )
		return

	bool isMP = IsLevelMultiplayer( GetActiveLevel() )

	DialogData dialogData
	dialogData.header = "#ARE_YOU_SURE_YOU_WANT_TO_LEAVE"
	dialogData.noChoiceWithNavigateBack = true
	dialogData.image = $"ui/menu/common/dialog_error"

	if ( isMP )
	{
		int lobbyType = GetLobbyTypeScript()
		if ( IsLobby() ) // && (lobbyType != eLobbyType.MATCH) ) // SOLO, PARTY_LEADER, PARTY_MEMBER, PRIVATE_MATCH
		{
			AddDialogButton( dialogData, "#CANCEL_NO" )

			if ( InPendingOpenInvite() )
			{
				AddDialogButton( dialogData, "#YES_LEAVE_OPEN_INVITE", LeaveOpenInvite )
			}

			if ( !PartyHasMembers() || AmIPartyLeader() )
			{
				if ( GetTimeToRestartMatchMaking() )
				{
					dialogData.header = "#STOP_MATCHMAKING"
					AddDialogButton( dialogData, "#YES_STOP_MATCHMAKING", CancelRestartingMatchmaking )
				}
				else if ( AreWeMatchmaking() )
				{
					dialogData.header = "#STOP_MATCHMAKING"
					AddDialogButton( dialogData, "#YES_STOP_MATCHMAKING", CancelSearch )
				}
				else if ( IsPrivateMatch() )
				{
					AddDialogButton( dialogData, "#YES_LEAVE_PRIVATE_LOBBY", LeaveMatch )
				}
				else if ( AmIPartyLeader() && PartyHasMembers() )
				{
					AddDialogButton( dialogData, "#YES_LEAVE_PARTY", LeaveParty )
				}
				else
				{
					// string swichString = Lobby_IsFDMode() ? "#DIALOG_SWITCH_TO_MP" : "#DIALOG_SWITCH_TO_FD"
					// AddDialogButton( dialogData, swichString, Lobby_ToggleFDMode )

					AddDialogButton( dialogData, "#YES_RETURN_TO_TITLE_MENU", Disconnect )
				}
			}
			else
			{
				Assert( PartyHasMembers() )
				Assert( !AmIPartyLeader() )
				if ( lobbyType == eLobbyType.PRIVATE_MATCH  )
					AddDialogButton( dialogData, "#YES_LEAVE_MATCH_AND_PARTY", LeaveMatchAndParty )
				else
					AddDialogButton( dialogData, "#YES_LEAVE_PARTY", LeaveParty )
			}
		}
		else
		{
			Assert( !InPendingOpenInvite() )

			AddDialogButton( dialogData, "#CANCEL_NO" )

			if ( IsPrivateMatch() && AmIPartyLeader() )
			{
				dialogData.header = "#END_MATCH"
				AddDialogButton( dialogData, "#END_MATCH_YES", ConfirmEndMatch )
			}
			else
			{
				string confirmSoloText = "#YES_LEAVE_MATCH"
				string confirmPartyText = "#YES_LEAVE_MATCH_AND_PARTY"
				if ( level.ui.penalizeDisconnect && !IsPrivateMatch() )
				{
					dialogData.message = "#LEAVING_MATCH_LOSS_WARNING"
					dialogData.messageColor = [ENEMY_R, ENEMY_G * 0.7, ENEMY_B * 0.7, 255]
					confirmSoloText = "#YES_LEAVE_MATCH_WITH_LOSS"
					confirmPartyText = "#YES_LEAVE_MATCH_AND_PARTY_WITH_LOSS"
				}

				if ( PartyHasMembers() )
					AddDialogButton( dialogData, confirmPartyText, LeaveMatchAndParty )
				else
					AddDialogButton( dialogData, confirmSoloText, LeaveMatch )
			}
		}
	}
	else  // SP
	{
		dialogData.header = "#ARE_YOU_SURE_YOU_WANT_TO_QUIT_SP"
		dialogData.message = "#QUIT_CONFIRM_MESSAGE_SP"

		AddDialogButton( dialogData, "#CANCEL" )
		AddDialogButton( dialogData, "#YES_RETURN_TO_TITLE_MENU", Disconnect )
	}

	OpenDialog( dialogData )
}

void function CancelRestartingMatchmaking()
{
	Signal( uiGlobal.signalDummy, "CancelRestartingMatchmaking" )
}

void function CancelSearch()
{
	CloseActiveMenu() // "SearchMenu"
	CancelMatchmaking()
}

void function LeaveMatch()
{
	// IMPORTANT: It's very important to always leave the party view if you back out
	// otherwise you risk trashing the party view for remaining players and pointing
	// it back to your private lobby.
	#if DURANGO_PROG
		Durango_LeaveParty()
	#endif // #if DURANGO_PROG

	CancelMatchmaking()
	ClientCommand( "LeaveMatch" )
	ShowLeavingDialog()
    RevertForcedMods() // A callback for "disconnect" or "LeaveMatch" would maybe be a better idea
}

void function ConfirmEndMatch()
{
	CloseAllDialogs()
	CloseActiveMenu()
	ClientCommand( "PrivateMatchEndMatch" )
}

void function ShowLeavingDialog()
{
	DialogData dialogData
	dialogData.header = "#FINDING_PARTY_SERVER"
	dialogData.showSpinner = true
	dialogData.forceChoice = true

	AddDialogButton( dialogData, "#CANCEL_AND_QUIT_TO_MAIN_MENU", Disconnect )

	AddDialogFooter( dialogData, "#A_BUTTON_SELECT" )

	OpenDialog( dialogData )
}

void function ShowPrivateMatchConnectDialog()
{
	DialogData dialogData
	dialogData.header = "#CONNECTING_PRIVATEMATCH"
	dialogData.showSpinner = true
	dialogData.forceChoice = true

	AddDialogButton( dialogData, "#CANCEL", CancelPrivateMatchSearch )

	AddDialogFooter( dialogData, "#A_BUTTON_SELECT" )

	OpenDialog( dialogData )
}

void function CancelPrivateMatchSearch()
{
	ClientCommand( "CancelPrivateMatchSearch" )
	CloseActiveMenu()
}

void function ShowMatchConnectDialog()
{
	DialogData dialogData
	dialogData.header = "#CONNECTING_SEARCHING"
	dialogData.showSpinner = true
	dialogData.forceChoice = true

	AddDialogButton( dialogData, "#CANCEL", CancelMatchSearch )

	AddDialogFooter( dialogData, "#A_BUTTON_SELECT" )

	OpenDialog( dialogData )
}

void function CancelMatchSearch()
{
	CancelMatchmaking()
	ClientCommand( "CancelMatchSearch" )
	CloseActiveMenu()
}

void function Disconnect()
{
	StopMatchmaking()
	ClientCommand( "disconnect" )
	ClientCommand( "party_leave" )
}

void function OpenDataCenterDialog( var button )
{
	DialogData dialogData
	dialogData.menu = GetMenu( "DataCenterDialog" )
	dialogData.header = "#DATA_CENTERS"

#if PC_PROG
	AddDialogButton( dialogData, "#DISMISS" )
#endif // PC_PROG

	AddDialogFooter( dialogData, "#A_BUTTON_SELECT" )
	AddDialogFooter( dialogData, "#B_BUTTON_DISMISS_RUI" )

	OpenDialog( dialogData )
}

void function OpenAnnouncementDialog()
{
	DialogData dialogData
	dialogData.menu = GetMenu( "AnnouncementDialog" )
	dialogData.header = "#ANNOUNCEMENT"
	dialogData.message = GetConVarString( "announcement" )
	dialogData.image = $"ui/menu/common/dialog_announcement_1"
//#if !DEV
//	dialogData.inputDisableTime = 2.0
//#endif // #if !DEV

#if PC_PROG
	AddDialogButton( dialogData, "#DISMISS", UpdateAnnouncementVersionSeen )

	AddDialogFooter( dialogData, "#A_BUTTON_SELECT" )
#endif // PC_PROG
	AddDialogFooter( dialogData, "#B_BUTTON_DISMISS_RUI" )

	OpenDialog( dialogData )
}

void function UpdateAnnouncementVersionSeen()
{
	if ( !IsFullyConnected() )
		return

	int announcementVersion = GetConVarInt( "announcementVersion" )
	uiGlobal.announcementVersionSeen = announcementVersion

	ClientCommand( "SetAnnouncementVersionSeen " + string( announcementVersion ) )
}


void function OnBtnBackPressed( var button )
{
	CloseActiveMenu()
}
