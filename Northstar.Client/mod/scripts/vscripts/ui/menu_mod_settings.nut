untyped
global function AddModSettingsMenu
global function AddConVarSetting
global function AddConVarSettingEnum
global function AddConVarSettingSlider
global function AddModTitle

const int BUTTONS_PER_PAGE = 12
const string SETTING_ITEM_TEXT = "                        " // this is long enough to be the same size as the textentry field

enum eEmptySpaceType 
{
	None, 
	TopBar,
	BottomBar
}

struct ConVarData {
	string displayName
	string conVar
	string modName
	string catName
	string type
	bool isCategoryName = false
	bool isModName = false
	bool isEmptySpace = false
	int spaceType = 0
	bool isEnumSetting = false
	bool isCustomButton = false
	
	// SLIDER BULLSHIT
	bool sliderEnabled = false
	float min = 0.0
	float max = 1.0
	float stepSize = 0.05

	array<string> values
	var customMenu
	bool hasCustomMenu = false
}

struct {
	var menu
	int scrollOffset = 0
	bool updatingList = false

	array<ConVarData> conVarList
	// if people use searches - i hate them but it'll do :)
	array<ConVarData> filteredList
	string filterText = ""
	table< int, int > enumRealValues
	array<var> modPanels
	array<MS_Slider> sliders
	table settingsTable
	string currentMod = ""
} file

struct {
	int deltaX = 0
	int deltaY = 0
} mouseDeltaBuffer

void function AddModSettingsMenu()
{
	AddMenu( "ModSettings", $"resource/ui/menus/mod_settings.menu", InitModMenu )
}

