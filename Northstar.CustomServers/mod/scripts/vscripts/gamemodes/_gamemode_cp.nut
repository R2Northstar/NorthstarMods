untyped

global function GamemodeCP_Init
global function RateSpawnpoints_CP

// docker run --rm -it --network=host -v ./Northstar.CustomServers/mod/scripts:/usr/lib/northstar/R2Northstar/mods/Northstar.CustomServers/mod/scripts:ro -v /run/media/pg/Titanfall2:/mnt/titanfall:ro -e 'NS_SERVER_NAME=amped hardpoint test' -e 'NS_SERVER_PASSWORD=pg' -e 'NS_INSECURE=1' -e 'NS_EXTRA_ARGUMENTS=+spewlog_enable 0 +setplaylist cp +launchplaylist cp +ns_should_return_to_lobby 0' ghcr.io/pg9182/northstar-dedicated:1-tf2.0.11.0

// 1: ./NorthstarLauncher.exe -multiple -windowed -allowdupeaccounts -width 960 -height 540 -port 37016 +ns_report_server_to_masterserver 0 +ns_auth_allow_insecure 1 +ns_erase_auth_info 0
// 2: ./NorthstarLauncher.exe -multiple -windowed -allowdupeaccounts -width 960 -height 540 -port 37017 +ns_report_server_to_masterserver 0 +ns_auth_allow_insecure 1 +ns_erase_auth_info 0
// 2: private match
// 1: connect 10.33.0.189:37017
// 2: reload

// needed for sh_gamemode_cp_dialogue
global array<entity> HARDPOINTS

struct HardpointState {
	string group
	entity ent // CHardPoint
	entity trigger
	entity prop
}

struct State {
    bool ampingEnabled
	array<HardpointState> hardpoints
}

State state

void function GamemodeCP_Init() {
	state.ampingEnabled = GetCurrentPlaylistVarInt("cp_amped_capture_points", 1) == 1

	RegisterSignal("HardpointCaptureStart")
	ScoreEvent_SetupEarnMeterValuesForMixedModes()

	AddCallback_EntitiesDidLoad(EntitiesDidLoad_SpawnHardpoints)
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

void function EntitiesDidLoad_SpawnHardpoints() {
	foreach (entity hp in GetEntArrayByClass_Expensive("info_hardpoint")) {
		if (GameModeRemove(hp))
			continue

		HardpointState hpState
		hpState.group = GetHardpointGroup(hp)
		hpState.ent = hp
		hpState.prop = CreatePropDynamic(hp.GetModelName(), hp.GetOrigin(), hp.GetAngles(), 6)
		hpState.trigger = GetEnt(expect string(hp.kv.triggerTarget))
		state.hardpoints.append(hpState)

		switch (hpState.group) {
		case "A":
			hp.SetHardpointID(0)
			break
		case "B":
			hp.SetHardpointID(1)
			break
		case "C":
			hp.SetHardpointID(2)
			break
		default:
			throw "unknown hardpoint group name"
		}
		SetTeam(hpState.ent, TEAM_UNASSIGNED)
		SetGlobalNetEnt("objective" + hpState.group + "Ent", hpState.ent)

		hpState.trigger.SetEnterCallback(OnHardpointEnter)
		hpState.trigger.SetLeaveCallback(OnHardpointLeave)

		hpState.ent.Minimap_SetCustomState(hpState.ent.GetHardpointID() + 1)
		hpState.ent.Minimap_AlwaysShow(TEAM_MILITIA, null)
		hpState.ent.Minimap_AlwaysShow(TEAM_IMC, null)
		hpState.ent.Minimap_SetAlignUpright(true)

		HARDPOINTS.append(hpState.ent) // for vo script
		hpState.ent.s.trigger <- hpState.trigger // also for vo script

		thread PlayAnim(hpState.prop, "mh_inactive_idle")
	}
}

void function OnPlayerKilled_UpdateMedals(entity victim, entity attacker, var damageInfo) {
    if (!attacker.IsPlayer())
        return
}

void function OnPlayerKilled_UpdateHardpoints(entity victim, entity attacker, var damageInfo) {

}

void function OnHardpointEnter(entity trigger, entity player) {
	printt("hp enter")
}

void function OnHardpointLeave(entity trigger, entity player) {
	printt("hp leave")
}

string function GetHardpointGroup(entity hardpoint) {
	if (GetMapName() == "mp_homestead" && !hardpoint.HasKey("hardpointGroup"))
		return "B" // homestead is missing group for B

	return string(hardpoint.kv.hardpointGroup)
}
