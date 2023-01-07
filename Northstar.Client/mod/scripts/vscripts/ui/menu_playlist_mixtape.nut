global function GetPlaylistMenuName
global function InitPlaylistMixtapeMenu
global function InitPlaylistMixtapeChecklistMenu
global function MixtapeMatchmakingIsEnabled
global function GetChecklistPlaylistsArray
global function GetMixtapeMatchmakingVersion
global function IsMixtapeVersionNew
global function PrintPlaylistAvailability
global function ConvertStringArrayToCSS

//script_ui AdvanceMenu( GetMenu( "PlaylistMixtapeMenu" ) )

struct
{
	var mixtapeMenu

	array<var> promoButtons
	array<var> checklistIconButtons
	var playButton
	var pveButton
	var pickButton

	var menuTitle
	var contentDescriptionTitle
	var contentDescription
	var notifyNewTitle

	bool isOnPlaylistCheckboxButton
	bool isOnPromoButton
	bool isOnPlayButton
	bool isShowingPlayButtonDescription

	string lastFocusedPlaylistDisplayName
	string lastFocusedPlaylistNoteText

	/////

	var checklistMenu
	array<var> checklistButtons
	int checklistButtonsFirstVisibleIndex
	array<string> activeChecksOnOpen

	var focusDescription
	int topBGHeight
} file

struct promoInfo
{
	string playlistName
	bool isPromoLocked
	bool isDoubleXP
}
struct checkInfo
{
	string playlistName
	bool isChecked
}
struct
{
	array<promoInfo> promo
	array<checkInfo> checks
} pplInfo


bool function MixtapeMatchmakingIsEnabled()
{
	bool result = (Code_GetCurrentPlaylistVarOrUseValue( "mixtape_matchmaking", "0" ) == "1")
	return result
}

string function GetPlaylistMenuName()
{
	bool mixtapeMatchmakingEnabled = MixtapeMatchmakingIsEnabled()
	if ( mixtapeMatchmakingEnabled )
		return MIXTAPE_MENU_NAME

	return "PlaylistMenu"
}

const int PROMO_SLOT_COUNT = 10
const int CHECKLIST_SLOT_COUNT = 15

void function ParsePlaylistInfos()
{
	pplInfo.promo.clear()
	pplInfo.promo.resize( PROMO_SLOT_COUNT )
	pplInfo.checks.clear()
	pplInfo.checks.resize( CHECKLIST_SLOT_COUNT)

	array<string> checkDisables = GetCheckDisablesFromConvar()
	int plCount = GetPlaylistCount()
	for ( int idx = 0; idx < plCount; ++idx )
	{
		string playlistName = string( GetPlaylistName( idx ) )

		bool visible = GetPlaylistVarOrUseValue( playlistName, "visible", "0" ) == "1"
		if ( !visible )
			continue

		int promoSlot = int( GetPlaylistVarOrUseValue( playlistName, "mixtape_promo_slot", "-1" ) )
		if ( (promoSlot >= 0) && (promoSlot < PROMO_SLOT_COUNT) )
		{
			pplInfo.promo[promoSlot].playlistName = playlistName
			pplInfo.promo[promoSlot].isPromoLocked = (GetPlaylistVarOrUseValue( playlistName, "mixtape_promo_islocked", "0" ) == "1")
			pplInfo.promo[promoSlot].isDoubleXP = (GetPlaylistVarOrUseValue( playlistName, "double_xp_enabled", "0" ) == "1")
		}

		int mixtapeSlot = int( GetPlaylistVarOrUseValue( playlistName, "mixtape_slot", "-1" ) )
		if ( (mixtapeSlot >= 0) && (mixtapeSlot < CHECKLIST_SLOT_COUNT) )
		{
			pplInfo.checks[mixtapeSlot].playlistName = playlistName
			pplInfo.checks[mixtapeSlot].isChecked = !(checkDisables.contains( playlistName ))
		}
	}
}

array<string> function GetChecklistPlaylistsArray()
{
	array<string> results
	results.resize( CHECKLIST_SLOT_COUNT )

	int plCount = GetPlaylistCount()
	for ( int idx = 0; idx < plCount; ++idx )
	{
		string playlistName = string( GetPlaylistName( idx ) )

		bool visible = GetPlaylistVarOrUseValue( playlistName, "visible", "0" ) == "1"
		if ( !visible )
			continue

		int mixtapeSlot = int( GetPlaylistVarOrUseValue( playlistName, "mixtape_slot", "-1" ) )
		if ( (mixtapeSlot >= 0) && (mixtapeSlot < CHECKLIST_SLOT_COUNT) )
			results[mixtapeSlot] = playlistName
	}

	return results
}