void function InitModMenu()
{
	file.menu = GetMenu( "ModSettings" )
	//DumpStack(2)
	AddMenuFooterOption( file.menu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )

	// Safe I/O stuff
	// uncomment when safe i/o is merged.

	/*
	try
	{
		file.settingsTable = expect table( compilestring( "return NSLoadFile( \"Mod Settings\", \"settings\" )" )() )
	}
	catch (ex)
	{
	}

	foreach (string key, var value in file.settingsTable)
	{
		printt(key, expect string( value ))
		try
		{
			SetConVarString(key, expect string( value ))
		}
		catch (ex)
		{
			
		}
	}*/

	/////////////////////////////
	// BASE NORTHSTAR SETTINGS //
	/////////////////////////////

	// most of these are overrided in the cfg, maybe ask bob to remove the cfg stuff from there?
	// at the same time, might fuck with dedis so idk.
	// these are pretty long too, might need to e x t e n d the settings menu
	AddModTitle( "#NORTHSTAR_BASE_SETTINGS" )
	AddConVarSettingEnum("ns_private_match_only_host_can_change_settings", "#ONLY_HOST_MATCH_SETTINGS", "#PRIVATE_MATCH", [ "No", "Yes" ])
	AddConVarSettingEnum("ns_private_match_only_host_can_change_settings", "#ONLY_HOST_CAN_START_MATCH", "#PRIVATE_MATCH", [ "No", "Yes" ])
	AddConVarSettingSlider("ns_private_match_countdown_length", "#MATCH_COUNTDOWN_LENGTH", "#PRIVATE_MATCH", 0, 30, 0.5)
	// probably shouldn't add this as a setting?
	// AddConVarSettingEnum("ns_private_match_override_maxplayers", "Override Max Player Count", "Northstar - Server", [ "No", "Yes" ])
	AddConVarSettingEnum("ns_should_log_unknown_clientcommands", "#LOG_UNKNOWN_CLIENTCOMMANDS", "Server", [ "No", "Yes" ])
	AddConVarSetting("ns_disallowed_tacticals", "#DISALLOWED_TACTICALS", "Server")
	AddConVarSetting("ns_disallowed_tactical_replacement", "#TACTICAL_REPLACEMENT", "Server")
	AddConVarSetting("ns_disallowed_weapons", "#DISALLOWED_WEAPONS", "Server")
	AddConVarSetting("ns_disallowed_weapon_primary_replacement", "#REPLACEMENT_WEAPON", "Server")
	AddConVarSettingEnum("ns_should_return_to_lobby", "#SHOULD_RETURN_TO_LOBBY", "Server", [ "No", "Yes" ])

	// Nuke weird rui on filter switch :D
	//RuiSetString( Hud_GetRui( Hud_GetChild( file.menu, "SwtBtnShowFilter")), "buttonText", "")

	file.modPanels = GetElementsByClassname( file.menu, "ModButton" )

	AddMenuEventHandler( file.menu, eUIEvent.MENU_OPEN, OnModMenuOpened )
	AddMenuEventHandler( file.menu, eUIEvent.MENU_CLOSE, OnModMenuClosed )

	int len = file.modPanels.len()
	print(len)	
	for (int i = 0; i < len; i++)
	{
		
		//AddButtonEventHandler( button, UIE_CHANGE, OnSettingButtonPressed  )
		// get panel
		var panel = file.modPanels[i]

		// reset to default nav
		var child = Hud_GetChild( panel, "BtnMod" )


		child.SetNavUp( Hud_GetChild( file.modPanels[ GetIndex( i - 1, len ) ], "BtnMod" ) )
		child.SetNavDown( Hud_GetChild( file.modPanels[ GetIndex( i + 1, len ) ], "BtnMod" ) )

		// Enum button nav
		child = Hud_GetChild( panel, "EnumSelectButton" )
		Hud_DialogList_AddListItem( child, SETTING_ITEM_TEXT, "main" )
		Hud_DialogList_AddListItem( child, SETTING_ITEM_TEXT, "next" )
		Hud_DialogList_AddListItem( child, SETTING_ITEM_TEXT, "prev" )

		child.SetNavUp( Hud_GetChild( file.modPanels[ GetIndex( i - 1, len ) ], "EnumSelectButton" ) )
		child.SetNavDown( Hud_GetChild( file.modPanels[ GetIndex( i + 1, len ) ], "EnumSelectButton" ) )
		Hud_AddEventHandler( child, UIE_CLICK, UpdateEnumSetting )

		// reset button nav
		
		child = Hud_GetChild( panel, "ResetModToDefault" )

		child.SetNavUp( Hud_GetChild( file.modPanels[ GetIndex( i - 1, len ) ], "ResetModToDefault" ) )
		child.SetNavDown( Hud_GetChild( file.modPanels[ GetIndex( i + 1, len ) ], "ResetModToDefault" ) )

		Hud_AddEventHandler( child, UIE_CLICK, ResetConVar )
		
		// text field nav
		child = Hud_GetChild( panel, "TextEntrySetting" )

		// 
		Hud_AddEventHandler( child, UIE_LOSE_FOCUS, SendTextPanelChanges )

		child.SetNavUp( Hud_GetChild( file.modPanels[ GetIndex( i - 1, len ) ], "TextEntrySetting" ) )
		child.SetNavDown( Hud_GetChild( file.modPanels[ GetIndex( i + 1, len ) ], "TextEntrySetting" ) )

		child = Hud_GetChild( panel, "Slider" )

		child.SetNavUp( Hud_GetChild( file.modPanels[ GetIndex( i - 1, len ) ], "Slider" ) )
		child.SetNavDown( Hud_GetChild( file.modPanels[ GetIndex( i + 1, len ) ], "Slider" ) )

		file.sliders.append(MS_Slider_Setup(child))

		Hud_AddEventHandler( child, UIE_CHANGE, OnSliderChange )
	}

	//Hud_AddEventHandler( Hud_GetChild( file.menu, "BtnModsSearch" ), UIE_LOSE_FOCUS, OnFilterTextPanelChanged )
	Hud_AddEventHandler( Hud_GetChild( file.menu, "BtnFiltersClear" ), UIE_CLICK, OnClearButtonPressed )
	// mouse delta 
	AddMouseMovementCaptureHandler( file.menu, UpdateMouseDeltaBuffer )

	thread SearchBarUpdate()
}

void function TestString(ConVarData test)
{
	test.displayName = "test"
}

void function SearchBarUpdate()
{
	while (true)
	{
		if (file.filterText != Hud_GetUTF8Text( Hud_GetChild( file.menu, "BtnModsSearch" ) ) )
		{
			file.filterText = Hud_GetUTF8Text( Hud_GetChild( file.menu, "BtnModsSearch" ) )
			OnFiltersChange(0)
		}
		WaitFrame()
	}
}

// magic function that converts an index from the full list into a index of a button,
// BUT loops around when getting an out-of-view index (so, when showing 0-7, 8 will return 0 and -1 will return 7)
// used for navigation code.
int function GetIndex( int index, int length )
{
	if (index < 0)
		return (length - 1) - (-index - 1) % length // this is really weird
	return index % length
}

void function ResetConVar( var button )
{
	ConVarData conVar = file.filteredList[ int ( Hud_GetScriptID( Hud_GetParent( button ) ) ) + file.scrollOffset ]

	if (conVar.isCategoryName)
	{
		ShowAreYouSureDialog( "Are you sure?", ResetAllConVarsForModEventHandler( conVar.catName ), "This will reset ALL settings that belong to this category.\n\nThis is not revertable."  )
	}
	else ShowAreYouSureDialog( "Are you sure?", ResetConVarEventHandler( int ( Hud_GetScriptID( Hud_GetParent( button ) ) ) + file.scrollOffset ), "This will reset the " + conVar.displayName + " setting to it's default value.\n\nThis is not revertable."  )
}

