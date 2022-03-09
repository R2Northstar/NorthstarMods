untyped

struct
{
	var menu
	var enterPasswordBox
	var enterPasswordDummy
	var connectButton
	var inviteJoinMenu
	var inviteEntryBox
} file

globalize_all_functions

void function SetupInviteSystem() {

	AddMenu( "JoinInviteMenu", $"resource/ui/menus/ns_joininvite.menu", InitInviteMenu, "#MENU_CONNECT" )
	AddMenu( "ConnectWithPasswordMenuInvite", $"resource/ui/menus/connect_password.menu", InitConnectPasswordMenu, "#MENU_CONNECT" )
}

void function ShowURIDialog() {
    DialogData dialogData
	dialogData.header = "#NS_INVITE_JOIN_HEADER"
	dialogData.image = $"rui/menu/fd_menu/upgrade_northstar_chassis"
	dialogData.message = Localize("#NS_INVITE_JOIN_BODY", NSGetInviteServerName())
	if (NSGetInviteShouldShowPasswordDialog())
		AddDialogButton( dialogData, "#YES", ShowPasswordDialogBeforeJoin)
	else
		AddDialogButton( dialogData, "#YES", NSAcceptInvite)
	AddDialogButton( dialogData, "#NO", NSDeclineInvite)
	OpenDialog( dialogData )
}

void function ShowPasswordDialogBeforeJoin() {
	print("Going to show password dialog next")
	AdvanceMenu( GetMenu( "ConnectWithPasswordMenuInvite" ) )
}

void function InitInviteMenu() {
	file.inviteJoinMenu = GetMenu( "JoinInviteMenu" )
	AddMenuFooterOption( file.inviteJoinMenu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )
	var connectButton = Hud_GetChild( file.inviteJoinMenu, "ConnectButton")
	Hud_AddEventHandler( connectButton, UIE_CLICK, TryJoinInvite )
	file.inviteEntryBox = Hud_GetChild(file.inviteJoinMenu, "EnterInviteBox")

	RegisterButtonPressedCallback( KEY_ENTER, ContinueInviteProcess )
}

void function InitConnectPasswordMenu() {
	file.menu = GetMenu( "ConnectWithPasswordMenuInvite" )

	file.enterPasswordBox = Hud_GetChild( file.menu, "EnterPasswordBox")
	file.enterPasswordDummy = Hud_GetChild( file.menu, "EnterPasswordBoxDummy")
	file.connectButton = Hud_GetChild( file.menu, "ConnectButton")

	AddMenuEventHandler( file.menu, eUIEvent.MENU_OPEN, OnConnectWithPasswordMenuOpenedInvite )
	AddMenuFooterOption( file.menu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )

	AddButtonEventHandler( file.connectButton, UIE_CLICK, ConnectWithPasswordInvite )

	AddButtonEventHandler( file.enterPasswordBox, UIE_CHANGE, UpdatePasswordLabelInvite )

	RegisterButtonPressedCallback( KEY_ENTER, ConnectWithPasswordInvite )
}


void function UpdatePasswordLabelInvite( var n )
{
	string hiddenPSWD
	for ( int i = 0; i < Hud_GetUTF8Text( file.enterPasswordBox ).len(); i++)
		hiddenPSWD += "*"
	Hud_SetText( file.enterPasswordDummy, hiddenPSWD )
}

void function OnConnectWithPasswordMenuOpenedInvite()
{
	UI_SetPresentationType( ePresentationType.KNOWLEDGEBASE_SUB )

	Hud_SetText( Hud_GetChild( file.menu, "Title" ), "#MENU_TITLE_CONNECT_PASSWORD" )
	Hud_SetText( file.connectButton, "#MENU_CONNECT_MENU_CONNECT" )
	Hud_SetText( file.enterPasswordBox, "" )
	Hud_SetText( file.enterPasswordDummy, "" )
}

void function ContinueInviteProcess( var button )
{
	if ( GetTopNonDialogMenu() == file.inviteJoinMenu && Hud_GetUTF8Text(file.enterPasswordBox) != "" ) {
		TryJoinInvite("")
	}
}

void function ConnectWithPasswordInvite( var button )
{

	if ( GetTopNonDialogMenu() == file.menu && Hud_GetUTF8Text(file.enterPasswordBox) != "") {
		if(!NSJoinInviteWithPassword(Hud_GetUTF8Text(file.enterPasswordBox))) {
			CreateJoinErrorDialog()
		}
	}
}

void function GenerateInviteSuccesDialog( DialogData randomParamIGuess ) {
	DialogData dialogData
	dialogData.header = "#NS_GENERATE_INVITE_SUCCESS"
	dialogData.ruiMessage.message = "#NS_GENERATE_INVITE_SUCCESS_MESSAGE"

	AddDialogButton( dialogData, "#OK" )

	OpenDialog( dialogData )
}

void function doGenerateServerInvite(bool link) {
	int res = NSGenerateServerInvite(link)
	if (res == 0) {
		DialogData dialogData
		dialogData.header = "#NS_INVITE_GENERATE_FAILURE_HEADER"
		dialogData.ruiMessage.message = "NS_GENERATE_INVITE_SUCCESS_BODY"

		AddDialogButton( dialogData, "#OK" )

		OpenDialog( dialogData )
	}
	else {
		DialogData dialogData
		dialogData.header = "#NS_INVITE_GENERATE_SUCCESS_HEADER"
		dialogData.ruiMessage.message = "NS_INVITE_GENERATE_SUCCESS_BODY"

		AddDialogButton( dialogData, "#OK" )

		OpenDialog( dialogData )
	}
}

void function GenerateServerInvite( var unused ) {
	doGenerateServerInvite(true)
}

void function CreateJoinErrorDialog() {
	NSDeclineInvite()
	DialogData dialogData
	dialogData.header = "#NS_INVITE_JOIN_FAILURE_HEADER"
	dialogData.ruiMessage.message = Localize("#NS_INVITE_JOIN_FAILURE_BODY", NSGetLastInviteError())
	AddDialogButton( dialogData, "#OK" )

	OpenDialog( dialogData )
}

void function TryJoinInvite( var unused ) {
	string invite = Hud_GetUTF8Text(file.inviteEntryBox)
	if (NSParseInvite(invite)) {
		if(!NSRequestInviteServerInfo()){
			CreateJoinErrorDialog()
			return
		}
		if (NSGetInviteShouldShowPasswordDialog()) {
			print("Should show password dialog")
			ShowPasswordDialogBeforeJoin()
		}
		else {
			if(!NSTryJoinInvite()) {
				CreateJoinErrorDialog()
			}
		}
	}
	else {
		CreateJoinErrorDialog()
	}
}