const string MIXTAPE_MENU_NAME = "PlaylistMixtapeMenu"
void function InitPlaylistMixtapeMenu()
{
	file.mixtapeMenu = GetMenu( MIXTAPE_MENU_NAME )

	file.menuTitle = Hud_GetChild( file.mixtapeMenu, "MenuTitle" )

	// Promo Buttons

	for ( int idx = 0; idx < PROMO_SLOT_COUNT; ++idx )
	{
		string btnName = ("PromoButton" + format( "%02d", idx ))
		var button = Hud_GetChild( file.mixtapeMenu, btnName )

		file.promoButtons.append( button )

		AddButtonEventHandler( button, UIE_CLICK, OnPromoButtonClick )
		AddButtonEventHandler( button, UIE_GET_FOCUS, OnPromoButtonFocus )
		AddButtonEventHandler( button, UIE_LOSE_FOCUS, OnPromoButtonFocusLost )
	}

	for ( int idx = 0; idx < CHECKLIST_SLOT_COUNT; ++idx )
	{
		string buttonName = ("BtnPlaylistIcon" + format( "%02d", idx ))
		var button = Hud_GetChild( file.mixtapeMenu, buttonName )

		AddButtonEventHandler( button, UIE_CLICK, OnChecklistIconButtonClick )
		AddButtonEventHandler( button, UIE_GET_FOCUS, OnChecklistIconButtonFocus )
		AddButtonEventHandler( button, UIE_LOSE_FOCUS, OnChecklistIconButtonFocusLost )
		file.checklistIconButtons.append( button )
	}

	file.playButton = Hud_GetChild( file.mixtapeMenu, "PlayButton" )
	AddButtonEventHandler( file.playButton, UIE_CLICK, OnPlayButtonClick )
	AddButtonEventHandler( file.playButton, UIE_GET_FOCUS, OnPlayButtonFocus )
	AddButtonEventHandler( file.playButton, UIE_LOSE_FOCUS, OnPlayButtonFocusLost )

	file.pveButton = Hud_GetChild( file.mixtapeMenu, "PromoButton09" )

	file.pickButton = Hud_GetChild( file.mixtapeMenu, "PickButton" )
	AddButtonEventHandler( file.pickButton, UIE_CLICK, OnPickButtonClick )
	AddButtonEventHandler( file.pickButton, UIE_GET_FOCUS, OnPickButtonFocus )

	file.contentDescriptionTitle = Hud_GetChild( file.mixtapeMenu, "ContentDescriptionTitle" )
	file.contentDescription = Hud_GetChild( file.mixtapeMenu, "ContentDescription" )
	Hud_SetText( file.contentDescription, "" )
	file.notifyNewTitle = Hud_GetChild( file.mixtapeMenu, "NotifyNewTitle" )
	Hud_SetText( file.notifyNewTitle, "#NEW" )
	Hud_SetVisible( file.notifyNewTitle, false )

	AddMenuEventHandler( file.mixtapeMenu, eUIEvent.MENU_OPEN, OnOpenPlaylistMixtapeMenu )

	//AddMenuFooterOption( file.mixtapeMenu, BUTTON_A, "#A_BUTTON_SELECT" )
	AddMenuFooterOption( file.mixtapeMenu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )
	AddMenuFooterOption( file.mixtapeMenu, BUTTON_Y, "#Y_BUTTON_TOGGLE_ALL", "#TOGGLE_ALL", ToggleAllCheckboxButtons, null )
	//AddMenuFooterOption( file.mixtapeMenu, BUTTON_X, "#X_BUTTON_DETAILS", "#MOUSE2_DETAILS", null, IsOnADetailsButton )

	file.focusDescription = Hud_GetChild( file.mixtapeMenu, "FocusDescription" )
	file.topBGHeight = Hud_GetHeight( Hud_GetChild( file.mixtapeMenu, "BackgroundLeft" ) )
}

bool function IsOnADetailsButton()
{
	if ( file.isOnPlaylistCheckboxButton )
		return true
	if ( file.isOnPromoButton )
		return true
	if ( file.isOnPlayButton )
		return true

	return false
}

/////////////////
void function UpdateChecklistIconButtonsThread()
{
	while ( GetTopNonDialogMenu() == GetMenu( MIXTAPE_MENU_NAME ) )
	{
		if ( GetUIPlayer() )
		{
			int enableCount = 0

			string singlePlaylistName
			int length = file.checklistIconButtons.len()
			for( int idx = 0; idx < length; ++idx )
			{
				var panel = file.checklistIconButtons[idx]
				var panelRui = Hud_GetRui( panel )
				string playlistName = pplInfo.checks[idx].playlistName
				if ( playlistName.len() == 0 )
					continue

				bool isLocked = PlaylistShouldShowAsLocked( playlistName )
				RuiSetBool( panelRui, "isLocked", isLocked )

				bool isChecked = pplInfo.checks[idx].isChecked
				RuiSetBool( panelRui, "isChecked", isChecked )

				if ( isChecked && !isLocked )
				{
					++enableCount
					if ( enableCount == 1 )
						singlePlaylistName = GetPlaylistVarOrUseValue( playlistName, "name", "#UNKNOWN_PLAYLIST_NAME" )
				}

				bool isMuted = (file.isOnPromoButton)
				RuiSetBool( panelRui, "isMuted", isMuted )

				bool isGlowing = (file.isOnPlayButton)
				RuiSetBool( panelRui, "isGlowing", isGlowing )
			}

			//
			{
				var playRui = Hud_GetRui( file.playButton )
				RuiSetInt( playRui, "enabledPlaylistCount", enableCount )
				RuiSetString( playRui, "playlistNoteName", singlePlaylistName )
			}
		}
		WaitFrame()
	}
}

