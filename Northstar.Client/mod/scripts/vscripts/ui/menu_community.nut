global function InitCommunitiesMenu
global function InitMyNetworksMenu

global function Community_CommunityUpdated
global function UICodeCallback_ShowCommunityInfo
global function UICodeCallback_CommunitySaved
global function UICodeCallback_CommunitySaveFailed
global function UICodeCallback_ShowCommunityJoinRequest
global function OnSwitchButton_Activate
global function OnBrowseNetworksButton_Activate
#if NETWORK_INVITE
global function OnInviteFriendsToNetworkButton_Activate
#endif

const int ADVOCATE_NETWORK = 1

struct CommunityPanel
{
	int CommunityId
	var Name
	var Creator
	var Members
	var MOTD
	var Kills
	var Wins
	var Losses
	var Deaths
	var XP
	var LanguagesLabel
	var RegionsLabel
	var CategoriesLabel
	var CommunityTypeLabel
	var MembershipTypeLabel
	var VisibilityLabel
	var MicPolicyLabel
	var HappyHourStartLabel
	var CommunityNameRui
}

struct
{
	CommunitySettings &settings
	array<string> languages
	array<string> categories
	array<string> regions

	bool haveSettings
	bool firstCommunityUpdateHappened

	var menu

	var switchButton
	var editButton
	var sendMessageButton
	var sendButton
	var chatroomToggleVoiceModeHeader
	var chatroomToggleVoiceModeButton0
	var chatroomToggleVoiceModeButton1

	var chatroomMenu
	var chatroomMenu_chatroomWidget

	var switchCommunityMenu
	var switchCommunityPanel
	var switchCommunityPanel_CommunityInfoPanel
	array<var> switchCommunityPanelButtons
	array<var> switchCommunityPanelHints
	var switchCommunityPanelCover
	var switchCommunityPanel_ListWidget

	string region
	string language

	BrowseFilters browseFilters

	UserInfoPanel pendingJoinRequestPanel
	var pendingJoinRequest_CommunityName
	var pendingJoinRequest_AcceptButton
	var adminViewPendingRequests
	var adminViewPendingRequestsButton
	int totalJoinRequests

	var browseCommunitiesPanel_LastFocused

	var browseCommunitiesMenu
	var browseCommunitiesPanel
	var browseCommunitiesPanel_CommunityInfoPanel
	var browseCommunitiesPanel_FilterBackground
	var browseCommunitiesPanel_ListWidget
	var browseCommunitiesPanel_NameWidget
	var browseCommunitiesPanel_ClantagWidget
	var browseCommunitiesPanel_TypeButton
	var browseCommunitiesPanel_MembershipButton
	var browseCommunitiesPanel_CategoryButton
	var browseCommunitiesPanel_PlaytimeButton
	var browseCommunitiesPanel_MicPolicyButton
	var browseCommunitiesPanel_MinMembersButton
	var browseCommunitiesPanel_ViewDetailsButton
	array<var> browseCommunitiesPanel_HintElements
	array<var> browseCommunitiesPanel_FilterElements

	int reportAbuseCommunityId
	array<int> reportedCommunityIds

	var editCommunityMenu
	var editCommunityLanguagesPanel
	var editCommunityCategoriesPanel
	var editCommunityRegionsPanel
	var editCommunityHappyHourPanel

	var editCommunityPanel_PopupBackground
	var editCommunityPanel_Header
	var editCommunityPanel_Name
	var editCommunityPanel_NameLabel
	var editCommunityPanel_NameBigLabel
	var editCommunityPanel_Clantag
	var editCommunityPanel_MOTD
	var editCommunityPanel_LanguagesButton
	var editCommunityPanel_RegionsButton
	var editCommunityPanel_CategoriesButton
	var editCommunityPanel_CommunityTypeButton
	var editCommunityPanel_MembershipTypeButton
	var editCommunityPanel_VisibilityButton
	var editCommunityPanel_MicPolicyButton
	var editCommunityPanel_HappyHourStartButton
	var editCommunityPanel_CreateButton
	var editCommunityPanel_SaveButton

	array<var> editCommunityLanguagesPanel_LanguageButtons
	array<var> editCommunityRegionsPanel_RegionButtons
	array<var> editCommunityCategoriesPanel_CategoryButtons
	array<var> editCommunityHappyHourPanel_HappyHourButtons

	bool communityEdited = false

	var sendCommunityMsgMenu
	int sendCommunityMsg_expiration
	var sendCommunityMsgPanel_ExpirationButton
	var sendCommunityMsgPanel_MsgText
	var sendCommunityMsgPanel_CommunityName
	var sendCommunityMsgPanel_SendButton

	CommunityPanel communityInfoPanelWidgets
	CommunityPanel myCommunityInfoPanelWidgets

	var selectNetWorkbutton
//	var browseNetworkButton
	bool inCommunityPanel
	array<var> temporaryPanels
	var lastButtonFocused
	table<string,string> keysToStrings
	int currentCommunityId

	ComboStruct &networksComboStruct
} file

void function HideAllPanels()
{
	Hud_Hide( file.editCommunityPanel_PopupBackground )
	Hud_Hide( file.editCommunityHappyHourPanel )
	Hud_Hide( file.editCommunityLanguagesPanel )
	Hud_Hide( file.editCommunityRegionsPanel )
	Hud_Hide( file.editCommunityCategoriesPanel )
	Hud_Hide( file.editCommunityHappyHourPanel )
}

void function OnSwitchButton_Activate( var button )
{
    if( Hud_IsLocked( button ) )
        return

	ClientCommand( "community_list" )
	AdvanceMenu( file.switchCommunityMenu )
	Hud_SetFocused( file.selectNetWorkbutton )
}


void function OnBrowseNetworksButton_Activate( var button )
{
    if( Hud_IsLocked( button ) )
        return

	UpdateBrowseFilters( file.browseFilters )
	AdvanceMenu( file.browseCommunitiesMenu )
	BrowseCommunities_OnChange( file.browseCommunitiesPanel_ListWidget )
	//Hud_SetFocused( file.browseCommunitiesPanel_ListWidget )
	Hud_SetFocused( file.browseCommunitiesPanel_NameWidget )
	CommunitySettings fakeSettings
	FillInCommunityInfoPanel( fakeSettings, file.communityInfoPanelWidgets )
}

void function FillInBrowseFilters( BrowseFilters filters )
{
	Hud_SetText( file.browseCommunitiesPanel_NameWidget, filters.name )
	Hud_SetText( file.browseCommunitiesPanel_ClantagWidget, filters.clantag )

	if ( filters.communityType == "social" )
		Hud_SetText( file.browseCommunitiesPanel_TypeButton, "#COMMUNITY_SOCIAL" )
	else if ( filters.communityType == "competitive" )
		Hud_SetText( file.browseCommunitiesPanel_TypeButton, "#COMMUNITY_COMPETITIVE" )
	else
		Hud_SetText( file.browseCommunitiesPanel_TypeButton, "#COMMUNITY_FILTER_ANY" )

	if ( filters.micPolicy == "nopref" )
		Hud_SetText( file.browseCommunitiesPanel_MicPolicyButton, "#COMMUNITY_MICS_NOPREF" )
	else if ( filters.micPolicy == "yes" )
		Hud_SetText( file.browseCommunitiesPanel_MicPolicyButton, "#COMMUNITY_MICS_YES" )
	else if ( filters.micPolicy == "no" )
		Hud_SetText( file.browseCommunitiesPanel_MicPolicyButton, "#COMMUNITY_MICS_NO" )
	else
		Hud_SetText( file.browseCommunitiesPanel_MicPolicyButton, "#COMMUNITY_FILTER_ANY" )

	if ( filters.membershipType == "invite" )
		Hud_SetText( file.browseCommunitiesPanel_MembershipButton, "#COMMUNITY_MEMBERSHIP_INVITEONLY" )
	else if ( filters.membershipType == "open" )
		Hud_SetText( file.browseCommunitiesPanel_MembershipButton, "#COMMUNITY_MEMBERSHIP_OPEN" )
	else
		Hud_SetText( file.browseCommunitiesPanel_MembershipButton, "#COMMUNITY_FILTER_ANY" )

	if ( filters.category == "gaming" )
		Hud_SetText( file.browseCommunitiesPanel_CategoryButton, "#COMMUNITY_CATEGORY_GAMING" )
	else if ( filters.category == "lifestyle" )
		Hud_SetText( file.browseCommunitiesPanel_CategoryButton, "#COMMUNITY_CATEGORY_LIFESTYLE" )
	else if ( filters.category == "geography" )
		Hud_SetText( file.browseCommunitiesPanel_CategoryButton, "#COMMUNITY_CATEGORY_GEOGRAPHY" )
	else if ( filters.category == "tech" )
		Hud_SetText( file.browseCommunitiesPanel_CategoryButton, "#COMMUNITY_CATEGORY_TECH" )
	else if ( filters.category == "other" )
		Hud_SetText( file.browseCommunitiesPanel_CategoryButton, "#COMMUNITY_CATEGORY_OTHER" )
	else
		Hud_SetText( file.browseCommunitiesPanel_CategoryButton, "#COMMUNITY_FILTER_ANY" )

	if ( filters.playtime == "morning" )
		Hud_SetText( file.browseCommunitiesPanel_PlaytimeButton, "#COMMUNITY_PLAYTIME_MORNING" )
	else if ( filters.playtime == "afternoon" )
		Hud_SetText( file.browseCommunitiesPanel_PlaytimeButton, "#COMMUNITY_PLAYTIME_AFTERNOON" )
	else if ( filters.playtime == "evening" )
		Hud_SetText( file.browseCommunitiesPanel_PlaytimeButton, "#COMMUNITY_PLAYTIME_EVENING" )
	else if ( filters.playtime == "night" )
		Hud_SetText( file.browseCommunitiesPanel_PlaytimeButton, "#COMMUNITY_PLAYTIME_NIGHTTIME" )
	else
		Hud_SetText( file.browseCommunitiesPanel_PlaytimeButton, "#COMMUNITY_FILTER_ANY" )

	if ( filters.minMembers == 1 )
		Hud_SetText( file.browseCommunitiesPanel_MinMembersButton, "#COMMUNITY_MEMBERCOUNTFILTER_1" )
	else if ( filters.minMembers == 2 )
		Hud_SetText( file.browseCommunitiesPanel_MinMembersButton, "#COMMUNITY_MEMBERCOUNTFILTER_2" )
	else if ( filters.minMembers == 10 )
		Hud_SetText( file.browseCommunitiesPanel_MinMembersButton, "#COMMUNITY_MEMBERCOUNTFILTER_10" )
	else if ( filters.minMembers == 100 )
		Hud_SetText( file.browseCommunitiesPanel_MinMembersButton, "#COMMUNITY_MEMBERCOUNTFILTER_100" )
	else if ( filters.minMembers == 1000 )
		Hud_SetText( file.browseCommunitiesPanel_MinMembersButton, "#COMMUNITY_MEMBERCOUNTFILTER_1000" )
	else if ( filters.minMembers == 10000 )
		Hud_SetText( file.browseCommunitiesPanel_MinMembersButton, "#COMMUNITY_MEMBERCOUNTFILTER_10000" )

}

void function PopupBackground_Activate( var button )
{
	// if this elements ran this callback, we could close the popup when you clicked outside of it
}

void function OnBrowseMembershipTypeButton_Activate( var button )
{
	if ( file.browseFilters.membershipType == "" )
		file.browseFilters.membershipType = "open";
	else if ( file.browseFilters.membershipType == "open" )
		file.browseFilters.membershipType = "invite";
	else if ( file.browseFilters.membershipType == "invite" )
		file.browseFilters.membershipType = "";

	file.browseFilters.pageNum = 0
	FillInBrowseFilters( file.browseFilters )
	UpdateBrowseFilters( file.browseFilters )
}

void function Browse_ChangeCommunityType_Activate( var button )
{
	if ( file.browseFilters.communityType == "social" )
		file.browseFilters.communityType = "competitive"
	else if ( file.browseFilters.communityType == "competitive" )
		file.browseFilters.communityType = ""
	else
		file.browseFilters.communityType = "social"

	file.browseFilters.pageNum = 0
	FillInBrowseFilters( file.browseFilters )
	UpdateBrowseFilters( file.browseFilters )
}

void function Browse_ChangeCommunityMembership_Activate( var button )
{
	if ( file.browseFilters.membershipType == "invite" )
		file.browseFilters.membershipType = "open"
	else if ( file.browseFilters.membershipType == "open" )
		file.browseFilters.membershipType = ""
	else
		file.browseFilters.membershipType = "invite"

	file.browseFilters.pageNum = 0
	FillInBrowseFilters( file.browseFilters )
	UpdateBrowseFilters( file.browseFilters )
}

void function Browse_ChangeCommunityCategory_Activate( var button )
{
	if ( file.browseFilters.category == "gaming" )
		file.browseFilters.category = "lifestyle"
	else if ( file.browseFilters.category == "lifestyle" )
		file.browseFilters.category = "geography"
	else if ( file.browseFilters.category == "geography" )
		file.browseFilters.category = "tech"
	else if ( file.browseFilters.category == "tech" )
		file.browseFilters.category = "other"
	else if ( file.browseFilters.category == "other" )
		file.browseFilters.category = ""
	else
		file.browseFilters.category = "gaming"

	file.browseFilters.pageNum = 0
	FillInBrowseFilters( file.browseFilters )
	UpdateBrowseFilters( file.browseFilters )
}

void function Browse_ChangeCommunityPlaytime_Activate( var button )
{
	if ( file.browseFilters.playtime == "morning" )
		file.browseFilters.playtime = "afternoon"
	else if ( file.browseFilters.playtime == "afternoon" )
		file.browseFilters.playtime = "evening"
	else if ( file.browseFilters.playtime == "evening" )
		file.browseFilters.playtime = "night"
	else if ( file.browseFilters.playtime == "night" )
		file.browseFilters.playtime = ""
	else
		file.browseFilters.playtime = "morning"

	file.browseFilters.pageNum = 0
	FillInBrowseFilters( file.browseFilters )
	UpdateBrowseFilters( file.browseFilters )
}

