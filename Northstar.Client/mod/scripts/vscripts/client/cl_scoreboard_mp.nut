untyped

global const SCOREBOARD_LOCAL_PLAYER_COLOR = <LOCAL_R / 255.0, LOCAL_G / 255.0, LOCAL_B / 255.0>
global const SCOREBOARD_PARTY_COLOR = <PARTY_R / 255.0, PARTY_G / 255.0, PARTY_B / 255.0>
const SCOREBOARD_FRIENDLY_COLOR = <FRIENDLY_R / 255.0, FRIENDLY_G / 255.0, FRIENDLY_B / 255.0>
const SCOREBOARD_FRIENDLY_SELECTED_COLOR = <0.6640625, 0.7578125, 0.85546875>
const SCOREBOARD_ENEMY_COLOR = <ENEMY_R / 255.0, ENEMY_G / 255.0, ENEMY_B / 255.0>
const SCOREBOARD_ENEMY_SELECTED_COLOR = <1.0, 0.7019, 0.592>
const SCOREBOARD_DEAD_FONT_COLOR = <0.7, 0.7, 0.7>
const SCOREBOARD_FFA_COLOR = <0.5, 0.5, 0.5>
const SCOREBOARD_BG_ALPHA = 0.35
const SCOREBOARD_EMPTY_COLOR = <0.0, 0.0, 0.0>
const SCOREBOARD_EMPTY_BG_ALPHA = 0.35

const SCOREBOARD_TITLE_HEIGHT = 50
const SCOREBOARD_SUBTITLE_HEIGHT = 35
const SCOREBOARD_FOOTER_HEIGHT = 35
const SCOREBOARD_TEAM_LOGO_OFFSET = 24
const SCOREBOARD_TEAM_LOGO_HEIGHT = 64
const SCOREBOARD_PLAYER_ROW_OFFSET = 12
const SCOREBOARD_PLAYER_ROW_HEIGHT = 35
const SCOREBOARD_PLAYER_ROW_SPACING = 2

const int MAX_TEAM_SLOTS = 16

const int MIC_STATE_NO_MIC = 0
const int MIC_STATE_HAS_MIC = 1
const int MIC_STATE_TALKING = 2
const int MIC_STATE_PARTY_HAS_MIC = 3
const int MIC_STATE_PARTY_TALKING = 4
const int MIC_STATE_MUTED = 5

global function ClScoreboardMp_Init
global function ClScoreboardMp_GetGameTypeDescElem
global function ScoreboardFocus
global function ScoreboardLoseFocus
global function ScoreboardSelectPrevPlayer
global function ScoreboardSelectNextPlayer
global function GetScoreBoardFooterRui
global function SetScoreboardUpdateCallback

struct {
	bool hasFocus = false
	var selectedPlayer
	var prevPlayer
	var nextPlayer

	var scoreboardBg
	var scoreboard
	var background

	array<var> scoreboardOverlays
	array<var> scoreboardElems

	table header = {
		background = null
		gametypeAndMap = null
		gametypeDesc = null
		scoreHeader = null
	}

	var footer
	var pingText

	table teamElems

	table highlightColumns

	var nameEndColumn

	table playerElems

	var scoreboardRUI

	void functionref(entity,var) scoreboardUpdateCallback
} file

function ClScoreboardMp_Init()
{
	clGlobal.initScoreboardFunc = InitScoreboardMP
	clGlobal.showScoreboardFunc = ShowScoreboardMP
	clGlobal.hideScoreboardFunc = HideScoreboardMP
	clGlobal.scoreboardInputFunc = ScoreboardInputMP

	RegisterConCommandTriggeredCallback( "scoreboard_focus", ScoreboardFocus )
	RegisterConCommandTriggeredCallback( "scoreboard_toggle_focus", ScoreboardToggleFocus )
}

void function ScoreboardFocus( entity player )
{
	if ( !clGlobal.showingScoreboard )
	{
		return
	}

	EmitSoundOnEntity( player, "menu_click" )
	file.hasFocus = true

	file.selectedPlayer = GetLocalClientPlayer()
	SetScoreboardPlayer( file.selectedPlayer )
	RuiSetGameTime( Hud_GetRui( file.footer ), "startFadeTime", -1.0 )

	string text = Localize( "#LEFT_SCOREBOARD_EXIT" ) + "   " + Localize( "#X_BUTTON_MUTE" )
	#if PC_PROG
		if ( Origin_IsOverlayAvailable() )
			text = text + "   " + Localize( "#Y_BUTTON_VIEW_PROFILE" )
	#else
		text = text + "   " + Localize( "#Y_BUTTON_VIEW_PROFILE" )
	#endif

	RuiSetString( Hud_GetRui( file.footer ), "footerText", text )
}

