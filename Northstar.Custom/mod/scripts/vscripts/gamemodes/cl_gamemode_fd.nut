global function ClGamemodeFD_Init
global function CLFD_RegisterNetworkFunctions

global function ServerCallback_FD_AnnouncePreParty
global function ServerCallback_FD_ClearPreParty
global function ServerCallback_FD_PingMinimap
global function ServerCallback_FD_SayThanks
global function ServerCallback_FD_MoneyFly
global function ServerCallback_FD_DisplayHarvesterKiller
global function ServerCallback_FD_NotifyStoreOpen
global function ServerCallback_ShowGameStats
global function ServerCallback_UpdateGameStats
global function ServerCallback_FD_UpdateWaveInfo
global function ServerCallback_FD_NotifyMVP

global function FD_ReadyUpEnabled

global function ShowWaveCompleteInfo

global function AttemptTutorialTip
global function DisplayTutorialTip
global function DisplayAITutorialTip
global function AttemptDisplayTutorialTip
global function AttemptPostStoreTutorialTip

global function FD_InitMusicSet

#if DEV
global function SetFDCustonDropshipIntroAnimIndex
global function GetFDCustonDropshipIntroAnimIndex
global function DEV_FD_HideHud
#endif

const bool FD_WAVE_INFO_ENABLED = true
const vector BOOST_STORE_ICON_SIZE = <96,96,0>


struct FD_RespawnDropshipIntroStruct
{
	bool isDrozTalking = true
	string dialogueLine
	float diagDelay = 0.3
}

struct
{
	bool wantToCloseStore = false
	bool canToggleStore = false
	array<var> waveRuis
	table<string, var> waveAwardRuis
	bool showWaveIntro = false
	var harvesterRui
	entity harvester

	entity droz = null
	entity davis = null
	array<string> drozDropshipAnims = [ "commander_DLC_flyin_Droz_finally", "commander_DLC_flyin_Droz_everytime", "commander_DLC_flyin_Droz_brother" ]
	array<asset> drozDropshipProps = [ FD_MODEL_DROZ_TABLET_PROP, FD_MODEL_DROZ_TABLET_PROP, DATA_KNIFE_MODEL ] //Make sure this lines up in the same order as Droz's animations!
	array< string > davisDropshipAnims = [ "commander_DLC_flyin_Davis_finally", "commander_DLC_flyin_Davis_everytime", "commander_DLC_flyin_Davis_brother" ]
	array< array <FD_RespawnDropshipIntroStruct> > respawnDropshipIntroData

	table<entity,var> boostStoreRuis

	array<var> turretRuis
	var scoreboardIconCover
	var readyUpRui
	var superRodeoRui
	var harvesterShieldRui
	var tutorialTip
	int dropshipIntroAnimIndex = -1
	bool useHintActive = false

	array<FD_PlayerAwards> playerAwards

	var scoreSplashRui
	var scoreboardWaveData
	array<var> scoreboardExtraRui
	bool usingShieldBoost

	array<int> validTutorialBitIndices

	float nextAllowReadyUpSoundTime
} file


table<string, void functionref(int,entity)> waveEndScoreEvents

void function ClGamemodeFD_Init()
{
	AddCreateCallback( "npc_titan", OnNPCTitanCreated )
	AddCreateCallback( "npc_turret_sentry", OnTurretCreated )
	AddCreateCallback( "prop_script", OnPropScriptCreated )
	AddCreateCallback( "player", OnPlayerCreated )
	AddCallback_OnClientScriptInit( FD_OverrideMinimapPackages )

	Minimap_SetZoomScale( 3.0 )
	Minimap_SetSizeScale( 1.5 )

	ClGameState_RegisterGameStateAsset( $"ui/gamestate_info_fd.rpak" )
	SetGameModeScoreBarUpdateRules( GameModeScoreBarRules_FD )

	AddEventNotificationCallback( eEventNotifications.FD_AnnounceWaveStart, FD_AnnounceWaveStart )
	AddEventNotificationCallback( eEventNotifications.FD_AnnounceWaveEnd, FD_AnnounceWaveEnd )
	AddEventNotificationCallback( eEventNotifications.FD_WaveRestart, FD_WaveRestart )
	AddEventNotificationCallback( eEventNotifications.FD_AmmoRefilled, FD_AmmoRefilled )
	AddEventNotificationCallback( eEventNotifications.FD_NotifyWaveBonusIncoming, FD_NotifyWaveBonusIncoming )
	AddEventNotificationCallback( eEventNotifications.FD_PlayerHealedHarvester, FD_PlayerHealedHarvester )
	AddEventNotificationCallback( eEventNotifications.FD_PlayerBoostedHarvesterShield, FD_PlayerBoostedHarvesterShield )
	AddEventNotificationCallback( eEventNotifications.FD_StoreClosing, FD_StoreClosing )
	AddEventNotificationCallback( eEventNotifications.FD_PlayerReady, FD_PlayerReady )
	AddEventNotificationCallback( eEventNotifications.FD_TurretRepair, FD_TurretRepair )
	AddEventNotificationCallback( eEventNotifications.FD_GotMoney, FD_GotMoney )
	AddEventNotificationCallback( eEventNotifications.FD_BoughtItem, FD_BoughtItem )

	CallsignEvents_SetEnabled( false )

	AddScoreboardShowCallback( OnScoreboardShow )
	AddScoreboardHideCallback( OnScoreboardHide )

	RegisterSignal( "WaveStarting" )
	RegisterSignal( "ClearWaveInfo" )
	RegisterSignal( "ActiveHarvesterChanged" )
	RegisterSignal( "FD_StoreClosing" )
	RegisterSignal( "FD_ToggleReady" )
	RegisterSignal( "Delayed_ReadyNag" )

	GamemodeFactionLeaderInit()
	RegisterConCommandTriggeredCallback( "+scriptCommand1", SendReadyMessage )

	ClGameState_SetPilotTitanStatusCallback( FD_GetPilotTitanStatus )

	AddCallback_GameStateEnter( eGameState.Prematch, Prematch_OnEnter )
	AddCallback_GameStateEnter( eGameState.Playing, Playing_OnEnter )
	AddCallback_GameStateEnter( eGameState.WinnerDetermined, WinnerDetermined_OnEnter )
	AddCallback_GameStateEnter( eGameState.Epilogue, Epilogue_OnEnter )

	FD_IntroMusicInit()

	//AddCallback_UseEntGainFocus( FD_OnUseEntGainFocus )
	//AddCallback_UseEntLoseFocus( FD_OnUseEntLoseFocus )

	ClLaserMesh_Init()
	ClTeamTitanSelectMenu_Init()

	file.scoreboardIconCover = CreatePermanentCockpitRui( $"ui/scoreboard_ping_icon.rpak", 2000 )
	file.superRodeoRui = CreateCockpitRui( $"ui/super_rodeo_hud.rpak" )
	file.harvesterShieldRui = CreateCockpitRui( $"ui/harvester_shield_hud.rpak" )
	file.tutorialTip = CreatePermanentCockpitRui( $"ui/fd_tutorial_tip.rpak", MINIMAP_Z_BASE )

	Obituary_SetIndexOffset( 2 )

	file.scoreboardExtraRui.append( RuiCreate( $"ui/fd_scoreboard.rpak", clGlobal.topoFullScreen, RUI_DRAW_HUD, 0 ) )
	thread ScoreboardInit()

	RegisterConCommandTriggeredCallback( "scoreboard_focus", UseHarvesterShieldBoost )
	RegisterConCommandTriggeredCallback( "scoreboard_toggle_focus", UseHarvesterShieldBoost )

	SetScoreboardUpdateCallback( FD_ScoreboardUpdate )

	waveEndScoreEvents = {
		[ "FDTeamWave" ] = OnScoreEvent_FDTeamWave,
		[ "FDDidntDie" ] = OnScoreEvent_FDDidntDie,
		[ "FDWaveMVP" ] = OnScoreEvent_FDWaveMVP,
		[ "FDTeamFlawlessWave" ] = OnScoreEvent_FDTeamFlawlessWave
	}

	foreach ( award, func in waveEndScoreEvents )
	{
		AddScoreEventCallback( GetScoreEvent( award ).eventId, func )
	}

	RunUIScript( "TTSMenuModeFD" )

	file.scoreboardWaveData = RuiCreate( $"ui/fd_scoreboard_data.rpak", clGlobal.topoFullScreen, RUI_DRAW_HUD, RUI_SORT_SCREENFADE + 100 )
	RuiSetBool( file.scoreboardWaveData, "isVisible", clGlobal.showingScoreboard )
	RuiSetString( file.scoreboardWaveData, "difficultyString", FD_GetDifficultyString() )
	RuiSetString( file.scoreboardWaveData, "waveString", "" )
	RuiSetString( file.scoreboardWaveData, "levelName", GetMapDisplayName( GetMapName() ) )

}


bool function AttemptDisplayTutorialTip( int tutorialBitIndex )
{
	asset backgroundImage = $""
	asset tipIcon = $""
	string tipTitle = ""
	string tipDesc = ""

	if ( IsPersistenceBitSet( GetLocalClientPlayer(), "fdTutorialBits", tutorialBitIndex ) )
		return false

	switch ( tutorialBitIndex )
	{
		case eFDTutorials.HARVESTER:
			backgroundImage = $"rui/hud/gametype_icons/fd/onboard_harvester"
			tipTitle = "#HARVESTER_HEADER"
			tipDesc = "#HARVESTER_DESC"
			break

		case eFDTutorials.ARC_TRAP:
			backgroundImage = $"rui/hud/gametype_icons/fd/onboard_arc_trap"
			tipTitle = "#WPN_ARC_TRAP"
			tipDesc = "#ONBOARD_ARC_TRAP_DESC"
			break

		case eFDTutorials.SENTRY_TURRET:
			backgroundImage = $"rui/hud/gametype_icons/fd/onboard_sentry_turret"
			tipTitle = "#WPN_SENTRY_TURRET"
			tipDesc = "#ONBOARD_SENTRY_TURRET_DESC"
			break

		case eFDTutorials.CORE_OVERLOAD:
			backgroundImage = $"rui/hud/gametype_icons/fd/onboard_core_overload"
			tipTitle = "#BURNMETER_SUPER_RODEO"
			tipDesc = "#ONBOARD_SUPER_RODEO_DESC"
			break

		case eFDTutorials.WAVE_BREAK:
			backgroundImage = $"rui/hud/gametype_icons/fd/onboard_wave_break"
			tipTitle = "#WAVE_BREAK"
			tipDesc = "#WAVE_BREAK_DESC"
			break

		default:
			if ( GetAIIDForTutorialBitIndex( tutorialBitIndex ) == -1 )
				return false

			int aiID = GetAIIDForTutorialBitIndex( tutorialBitIndex )
			backgroundImage = FD_GetOnboardForAI_byAITypeID( aiID )
			tipIcon = FD_GetIconForAI_byAITypeID( aiID )
			tipTitle = FD_GetSquadDisplayName_byAITypeID( aiID )
			tipDesc = FD_GetSquadDisplayDesc_byAITypeID( aiID )
	}

	GetLocalClientPlayer().ClientCommand( "FD_SetTutorialBit " + tutorialBitIndex )

	DisplayTutorialTip( backgroundImage, tipIcon, tipTitle, tipDesc )

	return true
}


void function DisplayTutorialTip( asset backgroundImage, asset tipIcon, string tipTitle, string tipDesc )
{
	RuiSetImage( file.tutorialTip, "backgroundImage", backgroundImage )
	RuiSetImage( file.tutorialTip, "iconImage", tipIcon )
	RuiSetString( file.tutorialTip, "titleText", tipTitle )
	RuiSetString( file.tutorialTip, "descriptionText", tipDesc )
	RuiSetGameTime( file.tutorialTip, "updateTime", Time() )
	RuiSetFloat( file.tutorialTip, "duration", 10.0 )
	thread TutorialTipSounds()
}

void function TutorialTipSounds()
{
	entity player = GetLocalClientPlayer()
	player.EndSignal( "OnDestroy" )

	EmitSoundOnEntity( player, "UI_InGame_FD_InfoCardSlideIn"  )
	wait 6.0
	EmitSoundOnEntity( player, "UI_InGame_FD_InfoCardSlideOut" )
}

void function DisplayAITutorialTip( int aiID )
{
	asset backgroundImage = FD_GetOnboardForAI_byAITypeID( aiID )
	asset tipIcon = FD_GetIconForAI_byAITypeID( aiID )
	string tipTitle = FD_GetSquadDisplayName_byAITypeID( aiID )
	string tipDesc = FD_GetSquadDisplayDesc_byAITypeID( aiID )

	DisplayTutorialTip( backgroundImage, tipIcon, tipTitle, tipDesc )
}