void function Browse_ChangeCommunityMicPolicy_Activate( var button )
{
	if ( file.browseFilters.micPolicy == "nopref" )
		file.browseFilters.micPolicy = "yes";
	else if ( file.browseFilters.micPolicy == "yes" )
		file.browseFilters.micPolicy = "no";
	else if ( file.browseFilters.micPolicy == "no" )
		file.browseFilters.micPolicy = "";
	else if ( file.browseFilters.micPolicy == "" )
		file.browseFilters.micPolicy = "nopref";

	file.browseFilters.pageNum = 0
	FillInBrowseFilters( file.browseFilters )
	UpdateBrowseFilters( file.browseFilters )
}

void function Browse_ChangeCommunityMinMembers_Activate( var button )
{
	if ( file.browseFilters.minMembers <= 1 )
		file.browseFilters.minMembers = 2;
	else if ( file.browseFilters.minMembers == 2 )
		file.browseFilters.minMembers = 10;
	else if ( file.browseFilters.minMembers == 10 )
		file.browseFilters.minMembers = 100;
	else if ( file.browseFilters.minMembers == 100 )
		file.browseFilters.minMembers = 1000;
	else if ( file.browseFilters.minMembers == 1000 )
		file.browseFilters.minMembers = 10000;
	else if ( file.browseFilters.minMembers == 10000 )
		file.browseFilters.minMembers = 1;

	file.browseFilters.pageNum = 0
	FillInBrowseFilters( file.browseFilters )
	UpdateBrowseFilters( file.browseFilters )
}

void function Browse_CommunityNameChanged( var textInput )
{
	file.browseFilters.name = Hud_GetUTF8Text( file.browseCommunitiesPanel_NameWidget )
	file.browseFilters.pageNum = 0
	UpdateBrowseFilters( file.browseFilters )
}

void function Browse_CommunityClantagChanged( var textInput )
{
	file.browseFilters.clantag = Hud_GetUTF8Text( file.browseCommunitiesPanel_ClantagWidget )
	file.browseFilters.pageNum = 0
	UpdateBrowseFilters( file.browseFilters )
}

void function OnEditCommunityButton_Activate( var button )
{
	thread GetCommunitySettingsThread()

	Hud_SetText( file.editCommunityPanel_Header, "#MENUHEADER_COMMUNITY_EDIT" )
	Hud_SetText( file.editCommunityPanel_NameBigLabel, Hud_GetUTF8Text( file.editCommunityPanel_Name ) )
	Hud_Show( file.editCommunityPanel_NameBigLabel )
	Hud_Hide( file.editCommunityPanel_NameLabel )
	Hud_Hide( file.editCommunityPanel_Name )
	Hud_Hide( file.editCommunityPanel_CreateButton )
	Hud_Show( file.editCommunityPanel_SaveButton )
	AdvanceMenu( file.editCommunityMenu )
	Hud_SetFocused( file.editCommunityPanel_Clantag )
	file.communityEdited = false
}

void function FillInSendMessageUI()
{
	string stringName
	if ( file.sendCommunityMsg_expiration >= 24 )
		stringName = "#COMMUNITY_EXPIRES_" + (file.sendCommunityMsg_expiration/24) + "DAY";
	else
		stringName = "#COMMUNITY_EXPIRES_" + file.sendCommunityMsg_expiration + "HOUR";
	Hud_SetUTF8Text( file.sendCommunityMsgPanel_ExpirationButton, Localize( stringName ) );
}

void function OnCommunitySendMsg_Open()
{
	OnStartSendCommunityMessageButton_Activate( null )
}

void function OnStartSendCommunityMessageButton_Activate( var button )
{
	var communityName = GetCurrentCommunityName()
	expect string(communityName)
	Hud_SetUTF8Text( file.sendCommunityMsgPanel_CommunityName, Localize( communityName ) )
	Hud_SetUTF8Text( file.sendCommunityMsgPanel_MsgText, "" )
	FillInSendMessageUI()
	AdvanceMenu( file.sendCommunityMsgMenu )
	Hud_SetFocused( file.sendCommunityMsgPanel_MsgText )
}

int function RotateExpirationPreset( int currentValue )
{
	array<int> intervals = [1, 12, 24, 2*24, 3*24, 5*24, 7*24];

	for ( int i = 0; i < intervals.len()-1; i++ )
	{
		if ( intervals[i] == currentValue )
			return intervals[i+1];
	}
	return intervals[0];
}

void function OnChangeCommunityMessageExpirationButton_Activate( var button )
{
	file.sendCommunityMsg_expiration = RotateExpirationPreset( file.sendCommunityMsg_expiration )
	FillInSendMessageUI();
}

void function OnActualSendCommunityMessageButton_Activate( var button )
{
	DialogData dialogData
	dialogData.header = "#COMMUNITY_SEND_CONFIRM"

	AddDialogButton( dialogData, "#YES", OnActualSendCommunityMessageButton_Confirm )
	AddDialogButton( dialogData, "#NO" )

	dialogData.noChoiceWithNavigateBack = true
	OpenDialog( dialogData )
}

void function OnActualSendCommunityMessageButton_Confirm()
{
	CloseActiveMenu()
	Hud_SetFocused( file.sendMessageButton )

	EmitUISound( "Menu_Email_Sent" )

	string text = Hud_GetUTF8Text( file.sendCommunityMsgPanel_MsgText )
	BroadcastCommunityMessage( file.sendCommunityMsg_expiration, text )
}

void function OnViewPendingRequestButton_Activate( var button )
{
	if ( file.totalJoinRequests )
	{
		AdvanceMenu( file.adminViewPendingRequests )
		ClientCommand( "community_getPendingJoinRequest" )
		Hud_SetFocused( file.pendingJoinRequest_AcceptButton )
	}
}

void function OnCreateCommunityButton_Activate( var button )
{
	file.region = MyRegion()

	CommunitySettings settings
	Assert( settings.communityId == 0 )
	settings.visibility = "public"
	settings.membershipType = "open"
	settings.communityType = "social"
	settings.category = "gaming"
	settings.micPolicy = "nopref"
	for ( int i = 0; i < file.languages.len(); i++ )
	{
		if ( file.languages[i].tolower() == GetLanguage().tolower() )
		{
			settings.language1 = file.languages[i]
			break
		}
	}

	settings.region1 = file.region
	file.settings = settings
	file.haveSettings = true
	FillInCommunitySettingsPanel( file.settings )
	Hud_SetText( file.editCommunityPanel_Clantag, settings.clanTag )
	Hud_SetText( file.editCommunityPanel_Name, settings.name )
	Hud_SetText( file.editCommunityPanel_MOTD, settings.motd )

	AdvanceMenu( file.editCommunityMenu )
	Hud_SetEnabled(	file.editCommunityPanel_Name, true )

	Hud_Show( file.editCommunityPanel_CreateButton )
	Hud_Hide( file.editCommunityPanel_SaveButton )

	Hud_SetText( file.editCommunityPanel_Header, "#MENUHEADER_COMMUNITY_CREATE" )
	Hud_Show( file.editCommunityPanel_NameBigLabel )
	Hud_Show( file.editCommunityPanel_NameLabel )
	Hud_Hide( file.editCommunityPanel_NameBigLabel )
	Hud_Show( file.editCommunityPanel_Name )
	Hud_SetFocused( file.editCommunityPanel_Name )
}

void function OnLanguagesButton_Activate( var button )
{
	ShowCommunityPanel( file.editCommunityLanguagesPanel )

	file.inCommunityPanel = true
	file.temporaryPanels.append( file.editCommunityLanguagesPanel )
	SetLanguageButtons()
	file.lastButtonFocused = button

	Hud_SetFocused( file.editCommunityLanguagesPanel_LanguageButtons[0] )
}

void function SetLanguageButtons()
{
	int toggledCount = 0
	for ( int i = 0; i < file.languages.len(); i++ )
	{
		if ( file.languages[i].tolower() == GetLanguage().tolower() )
		{
			Hud_SetSelected( file.editCommunityLanguagesPanel_LanguageButtons[i], true )
			Hud_SetEnabled( file.editCommunityLanguagesPanel_LanguageButtons[i], false )
		}
		else if ( file.settings.language1 == file.languages[i] || file.settings.language2 == file.languages[i] || file.settings.language3 == file.languages[i] )
		{
			Hud_SetSelected( file.editCommunityLanguagesPanel_LanguageButtons[i], true )
			Hud_SetEnabled( file.editCommunityLanguagesPanel_LanguageButtons[i], true )
		}
		else
		{
			Hud_SetSelected( file.editCommunityLanguagesPanel_LanguageButtons[i], false )
			Hud_SetEnabled( file.editCommunityLanguagesPanel_LanguageButtons[i], true )
		}
	}

	UpdateComboSelectButtons( file.editCommunityLanguagesPanel_LanguageButtons, GetToggledLanguage( 2 ) != "" )
}

bool function HasRegionSelected( string region )
{
	// boy I with this was an array
	if ( file.settings.region1 == region || file.settings.region2 == region || file.settings.region3 == region || file.settings.region4 == region || file.settings.region5 == region )
		return true
	return false
}

void function SetRegionButtons()
{
	int toggledCount = 0
	for ( int i = 0; i < file.regions.len(); i++ )
	{
		if ( file.regions[i] == file.region )
		{
			Hud_SetSelected( file.editCommunityRegionsPanel_RegionButtons[i], true )
			Hud_SetEnabled( file.editCommunityRegionsPanel_RegionButtons[i], false )
		}
		else if ( HasRegionSelected( file.regions[i] ) )
		{
			Hud_SetSelected( file.editCommunityRegionsPanel_RegionButtons[i], true )
			Hud_SetEnabled( file.editCommunityRegionsPanel_RegionButtons[i], true )
		}
		else
		{
			Hud_SetSelected( file.editCommunityRegionsPanel_RegionButtons[i], false )
			Hud_SetEnabled( file.editCommunityRegionsPanel_RegionButtons[i], true )
		}
	}

	UpdateComboSelectButtons( file.editCommunityRegionsPanel_RegionButtons, GetToggledRegion( 2 ) != "" )
}

string function GetToggledLanguage( int index )
{
	int toggledCount = 0
	for ( int i = 0; i < file.languages.len(); i++ )
	{
		if ( Hud_IsSelected( file.editCommunityLanguagesPanel_LanguageButtons[i] ) )
		{
			if ( index == toggledCount )
			{
				var language = file.languages[i]
				expect string(language)
				return language;
			}
			toggledCount++
		}
	}
	return ""
}

void function OnSaveLanguagesButton_Activate( var button )
{
	HideAllPanels()
	Hud_SetFocused( file.editCommunityPanel_LanguagesButton )

	if ( !file.haveSettings )
		return

	file.settings.language1 = GetToggledLanguage( 0 )
	printt( "language1 is " + file.settings.language1 )
	file.settings.language2 = GetToggledLanguage( 1 )
	printt( "language2 is " + file.settings.language2 )
	file.settings.language3 = GetToggledLanguage( 2 )
	printt( "language3 is " + file.settings.language3 )

	FillInCommunitySettingsPanel( file.settings )
	file.communityEdited = true
}

string function GetToggledRegion( int index )
{
	int toggledCount = 0
	for ( int i = 0; i < file.regions.len(); i++ )
	{
		if ( Hud_IsSelected( file.editCommunityRegionsPanel_RegionButtons[i] ) )
		{
			if ( index == toggledCount )
			{
				var region = file.regions[i]
				expect string(region)
				return region;
			}
			toggledCount++
		}
	}
	return ""
}

void function ShowCommunityPanel( var panel )
{
	Hud_Show( file.editCommunityPanel_PopupBackground )
	file.temporaryPanels.append( file.editCommunityPanel_PopupBackground )

	if ( panel == file.editCommunityRegionsPanel )
		Hud_Show( file.editCommunityRegionsPanel )
	else
		Hud_Hide( file.editCommunityRegionsPanel )

	if ( panel == file.editCommunityLanguagesPanel )
		Hud_Show( file.editCommunityLanguagesPanel )
	else
		Hud_Hide( file.editCommunityLanguagesPanel )

	if ( panel == file.editCommunityCategoriesPanel )
		Hud_Show( file.editCommunityCategoriesPanel )
	else
		Hud_Hide( file.editCommunityCategoriesPanel )

	if ( panel == file.editCommunityHappyHourPanel )
		Hud_Show( file.editCommunityHappyHourPanel )
	else
		Hud_Hide( file.editCommunityHappyHourPanel )
}

void function OnRegionsButton_Activate( var button )
{
	ShowCommunityPanel( file.editCommunityRegionsPanel )

	file.inCommunityPanel = true
	file.temporaryPanels.append( file.editCommunityRegionsPanel )
	file.lastButtonFocused = button
	SetRegionButtons()

	Hud_SetFocused( file.editCommunityRegionsPanel_RegionButtons[0] )
}

void function OnSaveRegionsButton_Activate( var button )
{
	HideAllPanels()
	Hud_SetFocused( file.editCommunityPanel_RegionsButton )

	if ( !file.haveSettings )
		return

	file.settings.region1 = GetToggledRegion( 0 )
	printt( "region1 is " + file.settings.region1 )
	file.settings.region2 = GetToggledRegion( 1 )
	printt( "region2 is " + file.settings.region2 )
	file.settings.region3 = GetToggledRegion( 2 )
	printt( "region3 is " + file.settings.region3 )
	file.settings.region4 = GetToggledRegion( 3 )
	printt( "region4 is " + file.settings.region4 )
	file.settings.region5 = GetToggledRegion( 4 )
	printt( "region5 is " + file.settings.region5 )

	FillInCommunitySettingsPanel( file.settings )
	file.communityEdited = true
}

void function OnCategoriesButton_Activate( var button )
{
	ShowCommunityPanel( file.editCommunityCategoriesPanel )

	int toggledCount = 0
	for ( int i = 0; i < file.categories.len(); i++ )
	{
		if ( file.settings.category.tolower() == file.categories[i].tolower() )
			Hud_SetSelected( file.editCommunityCategoriesPanel_CategoryButtons[i], true )
		else
			Hud_SetSelected( file.editCommunityCategoriesPanel_CategoryButtons[i], false )
	}

	file.inCommunityPanel = true
	file.temporaryPanels.append( file.editCommunityCategoriesPanel )
	file.lastButtonFocused = button

	Hud_SetFocused( file.editCommunityCategoriesPanel_CategoryButtons[0] )
}

