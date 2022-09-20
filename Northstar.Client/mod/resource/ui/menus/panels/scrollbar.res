resource/ui/menus/panels/scrollbar.res
{
		SliderCover
		{
			ControlName			RuiButton
			InheritProperties	RuiSmallButton

			wide	50
			tall	50
			zpos	2

			drawColor	"255 255 255 128"
		}

		MouseMovementCapture
		{
			ControlName	CMouseMovementCapturePanel
				
			wide	50
			tall	50
			zpos	1
		}

		SliderButton
		{
			ControlName			RuiButton
			InheritProperties	RuiSmallButton
			
			wide	50
			tall	50
			zpos	0

			image		"vgui/hud/white"
			drawColor	"255 255 255 128"
		}

		BtnModListSliderPanel
		{
			ControlName	RuiPanel
			
			wide	50
			tall	50
			zpos	-1

			rui		"ui/knowledgebase_panel.rpak"
		}
}