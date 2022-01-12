global function ClGamemodePilot_Init
global function ServerCallback_YouArePilot
global function ServerCallback_AnnouncePilot
global function ServerCallback_PilotDamageTaken
global function ServerCallback_ShowPilotHealthUI
global function ServerCallback_HidePilotHealthUI

global var healthRui

void function ClGamemodePilot_Init()
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

void function ServerCallback_YouArePilot()
{
	// heavily based on mfd code
	entity localPlayer = GetLocalViewPlayer()

	StartParticleEffectOnEntity( localPlayer.GetCockpit(), GetParticleSystemIndex( $"P_MFD" ), FX_PATTACH_ABSORIGIN_FOLLOW, -1 )
	EmitSoundOnEntity( localPlayer, "UI_InGame_MarkedForDeath_PlayerMarked"  )
	HideEventNotification()
	AnnouncementData announcement = Announcement_Create( "#PILOT_YOU_ARE_PILOT" )
	Announcement_SetSubText( announcement, "#PILOT_KILL_GRUNTS" )
	Announcement_SetTitleColor( announcement, <1,0,0> )
	Announcement_SetPurge( announcement, true )
	Announcement_SetPriority( announcement, 200 ) //Be higher priority than Titanfall ready indicator etc
	Announcement_SetSoundAlias( announcement, SFX_HUD_ANNOUNCE_QUICK )
	Announcement_SetStyle( announcement, ANNOUNCEMENT_STYLE_QUICK )
	AnnouncementFromClass( localPlayer, announcement )
}

void function ServerCallback_PilotDamageTaken( int remainingHP )
{
	// heavily based on mfd code
	/**
	entity localPlayer = GetLocalViewPlayer()
	string health = remainingHP.tostring()
	AnnouncementData announcement = Announcement_Create( health + " Health remaining" )
	Announcement_SetTitleColor( announcement, <1,0,0> )
	Announcement_SetPurge( announcement, true )
	Announcement_SetPriority( announcement, 200 ) //Be higher priority than Titanfall ready indicator etc
	Announcement_SetSoundAlias( announcement, SFX_HUD_ANNOUNCE_QUICK )
	Announcement_SetStyle( announcement, ANNOUNCEMENT_STYLE_QUICK )
	AnnouncementFromClass( localPlayer, announcement )
	**/
}

void function ServerCallback_AnnouncePilot( int survivorEHandle )
{
	entity player = GetEntityFromEncodedEHandle( survivorEHandle )

	AnnouncementData announcement = Announcement_Create( Localize( "#PILOT_REVEAL_PILOT", player.GetPlayerName() ) )
	//Announcement_SetSubText( announcement, "#PILOT_WORK_TOGETHER" )
	Announcement_SetTitleColor( announcement, <1,0,0> )
	Announcement_SetPurge( announcement, true )
	Announcement_SetPriority( announcement, 200 ) //Be higher priority than Titanfall ready indicator etc
	Announcement_SetSoundAlias( announcement, SFX_HUD_ANNOUNCE_QUICK )
	Announcement_SetStyle( announcement, ANNOUNCEMENT_STYLE_QUICK )
	AnnouncementFromClass( GetLocalViewPlayer(), announcement )
}

struct
{
	int healthPerSegment = 20
	bool healthVisible = false
	var healthRui
} file

void function ServerCallback_ShowPilotHealthUI(int healthPerSegment = 20)
{
	file.healthPerSegment = healthPerSegment
	print("we are getting there")
	entity player = GetLocalViewPlayer()
	if ( file.healthRui == null ) {
		file.healthRui = CreateCockpitRui( $"ui/ajax_cockpit_base.rpak" )
		healthRui = file.healthRui

		RuiTrackFloat3( file.healthRui, "playerOrigin", player, RUI_TRACK_ABSORIGIN_FOLLOW )
		RuiTrackFloat3( file.healthRui, "playerEyeAngles", player, RUI_TRACK_EYEANGLES_FOLLOW )
		RuiTrackFloat( file.healthRui, "healthFrac", player, RUI_TRACK_HEALTH )
		RuiTrackFloat( file.healthRui, "shieldFrac", player, RUI_TRACK_SHIELD_FRACTION )

		RuiSetBool( file.healthRui, "ejectIsAllowed", false ) // You need this or the entire rui doesn't show up, fun!

		float health = player.GetPlayerModHealth()
		RuiSetInt( file.healthRui, "numHealthSegments", int( health / file.healthPerSegment ) )

		RuiTrackFloat( file.healthRui, "cockpitColor", player, RUI_TRACK_STATUS_EFFECT_SEVERITY, eStatusEffect.cockpitColor )
	}

	file.healthVisible = true
	RuiSetDrawGroup( file.healthRui, RUI_DRAW_COCKPIT )

	thread PilotHealthChangedThink( player )
}

void function ServerCallback_HidePilotHealthUI()
{
	file.healthVisible = false

	if (file.healthRui != null)
		RuiSetDrawGroup( file.healthRui, RUI_DRAW_NONE )
}

void function PilotHealthChangedThink( entity player )
{
	while ( file.healthVisible )
	{
		table results = WaitSignal( player, "HealthChanged" )

		if ( !IsAlive( player ) )
			continue

		float maxHealth = player.GetPlayerModHealth()
		RuiSetInt( file.healthRui, "numHealthSegments", int( maxHealth / file.healthPerSegment ) )

		float oldHealthFrac = float( results.oldHealth ) / maxHealth 
		float newHealthFrac = float( results.newHealth ) / maxHealth

		if ( oldHealthFrac > newHealthFrac )
		{
			var rui = CreateCockpitRui( $"ui/ajax_cockpit_lost_health_segment.rpak", 10 )
			RuiSetGameTime( rui, "startTime", Time() )
			RuiSetFloat( rui, "oldHealthFrac", oldHealthFrac )
			RuiSetFloat( rui, "newHealthFrac", newHealthFrac )

			RuiSetInt( rui, "numHealthSegments", int( maxHealth / file.healthPerSegment ) )
		} else {
			RuiSetGameTime( file.healthRui, "startFlashTime", Time() )
			RuiSetFloat3( file.healthRui, "flashColor", <0.0,1.0,0.0> )
		}
	}
}

