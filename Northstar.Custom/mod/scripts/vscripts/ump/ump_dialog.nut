global function UMP_Dialog_PreInit

#if SERVER
global function UMP_OpenDialog
global function UMP_AddDialogButton

global struct UMPDialogButtonData {
	string label
	void functionref(entity, string) activateFunc
	string focusMessage
	bool startFocused
}

global struct UMPDialogData {
	string header
	string message
	
	array messageColor = []
	
	asset image = $""
	asset rightImage = $""

	bool forceChoice = false
	bool noChoice = false
	bool showSpinner = false
	bool darkenBackground = false

	array<UMPDialogButtonData> buttonData = []

	entity player
	int id = -1
}

struct {
	int stateIndex = 1
	table<int, UMPDialogData> dialogStates
} file

int function GetNewState()
{
	return file.stateIndex++
}
#endif

void function UMP_Dialog_PreInit()
{
#if UI
	UMP_RPC_SetFunctionCallback("UMP_UI_CreateDialog", UMP_UI_CreateDialog)
#endif

#if SERVER
	UMP_RPC_SetFunctionCallback("UMP_SV_DialogCallback", UMP_SV_DialogCallback)
#endif
}

#if SERVER
void function UMP_SV_DialogCallback(entity ornull player, array<var> arguments)
{
	if (player == null)
		return

	expect entity(player)

	if (!IsValid(player))
		return

	// state, choice
	if (arguments.len() < 2)
		return

	var stateId = arguments[0]
	if (type(stateId) != "int")
		return
	expect int(stateId)

	var choiceId = arguments[1]
	if (type(choiceId) != "int")
		return
	expect int(choiceId)

	if (!(stateId in file.dialogStates))
		return

	UMPDialogData dialogData = file.dialogStates[stateId]
	if (dialogData.player != player)
		return

	if (choiceId <= 0 || choiceId > dialogData.buttonData.len())
		return

	UMPDialogButtonData buttonData = dialogData.buttonData[choiceId - 1]
	
	if (buttonData.activateFunc != null)
		buttonData.activateFunc(player, buttonData.label)

	delete file.dialogStates[stateId]
}

UMPDialogButtonData function UMP_AddDialogButton(UMPDialogData dialogData, string label, void functionref(entity, string) activateFunc = null, string focusMessage = "", bool startFocused = false)
{
	UMPDialogButtonData newButtonData

	newButtonData.label = label
	newButtonData.activateFunc = activateFunc
	newButtonData.focusMessage = focusMessage
	newButtonData.startFocused = startFocused

	dialogData.buttonData.append(newButtonData)
	return newButtonData
}

void function UMP_OpenDialog(entity player, UMPDialogData dialogData)
{
	if (!IsValid(player) || IsDisconnected(player))
		return

	dialogData.id = GetNewState()
	dialogData.player = player

	array<var> buttons = []

	foreach (UMPDialogButtonData button in dialogData.buttonData) {
		buttons.append(button.label)
		buttons.append(button.focusMessage)
		buttons.append(button.startFocused)
	}

	table<var, var> optionalSettings = {}

	if (dialogData.messageColor.len() >= 4) {
		optionalSettings["mR"] <- dialogData.messageColor[0]
		optionalSettings["mG"] <- dialogData.messageColor[1]
		optionalSettings["mB"] <- dialogData.messageColor[2]
		optionalSettings["mA"] <- dialogData.messageColor[3]
	}

	if (string(dialogData.image).len() > 3)
		optionalSettings["i"] <- dialogData.image

	if (dialogData.forceChoice)
		optionalSettings["fC"] <- dialogData.forceChoice

	if (dialogData.noChoice)
		optionalSettings["nC"] <- dialogData.noChoice

	if (dialogData.showSpinner)
		optionalSettings["sS"] <- dialogData.showSpinner

	if (dialogData.darkenBackground)
		optionalSettings["dB"] <- dialogData.darkenBackground

	UMP_RPC_CallUIFunction(player, "UMP_UI_CreateDialog", 
		dialogData.id,
		dialogData.header,
		dialogData.message,

		dialogData.buttonData.len(),
		buttons,
		
		optionalSettings
	)

	file.dialogStates[dialogData.id] <- dialogData
}
#endif

#if UI
// Arguments data:
// 0 - dialog ID
// 1 - header
// 2 - message
// 3 - button amount
// [x for button_amount] - button name, focus message, start focused
// r - KV optional settings
void function UMP_UI_CreateDialog(entity ornull player, array<var> arguments)
{
	const int MANDATORY_ARGUMENTS = 4

	if (arguments.len() < MANDATORY_ARGUMENTS)
		return

	DialogData dialogData

	var dialogID = arguments[0]
	expect int(dialogID)

	var header = arguments[1]
	expect string(header)

	var message = arguments[2]
	expect string(message)

	dialogData.header = header
	dialogData.message = message

	var buttonsAmount = arguments[3]
	expect int(buttonsAmount)

	for (int i = MANDATORY_ARGUMENTS; i < MANDATORY_ARGUMENTS + (buttonsAmount * 3); i += 3) {
		var choice = arguments[i]
		expect string(choice)

		var focusMessage = arguments[i + 1]
		expect string(focusMessage)

		var startFocused = arguments[i + 2]
		expect bool(startFocused)

		AddDialogButton(dialogData, choice, void function() : (dialogID, i) {
			int buttonIndex = i - 3
			printt("Option selected for dialog", dialogID, ":", buttonIndex)
			UMP_RPC_CallServerFunction("UMP_SV_DialogCallback", dialogID, buttonIndex)
		}, focusMessage, startFocused)
	}

	if (arguments.len() - MANDATORY_ARGUMENTS >= 2) {
		int startIndex = (MANDATORY_ARGUMENTS + buttonsAmount)
		table<var, var> optionalSettings = UMP_ArrayToTable(arguments, startIndex)
	
		if ("mR" in optionalSettings)
			dialogData.messageColor = [
				expect int(optionalSettings["mR"]),
				expect int(optionalSettings["mG"]),
				expect int(optionalSettings["mB"]),
				expect int(optionalSettings["mA"]),
			]
	
		if ("i" in optionalSettings)
			dialogData.image = expect asset(optionalSettings["i"])

		if ("fC" in optionalSettings)
			dialogData.forceChoice = expect bool(optionalSettings["fC"])

		if ("nC" in optionalSettings)
			dialogData.noChoice = expect bool(optionalSettings["nC"])

		if ("sS" in optionalSettings)
			dialogData.showSpinner = expect bool(optionalSettings["sS"])

		if ("dB" in optionalSettings)
			dialogData.darkenBackground = expect bool(optionalSettings["dB"])

		// if ("rightImage" in optionalSettings)
		//	dialogData.rightImage = expect asset(optionalSettings["rightImage"])
	}

	OpenDialog(dialogData)
}
#endif