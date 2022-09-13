untyped
global function nscnRuiPrecache


void function nscnRuiPrecache(){
    // AddCreateTitanCockpitCallback(nscnRuiInit)
	// AddCreatePilotCockpitCallbackllback(nscnRuiInit)
	thread nscnRuiInit()
}

var NS = null
string strr = ""

void function nscnRuiInit(){
    WaitFrame()

	string playerName = GetLocalClientPlayer().GetPlayerName()
	string playerUID = NSGetLocalPlayerUID()

    strr += "NorthStarCN\n   "
	strr += playerName
	strr +="\n"
	// strr += playerUID
	strr += playerUID
  	// NS = RuiCreate( $"ui/cockpit_console_text_top_left.rpak", clGlobal.topoCockpitHudPermanent, RUI_DRAW_COCKPIT, -1 )
	// RuiSetInt(NS, "maxLines", 1)
	// RuiSetInt(NS, "lineNum", 1)
	// RuiSetFloat2(NS, "msgPos", <0.0, 0.25, 0.0>)
	// RuiSetString(NS, "msgText", strr)
	// RuiSetFloat(NS, "msgFontSize", 25.0)
	// RuiSetFloat(NS, "msgAlpha", 1.0)
	// //RuiSetFloat(sus, "thicken", 1.0)
	// RuiSetFloat3(NS, "msgColor", <1.0, 1.0, 1.0>)

	string topText = ""
	topText += "NSCN Client:"
	topText += playerName
	topText += " "
	topText += playerUID

	var rui = RuiCreate($"ui/cockpit_console_text_top_left.rpak", clGlobal.topoFullScreen, RUI_DRAW_HUD, -1)
    RuiSetString(rui, "msgText", topText)
    RuiSetInt(rui, "lineNum", 1)
    RuiSetFloat(rui, "msgFontSize", 20)
	RuiSetFloat2(rui, "msgPos", <0.02,0,0.0>)
    RuiSetFloat(rui, "msgAlpha", 1.0)
    // RuiSetFloat(rui, "thicken", settings.bold)
    RuiSetFloat3(rui, "msgColor", <1.0, 1.0, 1.0>)

}