void function SetupChecklistIconButtons()
{
	int length = file.checklistIconButtons.len()
	for( int idx = 0; idx < length; ++idx )
	{
		var button = file.checklistIconButtons[idx]
		string playlistName = pplInfo.checks[idx].playlistName

		Hud_SetVisible( button, false )

		var buttonRui = Hud_GetRui( button )
		asset playlistThumbnail = GetPlaylistThumbnailImage( playlistName )
		RuiSetImage( buttonRui, "checkImage", playlistThumbnail )

		string abbr = GetPlaylistVarOrUseValue( playlistName, "abbreviation", "" )
		RuiSetString( buttonRui, "abbreviation", Localize( abbr ) )
	}

	thread UpdateChecklistIconButtonsThread()
}

void function RefreshDescriptionTitle( bool asEnabled )
{
	if ( file.isOnPlaylistCheckboxButton && (file.lastFocusedPlaylistDisplayName.len() > 0) )
	{
		string titleText = Localize( file.lastFocusedPlaylistDisplayName )
		Hud_SetText( file.contentDescriptionTitle, titleText )

		string noteText = Localize( file.lastFocusedPlaylistNoteText )
		Hud_SetText( file.contentDescription, noteText )

		if ( asEnabled )
			Hud_SetColor( file.contentDescriptionTitle, 255, 184, 0, 255 )
		else
			Hud_SetColor( file.contentDescriptionTitle, 128, 128, 128, 255 )
	}
	else
	{
		Hud_SetText( file.contentDescriptionTitle, "#MATCHMAKING_MIXTAPE_CHOOSE_INFO" )
		Hud_SetText( file.contentDescription, "" )

		Hud_SetColor( file.contentDescriptionTitle, 192, 192, 192, 192 )
	}
}

void function SetDescriptionTitleForIconButton( int buttonID )
{
	string playlistName = pplInfo.checks[buttonID].playlistName
	file.lastFocusedPlaylistDisplayName = GetPlaylistVarOrUseValue( playlistName, "name", "#UNKNOWN_PLAYLIST_NAME" )
	file.lastFocusedPlaylistNoteText = GetPlaylistVarOrUseValue( playlistName, "promo_note", "" )

	bool isChecked = pplInfo.checks[buttonID].isChecked
	RefreshDescriptionTitle( isChecked )
}

void function OnChecklistIconButtonFocus( var button )
{
	file.isOnPlaylistCheckboxButton = true
	file.isOnPromoButton = false
	file.isOnPlayButton = false

	int buttonID = int( Hud_GetScriptID( button ) )
	SetDescriptionTitleForIconButton( buttonID )

	string descText = GetPlaylistDescription( pplInfo.checks[buttonID].playlistName )
	Hud_SetText( file.focusDescription, descText )
	file.isShowingPlayButtonDescription = false

	//SetMixtapeVersionCurrent()
}

void function OnChecklistIconButtonFocusLost( var button )
{
//	file.isOnPlaylistCheckboxButton = false
	file.lastFocusedPlaylistDisplayName = ""
	file.lastFocusedPlaylistNoteText = ""
	RefreshDescriptionTitle( false )
}

void function OnChecklistIconButtonClick( var button )
{
	int buttonID = int( Hud_GetScriptID( button ) )

	bool wasChecked = pplInfo.checks[buttonID].isChecked
	pplInfo.checks[buttonID].isChecked = !(wasChecked)
	WriteCheckDisablesToConvar()

	BouncePlayNoteText( !wasChecked )

	SetDescriptionTitleForIconButton( buttonID )

	SetMixtapeVersionCurrent()
}

bool function AreAnyPlaylistsCheckedOff()
{
	int count = pplInfo.checks.len()
	for ( int idx = 0; idx < count; ++idx )
	{
		string playlistName = pplInfo.checks[idx].playlistName
		if ( playlistName.len() <= 0 )
			continue

		if ( !pplInfo.checks[idx].isChecked )
			return true
	}

	return false
}

void function ToggleAllCheckboxButtons( var button )
{
	bool turnAllOn = AreAnyPlaylistsCheckedOff()

	int count = pplInfo.checks.len()
	for ( int idx = 0; idx < count; ++idx )
	{
		string playlistName = pplInfo.checks[idx].playlistName
		if ( playlistName.len() <= 0 )
			continue

		bool wasChecked = pplInfo.checks[idx].isChecked
		if ( turnAllOn && wasChecked )
			continue
		if ( !turnAllOn && !wasChecked )
			continue

		pplInfo.checks[idx].isChecked = !wasChecked
	}
	WriteCheckDisablesToConvar()

	RefreshDescriptionTitle( turnAllOn )

	BouncePlayNoteText( turnAllOn )

	if ( turnAllOn )
		EmitUISound( "Menu_LoadOut_Weapon_Select" )
	else
		EmitUISound( "Menu_LoadOut_PilotCamo_Select" )

	if ( file.isShowingPlayButtonDescription )
		Hud_SetText( file.focusDescription, GetPlayButtonDescription() )
}

