
global function InitInboxFrontMenu
global function InitInboxMenu

global function TryToShowAnInboxMessage
global function UICodeCallback_InboxUpdated
global function OnInboxButton_Activate

const int NUM_DISPLAY_RECENT_UNLOCKS = 5

struct
{
	var menu

	var messagesButton
	var lootButton

	var messagesCountLabel
	var lootCountLabel

	var lootDisplay
	array<var> recentLootUnlocks
	array<int> reportedMessageIds

	var inboxMenu
	var inboxPanel
	var inboxCommunityName
	var inboxSenderName
	var inboxDate
	var inboxMessageText
	int inboxCurrentMessageId
	int inboxPrevMessageId
	int inboxNextMessageId
	int reportAbuseCommunityId
	int reportAbuseSeverity
	var inboxPrevMsgButton
	var inboxNextMsgButton
	var inboxDeleteButton
	var inboxAcceptButton
	var inboxReportAbuseButton
	var inboxCanDeleteMsg
	var inboxCanAcceptMsg
	var inboxCanReportAbuse
	bool inboxThreadRunning

	string oldMessageText
} file

void function InitInboxFrontMenu()
{
	var menu = GetMenu( "InboxFrontMenu" )
	file.menu = menu

	AddMenuEventHandler( menu, eUIEvent.MENU_OPEN, OnOpenInboxFrontMenu )
	AddMenuEventHandler( menu, eUIEvent.MENU_CLOSE, OnCloseInboxFrontMenu )

	file.messagesButton = Hud_GetChild( menu, "MessagesButton" )
	Hud_AddEventHandler( file.messagesButton, UIE_CLICK, OnMessagesButton_Activate )

	file.lootButton = Hud_GetChild( menu, "LootButton" )
	Hud_AddEventHandler( file.lootButton, UIE_CLICK, OnLootButton_Activate )

	file.messagesCountLabel = Hud_GetChild( menu, "MessagesCountLabel" )
	file.lootCountLabel = Hud_GetChild( menu, "LootCountLabel" )

	file.lootDisplay = Hud_GetChild( menu, "LootDisplay" )

	for ( int index = 0; index < NUM_DISPLAY_RECENT_UNLOCKS; index++ )
	{
		file.recentLootUnlocks.append( Hud_GetChild( menu, "RecentUnlock" + index ) )
	}

	AddMenuFooterOption( menu, BUTTON_A, "#A_BUTTON_SELECT", "", null, DoesFocusHaveItems )
	AddMenuFooterOption( menu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )
}


void function OnOpenInboxFrontMenu()
{
	UpdateInboxFrontButtons()
	thread UpdateInboxFrontThread()
	UI_SetPresentationType( ePresentationType.NO_MODELS )
}

void function OnCloseInboxFrontMenu()
{
	Signal( uiGlobal.signalDummy, "StopInboxThread" )
}


void function UpdateInboxFrontThread()
{
	EndSignal( uiGlobal.signalDummy, "CleanupInGameMenus" )

	while ( GetTopNonDialogMenu() == GetMenu( "InboxFrontMenu" ) )
	{
		UpdateInboxFrontButtons()

		wait 0.1
	}
}

bool function DoesFocusHaveItems()
{
	entity player = GetUIPlayer()

	if ( !player )
		return false

	var button = GetFocus()
	if ( button == file.messagesButton )
		return Inbox_GetTotalMessageCount() > 0
	else if ( button == file.lootButton )
		return PlayerRandomUnlock_GetTotal( player ) > 0

	return true
}