void function ScoreboardLoseFocus( entity player )
{
	if ( !clGlobal.showingScoreboard )
		return

	EmitSoundOnEntity( player, "menu_click" )
	file.hasFocus = false
	file.selectedPlayer = null
	SetScoreboardPlayer( null )

	RuiSetString( Hud_GetRui( file.footer ), "footerText", "" )
	//RuiSetGameTime( Hud_GetRui( file.footer ), "startFadeTime", Time() )
	//RuiSetString( Hud_GetRui( file.footer ), "footerText", Localize( "#RIGHT_SCOREBOARD_FOCUS" ) )
}

void function ScoreboardToggleFocus( entity player )
{
	if ( file.hasFocus )
		ScoreboardLoseFocus( player )
	else
		ScoreboardFocus( player )
}

int function GetEnemyScoreboardTeam()
{
	return GetEnemyTeam( GetLocalClientPlayer().GetTeam() )
}

int function GetScoreboardDisplaySlotCount()
{
	int rawValue = expect int( level.maxTeamSize )
	if ( UseSingleTeamScoreboard() )
		rawValue = GetCurrentPlaylistVarInt( "max_players", 8 )

	return minint( MAX_TEAM_SLOTS, rawValue )
}

void function InitScoreboardMP()
{
	entity localPlayer = GetLocalClientPlayer()
	int myTeam = localPlayer.GetTeam()
	int enemyTeam = GetEnemyScoreboardTeam()
	print("======")
	print("MyTeam:"+myTeam)
	print("EnemyTeam:"+enemyTeam)
	print("======")
	string mapName = GetMapDisplayName( GetMapName() )

	local scoreboard = HudElement( "Scoreboard" )
	file.scoreboard = scoreboard

	file.header.gametypeAndMap = HudElement( "ScoreboardGametypeAndMap", scoreboard )
	RuiSetString( Hud_GetRui( file.header.gametypeAndMap ), "gameType", GAMETYPE_TEXT[ GAMETYPE ] )
	RuiSetString( Hud_GetRui( file.header.gametypeAndMap ), "mapName", mapName )
	file.header.gametypeDesc = HudElement( "ScoreboardHeaderGametypeDesc", scoreboard )
	RuiSetString( Hud_GetRui( file.header.gametypeDesc ), "desc", GAMEDESC_CURRENT )
	file.header.scoreHeader = HudElement( "ScoreboardScoreHeader", scoreboard )

	file.footer = HudElement( "ScoreboardGamepadFooter", scoreboard )
	file.pingText = HudElement( "ScoreboardPingText", scoreboard )

	file.teamElems[myTeam] <- {
		logo = HudElement( "ScoreboardMyTeamLogo", scoreboard )
		score = HudElement( "ScoreboardMyTeamScore", scoreboard )
	}

	file.teamElems[enemyTeam] <- {
		logo = HudElement( "ScoreboardEnemyTeamLogo", scoreboard )
		score = HudElement( "ScoreboardEnemyTeamScore", scoreboard )
	}

	if ( !UseSingleTeamScoreboard() )
	{
		string myFaction = GetFactionChoice( localPlayer )
		ItemDisplayData myDisplayData = GetItemDisplayData( myFaction )
		asset myFactionLogo = myDisplayData.image
		RuiSetImage( Hud_GetRui( file.teamElems[myTeam].logo ), "logo", myFactionLogo )
	}

	file.scoreboardElems.append( file.header.gametypeAndMap )
	file.scoreboardElems.append( file.header.gametypeDesc )
	file.scoreboardElems.append( file.header.scoreHeader )
	file.scoreboardElems.append( file.footer )
	file.scoreboardElems.append( file.pingText )

	file.playerElems[myTeam] <- []
	file.playerElems[enemyTeam] <- []

	array<int> teams = [ myTeam, enemyTeam ]
	local prefix

	int maxPlayerDisplaySlots = GetScoreboardDisplaySlotCount()

	foreach ( int team in teams )
	{
		file.scoreboardElems.append( file.teamElems[team].logo )
		file.scoreboardElems.append( file.teamElems[team].score )

		if ( team == myTeam )
			prefix = "ScoreboardTeammate"
		else
			prefix = "ScoreboardOpponent"

		for ( int elem = 0; elem < maxPlayerDisplaySlots; elem++  )
		{
			local elemNum = string( elem )

			local Table = {}
			Table.background <- HudElement( prefix + "Background" + elemNum, scoreboard )
			Table.background.Show()

			file.scoreboardElems.append( Table.background )

			file.playerElems[team].append( Table )
		}
	}

	file.header.gametypeAndMap.Show()
	file.header.gametypeDesc.Show()

	if ( UseSingleTeamScoreboard() )
	{
		file.teamElems[myTeam].logo.Hide()
		file.teamElems[myTeam].score.Hide()
		file.teamElems[enemyTeam].logo.Hide()
		file.teamElems[enemyTeam].score.Hide()
	}
	else
	{
		file.teamElems[myTeam].logo.Show()
		file.teamElems[myTeam].score.Show()
		file.teamElems[enemyTeam].logo.Show()
		file.teamElems[enemyTeam].score.Show()
	}
}


