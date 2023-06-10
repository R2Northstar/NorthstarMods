global function AtlasAuthDialog

void function AtlasAuthDialog()
{
	thread AtlasAuthDialog_Threaded()
}

void function AtlasAuthDialog_Threaded()
{
	while ( !NSIsMasterServerAuthenticated() || GetConVarBool( "ns_auth_allow_insecure" ) )
		WaitFrame()

	if (GetConVarBool( "ns_auth_allow_insecure" ))
		return

	MasterServerAuthResult res = NSGetMasterServerAuthResult()

	// do nothing on successful authentication
	if (res.success)
	    return

	EmitUISound( "blackmarket_purchase_fail" )

	DialogData dialogData
	dialogData.image = $"ui/menu/common/dialog_error"
	dialogData.header = "Authentication Failed"
	dialogData.message = "Failed to authenticate with Atlas:"

	// if we got a special error message from Atlas, display it
	if (res.errorMessage != "")
		dialogData.message += "\n" + res.errorMessage

	if (res.errorCode != "")
		dialogData.message += "\n\nError code: " + res.errorCode

	CloseAllDialogs()
	AddDialogButton( dialogData, "#OK", null )
	AddDialogButton( dialogData, "Help", null ) // todo: open northstar wiki in browser

	OpenDialog( dialogData )
}