void function SetChecklistIconButtonsVisible( bool setBool )
{
	int length = file.checklistIconButtons.len()
	for( int idx = 0; idx < length; ++idx )
	{
		var button = file.checklistIconButtons[idx]
		string playlistName = pplInfo.checks[idx].playlistName

		if ( playlistName.len() == 0 )
		{
			Hud_SetVisible( button, false )
			continue
		}

		Hud_SetVisible( button, setBool )
	}
}
/////////////////

void function UpdatePromoButtonsThread()
{
	while ( GetTopNonDialogMenu() == GetMenu( MIXTAPE_MENU_NAME ) )
	{
		if ( GetUIPlayer() )
		{
			int length = file.promoButtons.len()
			for( int idx = 0; idx < length; ++idx )
			{
				var button = file.promoButtons[idx]
				var buttonRui = Hud_GetRui( button )
				string playlistName = pplInfo.promo[idx].playlistName
				if ( playlistName.len() == 0 )
					continue

				UpdatePlaylistButton( button, playlistName, pplInfo.promo[idx].isPromoLocked )
				RuiSetBool( buttonRui, "doubleXP", pplInfo.promo[idx].isDoubleXP )
			}

		}
		WaitFrame()
	}
}

void function SetupPromoButtons()
{
	int numPromoButtons = 0
	int length = file.promoButtons.len()
	for( int idx = 0; idx < length; ++idx )
	{
		var button = file.promoButtons[idx]
		var buttonRui = Hud_GetRui( button )
		string playlistName = pplInfo.promo[idx].playlistName

		if ( playlistName.len() == 0 )
		{
			Hud_SetVisible( button, false )
			continue
		}

		Hud_SetVisible( button, true )
		numPromoButtons++

		asset playlistImage = GetPlaylistImage( playlistName )
		RuiSetImage( buttonRui, "itemImage", playlistImage )

		string displayName = GetPlaylistVarOrUseValue( playlistName, "name", "#UNKNOWN_PLAYLIST_NAME" )
		RuiSetString( buttonRui, "title", displayName )

		string displayNote = GetPlaylistVarOrUseValue( playlistName, "promo_note", "" )
		RuiSetString( buttonRui, "playlistNoteName", displayNote )
		RuiSetBool( buttonRui, "playlistHasPromotText", displayNote != "" )
	}

	var topBG = Hud_GetChild( file.mixtapeMenu, "BackgroundLeft" )
	var bottomBG = Hud_GetChild( file.mixtapeMenu, "DetailsBackground" )

	//if ( numPromoButtons <= 4 )
	//{
	//	int diff = int( file.topBGHeight * 0.2 )
	//	Hud_SetHeight( topBG, file.topBGHeight * 0.8 )
	//	Hud_SetY( bottomBG, Hud_GetBaseY( bottomBG ) - diff )
	//}
	//else
	//{
		Hud_SetHeight( topBG, file.topBGHeight )
		Hud_SetY( bottomBG, Hud_GetBaseY( bottomBG ) )
	//}

	thread UpdatePromoButtonsThread()
}

int function GetMixtapeMatchmakingVersion()
{
	int result = int( Code_GetCurrentPlaylistVarOrUseValue( "mixtape_version", "-1" ) )
	return result
}

bool function IsMixtapeVersionNew()
{
	int versionNow = GetMixtapeMatchmakingVersion()
	int lastVersionSeen = GetConVarInt( "match_mixtape_version" )
	bool mixtapeVersionIsNew = (versionNow != lastVersionSeen)
	return mixtapeVersionIsNew
}

void function SetMixtapeVersionCurrent()
{
	int versionNow = GetMixtapeMatchmakingVersion()
	int lastVersionSeen = GetConVarInt( "match_mixtape_version" )
	if ( versionNow == lastVersionSeen )
		return

	SetConVarInt( "match_mixtape_version", versionNow )
	Hud_SetVisible( file.notifyNewTitle, false )
}

string function GetMenuHeader()
{
	bool openInviting = IsSendOpenInviteTrue()
	return (openInviting ? "#MENU_HEADER_INVITE_ROOM" : "#MENU_HEADER_FIND_GAME")
}