void function ScoreboardInit()
{
	WaitEndFrame()
	clGlobal.scoreboardInputFunc = ScoreboardInputFD
}

void function GameModeScoreBarRules_FD( var rui )
{
	entity player = GetLocalClientPlayer()
	if ( !IsValid( player ) )
		return

	float teamWaveScore = float ( GetGlobalNetInt( "FD_wavePoints" ) + ( 256 * GetGlobalNetInt( "FD_wavePoints256" ) ) )
	// RuiSetFloat( rui, "teamWaveScore", teamWaveScore )
}

void function FD_OverrideMinimapPackages( entity player )
{
	RegisterMinimapPackage( "npc_titan", eMinimapObject_npc_titan.AT_BOUNTY_BOSS, $"ui/minimap_object.rpak", FD_NPCTitanInit )
	RegisterMinimapPackage( "npc_soldier", eMinimapObject_npc.AI_TDM_AI, $"ui/minimap_object.rpak", FD_NPCHumanSizedInit )
	RegisterMinimapPackage( "npc_spectre", eMinimapObject_npc.AI_TDM_AI, $"ui/minimap_object.rpak", FD_NPCHumanSizedInit )
	RegisterMinimapPackage( "npc_stalker", eMinimapObject_npc.AI_TDM_AI, $"ui/minimap_object.rpak", FD_NPCHumanSizedInit )
	RegisterMinimapPackage( "npc_drone", eMinimapObject_npc.AI_TDM_AI, $"ui/minimap_object.rpak", FD_NPCHumanSizedInit )
	RegisterMinimapPackage( "npc_frag_drone", eMinimapObject_npc.AI_TDM_AI, $"ui/minimap_object.rpak", FD_NPCHumanSizedInit )
	RegisterMinimapPackage( "npc_super_spectre", eMinimapObject_npc.AI_TDM_AI, $"ui/minimap_object.rpak", FD_NPCHumanSizedInit )
	RegisterMinimapPackage( "npc_turret_sentry", eMinimapObject_npc.FD_TURRET, $"ui/minimap_object.rpak", FD_NPCTurretSentryInit )

	if ( !BoostStoreEnabled() )
		return

	var rui = CreateCockpitRui( $"ui/fd_score_splash.rpak", 500 )
	RuiTrackInt( rui, "pointValue", player, RUI_TRACK_SCRIPT_NETWORK_VAR_INT, GetNetworkedVariableIndex( "FD_money" ) )
	RuiTrackInt( rui, "pointStack", player, RUI_TRACK_SCRIPT_NETWORK_VAR_INT, GetNetworkedVariableIndex( "FD_money256" ) )
	file.scoreSplashRui = rui
}

void function FD_NPCTurretSentryInit( entity ent, var rui )
{
	RuiSetImage( rui, "defaultIcon", $"rui/hud/minimap/compass_icon_friendly_turret" )
	thread TurretMinimapTrackHealth( ent, rui )
}

void function TurretMinimapTrackHealth( entity turret, var rui )
{
	turret.EndSignal( "OnDeath" )

	RuiSetFloat3( rui, "iconColor", TEAM_COLOR_YOU/255.0 )

	while( IsValid( turret ) )
	{
		if ( turret.GetHealth() > 1 )
		{
			RuiSetBool( rui, "useTeamColor", true )
		}
		else
		{
			RuiSetBool( rui, "useTeamColor", false )
		}
		wait 0.1
	}
}

void function CLFD_RegisterNetworkFunctions()
{
	if ( IsLobby() )
		return

	RegisterNetworkedVariableChangeCallback_ent( "FD_activeHarvester", ActiveHarvesterChanged )
	RegisterNetworkedVariableChangeCallback_int( "FD_restartsRemaining", NumRetriesChanged )
	RegisterNetworkedVariableChangeCallback_bool( "boostStoreOpen", BoostStoreStateChanged )
	RegisterNetworkedVariableChangeCallback_bool( "FD_waveActive", WaveActiveChanged )
	RegisterNetworkedVariableChangeCallback_int( "numSuperRodeoGrenades", UpdateSuperRodeoBatteryCount )
	RegisterNetworkedVariableChangeCallback_int( "numHarvesterShieldBoost", UpdateHarvesterShieldCount )
	RegisterNetworkedVariableChangeCallback_bool( "FD_readyForNextWave", ReadyForNextWaveChanged )
}

void function UpdateSuperRodeoBatteryCount( entity player, int old, int new, bool actuallyChanged )
{
	if ( player != GetLocalViewPlayer() )
		return
	RuiSetInt( file.superRodeoRui, "batteryCount", new )
}

void function UpdateHarvesterShieldCount( entity player, int old, int new, bool actuallyChanged )
{
	if ( player != GetLocalViewPlayer() )
		return
	RuiSetInt( file.harvesterShieldRui, "batteryCount", new )
}


void function BoostStoreStateChanged( entity player, bool old, bool new, bool actuallyChanged )
{
	foreach( prop,rui in file.boostStoreRuis )
	{
		RuiSetBool( rui, "isVisible", new )
		if ( actuallyChanged && new )
		{
			RuiSetGameTime( rui, "startTime", Time() )
			RuiSetFloat( rui, "fadeTime", 1.75 )
			RuiSetFloat2( rui, "iconSize", BOOST_STORE_ICON_SIZE )
			thread PingBoostStore( prop )
			thread BoostStoreOpenSounds()
		}
	}
	if ( ClGameState_GetRui() != null )
		RuiSetBool( ClGameState_GetRui(), "showStatusTextAdd", new )
}

void function BoostStoreOpenSounds()
{
	entity player = GetLocalClientPlayer()

	EmitSoundOnEntity( player, "UI_InGame_FD_ArmorySymbolAppear" )

	wait 0.6 * 1.75

	EmitSoundOnEntity( player, "UI_InGame_FD_ArmorySymbolMove" )
}

void function WaveActiveChanged( entity player, bool old, bool new, bool actuallyChanged )
{
	if ( file.scoreSplashRui == null )
		return

	if ( new )
	{
		if ( GetGlobalNetInt( "FD_currentWave" )+1 == GetGlobalNetInt( "FD_totalWaves" ) )
		{
			RuiSetBool( file.scoreSplashRui, "isVisible", false )
			return
		}
	}

	RuiSetBool( file.scoreSplashRui, "isVisible", true )
}

void function PingBoostStore( entity prop )
{
	prop.EndSignal( "OnDestroy" )

	float startTime = Time()
	float endTime = Time() + 10.0

	while ( Time() < endTime )
	{
		var rui = CreateCockpitRui( $"ui/overhead_icon_ping.rpak" )
		RuiSetBool( rui, "isVisible", true )
		RuiSetFloat2( rui, "iconSize", BOOST_STORE_ICON_SIZE )
		RuiTrackFloat3( rui, "pos", prop, RUI_TRACK_OVERHEAD_FOLLOW )
		RuiSetGameTime( rui, "startTime", Time() )
		RuiSetGameTime( rui, "startFlyTime", startTime )
		RuiSetFloat( rui, "fadeTime", 1.75 )
		RuiSetFloat( rui, "duration", 0.5 )
		RuiSetFloat3( rui, "iconColor", TEAM_COLOR_YOU / 255.0 )
		RuiSetFloat( rui, "scale", 4.0 )
		wait 0.5
	}
}

void function ReadyForNextWaveChanged( entity player, bool old, bool new, bool actuallyChanged )
{
	if ( !actuallyChanged )
		return

	if ( player == GetLocalViewPlayer() )
		return

	if ( GetLocalViewPlayer().GetPlayerNetBool( "FD_readyForNextWave" ) )
		return

	if ( Time() > file.nextAllowReadyUpSoundTime )
	{
		string sound = new ? "UI_InGame_FD_ReadyUp_3p" : "UI_InGame_FD_UnReadyUp_3p"
		EmitSoundOnEntity( GetLocalViewPlayer(), sound )
		file.nextAllowReadyUpSoundTime = Time() + 3.0
	}

	if ( GetPlayerArray().len() <= 1 )
		return

	if ( !AllTeammatesReady() )
		return

	thread Delayed_ReadyNag()
}

void function Delayed_ReadyNag()
{
	clGlobal.levelEnt.Signal( "Delayed_ReadyNag" )
	clGlobal.levelEnt.EndSignal( "Delayed_ReadyNag" )
	clGlobal.levelEnt.EndSignal( "WaveStarting" )

	entity player = GetLocalViewPlayer()

	player.EndSignal( "OnDestroy" )

	wait 2.0

	if ( GetLocalViewPlayer().GetPlayerNetBool( "FD_readyForNextWave" ) )
		return

	if ( !AllTeammatesReady() )
		return

	if ( GetPlayerArray().len() <= 1 )
		return

	PlayFactionDialogueOnLocalClientPlayer( "fd_playerNeedsToReadyUp" )
}

bool function AllTeammatesReady()
{
	foreach ( otherPlayer in GetPlayerArray() )
	{
		if ( otherPlayer != GetLocalViewPlayer() )
		{
			if ( !otherPlayer.GetPlayerNetBool( "FD_readyForNextWave" ) )
			{
				return false
			}
		}
	}

	return true
}

void function NumRetriesChanged( entity player, int old, int new, bool actuallyChanged )
{
	RuiSetBool( ClGameState_GetRui(), "hasRestarted", FD_HasRestarted() )
}

void function ActiveHarvesterChanged( entity player, entity oldEnt, entity newEnt, bool actuallyChanged )
{
	if ( newEnt == null )
		return

	RuiTrackFloat( ClGameState_GetRui(), "friendlyShield", newEnt, RUI_TRACK_SHIELD_FRACTION )
	RuiTrackFloat( ClGameState_GetRui(), "friendlyHealth", newEnt, RUI_TRACK_HEALTH )
	RuiTrackInt( ClGameState_GetRui(), "remainingAI", null, RUI_TRACK_SCRIPT_NETWORK_VAR_GLOBAL_INT, GetNetworkedVariableIndex( "FD_AICount_Current" ) )
	RuiTrackInt( ClGameState_GetRui(), "totalAI", null, RUI_TRACK_SCRIPT_NETWORK_VAR_GLOBAL_INT, GetNetworkedVariableIndex( "FD_AICount_Total" ) )
	RuiTrackFloat( ClGameState_GetRui(), "harvesterShieldBoostTime", null, RUI_TRACK_SCRIPT_NETWORK_VAR_GLOBAL, GetNetworkedVariableIndex( "FD_harvesterInvulTime" ) )
	RuiTrackFloat( ClGameState_GetRui(), "nextWaveStartTime", null, RUI_TRACK_SCRIPT_NETWORK_VAR_GLOBAL, GetNetworkedVariableIndex( "FD_nextWaveStartTime" ) )
	RuiTrackInt( ClGameState_GetRui(), "currentWave", null, RUI_TRACK_SCRIPT_NETWORK_VAR_GLOBAL_INT, GetNetworkedVariableIndex( "FD_currentWave" ) )
	RuiTrackInt( ClGameState_GetRui(), "maxWaves", null, RUI_TRACK_SCRIPT_NETWORK_VAR_GLOBAL_INT, GetNetworkedVariableIndex( "FD_totalWaves" ) )
	RuiTrackInt( ClGameState_GetRui(), "waveState", null, RUI_TRACK_SCRIPT_NETWORK_VAR_GLOBAL_INT, GetNetworkedVariableIndex( "FD_waveState" ) )

	RuiTrackInt( ClGameState_GetRui(), "restartsRemaining", null, RUI_TRACK_SCRIPT_NETWORK_VAR_GLOBAL_INT, GetNetworkedVariableIndex( "FD_restartsRemaining" ) )

	RuiSetString( ClGameState_GetRui(), "difficultyString", FD_GetDifficultyString() )

	FD_StoreOpen( null, null )

	file.harvester = newEnt

	if ( file.harvesterRui != null )
	{
		RuiDestroy( file.harvesterRui )
	}

	file.harvesterRui = CreateCockpitRui( $"ui/overhead_icon_generic.rpak", MINIMAP_Z_BASE + 200 )
	RuiSetImage( file.harvesterRui, "icon", $"rui/hud/gametype_icons/fd/coop_harvester" )
 	RuiSetBool( file.harvesterRui, "isVisible", true )
 	RuiSetBool( file.harvesterRui, "showClampArrow", true )
 	RuiSetFloat2( file.harvesterRui, "iconSize", <96,96,0> )
 	RuiTrackFloat3( file.harvesterRui, "pos", newEnt, RUI_TRACK_ABSORIGIN_FOLLOW )

	thread TrackHarvesterDamage( file.harvester )
}

