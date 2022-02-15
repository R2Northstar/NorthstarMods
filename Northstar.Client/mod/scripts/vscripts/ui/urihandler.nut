untyped

globalize_all_functions

void function ShowURIDialog() {
    DialogData dialogData
	dialogData.header = "Invite received"
	dialogData.image = $"rui/menu/fd_menu/upgrade_northstar_chassis"
	dialogData.message = "#INVITE_RECEIVED"
	AddDialogButton( dialogData, "#YES", NSAcceptInvite)
	AddDialogButton( dialogData, "#NO", NSDeclineInvite)
	OpenDialog( dialogData )
}