array<var> function CreateScoreboardOverlays()
{
	array<var> overlays

	switch ( GAMETYPE )
	{
		case ATTRITION:
			overlays.extend( AT_CreateScoreboardOverlays() )
			break;
		default:

			break;
	}

	return overlays
}

function ScoreboardFadeIn()
{
	foreach ( elem in file.scoreboardElems )
	{
		RuiSetGameTime( Hud_GetRui( elem ), "fadeOutStartTime", RUI_BADGAMETIME )
		RuiSetGameTime( Hud_GetRui( elem ), "fadeInStartTime", Time() )
	}

	if ( file.scoreboardBg != null )
	{
		RuiSetGameTime( file.scoreboardBg, "fadeOutStartTime", RUI_BADGAMETIME )
		RuiSetGameTime( file.scoreboardBg, "fadeInStartTime", Time() )
	}
}

function ScoreboardFadeOut()
{
	foreach ( elem in file.scoreboardElems )
	{
		RuiSetGameTime( Hud_GetRui( elem ), "fadeInStartTime", RUI_BADGAMETIME )
		RuiSetGameTime( Hud_GetRui( elem ), "fadeOutStartTime", Time() )
	}

	if ( file.scoreboardBg != null )
	{
		RuiSetGameTime( file.scoreboardBg, "fadeInStartTime", RUI_BADGAMETIME )
		RuiSetGameTime( file.scoreboardBg, "fadeOutStartTime", Time() )
	}
}