void function TrackHarvesterDamage( entity harvester )
{
	FlagWait( "ClientInitComplete" )
	clGlobal.levelEnt.Signal( "ActiveHarvesterChanged" )
	clGlobal.levelEnt.EndSignal( "ActiveHarvesterChanged" )

	int oldHealth = harvester.GetHealth()
	int oldShield = harvester.GetShieldHealth()

	while ( IsValid( harvester ) )
	{
		if ( harvester.GetHealth() < oldHealth || harvester.GetShieldHealth() < oldShield && file.scoreboardIconCover != null )
		{
			bool hasShield = harvester.GetShieldHealth() > 0

			var rui = CreatePermanentCockpitRui( $"ui/scoreboard_ping_fd.rpak", 1500 )
			RuiSetGameTime( rui, "startTime", Time() )
			RuiSetFloat( rui, "duration", 0.5 )

			vector color
			if ( hasShield )
			{
				color = TEAM_COLOR_FRIENDLY/255.0
				RuiSetFloat( rui, "scale", 3.0 )
			}
			else
			{
				float frac = GetHealthFrac( harvester )
				color = GraphCappedVector( frac, 1.0, 0.5, TEAM_COLOR_ENEMY/255.0, <1.0,0.0,0.0> )
				RuiSetFloat( rui, "scale", 6.0 )
			}
			RuiSetFloat3( rui, "iconColor", color )
		}
		oldHealth = harvester.GetHealth()
		oldShield = harvester.GetShieldHealth()

		WaitFrame()
	}
}

void function OnTurretCreated( entity turret )
{
	thread TrackTurretKillCount( turret )
}

void function TrackTurretKillCount( entity turret )
{
	entity owner = turret.GetBossPlayer()

	var turretRui
	if ( (owner == GetLocalViewPlayer()) )
	{
		turretRui = CreateCockpitRui( $"ui/turret_hud_status.rpak" )
		file.turretRuis.append( turretRui )
		UpdateTurretRuiIndeces()
	}

	var rui = CreateCockpitRui( $"ui/turret_kill_tracker.rpak", 0 )
	RuiSetBool( rui, "isMine", (owner == GetLocalViewPlayer()) )
	RuiTrackFloat3( rui, "pos", turret, RUI_TRACK_ABSORIGIN_FOLLOW )
	turret.EndSignal( "OnDeath" )
	OnThreadEnd(
		function () : ( rui, turretRui )
		{
			RuiDestroy( rui )

			if ( IsValid( turretRui ) )
			{
				file.turretRuis.fastremovebyvalue( turretRui )
				RuiDestroy( turretRui )
			}


			UpdateTurretRuiIndeces()
		}
	)

	while( IsValid( turret ) )
	{
		int killCount = int( turret.kv.killCount )
		if ( IsValid( turretRui ) )
		{
			RuiSetInt( turretRui, "killCount", killCount )
			RuiSetBool( turretRui, "isOnline", turret.GetHealth() > 1 )
		}
		RuiSetBool( rui, "isOnline", turret.GetHealth() > 1 )
		RuiSetInt( rui, "killCount", killCount )
		wait 0.1
	}
}

void function UpdateTurretRuiIndeces()
{
	for ( int i=0; i<file.turretRuis.len(); i++ )
	{
		RuiSetInt( file.turretRuis[i], "index", i )
	}
}

void function OnNPCTitanCreated( entity titan )
{
	if ( titan.GetTeam() == TEAM_IMC && FD_GetDifficultyLevel() < eFDDifficultyLevel.INSANE )
	{
		if( titan.GetAISettingsName().find( "elite" ) ) //Hack for Elites overhead icons
		{
			if( GetConVarInt( "ns_fd_elite_overhead_icontype" ) == 1 )
				thread AddOverheadIcon( titan, $"rui/hud/gametype_icons/fd/fd_icon_titan_elite" )
			else if( GetConVarInt( "ns_fd_elite_overhead_icontype" ) == 2 )
				thread AddOverheadIcon( titan, FD_GetGreyIconForAI_byAITypeID( FD_GetAITypeID_ByString( titan.GetTargetName() ) ) )
			else
				thread AddOverheadIcon( titan, GetIconForTitanType( titan.GetTargetName() ) )
		}
		else
			thread AddOverheadIcon( titan, GetIconForTitanType( titan.GetTargetName() ) )
	}
}

void function OnPropScriptCreated( entity prop )
{
	switch ( prop.GetTargetName() )
	{
		case "loadoutCrate":
			thread AddOverheadIcon( prop, $"rui/hud/gametype_icons/fd/coop_ammo_locker_icon", false )
			break
		case "boostStore":
			var rui = AddOverheadIcon( prop, $"rui/hud/gametype_icons/bounty_hunt/bh_bonus_icon", true, $"ui/overhead_icon_objective.rpak" )
			RuiSetBool( rui, "isVisible", GetGlobalNetBool( "boostStoreOpen" ) )
			RuiSetFloat2( rui, "iconSize", BOOST_STORE_ICON_SIZE )
			thread BoostStoreRuiTrack( rui, prop )
			break
		case "batteryExchange":
			thread AddOverheadIcon( prop, $"rui/hud/gametype_icons/bounty_hunt/bh_bank_icon", false )
			AddEntityCallback_GetUseEntOverrideText( prop, FD_BatteryPortCheckBattery )
			break
		case "mortarPosition":
			var rui = AddOverheadIcon( prop, $"rui/hud/gametype_icons/fd/fd_icon_spectre_mortar", true, $"ui/overhead_icon_ellipse.rpak" )
			RuiSetImage( rui, "iconBG", $"rui/hud/gametype_icons/fd/fd_icon_spectre_mortar_bg" )
			RuiTrackFloat( rui, "arcPercent", prop, RUI_TRACK_SHIELD_FRACTION )
			thread MortarPositionVisibilityTrack( rui, prop )
			break
		case "harvesterBoostPort":
			AddEntityCallback_GetUseEntOverrideText( prop, FD_BatteryPortCheckBattery )
			thread AddOverheadIcon( prop, $"rui/hud/battery/battery_generator", false )
			break
	}
}

void function MortarPositionVisibilityTrack( var rui, entity prop )
{
	prop.EndSignal( "OnDestroy" )
	while ( 1 )
	{
		RuiSetBool( rui, "isVisible", prop.GetAngles().y == 0 )
		WaitFrame()
	}
}

void function BoostStoreRuiTrack( var rui, entity prop )
{
	prop.EndSignal( "OnDestroy" )
	file.boostStoreRuis[ prop ] <- rui

	OnThreadEnd(
		function() : ( rui, prop )
		{
			delete file.boostStoreRuis[prop]
		}
	)

	WaitForever()
}

void function OnPlayerCreated( entity player )
{
	if ( player != GetLocalViewPlayer() )
		AddEntityCallback_GetUseEntOverrideText( player, FD_CheckPlayerMoney )
}

string function FD_CheckPlayerMoney( entity player )
{
	if ( GetGameState() != eGameState.Playing )
		return " "

	if ( GetGlobalNetBool( "FD_waveActive" ) )
		return " "

	int money = GetPlayerMoney( GetLocalViewPlayer() )

	if ( money <= 0 )
		return " "

	return Localize( "#PLAYER_CASH_HOLD_USE", minint( money, 100 ), player.GetPlayerName() )
}

string function FD_BatteryPortCheckBattery( entity ent )
{
	entity player = GetLocalViewPlayer()

	if ( PlayerHasBattery( player ) )
		return ""

	if ( player.GetPlayerNetBool( "playerHasBatteryBoost" ) )
		return ""

	return "#HARVESTER_BOOST_NEED_BATT"
}

var function AddOverheadIcon( entity prop, asset icon, bool pinToEdge = true, asset ruiFile = $"ui/overhead_icon_generic.rpak" )
{
	var rui = CreateCockpitRui( ruiFile, MINIMAP_Z_BASE - 20 )
	RuiSetImage( rui, "icon", icon )
	RuiSetBool( rui, "isVisible", true )
	RuiSetBool( rui, "pinToEdge", pinToEdge )
	RuiTrackFloat3( rui, "pos", prop, RUI_TRACK_OVERHEAD_FOLLOW )

	thread AddOverheadIconThread( prop, rui )
	return rui
}

void function AddOverheadIconThread( entity prop, var rui )
{
	prop.EndSignal( "OnDestroy" )
	if ( prop.IsNPC() )
		prop.EndSignal( "OnDeath" )

	OnThreadEnd(
	function() : ( rui )
		{
			RuiDestroy( rui )
		}
	)

	//If overhead icon owner is cloaked, hide icon.
	if ( prop.IsNPC() )
	{
		while ( 1 )
		{
			bool showIcon = !IsCloaked( prop )

			if ( prop.IsTitan() && IsValid( prop.GetTitanSoul() ) )
				showIcon = showIcon && prop.GetTitanSoul().GetTitanSoulNetBool( "showOverheadIcon" )

			RuiSetBool( rui, "isVisible", showIcon )
			wait 0.5
		}
	}

	WaitForever()
}

void function FD_NPCTitanInit( entity ent, var rui )
{
	if ( ent.GetTeam() == TEAM_IMC )
	{
		if( ent.GetAISettingsName().find( "elite" ) ) //Hack for Elites overhead icons
		{
			if( GetConVarInt( "ns_fd_elite_minimap_icontype" ) == 1 )
			{
				RuiSetImage( rui, "defaultIcon", $"rui/hud/gametype_icons/fd/fd_icon_titan_elite" )
				RuiSetImage( rui, "clampedDefaultIcon", $"rui/hud/gametype_icons/fd/fd_icon_titan_elite" )
			}
			else if( GetConVarInt( "ns_fd_elite_minimap_icontype" ) == 2 )
			{
				RuiSetImage( rui, "defaultIcon", FD_GetGreyIconForAI_byAITypeID( FD_GetAITypeID_ByString( ent.GetTargetName() ) ) )
				RuiSetImage( rui, "clampedDefaultIcon", FD_GetGreyIconForAI_byAITypeID( FD_GetAITypeID_ByString( ent.GetTargetName() ) ) )
			}
			else
			{
				RuiSetImage( rui, "defaultIcon", GetIconForTitanType( ent.GetTargetName() ) )
				RuiSetImage( rui, "clampedDefaultIcon", GetIconForTitanType( ent.GetTargetName() ) )
			}
		}
		else
		{
			RuiSetImage( rui, "defaultIcon", GetIconForTitanType( ent.GetTargetName() ) )
			RuiSetImage( rui, "clampedDefaultIcon", GetIconForTitanType( ent.GetTargetName() ) )
		}
		RuiSetBool( rui, "useTeamColor", false )
		RuiSetBool( rui, "overrideTitanIcon", true )
	}
	else
	{
		RuiSetBool( rui, "useTeamColor", false )
	}
	RuiSetFloat( rui, "sonarDetectedFrac", 1.0 )
	RuiSetGameTime( rui, "lastFireTime", Time() + ( GetCurrentPlaylistVarFloat( "timelimit", 10 ) * 60.0 ) + 999.0 )
	RuiSetBool( rui, "showOnMinimapOnFire", true )
}

void function FD_NPCHumanSizedInit( entity ent, var rui )
{
	if ( IsSuperSpectre( ent ) )
	{
		RuiSetImage( rui, "defaultIcon", $"rui/hud/minimap/compass_icon_enemy_pilot" )
		RuiSetBool( rui, "useTeamColor", false )
	}
	else if ( ent.GetTargetName() == "Cloak Drone" )
	{
		RuiSetImage( rui, "defaultIcon", $"rui/hud/gametype_icons/fd/fd_icon_drone_cloak_minimap" )
		RuiSetBool( rui, "useTeamColor", false )
	}
	else
	{
		RuiSetImage( rui, "defaultIcon", $"rui/hud/minimap/compass_icon_small_dot" )
	}

	RuiSetImage( rui, "clampedDefaultIcon", $""  )
	RuiSetGameTime( rui, "lastFireTime", Time() + ( GetCurrentPlaylistVarFloat( "timelimit", 10 ) * 60.0 ) + 999.0 )
	RuiSetBool( rui, "showOnMinimapOnFire", true )
	RuiSetBool( rui, "alwaysShowOnMinimap", true )
}

/*
fastfunction ServerCallback_NewEnemyAnnounceCards( arg0, arg1 = null, arg2 = null, arg3 = null, arg4 = null, arg5 = null, arg6 = null, arg7 = null, arg8 = null )
{
	local args = []
	args.append( arg0 )
	args.append( arg1 )
	args.append( arg2 )
	args.append( arg3 )
	args.append( arg4 )
	args.append( arg5 )
	args.append( arg6 )
	args.append( arg7 )
	args.append( arg8 )

	for ( local i = 0 ; i < args.len() - 1; i++ )
	{
		local aiTypeID = args[i]
		if ( aiTypeID != null )
		{
			NewEnemyAnnounce_AddToQueue( aiTypeID )
		}
	}

	thread EnemyAnnounce_ReprocessQueue()
}

*/

