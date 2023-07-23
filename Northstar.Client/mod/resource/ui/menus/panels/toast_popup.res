resource/ui/menus/panels/toast_popup.res
{
	Frame
	{
		ControlName	ImagePanel

		tall		100
		auto_wide_tocontents	1

		image		vgui/hud/white
		drawcolor	"0 0 0 240"
		scaleImage	1
	}

	Image
	{
		ControlName	RuiPanel

		wide	50
		tall	50

		xpos	-20
		rui		"ui/basic_image.rpak" // The rui of an ruipanel needs to end with .rpak. Don't ask.

		pin_to_sibling			Frame
		pin_to_sibling_corner	LEFT
		pin_corner_to_sibling	LEFT
	}

	Text
	{
		ControlName	Label

		tall		100
		auto_wide_tocontents	1

		xpos					20
		labelText				"#INCORRECT_MOD_INSTALL_TOAST"
		
		pin_to_sibling			Image
		pin_to_sibling_corner	RIGHT
		pin_corner_to_sibling	LEFT
	}

	Button
	{
		ControlName				RuiButton

		tall		100
		labelText	""

		pin_to_sibling			Frame
		pin_to_sibling_corner	CENTER
		pin_corner_to_sibling	CENTER
	}
}