void function ShowAreYouSureDialog( string header, void functionref() func, string details )
{
	DialogData dialogData
	dialogData.header = header
	dialogData.message = details

	AddDialogButton( dialogData, "#NO" )
	AddDialogButton( dialogData, "#YES", func )

	AddDialogFooter( dialogData, "#A_BUTTON_SELECT" )
	AddDialogFooter( dialogData, "#B_BUTTON_BACK" )

	OpenDialog( dialogData )
}

void functionref() function ResetAllConVarsForModEventHandler( string catName )
{
	return void function() : ( catName )
	{
		for (int i = 0; i < file.conVarList.len(); i++)
		{
			ConVarData c = file.conVarList[i]
			if (c.catName != catName || c.isCategoryName || c.isEmptySpace) continue
			SetConVarToDefault(c.conVar)

			int index = file.filteredList.find(c)
			if (file.filteredList.find(c) < 0) continue

			if (min( BUTTONS_PER_PAGE, max(0, index - file.scrollOffset)) == index - file.scrollOffset)
				Hud_SetText(Hud_GetChild( file.modPanels[i - file.scrollOffset], "TextEntrySetting"), c.isEnumSetting ? c.values[GetConVarInt(c.conVar)] : GetConVarString(c.conVar))
		}
	}
}

void functionref() function ResetConVarEventHandler( int modIndex )
{
	return void function() : ( modIndex )
	{
		ConVarData c = file.filteredList[modIndex]
		SetConVarToDefault(c.conVar)
		if (min( BUTTONS_PER_PAGE, max(0, modIndex - file.scrollOffset)) == modIndex - file.scrollOffset)
			Hud_SetText(Hud_GetChild( file.modPanels[modIndex - file.scrollOffset], "TextEntrySetting"), c.isEnumSetting ? c.values[GetConVarInt(c.conVar)] : GetConVarString(c.conVar))
	}
}

////////////////////////
// slider
////////////////////////
void function UpdateMouseDeltaBuffer(int x, int y)
{
	mouseDeltaBuffer.deltaX += x
	mouseDeltaBuffer.deltaY += y

	SliderBarUpdate()
}

void function FlushMouseDeltaBuffer()
{
	mouseDeltaBuffer.deltaX = 0
	mouseDeltaBuffer.deltaY = 0
}

void function SliderBarUpdate()
{
	if ( file.filteredList.len() <= 15 )
	{
		FlushMouseDeltaBuffer()
		return
	}

	var sliderButton = Hud_GetChild( file.menu , "BtnModListSlider" )
	var sliderPanel = Hud_GetChild( file.menu , "BtnModListSliderPanel" )
	var movementCapture = Hud_GetChild( file.menu , "MouseMovementCapture" )

	Hud_SetFocused(sliderButton)

	float minYPos = -40.0 * (GetScreenSize()[1] / 1080.0) // why the hardcoded positions?!?!?!?!?!
	float maxHeight = 480.0  * (GetScreenSize()[1] / 1080.0)
	float maxYPos = minYPos - (maxHeight - Hud_GetHeight( sliderPanel ))
	float useableSpace = (maxHeight - Hud_GetHeight( sliderPanel ))

	float jump = minYPos - (useableSpace / ( float( file.filteredList.len())))

	// got local from official respaw scripts, without untyped throws an error
	local pos =	Hud_GetPos(sliderButton)[1]
	local newPos = pos - mouseDeltaBuffer.deltaY
	FlushMouseDeltaBuffer()

	if ( newPos < maxYPos ) newPos = maxYPos
	if ( newPos > minYPos ) newPos = minYPos

	Hud_SetPos( sliderButton , 2, newPos )
	Hud_SetPos( sliderPanel , 2, newPos )
	Hud_SetPos( movementCapture , 2, newPos )

	file.scrollOffset = -int( ( (newPos - minYPos) / useableSpace ) * ( file.filteredList.len() - BUTTONS_PER_PAGE) )
	UpdateList()
}

void function UpdateListSliderHeight()
{
	var sliderButton = Hud_GetChild( file.menu , "BtnModListSlider" )
	var sliderPanel = Hud_GetChild( file.menu , "BtnModListSliderPanel" )
	var movementCapture = Hud_GetChild( file.menu , "MouseMovementCapture" )
	
	float mods = float ( file.filteredList.len() )

	float maxHeight = 480.0 * (GetScreenSize()[1] / 1080.0) // why the hardcoded 320/80???
	float minHeight = 80.0 * (GetScreenSize()[1] / 1080.0)

	float height = maxHeight * ( float( BUTTONS_PER_PAGE ) / mods )

	if ( height > maxHeight ) height = maxHeight
	if ( height < minHeight ) height = minHeight

	Hud_SetHeight( sliderButton , height )
	Hud_SetHeight( sliderPanel , height )
	Hud_SetHeight( movementCapture , height )
}