void function ServerCallback_FD_ClearPreParty()
{
	entity player = GetLocalClientPlayer()
	file.showWaveIntro = false
	player.Signal( "ClearWaveInfo" )
}

void function ServerCallback_FD_UpdateWaveInfo( int aiID0, int aiID1 = -1, int aiID2 = -1, int aiID3 = -1, int aiID4 = -1, int aiID5 = -1, int aiID6 = -1, int aiID7 = -1, int aiID8 = -1 )
{
	array<int> aiIDs = []
	if ( aiID0 != -1 )
		aiIDs.append( aiID0 )
	if ( aiID1 != -1 )
		aiIDs.append( aiID1 )
	if ( aiID2 != -1 )
		aiIDs.append( aiID2 )
	if ( aiID3 != -1 )
		aiIDs.append( aiID3 )
	if ( aiID4 != -1 )
		aiIDs.append( aiID4 )
	if ( aiID5 != -1 )
		aiIDs.append( aiID5 )
	if ( aiID6 != -1 )
		aiIDs.append( aiID6 )
	if ( aiID7 != -1 )
		aiIDs.append( aiID7 )
	if ( aiID8 != -1 )
		aiIDs.append( aiID8 )

	entity player = GetLocalClientPlayer()

	if ( file.scoreboardWaveData != null )
		RuiDestroyIfAlive( file.scoreboardWaveData )

	int waveNum = GetGlobalNetInt( "FD_currentWave" ) + 1

	file.scoreboardWaveData = RuiCreate( $"ui/fd_scoreboard_data.rpak", clGlobal.topoFullScreen, RUI_DRAW_HUD, RUI_SORT_SCREENFADE + 100 )
	RuiSetBool( file.scoreboardWaveData, "isVisible", clGlobal.showingScoreboard )
	RuiSetString( file.scoreboardWaveData, "difficultyString", FD_GetDifficultyString() )
	RuiSetString( file.scoreboardWaveData, "waveString", GetWaveStatusString( waveNum ) )
	RuiSetString( file.scoreboardWaveData, "levelName", GetMapDisplayName( GetMapName() ) )

	int count = 0
	foreach ( int aiID in aiIDs )
	{
		asset icon = FD_GetIconForAI_byAITypeID( aiID )
		RuiSetImage( file.scoreboardWaveData, "icon" + (count), icon )
		RuiSetImage( file.scoreboardWaveData, "emptyIcon" + (count), FD_GetGreyIconForAI_byAITypeID( aiID ) )
		RuiTrackInt( file.scoreboardWaveData, "count" + (count), null, RUI_TRACK_SCRIPT_NETWORK_VAR_GLOBAL_INT, GetNetworkedVariableIndex( FD_GetAINetIndex_byAITypeID( aiID ) ) )
		count++
	}
}

void function ServerCallback_FD_AnnouncePreParty( int aiID0, int aiID1 = -1, int aiID2 = -1, int aiID3 = -1, int aiID4 = -1, int aiID5 = -1, int aiID6 = -1, int aiID7 = -1, int aiID8 = -1 )
{
	array<int> aiIDs = []
	if ( aiID0 != -1 )
		aiIDs.append( aiID0 )
	if ( aiID1 != -1 )
		aiIDs.append( aiID1 )
	if ( aiID2 != -1 )
		aiIDs.append( aiID2 )
	if ( aiID3 != -1 )
		aiIDs.append( aiID3 )
	if ( aiID4 != -1 )
		aiIDs.append( aiID4 )
	if ( aiID5 != -1 )
		aiIDs.append( aiID5 )
	if ( aiID6 != -1 )
		aiIDs.append( aiID6 )
	if ( aiID7 != -1 )
		aiIDs.append( aiID7 )
	if ( aiID8 != -1 )
		aiIDs.append( aiID8 )

	entity player = GetLocalClientPlayer()

	file.showWaveIntro = true

	ServerCallback_FD_UpdateWaveInfo( aiID0, aiID1, aiID2, aiID3, aiID4, aiID5, aiID6, aiID7, aiID8 )

	float interval = 0.1
	float delay = interval * file.waveRuis.len()
	file.waveAwardRuis.clear()
	foreach ( rui in file.waveRuis )
	{
		RuiSetGameTime( rui, "startFadeOutTime", Time() + delay )
		delay -= interval
	}
	file.waveRuis.clear()

	if ( FD_WAVE_INFO_ENABLED && !IsWatchingKillReplay() )
	{
		thread ShowWaveInfo( player, aiIDs, GetGlobalNetInt( "FD_currentWave" ) + 1 )
	}

	array<int> validTutorialBitIndices

	foreach ( int aiID in aiIDs )
	{
		int tutorialBitIndex = GetTutorialBitIndexForAIID( aiID )
		if ( tutorialBitIndex == -1 )
			continue

		if ( IsPersistenceBitSet( player, "fdTutorialBits", tutorialBitIndex ) )
			continue

		validTutorialBitIndices.append( tutorialBitIndex )
	}

	file.validTutorialBitIndices = validTutorialBitIndices
}


void function AttemptTutorialTip( array<int> validTutorialBitIndices, float delay = 0.0 )
{
	GetLocalClientPlayer().EndSignal( "OnDeath" )

	wait delay

	foreach ( tutorialBitIndex in validTutorialBitIndices )
	{
		if( AttemptDisplayTutorialTip( tutorialBitIndex ) )
			break
	}
}


void function AttemptPostStoreTutorialTip( float delay = 0.0)
{
	thread AttemptPostStoreTutorialTip_Internal( delay )
}


void function AttemptPostStoreTutorialTip_Internal( float delay )
{
	GetLocalClientPlayer().EndSignal( "OnDeath" )

	wait delay

	if ( GetGlobalNetBool( "FD_waveActive" ) )
		return

	while ( file.showWaveIntro )
		WaitFrame()

	entity player = GetLocalClientPlayer()

	array<int> validTutorialBitIndices
	if ( PlayerHasArcTrapReady( player ) )
	{
		if( AttemptDisplayTutorialTip( eFDTutorials.ARC_TRAP ) )
		{
			PlayFactionDialogueOnLocalClientPlayer( "fd_boughtArcTrap" )
			return
		}
	}

	//if ( PlayerHasHarvesterShieldBoost( player ) )
	//	validTutorialBitIndices.append( eFDTutorials.HARVESTER_SHIELD_BOOST )

	if ( PlayerHasSentryTurretReady( player ) )
	{
		if( AttemptDisplayTutorialTip( eFDTutorials.SENTRY_TURRET ) )
		{
			PlayFactionDialogueOnLocalClientPlayer( "fd_boughtSentryTurret" )
			return
		}
	}

	if ( PlayerHasCoreOverloadReady( player ) )
	{
		if( AttemptDisplayTutorialTip( eFDTutorials.CORE_OVERLOAD ) )
		{
			PlayFactionDialogueOnLocalClientPlayer( "fd_boughtCoreOverload" )
			return
		}
	}
}


int function GetTutorialBitIndexForAIID( int aiID )
{
	switch ( aiID )
	{
		case eFD_AITypeIDs.TITAN_ARC:
			return eFDTutorials.AI_TITAN_ARC

		case eFD_AITypeIDs.TITAN_MORTAR:
			return eFDTutorials.AI_TITAN_MORTAR

		case eFD_AITypeIDs.TITAN_NUKE:
			return eFDTutorials.AI_TITAN_NUKE

		case eFD_AITypeIDs.GRUNT:
			return eFDTutorials.AI_GRUNT

		case eFD_AITypeIDs.SPECTRE:
			return eFDTutorials.AI_SPECTRE

		case eFD_AITypeIDs.SPECTRE_MORTAR:
			return eFDTutorials.AI_SPECTRE_MORTAR

		case eFD_AITypeIDs.STALKER:
			return eFDTutorials.AI_STALKER

		case eFD_AITypeIDs.REAPER:
			return eFDTutorials.AI_REAPER

		case eFD_AITypeIDs.DRONE:
			return eFDTutorials.AI_DRONE

		case eFD_AITypeIDs.DRONE_CLOAK:
			return eFDTutorials.AI_DRONE_CLOAK

		case eFD_AITypeIDs.TICK:
			return eFDTutorials.AI_TICK
	}

	return -1
}

int function GetAIIDForTutorialBitIndex( int tutorialBit )
{
	switch ( tutorialBit )
	{
		case eFDTutorials.AI_TITAN_ARC:
			return eFD_AITypeIDs.TITAN_ARC

		case eFDTutorials.AI_TITAN_MORTAR:
			return eFD_AITypeIDs.TITAN_MORTAR

		case eFDTutorials.AI_TITAN_NUKE:
			return eFD_AITypeIDs.TITAN_NUKE

		case eFDTutorials.AI_GRUNT:
			return eFD_AITypeIDs.GRUNT

		case eFDTutorials.AI_SPECTRE:
			return eFD_AITypeIDs.SPECTRE

		case eFDTutorials.AI_SPECTRE_MORTAR:
			return eFD_AITypeIDs.SPECTRE_MORTAR

		case eFDTutorials.AI_STALKER:
			return eFD_AITypeIDs.STALKER

		case eFDTutorials.AI_REAPER:
			return eFD_AITypeIDs.REAPER

		case eFDTutorials.AI_DRONE:
			return eFD_AITypeIDs.DRONE

		case eFDTutorials.AI_DRONE_CLOAK:
			return eFD_AITypeIDs.DRONE_CLOAK

		case eFDTutorials.AI_TICK:
			return eFD_AITypeIDs.TICK
	}

	return -1
}

void function ShowWaveInfo( entity player, array<int> aiIDs, int waveNum )
{
	file.showWaveIntro = true
	player.EndSignal( "OnDeath" )
	player.EndSignal( "ClearWaveInfo" )

	float FD_WAVE_BUY_TIME = GetCurrentPlaylistVarFloat( "fd_wave_buy_time", 60.0 )
	float holdtime = BoostStoreOpen() ? FD_WAVE_BUY_TIME * 2.0 : 10.0
	var rui
	float offsetTime = Time()
	float endTime = offsetTime + holdtime // extra

	OnThreadEnd(
	function() : ()
		{
			float interval = 0.1
			float delay = interval * file.waveRuis.len()
			file.waveAwardRuis.clear()
			foreach ( rui in file.waveRuis )
			{
				RuiSetGameTime( rui, "startFadeOutTime", Time() + delay )
				thread PlaySlideInOutSounds( Time() + delay, "UI_InGame_FD_SliderExit" )
				delay -= interval
			}
			file.waveRuis.clear()
		}
	)

	rui = RuiCreate( $"ui/fd_wave_intro.rpak", clGlobal.topoFullScreen, RUI_DRAW_HUD, 0 )
	file.waveRuis.append( rui )
	if ( clGlobal.showingScoreboard )
		RuiSetBool( rui, "visible", false )
	RuiSetInt( rui, "listPos", 0 )
	RuiSetGameTime( rui, "startFadeInTime", offsetTime )
	// RuiSetGameTime( rui, "startFadeOutTime", endTime )
	RuiSetImage( rui, "bgImage", $"rui/hud/bounty_hunt/wave_callout_hazard" )
	string title = "#WAVE_STATUS_SINGLE"
	if ( waveNum >= GetGlobalNetInt( "FD_totalWaves" ) )
		title = "#WAVE_STATUS_FINAL"
	RuiSetString( rui, "titleText", Localize( title, waveNum ) )
	thread PlaySlideInOutSounds( offsetTime, "UI_InGame_FD_WaveSliderIn" )

//	if ( waveNum == FD_GetWaveCount()-1 )
//	{
//		RuiSetString( rui, "titleText", "#AT_WAVE_FINAL" )

//	}
	int count = 1

	float offsetTimeAdd = 0.75

	foreach ( int aiID in aiIDs )
	{
		offsetTime += offsetTimeAdd
		endTime -= 0.1
		rui = RuiCreate( $"ui/fd_wave_intro.rpak", clGlobal.topoFullScreen, RUI_DRAW_HUD, 0 )
		file.waveRuis.append( rui )
		RuiSetBool( rui, "visible", !clGlobal.showingScoreboard )

		asset icon = FD_GetIconForAI_byAITypeID( aiID )

		RuiSetInt( rui, "listPos", count++ )
		RuiSetGameTime( rui, "startFadeInTime", offsetTime )
		// RuiSetGameTime( rui, "startFadeOutTime", endTime )
		RuiSetImage( rui, "bgImage", $"rui/hud/bounty_hunt/wave_callout_strip" )

		RuiSetImage( rui, "iconImage", icon )
		//RuiSetString( rui, "itemText", expect string( Dev_GetAISettingByKeyField_Global( aiName, "Title" ) ) )
		RuiSetString( rui, "itemText", FD_GetSquadDisplayName_byAITypeID( aiID ) )

		// string eventName = GetAttritionScoreEventName( aiName )
		// int scoreVal = ScoreEvent_GetPointValue( GetScoreEvent( eventName ) )

		RuiSetInt( rui, "pointValue", FD_GetAICount_byAITypeID( aiID ) )

		thread PlaySlideInOutSounds( offsetTime )
	}

	wait endTime - Time()

	file.showWaveIntro = false
}