void function UpdateInboxFrontButtons()
{
	entity player = GetUIPlayer()

	if ( !player )
		return

	int totalMessages = Inbox_GetTotalMessageCount()
	array<int> messageIds
	array<int> lootIds

	for ( int messageIndex = 0; messageIndex < totalMessages; messageIndex++ )
	{
		int messageId = Inbox_GetMessageIdByIndex( messageIndex )
		InboxMessage inboxMessage = Inbox_GetMessage( messageId )
		messageIds.append( inboxMessage.messageId )
	}

	if ( messageIds.len() )
	{
		string countString
		if ( messageIds.len() >= MAX_MAIL_COUNT )
			countString = MAX_MAIL_COUNT + "+"
		else
			countString = string( messageIds.len() )


		SetButtonRuiText( file.messagesButton, "#COMMUNITY_INBOX_READ_MESSAGE" )
		if ( messageIds.len() == 1 )
			SetLabelRuiText( file.messagesCountLabel, Localize( "#COMMUNITY_INBOX_MESSAGE_COUNT_1" ) )
		else
			SetLabelRuiText( file.messagesCountLabel, Localize( "#COMMUNITY_INBOX_MESSAGE_COUNT_N", countString ) )
	}
	else
	{
		SetButtonRuiText( file.messagesButton, "#COMMUNITY_INBOX_NO_MESSAGES" )
		SetLabelRuiText( file.messagesCountLabel, Localize( "#COMMUNITY_INBOX_MESSAGE_COUNT_0" ) )
		//SetLabelRuiText( file.messagesCountLabel, "" )
	}
	Hud_SetLocked( file.messagesButton, messageIds.len() == 0 )

	int totalRandomUnlocks = PlayerRandomUnlock_GetTotal( player )

	if ( totalRandomUnlocks )
	{
		SetButtonRuiText( file.lootButton, "#COMMUNITY_INBOX_OPEN_LOOT" )
		if ( totalRandomUnlocks == 1 )
			SetLabelRuiText( file.lootCountLabel, Localize( "#COMMUNITY_INBOX_LOOT_COUNT_1" ) )
		else
			SetLabelRuiText( file.lootCountLabel, Localize( "#COMMUNITY_INBOX_LOOT_COUNT_N", totalRandomUnlocks ) )
	}
	else
	{
		SetButtonRuiText( file.lootButton, "#COMMUNITY_INBOX_NO_LOOT" )
		SetLabelRuiText( file.lootCountLabel, Localize( "#COMMUNITY_INBOX_LOOT_COUNT_0" ) )
		//SetLabelRuiText( file.lootCountLabel, "" )
	}
	Hud_SetLocked( file.lootButton, totalRandomUnlocks == 0 )

	var lootDisplayRui = Hud_GetRui( file.lootDisplay )
	RuiSetInt( lootDisplayRui, "coliseumTicketCount", Player_GetColiseumTicketCount( player ) )
	RuiSetInt( lootDisplayRui, "doubleXPCount", Player_GetDoubleXPCount( player ) )

	for ( int index = 0; index < NUM_DISPLAY_RECENT_UNLOCKS; index++ )
	{
		ItemDisplayData ornull displayData = Player_GetRecentUnlock( player, index )
		var recentLootRui = Hud_GetRui( file.recentLootUnlocks[index] )

		if ( displayData != null )
		{
			expect ItemDisplayData( displayData )
			int count = Player_GetRecentUnlockCount( player, index )

			string title
			string category
			string parentTitle
			if ( displayData.parentRef != "" )
			{
				parentTitle = Localize( GetItemName( displayData.parentRef ) )
				string categoryName = GetItemRefTypeName( displayData.ref, displayData.parentRef )
				category = Localize( categoryName, Localize( parentTitle ) )
				//category = Localize( categoryName )
				title = Localize( displayData.name )
			}
			else
			{
				string categoryName = GetItemRefTypeName( displayData.ref )
				category = Localize( categoryName )
				title = Localize( displayData.name )
				parentTitle = ""
			}

			if ( count > 1 )
				title = Localize( "#COMMUNITY_INBOX_ITEM_XN", title, count )

			RuiSetImage( recentLootRui, "unlockImage", displayData.image )
			RuiSetString( recentLootRui, "unlockTitle", title )
			RuiSetString( recentLootRui, "unlockCategory", category )
			RuiSetString( recentLootRui, "unlockParentTitle", parentTitle )
			RuiSetInt( recentLootRui, "unlockImageAtlas", displayData.imageAtlas )
			RuiSetFloat2( recentLootRui, "unlockImageRatio", GetItemImageAspect( displayData.ref ) )
			RuiSetFloat( recentLootRui, "unlockAlpha", 1.0 - index / NUM_DISPLAY_RECENT_UNLOCKS )
		}
		else
		{
			RuiSetImage( recentLootRui, "unlockImage", $"" )
			RuiSetString( recentLootRui, "unlockTitle", "" )
			RuiSetInt( recentLootRui, "unlockImageAtlas", -1 )
			RuiSetFloat( recentLootRui, "unlockAlpha", 0.0 )
		}
	}
	//Inbox_HasNewMessages
	//Inbox_HasUnreadMessages
	//Inbox_MarkMessageRead
	//Inbox_GetPrevMessageId
	//Inbox_GetNextMessageId
	//Inbox_GetMessage
}

