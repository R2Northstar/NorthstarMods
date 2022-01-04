globalize_all_functions

#if SERVER
global const int ANNOUNCEMENT_STYLE_BIG = 0
global const int ANNOUNCEMENT_STYLE_QUICK = 1
global const int ANNOUNCEMENT_STYLE_SWEEP = 5
global const int ANNOUNCEMENT_STYLE_RESULTS = 6

global const string SFX_HUD_ANNOUNCE_STANDARD = "HUD_center_announcement_standard_1P"
global const string SFX_HUD_ANNOUNCE_QUICK 	  = "HUD_center_announcement_no_animation_1P"

global struct AnnouncementData {
	string messageText = "#EMPTY_STRING"
	string subText = ""
	vector titleColor = <0.0, 0.0, 0.0>
	bool hideOnDeath = true
	float duration = -1.0
	bool purge = false

	// max. 5
	// "", "", "", "", ""
	array<string> optionalTextArgs = []
	array<string> optionalSubTextArgs = []

	int priority = 0
	asset icon = $""
	// vector iconAspect = <0, 0, 0>
	string soundAlias = ""
	int announcementStyle = -1
	int sortKey = -1
	bool drawOverScreenFade = false
}
#endif

void function UMP_Announcement_PreInit()
{
#if CLIENT
	UMP_RPC_SetFunctionCallback("UMP_CL_CreateAnnouncement", UMP_CL_CreateAnnouncement)
#endif
}

#if SERVER
void function AnnouncementFromClass(entity player, AnnouncementData announcementData)
{
	if (!IsValid(player) || IsDisconnected(player))
		return

	table<var, var> optionalSettings = {}

	if (announcementData.subText.len() > 0)
		optionalSettings["sT"] <- announcementData.subText

	if (announcementData.titleColor != ZERO_VECTOR) {
		optionalSettings["tCX"] <- announcementData.titleColor.x
		optionalSettings["tCY"] <- announcementData.titleColor.y
		optionalSettings["tCZ"] <- announcementData.titleColor.z
	}

	if (!announcementData.hideOnDeath)
		optionalSettings["hOD"] <- announcementData.hideOnDeath

	if (announcementData.duration != -1.0)
		optionalSettings["d"] <- announcementData.duration

	if (announcementData.purge)
		optionalSettings["pu"] <- announcementData.purge

	if (announcementData.optionalTextArgs.len() > 0)
		for (int i = 0; i < announcementData.optionalTextArgs.len(); i++)
			optionalSettings["oTA" + i] <- announcementData.optionalTextArgs[i]

	if (announcementData.optionalSubTextArgs.len() > 0)
		for (int i = 0; i < announcementData.optionalSubTextArgs.len(); i++)
			optionalSettings["oSTA" + i] <- announcementData.optionalSubTextArgs[i]

	if (announcementData.priority != 0)
		optionalSettings["pr"] <- announcementData.priority
	
	if (string(announcementData.icon).len() > 3)
		optionalSettings["i"] <- announcementData.icon

	if (announcementData.soundAlias.len() > 0)
		optionalSettings["sA"] <- announcementData.soundAlias

	if (announcementData.announcementStyle != -1)
		optionalSettings["aS"] <- announcementData.announcementStyle

	if (announcementData.sortKey != -1)
		optionalSettings["sK"] <- announcementData.sortKey

	if (announcementData.drawOverScreenFade)
		optionalSettings["doSF"] <- announcementData.drawOverScreenFade

	UMP_RPC_CallClientFunction(player, "UMP_CL_CreateAnnouncement",
		announcementData.messageText,
		optionalSettings
	)
}

AnnouncementData function Announcement_Create( string messageText )
{
	AnnouncementData announcement
	announcement.messageText = messageText
	return announcement
}

void function Announcement_SetPurge( AnnouncementData announcement,  bool state )
{
	announcement.purge = state
}

bool function Announcement_GetPurge( AnnouncementData announcement )
{
	return announcement.purge
}

void function Announcement_SetPriority( AnnouncementData announcement,  int priority )
{
	announcement.priority = priority
}

int function Announcement_GetPriority( AnnouncementData announcement )
{
	return announcement.priority
}

void function Announcement_SetSubText( AnnouncementData announcement, string subText )
{
	announcement.subText = subText
}

void function Announcement_SetStyle( AnnouncementData announcement, int style )
{
	announcement.announcementStyle = style
}

vector function NormalizeColorVector( vector colorVector )
{
	if ( colorVector.x > 2.0 || colorVector.y > 2.0 || colorVector.z > 2.0 )
		return colorVector / 255.0

	return colorVector
}

void function Announcement_SetTitleColor( AnnouncementData announcement,  vector titleColor )
{
	announcement.titleColor = NormalizeColorVector( titleColor )
}

void function Announcement_SetHideOnDeath( AnnouncementData announcement,  bool state )
{
	announcement.hideOnDeath = state
}

void function Announcement_SetDuration( AnnouncementData announcement,  float duration )
{
	announcement.duration = max( duration, 3.0 )
}

void function Announcement_SetSoundAlias( AnnouncementData announcement,  string alias )
{
	announcement.soundAlias = alias
}

void function Announcement_SetOptionalTextArgsArray( AnnouncementData announcement,  array<string> args )
{
	// Set these to null just in case someone passes in an array with less than 5 args
	for ( int i = 0; i < announcement.optionalTextArgs.len(); i++ )
		announcement.optionalTextArgs[ i ] = ""

	for ( int i = 0; i < args.len(); i++ )
		announcement.optionalTextArgs[ i ] = args[ i ]
}

