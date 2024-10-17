#base "../combo_buttons.res"
"resource/ui/menus/panels/mainmenu.res"
{
    // Quit Button
    MainMenuButton0
    {
        ControlName				RuiButton
        InheritProperties		RuiSmallButton
        classname 				MainMenuButtonClass
        scriptID				0
        visible					0

        navUp					MainMenuButton6
        navDown					MainMenuButton1

        pin_to_sibling			ButtonRow3x0
        pin_corner_to_sibling	TOP_LEFT
        pin_to_sibling_corner	BOTTOM_LEFT
    }
}