void function OnOpenPlaylistMixtapeMenu()
{
	StopMatchmaking()
	////

	ParsePlaylistInfos()

	UI_SetPresentationType( ePresentationType.NO_MODELS )

	bool openInviting = IsSendOpenInviteTrue()

	Hud_SetText( file.menuTitle, GetMenuHeader() )

	var pbRui = Hud_GetRui( file.playButton )
	RuiSetBool( pbRui, "bigPresentation", true )
	RuiSetImage( pbRui, "itemImage", $"rui/menu/gametype_select/mixtape_play_image" )
	RuiSetString( pbRui, "title", "#MATCHMAKING_MIXTAPE_PLAY_BUTTON" )

	const bool DO_SHOW_PICK_BUTTON = false
	Hud_SetVisible( file.pickButton, DO_SHOW_PICK_BUTTON )
	if ( DO_SHOW_PICK_BUTTON )
	{
		SetButtonRuiText( file.pickButton, "#MATCHMAKING_MIXTAPE_CHOOSE_OPTION" )
		SetNamedRuiBool( file.pickButton, "showThinBorder", true )

		// SetNamedRuiBool( file.pickButton, "isNew", mixtapeVersionIsNew )
	}

	bool mixtapeVersionIsNew = IsMixtapeVersionNew()
	Hud_SetVisible( file.notifyNewTitle, mixtapeVersionIsNew )


	SetupPromoButtons()
	SetupChecklistIconButtons()

	var pveRui = Hud_GetRui( file.pveButton )
	RuiSetBool( pveRui, "bigPresentation", true )
	RuiSetImage( pveRui, "itemImage", $"rui/menu/gametype_select/pve_play_image" )
	//RuiSetString( pveRui, "title", "#MATCHMAKING_PVE_PLAY_BUTTON" )

	// player count:
	{
		string playlistName = "at"
		//string regionDesc = GetPlaylistCountDescForRegion( playlistName )
		//string worldDesc = GetPlaylistCountDescForWorld( playlistName )
#if DEV
		if ( worldDesc == "" )
			worldDesc = "37429"
#endif // #if DEV
		int totalPlayers = 0
		for ( int i = 0; i < NSGetServerCount(); i++ )
		{
			int serverPlayers = NSGetServerPlayerCount( i )
			totalPlayers += serverPlayers
		}
		string regionDesc = string( totalPlayers )
		Hud_SetText( Hud_GetChild( file.mixtapeMenu, "PlayerCount" ), "#PLAYLIST_PLAYERCOUNT_MIXTAPE_SCREEN", regionDesc, regionDesc )
	}

	SetChecklistIconButtonsVisible( true )

	RefreshDescriptionTitle( false )

	thread DelayedSetFocusThread( file.playButton )
}

bool function IsDialogUp()
{
	bool result = IsDialog( uiGlobal.activeMenu )
	return result
}

void function DelayedSetFocusThread( var item )
{
	WaitEndFrame()
	if ( IsDialogUp() )
		return

	Hud_SetFocused( item )
}

void function OnPromoButtonClick( var button )
{
	int buttonID = int( Hud_GetScriptID( button ) )

	CloseAllDialogs()

	string playlistName = pplInfo.promo[buttonID].playlistName
	array<var> refreshButtons	// empty

	SetNextAutoMatchmakingPlaylist( "" )
	bool didStartMatchmaking = PlaylistButton_Click_Internal( button, playlistName, refreshButtons )
	if ( didStartMatchmaking )
		SetNextAutoMatchmakingPlaylist( playlistName )
}


void function DoPlaylistInfoDialog( string playlistName )
{
	if ( IsDialogUp() )
		return

	string titleText = GetPlaylistVarOrUseValue( playlistName, "name", "#UNKNOWN_PLAYLIST_NAME" )
	string descText = GetPlaylistVarOrUseValue( playlistName, "description", "#UNKNOWN_PLAYLIST_NAME" )

	DialogData dialogData
	dialogData.header = titleText
	dialogData.message = descText
	dialogData.noChoiceWithNavigateBack = true

	AddDialogButton( dialogData, "#OK" )

	OpenDialog( dialogData )
}

string function pldn( array<string> pl, int index )
{
	string playlistName = pl[index]
	string playlistDisplayName = GetPlaylistVarOrUseValue( playlistName, "name", "#UNKNOWN_PLAYLIST_NAME" )
	return Localize( playlistDisplayName )
}