void function UpdateList()
{
	Hud_SetFocused(Hud_GetChild(file.menu, "BtnModsSearch"))
	file.updatingList = true

	array<ConVarData> filteredList = []

	/*foreach (ConVarData c in file.conVarList)
	{
		if (c.isEmptySpace)
			print(" ")
		else if (c.isModName)
		{
			printt("MOD     ", c.modName)
		}
		else if (c.isCategoryName)
			printt("CATEGORY", c.modName)
		else printt("SETTING ", c.displayName)
	}*/

	string lastCatNameInFilter = ""
	string lastModNameInFilter = ""
	int curCatIndex = 0
	int curModTitleIndex = -1
	
	for (int i = 0; i < file.conVarList.len(); i++)
	{
		ConVarData prev = file.conVarList[maxint(0, i - 1)]
		ConVarData c = file.conVarList[i]
		ConVarData next = file.conVarList[minint(file.conVarList.len() - 1, i + 1)]
		if (c.isEmptySpace) continue

		string displayName = c.displayName
		if (c.isModName) {
			displayName = c.modName
			curModTitleIndex = i
		}
		if (c.isCategoryName) {
			displayName = c.catName
			curCatIndex = i
		}
		if (file.filterText == "" || Localize( displayName ).tolower().find(file.filterText.tolower()) != null)
		{
			if (c.isModName)
			{
				lastModNameInFilter = c.modName
				array<ConVarData> modVars = GetAllVarsInMod(c.modName)
				if (filteredList.len() <= 0 && modVars[0].spaceType == eEmptySpaceType.None)
					filteredList.extend(modVars.slice(1, modVars.len()))
				else filteredList.extend(modVars)
				i += modVars.len() - 1
			}
			else if (c.isCategoryName)
			{
				if (lastModNameInFilter != c.modName)
				{
					array<ConVarData> modVars = GetModConVarDatas(curModTitleIndex)
					if (filteredList.len() <= 0 && modVars[0].spaceType == eEmptySpaceType.None)
						filteredList.extend(modVars.slice(1, modVars.len()))
					else filteredList.extend(modVars)
					lastModNameInFilter = c.modName
				}
				filteredList.extend(GetAllVarsInCategory(c.catName))
				i += GetAllVarsInCategory(c.catName).len() - 1
				lastCatNameInFilter = c.catName
			}
			else {
				if (lastModNameInFilter != c.modName)
				{
					array<ConVarData> modVars = GetModConVarDatas(curModTitleIndex)
					if (filteredList.len() <= 0 && modVars[0].spaceType == eEmptySpaceType.None)
						filteredList.extend(modVars.slice(1, modVars.len()))
					else filteredList.extend(modVars)
					lastModNameInFilter = c.modName
				}
				if (lastCatNameInFilter != c.catName)
				{
					filteredList.extend(GetCatConVarDatas(curCatIndex))
					lastCatNameInFilter = c.catName
				}
				filteredList.append(c)
			}
		}
	}

	file.filteredList = filteredList

	int j = int( min( file.filteredList.len() + file.scrollOffset, BUTTONS_PER_PAGE ) )

	for ( int i = 0; i < BUTTONS_PER_PAGE; i++ )
	{
		Hud_SetEnabled( file.modPanels[ i ], i < j )
		Hud_SetVisible( file.modPanels[ i ], i < j )
		
		if (i < j)
			SetModMenuNameText( file.modPanels[ i ] )
	}
	file.updatingList = false
}

array<ConVarData> function GetModConVarDatas(int index)
{
	return [file.conVarList[index - 1], file.conVarList[index], file.conVarList[index + 1]]	
}

array<ConVarData> function GetCatConVarDatas(int index)
{
	if (index == 0)
		return [file.conVarList[index]]	
	return [file.conVarList[index - 1], file.conVarList[index]]	
}

array<ConVarData> function GetAllVarsInCategory(string catName)
{
	array<ConVarData> vars = []
	for (int i = 0; i < file.conVarList.len(); i++)
	{
		ConVarData c = file.conVarList[i]
		if (c.catName == catName) 
		{
			vars.append(file.conVarList[i])
			//printt(file.conVarList[i].conVar + " is in mod " + file.conVarList[i].modName)
		}
	}
	/*ConVarData empty
	empty.isEmptySpace = true
	vars.append(empty)*/
	return vars
}

array<ConVarData> function GetAllVarsInMod(string modName)
{
	array<ConVarData> vars = []
	for (int i = 0; i < file.conVarList.len(); i++)
	{
		ConVarData c = file.conVarList[i]
		if (c.modName == modName) 
		{
			vars.append(file.conVarList[i])
			//printt(file.conVarList[i].conVar + " is in mod " + file.conVarList[i].modName)
		}
	}
	/*ConVarData empty
	empty.isEmptySpace = true
	vars.append(empty)*/
	return vars
}

