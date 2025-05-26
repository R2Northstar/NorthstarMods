untyped

global function GamemodeCP_Init
global function RateSpawnpoints_CP

// docker run --rm -it --network=host -v ./Northstar.CustomServers/mod/scripts:/usr/lib/northstar/R2Northstar/mods/Northstar.CustomServers/mod/scripts:ro -v /run/media/pg/Titanfall2:/mnt/titanfall:ro -e 'NS_SERVER_NAME=amped hardpoint test' -e 'NS_SERVER_PASSWORD=pg' -e 'NS_INSECURE=1' -e 'NS_EXTRA_ARGUMENTS=+spewlog_enable 0 +setplaylist cp +launchplaylist cp +ns_should_return_to_lobby 0' ghcr.io/pg9182/northstar-dedicated:1-tf2.0.11.0

// needed for sh_gamemode_cp_dialogue
global array<entity> HARDPOINTS

struct {
    bool ampingEnabled = true
} state

void function GamemodeCP_Init() {
	state.ampingEnabled = GetCurrentPlaylistVarInt("cp_amped_capture_points", 1) == 1

	RegisterSignal("HardpointCaptureStart")
	ScoreEvent_SetupEarnMeterValuesForMixedModes()

	AddCallback_OnPlayerKilled(OnPlayerKilled_UpdateMedals)
	AddCallback_OnPlayerKilled(OnPlayerKilled_UpdateHardpoints)

	ScoreEvent_SetEarnMeterValues("KillPilot", 0.1, 0.12)
	ScoreEvent_SetEarnMeterValues("KillTitan", 0, 0)
	ScoreEvent_SetEarnMeterValues("TitanKillTitan", 0, 0)
	ScoreEvent_SetEarnMeterValues("PilotBatteryStolen", 0, 35)
	ScoreEvent_SetEarnMeterValues("Headshot", 0, 0.02)
	ScoreEvent_SetEarnMeterValues("FirstStrike", 0, 0.05)

	ScoreEvent_SetEarnMeterValues("ControlPointCapture", 0.1, 0.1)
	ScoreEvent_SetEarnMeterValues("ControlPointHold", 0.02, 0.02)
	ScoreEvent_SetEarnMeterValues("ControlPointAmped", 0.2, 0.15)
	ScoreEvent_SetEarnMeterValues("ControlPointAmpedHold", 0.05, 0.05)

	ScoreEvent_SetEarnMeterValues("HardpointAssault", 0.10, 0.15)
	ScoreEvent_SetEarnMeterValues("HardpointDefense", 0.5, 0.10)
	ScoreEvent_SetEarnMeterValues("HardpointPerimeterDefense", 0.1, 0.12)
	ScoreEvent_SetEarnMeterValues("HardpointSiege", 0.1, 0.15)
	ScoreEvent_SetEarnMeterValues("HardpointSnipe", 0.1, 0.15)
}

void function RateSpawnpoints_CP(int checkClass, array<entity> spawnpoints, int team, entity player) {

}

void function OnPlayerKilled_UpdateMedals(entity victim, entity attacker, var damageInfo) {
    if (!attacker.IsPlayer())
        return
}

void function OnPlayerKilled_UpdateHardpoints(entity victim, entity attacker, var damageInfo) {

}