void function OnSaveCategoriesButton_Activate( var button )
{
	for ( int i = 0; i < file.categories.len(); i++ )
	{
		if ( file.editCommunityCategoriesPanel_CategoryButtons[i] == button )
		{
			file.settings.category = file.categories[i]
			break
		}
	}
	printt( "category is " + file.settings.category )
	HideAllPanels()
	Hud_SetFocused( file.editCommunityPanel_CategoriesButton )
	FillInCommunitySettingsPanel( file.settings )
	file.communityEdited = true
}

void function FillInCommunitySettingsPanel( CommunitySettings settings )
{
	string languages = Localize( ConvertKeyToLocalizedString( settings.language1 ) )
	if ( settings.language2 != "" )
		languages += ", " + Localize( ConvertKeyToLocalizedString( settings.language2 ) )
	if ( settings.language3 != "" )
		languages += ", " + Localize( ConvertKeyToLocalizedString( settings.language3 ) )

	Hud_SetText( file.editCommunityPanel_LanguagesButton, languages )

	string regions = settings.region1
	if ( settings.region2 != "" )
		regions += ", " + Localize( ConvertKeyToLocalizedString( settings.region2 ) )
	if ( settings.region3 != "" )
		regions += ", " + Localize( ConvertKeyToLocalizedString( settings.region3 ) )
	if ( settings.region4 != "" )
		regions += ", " + Localize( ConvertKeyToLocalizedString( settings.region4 ) )
	if ( settings.region5 != "" )
		regions += ", " + Localize( ConvertKeyToLocalizedString( settings.region5 ) )

	Hud_SetText( file.editCommunityPanel_RegionsButton, regions )

	if ( settings.communityType == "social" )
		Hud_SetText( file.editCommunityPanel_CommunityTypeButton, "#COMMUNITY_SOCIAL" )
	else
		Hud_SetText( file.editCommunityPanel_CommunityTypeButton, "#COMMUNITY_COMPETITIVE" )

	if ( settings.micPolicy == "nopref" )
		Hud_SetText( file.editCommunityPanel_MicPolicyButton, "#COMMUNITY_MICS_NOPREF" )
	else if ( settings.micPolicy == "yes" )
		Hud_SetText( file.editCommunityPanel_MicPolicyButton, "#COMMUNITY_MICS_YES" )
	else
		Hud_SetText( file.editCommunityPanel_MicPolicyButton, "#COMMUNITY_MICS_NO" )

	if ( settings.visibility == "public" )
		Hud_SetText( file.editCommunityPanel_VisibilityButton, "#COMMUNITY_VISIBILITY_PUBLIC" )
	else
		Hud_SetText( file.editCommunityPanel_VisibilityButton, "#COMMUNITY_VISIBILITY_PRIVATE" )

	if ( settings.membershipType == "invite" )
		Hud_SetText( file.editCommunityPanel_MembershipTypeButton, "#COMMUNITY_MEMBERSHIP_INVITEONLY" )
	else
		Hud_SetText( file.editCommunityPanel_MembershipTypeButton, "#COMMUNITY_MEMBERSHIP_OPEN" )

	printt( "setting category to " + settings.category )
	if ( settings.category == "gaming" )
		Hud_SetText( file.editCommunityPanel_CategoriesButton, "#COMMUNITY_CATEGORY_GAMING" )
	else if ( settings.category == "lifestyle" )
		Hud_SetText( file.editCommunityPanel_CategoriesButton, "#COMMUNITY_CATEGORY_LIFESTYLE" )
	else if ( settings.category == "geography" )
		Hud_SetText( file.editCommunityPanel_CategoriesButton, "#COMMUNITY_CATEGORY_GEOGRAPHY" )
	else if ( settings.category == "tech" )
		Hud_SetText( file.editCommunityPanel_CategoriesButton, "#COMMUNITY_CATEGORY_TECH" )
	else if ( settings.category == "other" )
		Hud_SetText( file.editCommunityPanel_CategoriesButton, "#COMMUNITY_CATEGORY_OTHER" )

	SetRegionButtons()
	SetLanguageButtons()

	printt( "happyHourStart: " + settings.happyHourStart )
	string happyHourString = "#COMMUNITY_HAPPYHOUR_" + settings.happyHourStart
	printt( "happy hour is " + happyHourString )
	Hud_SetText( file.editCommunityPanel_HappyHourStartButton, happyHourString )
}

void function OnMembershipTypeButton_Activate( var button )
{
	if ( !file.haveSettings )
		return

	if ( file.settings.membershipType == "invite" )
		file.settings.membershipType = "open";
	else
		file.settings.membershipType = "invite";

	FillInCommunitySettingsPanel( file.settings )
	file.communityEdited = true
}

void function OnMicPolicyButton_Activate( var button )
{
	if ( !file.haveSettings )
		return

	if ( file.settings.micPolicy == "nopref" )
		file.settings.micPolicy = "yes";
	else if ( file.settings.micPolicy == "yes" )
		file.settings.micPolicy = "no";
	else
		file.settings.micPolicy = "nopref";

	FillInCommunitySettingsPanel( file.settings )
	file.communityEdited = true
}

void function OnVisibilityButton_Activate( var button )
{
	if ( !file.haveSettings )
		return

	if ( file.settings.visibility == "public" )
		file.settings.visibility = "private";
	else
		file.settings.visibility = "public";

	FillInCommunitySettingsPanel( file.settings )
	file.communityEdited = true
}

void function OnCommunityTypeButton_Activate( var button )
{
	if ( !file.haveSettings )
		return

	if ( file.settings.communityType == "social" )
		file.settings.communityType = "competitive";
	else
		file.settings.communityType = "social";

	FillInCommunitySettingsPanel( file.settings )
	file.communityEdited = true
	file.communityEdited = true
}

void function OnHappyHourButton_Activate( var button )
{
	HideAllPanels()
	// Hud_Hide( file.editCommunityCategoriesPanel )
	// Hud_Hide( file.editCommunityLanguagesPanel )
	// Hud_Hide( file.editCommunityRegionsPanel )
	// Hud_Show( file.editCommunityHappyHourPanel )
	// Hud_SetFocused( file.editCommunityHappyHourPanel_HappyHourButtons[0] )

	// file.inCommunityPanel = true
	// file.temporaryPanels.append( file.editCommunityHappyHourPanel )
	// file.lastButtonFocused = button

	OnHappyHourNext( button )
	file.communityEdited = true
}

void function OnHappyHourPrev( var button )
{
	file.settings.happyHourStart = (file.settings.happyHourStart-1+24)%24
	SetHappyHour( file.settings.happyHourStart )

	if ( Hud_GetHudName( button ) == "HappyHourLeftHidden" || Hud_GetHudName( button ) == "HappyHourRightHidden" )
		Hud_SetFocused( file.editCommunityPanel_HappyHourStartButton )
}

void function OnHappyHourNext( var button )
{
	file.settings.happyHourStart = (file.settings.happyHourStart+1)%24
	SetHappyHour( file.settings.happyHourStart )

	if ( Hud_GetHudName( button ) == "HappyHourLeftHidden" || Hud_GetHudName( button ) == "HappyHourRightHidden" )
		Hud_SetFocused( file.editCommunityPanel_HappyHourStartButton )
}

void function SetHappyHour( int startTime )
{
	if ( !file.haveSettings )
		return

	file.settings.happyHourStart = startTime

	HideAllPanels()
	// Hud_SetFocused( file.editCommunityPanel_HappyHourStartButton )

	FillInCommunitySettingsPanel( file.settings )
}

void function OnHappyHour0Button_Activate( var button )
{
	SetHappyHour( 0 )
}

void function OnHappyHour1Button_Activate( var button )
{
	SetHappyHour( 1 )
}

void function OnHappyHour2Button_Activate( var button )
{
	SetHappyHour( 2 )
}

void function OnHappyHour3Button_Activate( var button )
{
	SetHappyHour( 3 )
}

void function OnHappyHour4Button_Activate( var button )
{
	SetHappyHour( 4 )
}

void function OnHappyHour5Button_Activate( var button )
{
	SetHappyHour( 5 )
}

void function OnHappyHour6Button_Activate( var button )
{
	SetHappyHour( 6 )
}

void function OnHappyHour7Button_Activate( var button )
{
	SetHappyHour( 7 )
}

void function OnHappyHour8Button_Activate( var button )
{
	SetHappyHour( 8 )
}

void function OnHappyHour9Button_Activate( var button )
{
	SetHappyHour( 9 )
}

void function OnHappyHour10Button_Activate( var button )
{
	SetHappyHour( 10 )
}

void function OnHappyHour11Button_Activate( var button )
{
	SetHappyHour( 11 )
}

void function OnHappyHour12Button_Activate( var button )
{
	SetHappyHour( 12 )
}

void function OnHappyHour13Button_Activate( var button )
{
	SetHappyHour( 13 )
}

void function OnHappyHour14Button_Activate( var button )
{
	SetHappyHour( 14 )
}

void function OnHappyHour15Button_Activate( var button )
{
	SetHappyHour( 15 )
}

void function OnHappyHour16Button_Activate( var button )
{
	SetHappyHour( 16 )
}

void function OnHappyHour17Button_Activate( var button )
{
	SetHappyHour( 17 )
}

void function OnHappyHour18Button_Activate( var button )
{
	SetHappyHour( 18 )
}

void function OnHappyHour19Button_Activate( var button )
{
	SetHappyHour( 19 )
}

void function OnHappyHour20Button_Activate( var button )
{
	SetHappyHour( 20 )
}

void function OnHappyHour21Button_Activate( var button )
{
	SetHappyHour( 21 )
}

void function OnHappyHour22Button_Activate( var button )
{
	SetHappyHour( 22 )
}

void function OnHappyHour23Button_Activate( var button )
{
	SetHappyHour( 23 )
}

void function UICodeCallback_CommunitySaved( int communityId )
{
	printt( "communityId " + communityId + " saved successfully" );
	CloseActiveMenu()
	HideAllPanels()

	Hud_SetFocused( file.editButton )
	thread GetCommunityInfoThread( communityId )
	file.communityEdited = false
}

void function UICodeCallback_CommunitySaveFailed( int communityId )
{
	printt( "communityId " + communityId + " failed to saved successfully" );
}

void function OnSaveCommunityButton_Activate( var button )
{
	if ( !file.haveSettings )
		return

	file.settings.name = Hud_GetUTF8Text( file.editCommunityPanel_Name )
	file.settings.clanTag = Hud_GetUTF8Text( file.editCommunityPanel_Clantag )
	file.settings.motd = Hud_GetUTF8Text( file.editCommunityPanel_MOTD )

	SaveCommunitySettings( file.settings )
	ClientCommand( "recheck" )
}

void function GetCommunitySettingsThread()
{
	while ( true )
	{
		if ( GetCurrentCommunityId() < 0 )
		{
			WaitFrameOrUntilLevelLoaded()
			continue
		}

		CommunitySettings ornull settings = GetCommunitySettings( GetCurrentCommunityId() )
		if ( !settings )
		{
			file.haveSettings = false
			wait 0.05
		}
		else
		{
			file.haveSettings = true
			expect CommunitySettings( settings )
			file.settings = settings

			Hud_SetText( file.editCommunityPanel_Clantag, settings.clanTag )
			Hud_SetText( file.editCommunityPanel_Name, settings.name )
			Hud_SetText( file.editCommunityPanel_MOTD, settings.motd )
			FillInCommunitySettingsPanel( file.settings )
			break
		}
	}
}

void function Community_CommunityUpdated()
{
	if ( !file.firstCommunityUpdateHappened )
		file.firstCommunityUpdateHappened = true

	int currentCommunityId = GetCurrentCommunityId()
	bool currentCommunityChanged = file.currentCommunityId != currentCommunityId
	file.currentCommunityId = currentCommunityId

	CommunitySettings ornull settings = GetCommunitySettings( currentCommunityId )
	if ( settings != null ) // if you are not on the advocate network then you joined a new network
	{
		expect CommunitySettings( settings )
		if ( currentCommunityId != ADVOCATE_NETWORK )
			ScriptCallback_UnlockAchievement( achievements.JOIN_NETWORK )
	}

	if ( currentCommunityChanged && InPendingOpenInvite() )
		ClientCommand( "leaveopeninvite" )

	string membershipLevel = GetCurrentCommunityMembershipLevel()

	// printt( "setting up community ui - you are " + membershipLevel + " of this community" );
	SetButtonRuiText( file.sendMessageButton, Localize( "#COMMUNITY_MESSAGE_SENDMESSAGE", GetCurrentCommunityName() ) )
	bool owner = membershipLevel == "owner"
	bool admin = owner || membershipLevel == "admin"
	Hud_SetEnabled( file.sendMessageButton, admin )
	Hud_SetEnabled( file.adminViewPendingRequestsButton, admin )

	if ( admin && file.totalJoinRequests )
	{
		Hud_Show( file.adminViewPendingRequestsButton )
	}
	else
	{
		Hud_Hide( file.adminViewPendingRequestsButton )
	}

	Hud_SetEnabled( file.editButton, owner )

	if ( owner )
		Hud_Show( file.editButton )
	else
		Hud_Hide( file.editButton )

	if ( admin )
	{
		Hud_Show( file.sendButton )
		Hud_Show( file.sendMessageButton )
	}
	else
	{
		Hud_Hide( file.sendButton )
	}

	Hud_SetEnabled( file.chatroomToggleVoiceModeButton0, admin )
	Hud_SetEnabled( file.chatroomToggleVoiceModeButton1, admin )
	if ( !file.inCommunityPanel )
	{
		UpdateChatroomToggleVis( admin )
	}

	UpdateChatroomToggleText()

	ComboButtons_ResetColumnFocus( file.networksComboStruct )
	UpdateChatroomUI()
	//UpdateArmoryMenu( admin, owner )
}

