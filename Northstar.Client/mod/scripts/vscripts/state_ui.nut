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
        //print("UPDATING FROM UI")
        NSUpdateGameStateUI(GetActiveLevel(), Localize(GetMapDisplayName(GetActiveLevel())), GetConVarString("mp_gamemode"), Localize(GetPlaylistDisplayName(GetConVarString("mp_gamemode"))), IsFullyConnected())
        wait 1.0
    }
}