void function ShowScoreboardMP()
{
	entity localPlayer = GetLocalClientPlayer()

	file.scoreboardBg = RuiCreate( $"ui/scoreboard_background.rpak", clGlobal.topoFullScreen, RUI_DRAW_HUD, 0 )
	file.scoreboardOverlays = CreateScoreboardOverlays()

	int myTeam = localPlayer.GetTeam()
	int enemyTeam = GetEnemyScoreboardTeam()

	/*if ( file.hasFocus )
	{
		if ( !IsValid( file.selectedPlayer ) )
			file.selectedPlayer = localPlayer
		SetScoreboardPlayer( file.selectedPlayer )
	} else {*/
		RuiSetGameTime( Hud_GetRui( file.footer ), "startFadeTime", Time() )
		RuiSetString( Hud_GetRui( file.footer ), "footerText", Localize( "#RIGHT_SCOREBOARD_FOCUS" ) )
	//}

	EndSignal( clGlobal.signalDummy, "OnHideScoreboard" )

	var screenSize = Hud.GetScreenSize()
	float resMultX = float( screenSize[0] ) / 1920.0
	float resMultY = float( screenSize[1] ) / 1080.0

	int numTeamPlayersDisplayed = GetNumTeamPlayers()
	int teamHeight = SCOREBOARD_TEAM_LOGO_HEIGHT + SCOREBOARD_PLAYER_ROW_OFFSET + ( SCOREBOARD_PLAYER_ROW_HEIGHT + SCOREBOARD_PLAYER_ROW_SPACING ) * numTeamPlayersDisplayed - SCOREBOARD_PLAYER_ROW_SPACING
	int scoreboardHeight

	if ( !UseSingleTeamScoreboard() )
	{
		scoreboardHeight = SCOREBOARD_TITLE_HEIGHT + SCOREBOARD_SUBTITLE_HEIGHT + SCOREBOARD_TEAM_LOGO_OFFSET + teamHeight + SCOREBOARD_TEAM_LOGO_OFFSET + teamHeight + SCOREBOARD_FOOTER_HEIGHT
	}
	else
	{
		scoreboardHeight = SCOREBOARD_TITLE_HEIGHT + SCOREBOARD_SUBTITLE_HEIGHT + SCOREBOARD_TEAM_LOGO_OFFSET + teamHeight + SCOREBOARD_FOOTER_HEIGHT
	}
	int scoreboardYOffset = -int( ( ( 1080 - scoreboardHeight ) / 2 - 48 ) * resMultY )

	int winningTeamYOffset = int( ( SCOREBOARD_SUBTITLE_HEIGHT + SCOREBOARD_TEAM_LOGO_OFFSET ) * resMultY )
	int losingTeamYOffset = int( ( SCOREBOARD_SUBTITLE_HEIGHT + SCOREBOARD_TEAM_LOGO_OFFSET + teamHeight + SCOREBOARD_TEAM_LOGO_OFFSET ) * resMultY )
	int footerYOffset = int( ( scoreboardHeight - SCOREBOARD_TITLE_HEIGHT - SCOREBOARD_FOOTER_HEIGHT + 36 ) * resMultY )

	int index
	var elemTable

	table<int, array<entity> > teamPlayers
	teamPlayers[myTeam] <- []
	teamPlayers[enemyTeam] <- []

	table playerSlotEmpty = {}
	playerSlotEmpty[myTeam] <- SCOREBOARD_MATERIAL_FRIENDLY_SLOT
	playerSlotEmpty[enemyTeam] <- SCOREBOARD_MATERIAL_ENEMY_SLOT

	table teamScore = {}
	teamScore[myTeam] <- []
	teamScore[enemyTeam] <- []

	int winningTeam
	int losingTeam
	IntFromEntityCompare compareFunc = GetScoreboardCompareFunc()

	file.scoreboard.Show()
	ScoreboardFadeIn()

	int maxPlayerDisplaySlots = GetScoreboardDisplaySlotCount()

	bool firstUpdate = true

	string enemyFaction
	string lastEnemyFaction
	int lastPlayerTeam

	for ( ;; )
	{
		localPlayer = GetLocalClientPlayer()

		Assert( clGlobal.showingScoreboard )

		if ( file.hasFocus )
		{
			if ( !IsValid( file.selectedPlayer ) )
			{
				if ( IsValid( file.nextPlayer ) )
					file.selectedPlayer = file.nextPlayer
				else
					file.selectedPlayer = localPlayer
				SetScoreboardPlayer( file.selectedPlayer )
			}
		}
		myTeam = localPlayer.GetTeam()
		enemyTeam = GetEnemyScoreboardTeam()

		if ( UseSingleTeamScoreboard() )
		{
			teamPlayers[myTeam] = GetSortedPlayers( compareFunc, 0 )
			teamPlayers[enemyTeam] = []

			winningTeam = myTeam
			losingTeam = enemyTeam

			if ( teamPlayers[myTeam].len() > 0 )
				RuiSetBool( Hud_GetRui( file.header.scoreHeader ), "winningTeamIsFriendly", teamPlayers[myTeam][ 0 ] == GetLocalClientPlayer() )
		}
		else
		{
			enemyFaction = GetEnemyFaction( localPlayer )
			if ( enemyFaction != lastEnemyFaction )
			{
				ItemDisplayData enemyDisplayData = GetItemDisplayData( enemyFaction )
				asset enemyFactionLogo = enemyDisplayData.image
				RuiSetImage( Hud_GetRui( file.teamElems[enemyTeam].logo ), "logo", enemyFactionLogo )
			}
			if ( myTeam != lastPlayerTeam )
			{
				string myFaction = GetFactionChoice( localPlayer )
				ItemDisplayData myDisplayData = GetItemDisplayData( myFaction )
				asset myFactionLogo = myDisplayData.image
				RuiSetImage( Hud_GetRui( file.teamElems[myTeam].logo ), "logo", myFactionLogo )
			}
			lastEnemyFaction = enemyFaction
			lastPlayerTeam = myTeam

			teamPlayers[myTeam] = GetSortedPlayers( compareFunc, myTeam )
			teamPlayers[enemyTeam] = GetSortedPlayers( compareFunc, enemyTeam )

			if ( IsRoundBased() )
			{
				teamScore[myTeam] <- GameRules_GetTeamScore2( myTeam )
				teamScore[enemyTeam] <- GameRules_GetTeamScore2( enemyTeam )
			}
			else
			{
				teamScore[myTeam] <- GameRules_GetTeamScore( myTeam )
				teamScore[enemyTeam] <- GameRules_GetTeamScore( enemyTeam )
			}

			if ( teamScore[myTeam] >= teamScore[enemyTeam] )
			{
				winningTeam = myTeam
				losingTeam = enemyTeam
				RuiSetBool( Hud_GetRui( file.header.scoreHeader ), "winningTeamIsFriendly", true )
			}
			else
			{
				winningTeam = enemyTeam
				losingTeam = myTeam
				RuiSetBool( Hud_GetRui( file.header.scoreHeader ), "winningTeamIsFriendly", false )
			}
		}

		if ( !UseSingleTeamScoreboard() )
		{
			RuiSetInt( Hud_GetRui( file.teamElems[winningTeam].score ), "score", teamScore[winningTeam] )
			RuiSetInt( Hud_GetRui( file.teamElems[losingTeam].score ), "score", teamScore[losingTeam] )

			file.teamElems[winningTeam].logo.SetY( winningTeamYOffset )
			file.teamElems[losingTeam].logo.SetY( losingTeamYOffset )
			file.header.gametypeAndMap.SetY( scoreboardYOffset )
			file.footer.SetY( footerYOffset )
		}
		else
		{
			file.header.gametypeAndMap.SetY( -160 * resMultY )
			file.teamElems[winningTeam].logo.SetY( winningTeamYOffset )
			file.footer.SetY( footerYOffset )
		}

		array<entity> allPlayers = []
		int selectedPlayerIndex = 0

		foreach ( team, players in teamPlayers )
		{
			index = 0

			foreach ( entity player in players )
			{
				if ( !IsValid( player ) )
					continue

				elemTable = file.playerElems[team][index]

				var rui = Hud_GetRui( elemTable.background )
				bool playerIsAlive = IsAlive( player )
				if ( UseSingleTeamScoreboard() )
				{
					if ( !playerIsAlive )
						RuiSetFloat3( rui, "bgColor", <0.5, 0.5, 0.5> )
					else
						RuiSetFloat3( rui, "bgColor", player.GetTeam() == myTeam ? SCOREBOARD_FRIENDLY_COLOR : SCOREBOARD_ENEMY_COLOR )

					if ( player == file.selectedPlayer )
					{
						RuiSetFloat( rui, "selectedAlpha", 1.0 )
						selectedPlayerIndex = allPlayers.len()
					}
					else
					{
						RuiSetFloat( rui, "selectedAlpha", 0.0 )
					}
				}
				else
				{
					if ( player == file.selectedPlayer )
					{
						if ( !playerIsAlive )
							RuiSetFloat3( rui, "bgColor", <0.5, 0.5, 0.5> )
						else
							RuiSetFloat3( rui, "bgColor", team == myTeam ? SCOREBOARD_FRIENDLY_SELECTED_COLOR : SCOREBOARD_ENEMY_SELECTED_COLOR )
						RuiSetFloat( rui, "selectedAlpha", 1.0 )
						selectedPlayerIndex = allPlayers.len()
					}
					else
					{
						if ( !playerIsAlive )
							RuiSetFloat3( rui, "bgColor", <0.5, 0.5, 0.5> )
						else
							RuiSetFloat3( rui, "bgColor", team == myTeam ? SCOREBOARD_FRIENDLY_COLOR : SCOREBOARD_ENEMY_COLOR )
						RuiSetFloat( rui, "selectedAlpha", 0.0 )
					}
				}

				allPlayers.append( player )

				RuiSetImage( rui, "playerCard", CallsignIcon_GetSmallImage( PlayerCallsignIcon_GetActive( player ) ) )

				//-------------------
				// Update player icon
				//-------------------

				switch ( GetPilotTitanStatusForPlayer( player ) )
				{
					case ePlayerStatusType.PTS_TYPE_DEAD_READY:
					case ePlayerStatusType.PTS_TYPE_DEAD:
						RuiSetImage( rui, "playerStatus", $"rui/hud/scoreboard/status_dead" )
					break
					case ePlayerStatusType.PTS_TYPE_DEAD_PILOT_TITAN:
						RuiSetImage( rui, "playerStatus", $"rui/hud/scoreboard/status_dead_with_titan" )
					break
					case ePlayerStatusType.PTS_TYPE_ION:
					case ePlayerStatusType.PTS_TYPE_SCORCH:
					case ePlayerStatusType.PTS_TYPE_RONIN:
					case ePlayerStatusType.PTS_TYPE_TONE:
					case ePlayerStatusType.PTS_TYPE_LEGION:
					case ePlayerStatusType.PTS_TYPE_NORTHSTAR:
					case ePlayerStatusType.PTS_TYPE_VANGUARD:
						RuiSetImage( rui, "playerStatus", $"rui/hud/scoreboard/status_titan" )
					break
					case ePlayerStatusType.PTS_TYPE_PILOT_TITAN:
						RuiSetImage( rui, "playerStatus", $"rui/hud/scoreboard/status_alive_with_titan" )
					break
					case ePlayerStatusType.PTS_TYPE_EVAC:
						RuiSetImage( rui, "playerStatus", $"rui/hud/scoreboard/status_evac" )
					break
					case ePlayerStatusType.PTS_TYPE_READY:
					case ePlayerStatusType.PTS_TYPE_PILOT:
						RuiSetImage( rui, "playerStatus", $"rui/hud/scoreboard/status_pilot" )
					break
					case ePlayerStatusType.PTS_TYPE_WAVE_READY:
						RuiSetImage( rui, "playerStatus", $"rui/hud/gametype_icons/bounty_hunt/bh_green_check" )
					break
					case ePlayerStatusType.PTS_TYPE_WAVE_NOT_READY:
						RuiSetImage( rui, "playerStatus", $"rui/hud/gametype_icons/bounty_hunt/bh_grey_check" )
					break
				}

				/*
				TODO: party leader
				if ( player.IsPartyLeader() )
					elemTable.leader.Show()
				else

					elemTable.leader.Hide()

				elemTable.status.Show()*/

				// Update player level number

				// Update player name and color
				string name = player.GetPlayerNameWithClanTag()
				if ( player.HasBadReputation() )
					name = "* " + name

				RuiSetString( rui, "playerName", name )

				if ( player == localPlayer )
				{
					RuiSetFloat3( rui, "textColor", SCOREBOARD_LOCAL_PLAYER_COLOR )
				}
				else
				{
					if ( !IsPrivateMatch() && IsPartyMember( player ) )
					{
						RuiSetFloat3( rui, "textColor", SCOREBOARD_PARTY_COLOR )
					}
					else
					{
						if ( playerIsAlive )
							RuiSetFloat3( rui, "textColor", <1.0, 1.0, 1.0> )
						else
							RuiSetFloat3( rui, "textColor", SCOREBOARD_DEAD_FONT_COLOR )
					}
				}
				// Update MIC/Talking icon state
				if ( player.HasMic() )
				{
					if ( player.IsMuted() )
					{
						RuiSetInt( rui, "micState", MIC_STATE_MUTED )
					}
					else if ( player.InPartyChat() )
					{
						if ( player.IsTalking() )
							RuiSetInt( rui, "micState", MIC_STATE_PARTY_TALKING )
						else
							RuiSetInt( rui, "micState", MIC_STATE_PARTY_HAS_MIC )
					}
					else if ( player.IsTalking() )
					{
						RuiSetInt( rui, "micState", MIC_STATE_TALKING )
					}
					else
					{
						RuiSetInt( rui, "micState", MIC_STATE_HAS_MIC )
					}
				}
				else
				{
					RuiSetInt( rui, "micState", MIC_STATE_NO_MIC )
				}

				UpdateScoreboardForGamemode( player, rui, Hud_GetRui( file.header.scoreHeader ) )

				if ( file.scoreboardUpdateCallback != null )
					file.scoreboardUpdateCallback( player, rui )

				index++

				if ( index >= maxPlayerDisplaySlots )
					break

				if ( !firstUpdate )
					WaitFrame()
			}

			int reservedCount
			int connectingCount
			int loadingCount
			if ( UseSingleTeamScoreboard() )
			{
				reservedCount = GetTotalPendingPlayersReserved()
				connectingCount = GetTotalPendingPlayersConnecting()
				loadingCount = GetTotalPendingPlayersLoading()
			}
			else
			{
				reservedCount = GetTeamPendingPlayersReserved( team )
				connectingCount = GetTeamPendingPlayersConnecting( team )
				loadingCount = GetTeamPendingPlayersLoading( team )
			}

			if ( team > 0
				&& ( !UseSingleTeamScoreboard() || team == TEAM_MILITIA )  // if you run this block for both teams, then it will show players "connecting" for both teams
				)
			{
				local numDone = 0
				for ( int idx = 0; idx < (reservedCount + connectingCount + loadingCount); idx++ )
				{
					if ( index >= maxPlayerDisplaySlots )
						continue

					elemTable = file.playerElems[team][index]

					if ( numDone < loadingCount )
						RuiSetString( Hud_GetRui( elemTable.background ), "playerName", Localize( "#PENDING_PLAYER_STATUS_LOADING" ) )
					else if ( numDone < (loadingCount + connectingCount) )
						RuiSetString( Hud_GetRui( elemTable.background ), "playerName", Localize( "#PENDING_PLAYER_STATUS_CONNECTING" ) )
					else
						RuiSetString( Hud_GetRui( elemTable.background ), "playerName", Localize( "#PENDING_PLAYER_STATUS_CONNECTING" ) )

					numDone++
					index++
				}
			}

			while ( index < maxPlayerDisplaySlots )
			{
				elemTable = file.playerElems[team][index]

				var rui = Hud_GetRui( elemTable.background )
				RuiSetString( rui, "playerName", "" )
				RuiSetInt( rui, "micState", MIC_STATE_NO_MIC )
				RuiSetImage( rui, "playerStatus", $"" )
				for( int i=0; i<6; i++ )
					RuiSetImage( rui, "extraIcon" + i, $"" )
				RuiSetFloat3( rui, "bgColor", SCOREBOARD_EMPTY_COLOR )
				RuiSetFloat( rui, "bgAlpha", SCOREBOARD_EMPTY_BG_ALPHA )
				if ( (UseSingleTeamScoreboard()) && team != myTeam )
					RuiSetFloat( rui, "bgAlpha", 0.0 )
				RuiSetImage( rui, "playerCard", $"" )
				RuiSetInt( rui, "numScoreColumns", 0 )

				index++
			}
		}

		RuiSetInt( Hud_GetRui( file.pingText ), "ping", MyPing() )

		if ( allPlayers.len() )
		{
			file.prevPlayer = allPlayers[ (selectedPlayerIndex + allPlayers.len() - 1) % allPlayers.len() ]
			file.nextPlayer = allPlayers[ (selectedPlayerIndex + 1) % allPlayers.len() ]
		}
		else
		{
			file.prevPlayer = file.selectedPlayer
			file.nextPlayer = file.selectedPlayer
		}

		teamPlayers[myTeam].clear()
		teamPlayers[enemyTeam].clear()

		firstUpdate = false
		WaitFrame()
	}
}