void function PlaySlideInOutSounds( float startTime, string soundalias = "UI_InGame_FD_UnitSliderIn" )
{
	entity player = GetLocalClientPlayer()
	player.EndSignal( "OnDestroy" )
	float delay1 =  ( startTime - Time() )
	wait delay1
	EmitSoundOnEntity( player, soundalias )
}

/*
 __          __                 _____ _        _                                                                               _
 \ \        / /                / ____| |      | |            /\                                                               | |
  \ \  /\  / /_ ___   _____   | (___ | |_ __ _| |_ ___      /  \   _ __  _ __   ___  _   _ _ __   ___ ___ _ __ ___   ___ _ __ | |_ ___
   \ \/  \/ / _` \ \ / / _ \   \___ \| __/ _` | __/ _ \    / /\ \ | '_ \| '_ \ / _ \| | | | '_ \ / __/ _ \ '_ ` _ \ / _ \ '_ \| __/ __|
    \  /\  / (_| |\ V /  __/   ____) | || (_| | ||  __/   / ____ \| | | | | | | (_) | |_| | | | | (_|  __/ | | | | |  __/ | | | |_\__ \
     \/  \/ \__,_| \_/ \___|  |_____/ \__\__,_|\__\___|  /_/    \_\_| |_|_| |_|\___/ \__,_|_| |_|\___\___|_| |_| |_|\___|_| |_|\__|___/
*/

void function FD_AnnounceWaveStart( entity ent, var info )
{
	clGlobal.levelEnt.Signal( "WaveStarting" )

	int currentWave = GetGlobalNetInt( "FD_currentWave" ) + 1
	// ClGameState_SetInfoStatusText( GetWaveStatusString( currentWave ) )

	thread FD_AnnounceWaveStart_Thread( currentWave )
}

void function FD_AnnounceWaveStart_Thread( int currentWave )
{
	GetLocalViewPlayer().EndSignal( "OnDestroy" )

	float duration = 12.0

	thread AttemptAITutorialTip( duration )

	AnnouncementData announcement = Announcement_Create( GetWaveStatusString( currentWave ) )
	Announcement_SetStyle( announcement, ANNOUNCEMENT_STYLE_FD_WAVE_INTRO )
	Announcement_SetSubText( announcement,  "\"" + Localize( GetMapDisplayName( GetMapName() ) + "_FD_WAVE_" + currentWave ) + "\"" )
	Announcement_SetSoundAlias( announcement,  "UI_InGame_FD_WaveIncoming" )
	Announcement_SetPurge( announcement, true )
	Announcement_SetPriority( announcement, 200 ) //Be higher priority than Titanfall ready indicator etc
	Announcement_SetOptionalTextArgsArray( announcement,  [ string( currentWave ), string( GetGlobalNetInt( "FD_totalWaves" ) ) ] )
	Announcement_SetDuration( announcement, duration )
	AnnouncementFromClass( GetLocalViewPlayer(), announcement )
	thread FD_AnnounceWaveStart_Music()
	thread FD_AnnounceWaveStart_SFX( currentWave, GetGlobalNetInt( "FD_totalWaves" ) )
}

void function FD_AnnounceWaveStart_SFX( int currentWave, int totalWaves )
{
	entity player = GetLocalClientPlayer()
	// these waits are based on numbers in ui/wave_announcement.rpak
	wait 1.5 // title delay
	for ( int i=0; i<totalWaves; i++ )
	{
		if ( i<currentWave )
		{
			EmitSoundOnEntity( player, "UI_InGame_FD_WaveTickGold" )
		}
		else
		{
			EmitSoundOnEntity( player, "UI_InGame_FD_WaveTick" )
		}

		wait 0.15
	}
}

void function AttemptAITutorialTip( float delay = 0.0 )
{
	wait delay
	// give file.validTutorialBitIndices time to be populated
	thread AttemptTutorialTip( file.validTutorialBitIndices )
}

void function FD_AnnounceWaveStart_Music()
{
	int currentWave = GetGlobalNetInt( "FD_currentWave" ) + 1
	int totalWaves = GetGlobalNetInt( "FD_totalWaves" )

	int musicPieceID = -1

	if (currentWave == 1 )
	{
		musicPieceID = eMusicPieceID.COOP_EARLYWAVE_BEGIN
	}
	else if ( currentWave == totalWaves )
	{
		musicPieceID = eMusicPieceID.COOP_FINALWAVE_BEGIN
	}
	else
	{
		musicPieceID = eMusicPieceID.COOP_MIDDLEWAVE_BEGIN
	}

	if ( musicPieceID == -1 )
		return

	StopMusic() //Have to call stopmusic everywhere to stop previous loops, annoying :/
	//printt( "Starting wave music" )
	thread ForceLoopMusic_DEPRECATED( musicPieceID )
}

void function FD_AnnounceWaveEnd( entity ent, var info )
{
	AnnouncementData announcement = Announcement_Create( "#FD_WAVE_COMPLETE" )
	Announcement_SetSoundAlias( announcement,  "UI_InGame_CoOp_WaveSurvived" )
	Announcement_SetStyle( announcement, ANNOUNCEMENT_STYLE_RESULTS )
	Announcement_SetTitleColor( announcement, TEAM_COLOR_FRIENDLY )
	Announcement_SetPurge( announcement, true )
	Announcement_SetPriority( announcement, 200 ) //Be higher priority than Titanfall ready indicator etc
	AnnouncementFromClass( GetLocalViewPlayer(), announcement )
	thread PlayWaveClearAndBetweenWavesMusic()

	if ( GetGlobalNetInt( "FD_currentWave" ) == 0 )
		thread AttemptTutorialTip( [eFDTutorials.WAVE_BREAK], 4.0 )

	/*
	if ( file.scoreboardWaveData != null )
	{
		RuiDestroyIfAlive( file.scoreboardWaveData )
		file.scoreboardWaveData = null
	}
	*/
}

void function PlayWaveClearAndBetweenWavesMusic()
{
	StopMusic()
	waitthread ForcePlayMusicToCompletion( eMusicPieceID.COOP_WAVEWON )
	thread ForceLoopMusic_DEPRECATED( eMusicPieceID.COOP_WAITINGFORWAVE )
}

void function ShowWaveCompleteInfo( entity player )
{
	player.EndSignal( "OnDeath" )
	player.EndSignal( "ClearWaveInfo" )

	float holdtime = 20.0
	var rui
	float offsetTime = Time()
	float endTime = offsetTime + holdtime // extra

	OnThreadEnd(
	function() : ()
		{
			float interval = 0.1
			float delay = interval * file.waveRuis.len()
			file.waveAwardRuis.clear()
			foreach ( rui in file.waveRuis )
			{
				RuiSetGameTime( rui, "startFadeOutTime", Time() + delay )
				delay -= interval
			}
			file.waveRuis.clear()
		}
	)

	rui = RuiCreate( $"ui/fd_wave_ending.rpak", clGlobal.topoFullScreen, RUI_DRAW_HUD, 0 )
	file.waveRuis.append( rui )
	if ( clGlobal.showingScoreboard )
		RuiSetBool( rui, "visible", false )
	RuiSetInt( rui, "listPos", 0 )
	RuiSetGameTime( rui, "startFadeInTime", offsetTime )
	RuiSetImage( rui, "bgImage", $"rui/hud/bounty_hunt/wave_callout_hazard" )
	RuiSetString( rui, "titleText", Localize( "#FD_WAVE_BONUSES" ) )
	thread PlaySlideInOutSounds( offsetTime )

	int count = 1
	float offsetTimeAdd = 0.25


	// HACK: because i want them to show up in this order, rather than the order that waveEndScoreEvents happens to be
	array<string> awards = [
		"FDTeamWave",
		"FDDidntDie",
		"FDWaveMVP",
		"FDTeamFlawlessWave",
	]

	foreach ( award in awards )
	{
		offsetTime += offsetTimeAdd
		endTime -= 0.1
		rui = RuiCreate( $"ui/fd_wave_ending.rpak", clGlobal.topoFullScreen, RUI_DRAW_HUD, 0 )
		file.waveRuis.append( rui )
		RuiSetBool( rui, "visible", !clGlobal.showingScoreboard )

		ScoreEvent event = GetScoreEvent( award )

		RuiSetInt( rui, "listPos", count++ )
		RuiSetGameTime( rui, "startFadeInTime", offsetTime )
		RuiSetImage( rui, "bgImage", $"rui/hud/bounty_hunt/wave_callout_strip" )
		RuiSetImage( rui, "iconImage", $"rui/hud/gametype_icons/bounty_hunt/bh_grey_check" )
		RuiSetString( rui, "itemText", ScoreEvent_GetSplashText( event ) )

		file.waveAwardRuis[ award ] <- rui
		thread PlaySlideInOutSounds( offsetTime )
	}

	wait endTime - Time()

	file.showWaveIntro = false
}

void function OnScoreEvent_FDTeamWave( int point, entity ent )
{
	OnScoreEventGeneric( "FDTeamWave" )
}
void function OnScoreEvent_FDDidntDie( int point, entity ent )
{
	OnScoreEventGeneric( "FDDidntDie" )
}
void function OnScoreEvent_FDWaveMVP( int point, entity ent )
{
	OnScoreEventGeneric( "FDWaveMVP" )
}
void function OnScoreEvent_FDTeamFlawlessWave( int point, entity ent )
{
	OnScoreEventGeneric( "FDTeamFlawlessWave" )
}

void function OnScoreEventGeneric( string scoreEvent )
{
	if ( scoreEvent in file.waveAwardRuis )
	{
		var rui = file.waveAwardRuis[ scoreEvent ]
		ScoreEvent event = GetScoreEvent( scoreEvent )
		RuiSetImage( rui, "iconImage", $"rui/hud/gametype_icons/bounty_hunt/bh_green_check" )
		RuiSetInt( rui, "pointValue", ScoreEvent_GetPointValue( event ) )
		RuiSetGameTime( rui, "iconPopTime", Time() )
	}
}

void function ServerCallback_FD_PingMinimap( float x, float y, float duration, float spreadRadius, float ringRadius, int colorIndex )
{
	vector origin = < x, y, 0 >
	vector color = TEAM_COLOR_ENEMY
	switch ( colorIndex )
	{
		case 0:
			color = TEAM_COLOR_ENEMY
		break;
		case 1:
			color = TEAM_COLOR_FRIENDLY
		break;
	}
	thread ServerCallback_FD_PingMinimap_Internal( origin, duration, spreadRadius, ringRadius, color )
}
void function ServerCallback_FD_PingMinimap_Internal( vector origin, float duration, float spreadRadius, float ringRadius, vector color )
{
	entity player = GetLocalViewPlayer()
	player.EndSignal( "OnDestroy" )

	float endTime = Time() + duration

	float randMin = -1*spreadRadius
	float randMax = spreadRadius

	float minWait = 0.6
	float maxWait = 1.0

	while ( Time() < endTime )
	{
		origin += < RandomIntRange( randMin, randMax ), RandomIntRange( randMin, randMax ), 0 >  // after first ping do little offsets

		Minimap_Ping( origin, ringRadius, 1.5, color/255.0 )

		wait RandomFloatRange( minWait, maxWait )
	}
}

void function FD_WaveRestart( entity ent, var info )
{
	AnnouncementData announcement = Announcement_Create( "#COOP_WAVE_RESTARTING" )
	announcement.drawOverScreenFade = true
	Announcement_SetSubText( announcement, GetRetryString( GetGlobalNetInt("FD_restartsRemaining") ) )
	Announcement_SetPurge( announcement, true )
	Announcement_SetSoundAlias( announcement, "UI_InGame_CoOp_TryAgain" )
	Announcement_SetDuration( announcement, 3.5 )
	AnnouncementFromClass( GetLocalViewPlayer(), announcement )

	if ( FD_PlayersHaveRestartsLeft() )
	{
		PlayFactionDialogueOnLocalClientPlayer( "fd_waveRestart" )
	}
	else
	{
		PlayFactionDialogueOnLocalClientPlayer( "fd_waveRedoFinal" )
	}
}

void function FD_AmmoRefilled( entity ent, var info )
{
	AnnouncementData announcement = Announcement_Create( "" )
	Announcement_SetSubText( announcement, "#LOADOUT_CRATE_AMMO_REFILLED" )
	Announcement_SetPurge( announcement, false )
	AnnouncementFromClass( GetLocalViewPlayer(), announcement )
}