void function OnMessagesButton_Activate( var button )
{
	if ( Hud_IsLocked( button ) )
		return

	AdvanceMenu( GetMenu( "Inbox" ) )
	Hud_SetFocused( file.inboxMessageText )
}



void function OnLootButton_Activate( var button )
{
	if ( Hud_IsLocked( button ) )
		return

	ClientCommand( "UnlockRandomLoot" )
	EmitUISound( "Menu_AdvocateGift_Open" )
}


void function InitInboxMenu()
{
	RegisterSignal( "StopInboxThread" )
	RegisterSignal( "StopMessageAbuseReports" )

	var menu = GetMenu( "Inbox" )
	file.inboxMenu = menu
	var inboxPanel = Hud_GetChild( menu, "InboxPanel" )

	AddMenuEventHandler( menu, eUIEvent.MENU_OPEN, OnInboxMenu_Open )

	file.inboxCurrentMessageId = Inbox_GetMessageIdByIndex( 0 )
	file.inboxNextMessageId = Inbox_GetNextMessageId( file.inboxCurrentMessageId )
	file.inboxPrevMessageId = Inbox_GetPrevMessageId( file.inboxCurrentMessageId )

	file.inboxCommunityName = Hud_GetChild( inboxPanel, "CommunityName" )
	file.inboxSenderName = Hud_GetChild( inboxPanel, "Sender" )
	file.inboxDate = Hud_GetChild( inboxPanel, "Date" )
	file.inboxMessageText = Hud_GetChild( inboxPanel, "Message" )
	// file.inboxPrevMsgButton = Hud_GetChild( inboxPanel, "PrevMessageButton" )
	// AddEventHandlerToButton( inboxPanel, "PrevMessageButton", UIE_CLICK, ActivatePrevMessage_OnClick )
	// file.inboxNextMsgButton = Hud_GetChild( inboxPanel, "NextMessageButton" )
	// AddEventHandlerToButton( inboxPanel, "NextMessageButton", UIE_CLICK, ActivateNextMessage_OnClick )

	//file.inboxDeleteButton = Hud_GetChild( inboxPanel, "DeleteMessageButton" )
	//AddEventHandlerToButton( inboxPanel, "DeleteMessageButton", UIE_CLICK, DeleteMessage_OnClick )
	//file.inboxAcceptButton = Hud_GetChild( inboxPanel, "AcceptMessageButton" )
	//AddEventHandlerToButton( inboxPanel, "AcceptMessageButton", UIE_CLICK, AcceptMessage_OnClick )
	//
	var elem = Hud_GetChild( inboxPanel, "MailIcon" )
	var rui = Hud_GetRui( elem )
	RuiSetImage( rui, "basicImage", $"rui/menu/common/inbox_icon_new" )

	AddMenuFooterOption( menu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )
	// AddMenuFooterOption( menu, BUTTON_X, "#X_BUTTON_INBOX_ACCEPT_ALL", "#INBOX_ACCEPT_ALL", AcceptAllMessage_OnClick, CanOnlyAcceptOrOnlyDeleteMessage )
	AddMenuFooterOption( menu, BUTTON_X, "#X_BUTTON_INBOX_DONE", "#INBOX_DONE", AcceptMessage_OnClick, CanOnlyAcceptMessage )
	AddMenuFooterOption( menu, BUTTON_X, "#X_BUTTON_INBOX_DONE", "#INBOX_DONE", DeleteMessage_OnClick, CanOnlyDeleteMessage )
	AddMenuFooterOption( menu, BUTTON_X, "#X_BUTTON_YES", "#YES", AcceptMessage_OnClick, CanAcceptAndDeleteMessage )
	AddMenuFooterOption( menu, BUTTON_Y, "#Y_BUTTON_NO", "#NO", DeleteMessage_OnClick, CanAcceptAndDeleteMessage )
	AddMenuFooterOption( menu, BUTTON_Y, "#COMMUNITY_REPORTMSGABUSE_YBUTTON", "#COMMUNITY_REPORTMSGABUSE", ReportMessageAbuse_OnClick, CanReportMessageAbuse )
}