string function BuildPlayWarningMessageTop( array<string> pl )
{
	int playlistCount = pl.len()
	switch ( playlistCount )
	{
		case 0:
		return Localize( "#MATCHMAKING_MIXTAPE_WARN_BODY_TOP_00" )
		case 1:
		return Localize( "#MATCHMAKING_MIXTAPE_WARN_BODY_TOP_01", pldn(pl,0) )
		case 2:
		return Localize( "#MATCHMAKING_MIXTAPE_WARN_BODY_TOP_02", pldn(pl,0), pldn(pl,1) )
		case 3:
		return Localize( "#MATCHMAKING_MIXTAPE_WARN_BODY_TOP_03", pldn(pl,0), pldn(pl,1), pldn(pl,2) )
		case 4:
		return Localize( "#MATCHMAKING_MIXTAPE_WARN_BODY_TOP_04", pldn(pl,0), pldn(pl,1), pldn(pl,2), pldn(pl,3) )
		case 5:
		return Localize( "#MATCHMAKING_MIXTAPE_WARN_BODY_TOP_05", pldn(pl,0), pldn(pl,1), pldn(pl,2), pldn(pl,3), pldn(pl,4) )
		case 6:
		return Localize( "#MATCHMAKING_MIXTAPE_WARN_BODY_TOP_06", pldn(pl,0), pldn(pl,1), pldn(pl,2), pldn(pl,3), pldn(pl,4), pldn(pl,5) )
		case 7:
		return Localize( "#MATCHMAKING_MIXTAPE_WARN_BODY_TOP_07", pldn(pl,0), pldn(pl,1), pldn(pl,2), pldn(pl,3), pldn(pl,4), pldn(pl,5), pldn(pl,6) )
		case 8:
		return Localize( "#MATCHMAKING_MIXTAPE_WARN_BODY_TOP_08", pldn(pl,0), pldn(pl,1), pldn(pl,2), pldn(pl,3), pldn(pl,4), pldn(pl,5), pldn(pl,6), pldn(pl,7) )
		case 9:
		return Localize( "#MATCHMAKING_MIXTAPE_WARN_BODY_TOP_09", pldn(pl,0), pldn(pl,1), pldn(pl,2), pldn(pl,3), pldn(pl,4), pldn(pl,5), pldn(pl,6), pldn(pl,7), pldn(pl,8) )
		default:
		return Localize( "#MATCHMAKING_MIXTAPE_WARN_BODY_TOP_MAX", pldn(pl,0), pldn(pl,1), pldn(pl,2), pldn(pl,3), pldn(pl,4), pldn(pl,5), pldn(pl,6), pldn(pl,7), pldn(pl,8) )
	}
	unreachable
}

void function DoPlayButtonWarningDialog( array<string> activePlaylists, bool andThenPlay )
{
	if ( IsDialogUp() )
		return

	string messageTop = BuildPlayWarningMessageTop( activePlaylists )

	DialogData dialogData
	dialogData.header = "#MENU_HEADER_PLAY"
	dialogData.message = messageTop + Localize( "#MATCHMAKING_MIXTAPE_WARN_BODY_BOTTOM" )
	dialogData.noChoiceWithNavigateBack = true

	if ( andThenPlay )
	{
		AddDialogButton( dialogData, "#MATCHMAKING_MIXTAPE_WARN_OK", DoPlayButtonAction )
		AddDialogButton( dialogData, "#MATCHMAKING_MIXTAPE_WARN_OKNEVERAGAIN", DoPlayButtonActionWithWarningDisable )
	}
	else
	{
		AddDialogButton( dialogData, "#MATCHMAKING_MIXTAPE_WARN_OK" )
	}

	AddDialogFooter( dialogData, "#B_BUTTON_BACK" )

	OpenDialog( dialogData )
}

void function PlayRightClickSound()
{
	EmitUISound( "Menu.Accept" )
}

void function OnPromoButtonFocus( var button )
{
	file.isOnPlaylistCheckboxButton = false
	file.isOnPromoButton = true
	file.isOnPlayButton = false

	int buttonID = int( Hud_GetScriptID( button ) )
	string descText = GetPlaylistDescription( pplInfo.promo[buttonID].playlistName )
	Hud_SetText( file.focusDescription, descText )
	file.isShowingPlayButtonDescription = false
}

void function OnPromoButtonFocusLost( var button )
{
}

void function BouncePlayNoteText( bool bounceUp )
{
	var playRui = Hud_GetRui( file.playButton )
	RuiSetGameTime( playRui, "playlistNoteBounceTime", Time() )
	RuiSetBool( playRui, "playlistNoteBounceUp", bounceUp )
}

void function DoPlayButtonAction_Internal( array<string> activePlaylists )
{
	if ( activePlaylists.len() <= 0 )
	{
		thread DelayedSetFocusThread( file.checklistIconButtons[0] )
		return
	}
	string playlistsCS = ConvertStringArrayToCSS( activePlaylists )

	CloseActiveMenu()

	printt( "Setting match_playlist to '" + playlistsCS + "' from playlist menu" )
	SetNextAutoMatchmakingPlaylist( playlistsCS )
	if ( IsSendOpenInviteTrue() )
		ClientCommand( "openinvite playlist " + playlistsCS )
	else
		StartMatchmakingPlaylists( playlistsCS )
}

void function DoPlayButtonAction()
{
	array<string> activePlaylists = GetActiveChecks()
	if ( activePlaylists.len() == 0 )
		return

	DoPlayButtonAction_Internal( activePlaylists )
}

void function DoPlayButtonActionWithWarningDisable()
{
	array<string> activePlaylists = GetActiveChecks()
	if ( activePlaylists.len() == 0 )
		return

	SetConVarBool( "match_mixtape_warnOnPlay", false )
	DoPlayButtonAction_Internal( activePlaylists )
}