void function UpdateScoreboardForGamemode( entity player, var rowRui, var scoreHeaderRui )
{
	array<string> headers = GameMode_GetScoreboardColumnTitles( GAMETYPE )
	array<int> playerGameStats = GameMode_GetScoreboardColumnScoreTypes( GAMETYPE )
	array<int> numDigits = GameMode_GetScoreboardColumnNumDigits( GAMETYPE )

	Assert( headers.len() > 0 && headers.len() == playerGameStats.len() && headers.len() == numDigits.len() )

	//int scoreboardWidth = 570
	int playerScore1 = 0
	int playerScore2 = 0
	int playerScore3 = 0
	int playerScore4 = 0
	int playerScore1NumDigits = 2
	int playerScore2NumDigits = 2
	int playerScore3NumDigits = 2
	int playerScore4NumDigits = 2
	string playerScore1Header
	string playerScore2Header
	string playerScore3Header
	string playerScore4Header

	int numScoreColumns = headers.len()

	switch ( numScoreColumns )
	{
		case 4:
			playerScore4Header = headers[ 3 ]
			playerScore4 = player.GetPlayerGameStat( playerGameStats[ 3 ] )
			playerScore4NumDigits = numDigits[ 3 ]

		case 3:
			playerScore3Header = headers[ 2 ]
			playerScore3 = player.GetPlayerGameStat( playerGameStats[ 2 ] )
			playerScore3NumDigits = numDigits[ 2 ]

		case 2:
			playerScore2Header = headers[ 1 ]
			playerScore2 = player.GetPlayerGameStat( playerGameStats[ 1 ] )
			playerScore2NumDigits = numDigits[ 1 ]

		case 1:
			playerScore1Header = headers[ 0 ]
			playerScore1 = player.GetPlayerGameStat( playerGameStats[ 0 ] )
			playerScore1NumDigits = numDigits[ 0 ]
	}

	if ( GAMETYPE == ATTRITION && GetGameState() >= eGameState.WinnerDetermined )
	{
		numScoreColumns = 2
		playerScore1 = player.GetPlayerGameStat( playerGameStats[ 0 ] )
		playerScore2 = player.GetPlayerGameStat( playerGameStats[ 2 ] )
		playerScore1NumDigits = numDigits[ 0 ]
		playerScore2NumDigits = numDigits[ 2 ]
		playerScore1Header = headers[ 0 ]
		playerScore2Header = headers[ 2 ]
	}

	/*int vguiWidth = int( scoreboardWidth * ( Hud.GetScreenSize()[ 1 ] / 1080.0 ) )
	file.footer.SetWidth( vguiWidth )
	file.header.gametypeAndMap.SetWidth( vguiWidth )
	file.header.gametypeDesc.SetWidth( vguiWidth )
	file.header.scoreHeader.SetWidth( vguiWidth )
	foreach ( team in [ TEAM_IMC, TEAM_MILITIA ] )
	{
		foreach ( elem in file.playerElems[ team ] )
		{
			elem.background.SetWidth( vguiWidth )
		}
	}*/

	RuiSetInt( rowRui, "numScoreColumns", numScoreColumns )
	RuiSetInt( rowRui, "playerScore1", playerScore1 )
	RuiSetInt( rowRui, "playerScore2", playerScore2 )
	RuiSetInt( rowRui, "playerScore3", playerScore3 )
	RuiSetInt( rowRui, "playerScore4", playerScore4 )
	RuiSetInt( rowRui, "playerScore1NumDigits", playerScore1NumDigits )
	RuiSetInt( rowRui, "playerScore2NumDigits", playerScore2NumDigits )
	RuiSetInt( rowRui, "playerScore3NumDigits", playerScore3NumDigits )
	RuiSetInt( rowRui, "playerScore4NumDigits", playerScore4NumDigits )
	RuiSetInt( scoreHeaderRui, "numScoreColumns", numScoreColumns )
	RuiSetString( scoreHeaderRui, "playerScore1Header", playerScore1Header )
	RuiSetString( scoreHeaderRui, "playerScore2Header", playerScore2Header )
	RuiSetString( scoreHeaderRui, "playerScore3Header", playerScore3Header )
	RuiSetString( scoreHeaderRui, "playerScore4Header", playerScore4Header )
	RuiSetInt( scoreHeaderRui, "playerScore1NumDigits", playerScore1NumDigits )
	RuiSetInt( scoreHeaderRui, "playerScore2NumDigits", playerScore2NumDigits )
	RuiSetInt( scoreHeaderRui, "playerScore3NumDigits", playerScore3NumDigits )
	RuiSetInt( scoreHeaderRui, "playerScore4NumDigits", playerScore4NumDigits )
}

