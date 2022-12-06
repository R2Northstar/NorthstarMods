untyped

global function Score_Init

global function AddPlayerScore
global function ScoreEvent_PlayerKilled
global function ScoreEvent_TitanDoomed
global function ScoreEvent_TitanKilled
global function ScoreEvent_NPCKilled

global function ScoreEvent_SetEarnMeterValues
global function ScoreEvent_SetupEarnMeterValuesForMixedModes
global function ScoreEvent_SetupEarnMeterValuesForTitanModes

// nessie modify
global function GetMVPPlayer
global function AddTitanKilledDialogueEvent
global function ScoreEvent_ForceUsePilotEliminateEvent

struct 
{
	bool firstStrikeDone = false

	// nessie modify
	table<string, string> killedTitanDialogues

	bool forceAddEliminateScore = false
	IntFromEntityCompare mvpCompareFunc = null
} file

void function Score_Init()
{
	SvXP_Init()
	AddCallback_OnClientConnected( InitPlayerForScoreEvents )
}

// modified!!!
void function InitTitanKilledDialogues() // init vanilla ones
{
	file.killedTitanDialogues["ion"] <- "kc_pilotkillIon"
	file.killedTitanDialogues["tone"] <- "kc_pilotkillTone"
	file.killedTitanDialogues["legion"] <- "kc_pilotkillLegion"
	file.killedTitanDialogues["scorch"] <- "kc_pilotkillScorch"
	file.killedTitanDialogues["northstar"] <- "kc_pilotkillNorthstar"
	file.killedTitanDialogues["ronin"] <- "kc_pilotkillRonin"
}

void function InitPlayerForScoreEvents( entity player )
{	
	player.s.currentKillstreak <- 0
	player.s.lastKillTime <- 0.0
	player.s.currentTimedKillstreak <- 0
}

void function AddPlayerScore( entity targetPlayer, string scoreEventName, entity associatedEnt = null, string noideawhatthisis = "", int pointValueOverride = -1 )
{
	ScoreEvent event = GetScoreEvent( scoreEventName )
	
	if ( !event.enabled || !IsValid( targetPlayer ) || !targetPlayer.IsPlayer() )
		return

	var associatedHandle = 0
	if ( associatedEnt != null )
		associatedHandle = associatedEnt.GetEncodedEHandle()
		
	if ( pointValueOverride != -1 )
		event.pointValue = pointValueOverride 
	
	float scale = targetPlayer.IsTitan() ? event.coreMeterScalar : 1.0
	
	float earnValue = event.earnMeterEarnValue * scale
	float ownValue = event.earnMeterOwnValue * scale
	
	PlayerEarnMeter_AddEarnedAndOwned( targetPlayer, earnValue, ownValue ) //( targetPlayer, earnValue * scale, ownValue * scale ) // seriously? this causes a value*scale^2
	
	// PlayerEarnMeter_AddEarnedAndOwned handles this scaling by itself, we just need to do this for the visual stuff
	float pilotScaleVar = ( expect string ( GetCurrentPlaylistVarOrUseValue( "earn_meter_pilot_multiplier", "1" ) ) ).tofloat()
	float titanScaleVar = ( expect string ( GetCurrentPlaylistVarOrUseValue( "earn_meter_titan_multiplier", "1" ) ) ).tofloat()
	
	if ( targetPlayer.IsTitan() )
	{
		earnValue *= titanScaleVar
		ownValue *= titanScaleVar
	}
	else
	{
		earnValue *= pilotScaleVar
		ownValue *= pilotScaleVar
	}
	
	Remote_CallFunction_NonReplay( targetPlayer, "ServerCallback_ScoreEvent", event.eventId, event.pointValue, event.displayType, associatedHandle, ownValue, earnValue )
	
	if ( event.displayType & eEventDisplayType.CALLINGCARD ) // callingcardevents are shown to all players
	{
		foreach ( entity player in GetPlayerArray() )
		{
			if ( player == targetPlayer ) // targetplayer already gets this in the scorevent callback
				continue
				
			Remote_CallFunction_NonReplay( player, "ServerCallback_CallingCardEvent", event.eventId, associatedHandle )
		}
	}
	
	if ( ScoreEvent_HasConversation( event ) )
		PlayFactionDialogueToPlayer( event.conversation, targetPlayer )
		
	HandleXPGainForScoreEvent( targetPlayer, event )
}