void function OnPlayButtonClick( var button )
{
	CloseAllDialogs()

	array<string> activePlaylists = GetActiveChecks()
	if ( activePlaylists.len() == 0 )
	{
		thread DelayedSetFocusThread( file.checklistIconButtons[0] )
		return
	}

	bool warnOnPlay = GetConVarBool( "match_mixtape_warnOnPlay" )
	if ( warnOnPlay )
	{
		DoPlayButtonWarningDialog( activePlaylists, true )
		return
	}

	DoPlayButtonAction_Internal( activePlaylists )
}

void function OnPlayButtonFocus( var button )
{
	file.isOnPlaylistCheckboxButton = false
	file.isOnPromoButton = false
	file.isOnPlayButton = true

	Hud_SetText( file.focusDescription, GetPlayButtonDescription() )
	file.isShowingPlayButtonDescription = true
}

void function OnPlayButtonFocusLost( var button )
{
	file.isOnPlayButton = false
}

void function OnPickButtonClick( var button )
{
	AdvanceMenu( file.checklistMenu )
}

void function OnPickButtonFocus( var button )
{
}



//////////////////////////
//////////////////////////

const string CHECKLIST_MENU_NAME = "PlaylistMixtapeChecklistMenu"
void function InitPlaylistMixtapeChecklistMenu()
{
	file.checklistMenu = GetMenu( CHECKLIST_MENU_NAME )

	for ( int idx = 0; idx < CHECKLIST_SLOT_COUNT; ++idx )
	{
		string btnName = ("BtnPlaylistCheck" + format( "%02d", idx ))
		var button = Hud_GetChild( file.checklistMenu, btnName )

		file.checklistButtons.append( button )

		AddButtonEventHandler( button, UIE_GET_FOCUS, OnChecklistButtonFocus )
		AddButtonEventHandler( button, UIE_CLICK, OnChecklistButtonClick )
	}

	AddMenuEventHandler( file.checklistMenu, eUIEvent.MENU_OPEN, OnOpenPlaylistMixtapeChecklistMenu )
	AddMenuFooterOption( file.checklistMenu, BUTTON_A, "#A_BUTTON_SELECT" )
	AddMenuFooterOption( file.checklistMenu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )
}

void function UpdateChecklistButtonsThread()
{
	while ( GetTopNonDialogMenu() == GetMenu( CHECKLIST_MENU_NAME ) )
	{
		if ( GetUIPlayer() )
		{
			int length = file.checklistButtons.len()
			for( int idx = 0; idx < length; ++idx )
			{
				var button = file.checklistButtons[idx]
				var buttonRui = Hud_GetRui( button )
				string playlistName = pplInfo.checks[idx].playlistName
				if ( playlistName.len() == 0 )
					continue

				bool isLocked = PlaylistShouldShowAsLocked( playlistName )
				RuiSetBool( buttonRui, "isLocked", isLocked )

				RuiSetBool( buttonRui, "isChecked", pplInfo.checks[idx].isChecked )
			}

		}
		WaitFrame()
	}
}

void function SetupChecklistButtons()
{
	file.checklistButtonsFirstVisibleIndex = -1
	int length = file.checklistButtons.len()
	for( int idx = 0; idx < length; ++idx )
	{
		var button = file.checklistButtons[idx]
		var buttonRui = Hud_GetRui( button )
		string playlistName = pplInfo.checks[idx].playlistName

		if ( playlistName.len() == 0 )
		{
			Hud_SetVisible( button, false )
			continue
		}

		Hud_SetVisible( button, true )
		if ( file.checklistButtonsFirstVisibleIndex < 0 )
			file.checklistButtonsFirstVisibleIndex = idx

		asset playlistThumbnail = GetPlaylistThumbnailImage( playlistName )
		RuiSetImage( buttonRui, "checkImage", playlistThumbnail )

		string playlistDisplayName = GetPlaylistVarOrUseValue( playlistName, "name", "#UNKNOWN_PLAYLIST_NAME" )
		SetButtonRuiText( button, playlistDisplayName )
	}

	thread UpdateChecklistButtonsThread()
}

void function OnOpenPlaylistMixtapeChecklistMenu()
{
	SetupChecklistButtons()

	file.activeChecksOnOpen = GetActiveChecks()

	// Clear "New!":
	{
		int versionNow = GetMixtapeMatchmakingVersion()
		SetConVarInt( "match_mixtape_version", versionNow )
	}

	if ( file.checklistButtonsFirstVisibleIndex >= 0 )
		thread DelayedSetFocusThread( file.checklistButtons[file.checklistButtonsFirstVisibleIndex] )
}

