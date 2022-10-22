global function GamemodeSpeedball_Init

struct {
	entity flagBase
	entity flag
	entity flagCarrier
} file

void function GamemodeSpeedball_Init()
{
	PrecacheModel( CTF_FLAG_MODEL )
	PrecacheModel( CTF_FLAG_BASE_MODEL )

	// gamemode settings
	SetRoundBased( true )
	SetRespawnsEnabled( false )
	SetShouldUseRoundWinningKillReplay( true )
	Riff_ForceTitanAvailability( eTitanAvailability.Never )
	Riff_ForceSetEliminationMode( eEliminationMode.Pilots )
	ScoreEvent_SetupEarnMeterValuesForMixedModes()
	
	AddSpawnCallbackEditorClass( "script_ref", "info_speedball_flag", CreateFlag )
	
	AddCallback_GameStateEnter( eGameState.Prematch, CreateFlagIfNoFlagSpawnpoint )
	AddCallback_GameStateEnter( eGameState.Playing, ResetFlag )
	AddCallback_GameStateEnter( eGameState.WinnerDetermined,GamemodeSpeedball_OnWinnerDetermined)
	AddCallback_OnTouchHealthKit( "item_flag", OnFlagCollected )
	AddCallback_OnPlayerKilled( OnPlayerKilled )
	SetTimeoutWinnerDecisionFunc( TimeoutCheckFlagHolder )
	SetTimeoutWinnerDecisionReason( "#GAMEMODE_SPEEDBALL_WIN_TIME_FLAG_LAST", "#GAMEMODE_SPEEDBALL_LOSS_TIME_FLAG_LAST" )
	AddCallback_OnRoundEndCleanup( ResetFlag )

	ClassicMP_SetCustomIntro( ClassicMP_DefaultNoIntro_Setup, ClassicMP_DefaultNoIntro_GetLength() )
	ClassicMP_ForceDisableEpilogue( true )
}

void function CreateFlag( entity flagSpawn )
{ 
	entity flagBase = CreatePropDynamic( CTF_FLAG_BASE_MODEL, flagSpawn.GetOrigin(), flagSpawn.GetAngles() )
	
	entity flag = CreateEntity( "item_flag" )
	flag.SetValueForModelKey( CTF_FLAG_MODEL )
	flag.MarkAsNonMovingAttachment()
	DispatchSpawn( flag )
	flag.SetModel( CTF_FLAG_MODEL )
	flag.SetOrigin( flagBase.GetOrigin() + < 0, 0, flagBase.GetBoundingMaxs().z + 1 > )
	flag.SetVelocity( < 0, 0, 1 > )

	flag.Minimap_AlwaysShow( TEAM_IMC, null )
	flag.Minimap_AlwaysShow( TEAM_MILITIA, null )
	flag.Minimap_SetAlignUpright( true )

	file.flag = flag
	file.flagBase = flagBase
}	

bool function OnFlagCollected( entity player, entity flag )
{
	if ( !IsAlive( player ) || flag.GetParent() != null || player.IsTitan() || player.IsPhaseShifted() ) 
		return false
		
	GiveFlag( player )
	return false // so flag ent doesn't despawn
}

void function OnPlayerKilled( entity victim, entity attacker, var damageInfo )
{
	if ( file.flagCarrier == victim )
		DropFlag()
		
	if ( victim.IsPlayer() && GetGameState() == eGameState.Playing )
		if ( GetPlayerArrayOfTeam_Alive( victim.GetTeam() ).len() == 1 )
			foreach ( entity player in GetPlayerArray() )
				Remote_CallFunction_NonReplay( player, "ServerCallback_SPEEDBALL_LastPlayer", player.GetTeam() != victim.GetTeam() )
}

void function GiveFlag( entity player )
{
	file.flag.SetParent( player, "FLAG" )
	file.flagCarrier = player
	SetTeam( file.flag, player.GetTeam() )
	SetGlobalNetEnt( "flagCarrier", player )
	thread DropFlagIfPhased( player )
	
	EmitSoundOnEntityOnlyToPlayer( player, player, "UI_CTF_1P_GrabFlag" )
	foreach ( entity otherPlayer in GetPlayerArray() )
	{
		MessageToPlayer( otherPlayer, eEventNotifications.SPEEDBALL_FlagPickedUp, player )
		
		if ( otherPlayer.GetTeam() == player.GetTeam() )
			EmitSoundOnEntityToTeamExceptPlayer( file.flag, "UI_CTF_3P_TeamGrabFlag", player.GetTeam(), player )
	}
}

void function DropFlagIfPhased( entity player )
{
	player.EndSignal( "StartPhaseShift" )
	player.EndSignal( "OnDestroy" )
	
	OnThreadEnd( function() : ( player ) 
	{
		if ( file.flag.GetParent() == player )
			DropFlag()
	})
	
	while( file.flag.GetParent() == player )
		WaitFrame()
}

void function DropFlag()
{
	file.flag.ClearParent()
	file.flag.SetAngles( < 0, 0, 0 > )
	SetTeam( file.flag, TEAM_UNASSIGNED )
	SetGlobalNetEnt( "flagCarrier", file.flag )
	
	if ( IsValid( file.flagCarrier ) )
		EmitSoundOnEntityOnlyToPlayer( file.flagCarrier, file.flagCarrier, "UI_CTF_1P_FlagDrop" )
	
	foreach ( entity player in GetPlayerArray() )
		MessageToPlayer( player, eEventNotifications.SPEEDBALL_FlagDropped, file.flagCarrier )
	
	file.flagCarrier = null
}

void function CreateFlagIfNoFlagSpawnpoint()
{
	if ( IsValid( file.flag ) )
		return
	
	foreach ( entity hardpoint in GetEntArrayByClass_Expensive( "info_hardpoint" ) )
	{
		if ( GetHardpointGroup(hardpoint) == "B" )
		{
			CreateFlag( hardpoint )
			return
		}
	}
}

void function ResetFlag()
{
	file.flag.ClearParent()
	file.flag.SetAngles( < 0, 0, 0 > )
	file.flag.SetVelocity( < 0, 0, 1 > ) // hack: for some reason flag won't have gravity if i don't do this
	file.flag.SetOrigin( file.flagBase.GetOrigin() + < 0, 0, file.flagBase.GetBoundingMaxs().z * 2 > )
	SetTeam( file.flag, TEAM_UNASSIGNED )
	file.flagCarrier = null
	SetGlobalNetEnt( "flagCarrier", file.flag )
}

int function TimeoutCheckFlagHolder()
{
	if ( file.flagCarrier == null )
		return TEAM_UNASSIGNED
		
	return file.flagCarrier.GetTeam()
}

void function GamemodeSpeedball_OnWinnerDetermined()
{
	if(IsValid(file.flagCarrier))
		file.flagCarrier.AddToPlayerGameStat( PGS_ASSAULT_SCORE, 1 )
}

string function GetHardpointGroup(entity hardpoint) //Hardpoint Entity B on Homestead is missing the Hardpoint Group KeyValue
{
	if((GetMapName()=="mp_homestead")&&(!hardpoint.HasKey("hardpointGroup")))
		return "B"

	return string(hardpoint.kv.hardpointGroup)
}