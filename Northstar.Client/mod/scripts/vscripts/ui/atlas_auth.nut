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
	dialogData.header = Localize("#AUTHENTICATION_FAILED_HEADER")
	dialogData.message = Localize("#AUTHENTICATION_FAILED_BODY")

	// if we got a special error message from Atlas, display it
	if (res.errorMessage != "")
		dialogData.message += "\n" + res.errorMessage

	if (res.errorCode != "")
		dialogData.message += "\n\n" + Localize("#AUTHENTICATION_FAILED_ERROR_CODE", res.errorCode)


	CloseAllDialogs()
	AddDialogButton( dialogData, "#OK", null )
	AddDialogButton( dialogData, Localize("#AUTHENTICATION_FAILED_HELP"), void function() {
		// todo: get MS to redirect, so i can use an MS link or something?
		// also todo: link using # to the error code given, needs work on wiki side of things
		string link = "https://r2northstar.gitbook.io/r2northstar-wiki/" 
		LaunchExternalWebBrowser( link, WEBBROWSER_FLAG_FORCEEXTERNAL )
	} )

	OpenDialog( dialogData )
}