string function ConVarDataToString( int index )
{
	ConVarData d = file.filteredList[ index ] 
	int i = 0
	for (i = 0; file.conVarList[i] != d; i++)
	{}
	string type = d.isModName ? "Mod" : "Setting"
	if (d.isCategoryName) type = "Category" 
	switch (type)
	{
		case "Mod":
			return "Mod Title " + d.modName + " at index " + index
		case "Setting":
			return "ConVar " + d.displayName + " (" + d.conVar + ") at index " + index + "/" + i
		case "Category":
			return "Category " + d.catName + " at index " + index + "/" + i
	}

	return "EMPTY SPACE	"
}

void function SetModMenuNameText( var button )
{
	int index = int ( Hud_GetScriptID( button ) ) + file.scrollOffset
	ConVarData conVar = file.filteredList[ int ( Hud_GetScriptID( button ) ) + file.scrollOffset ]

	var panel = file.modPanels[ int ( Hud_GetScriptID( button ) ) ]

	var label = Hud_GetChild( panel, "BtnMod" )
	var textField = Hud_GetChild( panel, "TextEntrySetting" )
	var enumButton = Hud_GetChild( panel, "EnumSelectButton" )
	var resetButton = Hud_GetChild( panel, "ResetModToDefault" )
	var bottomLine = Hud_GetChild(panel, "BottomLine")
	var topLine = Hud_GetChild(panel, "TopLine")
	var modTitle = Hud_GetChild(panel, "ModTitle")
	var customMenuButton = Hud_GetChild(panel, "OpenCustomMenu")
	var slider = Hud_GetChild(panel, "Slider")
	Hud_SetVisible( slider, false )
	Hud_SetEnabled( slider, true )


	if (conVar.isEmptySpace)
	{
		string s = ""
		Hud_SetPos( label, 0, 0 )
		Hud_SetVisible( label, false )
		Hud_SetVisible( textField, false )
		Hud_SetVisible( enumButton, false )
		Hud_SetVisible( resetButton, false )
		Hud_SetVisible( modTitle, false )
		Hud_SetVisible( customMenuButton, false )
		Hud_SetVisible( bottomLine, false )
		Hud_SetVisible( topLine, false )
		switch (conVar.spaceType)
		{
			case eEmptySpaceType.TopBar:
				Hud_SetVisible( topLine, true )
				return
				
			case eEmptySpaceType.BottomBar:
				Hud_SetVisible( bottomLine, true )
				return
			
			case eEmptySpaceType.None:
				return
		}
	}



	// should be localisation at some point
	Hud_SetVisible(textField, !conVar.isCategoryName)
	Hud_SetVisible(bottomLine, conVar.isCategoryName || conVar.spaceType == eEmptySpaceType.BottomBar)
	Hud_SetVisible(topLine, false)
	Hud_SetVisible( enumButton, !conVar.isCategoryName && conVar.isEnumSetting )
	Hud_SetVisible( modTitle, conVar.isModName )
	Hud_SetVisible( customMenuButton, false )
	float scaleX = GetScreenSize()[1] / 1080.0
	float scaleY = GetScreenSize()[1] / 1080.0
	if (conVar.sliderEnabled)
	{
		Hud_SetSize( slider, int( 320 * scaleX ), int( 45 * scaleY ))
		MS_Slider s = file.sliders[int ( Hud_GetScriptID( button ) )]
		MS_Slider_SetMin( s, conVar.min )
		MS_Slider_SetMax( s, conVar.max )
		MS_Slider_SetStepSize(s, conVar.stepSize)
		MS_Slider_SetValue( s, GetConVarFloat(conVar.conVar) )
	}
	else
		Hud_SetSize( slider, 0, int( 45 * scaleY ))
	if (conVar.isModName)
	{
		Hud_SetText( modTitle, conVar.modName ) 
		Hud_SetSize( resetButton, 0, int(40 * scaleY) )
		Hud_SetPos( label, 0, 0 )
		Hud_SetVisible( label, false )
		Hud_SetVisible( textField, false )
		Hud_SetVisible( enumButton, false )
		Hud_SetVisible( resetButton, false )
		Hud_SetVisible( bottomLine, false )
		Hud_SetVisible( topLine, false )
	}
	else if ( conVar.isCategoryName ) {
		Hud_SetText( label, conVar.catName ) 
		Hud_SetText( resetButton, "Reset All" ) 
		Hud_SetSize( resetButton, int(120 * scaleX), int(40 * scaleY) )
		Hud_SetPos( label, 0, 0 )
		Hud_SetSize( label, int(scaleX * (1180 - 420 - 85)), int(scaleY * 40) )
		Hud_SetSize( customMenuButton, int(85 * scaleX), int(40 * scaleY) )
		Hud_SetVisible( customMenuButton, conVar.hasCustomMenu )
		Hud_SetVisible( label, true )
		Hud_SetVisible( textField, false )
		Hud_SetVisible( enumButton, false )
		Hud_SetVisible( resetButton, true )
	}
	else {
		Hud_SetVisible( slider, conVar.sliderEnabled )
		
		Hud_SetText( label, conVar.displayName ) 
		Hud_SetText( textField, conVar.isEnumSetting ? conVar.values[GetConVarInt(conVar.conVar)] : GetConVarString(conVar.conVar))
		Hud_SetPos( label, int(scaleX * 25), 0 )
		Hud_SetText( resetButton, "Reset" ) 
		Hud_SetSize( resetButton, int(scaleX * 90), int(scaleY * 40) )
		if (conVar.sliderEnabled)
			Hud_SetSize( label, int(scaleX * (375 + 85)), int(scaleY * 40) )
		else Hud_SetSize( label, int(scaleX * (375 + 405)), int(scaleY * 40) )
		Hud_SetSize( customMenuButton, 0, 40 )
		Hud_SetVisible( label, true )
		Hud_SetVisible( textField, true )
		//Hud_SetVisible( enumButton, true )
		Hud_SetVisible( resetButton, true )
	}
}

