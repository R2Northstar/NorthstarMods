global function GamemodePs_Init

struct
{
	array<entity> spawnzones

	entity militiaActiveSpawnZone
	entity imcActiveSpawnZone

	array<entity> militiaPreviousSpawnZones
	array<entity> imcPreviousSpawnZones
} file

void function GamemodePs_Init()
{
	Riff_ForceTitanAvailability( eTitanAvailability.Never )

	AddCallback_OnPlayerKilled( GiveScoreForPlayerKill )
	ScoreEvent_SetupEarnMeterValuesForMixedModes()
	SetupGenericFFAChallenge()
	SetPlayThreeMinuteMusic( true )

	file.militiaPreviousSpawnZones = [ null, null, null ]
	file.imcPreviousSpawnZones = [ null, null, null ]
}

void function GiveScoreForPlayerKill( entity victim, entity attacker, var damageInfo )
{
	if ( victim != attacker && victim.IsPlayer() && attacker.IsPlayer() || GetGameState() != eGameState.Playing )
		AddTeamScore( attacker.GetTeam(), 1 )
}