void function ScoreEvent_PlayerKilled( entity victim, entity attacker, var damageInfo )
{
	// reset killstreaks and stuff		
	victim.s.currentKillstreak = 0
	victim.s.lastKillTime = 0.0
	victim.s.currentTimedKillstreak = 0
	
	victim.p.numberOfDeathsSinceLastKill++ // this is reset on kill
	victim.p.lastDeathTime = Time()
	victim.p.lastKiller = attacker
	victim.p.seekingRevenge = true
	
	// have to do this early before we reset victim's player killstreaks
	// nemesis when you kill a player that is dominating you
	if ( attacker.IsPlayer() && attacker in victim.p.playerKillStreaks && victim.p.playerKillStreaks[ attacker ] >= NEMESIS_KILL_REQUIREMENT )
		AddPlayerScore( attacker, "Nemesis", attacker )
	
	// reset killstreaks on specific players
	foreach ( entity killstreakPlayer, int numKills in victim.p.playerKillStreaks )
		delete victim.p.playerKillStreaks[ killstreakPlayer ]

	if ( victim.IsTitan() )
		ScoreEvent_TitanKilled( victim, attacker, damageInfo )

	if ( !attacker.IsPlayer() )
		return

	attacker.p.numberOfDeathsSinceLastKill = 0 // since they got a kill, remove the comeback trigger
	// pilot kill
	if( IsPilotEliminationBased() || IsTitanEliminationBased() )
	{
		if( GetPlayerArrayOfEnemies_Alive( attacker.GetTeam() ).len() == 0 ) // no enemy player left
			AddPlayerScore( attacker, "VictoryKill", attacker ) // show a callsign event
	}
	
	if( IsPilotEliminationBased() || file.forceAddEliminateScore )
		AddPlayerScore( attacker, "EliminatePilot", victim ) // elimination gamemodes have a special medal
	else
		AddPlayerScore( attacker, "KillPilot", victim )

	// mvp kill
	if( GetMVPPlayer( victim.GetTeam() ) == victim )
		AddPlayerScore( attacker, "KilledMVP", victim )
	
	// headshot
	if ( DamageInfo_GetCustomDamageType( damageInfo ) & DF_HEADSHOT )
		AddPlayerScore( attacker, "Headshot", victim )

	// special method of killing dialogues
	if( DamageInfo_GetCustomDamageType( damageInfo ) & DF_HEADSHOT )
		PlayFactionDialogueToPlayer( "kc_bullseye", attacker )
	if( DamageInfo_GetDamageSourceIdentifier( damageInfo ) == damagedef_titan_step )
		PlayFactionDialogueToPlayer( "kc_hitandrun", attacker )

	// first strike
	if ( !file.firstStrikeDone )
	{
		file.firstStrikeDone = true
		AddPlayerScore( attacker, "FirstStrike", attacker )
	}

	// revenge && quick revenge
	if( attacker.p.lastKiller == victim && attacker.p.seekingRevenge )
	{
		if( Time() <= attacker.p.lastDeathTime + QUICK_REVENGE_TIME_LIMIT )
			AddPlayerScore( attacker, "QuickRevenge", victim )
		else
			AddPlayerScore( attacker, "Revenge", victim )
		attacker.p.seekingRevenge = false
	}

	// comeback
	if ( attacker.p.numberOfDeathsSinceLastKill >= COMEBACK_DEATHS_REQUIREMENT )
	{
		AddPlayerScore( attacker, "Comeback", attacker )
		attacker.p.numberOfDeathsSinceLastKill = 0
	}
	
	// untimed killstreaks
	attacker.s.currentKillstreak++
	if ( attacker.s.currentKillstreak == 3 )
		AddPlayerScore( attacker, "KillingSpree", attacker )
	else if ( attacker.s.currentKillstreak == 5 )
		AddPlayerScore( attacker, "Rampage", attacker )
	
	// increment untimed killstreaks against specific players
	if ( !( victim in attacker.p.playerKillStreaks ) )
		attacker.p.playerKillStreaks[ victim ] <- 1
	else
		attacker.p.playerKillStreaks[ victim ]++
	
	// dominating
	if ( attacker.p.playerKillStreaks[ victim ] >= DOMINATING_KILL_REQUIREMENT )
		AddPlayerScore( attacker, "Dominating", victim )
	
	if ( Time() - attacker.s.lastKillTime > CASCADINGKILL_REQUIREMENT_TIME )
	{
		attacker.s.currentTimedKillstreak = 0 // reset first before kill
		attacker.s.lastKillTime = Time()
	}
	
	// timed killstreaks
	if ( Time() - attacker.s.lastKillTime <= CASCADINGKILL_REQUIREMENT_TIME )
	{
		attacker.s.currentTimedKillstreak++
		
		if ( attacker.s.currentTimedKillstreak == DOUBLEKILL_REQUIREMENT_KILLS )
			AddPlayerScore( attacker, "DoubleKill", attacker )
		else if ( attacker.s.currentTimedKillstreak == TRIPLEKILL_REQUIREMENT_KILLS )
			AddPlayerScore( attacker, "TripleKill", attacker )
		else if ( attacker.s.currentTimedKillstreak >= MEGAKILL_REQUIREMENT_KILLS )
			AddPlayerScore( attacker, "MegaKill", attacker )
	}
	
	attacker.s.lastKillTime = Time()
}