void function OnInboxMenu_Open()
{
	UI_SetPresentationType( ePresentationType.NO_MODELS )
}

bool function CanDeleteMessage()
{
	bool res = bool( IsViewingMessages() && file.inboxCanDeleteMsg )
	return res
}

bool function CanAcceptMessage()
{
	bool res = bool( IsViewingMessages() && file.inboxCanAcceptMsg )
	return res
}

bool function CanOnlyAcceptMessage()
{
	return CanAcceptMessage() && !CanDeleteMessage()
}

bool function CanOnlyDeleteMessage()
{
	return CanDeleteMessage() && !CanAcceptMessage()
}

bool function CanOnlyAcceptOrOnlyDeleteMessage()
{
	return CanOnlyAcceptMessage() || CanOnlyDeleteMessage()
}

bool function CanAcceptAndDeleteMessage()
{
	return CanAcceptMessage() && CanDeleteMessage()
}

bool function IsViewingMessages()
{
	return Hud_IsVisible( file.inboxMenu )
}

bool function HasPrevMessage()
{
	if ( !IsViewingMessages() )
		return false

	if ( file.inboxPrevMessageId >= 0 )
		return true

	return false
}

bool function HasNextMessage()
{
	if ( !IsViewingMessages() )
		return false

	if ( file.inboxNextMessageId >= 0 )
		return true

	return false
}


void function DeleteMessage_OnClick( var button )
{
	printt( "deleting message id " + file.inboxCurrentMessageId )
	if ( file.inboxCurrentMessageId >= 0 )
		Inbox_DeleteMessage( file.inboxCurrentMessageId )

	CloseActiveMenu()
	//TryToShowAnInboxMessage()
	//
	//UpdateFooterOptions()
}

void function AcceptMessage_OnClick( var button )
{
	AcceptMessage()
	CloseActiveMenu()

	/*
	DialogData dialogData
	dialogData.header = "#ACCEPT_MESSAGE_COMFIRM"
	dialogData.message = "#ACCEPT_MESSAGE_COMFIRM_SUB"


	AddDialogButton( dialogData, "#YES", AcceptMessage )
	AddDialogButton( dialogData, "#NO" )

	AddDialogFooter( dialogData, "#A_BUTTON_SELECT" )
	AddDialogFooter( dialogData, "#B_BUTTON_BACK" )

	OpenDialog( dialogData )
	*/
}

void function AcceptAllMessage_OnClick( var button )
{
	DialogData dialogData
	dialogData.header = "#ACCEPT_ALL_MESSAGE_COMFIRM"
	dialogData.message = "#ACCEPT_ALL_MESSAGE_COMFIRM_SUB"


	AddDialogButton( dialogData, "#YES", AcceptMessage )
	AddDialogButton( dialogData, "#NO" )

	AddDialogFooter( dialogData, "#A_BUTTON_SELECT" )
	AddDialogFooter( dialogData, "#B_BUTTON_BACK" )

	OpenDialog( dialogData )
}

void function AcceptMessage()
{
	if ( CanAcceptMessage() )
	{
		if ( file.inboxCurrentMessageId >= 0 )
		{
			Inbox_ExecuteMessageAction( file.inboxCurrentMessageId )
		}
	}

	DeleteMessage_OnClick( null )
}

void function ReportMessageAbuse_Final()
{
	if ( file.reportedMessageIds.len() > 100 )
		return

	foreach ( messageId in file.reportedMessageIds )
	{
		if ( messageId == file.inboxCurrentMessageId )
			return
	}

	ReportCommunity( file.reportAbuseCommunityId, file.reportAbuseSeverity )

	file.reportedMessageIds.append( file.inboxCurrentMessageId )
	ReportInboxMessage( file.inboxCurrentMessageId, file.reportAbuseSeverity )
}

void function ReportMessageAbuseAndLeaveNetwork_Final()
{
	file.reportAbuseSeverity = 1
	ReportMessageAbuse_Final()
	if ( AreWeInCommunity( file.reportAbuseCommunityId ) )
		LeaveCommunity( file.reportAbuseCommunityId )
}

