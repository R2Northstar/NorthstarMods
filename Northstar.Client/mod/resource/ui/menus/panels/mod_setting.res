"resource/ui/menus/panels/mod_setting.res"
{
    BtnMod
    {
		ControlName				Label
        InheritProperties		RuiSmallButton
        labelText               "Mod"

        navRight                EnumSelectButton
        navLeft                 TextEntrySetting

        wide                    510
        tall                    40
        
    }

    EnumSelectButton
    {
        ControlName				RuiButton
        InheritProperties		RuiSmallButton
		style					DialogListButton
        labelText				""

        zpos                    4

        wide                    225
        tall                    40
        scriptID                0

        pin_to_sibling				ResetModToDefault
        pin_corner_to_sibling		TOP_LEFT
        pin_to_sibling_corner		TOP_RIGHT
        
        navLeft                 TextEntrySetting
        navRight                TextEntrySetting
    }
    ResetModToDefault
    {
        ControlName				RuiButton
        InheritProperties		RuiSmallButton
        labelText				"Reset"

        zpos                    4

        wide                    120
        tall                    40
        scriptID                0

        pin_to_sibling				BtnMod
        pin_corner_to_sibling		TOP_LEFT
        pin_to_sibling_corner		TOP_RIGHT
        
        navLeft                 TextEntrySetting
        navRight                TextEntrySetting
    }
    TextEntrySetting
    {
        ControlName				TextEntry
        classname				MatchSettingTextEntry
        xpos                    -35
        ypos					"-5"
        zpos					100 // This works around input weirdness when the control is constructed by code instead of VGUI blackbox.
        wide					160
        tall					30
        scriptID				0
        textHidden				0
        editable				1
        //NumericInputOnly		1
        font 					Default_21
        allowRightClickMenu		0
        allowSpecialCharacters	1
        unicode					0
    
        pin_to_sibling			EnumSelectButton
        pin_corner_to_sibling	TOP_RIGHT
        pin_to_sibling_corner	TOP_RIGHT
        
        navLeft                 EnumSelectButton
        navRight                EnumSelectButton
    }

    // we're getting to the bottom of this :)
    BottomLine
    {
		ControlName				ImagePanel
		InheritProperties		MenuTopBar
        ypos					0
        wide					%100
        pin_to_sibling			BtnMod
        pin_corner_to_sibling	TOP_LEFT
        pin_to_sibling_corner	BOTTOM_LEFT
    }
}