void function UpdateChatroomToggleVis( bool admin )
{
	if ( admin )
	{
		Hud_Show( file.chatroomToggleVoiceModeButton0 )
		Hud_Show( file.chatroomToggleVoiceModeButton1 )
		Hud_Show( file.chatroomToggleVoiceModeHeader )
	}
	else
	{
		Hud_Hide( file.chatroomToggleVoiceModeButton0 )
		Hud_Hide( file.chatroomToggleVoiceModeButton1 )
		Hud_Hide( file.chatroomToggleVoiceModeHeader )
	}
}

void function UpdateChatroomToggleText( int currentVoiceMode = -1 )
{
	if ( currentVoiceMode == -1 )
		currentVoiceMode = GetConVarInt( "chatroom_voiceMode" )
	if ( currentVoiceMode == 0 )
	{
		ComboButton_SetText( file.chatroomToggleVoiceModeButton0, Localize( "#MENU_TITLE_CHATROOM_SELECTED", Localize( "#MENU_TITLE_CHATROOM_FREETALK" ) ) )
		ComboButton_SetText( file.chatroomToggleVoiceModeButton1, Localize( "#MENU_TITLE_CHATROOM_ADMINSONLY" ) )
	}
	else
	{
		ComboButton_SetText( file.chatroomToggleVoiceModeButton0, Localize( "#MENU_TITLE_CHATROOM_FREETALK" ) )
		ComboButton_SetText( file.chatroomToggleVoiceModeButton1, Localize( "#MENU_TITLE_CHATROOM_SELECTED", Localize( "#MENU_TITLE_CHATROOM_ADMINSONLY" ) ) )
	}
}

void function GetCommunityInfoThread( int communityId )
{
	EndSignal( uiGlobal.signalDummy, "StopCommunityLookups" )

	wait 0.3

	printt( "getting info on community " + communityId )

	CommunitySettings fakeSettings
	fakeSettings.name = Localize( "#COMMUNITY_FETCHING" )
	FillInCommunityInfoPanel( fakeSettings, file.myCommunityInfoPanelWidgets )
	FillInCommunityInfoPanel( fakeSettings, file.communityInfoPanelWidgets )
	file.communityInfoPanelWidgets.CommunityId = 0
	file.myCommunityInfoPanelWidgets.CommunityId = 0

	while ( true )
	{
		CommunitySettings ornull settings = GetCommunitySettings( communityId )
		if ( !settings )
		{
			wait 0.05
		}
		else
		{
			expect CommunitySettings( settings )
			if ( settings.doneResolving )
				printt( "Got fully resolved community info/settings for community " + communityId )

			file.communityInfoPanelWidgets.CommunityId = communityId
			file.myCommunityInfoPanelWidgets.CommunityId = communityId
			FillInCommunityInfoPanel( settings, file.myCommunityInfoPanelWidgets )
			FillInCommunityInfoPanel( settings, file.communityInfoPanelWidgets )

			if ( settings.doneResolving )
				return
			wait 0.05
		}
	}
}

void function UICodeCallback_ShowCommunityInfo( int communityId )
{
	printt( "Showing community info for communityId " + communityId )

	Signal( uiGlobal.signalDummy, "StopCommunityLookups" )
	thread GetCommunityInfoThread( communityId )
}

void function LeaveCommunityButton_Activate( var button )
{
	DialogData dialogData
	CommunitySettings ornull settings = GetCommunitySettings( file.communityInfoPanelWidgets.CommunityId )

	if ( settings == null )
		return

	expect CommunitySettings( settings )

	string name = settings.name
	dialogData.header = Localize( "#REALLY_LEAVE_COMMUNITY", name )

	AddDialogButton( dialogData, "#YES", LeaveCommunityDialog )
	AddDialogButton( dialogData, "#NO" )

	dialogData.noChoiceWithNavigateBack = true
	OpenDialog( dialogData )
}

void function LeaveCommunityDialog()
{
	if ( AreWeInCommunity( file.communityInfoPanelWidgets.CommunityId ) )
		LeaveCommunity( file.communityInfoPanelWidgets.CommunityId )
}


void function LeaveCurrentCommunityButton_Activate( var button )
{
	DialogData dialogData
	CommunitySettings ornull settings = GetCommunitySettings( GetCurrentCommunityId() )

	if ( settings == null )
		return

	expect CommunitySettings( settings )

	string name = settings.name
	dialogData.header = Localize( "#REALLY_LEAVE_COMMUNITY", name )

	AddDialogButton( dialogData, "#YES", LeaveCurrentCommunityDialog )
	AddDialogButton( dialogData, "#NO" )

	dialogData.noChoiceWithNavigateBack = true
	OpenDialog( dialogData )
}

void function LeaveCurrentCommunityDialog()
{
	if ( AreWeInCommunity( GetCurrentCommunityId() ) )
		LeaveCommunity( GetCurrentCommunityId() )
}

void function UICodeCallback_ShowCommunityJoinRequest( int communityId, int totalRemainingRequests, string requesterUID, string requesterHardware )
{
	printt( totalRemainingRequests + " total requests left to answer" )
	file.totalJoinRequests = totalRemainingRequests

	Signal( uiGlobal.signalDummy, "StopUserJoinRequestLookups" )
	if ( !totalRemainingRequests )
	{
		if ( Hud_IsVisible( file.adminViewPendingRequests ) )
			CloseActiveMenu()
	}
	else
	{
		if ( requesterUID != "0" )
			thread GetPendingJoinUserInfoThread( communityId, requesterHardware, requesterUID )
	}
}

void function JoinRequest_Accept( var button )
{
	Signal( uiGlobal.signalDummy, "StopUserJoinRequestLookups" )
	ClientCommand( "community_getPendingJoinRequest 1" )
}

void function JoinRequest_Deny( var button )
{
	Signal( uiGlobal.signalDummy, "StopUserJoinRequestLookups" )
	ClientCommand( "community_getPendingJoinRequest 0" )
}


void function GetPendingJoinUserInfoThread( int communityId, string hardware, string userId )
{
	EndSignal( uiGlobal.signalDummy, "StopUserJoinRequestLookups" )
	printt( "pendingJoin getting userinfo for user " + userId )

	CommunityUserInfo fakeSettings
	fakeSettings.name =  Localize( "#COMMUNITY_FETCHING" )
	FillInUserInfoPanel( file.pendingJoinRequestPanel, fakeSettings )

	while ( true )
	{
		CommunitySettings ornull settings = GetCommunitySettings( communityId )
		CommunityUserInfo ornull userInfo = GetCommunityUserInfo( hardware, userId )

		if ( !userInfo || !settings )
		{
			printt( "pendingJoin asking for userinfo for " + hardware + "=" + userId )
			wait 0.05
		}
		else
		{
			printt( "Got user info for user " + userId + " on hardware " + hardware )
			expect CommunityUserInfo( userInfo )
			expect CommunitySettings( settings )

			printt( "User " + userId + " is in " + userInfo.numCommunities + " communities" )

			FillInUserInfoPanel( file.pendingJoinRequestPanel, userInfo )

			string title
			if ( settings.communityId )
				title = "[" + settings.clanTag + "] " + settings.name;
			else
				title = settings.name;
			Hud_SetText( file.pendingJoinRequest_CommunityName, title )
			break
		}
	}
}

void function FillInCommunityInfoPanel( CommunitySettings settings, CommunityPanel communityPanel )
{
	string title
	if ( settings.communityId )
		title = "[" + settings.clanTag + "] " + settings.name;
	else
		title = settings.name;

	if ( communityPanel.Name != null )
		Hud_SetText( communityPanel.Name, title )

	if ( communityPanel.CommunityNameRui != null )
		SetLabelRuiText( communityPanel.CommunityNameRui, Localize( "#COMMUNITY_CHATROOM", title ) )

	Hud_SetText( communityPanel.Creator, settings.creatorName )
	string memberCountText = "" + settings.memberCount;
	Hud_SetText( communityPanel.Members, memberCountText )
	Hud_SetText( communityPanel.MOTD, settings.motd )
	string killsText = "" + settings.kills
	Hud_SetText( communityPanel.Kills, killsText )
	string winsText = "" + settings.wins
	Hud_SetText( communityPanel.Wins, winsText )
	string lossesText = "" + settings.losses
	Hud_SetText( communityPanel.Losses, lossesText )
	string deathsText = "" + settings.deaths
	Hud_SetText( communityPanel.Deaths, deathsText )
	string xpText = ShortenNumber( settings.xp )
	Hud_SetText( communityPanel.XP, xpText )

	string languages = Localize( ConvertKeyToLocalizedString( settings.language1 ) )
	if ( settings.language2 != "" )
		languages += ", " + Localize( ConvertKeyToLocalizedString( settings.language2 ) )
	if ( settings.language3 != "" )
		languages += ", " + Localize( ConvertKeyToLocalizedString( settings.language3 ) )

	Hud_SetText( communityPanel.LanguagesLabel, languages )

	string regions = Localize( ConvertKeyToLocalizedString( settings.region1 ) )
	if ( settings.region2 != "" )
		regions += ", " + Localize( ConvertKeyToLocalizedString( settings.region2 ) )
	if ( settings.region3 != "" )
		regions += ", " + Localize( ConvertKeyToLocalizedString( settings.region3 ) )

	Hud_SetText( communityPanel.RegionsLabel, regions )

	if ( settings.communityType == "social" )
		Hud_SetText( communityPanel.CommunityTypeLabel, "#COMMUNITY_SOCIAL" )
	else
		Hud_SetText( communityPanel.CommunityTypeLabel, "#COMMUNITY_COMPETITIVE" )

	if ( settings.micPolicy == "nopref" )
		Hud_SetText( communityPanel.MicPolicyLabel, "#COMMUNITY_MICS_NOPREF" )
	else if ( settings.micPolicy == "yes" )
		Hud_SetText( communityPanel.MicPolicyLabel, "#COMMUNITY_MICS_YES" )
	else
		Hud_SetText( communityPanel.MicPolicyLabel, "#COMMUNITY_MICS_NO" )

	if ( settings.visibility == "public" )
		Hud_SetText( communityPanel.VisibilityLabel, "#COMMUNITY_VISIBILITY_PUBLIC" )
	else
		Hud_SetText( communityPanel.VisibilityLabel, "#COMMUNITY_VISIBILITY_PRIVATE" )

	if ( settings.membershipType == "invite" )
		Hud_SetText( communityPanel.MembershipTypeLabel, "#COMMUNITY_MEMBERSHIP_INVITEONLY" )
	else
		Hud_SetText( communityPanel.MembershipTypeLabel, "#COMMUNITY_MEMBERSHIP_OPEN" )

	// printt( "setting category to " + settings.category )
	if ( settings.category == "gaming" )
		Hud_SetText( communityPanel.CategoriesLabel, "#COMMUNITY_CATEGORY_GAMING" )
	else if ( settings.category == "lifestyle" )
		Hud_SetText( communityPanel.CategoriesLabel, "#COMMUNITY_CATEGORY_LIFESTYLE" )
	else if ( settings.category == "geography" )
		Hud_SetText( communityPanel.CategoriesLabel, "#COMMUNITY_CATEGORY_GEOGRAPHY" )
	else if ( settings.category == "tech" )
		Hud_SetText( communityPanel.CategoriesLabel, "#COMMUNITY_CATEGORY_TECH" )
	else if ( settings.category == "other" )
		Hud_SetText( communityPanel.CategoriesLabel, "#COMMUNITY_CATEGORY_OTHER" )

	string happyHourString = "#COMMUNITY_HAPPYHOUR_" + settings.happyHourStart
	Hud_SetText( communityPanel.HappyHourStartLabel, happyHourString )

	/*
		if ( !settings.communityId )
		{
			Hud_Hide( communityPanel.JoinButton )
			Hud_Hide( communityPanel.LeaveButton )
		}
		else if ( AreWeInCommunity( settings.communityId ) )
		{
			Hud_Hide( communityPanel.JoinButton )
			Hud_Show( communityPanel.LeaveButton )
			Hud_Show( communityPanel.SetActiveButton )
			Hud_SetFocused( communityPanel.CloseButton )
		}
		else
		{
			Hud_Show( communityPanel.JoinButton )
			Hud_Hide( communityPanel.LeaveButton )
			Hud_Hide( communityPanel.SetActiveButton )
			Hud_SetFocused( communityPanel.CloseButton )
			// Hud_SetFocused( communityPanel.JoinButton )
		}
	*/
}

bool function ListCommunitiesPanelHasFocus()
{
	return file.inCommunityPanel
}

void function MyCommunities_OnGetFocus( var list )
{
	printt( "MyCommunities_OnGetFocus" )
	if ( !file.inCommunityPanel )
	{
		file.inCommunityPanel = true
		// Hud_Show( file.switchCommunityPanelCover )
		foreach ( button in file.switchCommunityPanelButtons )
		{
			Hud_Hide( button )
		}
		foreach ( button in file.switchCommunityPanelHints )
		{
			Hud_Show( button )
		}
	}
}

void function MyCommunities_OnLoseFocus( var list )
{
	Signal( uiGlobal.signalDummy, "StopCommunityLookups" )
	printt( "MyCommunities_OnLoseFocus" )
	if ( file.inCommunityPanel )
	{
		file.inCommunityPanel = false
		// Hud_Hide( file.switchCommunityPanelCover )
		foreach ( button in file.switchCommunityPanelButtons )
		{
			Hud_Show( button )
		}
		foreach ( button in file.switchCommunityPanelHints )
		{
			Hud_Hide( button )
		}

		Community_CommunityUpdated()
	}
}

void function MyCommunities_OnChange( var list )
{
	string itemName = Hud_GetListPanelSelectedItem( file.switchCommunityPanel_ListWidget )
	Assert( IsValid( itemName ) )
	if ( itemName == "" )
		return
	int communityId = int( itemName )
	printt( "Showing community info for communityId " + communityId )
	Signal( uiGlobal.signalDummy, "StopCommunityLookups" )
	thread GetCommunityInfoThread( communityId )
}