void function ScoreEvent_TitanDoomed( entity titan, entity attacker, var damageInfo )
{
	// will this handle npc titans with no owners well? i have literally no idea
	
	if ( titan.IsNPC() )
		AddPlayerScore( attacker, "DoomAutoTitan", titan )
	else
		AddPlayerScore( attacker, "DoomTitan", titan )
}

void function ScoreEvent_TitanKilled( entity victim, entity attacker, var damageInfo )
{
	// will this handle npc titans with no owners well? i have literally no idea
	if ( !attacker.IsPlayer() )
		return

	string scoreEvent = "KillTitan"
	if( attacker.IsTitan() )
		scoreEvent = "TitanKillTitan"
	if( victim.IsNPC() )
		scoreEvent = "KillAutoTitan"
	if( IsTitanEliminationBased() || file.forceAddEliminateScore )
	{
		if( victim.IsNPC() )
			scoreEvent = "EliminateAutoTitan"
		else
			scoreEvent = "EliminateTitan"
	}

	if( victim.GetBossPlayer() || victim.IsPlayer() ) // to confirm this is a pet titan or player titan
	{
		AddPlayerScore( attacker, scoreEvent, attacker ) // this will show the "Titan Kill" callsign event
		if( GetShouldPlayFactionDialogue() )
			KilledPlayerTitanDialogue( attacker, victim )
	}
	else
	{
		AddPlayerScore( attacker, scoreEvent ) // no callsign event and event
	}

	/* // using a new check
	if ( attacker.IsTitan() )
	{
		if( victim.GetBossPlayer() || victim.IsPlayer() ) // to confirm this is a pet titan or player titan
		{
			AddPlayerScore( attacker, "TitanKillTitan", attacker ) // this will show the "Titan Kill" callsign event
			if( GetShouldPlayFactionDialogue() )
				KilledPlayerTitanDialogue( attacker, victim )
		}
		else
		{
			AddPlayerScore( attacker, "TitanKillTitan" ) // no callsign event
		}
	}
	else
	{
		if( victim.GetBossPlayer() || victim.IsPlayer() )
		{
			AddPlayerScore( attacker, "KillTitan", attacker ) // this will show the "Titan Kill" callsign event
			if( GetShouldPlayFactionDialogue() )
				KilledPlayerTitanDialogue( attacker, victim )
		}
		else
		{
			AddPlayerScore( attacker, "KillTitan" )
		}
	}
	*/

	table<int, bool> alreadyAssisted
	foreach( DamageHistoryStruct attackerInfo in victim.e.recentDamageHistory )
	{
		if ( !IsValid( attackerInfo.attacker ) || !attackerInfo.attacker.IsPlayer() || attackerInfo.attacker == victim )
			continue
			
		bool exists = attackerInfo.attacker.GetEncodedEHandle() in alreadyAssisted ? true : false
		if( attackerInfo.attacker != attacker && !exists )
		{
			alreadyAssisted[attackerInfo.attacker.GetEncodedEHandle()] <- true
			AddPlayerScore( attackerInfo.attacker, "TitanAssist", victim )
			Remote_CallFunction_NonReplay( attackerInfo.attacker, "ServerCallback_SetAssistInformation", attackerInfo.damageSourceId, attacker.GetEncodedEHandle(), victim.GetEncodedEHandle(), attackerInfo.time ) 
		}
	}
}

