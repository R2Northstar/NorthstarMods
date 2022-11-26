untyped
globalize_all_functions

struct UIPresenceStruct {
	bool isLoading
	bool isLobby
	string loadingLevel
	string loadedLevel
}

void function GenerateUIPresence() {
	UIPresenceStruct uis

	uis.isLoading = uiGlobal.isLoading
	uis.isLobby = IsLobby()
	uis.loadingLevel = uiGlobal.loadingLevel
	uis.loadedLevel = uiGlobal.loadedLevel
	NSPushUIPresence(uis)
}