void function OnScrollDown( var button )
{
	if ( file.filteredList.len() <= BUTTONS_PER_PAGE ) return
	file.scrollOffset += 5
	if (file.scrollOffset + BUTTONS_PER_PAGE > file.filteredList.len()) {
		file.scrollOffset = file.filteredList.len() - BUTTONS_PER_PAGE
	}
	UpdateList()
	UpdateListSliderPosition()
}

void function OnScrollUp( var button )
{
	file.scrollOffset -= 5
	if (file.scrollOffset < 0) {
		file.scrollOffset = 0
	}
	UpdateList()
	UpdateListSliderPosition()
}

void function UpdateListSliderPosition()
{
	var sliderButton = Hud_GetChild( file.menu , "BtnModListSlider" )
	var sliderPanel = Hud_GetChild( file.menu , "BtnModListSliderPanel" )
	var movementCapture = Hud_GetChild( file.menu , "MouseMovementCapture" )
	
	float mods = float ( file.filteredList.len() )

	float minYPos = -40.0 * (GetScreenSize()[1] / 1080.0)
	float useableSpace = (480.0 * (GetScreenSize()[1] / 1080.0) - Hud_GetHeight( sliderPanel ))

	float jump = minYPos - (useableSpace / ( mods - float( BUTTONS_PER_PAGE ) ) * file.scrollOffset)

	//jump = jump * (GetScreenSize()[1] / 1080.0)

	if ( jump > minYPos ) jump = minYPos

	Hud_SetPos( sliderButton , 2, jump )
	Hud_SetPos( sliderPanel , 2, jump )
	Hud_SetPos( movementCapture , 2, jump )
}

void function OnModMenuOpened()
{
	file.scrollOffset = 0
	file.filterText = ""
	
	RegisterButtonPressedCallback(MOUSE_WHEEL_UP , OnScrollUp)
	RegisterButtonPressedCallback(MOUSE_WHEEL_DOWN , OnScrollDown)
	//RegisterButtonPressedCallback(KEY_F1, ToggleHideMenu)

	//SetBlurEnabled( false )
	//UI_SetPresentationType( ePresentationType.INACTIVE )
	//Hud_SetVisible( file.menu, true )
	
	OnFiltersChange(0)
}

void function OnFiltersChange( var n )
{
	file.scrollOffset = 0
	
	//HideAllButtons()
	
	//RefreshModsArray()
	
	UpdateList()
	
	UpdateListSliderHeight()
}

void function OnModMenuClosed()
{
	try
	{
		DeregisterButtonPressedCallback(MOUSE_WHEEL_UP , OnScrollUp)
		DeregisterButtonPressedCallback(MOUSE_WHEEL_DOWN , OnScrollDown)
		//DeregisterButtonPressedCallback(KEY_F1 , ToggleHideMenu)
	}
	catch ( ex ) {}
	
	file.scrollOffset = 0
	//UI_SetPresentationType( ePresentationType.DEFAULT )
	//SetBlurEnabled( !IsMultiplayer() )
	//Hud_SetVisible( file.menu, false )
}

void function AddModTitle(string modName)
{
	file.currentMod = modName
	if (file.conVarList.len() > 0)
	{
		ConVarData catData

		catData.isEmptySpace = true
		catData.modName = file.currentMod

		file.conVarList.append(catData)
	}
	ConVarData topBar
	topBar.isEmptySpace = true
	topBar.modName = modName
	topBar.spaceType = eEmptySpaceType.TopBar
	
	
	ConVarData modData

	modData.modName = modName
	modData.displayName = modName
	modData.isModName = true


	ConVarData botBar
	botBar.isEmptySpace = true
	botBar.modName = modName
	botBar.spaceType = eEmptySpaceType.BottomBar
	file.conVarList.extend([ topBar, modData, botBar ])
}