void function SetActiveCommunity_Thread( int communityId )
{
	Signal( uiGlobal.signalDummy, "StopCommunityLookups" )
	EndSignal( uiGlobal.signalDummy, "StopCommunityLookups" )

	DialogData dialogData
	CommunitySettings ornull settings = GetCommunitySettings( communityId )

	while ( settings == null )
	{
		wait 0.05
		settings = GetCommunitySettings( communityId )
	}

	expect CommunitySettings( settings )

	string name = settings.name
	dialogData.header = Localize( "#REALLY_SET_ACTIVE_COMMUNITY", name )
	dialogData.message = "#REALLY_SET_ACTIVE_COMMUNITY_SUB"


	AddDialogButton( dialogData, "#YES", MyCommunities_SetActive )
	AddDialogButton( dialogData, "#NO" )

	dialogData.noChoiceWithNavigateBack = true
	OpenDialog( dialogData )
}

void function MyCommunities_OnSelect( var list )
{
	string itemName = Hud_GetListPanelSelectedItem( file.switchCommunityPanel_ListWidget )
	Assert( IsValid( itemName ) )
	if ( itemName == "" )
		return
	int communityId = int( itemName )

	thread SetActiveCommunity_Thread( communityId )
}

void function MyCommunities_SetActive()
{
	string itemName = Hud_GetListPanelSelectedItem( file.switchCommunityPanel_ListWidget )
	Assert( IsValid( itemName ) )
	if ( itemName == "" || itemName == "next" || itemName == "prev" )
		return
	int communityId = int( itemName )
	printt( "they selected community" + communityId )
	SetActiveCommunity( communityId )
	// file.inCommunityPanel = false
	Hud_SetFocused( file.selectNetWorkbutton )
	EmitUISound( "Menu.Accept" )
	Community_CommunityUpdated()
}

bool function BrowseCommunities_ListWasFocused()
{
	if ( file.browseCommunitiesPanel_LastFocused != file.browseCommunitiesPanel_ListWidget )
		return false

	string itemName = Hud_GetListPanelSelectedItem( file.browseCommunitiesPanel_ListWidget )
	Assert( IsValid( itemName ) )
	if ( itemName == "" )
		return false

	return true
}

bool function BrowseCommunities_ListNotFocused()
{
	return ( file.browseCommunitiesPanel_LastFocused != file.browseCommunitiesPanel_ListWidget )
}

void function BrowseCommunities_FilterGetFocus( var button )
{
	file.browseCommunitiesPanel_LastFocused = button

	//file.browseCommunitiesPanel_ViewDetailsButton

	//Hud_Show( file.browseCommunitiesPanel_FilterBackground )
	RuiSetColorAlpha( Hud_GetRui( file.browseCommunitiesPanel_FilterBackground ), "backgroundColor", <0, 0, 0>, 0.65 )
	Hud_Show( file.browseCommunitiesPanel_ViewDetailsButton )

	Hud_Hide( file.browseCommunitiesPanel_CommunityInfoPanel )
	foreach ( var hintElement in file.browseCommunitiesPanel_HintElements )
	{
		Hud_Show( hintElement )
	}

	foreach ( var filterElement in file.browseCommunitiesPanel_FilterElements )
	{
		//Hud_Show( filterElement )
		Hud_SetAlpha( filterElement, 255 )
	}
}

void function BrowseCommunities_ListGetFocus( var list )
{
	file.browseCommunitiesPanel_LastFocused = list

	//Hud_Hide( file.browseCommunitiesPanel_FilterBackground )
	RuiSetColorAlpha( Hud_GetRui( file.browseCommunitiesPanel_FilterBackground ), "backgroundColor", <0, 0, 0>, 0.25 )
	Hud_Hide( file.browseCommunitiesPanel_ViewDetailsButton )

	Hud_Show( file.browseCommunitiesPanel_CommunityInfoPanel )
	foreach ( var hintElement in file.browseCommunitiesPanel_HintElements )
	{
		Hud_Hide( hintElement )
	}

	foreach ( var filterElement in file.browseCommunitiesPanel_FilterElements )
	{
		Hud_SetAlpha( filterElement, 32 )
		//Hud_Hide( filterElement )
	}
}

void function BrowseCommunities_ListLoseFocus( var list )
{
	RuiSetColorAlpha( Hud_GetRui( file.browseCommunitiesPanel_FilterBackground ), "backgroundColor", <0, 0, 0>, 0.65 )
	Hud_Show( file.browseCommunitiesPanel_ViewDetailsButton )

	Hud_Hide( file.browseCommunitiesPanel_CommunityInfoPanel )
	foreach ( var hintElement in file.browseCommunitiesPanel_HintElements )
	{
		Hud_Show( hintElement )
	}

	foreach ( var filterElement in file.browseCommunitiesPanel_FilterElements )
	{
		//Hud_Show( filterElement )
		Hud_SetAlpha( filterElement, 255 )
	}
}

void function BrowseCommunities_OnViewDetails( var list )
{
	Hud_SetFocused( file.browseCommunitiesPanel_ListWidget )
}

void function BrowseCommunities_OnChange( var list )
{
	string itemName = Hud_GetListPanelSelectedItem( file.browseCommunitiesPanel_ListWidget )
	Assert( IsValid( itemName ) )
	if ( itemName == "" )
		return
	if ( itemName == "prev" )
	{
		if ( !IsBrowserFetchingMoreData() )
		{
			file.browseFilters.pageNum--
			printt( "asking for browse results, prev page " + file.browseFilters.pageNum );
			UpdateBrowseFilters( file.browseFilters )
		}
	}
	else if ( itemName == "next" )
	{
		if ( !IsBrowserFetchingMoreData() )
		{
			file.browseFilters.pageNum++
			printt( "asking for browse results, next page " + file.browseFilters.pageNum );
			UpdateBrowseFilters( file.browseFilters )
		}
	}
	else
	{
		if ( !IsBrowserFetchingMoreData() )
		{
			int communityId = int( itemName )
			printt( "Showing community info for communityId " + communityId + " (item " + itemName + " in list)" )
			Signal( uiGlobal.signalDummy, "StopCommunityLookups" )
			thread GetCommunityInfoThread( communityId )
		}
	}
	UpdateFooterOptions()
}

void function AskToJoinCommunity_Thread( int communityId )
{
	Signal( uiGlobal.signalDummy, "StopCommunityLookups" )
	EndSignal( uiGlobal.signalDummy, "StopCommunityLookups" )

	DialogData dialogData
	CommunitySettings ornull settings = GetCommunitySettings( communityId )

	while ( settings == null )
	{
		wait 0.05
		settings = GetCommunitySettings( communityId )
	}

	expect CommunitySettings( settings )

	string name = settings.name
	dialogData.header = Localize( "#REALLY_JOIN_COMMUNITY", name )

	if ( settings.membershipType == "invite" )
		dialogData.message = "#COMMUNITY_IS_INVITE_ONLY_WARNING"

	if ( settings.membershipType == "invite" )
		AddDialogButton( dialogData, "#YES_JOIN_COMMUNITY", BrowseCommunities_JoinCommunity )
	else
		AddDialogButton( dialogData, "#YES", BrowseCommunities_JoinCommunity )

	AddDialogButton( dialogData, "#NO" )

	dialogData.noChoiceWithNavigateBack = true
	OpenDialog( dialogData )
}

void function BrowseCommunities_OnSelect( var list )
{
	printt( "they selected a community!" )

	string itemName = Hud_GetListPanelSelectedItem( file.browseCommunitiesPanel_ListWidget )
	Assert( IsValid( itemName ) )
	if ( itemName == "" )
		return
	int communityId = int( itemName )

	thread AskToJoinCommunity_Thread( communityId )
}

void function BrowseCommunities_JoinCommunity()
{
	string itemName = Hud_GetListPanelSelectedItem( file.browseCommunitiesPanel_ListWidget )
	Assert( IsValid( itemName ) )
	if ( itemName == "" )
		return
	int communityId = int( itemName )
	if ( AreWeInCommunity( communityId ) )
	{
		SetActiveCommunity( communityId )
		CloseActiveMenu()
		return
	}

	thread JoinCommunityThread( communityId )
}

void function JoinCommunityThread( int communityId )
{
	Signal( uiGlobal.signalDummy, "StopJoinCommunity" )
	EndSignal( uiGlobal.signalDummy, "StopJoinCommunity" )

	printt( "they want to join community" + communityId )
	JoinCommunity( communityId )

	CommunitySettings ornull settings = GetCommunitySettings( communityId )
	while ( settings == null )
	{
		wait 0.05
		settings = GetCommunitySettings( communityId )
	}

	expect CommunitySettings( settings )

	if ( settings.membershipType != "invite" )
		return

	DialogData dialogData
	dialogData.header = Localize( "#COMMUNITY_JOIN_REQUEST_SENT" )
	dialogData.message = "#COMMUNITY_JOIN_REQUEST_SENT_DESC"
	//AddDialogButton( dialogData, "#OK", CloseActiveMenu() )
	AddDialogButton( dialogData, "#OK" )

	dialogData.noChoiceWithNavigateBack = true
	OpenDialog( dialogData )
}

void function BrowseCommunities_ReportAbuse_Final()
{
	if ( file.reportedCommunityIds.len() > 100 )
		return

	foreach ( communityId in file.reportedCommunityIds )
	{
		if ( communityId == file.reportAbuseCommunityId )
			return
	}
	file.reportedCommunityIds.append( file.reportAbuseCommunityId )
	ReportCommunity( file.reportAbuseCommunityId, 0 )
}

void function ReportAbuse_Thread( int communityId )
{
	Signal( uiGlobal.signalDummy, "StopAbuseReports" )
	EndSignal( uiGlobal.signalDummy, "StopAbuseReports" )

	DialogData dialogData
	CommunitySettings ornull settings = GetCommunitySettings( communityId )
	while ( settings == null )
	{
		wait 0.05
		settings = GetCommunitySettings( communityId )
	}

	expect CommunitySettings( settings )

	file.reportAbuseCommunityId = communityId

	string name = settings.name
	dialogData.header = Localize( "#REALLY_REPORT_ABUSE_HEADER", name )
	dialogData.message = Localize( "#REALLY_REPORT_ABUSE", name )

	AddDialogButton( dialogData, "#YES", BrowseCommunities_ReportAbuse_Final )
	AddDialogButton( dialogData, "#NO" )

	dialogData.noChoiceWithNavigateBack = true
	OpenDialog( dialogData )
}

void function ReportAbuse_OnClick( var button )
{
	EmitUISound( "Menu.Accept" )

	string itemName = Hud_GetListPanelSelectedItem( file.browseCommunitiesPanel_ListWidget )
	Assert( IsValid( itemName ) )
	if ( itemName == "" )
		return
	int communityId = int( itemName )
	thread ReportAbuse_Thread( communityId )
}

bool function CanReportAbuse()
{
	string itemName = Hud_GetListPanelSelectedItem( file.browseCommunitiesPanel_ListWidget )
	Assert( IsValid( itemName ) )
	if ( itemName == "" )
		return false
	int selectedCommunityId = int( itemName )
	// if ( AreWeInCommunity( selectedCommunityId ) )
	// 	return false

	if ( file.reportedCommunityIds.len() > 100 )
		return false

	foreach ( communityId in file.reportedCommunityIds )
	{
		if ( communityId == selectedCommunityId )
			return false
	}

	return true
}

void function JoinNetwork_OnClick( var button )
{
	EmitUISound( "Menu.Accept" )

	//string itemName = Hud_GetListPanelSelectedItem( file.browseCommunitiesPanel_ListWidget )
	//Assert( IsValid( itemName ) )
	//if ( itemName == "" )
	//	return
	//int communityId = int( itemName )
	//thread ReportAbuse_Thread( communityId )
}


bool function CanJoinNetwork()
{
	// JFS: this seems bad, but the footer function gets called before we are even in the menu
	if ( uiGlobal.activeMenu != file.browseCommunitiesMenu )
		return false

	if ( BrowseCommunities_ListNotFocused() )
		return false

	string itemName = Hud_GetListPanelSelectedItem( file.browseCommunitiesPanel_ListWidget )
	Assert( IsValid( itemName ) )
	if ( itemName == "" )
		return false
	int selectedCommunityId = int( itemName )

	if ( AreWeInCommunity( selectedCommunityId ) )
		return false

	return true
}

void function FindCommunityInfoWidgetsInPanel( CommunityPanel infostruct, var panel )
{
	if ( Hud_HasChild( panel, "CommunityName" ) )
		infostruct.Name = Hud_GetChild( panel, "CommunityName" )

	if ( Hud_HasChild( panel, "CommunityNameRui" ) )
		infostruct.CommunityNameRui = Hud_GetChild( panel, "CommunityNameRui" )

	infostruct.Creator = Hud_GetChild( panel, "CreatorName" )
	infostruct.Members = Hud_GetChild( panel, "ActiveMembers" )
	infostruct.MOTD = Hud_GetChild( panel, "MOTD" )
	infostruct.Kills = Hud_GetChild( panel, "Kills" )
	infostruct.Wins = Hud_GetChild( panel, "Wins" )
	infostruct.Losses = Hud_GetChild( panel, "Losses" )
	infostruct.Deaths = Hud_GetChild( panel, "Deaths" )
	infostruct.XP = Hud_GetChild( panel, "XP" )
	infostruct.CategoriesLabel = Hud_GetChild( panel, "Category" )
	infostruct.LanguagesLabel = Hud_GetChild( panel, "Languages" )
	infostruct.RegionsLabel = Hud_GetChild( panel, "Regions" )
	infostruct.CommunityTypeLabel = Hud_GetChild( panel, "CommunityType" )
	infostruct.MembershipTypeLabel = Hud_GetChild( panel, "MembershipPolicy" )
	infostruct.VisibilityLabel = Hud_GetChild( panel, "Visibility" )
	infostruct.MicPolicyLabel = Hud_GetChild( panel, "MicPolicy" )
	infostruct.HappyHourStartLabel = Hud_GetChild( panel, "HappyHourStart" )
}