void function Announcement_SetOptionalSubTextArgsArray( AnnouncementData announcement,  array<string> args )
{
	// Set these to null just in case someone passes in an array with less than 5 args
	for ( int i = 0; i < announcement.optionalSubTextArgs.len(); i++ )
		announcement.optionalSubTextArgs[ i ] = ""

	for ( int i = 0; i < args.len(); i++ )
		announcement.optionalSubTextArgs[ i ] = args[ i ]
}

void function Announcement_SetIcon( AnnouncementData announcement,  asset image )
{
	announcement.icon = image
}

AnnouncementData function CreateAnnouncementMessageQuick( entity player, string messageText, string subText = "", vector titleColor = <1, 1, 1>, asset icon = $"" )
{
	AnnouncementData announcement = Announcement_Create( messageText )

	announcement.subText = subText
	announcement.titleColor = titleColor
	announcement.icon = icon
	announcement.announcementStyle = ANNOUNCEMENT_STYLE_QUICK
	announcement.soundAlias = SFX_HUD_ANNOUNCE_QUICK

	return announcement
}

void function AnnouncementMessageQuick( entity player, string messageText, string subText = "", vector titleColor = <1, 1, 1>, asset icon = $"" )
{
	AnnouncementData announcement = CreateAnnouncementMessageQuick(player, messageText, subText, titleColor, icon)
	AnnouncementFromClass(player, announcement)
}

AnnouncementData function CreateAnnouncementMessage( entity player, string messageText, string subText = "", vector titleColor = <1, 1, 1> )
{
	AnnouncementData announcement = Announcement_Create( messageText )

	announcement.subText = subText
	announcement.titleColor = titleColor

	return announcement
}

void function AnnouncementMessage( entity player, string messageText, string subText = "", vector titleColor = <1, 1, 1> )
{
	AnnouncementData announcement = CreateAnnouncementMessage(player, messageText, subText, titleColor)
	AnnouncementFromClass(player, announcement)
}

void function AnnouncementMessageSweep( entity player, string messageText, string subText = "", vector titleColor = <1, 1, 1>, asset icon = $"", string soundAlias = SFX_HUD_ANNOUNCE_QUICK )
{
	AnnouncementData announcement = Announcement_Create( messageText )

	announcement.announcementStyle = ANNOUNCEMENT_STYLE_SWEEP
	announcement.icon = icon
	announcement.soundAlias = SFX_HUD_ANNOUNCE_QUICK
	announcement.duration = 2.0
	announcement.soundAlias = soundAlias

	AnnouncementFromClass(player, announcement)
}
#endif

#if CLIENT
// 0 - message text
// r - KV optional arguments
void function UMP_CL_CreateAnnouncement(entity ornull player, array<var> arguments)
{
	const int MANDATORY_ARGUMENTS = 1

	if (arguments.len() < MANDATORY_ARGUMENTS)
		return

	var messageText = arguments[0]
	expect string(messageText)

	AnnouncementData announcementData = Announcement_Create(messageText)

	if (arguments.len() - MANDATORY_ARGUMENTS >= 2) {
		int startIndex = MANDATORY_ARGUMENTS
		table<var, var> optionalSettings = UMP_ArrayToTable(arguments, startIndex)

		if ("sT" in optionalSettings)
			Announcement_SetSubText(announcementData, expect string(optionalSettings["sT"]))

		if ("tCX" in optionalSettings)
			Announcement_SetTitleColor(announcementData, <
				expect float(optionalSettings["tCX"]),
				expect float(optionalSettings["tCY"]),
				expect float(optionalSettings["tCZ"])
			>)

		if ("hOD" in optionalSettings)
			Announcement_SetHideOnDeath(announcementData, expect bool(optionalSettings["hOD"]))

		if ("d" in optionalSettings)
			Announcement_SetDuration(announcementData, expect float(optionalSettings["d"]))

		if ("pu" in optionalSettings)
			Announcement_SetPurge(announcementData, expect bool(optionalSettings["pu"]))

		array<string> optionalTextArgs = ["", "", "", "", ""]
		array<string> optionalSubTextArgs = ["", "", "", "", ""]
		
		for (int i = 0; i < 5; i++) {
			string oTAKey = "oTA" + i
			if (oTAKey in optionalSettings)
				optionalTextArgs.append(expect string(optionalSettings[oTAKey]))

			string oSTAKey = "oSTA" + i
			if (oSTAKey in optionalSettings)
				optionalSubTextArgs.append(expect string(optionalSettings[oSTAKey]))
		}

		Announcement_SetOptionalTextArgsArray(announcementData, optionalTextArgs)
		Announcement_SetOptionalSubTextArgsArray(announcementData, optionalSubTextArgs)

		if ("pr" in optionalSettings)
			Announcement_SetPriority(announcementData, expect int(optionalSettings["pr"]))

		if ("i" in optionalSettings)
			Announcement_SetIcon(announcementData, expect asset(optionalSettings["i"]))

		if ("sA" in optionalSettings)
			Announcement_SetSoundAlias(announcementData, expect string(optionalSettings["sA"]))

		if ("aS" in optionalSettings)
			Announcement_SetStyle(announcementData, expect int(optionalSettings["aS"]))

		if ("sK" in optionalSettings)
			announcementData.sortKey = expect int(optionalSettings["sK"])

		if ("doSF" in optionalSettings)
			announcementData.drawOverScreenFade = expect bool(optionalSettings["doSF"])
	}

	AnnouncementFromClass(GetLocalClientPlayer(), announcementData)
}
#endif