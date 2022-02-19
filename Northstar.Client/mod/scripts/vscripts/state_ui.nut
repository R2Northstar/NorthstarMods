untyped

globalize_all_functions

void function NSUpdateGameStateUIStart() {
    thread NSUpdateGameStateLoopUI()
}

void function NSUpdateGameStateLoopUI() {
    while (true) {
        // gamemode and name
        // Localize(GetPlaylistDisplayName(GetCurrentPlaylistName()))

        // map and mapname
        // Localize(GetMapDisplayName(GetActiveLevel()))
        wait 1.0
        print("TEST FROM UI")
        if (uiGlobal.loadedLevel == "") {
            //print("NOT FULLY CONNECTED")
            //NSUpdateGameStateUI("northstar", "Loading...", "Loading...", "Loading...", true)
            if (uiGlobal.isLoading)
                NSSetLoading(true)
            else {
                NSSetLoading(false)
                NSUpdateGameStateUI("", "", "", "", true, false)
            }
            continue
        }
        NSSetLoading(false)
        NSUpdateGameStateUI(GetActiveLevel(), Localize(GetMapDisplayName(GetActiveLevel())), GetConVarString("mp_gamemode"), Localize(GetPlaylistDisplayName(GetConVarString("mp_gamemode"))), IsFullyConnected(), false)
    }
}