void function ReportMessageAbuse_Thread( InboxMessage msg )
{
	Signal( uiGlobal.signalDummy, "StopMessageAbuseReports" )
	EndSignal( uiGlobal.signalDummy, "StopMessageAbuseReports" )

	DialogData dialogData

	file.reportAbuseCommunityId = msg.communityID
	file.reportAbuseSeverity = 0

	dialogData.header = Localize( "#REALLY_REPORT_ABUSEMSG_HEADER" )
	dialogData.message = Localize( "#REALLY_REPORT_ABUSEMSG" )

	AddDialogButton( dialogData, "#NO" )
	AddDialogButton( dialogData, "#YES_REPORT_ABUSEMSG", ReportMessageAbuse_Final )
	if ( AreWeInCommunity( file.reportAbuseCommunityId ) )
		AddDialogButton( dialogData, "#YES_REPORTMSG_AND_LEAVENETWORK", ReportMessageAbuseAndLeaveNetwork_Final )

	AddDialogFooter( dialogData, "#A_BUTTON_SELECT" )
	AddDialogFooter( dialogData, "#B_BUTTON_BACK" )

	OpenDialog( dialogData )
}

void function ReportMessageAbuse_OnClick( var button )
{
	EmitUISound( "Menu.Accept" )

	InboxMessage msg = Inbox_GetMessage( file.inboxCurrentMessageId )
	Assert( IsValid( msg ) )
	if ( msg.senderUID == "" )
		return

	thread ReportMessageAbuse_Thread( msg )
}

bool function CanReportMessageAbuse()
{
	if ( CanAcceptAndDeleteMessage() )
		return false;

	InboxMessage msg = Inbox_GetMessage( file.inboxCurrentMessageId )
	Assert( IsValid( msg ) )

	if ( file.reportedMessageIds.len() > 100 )
		return false

	foreach ( messageId in file.reportedMessageIds )
	{
		if ( messageId == msg.messageId )
			return false
	}

	return msg.reportable
}

void function ActivateNextMessage( var button )
{
	if ( file.inboxNextMessageId >= 0 )
	{
		file.inboxCurrentMessageId = file.inboxNextMessageId
		file.inboxNextMessageId = Inbox_GetNextMessageId( file.inboxCurrentMessageId )
		file.inboxPrevMessageId = Inbox_GetPrevMessageId( file.inboxCurrentMessageId )

		/*
				var rui = Hud_GetRui( file.inboxMessageText )
				RuiSetInt( rui, "direction", 1 )
		*/

		ShowInboxMessage( file.inboxCurrentMessageId )

		UpdateFooterOptions()
	}
}

void function ActivatePrevMessage( var button )
{
	if ( file.inboxPrevMessageId >= 0 )
	{
		file.inboxCurrentMessageId = file.inboxPrevMessageId
		file.inboxNextMessageId = Inbox_GetNextMessageId( file.inboxCurrentMessageId )
		file.inboxPrevMessageId = Inbox_GetPrevMessageId( file.inboxCurrentMessageId )

		/*
				var rui = Hud_GetRui( file.inboxMessageText )
				RuiSetInt( rui, "direction", -1 )
		*/

		ShowInboxMessage( file.inboxCurrentMessageId )

		UpdateFooterOptions()
	}
}


