untyped
global function AddColorPickerMenu



struct {
	var menu


	array<MS_Slider> sliders
	array<var> labels
	array<var> textFields
	array<var> resets

	array<int> color

	var colorPicker
	var colorImage
} file

void function AddColorPickerMenu()
{
	AddSubmenu( "ColorPicker", $"resource/ui/menus/colorsliders.menu" )


	file.colorPicker = GetMenu( "ColorPicker" )
	file.colorImage = Hud_GetChild( file.colorPicker, "Color" )

	var frameElem = Hud_GetChild( file.colorPicker, "DialogFrame" )
	RuiSetImage( Hud_GetRui( frameElem ), "basicImage", $"rui/menu/common/dialog_gradient" )
	RuiSetFloat3( Hud_GetRui( frameElem ), "basicImageColor", < 1, 1, 1 > )

	// AddMenuFooterOption( file.colorPicker, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )

	var screen = Hud_GetChild( file.colorPicker, "DarkenBackground" )
	Hud_AddEventHandler( screen, UIE_CLICK, OnScreen_BGActivate )
	var rui = Hud_GetRui( screen )
	RuiSetFloat( rui, "basicImageAlpha", 0.0 )



	AddMenuEventHandler( file.colorPicker, eUIEvent.MENU_OPEN, OnColorPickerOpen )
	AddMenuEventHandler( file.colorPicker, eUIEvent.MENU_CLOSE, OnColorPickerClose )
	// AddMenuEventHandler( file.colorPicker, eUIEvent.MENU_NAVIGATE_BACK, OnColorPickerClose )

	file.labels = GetElementsByClassname( file.colorPicker, "LabelClass" )

	file.sliders = []
	foreach (child in GetElementsByClassname( file.colorPicker, "SliderClass" )) {

		MS_Slider slider = MS_Slider_Setup( child )
		MS_Slider_SetMin( slider, 0 )
		MS_Slider_SetMax( slider, 255 )
		MS_Slider_SetStepSize( slider, 1 )

		file.sliders.append(slider)
		Hud_AddEventHandler( child, UIE_CHANGE, OnSliderChange )
	}


	file.textFields = GetElementsByClassname( file.colorPicker, "TextEntrySettingClass" )
	foreach (value in file.textFields) {
		Hud_AddEventHandler( value, UIE_LOSE_FOCUS, SendTextPanelChanges )
	}

	file.resets = GetElementsByClassname( file.colorPicker, "ResetModToDefaultClass" )
	foreach (value in file.resets) {
		Hud_AddEventHandler( value, UIE_CLICK, void function (var _button) {
			int index = int(Hud_GetScriptID(_button))
			ResetColor(index)
			printt("Try to reset color", index)
		}  )
	}

}


void function OnColorPickerOpen() {
	array < int > c = ColorsFromConvar()
	if (c.len() >= 3) {

		for (int i = 0; i < c.len(); i++) {
			_MS_Slider slider = file.sliders[i]
			var textPanel = file.textFields[i]


			int val = int(clamp(c[i], 0, 255))
			_MS_Slider_SetValue(slider, val.tofloat())
			Hud_SetText( textPanel, string(val) )
		}

		int alpha = int(clamp(c.len() == 4 ? c[3] : 255, 0, 255))
		Hud_SetColor(file.colorImage, c[0], c[1], c[2], alpha)
		file.color = c
		printt("ColorPicker Read ConVar", GetConVarString("modemenu_current_color_convar"), "With Value:", GetConVarString(GetConVarString("modemenu_current_color_convar")), ",Parsed To:",
		    c[0], c[1], c[2], alpha)

	}
}

void function OnColorPickerClose() {
	printt("Trying to close Color Picker")

	ColorsToConvar()

	file.color = []
	TryUpdateModSettingLists()
}