void function ScoreEvent_NPCKilled( entity victim, entity attacker, var damageInfo )
{
	try
	{		
		// have to trycatch this because marvins will crash on kill if we dont
		AddPlayerScore( attacker, ScoreEventForNPCKilled( victim, damageInfo ), victim )
	}
	catch ( ex ) {}
}



void function ScoreEvent_SetEarnMeterValues( string eventName, float earned, float owned, float coreScale = 1.0 )
{
	ScoreEvent event = GetScoreEvent( eventName )
	event.earnMeterEarnValue = earned
	event.earnMeterOwnValue = owned
	event.coreMeterScalar = coreScale
}

void function ScoreEvent_SetupEarnMeterValuesForMixedModes() // mixed modes in this case means modes with both pilots and titans
{
	thread SetupEarnMeterValuesForMixedModes_Threaded() // needs thread or "PilotEmilinate" won't behave up correctly
	
	/*
	// todo needs earn/overdrive values
	// player-controlled stuff
	ScoreEvent_SetEarnMeterValues( "KillPilot", 0.07, 0.15 )
	ScoreEvent_SetEarnMeterValues( "KillTitan", 0.0, 0.15 )
	ScoreEvent_SetEarnMeterValues( "TitanKillTitan", 0.0, 0.15 ) // unsure
	ScoreEvent_SetEarnMeterValues( "PilotBatteryStolen", 0.0, 0.35 ) // this actually just doesn't have overdrive in vanilla even
	ScoreEvent_SetEarnMeterValues( "Headshot", 0.0, 0.05 )
	ScoreEvent_SetEarnMeterValues( "FirstStrike", 0.0, 0.05 )
	ScoreEvent_SetEarnMeterValues( "PilotBatteryApplied", 0.0, 0.35 )
	
	// ai
	ScoreEvent_SetEarnMeterValues( "KillGrunt", 0.02, 0.02, 0.5 )
	ScoreEvent_SetEarnMeterValues( "KillSpectre", 0.02, 0.02, 0.5 )
	ScoreEvent_SetEarnMeterValues( "LeechSpectre", 0.02, 0.02 )
	ScoreEvent_SetEarnMeterValues( "KillStalker", 0.02, 0.02, 0.5 )
	ScoreEvent_SetEarnMeterValues( "KillSuperSpectre", 0.0, 0.1, 0.5 )
	*/
}

void function SetupEarnMeterValuesForMixedModes_Threaded()
{
	WaitFrame()

	// todo needs earn/overdrive values
	// player-controlled stuff
	ScoreEvent_SetEarnMeterValues( "KillPilot", 0.07, 0.15 )
	ScoreEvent_SetEarnMeterValues( "EliminatePilot", 0.07, 0.15 )
	ScoreEvent_SetEarnMeterValues( "KillTitan", 0.0, 0.15 )
	ScoreEvent_SetEarnMeterValues( "KillAutoTitan", 0.0, 0.15 )
	ScoreEvent_SetEarnMeterValues( "EliminateTitan", 0.0, 0.15 )
	ScoreEvent_SetEarnMeterValues( "EliminateAutoTitan", 0.0, 0.15 )
	ScoreEvent_SetEarnMeterValues( "TitanKillTitan", 0.0, 0.15 ) // unsure
	ScoreEvent_SetEarnMeterValues( "PilotBatteryStolen", 0.0, 0.35 ) // this actually just doesn't have overdrive in vanilla even
	ScoreEvent_SetEarnMeterValues( "Headshot", 0.0, 0.05 )
	ScoreEvent_SetEarnMeterValues( "FirstStrike", 0.0, 0.05 )
	ScoreEvent_SetEarnMeterValues( "PilotBatteryApplied", 0.0, 0.35 )
	
	// ai
	ScoreEvent_SetEarnMeterValues( "KillGrunt", 0.02, 0.02, 0.5 )
	ScoreEvent_SetEarnMeterValues( "KillSpectre", 0.02, 0.02, 0.5 )
	ScoreEvent_SetEarnMeterValues( "LeechSpectre", 0.02, 0.02 )
	ScoreEvent_SetEarnMeterValues( "KillStalker", 0.02, 0.02, 0.5 )
	ScoreEvent_SetEarnMeterValues( "KillSuperSpectre", 0.0, 0.1, 0.5 )
}

