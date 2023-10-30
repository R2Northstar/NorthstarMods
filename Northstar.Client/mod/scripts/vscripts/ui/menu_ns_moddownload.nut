global function DownloadMod

global enum eModInstallStatus
{
    DOWNLOADING,
    CHECKSUMING,
    EXTRACTING,
    DONE,
    FAILED,
    FAILED_READING_ARCHIVE,
    FAILED_WRITING_TO_DISK,
    MOD_FETCHING_FAILED,
    MOD_CORRUPTED,
    NO_DISK_SPACE_AVAILABLE,
    NOT_FOUND
}

void function DownloadMod( RequiredModInfo mod )
{
	// Downloading mod UI
	DialogData dialogData
	dialogData.header = Localize( "#DOWNLOADING_MOD_TITLE" )
	dialogData.message = Localize( "#DOWNLOADING_MOD_TEXT", mod.name, mod.version )
	dialogData.showSpinner = true;

	// Prevent user from closing dialog
	dialogData.forceChoice = true;
	OpenDialog( dialogData )

	// Save reference to UI elements, to update their content
	var menu = GetMenu( "Dialog" )
	var header = Hud_GetChild( menu, "DialogHeader" )
	var body = GetSingleElementByClassname( menu, "DialogMessageClass" )

	// Start actual mod downloading
	NSDownloadMod( mod.name, mod.version )

	ModInstallState state = NSGetModInstallState()
	while (state.status < eModInstallStatus.DONE)
	{
		state = NSGetModInstallState()
		UpdateModDownloadDialog( mod, state, menu, header, body )
		WaitFrame()
	}

	print("Mod status: " + state.status)

	// Close loading dialog
	CloseActiveMenu()
}

void function UpdateModDownloadDialog( RequiredModInfo mod, ModInstallState state, var menu, var header, var body )
{
	switch (state.status) {
		case eModInstallStatus.DOWNLOADING:
			Hud_SetText( header, "DOWNLOADING MOD..." )
			break;
		case eModInstallStatus.CHECKSUMING:
			Hud_SetText( header, "CHECKSUMING MOD..." )
			break;
		case eModInstallStatus.EXTRACTING:
			Hud_SetText( header, "EXTRACTING MOD..." )
			break;
		default:
			break;
	}
}