bool function UpdateInboxMessageUI( InboxMessage msg )
{
	if ( msg.messageId < 0 )
		return false

	Hud_SetUTF8Text( file.inboxCommunityName, Localize( msg.communityName ) )
	Hud_SetUTF8Text( file.inboxSenderName, Localize( msg.senderName ) )
	Hud_SetUTF8Text( file.inboxDate, Localize( msg.dateSent ) )
	Hud_SetUTF8Text( file.inboxMessageText, Localize( msg.messageText ) )

	Hud_SetFocused( file.inboxMessageText );

	if ( file.oldMessageText != msg.messageText )
	{
		printt( "setting new message:" )
		printt( msg.messageText )
		printt( Time() )
		/*
				var rui = Hud_GetRui( file.inboxMessageText )
				RuiSetString( rui, "oldMessage", file.oldMessageText )
				RuiSetString( rui, "newMessage", msg.messageText )
				RuiSetGameTime( rui, "startTime", Time() )
		*/
		file.oldMessageText = msg.messageText
	}

	Inbox_MarkMessageRead( msg.messageId )

	int prevMsgId = Inbox_GetPrevMessageId( msg.messageId )
	#if PC_PROG
		//	if ( prevMsgId >= 0 )
		//		Hud_Show( file.inboxPrevMsgButton )
		//	else
		//		Hud_Hide( file.inboxPrevMsgButton )
	#endif

	int nextMsgId = Inbox_GetNextMessageId( msg.messageId )
	#if PC_PROG
		//	if ( nextMsgId >= 0 )
		//		Hud_Show( file.inboxNextMsgButton )
		//	else
		//		Hud_Hide( file.inboxNextMsgButton )
	#endif

	file.inboxCanDeleteMsg = msg.deletable
	//#if PC_PROG
	//	if ( file.inboxCanDeleteMsg )
	//		Hud_Show( file.inboxDeleteButton )
	//	else
	//		Hud_Hide( file.inboxDeleteButton )
	//#endif

	file.inboxCanAcceptMsg = msg.actionURL != ""

	if ( file.inboxCanAcceptMsg )
	{
		//Hud_Show( file.inboxAcceptButton )
		//// Hud_SetFocused( file.inboxAcceptButton )
		//Hud_SetText( file.inboxAcceptButton, msg.actionLabel )
	}
	else
	{
		//#if PC_PROG
		//	// Hud_SetFocused( file.inboxDeleteButton )
		//#endif
		//Hud_Hide( file.inboxAcceptButton )
	}

	UpdateFooterOptions()

	return true
}

void function UICodeCallback_InboxUpdated()
{
	ShowNotification()

	//ArmoryMenu_UpdateInboxButtons()
	Lobby_UpdateInboxButtons()
	Search_UpdateInboxButtons()

	TryToShowAnInboxMessage()
}


void function KeepUpdatingInboxMessageThread()
{
	Signal( uiGlobal.signalDummy, "StopInboxThread" )

	while ( true )
	{
		WaitFrameOrUntilLevelLoaded()
		InboxMessage msg = Inbox_GetMessage( file.inboxCurrentMessageId )
		if ( msg.messageId >= 0 )
			UpdateInboxMessageUI( msg )
		if ( msg.doneResolving )
			return
	}
	Assert( false )
}

void function ActivatePrevMessage_OnClick( var button )
{
	ActivatePrevMessage( button )
}

void function ActivateNextMessage_OnClick( var button )
{
	ActivateNextMessage( button )
}

bool function ShowInboxMessage( int messageId )
{
	if ( Inbox_GetTotalMessageCount() )
	{
		Assert( messageId >= 0 )
		InboxMessage msg = Inbox_GetMessage( messageId )
		if ( msg.messageId < 0 ) // invalid
			return false

		Signal( uiGlobal.signalDummy, "StopInboxThread" )
		thread KeepUpdatingInboxMessageThread()
		return true
	}

	return false
}

bool function TryToShowAnInboxMessage()
{
	// file.inboxCurrentMessageId = Inbox_GetNextMessageId( file.inboxCurrentMessageId )
	InboxMessage msg = Inbox_GetMessage( file.inboxCurrentMessageId )
	if ( msg.messageId < 0 ) // invalid
	{
		file.inboxCurrentMessageId = Inbox_GetPrevMessageId( file.inboxCurrentMessageId )
		InboxMessage msg = Inbox_GetMessage( file.inboxCurrentMessageId )
		if ( msg.messageId < 0 ) // invalid
			file.inboxCurrentMessageId = Inbox_GetMessageIdByIndex( 0 )
	}

	file.inboxNextMessageId = Inbox_GetNextMessageId( file.inboxCurrentMessageId )
	file.inboxPrevMessageId = Inbox_GetPrevMessageId( file.inboxCurrentMessageId )

	if ( !ShowInboxMessage( file.inboxCurrentMessageId ) )
	{
		if ( IsViewingMessages() )
			CloseActiveMenu()
		return false
	}
	return true
}

void function OnInboxButton_Activate( var button )
{
	//if ( !Inbox_GetTotalMessageCount() || !TryToShowAnInboxMessage() )
	//{
	//	if ( IsViewingMessages() )
	//		CloseActiveMenu()
	//	return
	//}
	//
	//AdvanceMenu( file.inboxMenu )
    if( Hud_IsLocked( button ) )
        return

	AdvanceMenu( GetMenu( "InboxFrontMenu" ) )
}