void function ScoreEvent_SetupEarnMeterValuesForTitanModes()
{
	// relatively sure we don't have to do anything here but leaving this function for consistency
}

void function KilledPlayerTitanDialogue( entity attacker, entity victim )
{
	if( !attacker.IsPlayer() )
		return
	entity titan
	if ( victim.IsTitan() )
		titan = victim

	if( !IsValid( titan ) )
		return
	string titanCharacterName = GetTitanCharacterName( titan )

	if( titanCharacterName in file.killedTitanDialogues ) // have this titan's dialogue
		PlayFactionDialogueToPlayer( file.killedTitanDialogues[titanCharacterName], attacker )
	else // play a default one
		PlayFactionDialogueToPlayer( "kc_pilotkilltitan", attacker )

	/* // not hardcoded anymore!
	switch( titanCharacterName )
	{
		case "ion":
			PlayFactionDialogueToPlayer( "kc_pilotkillIon", attacker )
			return
		case "tone":
			PlayFactionDialogueToPlayer( "kc_pilotkillTone", attacker )
			return
		case "legion":
			PlayFactionDialogueToPlayer( "kc_pilotkillLegion", attacker )
			return
		case "scorch":
			PlayFactionDialogueToPlayer( "kc_pilotkillScorch", attacker )
			return
		case "ronin":
			PlayFactionDialogueToPlayer( "kc_pilotkillRonin", attacker )
			return
		case "northstar":
			PlayFactionDialogueToPlayer( "kc_pilotkillNorthstar", attacker )
			return
		default:
			PlayFactionDialogueToPlayer( "kc_pilotkilltitan", attacker )
			return
	}
	*/
}

// nessy modify
entity function GetMVPPlayer( int team = 0 )
{
	if( IsFFAGame() )
		team = 0 // 0 means sorting all players( good for ffa ), if use a teamNumber it will sort a certain team
	
	array<entity> sortedPlayer
	if( file.mvpCompareFunc != null ) // a overwriting one, save for modding
	{
		sortedPlayer = GetSortedPlayers( file.mvpCompareFunc, team )
		return sortedPlayer[0] // mvp
	}

	// respawn hardcoded some functions in _utility_shared, guess I will use it!
	IntFromEntityCompare compareFunc = CompareKills // default comparing kills

	switch( GAMETYPE )
	{
		case "ps":
		case "tdm":
		case "ttdm": // ttdm in northstar still using pilotKills for check
			break // still using CompareKills
		case "lts":
			compareFunc = CompareLTS
			break
		case "cp":
			compareFunc = CompareCP
			break
		case "ctf":
			compareFunc = CompareCTF
			break
		case "speedball":
			compareFunc = CompareSpeedball
			break
		case "mfd":
			compareFunc = CompareMFD
			break
	}

	sortedPlayer = GetSortedPlayers( compareFunc, team )
	return sortedPlayer[0] // mvp
}

void function AddTitanKilledDialogueEvent( string titanName, string dialogueName )
{
	file.killedTitanDialogues[titanName] <- dialogueName
}

void function ScoreEvent_ForceUsePilotEliminateEvent( bool force )
{
	file.forceAddEliminateScore = force
}