void function OnChecklistButtonFocus( var button )
{
	int buttonID = int( Hud_GetScriptID( button ) )

	string playlistName = pplInfo.checks[buttonID].playlistName

	asset playlistImage = GetPlaylistImage( playlistName )
	RuiSetImage( Hud_GetRui( Hud_GetChild( file.checklistMenu, "PlaylistImage" ) ), "basicImage", playlistImage )

	string displayName = GetPlaylistVarOrUseValue( playlistName, "name", "#UNKNOWN_PLAYLIST_NAME" )
	Hud_SetText( Hud_GetChild( file.checklistMenu, "PlaylistDescriptionTitle" ), displayName )

	string descText = GetPlaylistVarOrUseValue( playlistName, "description", "#UNKNOWN_PLAYLIST_NAME" )
	Hud_SetText( Hud_GetChild( file.checklistMenu, "PlaylistDescription" ), descText )
}

void function OnChecklistButtonClick( var button )
{
	int buttonID = int( Hud_GetScriptID( button ) )
	//bool isLocked = PlaylistShouldShowAsLocked( pplInfo.checks[buttonID].playlistName )
	//if ( isLocked )
	//	return

	pplInfo.checks[buttonID].isChecked = !(pplInfo.checks[buttonID].isChecked)
	WriteCheckDisablesToConvar()
}

void function WriteCheckDisablesToConvar()
{
	string result = ""
	bool foundADisable = false
	int checksCount = pplInfo.checks.len()
	for ( int idx = 0; idx < checksCount; ++idx )
	{
		string playlistName = pplInfo.checks[idx].playlistName
		if ( (playlistName.len() > 0) && !pplInfo.checks[idx].isChecked )
		{
			if ( !foundADisable )
				foundADisable = true
			else
				result += ","
			result += playlistName
		}
	}

	SetConVarString( "match_mixtape_unchecked", result )

	int convarVersionOld = GetConVarInt( "match_mixtape_unchecked_version" )
	int convarVersionNow = int( Code_GetCurrentPlaylistVarOrUseValue( "mixtape_checkbox_memory_version", "-1" ) )
	if ( convarVersionOld != convarVersionNow )
		SetConVarInt( "match_mixtape_unchecked_version", convarVersionNow )
}

array<string> function GetCheckDisablesFromConvar()
{
	int convarVersionUsed = GetConVarInt( "match_mixtape_unchecked_version" )
	int convarVersionNow = int( Code_GetCurrentPlaylistVarOrUseValue( "mixtape_checkbox_memory_version", "-1" ) )

	string convarVal = (convarVersionUsed == convarVersionNow) ? GetConVarString( "match_mixtape_unchecked" ) : ""
	array<string> result = split( convarVal, "," )
	return result
}

array<string> function GetActiveChecks_Internal( bool excludeIfLocked )
{
	array<string> result

	int count = pplInfo.checks.len()
	for ( int idx = 0; idx < count; ++idx )
	{
		string playlistName = pplInfo.checks[idx].playlistName
		if ( playlistName.len() <= 0 )
			continue

		if ( !pplInfo.checks[idx].isChecked )
			continue

		if ( excludeIfLocked && PlaylistShouldShowAsLocked( playlistName ) )
			continue

		result.append( playlistName )
	}

	return result
}

array<string> function GetActiveChecks()
{
	return GetActiveChecks_Internal( true )
}

string function ConvertStringArrayToCSS( array<string> strArray )
{
	string result = ""
	bool usedOne = false
	int count = strArray.len()
	for ( int idx = 0; idx < count; ++idx )
	{
		string thisStr = strArray[idx]
		if ( (thisStr.len() > 0) )
		{
			if ( !usedOne )
				usedOne = true
			else
				result += ","
			result += thisStr
		}
	}

	return result
}

string function GetPlayButtonDescription()
{
	string message = BuildPlayWarningMessageTop( GetActiveChecks() )
	string descText = message + Localize( "#MATCHMAKING_MIXTAPE_WARN_BODY_BOTTOM" )

	return descText
}

string function GetPlaylistDescription( string playlistName )
{
	return GetPlaylistVarOrUseValue( playlistName, "description", "#UNKNOWN_PLAYLIST_NAME" )
}

void function PrintPlaylistAvailability()
{
	printt( "!!!!!!!!!!!!!!!!!!!!!!! PrintPlaylistAvailability() called with party size", GetPartySize() )
	printt( "!!!!!!!!!!!!!!!!!!!!!!!     aitdm:", CanPlaylistFitMyParty( "aitdm" ) )
	printt( "!!!!!!!!!!!!!!!!!!!!!!!     at:   ", CanPlaylistFitMyParty( "at" ) )
	printt( "!!!!!!!!!!!!!!!!!!!!!!!     cp:   ", CanPlaylistFitMyParty( "cp" ) )
	printt( "!!!!!!!!!!!!!!!!!!!!!!!     lts:  ", CanPlaylistFitMyParty( "lts" ) )
	printt( "!!!!!!!!!!!!!!!!!!!!!!!     ctf:  ", CanPlaylistFitMyParty( "ctf" ) )
	printt( "!!!!!!!!!!!!!!!!!!!!!!!     ps:   ", CanPlaylistFitMyParty( "ps" ) )
	printt( "!!!!!!!!!!!!!!!!!!!!!!!     ffa:  ", CanPlaylistFitMyParty( "ffa" ) )
}