void function SendTextPanelChanges( var textPanel )
{
	int newSetting = int(Hud_GetUTF8Text( textPanel ))
	int index = int(Hud_GetScriptID(textPanel))
	try
	{
		newSetting = int(clamp(newSetting, 0, 255))

		_MS_Slider slider = file.sliders[index]
		_MS_Slider_SetValue(slider, newSetting.tofloat())

		UpdateColor()
	}
	catch ( ex )
	{
		// ThrowInvalidValue( "This part of color is an integer, and only accepts whole numbers(0..1..255)." )
		ResetColor(index)
		
	}
}

void function OnSliderChange( var button )
{
	int index = int(Hud_GetScriptID(button))
	int val = int(Hud_SliderControl_GetCurrentValue( button ))

	var textPanel = file.textFields[index]
	Hud_SetText( textPanel, string( val ) )
	UpdateColor()
}

// write to convar
void function UpdateColor()
{

	try {
		ColorsToConvar()

		array < int > c = ColorsFromConvar()
		int alpha = c.len() == 4 ? c[3] : 255

		Hud_SetColor(file.colorImage, c[0], c[1], c[2], alpha)
	}
	catch ( ex )
	{
		printt("Failed to UpdateColor", ex)
		// ThrowInvalidValue("This setting is a color, and only accepts a trio of numbers - you put something we could not parse!\n\n( Use \".\" for the int like \"255 255 255\", not \",\". )")
	}
}
void function ResetColors() {
	for (int i = 0; i < 4; i++) {
		ResetColor(i)
	}
}

void function ResetColor(int index)
{
	array < int > c = file.color
	if (c.len() >= 3) {
		var textPanel = file.textFields[index]
		MS_Slider slider = file.sliders[index]

		Hud_SetText( textPanel, string(c[index]) )
		MS_Slider_SetValue(slider, c[index].tofloat())

		int alpha = c.len() == 4 ? c[3] : 255
		Hud_SetColor(file.colorImage, c[0], c[1], c[2], alpha)

		UpdateColor()

	}
}




array<int> function ColorsFromConvar()
{
	string convar = GetConVarString("modemenu_current_color_convar")
	array<int> c
	if (convar != "") {
		try {
			array<string> tokens = split( GetConVarString(convar), " " )

			// Assert(tokens.len() == 3)
			if (tokens.len() < 3) {
				throw "Convar " + convar + ": " + GetConVarString(convar) + "is not a trio/four of numbers"
			// printt("Failed to ColorsFromConvar. With Convar", convar, ":",GetConVarString(convar))

			}

			for (int i = 0; i < tokens.len(); i++) {
				c.append(int(clamp(tokens[i].tointeger(), 0, 255)))
			}

			if (tokens.len() == 3) {
				c.append(255)
			}
		}
		catch ( ex )
		{
			printt("Failed to ColorsFromConvar. With Convar", convar, ":",GetConVarString(convar) , ex)
			// ThrowInvalidValue("This setting is a color, and only accepts a trio of numbers - you put something we could not parse!\n\n( Use \".\" for the int like \"255 255 255\", not \",\". )")
		}
	}

	return c
}

void function ColorsToConvar()
{
	string convar = GetConVarString("modemenu_current_color_convar")
	if (convar != "") {
		try {
			string str = ""
			for (int i = 0; i < 4; i++) {
				str += "" + int(Hud_GetUTF8Text( file.textFields[i] ))
				if (i != 3) {
					str += " "
				}
			}

			SetConVarString(convar, str)
			// printt("ColorPicker write ConVar", GetConVarString("modemenu_current_color_convar"), "With " + str)

		}
		catch ( ex )
		{
			printt("Failed to ColorsToConvar. With Convar", convar, ":",GetConVarString(convar) , ex)
			// ThrowInvalidValue("This setting is a color, and only accepts a four of numbers - you put something we could not parse!\n\n( Use \".\" for the int like \"255 255 255\", not \",\". )")
		}
	}
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


void function OnScreen_BGActivate( var button )
{
    CloseSubmenu()
	printt("Close ColorPicker")
}
