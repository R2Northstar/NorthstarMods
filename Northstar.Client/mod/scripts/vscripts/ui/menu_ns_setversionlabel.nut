untyped
global function NS_SetVersionLabel

void function NS_SetVersionLabel()
{
    if( NSIsModEnabled( "Northstar.Custom" ) ) //Checks if Northstar.Custom is enabled for pulling version data.
    {
        var mainMenu = GetMenu( "MainMenu" ) //Gets main menu element
        var versionLabel = GetElementsByClassname( mainMenu, "nsVersionClass" )[0] //Gets the label from the mainMenu element.
        Hud_SetText( versionLabel, "Northstar v" + NSGetModVersionByModName("Northstar.Custom")) //Sets the label text (Getting Northstar version from Northstar.Custom)
    }
}