void function InitCommunitiesMenu()
{
	RegisterSignal( "StopCommunityLookups" )
	RegisterSignal( "StopUserJoinRequestLookups" )
	RegisterSignal( "StopAbuseReports" )
	RegisterSignal( "StopJoinCommunity" )

	PrecacheHUDMaterial( $"ui/menu/main_menu/currently_selected" )
	PrecacheHUDMaterial( $"ui/menu/main_menu/verified_community" )

	var menu = GetMenu( "CommunitiesMenu" )
	file.menu = menu

	Chatroom_GlobalInit()
	InitChatroom( menu )

	InitCommunityKeys()

	/*
		file.chatroomMenu = Hud_GetChild( menu, "Chatroom" ) // GetMenu( "ChatRoom" )
		file.chatroomMenu_chatroomWidget = Hud_GetChild( file.chatroomMenu, "ChatRoom" )
	*/

	file.adminViewPendingRequests = GetMenu( "CommunityAdminInviteRequestMenu" )

	file.totalJoinRequests = 0
	file.pendingJoinRequestPanel.Panel = Hud_GetChild( file.adminViewPendingRequests, "JoinRequestPanel" )
	file.pendingJoinRequestPanel.Name = Hud_GetChild( file.pendingJoinRequestPanel.Panel, "Requester" )
	file.pendingJoinRequestPanel.Kills = Hud_GetChild( file.pendingJoinRequestPanel.Panel, "Kills" )
	file.pendingJoinRequestPanel.Wins = Hud_GetChild( file.pendingJoinRequestPanel.Panel, "Wins" )
	file.pendingJoinRequestPanel.Losses = Hud_GetChild( file.pendingJoinRequestPanel.Panel, "Losses" )
	file.pendingJoinRequestPanel.Deaths = Hud_GetChild( file.pendingJoinRequestPanel.Panel, "Deaths" )
	file.pendingJoinRequestPanel.XP = Hud_GetChild( file.pendingJoinRequestPanel.Panel, "XP" )
	file.pendingJoinRequestPanel.callsignCard = Hud_GetChild( file.pendingJoinRequestPanel.Panel, "CallsignCard" )
	file.pendingJoinRequest_AcceptButton = Hud_GetChild( file.pendingJoinRequestPanel.Panel, "AcceptRequestButton" )
	file.pendingJoinRequest_CommunityName = Hud_GetChild( file.pendingJoinRequestPanel.Panel, "CommunityName" )
	//file.pendingJoinRequestPanel.ViewUserCardButton = Hud_GetChild( file.pendingJoinRequestPanel.Panel, "ViewUserCard" )

	for ( int i = 0; ; i++ )
	{
		if ( !Hud_HasChild( file.pendingJoinRequestPanel.Panel, "Community" + i + "Label" ) )
			break;
		var communityLabel = Hud_GetChild( file.pendingJoinRequestPanel.Panel, "Community" + i + "Label" )
		var communityName = Hud_GetChild( file.pendingJoinRequestPanel.Panel, "Community" + i )
		Assert( communityName, "found Community" + i + "Label, but no Community" + i + " in pendingJoinRequestPanel panel" );
		file.pendingJoinRequestPanel.communityLabels.append( communityLabel )
		file.pendingJoinRequestPanel.communityNames.append( communityName )
	}

	AddEventHandlerToButton( file.pendingJoinRequestPanel.Panel, "AcceptRequestButton", UIE_CLICK, JoinRequest_Accept )
	AddEventHandlerToButton( file.pendingJoinRequestPanel.Panel, "DenyRequestButton", UIE_CLICK, JoinRequest_Deny )
	AddMenuFooterOption( file.adminViewPendingRequests, BUTTON_A, "#A_BUTTON_SELECT" )
	AddMenuFooterOption( file.adminViewPendingRequests, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )

	// BrowseFilters filters
	// file.browseFilters = filters
	file.browseFilters.name = ""
	file.browseFilters.clantag = ""
	file.browseFilters.communityType = "social"
	file.browseFilters.membershipType = "open"
	file.browseFilters.category = ""
	file.browseFilters.playtime = ""
	file.browseFilters.micPolicy = ""
	file.browseFilters.pageNum = 0
	file.browseFilters.minMembers = 1

	file.haveSettings = false
	file.firstCommunityUpdateHappened = false

	// file.editButton = Hud_GetChild( menu, "BtnEdit" )
	file.sendMessageButton = Hud_GetChild( menu, "BtnSendMessage" )
	// file.adminViewPendingRequestsButton = Hud_GetChild( menu, "BtnPendingRequests" )

	file.browseCommunitiesMenu = GetMenu( "BrowseCommunities" )

	file.browseCommunitiesPanel = Hud_GetChild( file.browseCommunitiesMenu, "BrowseCommunitiesPanel" )
	file.browseCommunitiesPanel_FilterBackground = Hud_GetChild( file.browseCommunitiesPanel, "ListCommunitiesBackground" )
	file.browseCommunitiesPanel_ListWidget = Hud_GetChild( file.browseCommunitiesPanel, "ListCommunities" )
	file.browseCommunitiesPanel_NameWidget = Hud_GetChild( file.browseCommunitiesPanel, "CommunityFilterName" )
	file.browseCommunitiesPanel_ClantagWidget = Hud_GetChild( file.browseCommunitiesPanel, "CommunityFilterClantag" )
	file.browseCommunitiesPanel_TypeButton = Hud_GetChild( file.browseCommunitiesPanel, "CommunityFilterType" )
	file.browseCommunitiesPanel_MembershipButton = Hud_GetChild( file.browseCommunitiesPanel, "CommunityFilterMembership" )
	file.browseCommunitiesPanel_CategoryButton = Hud_GetChild( file.browseCommunitiesPanel, "CommunityFilterCategory" )
	file.browseCommunitiesPanel_PlaytimeButton = Hud_GetChild( file.browseCommunitiesPanel, "CommunityFilterPlaytime" )
	file.browseCommunitiesPanel_MicPolicyButton = Hud_GetChild( file.browseCommunitiesPanel, "CommunityMicFilterPolicy" )
	file.browseCommunitiesPanel_MinMembersButton = Hud_GetChild( file.browseCommunitiesPanel, "MemberCountFilter" )
	file.browseCommunitiesPanel_ViewDetailsButton = Hud_GetChild( file.browseCommunitiesPanel, "ViewDetails" )

	Hud_SetText( Hud_GetChild( file.browseCommunitiesPanel, "MyRegion" ), Localize( "#MY_REGION_N", MyRegion() ) )

	file.browseCommunitiesPanel_FilterElements.append( file.browseCommunitiesPanel_NameWidget )
	file.browseCommunitiesPanel_FilterElements.append( file.browseCommunitiesPanel_ClantagWidget )
	file.browseCommunitiesPanel_FilterElements.append( file.browseCommunitiesPanel_TypeButton )
	file.browseCommunitiesPanel_FilterElements.append( file.browseCommunitiesPanel_MembershipButton )
	file.browseCommunitiesPanel_FilterElements.append( file.browseCommunitiesPanel_CategoryButton )
	file.browseCommunitiesPanel_FilterElements.append( file.browseCommunitiesPanel_MinMembersButton )
	file.browseCommunitiesPanel_FilterElements.append( file.browseCommunitiesPanel_PlaytimeButton )
	file.browseCommunitiesPanel_FilterElements.append( file.browseCommunitiesPanel_MicPolicyButton )
	file.browseCommunitiesPanel_FilterElements.append( file.browseCommunitiesPanel_ViewDetailsButton )

	file.browseCommunitiesPanel_FilterElements.append( Hud_GetChild( file.browseCommunitiesPanel, "NameFilterLabel" ) )
	file.browseCommunitiesPanel_FilterElements.append( Hud_GetChild( file.browseCommunitiesPanel, "ClantagFilterLabel" ) )
	file.browseCommunitiesPanel_FilterElements.append( Hud_GetChild( file.browseCommunitiesPanel, "TypeFilterLabel" ) )
	file.browseCommunitiesPanel_FilterElements.append( Hud_GetChild( file.browseCommunitiesPanel, "CategoryFilterLabel" ) )
	file.browseCommunitiesPanel_FilterElements.append( Hud_GetChild( file.browseCommunitiesPanel, "PlaytimeFilterLabel" ) )
	file.browseCommunitiesPanel_FilterElements.append( Hud_GetChild( file.browseCommunitiesPanel, "MemberCountFilterLabel" ) )
	file.browseCommunitiesPanel_FilterElements.append( Hud_GetChild( file.browseCommunitiesPanel, "MembershipFilterLabel" ) )
	file.browseCommunitiesPanel_FilterElements.append( Hud_GetChild( file.browseCommunitiesPanel, "MicPolicyFilterLabel" ) )

	file.browseCommunitiesPanel_HintElements.append( Hud_GetChild( file.browseCommunitiesPanel, "HintBackground" ) )
	file.browseCommunitiesPanel_HintElements.append( Hud_GetChild( file.browseCommunitiesPanel, "HintIcon" ) )
	file.browseCommunitiesPanel_HintElements.append( Hud_GetChild( file.browseCommunitiesPanel, "HintLabel" ) )
	file.browseCommunitiesPanel_HintElements.append( Hud_GetChild( file.browseCommunitiesPanel, "HintCopy" ) )

	file.browseCommunitiesPanel_CommunityInfoPanel = Hud_GetChild( file.browseCommunitiesPanel, "CommunityInfo" )

	var elem = Hud_GetChild( file.browseCommunitiesPanel_CommunityInfoPanel, "MOTDIcon" )
	var rui = Hud_GetRui( elem )
	RuiSetImage( rui, "basicImage", $"rui/menu/common/inbox_icon" )

	elem = Hud_GetChild( file.browseCommunitiesPanel_CommunityInfoPanel, "XPIcon" )
	rui = Hud_GetRui( elem )
	RuiSetImage( rui, "basicImage", $"rui/merits/credit_sign_small" )

	elem = Hud_GetChild( file.browseCommunitiesPanel, "HintIcon" )
	rui = Hud_GetRui( elem )
	RuiSetImage( rui, "basicImage", $"rui/menu/common/bulb_hint_icon" )

	AddEventHandlerToButton( file.browseCommunitiesPanel, "ListCommunities", UIE_CLICK, BrowseCommunities_OnSelect )
	AddEventHandlerToButton( file.browseCommunitiesPanel, "ListCommunities", UIE_CHANGE, BrowseCommunities_OnChange )

	AddEventHandlerToButton( file.browseCommunitiesPanel, "ListCommunities", UIE_GET_FOCUS, BrowseCommunities_ListGetFocus )
	AddEventHandlerToButton( file.browseCommunitiesPanel, "ListCommunities", UIE_LOSE_FOCUS, BrowseCommunities_ListLoseFocus )

	AddEventHandlerToButton( file.browseCommunitiesPanel, "CommunityFilterName", UIE_GET_FOCUS, BrowseCommunities_FilterGetFocus )
	AddEventHandlerToButton( file.browseCommunitiesPanel, "CommunityFilterClantag", UIE_GET_FOCUS, BrowseCommunities_FilterGetFocus )
	AddEventHandlerToButton( file.browseCommunitiesPanel, "CommunityFilterType", UIE_GET_FOCUS, BrowseCommunities_FilterGetFocus )
	AddEventHandlerToButton( file.browseCommunitiesPanel, "CommunityFilterMembership", UIE_GET_FOCUS, BrowseCommunities_FilterGetFocus )
	AddEventHandlerToButton( file.browseCommunitiesPanel, "CommunityFilterCategory", UIE_GET_FOCUS, BrowseCommunities_FilterGetFocus )
	AddEventHandlerToButton( file.browseCommunitiesPanel, "CommunityFilterPlaytime", UIE_GET_FOCUS, BrowseCommunities_FilterGetFocus )
	AddEventHandlerToButton( file.browseCommunitiesPanel, "CommunityMicFilterPolicy", UIE_GET_FOCUS, BrowseCommunities_FilterGetFocus )
	AddEventHandlerToButton( file.browseCommunitiesPanel, "MemberCountFilter", UIE_GET_FOCUS, BrowseCommunities_FilterGetFocus )
	//	AddEventHandlerToButton( file.browseCommunitiesPanel, "ViewDetails", UIE_GET_FOCUS, BrowseCommunities_FilterGetFocus )

	AddEventHandlerToButton( file.browseCommunitiesPanel, "ViewDetails", UIE_CLICK, BrowseCommunities_OnViewDetails )


	AddMenuEventHandler( file.browseCommunitiesMenu, eUIEvent.MENU_OPEN, OnBrowseNetworksMenu_Open )
	AddMenuEventHandler( file.browseCommunitiesMenu, eUIEvent.MENU_NAVIGATE_BACK, OnBrowseMentworksMenu_NavigateBack )

	AddMenuFooterOption( file.browseCommunitiesMenu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )
	AddMenuFooterOption( file.browseCommunitiesMenu, BUTTON_A, "#COMMUNITY_JOINCOMMUNITY_ABUTTON", "#COMMUNITY_JOINCOMMUNITY", null, CanJoinNetwork )
	AddMenuFooterOption( file.browseCommunitiesMenu, BUTTON_X, "#COMMUNITY_REPORTABUSE_XBUTTON", "#COMMUNITY_REPORTABUSE", ReportAbuse_OnClick, CanReportAbuse )

	AddEventHandlerToButton( file.browseCommunitiesPanel, "CommunityFilterType", UIE_CLICK, Browse_ChangeCommunityType_Activate )
	AddEventHandlerToButton( file.browseCommunitiesPanel, "CommunityFilterMembership", UIE_CLICK, Browse_ChangeCommunityMembership_Activate )
	AddEventHandlerToButton( file.browseCommunitiesPanel, "CommunityFilterCategory", UIE_CLICK, Browse_ChangeCommunityCategory_Activate )
	AddEventHandlerToButton( file.browseCommunitiesPanel, "CommunityFilterPlaytime", UIE_CLICK, Browse_ChangeCommunityPlaytime_Activate )
	AddEventHandlerToButton( file.browseCommunitiesPanel, "CommunityMicFilterPolicy", UIE_CLICK, Browse_ChangeCommunityMicPolicy_Activate )
	AddEventHandlerToButton( file.browseCommunitiesPanel, "MemberCountFilter", UIE_CLICK, Browse_ChangeCommunityMinMembers_Activate )
	AddEventHandlerToButton( file.browseCommunitiesPanel, "CommunityFilterName", UIE_CHANGE, Browse_CommunityNameChanged )
	AddEventHandlerToButton( file.browseCommunitiesPanel, "CommunityFilterClantag", UIE_CHANGE, Browse_CommunityClantagChanged )

	file.editCommunityMenu = GetMenu( "CommunityEditMenu" )
	var editCommunityPanel = Hud_GetChild( file.editCommunityMenu, "editCommunityPanel" )
	file.editCommunityPanel_LanguagesButton = Hud_GetChild( editCommunityPanel, "Languages" )
	file.editCommunityPanel_SaveButton = Hud_GetChild( editCommunityPanel, "Save" )
	file.editCommunityPanel_CreateButton = Hud_GetChild( editCommunityPanel, "Create" )
	file.editCommunityLanguagesPanel = Hud_GetChild( file.editCommunityMenu, "EditCommunityLanguagesPanel" )
	file.editCommunityRegionsPanel = Hud_GetChild( file.editCommunityMenu, "EditCommunityRegionsPanel" )
	file.editCommunityCategoriesPanel = Hud_GetChild( file.editCommunityMenu, "EditCommunityCategoriesPanel" )
	file.editCommunityHappyHourPanel = Hud_GetChild( file.editCommunityMenu, "EditCommunityHappyHourPanel" )

	Hud_AddEventHandler( Hud_GetChild( editCommunityPanel, "HappyHourLeftHidden" ), UIE_GET_FOCUS, OnHappyHourPrev )
	Hud_AddEventHandler( Hud_GetChild( editCommunityPanel, "HappyHourRightHidden" ), UIE_GET_FOCUS, OnHappyHourNext )
	Hud_AddEventHandler( Hud_GetChild( editCommunityPanel, "HappyHourLeft" ), UIE_CLICK, OnHappyHourPrev )
	Hud_AddEventHandler( Hud_GetChild( editCommunityPanel, "HappyHourRight" ), UIE_CLICK, OnHappyHourNext )

	file.editCommunityPanel_PopupBackground = Hud_GetChild( file.editCommunityMenu, "PanelBackground" )
	Hud_AddEventHandler( file.editCommunityPanel_PopupBackground, UIE_CLICK, PopupBackground_Activate )

	file.editCommunityPanel_Header = Hud_GetChild( file.editCommunityMenu, "MenuTitle" )
	file.editCommunityPanel_NameLabel = Hud_GetChild( editCommunityPanel, "CommunityNameLabel" )
	file.editCommunityPanel_NameBigLabel = Hud_GetChild( editCommunityPanel, "CommunityNameBigLabel" )
	file.editCommunityPanel_Name = Hud_GetChild( editCommunityPanel, "CommunityNameEditBox" )
	file.editCommunityPanel_Clantag = Hud_GetChild( editCommunityPanel, "ClantagEditBox" )
	file.editCommunityPanel_MOTD = Hud_GetChild( editCommunityPanel, "MOTDEditBox" )
	file.editCommunityPanel_CategoriesButton = Hud_GetChild( editCommunityPanel, "Category" )
	file.editCommunityPanel_RegionsButton = Hud_GetChild( editCommunityPanel, "Regions" )
	file.editCommunityPanel_CommunityTypeButton = Hud_GetChild( editCommunityPanel, "CommunityType" )
	file.editCommunityPanel_MembershipTypeButton = Hud_GetChild( editCommunityPanel, "MembershipPolicy" )
	file.editCommunityPanel_VisibilityButton = Hud_GetChild( editCommunityPanel, "Visibility" )
	file.editCommunityPanel_MicPolicyButton = Hud_GetChild( editCommunityPanel, "MicPolicy" )
	file.editCommunityPanel_HappyHourStartButton = Hud_GetChild( editCommunityPanel, "HappyHourStart" )

	AddMenuEventHandler( file.editCommunityMenu, eUIEvent.MENU_NAVIGATE_BACK, OnEditCommunityMenu_Close )
	AddMenuFooterOption( file.editCommunityMenu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )

	file.editCommunityLanguagesPanel_LanguageButtons = SetupComboSelectButtons( file.editCommunityLanguagesPanel, file.languages, OnLanguageSelectButtonClick, true )
	file.editCommunityRegionsPanel_RegionButtons = SetupComboSelectButtons( file.editCommunityRegionsPanel, file.regions, OnComboSelectButtonClick, true )
	file.editCommunityCategoriesPanel_CategoryButtons = SetupComboSelectButtons( file.editCommunityCategoriesPanel, file.categories, OnSaveCategoriesButton_Activate, false )

	for ( int i = 0; i < 24; i++ )
		file.editCommunityHappyHourPanel_HappyHourButtons.append( Hud_GetChild( file.editCommunityHappyHourPanel, "time" + i ) )

	file.sendCommunityMsgMenu = GetMenu( "CommunityAdminSendMessage" )
	var sendCommunityMsgPanel = Hud_GetChild( file.sendCommunityMsgMenu, "SendCommunityMessagePanel" )
	file.sendCommunityMsg_expiration = 24 // default to 24 hours
	file.sendCommunityMsgPanel_ExpirationButton = Hud_GetChild( sendCommunityMsgPanel, "Expiration" )
	file.sendCommunityMsgPanel_CommunityName = Hud_GetChild( sendCommunityMsgPanel, "CommunityName" )
	file.sendCommunityMsgPanel_MsgText = Hud_GetChild( sendCommunityMsgPanel, "MessageEditBox" )
	file.sendCommunityMsgPanel_SendButton = Hud_GetChild( sendCommunityMsgPanel, "Send" )
	AddMenuEventHandler( file.sendCommunityMsgMenu, eUIEvent.MENU_OPEN, OnCommunitySendMsg_Open )
	AddMenuEventHandler( file.sendCommunityMsgMenu, eUIEvent.MENU_NAVIGATE_BACK, OCommunitySendMsg_NavigateBack )
	AddMenuFooterOption( file.sendCommunityMsgMenu, BUTTON_A, "#A_BUTTON_SELECT" )
	AddMenuFooterOption( file.sendCommunityMsgMenu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )


	elem = Hud_GetChild( sendCommunityMsgPanel, "MailIcon" )
	rui = Hud_GetRui( elem )
	RuiSetImage( rui, "basicImage", $"rui/menu/common/inbox_icon_new" )

	FindCommunityInfoWidgetsInPanel( file.communityInfoPanelWidgets, file.browseCommunitiesPanel_CommunityInfoPanel )

	AddMenuEventHandler( menu, eUIEvent.MENU_OPEN, OnCommunityMenu_Open )
	AddMenuEventHandler( menu, eUIEvent.MENU_CLOSE, OnCommunityMenu_Close )

	AddEventHandlerToButton( menu, "BtnBrowse", UIE_CLICK, OnBrowseNetworksButton_Activate )

	var button = Hud_GetChild( menu, "BtnBrowse" )
	SetButtonRuiText( button, "#COMMUNITY_BROWSE_NETWORKS" )
	AddButtonEventHandler( button, UIE_CLICK, OnBrowseNetworksButton_Activate )

	button = Hud_GetChild( menu, "BtnCreate" )
	SetButtonRuiText( button, "#COMMUNITY_CREATECOMMUNITY" )
	AddButtonEventHandler( button, UIE_CLICK, OnCreateCommunityButton_Activate )

	button = Hud_GetChild( menu, "BtnEdit" )
	SetButtonRuiText( button, "#COMMUNITY_EDITCOMMUNITY" )
	AddButtonEventHandler( button, UIE_CLICK, OnEditCommunityButton_Activate )

	button = Hud_GetChild( menu, "BtnSendMessage" )
	SetButtonRuiText( button, "#COMMUNITY_SENDMESSAGE" )
	AddButtonEventHandler( button, UIE_CLICK, OnStartSendCommunityMessageButton_Activate )

	button = Hud_GetChild( menu, "BtnPendingRequests" )
	SetButtonRuiText( button, "#COMMUNITY_NOPENDINGREQUESTSTOJOIN" )
	AddButtonEventHandler( button, UIE_CLICK, OnViewPendingRequestButton_Activate )

	AddEventHandlerToButton( sendCommunityMsgPanel, "Send", UIE_CLICK, OnActualSendCommunityMessageButton_Activate )
	AddEventHandlerToButton( sendCommunityMsgPanel, "Expiration", UIE_CLICK, OnChangeCommunityMessageExpirationButton_Activate )

	AddEventHandlerToButton( editCommunityPanel, "CommunityType", UIE_CLICK, OnCommunityTypeButton_Activate )
	AddEventHandlerToButton( editCommunityPanel, "Languages", UIE_CLICK, OnLanguagesButton_Activate )
	AddEventHandlerToButton( editCommunityPanel, "Regions", UIE_CLICK, OnRegionsButton_Activate )
	AddEventHandlerToButton( editCommunityPanel, "Category", UIE_CLICK, OnCategoriesButton_Activate )
	AddEventHandlerToButton( editCommunityPanel, "MembershipPolicy", UIE_CLICK, OnMembershipTypeButton_Activate )
	AddEventHandlerToButton( editCommunityPanel, "Visibility", UIE_CLICK, OnVisibilityButton_Activate )
	AddEventHandlerToButton( editCommunityPanel, "MicPolicy", UIE_CLICK, OnMicPolicyButton_Activate )
	AddEventHandlerToButton( editCommunityPanel, "HappyHourStart", UIE_CLICK, OnHappyHourButton_Activate )
	AddEventHandlerToButton( editCommunityPanel, "Create", UIE_CLICK, OnSaveCommunityButton_Activate )
	AddEventHandlerToButton( editCommunityPanel, "Save", UIE_CLICK, OnSaveCommunityButton_Activate )
	AddEventHandlerToButton( file.editCommunityLanguagesPanel, "Save", UIE_CLICK, OnSaveLanguagesButton_Activate )
	AddEventHandlerToButton( file.editCommunityRegionsPanel, "Save", UIE_CLICK, OnSaveRegionsButton_Activate )

	AddEventHandlerToButton( file.editCommunityHappyHourPanel, "time0", UIE_CLICK, OnHappyHour0Button_Activate )
	AddEventHandlerToButton( file.editCommunityHappyHourPanel, "time1", UIE_CLICK, OnHappyHour1Button_Activate )
	AddEventHandlerToButton( file.editCommunityHappyHourPanel, "time2", UIE_CLICK, OnHappyHour2Button_Activate )
	AddEventHandlerToButton( file.editCommunityHappyHourPanel, "time3", UIE_CLICK, OnHappyHour3Button_Activate )
	AddEventHandlerToButton( file.editCommunityHappyHourPanel, "time4", UIE_CLICK, OnHappyHour4Button_Activate )
	AddEventHandlerToButton( file.editCommunityHappyHourPanel, "time5", UIE_CLICK, OnHappyHour5Button_Activate )
	AddEventHandlerToButton( file.editCommunityHappyHourPanel, "time6", UIE_CLICK, OnHappyHour6Button_Activate )
	AddEventHandlerToButton( file.editCommunityHappyHourPanel, "time7", UIE_CLICK, OnHappyHour7Button_Activate )
	AddEventHandlerToButton( file.editCommunityHappyHourPanel, "time8", UIE_CLICK, OnHappyHour8Button_Activate )
	AddEventHandlerToButton( file.editCommunityHappyHourPanel, "time9", UIE_CLICK, OnHappyHour9Button_Activate )
	AddEventHandlerToButton( file.editCommunityHappyHourPanel, "time10", UIE_CLICK, OnHappyHour10Button_Activate )
	AddEventHandlerToButton( file.editCommunityHappyHourPanel, "time11", UIE_CLICK, OnHappyHour11Button_Activate )
	AddEventHandlerToButton( file.editCommunityHappyHourPanel, "time12", UIE_CLICK, OnHappyHour12Button_Activate )
	AddEventHandlerToButton( file.editCommunityHappyHourPanel, "time13", UIE_CLICK, OnHappyHour13Button_Activate )
	AddEventHandlerToButton( file.editCommunityHappyHourPanel, "time14", UIE_CLICK, OnHappyHour14Button_Activate )
	AddEventHandlerToButton( file.editCommunityHappyHourPanel, "time15", UIE_CLICK, OnHappyHour15Button_Activate )
	AddEventHandlerToButton( file.editCommunityHappyHourPanel, "time16", UIE_CLICK, OnHappyHour16Button_Activate )
	AddEventHandlerToButton( file.editCommunityHappyHourPanel, "time17", UIE_CLICK, OnHappyHour17Button_Activate )
	AddEventHandlerToButton( file.editCommunityHappyHourPanel, "time18", UIE_CLICK, OnHappyHour18Button_Activate )
	AddEventHandlerToButton( file.editCommunityHappyHourPanel, "time19", UIE_CLICK, OnHappyHour19Button_Activate )
	AddEventHandlerToButton( file.editCommunityHappyHourPanel, "time20", UIE_CLICK, OnHappyHour20Button_Activate )
	AddEventHandlerToButton( file.editCommunityHappyHourPanel, "time21", UIE_CLICK, OnHappyHour21Button_Activate )
	AddEventHandlerToButton( file.editCommunityHappyHourPanel, "time22", UIE_CLICK, OnHappyHour22Button_Activate )
	AddEventHandlerToButton( file.editCommunityHappyHourPanel, "time23", UIE_CLICK, OnHappyHour23Button_Activate )

	AddMenuFooterOption( menu, BUTTON_A, "#A_BUTTON_SELECT" )
	AddMenuFooterOption( menu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )
	AddMenuFooterOption( menu, BUTTON_TRIGGER_RIGHT, "#R_TRIGGER_CHAT", "", null, IsVoiceChatPushToTalk )
}