void function HideScoreboardMP()
{
	ScoreboardFadeOut()
	wait( 0.1 )
	file.hasFocus = false
	file.selectedPlayer = null
	SetScoreboardPlayer( null )

	file.scoreboard.Hide()
	if ( file.scoreboardBg != null )
	{
		RuiDestroy( file.scoreboardBg )
		file.scoreboardBg = null
	}
	foreach ( overlay in file.scoreboardOverlays )
	{
		RuiDestroy( overlay )
	}
	file.scoreboardOverlays = []

	entity localPlayer = GetLocalClientPlayer()
	int myTeam = localPlayer.GetTeam()
	int enemyTeam = GetEnemyScoreboardTeam()

	Signal( clGlobal.signalDummy, "OnHideScoreboard" )
}

function GetConnectionImage( ping )
{
	local image

	if ( ping > 150 )
		image = SCOREBOARD_MATERIAL_CONNECTION_QUALITY_1
	else if ( ping > 100 )
		image = SCOREBOARD_MATERIAL_CONNECTION_QUALITY_2
	else if ( ping > 75 )
		image = SCOREBOARD_MATERIAL_CONNECTION_QUALITY_3
	else if ( ping > 50 )
		image = SCOREBOARD_MATERIAL_CONNECTION_QUALITY_4
	else
		image = SCOREBOARD_MATERIAL_CONNECTION_QUALITY_5

	return image
}

