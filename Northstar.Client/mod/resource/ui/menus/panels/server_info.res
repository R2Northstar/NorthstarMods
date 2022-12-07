resource/ui/menus/panels/server_info.res
{
        ServerName
        {
            ControlName Label
            labelText   "#INFO_UNAVAILABLE"

            wide    %23
            tall    %13
            wrap    1

			pin_to_sibling			ButtonRowAnchor
			pin_corner_to_sibling 	TOP_LEFT
			pin_to_sibling_corner 	BOTTOM_LEFT
        }

        ServerDescription
        {
            ControlName Label
            labelText   "#INFO_UNAVAILABLE"

            wide    %23
            tall    %25
            wrap    1

			pin_to_sibling			ServerName
			pin_corner_to_sibling 	TOP_LEFT
			pin_to_sibling_corner 	BOTTOM_LEFT
        }

        MaxPlayers
        {
            ControlName Label
            labelText   "#INFO_UNAVAILABLE"

            wide    %23
            tall    50

			pin_to_sibling			ServerDescription
			pin_corner_to_sibling 	TOP_LEFT
			pin_to_sibling_corner 	BOTTOM_LEFT
        }

        PlayerPing
        {
            ControlName Label
            labelText   "#INFO_UNAVAILABLE"

            wide    %23
            tall    50

			pin_to_sibling			MaxPlayers
			pin_corner_to_sibling 	TOP_LEFT
			pin_to_sibling_corner 	BOTTOM_LEFT
        }

        BackgroundPanel
        {
            ControlName RuiPanel

            wide    %25
            tall    %50
            xpos    %-2
            zpos    -1
            rui     "ui/knowledgebase_panel.rpak"
        }
    }
}