void function FD_NotifyWaveBonusIncoming( entity ent, var info )
{
	// AnnouncementData announcement = Announcement_Create( "#FD_WAVE_BONUS" )
	// Announcement_SetStyle( announcement, ANNOUNCEMENT_STYLE_SWEEP )
	// Announcement_SetSubText( announcement, "#FD_WAVE_BONUS_HINT" )
	// Announcement_SetPurge( announcement, true )
	// Announcement_SetDuration( announcement, 3.5 )
	// AnnouncementFromClass( GetLocalViewPlayer(), announcement )

	thread ShowWaveCompleteInfo( GetLocalViewPlayer() )
}

void function ServerCallback_FD_NotifyStoreOpen()
{
	FD_StoreOpen( null, null )
	thread NotifyPlayerCanSkip()
}

void function NotifyPlayerCanSkip()
{
	entity player = GetLocalClientPlayer()

	clGlobal.levelEnt.EndSignal( "FD_StoreClosing" )

	file.wantToCloseStore = false
	file.canToggleStore = true
	if ( file.readyUpRui == null )
		file.readyUpRui = CreateCockpitRui( $"ui/ready_up_box.rpak", MINIMAP_Z_BASE )

	RuiSetGameTime( file.readyUpRui, "startTime", Time() )

	RuiSetBool( file.readyUpRui, "isVisible", !clGlobal.isAnnouncementActive )

	OnThreadEnd(
		function() : ()
		{
			file.canToggleStore = false
			file.wantToCloseStore = false
			if ( file.readyUpRui != null )
				RuiSetGameTime( file.readyUpRui, "endTime", Time() )
			file.readyUpRui = null
		}
	)

	thread NotifyPlayerCanSkip_Update()

	while ( 1 )
	{
		RuiSetBool( file.readyUpRui, "isReady", file.wantToCloseStore )

		if ( ClGameState_GetRui() )
			RuiSetBool( ClGameState_GetRui(), "isReady", file.wantToCloseStore )

		clGlobal.levelEnt.WaitSignal( "FD_ToggleReady" )
	}

}

void function NotifyPlayerCanSkip_Update()
{
	entity player = GetLocalClientPlayer()

	clGlobal.levelEnt.EndSignal( "FD_StoreClosing" )

	while ( file.readyUpRui != null )
	{
		RuiSetBool( file.readyUpRui, "isVisible", !clGlobal.isAnnouncementActive || file.wantToCloseStore )
		WaitFrame()
	}
}


void function FD_PlayerHealedHarvester( entity ent, var info )
{
	AnnouncementData announcement = Announcement_Create( Localize( "#FD_PLAYER_HEALED_HARVESTER", ent.GetPlayerName() ) )
	Announcement_SetStyle( announcement, ANNOUNCEMENT_STYLE_SWEEP )
	Announcement_SetTitleColor( announcement, TEAM_COLOR_FRIENDLY )
	Announcement_SetSoundAlias( announcement, SFX_HUD_ANNOUNCE_QUICK )
	Announcement_SetOptionalTextArgsArray( announcement, [ ent.GetPlayerName() ] )
	Announcement_SetPurge( announcement, true )
	Announcement_SetDuration( announcement, 1.5 )
	AnnouncementFromClass( GetLocalViewPlayer(), announcement )
}

void function FD_PlayerBoostedHarvesterShield( entity ent, var info )
{
	AnnouncementData announcement = Announcement_Create( Localize( "#FD_PLAYER_BOOSTED_SHIELD", ent.GetPlayerName() ) )
	Announcement_SetStyle( announcement, ANNOUNCEMENT_STYLE_FD_ITEM )
	Announcement_SetTitleColor( announcement, TEAM_COLOR_FRIENDLY )
	Announcement_SetSoundAlias( announcement, SFX_HUD_ANNOUNCE_QUICK )
	Announcement_SetIcon( announcement, $"rui/menu/boosts/boost_icon_harvester_shield_256" )
	Announcement_SetOptionalTextArgsArray( announcement, [ "true" ] )
	Announcement_SetPurge( announcement, true )
	announcement.duration = 1.0
	AnnouncementFromClass( GetLocalViewPlayer(), announcement )
}

void function FD_TurretRepair( entity ent, var info )
{
	expect int( info )
	entity turretOwner = GetEntityFromEncodedEHandle( info )

	if ( turretOwner == null )
		return

	if ( turretOwner == GetLocalViewPlayer() )
	{
		AnnouncementData announcement = Announcement_Create( Localize( "#HUD_TURRET_REPAIRED", ent.GetPlayerName() ) )
		Announcement_SetStyle( announcement, ANNOUNCEMENT_STYLE_SWEEP )
		Announcement_SetTitleColor( announcement, TEAM_COLOR_FRIENDLY )
		Announcement_SetSoundAlias( announcement, SFX_HUD_ANNOUNCE_QUICK )
		Announcement_SetPurge( announcement, true )
		Announcement_SetDuration( announcement, 1.5 )
		AnnouncementFromClass( GetLocalViewPlayer(), announcement )
		Obituary_Print_Generic( "#HUD_TURRET_REPAIRED", ent.GetPlayerName(), <255, 255, 255>, OBITUARY_COLOR_FRIENDLY )

		PlayFactionDialogueOnLocalClientPlayer( "fd_turretOnline" )
	}
	else if ( ent != turretOwner )
	{
		Obituary_Print_Generic( Localize( "#HUD_TURRET_REPAIRED_OTHER", ent.GetPlayerName(), turretOwner.GetPlayerName() ), "", <255, 255, 255>, OBITUARY_COLOR_FRIENDLY )
	}
}

void function FD_BoughtItem( entity ent, var info )
{
	BurnReward burnReward = BurnReward_GetById( expect int( info ) )
	Obituary_Print_Generic( Localize( "#HUD_BOUGHT_ITEM", ent.GetPlayerName(), Localize( burnReward.localizedName ) ), "", <255, 255, 255>, OBITUARY_COLOR_FRIENDLY )
}

void function FD_GotMoney( entity ent, var info )
{
	Obituary_Print_Generic( Localize( "#HUD_GOT_MONEY", string( info ), ent.GetPlayerName()  ), "", <255, 255, 255>, OBITUARY_COLOR_FRIENDLY )
}

void function FD_PlayerReady( entity ent, var info )
{
	Obituary_Print_Generic( "#FD_PLAYER_READY", ent.GetPlayerName(), <255, 255, 255>, OBITUARY_COLOR_FRIENDLY )
}

void function FD_StoreOpen( entity ent, var info )
{
	RuiSetString( ClGameState_GetRui(), "statusTextAdd", "#FD_STORE_OPEN" )
}

void function FD_StoreClosing( entity ent, var info )
{
	AnnouncementData announcement = Announcement_Create( "#FD_STORE_CLOSING_NOW" )
	Announcement_SetStyle( announcement, ANNOUNCEMENT_STYLE_SWEEP )
	Announcement_SetPurge( announcement, true )
	Announcement_SetDuration( announcement, 3.5 )
	AnnouncementFromClass( GetLocalViewPlayer(), announcement )

	clGlobal.levelEnt.Signal( "FD_StoreClosing" )

	thread FD_StoreClosing_Thread( Time() + 4.0 )
}

void function FD_StoreClosing_Thread( float endTime )
{
	clGlobal.levelEnt.EndSignal( "WaveStarting" )
	clGlobal.levelEnt.Signal( "Delayed_ReadyNag" )

	entity player = GetLocalViewPlayer()
	thread EmitCountdownSound( endTime, "UI_InGame_MarkedForDeath_CountdownToMarked" )

	OnThreadEnd(
	function() : (  )
		{
			RuiSetString( ClGameState_GetRui(), "statusTextAdd", "#FD_STORE_OPEN" )
		}
	)

	while ( Time() <= endTime )
	{
		RuiSetString( ClGameState_GetRui(), "statusTextAdd", Localize( "#FD_STORE_CLOSING", floor( endTime - Time() ) ) )
		WaitFrame()
	}

	wait 1.0
}

void function ServerCallback_FD_MoneyFly( int playerHandle, int amount )
{
	entity player = GetEntityFromEncodedEHandle( playerHandle )

	vector randDir2D = < RandomFloatRange( -1, 1 ), 1, 0 >
	randDir2D = Normalize( randDir2D )

	var rui = RuiCreate( $"ui/at_score_popup.rpak", clGlobal.topoFullScreen, RUI_DRAW_HUD, 100 )
	RuiSetInt( rui, "scoreVal", amount )
	RuiSetGameTime( rui, "startTime", Time() )
	RuiSetFloat3( rui, "pos", player.EyePosition() )
	RuiSetFloat2( rui, "driftDir", randDir2D )
	RuiSetBool( rui, "showNormalPoints", false )
}

void function ServerCallback_FD_SayThanks( int playerHandle )
{
	entity player = GetEntityFromEncodedEHandle( playerHandle )
	string soundalias = GetChatterPhrase( player, "s2", 1, player==GetLocalViewPlayer() )
	EmitSoundOnEntity( player, soundalias )
}

string function GetChatterPhrase( entity player, string battlechatterAlias, int soundAliasIndex, bool isFirstPerson = false )
{
	int voiceIndex = player.GetPlayerNetInt( "battleChatterVoiceIndex" )
	string voiceIndexString = battleChatterData.battleChatterIndexToStringMap[ voiceIndex ]
	int aliasIndex = soundAliasIndex
	string firstOrThirdPerson = isFirstPerson ? "1" : "3"
	string soundalias =  "diag_mp_player" + voiceIndexString + "_bc_" + battlechatterAlias + "_0" + aliasIndex + "_" + firstOrThirdPerson + "p"
	printt( soundalias )
	return soundalias
}


//Custom faction leader for FD
void function GamemodeFactionLeaderInit()
{
	OverrideFactionLeaderStruct fdFactionLeaderStruct
	fdFactionLeaderStruct.dialoguePrefix = "mcor_cmdr"
	fdFactionLeaderStruct.factionName = "#FD_FACTION_NAME"
	fdFactionLeaderStruct.factionLogo = $"rui/faction/faction_logo_last_resort"
	fdFactionLeaderStruct.useWaveForm = false
	fdFactionLeaderStruct.dropshipIntroOverride = FD_CustomDropshipIntro

	SetOverrideFactionLeader( fdFactionLeaderStruct )

	FD_RespawnDropshipIntroInit()

}

void function FD_RespawnDropshipIntroInit()
{
	FD_RespawnDropshipIntroStruct sequence0_0
	sequence0_0.isDrozTalking = true
	sequence0_0.dialogueLine = "diag_mcor_cmdr_fd_retryDropship_01a_droz"

	FD_RespawnDropshipIntroStruct sequence0_1
	sequence0_1.isDrozTalking = false
	sequence0_1.dialogueLine = "diag_mcor_cmdr_fd_retryDropship_01b_davis"

	array<FD_RespawnDropshipIntroStruct> sequence0 = [ sequence0_0, sequence0_1 ]

	FD_RespawnDropshipIntroStruct sequence1_0
	sequence1_0.isDrozTalking = false
	sequence1_0.dialogueLine = "diag_mcor_cmdr_fd_retryDropship_02a_davis"

	FD_RespawnDropshipIntroStruct sequence1_1
	sequence1_1.isDrozTalking = true
	sequence1_1.dialogueLine = "diag_mcor_cmdr_fd_retryDropship_02b_droz"
	sequence1_1.diagDelay = 3.2

	FD_RespawnDropshipIntroStruct sequence1_2
	sequence1_2.isDrozTalking = false
	sequence1_2.dialogueLine = "diag_mcor_cmdr_fd_retryDropship_02c_davis"

	array<FD_RespawnDropshipIntroStruct> sequence1 = [ sequence1_0, sequence1_1, sequence1_2 ]

	FD_RespawnDropshipIntroStruct sequence2_0
	sequence2_0.isDrozTalking = true
	sequence2_0.dialogueLine = "diag_mcor_cmdr_fd_retryDropship_03a_droz"

	FD_RespawnDropshipIntroStruct sequence2_1
	sequence2_1.isDrozTalking = false
	sequence2_1.dialogueLine = "diag_mcor_cmdr_fd_retryDropship_03b_davis"

	array<FD_RespawnDropshipIntroStruct> sequence2 = [ sequence2_0, sequence2_1 ]

	file.respawnDropshipIntroData = [ sequence0, sequence1, sequence2 ]
}