void function InitCommunityKeys()
{
	var dataTable = GetDataTable( $"datatable/community_entries.rpak" )
	int numRows = GetDatatableRowCount( dataTable )
	file.keysToStrings[""] <- ""
	for ( int i=0; i<numRows; i++ )
	{
		string category = GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "category" ) )
		string key = GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "key" ) )
		string locString = GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "locString" ) )
		file.keysToStrings[ key ] <- locString

		switch ( category )
		{
			case "categories":
				file.categories.append( key )
			break
			case "regions":
				file.regions.append( key )
			break
			case "languages":
				file.languages.append( key )
			break
		}
	}
}

array<var> function SetupComboSelectButtons( var panel, array<string> labelNames, void functionref(var) func, bool hasSaveButton )
{
	int MAX_BUTTONS = 15
	array<var> buttons = []
	var lastButton
	int i

	int height = 0

	var BG = Hud_GetChild( panel, "Background" )

	for ( i=0; i<MAX_BUTTONS && i<labelNames.len(); i++ )
	{
		var button = Hud_GetChild( panel, "Button" + i )
		var rui = Hud_GetRui( button )
		string localizedName = Localize( ConvertKeyToLocalizedString( labelNames[i] ) )
		RuiSetString( rui, "buttonText", localizedName )
		Hud_Show( button )
		buttons.append( button )
		AddButtonEventHandler( button, UIE_CLICK, func )
		lastButton = button
		height += Hud_GetY( button )
		height += Hud_GetHeight( button )
	}

	array<var> allbuttons = clone buttons
	if ( hasSaveButton )
	{
		var saveButton = Hud_GetChild( panel, "Save" )
		var rui = Hud_GetRui( saveButton )
		RuiSetString( rui, "buttonText", "#SAVE" )
		Hud_Show( saveButton )
		Hud_SetPinSibling( saveButton, Hud_GetHudName( lastButton ) )
		allbuttons.append( saveButton )
		height += Hud_GetHeight( saveButton )
		height += Hud_GetY( saveButton )
	}

	SetNavUpDown( allbuttons )

	Hud_SetHeight( BG, height )

	return buttons
}

