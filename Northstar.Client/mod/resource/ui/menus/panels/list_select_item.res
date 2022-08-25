"resource/ui/menus/panels/list_select_item.res"
{
	ItemImage
	{
		ControlName RuiPanel
		wide %20
		tall %20
		visible 1
		scaleImage 1
		zpos 0

		// Hud_GetRui() requires this to work
		rui "ui/basic_image_add.rpak"
	}
	ItemForeground
	{
		ControlName				Label
		xpos					0
		ypos					0
		wide					%100
		tall					%100
		labelText				""
		bgcolor_override		"1 0 0 227"
		visible					1
		paintbackground			1

		pin_to_sibling ItemImage
		pin_corner_to_sibling TOP_LEFT
		pin_to_sibling_corner TOP_LEFT
	}
	ItemName
	{
		ControlName Label
		wide %20
		tall %20

		labelText "forwardbase kodaiiiiii"
		use_proportional_insets 1
		textinsetx 2
		font Default_21_DropShadow
		allcaps 1
		fgcolor_override "255 255 255 255"

		pin_to_sibling ItemImage
		pin_corner_to_sibling BOTTOM_RIGHT
		pin_to_sibling_corner BOTTOM_RIGHT
	}
}