void function AddConVarSetting( string conVar, string displayName, string catName, string type = "" )
{
	if (file.conVarList.len() < 1)
	{
		ConVarData catData

		catData.catName = catName
		catData.modName = file.currentMod
		catData.displayName = catName
		catData.isCategoryName = true

		file.conVarList.append(catData)
	}
	else if (catName != file.conVarList[file.conVarList.len() - 1].catName)
	{
		ConVarData space
		space.isEmptySpace = true
		space.modName = file.currentMod
		space.catName = catName
		file.conVarList.append(space)

		ConVarData modData

		modData.catName = catName
		modData.displayName = catName
		modData.modName = file.currentMod
		modData.isCategoryName = true

		file.conVarList.append(modData)
	}

	ConVarData data

	data.catName = catName
	data.conVar = conVar
	data.modName = file.currentMod
	data.displayName = displayName
	data.type = type

	file.conVarList.append(data)
}

void function AddConVarSettingSlider( string conVar, string displayName, string catName, float min = 0.0, float max = 1.0, float stepSize = 0.1 )
{
	if (file.conVarList.len() < 1)
	{
		ConVarData catData

		catData.catName = catName
		catData.modName = file.currentMod
		catData.displayName = catName
		catData.isCategoryName = true

		file.conVarList.append(catData)
	}
	else if (catName != file.conVarList[file.conVarList.len() - 1].catName)
	{
		ConVarData space
		space.isEmptySpace = true
		space.modName = file.currentMod
		space.catName = catName
		file.conVarList.append(space)

		ConVarData modData

		modData.catName = catName
		modData.displayName = catName
		modData.modName = file.currentMod
		modData.isCategoryName = true

		file.conVarList.append(modData)
	}

	ConVarData data

	data.catName = catName
	data.conVar = conVar
	data.modName = file.currentMod
	data.displayName = displayName
	data.type = "float"
	data.sliderEnabled = true
	data.min = min
	data.max = max
	data.stepSize = stepSize

	file.conVarList.append(data)
}

void function AddConVarSettingEnum( string conVar, string displayName, string catName, array<string> values )
{
	if (file.conVarList.len() < 1)
	{
		ConVarData modData

		modData.catName = catName
		modData.modName = file.currentMod
		modData.isCategoryName = true

		file.conVarList.append(modData)
	}
	else if (catName != file.conVarList[file.conVarList.len() - 1].catName)
	{
		ConVarData space
		space.modName = file.currentMod
		space.catName = catName
		space.isEmptySpace = true
		file.conVarList.append(space)

		ConVarData modData

		modData.catName = catName
		modData.modName = file.currentMod
		modData.isCategoryName = true

		file.conVarList.append(modData)
	}

	ConVarData data

	data.catName = catName
	data.modName = file.currentMod
	data.conVar = conVar
	data.displayName = displayName
	data.values = values
	data.isEnumSetting = true

	file.conVarList.append(data)
}

void function SetCategoryCustomMenu( string category, var menu )
{
	foreach (ConVarData c in file.conVarList)
	{
		if (!c.isCategoryName) continue
		if (!c.isModName) continue
		if (c.isEmptySpace) continue
		if (c.catName != category) continue

		c.customMenu = menu
		c.hasCustomMenu = true
		break
	}
}

void function OnSliderChange( var button )
{
	var panel = Hud_GetParent( button )
	ConVarData c = file.filteredList[ int( Hud_GetScriptID( panel ) ) + file.scrollOffset ]
	var textPanel = Hud_GetChild( panel, "TextEntrySetting" )

	float val = Hud_SliderControl_GetCurrentValue( button )
	SetConVarFloat( c.conVar, val )

	Hud_SetText( textPanel, string( GetConVarFloat(c.conVar) ) )
}