void function FD_CustomDropshipIntro( int shipEHandle, float dropshipSpawnTime )
{
	entity dropShip = GetEntityFromEncodedEHandle( shipEHandle )
	entity localViewPlayer = GetLocalViewPlayer()

	entity davis = CreatePropDynamic( FD_MODEL_DAVIS )
	davis.SetParent( dropShip, "ORIGIN" )
	davis.MarkAsNonMovingAttachment()
	file.davis = davis

	entity droz = CreatePropDynamic( FD_MODEL_DROZ )
	droz.SetParent( dropShip, "ORIGIN" )
	droz.MarkAsNonMovingAttachment()
	droz.SetSkin( 2 ) //FD only skin; replaces "64" on helmet with new faction logo
	file.droz = droz

	Assert( file.davisDropshipAnims.len() == file.drozDropshipAnims.len() )

	string davisAnim
	string drozAnim
	entity drozProp

	int dropshipAnimIndex = file.dropshipIntroAnimIndex

	if ( GetRoundsPlayed() == 0 )
	{
		if ( file.dropshipIntroAnimIndex == -1 )
			dropshipAnimIndex = RandomInt( file.davisDropshipAnims.len() )

		drozProp = CreatePropDynamic( file.drozDropshipProps[ dropshipAnimIndex ] )
		drozProp.MarkAsNonMovingAttachment()
		drozProp.SetParent( droz, "R_HAND" )
		davisAnim = file.davisDropshipAnims[ dropshipAnimIndex ]
		drozAnim = file.drozDropshipAnims[ dropshipAnimIndex ]

	}
	else
	{
		drozAnim  = "droz_fd_respawn_intro"
		davisAnim = "Militia_flyinA_countdown_mac"
		drozProp = CreatePropDynamic( $"models/Weapons/p2011/w_p2011.mdl" )
		drozProp.MarkAsNonMovingAttachment()
		drozProp.SetParent( droz, "KNIFE" )

		AddAnimEvent( droz, "play_fd_respawn_intro_diag", PlayFDRespawnIntroDiag )
	}

	thread PlayAnim( davis, davisAnim, dropShip, "ORIGIN" )
	thread PlayAnim( droz, drozAnim, dropShip, "ORIGIN" )

	droz.Anim_SetStartTime( dropshipSpawnTime )
	droz.LerpSkyScale( 0.9, 0.1 )
	SetTeam( droz, localViewPlayer.GetTeam() )

	davis.Anim_SetStartTime( dropshipSpawnTime )
	davis.LerpSkyScale( 0.9, 0.1 )
	SetTeam( davis, localViewPlayer.GetTeam() )

	dropShip.EndSignal( "OnDestroy" )

	OnThreadEnd(
	function() : ( davis, droz, drozProp )
		{
			if ( IsValid( davis ) )
				davis.Destroy()

			if ( IsValid( droz ) )
				droz.Destroy()

			if ( IsValid( drozProp ) )
				drozProp.Destroy()
		}
	)

	WaitForever()
	//printt( "animation name: " + factionLeaderInfo.dropshipAnimName + ", initialTime: " + initialTime + ", propAttachment: " + factionLeaderInfo.propAttachment )
}

void function PlayFDRespawnIntroDiag( entity droz )
{
	thread PlayFDRespawnIntroDiag_threaded()
}

void function PlayFDRespawnIntroDiag_threaded()
{
	wait 3.5 //In retrospect this would have been better if we didn't wait in script here, but instead only fired off the anim event at the correct time.

	entity droz = file.droz
	entity davis = file.davis

	if ( !IsValid( droz ) )
		return

	if ( !IsValid( davis ) )
		return

	droz.EndSignal( "OnDestroy" )
	davis.EndSignal( "OnDestroy" )

	int randomDiagIndex = file.dropshipIntroAnimIndex

	if ( file.dropshipIntroAnimIndex == -1 )
		randomDiagIndex = RandomInt( file.respawnDropshipIntroData.len() )

	array<FD_RespawnDropshipIntroStruct> respawnDropshipIntroSequence = file.respawnDropshipIntroData[ randomDiagIndex ]
	foreach( dataStruct in respawnDropshipIntroSequence )
	{
		if ( dataStruct.isDrozTalking )
		{
			var drozDiagHandle = EmitSoundOnEntity( droz, dataStruct.dialogueLine)
			WaitSignal(  drozDiagHandle, "OnSoundFinished" )
		}
		else
		{
			var davisDiagHandle = EmitSoundOnEntity( davis, dataStruct.dialogueLine )
			WaitSignal( davisDiagHandle, "OnSoundFinished" )
		}

		wait dataStruct.diagDelay
	}
}

#if DEV
void function SetFDCustonDropshipIntroAnimIndex( int value )
{
	file.dropshipIntroAnimIndex = value
}

int function GetFDCustonDropshipIntroAnimIndex()
{
	return file.dropshipIntroAnimIndex
}
#endif

string function GetWaveStatusString( int currentWave )
{
	if ( currentWave < GetGlobalNetInt( "FD_totalWaves" ) )
	{
		return Localize( "#WAVE_STATUS_SINGLE", currentWave )
	}

	return Localize( "#WAVE_STATUS_FINAL" )
}

void function ServerCallback_FD_DisplayHarvesterKiller( int retries, int hintId, int killerNameId1, float damageFrac1, int killerNameId2, float damageFrac2, int killerNameId3, float damageFrac3 )
{
	thread HideScoreboard()
	clGlobal.lockScoreboard = true

	thread DisplayHarvesterKiller_Thread( retries, hintId, killerNameId1, damageFrac1, killerNameId2, damageFrac2, killerNameId3, damageFrac3 )
}

void function DisplayHarvesterKiller_Thread( int retries, int hintId, int killerNameId1, float damageFrac1, int killerNameId2, float damageFrac2, int killerNameId3, float damageFrac3 )
{
	array<string> names
	array<int> damages
	array<int> ids

	ids.append( killerNameId1 )
	ids.append( killerNameId2 )
	ids.append( killerNameId3 )
	names.append( FD_GetAINameFromTypeID( killerNameId1 ) )
	names.append( FD_GetAINameFromTypeID( killerNameId2 ) )
	names.append( FD_GetAINameFromTypeID( killerNameId3 ) )
	damages.append( int( floor( damageFrac1 * 100.0 ) ) )
	damages.append( int( floor( damageFrac2 * 100.0 ) ) )
	damages.append( int( floor( damageFrac3 * 100.0 ) ) )

	entity player = GetLocalViewPlayer()

	float announceTime = 2.0
	AnnouncementData announcement = Announcement_Create( "#COOP_WAVE_FAILED" )
	announcement.drawOverScreenFade = true
	Announcement_SetSubText( announcement, "" )
	Announcement_SetPurge( announcement, true )
	Announcement_SetSoundAlias( announcement, "UI_InGame_CoOp_HarvesterDefenseFailed" )
	Announcement_SetDuration( announcement, announceTime )
	AnnouncementFromClass( player, announcement )

	player.EndSignal( "OnDestroy" )

	retries -= 1 // HACK: this is because it hasn't been updated yet, it will get updated when the round resets

	if ( killerNameId1 != -1 ) // if this is -1, assume no one killed the harvester
	{
		wait announceTime

		var rui = RuiCreate( $"ui/harvester_damage_report.rpak", clGlobal.topoFullScreen, RUI_DRAW_HUD, RUI_SORT_SCREENFADE + 100 )

		printt( "HARVESTER DAMAGE REPORT" )
		for ( int i=0; i<names.len(); i++ )
		{
			printt( names[i] + " - " + damages[i] )
		}

		float initialDelay = 2.0

		RuiSetGameTime( rui, "startTime", Time() + initialDelay )
		RuiSetGameTime( rui, "endTime", Time() + initialDelay + GAME_WINNER_DETERMINED_WAIT + 2.0 )

		int numEnemies = 0
		for ( int i=0; i<names.len(); i++ )
		{
			bool legit = damages[i] > 0
			if ( legit )
			{
				numEnemies++
				asset icon = FD_GetIconForAI_byAITypeID( ids[i] )
				RuiSetImage( rui, "icon"+i, icon )
				RuiSetString( rui, "name"+i, names[i] )
				RuiSetInt( rui, "damage"+i, damages[i] )
			}
		}

		RuiSetString( rui, "retryString", GetRetryString(retries) )

		string hint = ""
		if ( hintId != -1 )
		{
			hint = GetHintFromId( hintId )
		}
		RuiSetString( rui, "tip", hint )

		thread DamageReportSounds( initialDelay, numEnemies )
	}
	else
	{
		wait GAME_WINNER_DETERMINED_WAIT

		AnnouncementData announcement2 = Announcement_Create( "#COOP_WAVE_TRY_AGAIN" )
		announcement2.drawOverScreenFade = true
		Announcement_SetSubText( announcement2, GetRetryString(retries) )
		Announcement_SetPurge( announcement2, true )
		Announcement_SetStyle( announcement2, ANNOUNCEMENT_STYLE_QUICK )
		Announcement_SetSoundAlias( announcement2, "UI_InGame_CoOp_TryAgain" )
		Announcement_SetDuration( announcement2, 4.0 )
		AnnouncementFromClass( player, announcement2 )
	}
}

void function DamageReportSounds( float initialDelay, int numEnemies )
{
	wait initialDelay
	EmitSoundOnEntity( GetLocalClientPlayer(), "UI_InGame_FD_DamageReportOpen" )
	wait 0.5
	for ( int i=0; i<numEnemies; i++ )
	{
		EmitSoundOnEntity( GetLocalClientPlayer(), "UI_InGame_FD_DamageReportUnit" )
		wait 0.75
	}
}

void function SendReadyMessage( entity player )
{
	if ( !FD_ReadyUpEnabled() )
		return

	file.wantToCloseStore = !file.wantToCloseStore

	string sound = file.wantToCloseStore ? "UI_InGame_FD_ReadyUp_1p" : "UI_InGame_FD_UnReadyUp_1p"
	EmitSoundOnEntity( player, sound )

	player.ClientCommand( "FD_ToggleReady " + file.wantToCloseStore )
	clGlobal.levelEnt.Signal( "FD_ToggleReady" )
}

bool function FD_ReadyUpEnabled()
{
	return ( file.canToggleStore )
}

int function FD_GetPilotTitanStatus( entity player, int currentStatus )
{
	if ( !FD_ReadyUpEnabled() )
		return currentStatus

	if ( player.GetPlayerNetBool( "FD_readyForNextWave" ) )
		return ePlayerStatusType.PTS_TYPE_WAVE_READY


	return ePlayerStatusType.PTS_TYPE_WAVE_NOT_READY
}

string function GetRetryString( int retries )
{
	if ( retries > 1 )
		return Localize( "#WAVE_RETRIES_REMAINING", string( retries ) )
	else if ( retries == 1 )
		return Localize( "#WAVE_RETRIES_REMAINING_ONE", string( retries ) )

	return "#WAVE_RETRIES_REMAINING_NONE"
}

void function FD_IntroMusicInit()
{
	SetGameStateMusicEnabled( false ) //FD does its own music for game states; primarily for timing purposes

	RegisterServerVarChangeCallback( "gameState", FD_MusicOnGameStateChanged )

	FD_InitMusicSet()
}

void function FD_InitMusicSet()
{
	if ( GetConVarBool( "sound_classic_music" ) )
		FD_SetClassicMusic()
	else
		FD_SetNormalMusic()

}

void function FD_MusicOnGameStateChanged()
{
	switch ( GetGameState() )
	{
		case eGameState.Prematch:
			thread PlayFDDropshipIntroMusic()
			break


		case eGameState.WinnerDetermined:
			entity player = GetLocalClientPlayer()
			int winningTeam = expect int( level.nv.winningTeam )
			int playerTeam = player.GetTeam()

			if ( playerTeam == winningTeam)
			{
				ForcePlayMusicToCompletion( eMusicPieceID.LEVEL_WIN )//cleared all waves!
			}
			else if ( !HasRoundScoreLimitBeenReached() )
			{
				ForcePlayMusicToCompletion( eMusicPieceID.ROUND_BASED_GAME_LOST )//Lost a wave, can still retry
			}
			else
			{
				ForcePlayMusicToCompletion( eMusicPieceID.LEVEL_LOSS )//Lost a wave, out of retries!
			}
			break
	}
}

void function PlayFDDropshipIntroMusic()
{
	if ( GetRoundsPlayed() > 0 )
		wait 2.0 //Just a timing thing so we let the damage summary fade first.

	ForcePlayMusicToCompletion( eMusicPieceID.LEVEL_INTRO )
}

