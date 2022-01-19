global function CL_GamemodeSpd_init
global function ServerCallback_SpdSpeedometer_SetWeaponIcon

global function ServerCallback_Spd_Runner_Teammate
global function ServerCallback_Spd_Runner_Teammate_Next
global function ServerCallback_Spd_Runner_You
global function ServerCallback_Spd_Runner_You_Next

void function CL_GamemodeSpd_init()
{
    ClGameState_RegisterGameStateAsset( $"ui/gamestate_info_ffa.rpak" ) // unsure if needed

    // add music for mode, this is copied directly from the mfd music registered in cl_music.gnut
    RegisterLevelMusicForTeam( eMusicPieceID.GAMEMODE_1, "Music_MarkedForDeath_IMC_YouAreMarked", TEAM_IMC )
    RegisterLevelMusicForTeam( eMusicPieceID.GAMEMODE_1, "Music_MarkedForDeath_MCOR_YouAreMarked", TEAM_MILITIA )

	RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_INTRO, "music_mp_mfd_intro_flyin", TEAM_IMC )
	RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_INTRO, "music_mp_mfd_intro_flyin", TEAM_MILITIA )

	RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_WIN, "music_mp_mfd_epilogue_win", TEAM_IMC )
	RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_WIN, "music_mp_mfd_epilogue_win", TEAM_MILITIA )

	RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_DRAW, "music_mp_mfd_epilogue_lose", TEAM_IMC )
	RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_DRAW, "music_mp_mfd_epilogue_lose", TEAM_MILITIA )

	RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_LOSS, "music_mp_mfd_epilogue_lose", TEAM_IMC )
	RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_LOSS, "music_mp_mfd_epilogue_lose", TEAM_MILITIA )

	RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_LAST_MINUTE, "music_mp_mfd_lastminute", TEAM_IMC )
	RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_LAST_MINUTE, "music_mp_mfd_lastminute", TEAM_MILITIA )

	Cl_GGEarnMeter_Init()
}

void function ServerCallback_SpdSpeedometer_SetWeaponIcon()
{
	asset weaponImage

	weaponImage = GetItemImage( "mp_ability_shifter" )
	
	SetEarnMeterRuiImage(weaponImage)
}

void function ServerCallback_Spd_Runner_Teammate(int EncodedEHandle)
{
	entity localPlayer = GetLocalClientPlayer()

	entity cockpit = localPlayer.GetCockpit()

	if ( !cockpit )
		return

	AnnouncementData announcement = Announcement_Create( Localize( "#SPD_RUNNER_TEAMMATE", GetEntityFromEncodedEHandle(EncodedEHandle).GetPlayerName() ) )
	Announcement_SetTitleColor( announcement, <0,0,1> )
	Announcement_SetPurge( announcement, true )
	Announcement_SetPriority( announcement, 200 ) //Be higher priority than Titanfall ready indicator etc
	Announcement_SetSoundAlias( announcement, SFX_HUD_ANNOUNCE_QUICK )
	Announcement_SetStyle( announcement, ANNOUNCEMENT_STYLE_QUICK )
	AnnouncementFromClass( localPlayer, announcement )
}

void function ServerCallback_Spd_Runner_Teammate_Next(int EncodedEHandle)
{
	entity localPlayer = GetLocalClientPlayer()

	entity cockpit = localPlayer.GetCockpit()

	if ( !cockpit )
		return

	AnnouncementData announcement = Announcement_Create(  Localize( "#SPD_RUNNER_TEAMMATE_NEXT", GetEntityFromEncodedEHandle(EncodedEHandle).GetPlayerName() ) )
	Announcement_SetTitleColor( announcement, <0,0,1> )
	Announcement_SetPurge( announcement, true )
	Announcement_SetPriority( announcement, 200 ) //Be higher priority than Titanfall ready indicator etc
	Announcement_SetSoundAlias( announcement, SFX_HUD_ANNOUNCE_QUICK )
	Announcement_SetStyle( announcement, ANNOUNCEMENT_STYLE_QUICK )
	AnnouncementFromClass( localPlayer, announcement )
}

void function ServerCallback_Spd_Runner_You()
{
	entity localPlayer = GetLocalClientPlayer()

	entity cockpit = localPlayer.GetCockpit()

	if ( !cockpit )
		return

	AnnouncementData announcement = Announcement_Create( Localize( "#SPD_RUNNER_YOU" ) )
	Announcement_SetTitleColor( announcement, <1,0,0> )
	Announcement_SetPurge( announcement, true )
	Announcement_SetPriority( announcement, 200 ) //Be higher priority than Titanfall ready indicator etc
	Announcement_SetSoundAlias( announcement, SFX_HUD_ANNOUNCE_QUICK )
	Announcement_SetStyle( announcement, ANNOUNCEMENT_STYLE_QUICK )
	AnnouncementFromClass( localPlayer, announcement )
}

void function ServerCallback_Spd_Runner_You_Next()
{
	entity localPlayer = GetLocalClientPlayer()

	entity cockpit = localPlayer.GetCockpit()

	if ( !cockpit )
		return

	AnnouncementData announcement = Announcement_Create( Localize( "#SPD_RUNNER_YOU_NEXT" ) )
	Announcement_SetTitleColor( announcement, <1,0,0> )
	Announcement_SetPurge( announcement, true )
	Announcement_SetPriority( announcement, 200 ) //Be higher priority than Titanfall ready indicator etc
	Announcement_SetSoundAlias( announcement, SFX_HUD_ANNOUNCE_QUICK )
	Announcement_SetStyle( announcement, ANNOUNCEMENT_STYLE_QUICK )
	AnnouncementFromClass( localPlayer, announcement )
}