void function SendTextPanelChanges( var textPanel ) 
{
	ConVarData c = file.filteredList[ int( Hud_GetScriptID( Hud_GetParent( textPanel ) ) ) + file.scrollOffset ]
	if (c.conVar == "") return
	// enums don't need to do this
	if ( !c.isEnumSetting )
	{
		string newSetting = Hud_GetUTF8Text( textPanel )

		switch (c.type)
		{
			case "int":
				try 
				{
					SetConVarInt(c.conVar, newSetting.tointeger())
					file.settingsTable[c.conVar] <- newSetting
				}
				catch (ex)
				{
					ThrowInvalidValue("This setting is an integer, and only accepts whole numbers.")
					Hud_SetText( textPanel, GetConVarString(c.conVar))
				}
			case "bool":
				if (newSetting != "0" && newSetting != "1")
				{
					ThrowInvalidValue("This setting is a boolean, and only accepts values of 0 or 1.")

					// set back to previous value :)
					Hud_SetText( textPanel, string( GetConVarBool(c.conVar) ))

					break
				}
				SetConVarBool(c.conVar, newSetting == "1")
				file.settingsTable[c.conVar] <- newSetting
				break
			case "float":
				try
				{
					SetConVarFloat(c.conVar, newSetting.tofloat())
					file.settingsTable[c.conVar] <- newSetting
				}
				catch (ex)
				{
					printt(ex)
					ThrowInvalidValue("This setting is a float, and only accepts a number - we could not parse this!\n\n(Use \".\" for the floating point, not \",\".)")
				}
				if (c.sliderEnabled)
				{
					var panel = Hud_GetParent( textPanel )
					MS_Slider s = file.sliders[int ( Hud_GetScriptID( panel ) )]

					MS_Slider_SetValue( s, GetConVarFloat(c.conVar))
				}
				break
			case "float2":
				try
				{
					array<string> split = split( newSetting, " " )
					if (split.len() != 2)
					{
						ThrowInvalidValue("This setting is a float2, and only accepts a pair of numbers - you put in " + split.len() + "!")
						Hud_SetText( textPanel, GetConVarString(c.conVar))
						break
					}
					vector settingTest = <split[0].tofloat(), split[1].tofloat(), 0>

					SetConVarString(c.conVar, newSetting)
					file.settingsTable[c.conVar] <- newSetting
				}
				catch (ex)
				{
					ThrowInvalidValue("This setting is a float2, and only accepts a pair of numbers - you put something we could not parse!\n\n(Use \".\" for the floating point, not \",\".)")
					Hud_SetText( textPanel, GetConVarString(c.conVar))
				}
				break
			// idk sometimes it's called Float3 most of the time it's called vector, I am not complaining.
			case "vector":
			case "float3":
				try
				{
					array<string> split = split( newSetting, " " )
					if (split.len() != 3)
					{
						ThrowInvalidValue("This setting is a float3, and only accepts a trio of numbers - you put in " + split.len() + "!")
						Hud_SetText( textPanel, GetConVarString(c.conVar))
						break
					}
					vector settingTest = <split[0].tofloat(), split[1].tofloat(), 0>

					SetConVarString(c.conVar, newSetting)
					file.settingsTable[c.conVar] <- newSetting
				}
				catch (ex)
				{
					ThrowInvalidValue("This setting is a float3, and only accepts a trio of numbers - you put something we could not parse!\n\n(Use \".\" for the floating point, not \",\".)")
					Hud_SetText( textPanel, GetConVarString(c.conVar))
				}
				break
			default:
				SetConVarString(c.conVar, newSetting)
				file.settingsTable[c.conVar] <- newSetting
				break;
		}
		try
		{
			compilestring( "return function ( t ) : () { NSSaveFile( \"Mod Settings\", \"settings\", t ) }" )() ( file.settingsTable )
		}
		catch (ex)
		{

		}
	}
	else Hud_SetText( textPanel, Localize( c.values[GetConVarInt(c.conVar)] ) )
}

void function ThrowInvalidValue( string desc )
{
	DialogData dialogData
	dialogData.header = "Invalid Value" 
	dialogData.image = $"ui/menu/common/dialog_error"
	dialogData.message = desc
	AddDialogButton( dialogData, "#OK" )
	OpenDialog( dialogData )
}

void function UpdateEnumSetting( var button )
{
	int scriptId = int( Hud_GetScriptID( Hud_GetParent( button ) ) )
	ConVarData c = file.filteredList[ scriptId + file.scrollOffset ]

	var panel = file.modPanels[scriptId]
	
	var textPanel = Hud_GetChild( panel, "TextEntrySetting")
	
	string selectionVal = Hud_GetDialogListSelectionValue( button )

	if ( selectionVal == "main" )
		return
					
	int enumVal = GetConVarInt(c.conVar)
	if ( selectionVal == "next" ) // enum val += 1
			enumVal = ( enumVal + 1 ) % c.values.len()
	else // enum val -= 1
	{
		enumVal--
		if ( enumVal == -1 )
			enumVal = c.values.len() - 1
	}
	
	SetConVarInt(c.conVar, enumVal)
	Hud_SetText( textPanel, c.values[ enumVal ] )

	Hud_SetDialogListSelectionValue( button, "main" )
}

void function OnClearButtonPressed( var button )
{
	file.filterText = ""

	Hud_SetText( Hud_GetChild( file.menu, "BtnModsSearch" ), "" )

	OnFiltersChange(0)
}

void function Hud_SliderControl_SetCurrentValue( var slider, float val )
{
	
}