asset function GetPlayerGenIcon( entity player )
{
	switch ( player.GetGen() )
	{
		case 1:
			return SCOREBOARD_MATERIAL_GEN1
		case 2:
			return SCOREBOARD_MATERIAL_GEN2
		case 3:
			return SCOREBOARD_MATERIAL_GEN3
		case 4:
			return SCOREBOARD_MATERIAL_GEN4
		case 5:
			return SCOREBOARD_MATERIAL_GEN5
		case 6:
			return SCOREBOARD_MATERIAL_GEN6
		case 7:
			return SCOREBOARD_MATERIAL_GEN7
		case 8:
			return SCOREBOARD_MATERIAL_GEN8
		case 9:
			return SCOREBOARD_MATERIAL_GEN9
		case 10:
			return SCOREBOARD_MATERIAL_GEN10
		default:
			Assert( 0, "GetGen( player ) did not return a value between 0 and 9" )
	}
	unreachable
}

int function GetNumTeamPlayers()
{
	if ( UseSingleTeamScoreboard() )
		return GetCurrentPlaylistVarInt( "max_players", MAX_TEAM_SLOTS )
	return GetCurrentPlaylistVarInt( "max_players", MAX_TEAM_SLOTS ) / 2
}

void function ScoreboardInputMP( int key )
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

		case SCOREBOARD_FOCUS:
			ScoreboardFocus( player )
			break

		case SCOREBOARD_LOSE_FOCUS:
			ScoreboardLoseFocus( player )
			break
	}
}

var function ClScoreboardMp_GetGameTypeDescElem()
{
	return file.header.gametypeDesc
}

bool function UseSingleTeamScoreboard()
{
	return ( IsFFAGame() || IsSingleTeamMode() )
}

void function ScoreboardSelectNextPlayer( entity player )
{
	EmitSoundOnEntity( player, "menu_click" )
	file.selectedPlayer = file.nextPlayer
	SetScoreboardPlayer( file.selectedPlayer )
}

void function ScoreboardSelectPrevPlayer( entity player )
{
	EmitSoundOnEntity( player, "menu_click" )
	file.selectedPlayer = file.prevPlayer
	SetScoreboardPlayer( file.selectedPlayer )
}

var function GetScoreBoardFooterRui()
{
	return Hud_GetRui( file.footer )
}

void function SetScoreboardUpdateCallback( void functionref( entity, var ) func )
{
	file.scoreboardUpdateCallback = func
}