string function ConvertKeyToLocalizedString( string key )
{
	if ( !( key in file.keysToStrings ) )
		return "???"

	return file.keysToStrings[ key ]
}

void function OnComboSelectButtonClick( var button )
{
	if ( Hud_IsLocked( button ) )
		return

	Hud_SetSelected( button, !Hud_IsSelected( button ) )

	UpdateComboSelectButtons( file.editCommunityRegionsPanel_RegionButtons, GetToggledRegion( 2 ) != "" )
}

void function OnLanguageSelectButtonClick( var button )
{
	if ( Hud_IsLocked( button ) )
		return

	Hud_SetSelected( button, !Hud_IsSelected( button ) )

	string language3 = GetToggledLanguage( 2 )

	UpdateComboSelectButtons( file.editCommunityLanguagesPanel_LanguageButtons, GetToggledLanguage( 2 ) != "" )
}

void function UpdateComboSelectButtons( array< var > buttons, bool shouldLockButtons )
{
	foreach( var button in buttons )
	{
		if ( shouldLockButtons )
			Hud_SetLocked( button, !Hud_IsSelected( button ) )
		else
			Hud_SetLocked( button, false )
	}
}

void function OnCommunityMenu_Open()
{
	HideAllPanels()
	FillInBrowseFilters( file.browseFilters )
	UI_SetPresentationType( ePresentationType.NO_MODELS )
}

void function OnEditCommunityMenu_Close()
{
	if ( file.inCommunityPanel )
	{
		MyCommunities_OnLoseFocus( file.switchCommunityPanel_ListWidget )

		if ( file.lastButtonFocused != null )
			Hud_SetFocused( file.lastButtonFocused )

		foreach ( panel in file.temporaryPanels )
		{
			Hud_Hide( panel )
		}
	}
	else
	{
		if ( file.communityEdited )
		{
			DialogData dialogData
			dialogData.header = "#COMMUNITY_ARE_YOU_SURE"
			dialogData.message = "#COMMUNITY_CHANGES_WILL_BE_LOST"

			AddDialogButton( dialogData, "#YES", LeaveEditCommunity )
			AddDialogButton( dialogData, "#NO" )

			dialogData.noChoiceWithNavigateBack = true
			OpenDialog( dialogData )
		}
		else
		{
			LeaveEditCommunity()
		}
	}
}

void function LeaveEditCommunity()
{
	HideAllPanels()
	CloseActiveMenu( true )
}

void function OnCommunityMenu_Close()
{
	Signal( uiGlobal.signalDummy, "StopCommunityLookups" )
	Signal( uiGlobal.signalDummy, "StopUserJoinRequestLookups" )
	HideAllPanels()
}

void function InitMyNetworksMenu()
{
	var menu = GetMenu( "MyNetworks" )

	var elem
	var rui

	file.switchCommunityMenu = menu

	file.switchCommunityPanelCover = Hud_GetChild( menu, "ButtonCover" )
	file.switchCommunityPanel = Hud_GetChild( menu, "SwitchCommunityPanel" )
	file.switchCommunityPanel_ListWidget = Hud_GetChild( file.switchCommunityPanel, "ListCommunities" )
	file.switchCommunityPanel_CommunityInfoPanel = Hud_GetChild( file.switchCommunityPanel, "CommunityInfo" )

	elem = Hud_GetChild( file.switchCommunityPanel_CommunityInfoPanel, "MOTDIcon" )
	rui = Hud_GetRui( elem )
	RuiSetImage( rui, "basicImage", $"rui/menu/common/inbox_icon" )

	elem = Hud_GetChild( file.switchCommunityPanel_CommunityInfoPanel, "XPIcon" )
	rui = Hud_GetRui( elem )
	RuiSetImage( rui, "basicImage", $"rui/merits/credit_sign_small" )

	elem = Hud_GetChild( file.switchCommunityMenu, "HintIcon" )
	rui = Hud_GetRui( elem )
	RuiSetImage( rui, "basicImage", $"rui/menu/common/bulb_hint_icon" )

	file.switchCommunityPanelHints.append( elem )
	file.switchCommunityPanelHints.append( Hud_GetChild( file.switchCommunityMenu, "HintBackground" ) )
	file.switchCommunityPanelHints.append( Hud_GetChild( file.switchCommunityMenu, "HintLabel" ) )
	file.switchCommunityPanelHints.append( Hud_GetChild( file.switchCommunityMenu, "HintLabelPC" ) )

	FindCommunityInfoWidgetsInPanel( file.myCommunityInfoPanelWidgets, file.switchCommunityPanel_CommunityInfoPanel )

	AddMenuEventHandler( menu, eUIEvent.MENU_OPEN, OnMyNetworksMenu_Open )

	SetupComboButtons( menu )

	AddEventHandlerToButton( file.switchCommunityPanel, "ListCommunities", UIE_CLICK, MyCommunities_OnSelect )
	AddEventHandlerToButton( file.switchCommunityPanel, "ListCommunities", UIE_CHANGE, MyCommunities_OnChange )
	AddEventHandlerToButton( file.switchCommunityPanel, "ListCommunities", UIE_GET_FOCUS, MyCommunities_OnGetFocus )
	AddEventHandlerToButton( file.switchCommunityPanel, "ListCommunities", UIE_LOSE_FOCUS, MyCommunities_OnLoseFocus )

	AddMenuEventHandler( menu, eUIEvent.MENU_NAVIGATE_BACK, OnNetworksMenu_NavigateBack )

	AddMenuFooterOption( menu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )
	AddMenuFooterOption( menu, BUTTON_A, "#A_BUTTON_SELECT" )
	AddMenuFooterOption( menu, BUTTON_X, "#COMMUNITY_LEAVECOMMUNITY_XBUTTON", "", LeaveCommunityButton_Activate, ListCommunitiesPanelHasFocus )
}

void function OnMyNetworksMenu_Open()
{
	Signal( uiGlobal.signalDummy, "StopCommunityLookups" )
	int communityId = GetCurrentCommunityId()
	if ( communityId >= 0 )
		thread GetCommunityInfoThread( communityId )

	HideAllPanels()
	UI_SetPresentationType( ePresentationType.NO_MODELS )
}

void function OnBrowseNetworksMenu_Open()
{
	Signal( uiGlobal.signalDummy, "StopCommunityLookups" )
	int communityId = GetCurrentCommunityId()
	if ( communityId >= 0 )
		thread GetCommunityInfoThread( communityId )

	HideAllPanels()
	UI_SetPresentationType( ePresentationType.NO_MODELS )

	Hud_SetText( Hud_GetChild( file.browseCommunitiesPanel, "MyRegion" ), Localize( "#MY_REGION_N", MyRegion() ) )

	thread FooterOptionsUpdate( uiGlobal.activeMenu )
}

void function FooterOptionsUpdate( var menu )
{
	EndSignal( uiGlobal.signalDummy, "CleanupInGameMenus" )

	while ( GetTopNonDialogMenu() == menu )
	{
		UpdateFooterOptions()
		WaitFrame()
	}
}

void function ToggleChatroomVoiceMode0( var button )
{
	ToggleChatroomVoiceMode( 0 )
}

void function ToggleChatroomVoiceMode1( var button )
{
	ToggleChatroomVoiceMode( 1 )
}

void function ToggleChatroomVoiceMode( int voiceMode )
{
	if ( voiceMode == 0 )
		ClientCommand( "chatroom_freetalk" )
	else
		ClientCommand( "chatroom_adminsonly" )

	UpdateChatroomToggleText( voiceMode )
}

void function SetupComboButtons( var menu )
{
	ComboStruct comboStruct = ComboButtons_Create( menu )

	int headerIndex = 0
	int buttonIndex = 0
	var activeNetworkHeader = AddComboButtonHeader( comboStruct, headerIndex, "#MENU_TITLE_ACTIVE_NETWORK" )
	file.switchCommunityPanelButtons.append( activeNetworkHeader )

	var selectButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#MENU_TITLE_CHOOSE_NETWORK" )
	file.switchCommunityPanelButtons.append( selectButton )
	file.selectNetWorkbutton = selectButton
	Hud_AddEventHandler( selectButton, UIE_CLICK, SelectNetworkButton_Activate )

	var createButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#MENU_TITLE_CREATE_NETWORK" )
	file.switchCommunityPanelButtons.append( createButton )
	AddButtonEventHandler( createButton, UIE_CLICK, OnCreateCommunityButton_Activate )

	var leaveButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#COMMUNITY_LEAVE_NETWORK" )
	file.switchCommunityPanelButtons.append( leaveButton )
	Hud_AddEventHandler( leaveButton, UIE_CLICK, LeaveCurrentCommunityButton_Activate )

	headerIndex++
	buttonIndex = 0

	var adminHeader = AddComboButtonHeader( comboStruct, headerIndex, "#MENU_TITLE_ADMIN" )
	file.switchCommunityPanelButtons.append( adminHeader )
	var editButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#MENU_TITLE_EDIT_NETWORK" )
	file.switchCommunityPanelButtons.append( editButton )
	AddButtonEventHandler( editButton, UIE_CLICK, OnEditCommunityButton_Activate )
	file.editButton = editButton

	file.sendButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#MENU_TITLE_SEND" )
	file.switchCommunityPanelButtons.append( file.sendButton )
	Hud_AddEventHandler( file.sendButton, UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "CommunityAdminSendMessage" ) ) )

	var pendingRequestButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#MENU_TITLE_MEMBER_REQ" )
	file.switchCommunityPanelButtons.append( pendingRequestButton )
	AddButtonEventHandler( pendingRequestButton, UIE_CLICK, OnViewPendingRequestButton_Activate )
	file.adminViewPendingRequestsButton = pendingRequestButton

	headerIndex++
	buttonIndex = 0

	file.chatroomToggleVoiceModeHeader = AddComboButtonHeader( comboStruct, headerIndex, "#MENU_TITLE_ADMIN_CHATROOM" )
	file.switchCommunityPanelButtons.append( file.chatroomToggleVoiceModeHeader )

	file.chatroomToggleVoiceModeButton0 = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#MENU_TITLE_CHATROOM_FREETALK" )
	file.switchCommunityPanelButtons.append( file.chatroomToggleVoiceModeButton0 )
	Hud_AddEventHandler( file.chatroomToggleVoiceModeButton0, UIE_CLICK, ToggleChatroomVoiceMode0 )

	file.chatroomToggleVoiceModeButton1 = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#MENU_TITLE_CHATROOM_ADMINSONLY" )
	file.switchCommunityPanelButtons.append( file.chatroomToggleVoiceModeButton1 )
	Hud_AddEventHandler( file.chatroomToggleVoiceModeButton1, UIE_CLICK, ToggleChatroomVoiceMode1 )

	// comboStruct.navDownButton = file.chatroomMenu_chatroomWidget
	ComboButtons_Finalize( comboStruct )

	file.networksComboStruct = comboStruct
}

void function SelectNetworkButton_Activate( var button )
{
	// file.inCommunityPanel = true
	Hud_SetFocused( file.switchCommunityPanel_ListWidget )
}

void function OnNetworksMenu_NavigateBack()
{
	if ( file.inCommunityPanel )
	{
		MyCommunities_OnLoseFocus( file.switchCommunityPanel_ListWidget )
		Hud_SetFocused( file.selectNetWorkbutton )
	}
	else
	{
		CloseActiveMenu( true )
	}
}

void function OnBrowseMentworksMenu_NavigateBack()
{
	printt( Hud_GetHudName( GetFocus() ) )
	if ( GetFocus() == file.browseCommunitiesPanel_ListWidget )
	{
		Hud_Show( file.browseCommunitiesPanel_ViewDetailsButton )
		Hud_SetFocused( file.browseCommunitiesPanel_ViewDetailsButton )
	}
	else
	{
		CloseActiveMenu( true )
	}
}


void function OCommunitySendMsg_NavigateBack()
{
	if ( !file.communityEdited )
	{
		LeaveEditCommunity()
		return
	}

	DialogData dialogData
	dialogData.header = "#COMMUNITY_ARE_YOU_SURE"
	dialogData.message = "#COMMUNITY_CHANGES_WILL_BE_LOST"

	AddDialogButton( dialogData, "#YES", LeaveEditCommunity )
	AddDialogButton( dialogData, "#NO" )

	dialogData.noChoiceWithNavigateBack = true
	OpenDialog( dialogData )
}


string function GetMyRegion_Localized()
{
	string myRegion = MyRegion()

	string myRegion_localized

	if ( myRegion in file.keysToStrings )
		myRegion_localized = Localize( "#MY_REGION_N", Localize( ConvertKeyToLocalizedString( myRegion ) ) )

	return myRegion_localized
}

#if NETWORK_INVITE
void function OnInviteFriendsToNetworkButton_Activate( var button )
{
    if( Hud_IsLocked( button ) )
        return

	AdvanceMenu( GetMenu( "InviteFriendsToNetworkMenu" ) )
}
#endif
