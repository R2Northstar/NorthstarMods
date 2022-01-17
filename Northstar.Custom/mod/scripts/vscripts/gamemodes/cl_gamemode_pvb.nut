global function ClGamemodePVB_Init
global function ServerCallback_YouAreBoss
global function ServerCallback_AnnounceBoss
global function ServerCallback_YouAreAmped
global function ServerCallback_AnnounceAmped
global function ServerCallback_AnnounceAmpedToBoss

void function ClGamemodePVB_Init()
{
    // add ffa gamestate asset
	// ClGameState_RegisterGameStateAsset( $"ui/gamestate_info_ffa.rpak" )

	// add music for mode, this is copied directly from the ffa/fra music registered in cl_music.gnut
	RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_INTRO, "music_mp_freeagents_intro", TEAM_IMC )
	RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_INTRO, "music_mp_freeagents_intro", TEAM_MILITIA )

	RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_WIN, "music_mp_freeagents_outro_win", TEAM_IMC )
	RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_WIN, "music_mp_freeagents_outro_win", TEAM_MILITIA )

	RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_DRAW, "music_mp_freeagents_outro_lose", TEAM_IMC )
	RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_DRAW, "music_mp_freeagents_outro_lose", TEAM_MILITIA )

	RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_LOSS, "music_mp_freeagents_outro_lose", TEAM_IMC )
	RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_LOSS, "music_mp_freeagents_outro_lose", TEAM_MILITIA )

	RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_THREE_MINUTE, "music_mp_freeagents_almostdone", TEAM_IMC )
	RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_THREE_MINUTE, "music_mp_freeagents_almostdone", TEAM_MILITIA )

	RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_LAST_MINUTE, "music_mp_freeagents_lastminute", TEAM_IMC )
	RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_LAST_MINUTE, "music_mp_freeagents_lastminute", TEAM_MILITIA )
}

void function ServerCallback_YouAreBoss()
{
	entity localPlayer = GetLocalViewPlayer()

	StartParticleEffectOnEntity( localPlayer.GetCockpit(), GetParticleSystemIndex( $"P_MFD" ), FX_PATTACH_ABSORIGIN_FOLLOW, -1 )
	EmitSoundOnEntity( localPlayer, "UI_InGame_MarkedForDeath_PlayerMarked"  )
	HideEventNotification()
	AnnouncementData announcement = Announcement_Create( "#PVB_YOU_ARE_BOSS" )
	Announcement_SetSubText( announcement, "#PVB_KILL_PILOTS" )
	Announcement_SetTitleColor( announcement, <1,0,0> )
	Announcement_SetPurge( announcement, true )
	Announcement_SetPriority( announcement, 200 )
	Announcement_SetSoundAlias( announcement, SFX_HUD_ANNOUNCE_QUICK )
	Announcement_SetStyle( announcement, ANNOUNCEMENT_STYLE_QUICK )
	AnnouncementFromClass( localPlayer, announcement )
}

void function ServerCallback_AnnounceBoss( int survivorEHandle )
{
	entity player = GetEntityFromEncodedEHandle( survivorEHandle )

	AnnouncementData announcement = Announcement_Create( Localize( "#PVB_BOSS_IS", player.GetPlayerName() ) )
	Announcement_SetSubText( announcement, "#PVB_KILL_BOSS" )
	Announcement_SetTitleColor( announcement, <1,0,0> )
	Announcement_SetPurge( announcement, true )
	Announcement_SetPriority( announcement, 200 )
	Announcement_SetSoundAlias( announcement, SFX_HUD_ANNOUNCE_QUICK )
	Announcement_SetStyle( announcement, ANNOUNCEMENT_STYLE_QUICK )
	AnnouncementFromClass( GetLocalViewPlayer(), announcement )
}

void function ServerCallback_YouAreAmped()
{
	// fix this later
	entity localPlayer = GetLocalViewPlayer()

	StartParticleEffectOnEntity( localPlayer.GetCockpit(), GetParticleSystemIndex( $"P_MFD" ), FX_PATTACH_ABSORIGIN_FOLLOW, -1 )
	EmitSoundOnEntity( localPlayer, "UI_InGame_MarkedForDeath_PlayerMarked"  )
	HideEventNotification()
	AnnouncementData announcement = Announcement_Create( "#PVB_YOU_ARE_AMPED" )
	Announcement_SetSubText( announcement, "#PVB_AMPED_KILL_BOSS" )
	Announcement_SetTitleColor( announcement, <1,0,0> )
	Announcement_SetPurge( announcement, true )
	Announcement_SetPriority( announcement, 200 )
	Announcement_SetSoundAlias( announcement, SFX_HUD_ANNOUNCE_QUICK )
	Announcement_SetStyle( announcement, ANNOUNCEMENT_STYLE_QUICK )
	AnnouncementFromClass( localPlayer, announcement )
}

void function ServerCallback_AnnounceAmped( int survivorEHandle )
{
	entity player = GetEntityFromEncodedEHandle( survivorEHandle )

	AnnouncementData announcement = Announcement_Create( Localize( "#PVB_AMPED_IS", player.GetPlayerName() ) )
	Announcement_SetSubText( announcement, "#PVB_KILL_BOSS" )
	Announcement_SetTitleColor( announcement, <1,0,0> )
	Announcement_SetPurge( announcement, true )
	Announcement_SetPriority( announcement, 200 )
	Announcement_SetSoundAlias( announcement, SFX_HUD_ANNOUNCE_QUICK )
	Announcement_SetStyle( announcement, ANNOUNCEMENT_STYLE_QUICK )
	AnnouncementFromClass( GetLocalViewPlayer(), announcement )
}

void function ServerCallback_AnnounceAmpedToBoss( int survivorEHandle )
{
	entity player = GetEntityFromEncodedEHandle( survivorEHandle )

	AnnouncementData announcement = Announcement_Create( Localize( "#PVB_AMPED_IS", player.GetPlayerName() ) )
	Announcement_SetSubText( announcement, "#PVB_BOSS_KILL_AMPED" )
	Announcement_SetTitleColor( announcement, <1,0,0> )
	Announcement_SetPurge( announcement, true )
	Announcement_SetPriority( announcement, 200 )
	Announcement_SetSoundAlias( announcement, SFX_HUD_ANNOUNCE_QUICK )
	Announcement_SetStyle( announcement, ANNOUNCEMENT_STYLE_QUICK )
	AnnouncementFromClass( GetLocalViewPlayer(), announcement )
}