void function FD_SetClassicMusic()
{
	RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_WIN, "music_mp_fd_victory_classic", TEAM_MILITIA ) //Not using eMusicPieceID.COOP_GAMEWON
	RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_LOSS, "music_mp_fd_defeat_classic", TEAM_MILITIA ) //Not using eMusicPieceID.COOP_GAMELOST
	RegisterLevelMusicForTeam( eMusicPieceID.ROUND_BASED_GAME_LOST, "music_mp_fd_wavefailed_classic", TEAM_MILITIA ) //Not using eMusicPieceID.COOP_WAVELOST

	RegisterLevelMusicForTeam( eMusicPieceID.COOP_WAVEWON, "music_mp_fd_wavecleared_classic", TEAM_MILITIA )
	RegisterLevelMusicForTeam( eMusicPieceID.COOP_WAITINGFORWAVE, "music_mp_fd_betweenwaves_classic", TEAM_MILITIA )

	RegisterLevelMusicForTeam( eMusicPieceID.COOP_EARLYWAVE_BEGIN, "music_mp_fd_introwave_classic", TEAM_MILITIA )
	RegisterLevelMusicForTeam( eMusicPieceID.COOP_MIDDLEWAVE_BEGIN, "music_mp_fd_midwave_classic", TEAM_MILITIA )
	RegisterLevelMusicForTeam( eMusicPieceID.COOP_FINALWAVE_BEGIN, "music_mp_fd_finalwave_classic", TEAM_MILITIA )

	int difficultyLevel = FD_GetDifficultyLevel()
	string difficultyLevelIntroMusic

	switch ( difficultyLevel )
	{
		case eFDDifficultyLevel.EASY:
		case eFDDifficultyLevel.NORMAL:
		{
			difficultyLevelIntroMusic = "music_mp_fd_intro_easy_classic"
			break
		}

		case eFDDifficultyLevel.HARD:
		{
			difficultyLevelIntroMusic = "music_mp_fd_intro_medium_classic"
			break
		}

		case eFDDifficultyLevel.MASTER:
		case eFDDifficultyLevel.INSANE:

		{
			difficultyLevelIntroMusic = "music_mp_fd_intro_hard_classic"
			break
		}

		default:
		{
			unreachable
		}

	}

	RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_INTRO, difficultyLevelIntroMusic, TEAM_MILITIA )

}

void function FD_SetNormalMusic()
{
	RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_WIN, "music_mp_fd_victory", TEAM_MILITIA ) //Not using eMusicPieceID.COOP_GAMEWON
	RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_LOSS, "music_mp_fd_defeat", TEAM_MILITIA ) //Not using eMusicPieceID.COOP_GAMELOST
	RegisterLevelMusicForTeam( eMusicPieceID.ROUND_BASED_GAME_LOST, "music_mp_fd_wavefailed", TEAM_MILITIA ) //Not using eMusicPieceID.COOP_WAVELOST

	RegisterLevelMusicForTeam( eMusicPieceID.COOP_WAVEWON, "music_mp_fd_wavecleared", TEAM_MILITIA )
	RegisterLevelMusicForTeam( eMusicPieceID.COOP_WAITINGFORWAVE, "music_mp_fd_betweenwaves", TEAM_MILITIA )

	RegisterLevelMusicForTeam( eMusicPieceID.COOP_EARLYWAVE_BEGIN, "music_mp_fd_introwave", TEAM_MILITIA )
	RegisterLevelMusicForTeam( eMusicPieceID.COOP_MIDDLEWAVE_BEGIN, "music_mp_fd_midwave", TEAM_MILITIA )
	RegisterLevelMusicForTeam( eMusicPieceID.COOP_FINALWAVE_BEGIN, "music_mp_fd_finalwave", TEAM_MILITIA )

	int difficultyLevel = FD_GetDifficultyLevel()
	string difficultyLevelIntroMusic

	switch ( difficultyLevel )
	{
		case eFDDifficultyLevel.EASY:
		case eFDDifficultyLevel.NORMAL:
		{
			difficultyLevelIntroMusic = "music_mp_fd_intro_easy"
			break
		}

		case eFDDifficultyLevel.HARD:
		{
			difficultyLevelIntroMusic = "music_mp_fd_intro_medium"
			break
		}

		case eFDDifficultyLevel.MASTER:
		case eFDDifficultyLevel.INSANE:

		{
			difficultyLevelIntroMusic = "music_mp_fd_intro_hard"
			break
		}

		default:
		{
			unreachable
		}

	}

	RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_INTRO, difficultyLevelIntroMusic, TEAM_MILITIA )

}

/*
void function FD_OnUseEntGainFocus( entity ent )
{
	file.useHintActive = true
	if ( file.readyUpRui != null )
	{
		RuiSetBool( file.readyUpRui, "isVisible", false )
	}
}

void function FD_OnUseEntLoseFocus( entity ent )
{
	file.useHintActive = false
	if ( file.readyUpRui != null )
	{
		RuiSetBool( file.readyUpRui, "isVisible", true )
	}
}
*/
void function ServerCallback_UpdateGameStats( int p, int a, float v, int suitIndex )
{
	entity player = GetEntityFromEncodedEHandle( p )
	FD_PlayerAwards awardData
	awardData.eHandle = p
	awardData.playerName = player.GetPlayerName()
	awardData.awardID = a
	awardData.awardValue = v
	awardData.suitIndex = suitIndex
	file.playerAwards.append( awardData )
}

void function ServerCallback_ShowGameStats( float endTime )
{
	var rui = RuiCreate( $"ui/fd_gamesummary.rpak", clGlobal.topoFullScreen, RUI_DRAW_HUD, RUI_SORT_SCREENFADE + 100 )
	RuiSetGameTime( rui, "startTime", Time() )
	RuiSetGameTime( rui, "endTime", endTime )

	float delay = 0.75
	int localPlayerIndex = -1
	for ( int i=0; i<file.playerAwards.len(); i++ )
	{
		FD_PlayerAwards awardData = file.playerAwards[i]
		entity player = GetEntityFromEncodedEHandle( awardData.eHandle )

		thread PlaySlideInOutSounds( Time() + delay,  "UI_InGame_FD_VictoryCard" )
		delay += 0.75

		if ( player == GetLocalClientPlayer() )
			localPlayerIndex = i
	}

	PopulateFDAwardData( rui, file.playerAwards, localPlayerIndex )

	if ( GetLocalClientPlayer().GetTeam() == level.nv.winningTeam )
		thread ForcePlayMusic( eMusicPieceID.PVE_OBJECTIVE_START ) // win
	else
		thread ForcePlayMusic( eMusicPieceID.PVE_OBJECTIVE_COMPLETE ) // loss
}

void function Prematch_OnEnter()
{
	clGlobal.lockScoreboard = false
}

void function Playing_OnEnter()
{
	clGlobal.lockScoreboard = false

	thread AttemptTutorialTip( [eFDTutorials.HARVESTER], 7.0 )
}

void function WinnerDetermined_OnEnter()
{
	if ( file.scoreboardWaveData != null )
	{
		RuiDestroyIfAlive( file.scoreboardWaveData )
		file.scoreboardWaveData = null
	}
}

void function Epilogue_OnEnter()
{
	thread HideScoreboard()
	clGlobal.lockScoreboard = true
}

void function OnScoreboardShow()
{
	foreach ( rui in file.waveRuis )
	{
		RuiSetBool( rui, "visible", false )
	}

	foreach ( rui in file.scoreboardExtraRui )
		RuiSetBool( rui, "isVisible", true )

	if ( file.scoreboardWaveData != null )
		RuiSetBool( file.scoreboardWaveData, "isVisible", true )

	thread DelayedFocusScoreboard()
}

void function DelayedFocusScoreboard()
{
	WaitEndFrame()

	if ( !clGlobal.showingScoreboard )
		return

	ScoreboardFocus( GetLocalClientPlayer() )

	string text = Localize( "#X_BUTTON_MUTE" )
	#if PC_PROG
		if ( Origin_IsOverlayAvailable() )
			text = text + "   " + Localize( "#Y_BUTTON_VIEW_PROFILE" )
	#else
		text = text + "   " + Localize( "#Y_BUTTON_VIEW_PROFILE" )
	#endif

	RuiSetString( GetScoreBoardFooterRui(), "footerText", text )
}

void function OnScoreboardHide()
{
	foreach ( rui in file.waveRuis )
	{
		RuiSetBool( rui, "visible", true )
	}

	foreach ( rui in file.scoreboardExtraRui )
		RuiSetBool( rui, "isVisible", false )

	if ( file.scoreboardWaveData != null )
		RuiSetBool( file.scoreboardWaveData, "isVisible", false )

	ScoreboardLoseFocus( GetLocalClientPlayer() )
}

void function ScoreboardInputFD( int key )
{
	Assert( clGlobal.showingScoreboard )

	entity player = GetLocalClientPlayer()

	switch( key )
	{
		case SCOREBOARD_INPUT_SELECT_PREV:
			ScoreboardSelectPrevPlayer( player )
			break

		case SCOREBOARD_INPUT_SELECT_NEXT:
			ScoreboardSelectNextPlayer( player )
			break
	}
}

void function UseHarvesterShieldBoost( entity player )
{
	if ( player.ContextAction_IsActive() )
		return

	if ( player.GetPlayerNetInt( "numHarvesterShieldBoost" ) > 0 && GetGlobalNetBool( "FD_waveActive" ) && BurnMeter_HarvesterShieldCanUse( GetLocalViewPlayer() ) )
		thread UseHarvesterShieldBoostThread( player )
}

bool function PlayerHasHarvesterShieldBoost( entity player )
{
	return player.GetPlayerNetInt( "numHarvesterShieldBoost" ) > 0
}

bool function PlayerHasSentryTurretReady( entity player )
{
	entity offhandWeapon = player.GetOffhandWeapon( OFFHAND_INVENTORY )
	if ( !IsValid( offhandWeapon ) )
		return false

	return offhandWeapon.GetWeaponClassName() == "mp_ability_turretweapon"
}

bool function PlayerHasArcTrapReady( entity player )
{
	entity offhandWeapon = player.GetOffhandWeapon( OFFHAND_INVENTORY )
	if ( !IsValid( offhandWeapon ) )
		return false

	return offhandWeapon.GetWeaponClassName() == "mp_weapon_arc_trap"
}

bool function PlayerHasCoreOverloadReady( entity player )
{
	return player.GetPlayerNetInt( "numSuperRodeoGrenades" ) > 0
}

void function UseHarvesterShieldBoostThread( entity player )
{
	if ( !IsAlive( player ) )
		return

	if ( file.usingShieldBoost )
		return

	player.EndSignal( "OnDeath" )

	file.usingShieldBoost = true

	OnThreadEnd(
	function() : ( player )
		{
			file.usingShieldBoost = false
		}
	)

	float duration = 1.0
	AnnouncementData announcement = Announcement_Create( "#HUD_SHIELD_BOOST_USED" )
	Announcement_SetStyle( announcement, ANNOUNCEMENT_STYLE_FD_ITEM )
	Announcement_SetSoundAlias( announcement,  "UI_TitanBattery_Titan_PickUp" )
	Announcement_SetPurge( announcement, true )
	Announcement_SetIcon( announcement, $"rui/menu/boosts/boost_icon_harvester_shield_256" )
	Announcement_SetPriority( announcement, 200 ) //Be higher priority than Titanfall ready indicator etc
	Announcement_SetOptionalTextArgsArray( announcement, [ "false" ] )
	announcement.duration = duration
	AnnouncementFromClass( GetLocalViewPlayer(), announcement )
	player.ClientCommand( "FD_UseHarvesterShieldBoost" )

	wait duration
}

void function FD_ScoreboardUpdate( entity player, var rui )
{
	int numTurrets = player.GetPlayerNetInt( "burn_numTurrets" )
	int numShieldBoosts = player.GetPlayerNetInt( "numHarvesterShieldBoost" )
	int numCoreOverload = player.GetPlayerNetInt( "numSuperRodeoGrenades" )

	int index = 0
	for ( int i=0; i<numTurrets; i++ )
	{
		RuiSetImage( rui, "extraIcon" + index++, $"rui/menu/boosts/boost_icon_personel_sentry" )
	}

	if ( numShieldBoosts > 0 )
		RuiSetImage( rui, "extraIcon" + index++, $"rui/menu/boosts/boost_icon_harvester_shield" )

	if ( numCoreOverload > 0 )
		RuiSetImage( rui, "extraIcon" + index++, $"rui/menu/boosts/boost_icon_core_overload" )

	while ( index < 6 ) // 6 is number of slots
	{
		RuiSetImage( rui, "extraIcon" + index++, $"" )
	}
}

void function ServerCallback_FD_NotifyMVP( int playerHandle )
{
	entity player = GetEntityFromEncodedEHandle( playerHandle )

	if ( "FDWaveMVP" in file.waveAwardRuis )
	{
		var rui = file.waveAwardRuis[ "FDWaveMVP" ]
		RuiSetString( rui, "itemText", Localize( "#SCORE_EVENT_WAVE_MVP_OTHER", player.GetPlayerName() ) )
	}
}

void function DEV_FD_HideHud()
{
	RuiSetBool( file.scoreSplashRui, "isVisible", false )
	RuiSetBool( ClGameState_GetRui(), "isVisible", false )
	if ( file.scoreboardIconCover != null )
	{
		RuiDestroy( file.scoreboardIconCover )
		file.scoreboardIconCover = null
	}
}
