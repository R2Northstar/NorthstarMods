global function DownloadMod
global function DisplayModDownloadErrorDialog
global function InitModDownloadControlsMenu

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

bool function DownloadMod( RequiredModInfo mod )
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

	return state.status == eModInstallStatus.DONE
}

const int MB = 1024*1000;

void function UpdateModDownloadDialog( RequiredModInfo mod, ModInstallState state, var menu, var header, var body )
{
	switch (state.status) {
		case eModInstallStatus.DOWNLOADING:
			Hud_SetText( header, format( "DOWNLOADING MOD (%s", string(state.ratio) ) + "%)")
			Hud_SetText( body, format( "Downloading %s v%s...\n(%i/%i MB)", mod.name, mod.version, floor(state.progress / MB), floor(state.total / MB) ) )
			break;
		case eModInstallStatus.CHECKSUMING:
			Hud_SetText( header, "CHECKSUMING MOD..." )
			break;
		case eModInstallStatus.EXTRACTING:
			Hud_SetText( header, format( "EXTRACTING MOD (%s", string(state.ratio) ) + "%)")
			Hud_SetText( body, format( "Extracting %s v%s...\n(%i/%i MB)", mod.name, mod.version, floor(state.progress / MB), floor(state.total / MB) ) )
			break;
		default:
			break;
	}
}

void function DisplayModDownloadErrorDialog( string modName )
{
	ModInstallState state = NSGetModInstallState()

	DialogData dialogData
	dialogData.header = Localize( "#FAILED_DOWNLOADING", modName )
	dialogData.image = $"ui/menu/common/dialog_error"

	switch (state.status) {
    	case eModInstallStatus.FAILED_READING_ARCHIVE:
			dialogData.message = Localize( "#FAILED_READING_ARCHIVE" )
			break
    	case eModInstallStatus.FAILED_WRITING_TO_DISK:
			dialogData.message = Localize( "#FAILED_WRITING_TO_DISK" )
			break
    	case eModInstallStatus.MOD_FETCHING_FAILED:
			dialogData.message = Localize( "#MOD_FETCHING_FAILED" )
			break
    	case eModInstallStatus.MOD_CORRUPTED:
			dialogData.message = Localize( "#MOD_CORRUPTED" )
			break
    	case eModInstallStatus.NO_DISK_SPACE_AVAILABLE:
			dialogData.message = Localize( "#NO_DISK_SPACE_AVAILABLE" )
			break
    	case eModInstallStatus.NOT_FOUND:
			dialogData.message = Localize( "#NOT_FOUND" )
			break
		case eModInstallStatus.FAILED:
		default:
			dialogData.message = Localize( "#FAILED" )
			break;
	}

	#if PC_PROG
		AddDialogButton( dialogData, "#DISMISS" )
		AddDialogFooter( dialogData, "#A_BUTTON_SELECT" )
	#endif
	AddDialogFooter( dialogData, "#B_BUTTON_DISMISS_RUI" )

	OpenDialog( dialogData )
}

void function InitModDownloadControlsMenu()
{
	string buttonName = "Automatic mod downloading"
	string description = "Activate this option to automatically download mods that are required by a server to join it."

	// Setup button
	var menu = GetMenu( "ControlsMenu" )
	var button = Hud_GetChild( menu, "SwchModDownload" )
	var itemDescriptionBox = Hud_GetChild( menu, "LblMenuItemDescription" )
	RuiSetString( Hud_GetRui( button ), "buttonText", buttonName )

	// Setting description handler
	AddButtonEventHandler( button, UIE_GET_FOCUS, void function( var button ): ( description, itemDescriptionBox ) {
		RuiSetString( Hud_GetRui( itemDescriptionBox ), "description", description )
	})
}