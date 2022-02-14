global function ShSpWildsCommonInit

// for wallrun calibration
global enum eWallrunStatusFlag
{
	NOT_ACTIVE,		// 0
	IN_PROGRESS,	// 1
	ABORTED,		// 2
	SUCCESS,		// 3
	FAIL_REUSE,		// 4

	TOTAL_COUNT
}

void function ShSpWildsCommonInit()
{
	PrecacheWeapon( "mp_weapon_wingman" )
	PrecacheWeapon( "mp_ability_cloak" )
	#if SERVER && DEV
	MarkNPCForAutoPrecache( "npc_drone_worker_fast" )
	#endif
	SP_CRASHSITE_AutoPrecache()

	RegisterOnscreenHint( "doublejump_hint", "#TRAINING_HINT_DOUBLEJUMP" )
	RegisterOnscreenHint( "vortex_hint", "#TITAN_TRAINING_HINT_VORTEX", "#TITAN_TRAINING_HINT_VORTEX_KBM" )
	RegisterOnscreenHint( "missile_system_hint", "#TITAN_TRAINING_HINT_MISSILE_SYSTEM", "#TITAN_TRAINING_HINT_MISSILE_SYSTEM_KBM" )
	RegisterOnscreenHint( "crouch_hint", "#HINT_CROUCH" )
	RegisterOnscreenHint( "grenade_hint", "#TRAINING_HINT_GRENADE" )
	RegisterOnscreenHint( "melee_hint", "#TRAINING_HINT_MELEE" )
	RegisterOnscreenHint( "cloak_hint", "#TRAINING_HINT_CLOAK" )
	RegisterOnscreenHint( "objective_hint", "#TRAINING_HINT_OBJECTIVE" )
	RegisterOnscreenHint( "leech_hint", "#TRAINING_HINT_LEECH" )
	RegisterOnscreenHint( "wallrun_reminder", "#TRAINING_WALLRUN_REMINDER" )
	RegisterOnscreenHint( "logbook_updated", "#HINT_LOGBOOK_UPDATED" )

//	########  ####    ###    ##        #######   ######   ##     ## ########
//	##     ##  ##    ## ##   ##       ##     ## ##    ##  ##     ## ##
//	##     ##  ##   ##   ##  ##       ##     ## ##        ##     ## ##
//	##     ##  ##  ##     ## ##       ##     ## ##   #### ##     ## ######
//	##     ##  ##  ######### ##       ##     ## ##    ##  ##     ## ##
//	##     ##  ##  ##     ## ##       ##     ## ##    ##  ##     ## ##
//	########  #### ##     ## ########  #######   ######    #######  ########
//
//  ##    ## ####  ######   ##     ## ######## ######## #### ##     ## ########
//  ###   ##  ##  ##    ##  ##     ##    ##       ##     ##  ###   ### ##
//  ####  ##  ##  ##        ##     ##    ##       ##     ##  #### #### ##
//  ## ## ##  ##  ##   #### #########    ##       ##     ##  ## ### ## ######
//  ##  ####  ##  ##    ##  ##     ##    ##       ##     ##  ##     ## ##
//  ##   ###  ##  ##    ##  ##     ##    ##       ##     ##  ##     ## ##
//  ##    ## ####  ######   ##     ##    ##       ##    #### ##     ## ########

	//	Are we near the drop zone?
	//	We are way off target.
	//	We are the target.
	RegisterDialogue( "diag_sp_intro_WD104_01_01_mcor_grunt1", "diag_sp_intro_WD104_01_01_mcor_grunt1", PRIORITY_NO_QUEUE )
	RegisterDialogue( "diag_sp_intro_WD104_02_01_mcor_grunt2", "diag_sp_intro_WD104_02_01_mcor_grunt2", PRIORITY_NO_QUEUE )
	RegisterDialogue( "diag_sp_intro_WD104_03_01_mcor_grunt3", "diag_sp_intro_WD104_03_01_mcor_grunt3", PRIORITY_NO_QUEUE )

	//	I can't find a landmark.
	//	I can't see who's shooting at us.
	//	I can't see anything.
	RegisterDialogue( "diag_sp_intro_WD104_04_01_mcor_grunt4", "diag_sp_intro_WD104_04_01_mcor_grunt4", PRIORITY_NO_QUEUE )
	RegisterDialogue( "diag_sp_intro_WD104_05_01_mcor_grunt5", "diag_sp_intro_WD104_05_01_mcor_grunt5", PRIORITY_NO_QUEUE )
	RegisterDialogue( "diag_sp_intro_WD104_06_01_mcor_grunt1", "diag_sp_intro_WD104_06_01_mcor_grunt1", PRIORITY_NO_QUEUE )

	//	Spectres.
	//	Watch out. Spectres.
	//	Where the hell's our Titan support?!
	RegisterDialogue( "diag_sp_intro_WD104_07_01_mcor_grunt2", "diag_sp_intro_WD104_07_01_mcor_grunt2", PRIORITY_NO_QUEUE )
	RegisterDialogue( "diag_sp_intro_WD104_08_01_mcor_grunt3", "diag_sp_intro_WD104_08_01_mcor_grunt3", PRIORITY_NO_QUEUE )
	RegisterDialogue( "diag_sp_intro_WD103_03_01_mcor_grunt3", "diag_sp_intro_WD103_03_01_mcor_grunt3", PRIORITY_NO_QUEUE )

	//	Get on the radio.
	//	I'm trying.
	//	(into radio) Home Plate, this is Badger One-One, Echo Company, 41st Militia Rifle Battalion,
	//	we are from the carrier James MacAllan! We've been shot down and we are trapped on the surface on Typhon! Do you read, over!
	RegisterDialogue( "diag_sp_intro_WD104_11_01_mcor_grunt2", "diag_sp_intro_WD104_11_01_mcor_grunt2", PRIORITY_NO_QUEUE )
	RegisterDialogue( "diag_sp_intro_WD104_12_01_mcor_grunt3", "diag_sp_intro_WD104_12_01_mcor_grunt3", PRIORITY_NO_QUEUE )
	RegisterDialogue( "diag_sp_intro_WD101_02_01_mcor_grunt2", "diag_sp_intro_WD101_02_01_mcor_grunt2", PRIORITY_NO_QUEUE )

	//	Partlow's hit - Dixon, give me cover.
	//	I can't give myself cover. (ALT - I can't. I'm already covering half the platoon.)
	RegisterDialogue( "diag_sp_intro_WD104_17_01_mcor_grunt4", "diag_sp_intro_WD104_17_01_mcor_grunt4", PRIORITY_NO_QUEUE )
	RegisterDialogue( "diag_sp_intro_WD104_18_01_mcor_grunt5", "diag_sp_intro_WD104_18_01_mcor_grunt5", PRIORITY_NO_QUEUE )

	//	No one's responding. We're on our own down here.
	//	Who's left? Who's in charge?
	//	We need Titans.
	//	Just keep firing.
	RegisterDialogue( "diag_sp_intro_WD104_19_01_mcor_grunt1", "diag_sp_intro_WD104_19_01_mcor_grunt1", PRIORITY_NO_QUEUE )
	RegisterDialogue( "diag_sp_intro_WD104_20_01_mcor_grunt2", "diag_sp_intro_WD104_20_01_mcor_grunt2", PRIORITY_NO_QUEUE )
	RegisterDialogue( "diag_sp_intro_WD104_21_01_mcor_grunt3", "diag_sp_intro_WD104_21_01_mcor_grunt3", PRIORITY_NO_QUEUE )
	RegisterDialogue( "diag_sp_intro_WD104_22_01_mcor_grunt4", "diag_sp_intro_WD104_22_01_mcor_grunt4", PRIORITY_NO_QUEUE )

	//	The Spectres keep coming. Where are they coming from?
	//	They're trying to corner us.
	//	We can't let them pin us down. We need to move.
	//	We can't stay here. Move. Move.
	//	We'll have to shoot our way out of this.
	//	Keep moving forward.
	RegisterDialogue( "diag_sp_intro_WD104_23_01_mcor_grunt5", "diag_sp_intro_WD104_23_01_mcor_grunt5", PRIORITY_NO_QUEUE )
	RegisterDialogue( "diag_sp_intro_WD104_24_01_mcor_grunt1", "diag_sp_intro_WD104_24_01_mcor_grunt1", PRIORITY_NO_QUEUE )
	RegisterDialogue( "diag_sp_intro_WD104_25_01_mcor_grunt2", "diag_sp_intro_WD104_25_01_mcor_grunt2", PRIORITY_NO_QUEUE )
	RegisterDialogue( "diag_sp_intro_WD104_26_01_mcor_grunt3", "diag_sp_intro_WD104_26_01_mcor_grunt3", PRIORITY_NO_QUEUE )
	RegisterDialogue( "diag_sp_intro_WD104_27_01_mcor_grunt4", "diag_sp_intro_WD104_27_01_mcor_grunt4", PRIORITY_NO_QUEUE )
	RegisterDialogue( "diag_sp_intro_WD104_28_01_mcor_grunt5", "diag_sp_intro_WD104_28_01_mcor_grunt5", PRIORITY_NO_QUEUE )

	//	INDIVIDUAL LINES
	//	Spectres everywhere! We're in danger of being overrun! Return fire return fire!
	//	None of this was in our briefing.
	//	Grab a gun. Shoot. (ALT - Grab a gun and shoot.)
	//	Where's SRS?
	//	Where's Commander Briggs?
	//	Watch ouuut! Spectrrrres!
	//	Back up! Back up!
	//	Fire at the Spectres.
	//	Calero's down.
	RegisterDialogue( "diag_sp_intro_WD103_06_01_mcor_grunt3", "diag_sp_intro_WD103_06_01_mcor_grunt3", PRIORITY_NO_QUEUE )
	RegisterDialogue( "diag_sp_intro_WD104_09_01_mcor_grunt5", "diag_sp_intro_WD104_09_01_mcor_grunt5", PRIORITY_NO_QUEUE )
	RegisterDialogue( "diag_sp_intro_WD104_10_01_mcor_grunt1", "diag_sp_intro_WD104_10_01_mcor_grunt1", PRIORITY_NO_QUEUE )
	RegisterDialogue( "diag_sp_intro_WD104_13_01_mcor_grunt5", "diag_sp_intro_WD104_13_01_mcor_grunt5", PRIORITY_NO_QUEUE )
	RegisterDialogue( "diag_sp_intro_WD104_14_01_mcor_grunt1", "diag_sp_intro_WD104_14_01_mcor_grunt1", PRIORITY_NO_QUEUE )
	RegisterDialogue( "diag_sp_intro_WD103_01_01_mcor_grunt1", "diag_sp_intro_WD103_01_01_mcor_grunt1", PRIORITY_NO_QUEUE )
	RegisterDialogue( "diag_sp_intro_WD103_02_01_mcor_grunt2", "diag_sp_intro_WD103_02_01_mcor_grunt2", PRIORITY_NO_QUEUE )
	RegisterDialogue( "diag_sp_intro_WD104_15_01_mcor_grunt2", "diag_sp_intro_WD104_15_01_mcor_grunt2", PRIORITY_NO_QUEUE )
	RegisterDialogue( "diag_sp_intro_WD104_16_01_mcor_grunt3", "diag_sp_intro_WD104_16_01_mcor_grunt3", PRIORITY_NO_QUEUE )

	//	Move it! Move it! We're inside the debris impact field!!! Go! <Go! (impact death effort sound) >
	//	INCOMING DEBRIIIIS!! MOVE MOOO<VE>!
	RegisterDialogue( "diag_sp_intro_WD103_04_01_mcor_grunt1", "diag_sp_intro_WD103_04_01_mcor_grunt1", PRIORITY_NO_QUEUE )
	RegisterDialogue( "diag_sp_intro_WD103_05_01_mcor_grunt2", "diag_sp_intro_WD103_05_01_mcor_grunt2", PRIORITY_NO_QUEUE )

	//	Do we have any Pilots in the area?
	//	This is Captain Lastimosa - I got a fix on your location. On my way.
	RegisterDialogue( "diag_sp_intro_WD104_29_01_mcor_grunt6", "diag_sp_intro_WD104_29_01_mcor_grunt6", PRIORITY_NO_QUEUE )
	RegisterDialogue( "diag_sp_intro_WD104_30_01_mcor_og", "diag_sp_intro_WD104_30_01_mcor_og", PRIORITY_NO_QUEUE )

	//	Hostile Titan, hostile Titan --- Ruuun!
	RegisterDialogue( "diag_sp_intro_WD103_07_01_mcor_grunt1", "diag_sp_intro_WD103_07_01_mcor_grunt1", PRIORITY_NO_QUEUE )

	//	That's a mercenary Titan! Apex Predators!  What the hell are they doing here?
	RegisterDialogue( "diag_sp_intro_WD103_08_01_mcor_grunt1", "diag_sp_intro_WD103_08_01_mcor_grunt1", PRIORITY_NO_QUEUE )


//  ########  ########   #######  ##    ## ########    ########  ########   #######     ###    ########   ######     ###     ######  ########
//  ##     ## ##     ## ##     ## ###   ## ##          ##     ## ##     ## ##     ##   ## ##   ##     ## ##    ##   ## ##   ##    ##    ##
//  ##     ## ##     ## ##     ## ####  ## ##          ##     ## ##     ## ##     ##  ##   ##  ##     ## ##        ##   ##  ##          ##
//  ##     ## ########  ##     ## ## ## ## ######      ########  ########  ##     ## ##     ## ##     ## ##       ##     ##  ######     ##
//  ##     ## ##   ##   ##     ## ##  #### ##          ##     ## ##   ##   ##     ## ######### ##     ## ##       #########       ##    ##
//  ##     ## ##    ##  ##     ## ##   ### ##          ##     ## ##    ##  ##     ## ##     ## ##     ## ##    ## ##     ## ##    ##    ##
//  ########  ##     ##  #######  ##    ## ########    ########  ##     ##  #######  ##     ## ########   ######  ##     ##  ######     ##

	// Militia intruders, this is General Marder of the IMC. You are in violation of Sovereign law.
	// I am offering you a brief amnesty. Surrender yourself to an IMC officer or force.
	// If you refuse, you will be eliminated.
	RegisterDialogue( "diag_sp_callOut_WD752_01_01_imc_genMarder", "diag_sp_callOut_WD752_01_01_imc_genMarder", PRIORITY_NO_QUEUE )

	// Authorized agents of the IMC are scouring every sector of Typhon.
	RegisterDialogue( "diag_sp_callOut_WD752_02_01_imc_genMarder", "diag_sp_callOut_WD752_02_01_imc_genMarder", PRIORITY_NO_QUEUE )

	// Welcome to the planet Typhon. I should remind you that outside the IMC settled sectors,
	// your probability of survival drops dramatically. The choice is yours.
	// Take your chances with the wildlife or turn yourself in.
	RegisterDialogue( "diag_sp_callOut_WD752_03_01_imc_genMarder", "diag_sp_callOut_WD752_03_01_imc_genMarder", PRIORITY_NO_QUEUE )

	// To any Militia forces in the region - we will find you. You are advised to discard any weapons and surrender immediately.
	// Do not attempt to resist. Lethal force is authorized against any armed Militia personnel.
	RegisterDialogue( "diag_sp_callOut_WD752_04_01_imc_genMarder", "diag_sp_callOut_WD752_04_01_imc_genMarder", PRIORITY_NO_QUEUE )

	// To all Militia personnel: The IMC will grant safe passage back to the Angel City Penitentiary
	// to all Militia who surrender. You would be wise to turn yourselves in to any IMC search teams immediately.
	RegisterDialogue( "diag_sp_callOut_WD752_05_01_imc_genMarder", "diag_sp_callOut_WD752_05_01_imc_genMarder", PRIORITY_NO_QUEUE )

	// To any Militia personnel: I must remind you that you are on the planet Typhon. This is an IMC controlled planet,
	// but there are many wild creatures outside the bounds of our installations, and we cannot control the wilds.
	// Turn yourselves in and we will ensure your personal safety as a Prisoner of War.
	RegisterDialogue( "diag_sp_callOut_WD752_06_01_imc_genMarder", "diag_sp_callOut_WD752_06_01_imc_genMarder", PRIORITY_NO_QUEUE )

	// We know there are Militia survivors our there. We will find you and we will track you down one by one.
	// I ask you to come out of hiding while you still can. We have IMC search teams everywhere.
	// If you resist capture, you will be branded an outlaw and we will have no choice but to kill you.
	RegisterDialogue( "diag_sp_callOut_WD752_07_01_imc_genMarder", "diag_sp_callOut_WD752_07_01_imc_genMarder", PRIORITY_NO_QUEUE )

	// To all Militia survivors - it would be in your best interests to turn yourselves in.
	// Surely you would agree it is better for our infantry to find you first, rather than a roaming Prowler in the woods?
	RegisterDialogue( "diag_sp_callOut_WD752_08_01_imc_genMarder", "diag_sp_callOut_WD752_08_01_imc_genMarder", PRIORITY_NO_QUEUE )

//  ########  ########
//  ##     ##    ##
//  ##     ##    ##
//  ########     ##
//  ##     ##    ##
//  ##     ##    ##
//  ########     ##

	// Power low. Insufficient power.
	RegisterDialogue( "diag_sp_pilotLink_WD143_01_01_mcor_bt", "diag_sp_pilotLink_WD143_01_01_mcor_bt", PRIORITY_NO_QUEUE )

	// Power at two-thirds. Datacore re-initialized. Ocular system - online.
	RegisterDialogue( "diag_sp_pilotLink_WD143_02_01_mcor_bt", "diag_sp_pilotLink_WD143_02_01_mcor_bt", PRIORITY_NO_QUEUE )
	// Adjusting focus.
	RegisterDialogue( "diag_sp_pilotLink_WD143_03_01_mcor_bt", "diag_sp_pilotLink_WD143_03_01_mcor_bt", PRIORITY_NO_QUEUE )
	// My systems are rebooting, but a third battery will accelerate the process. I will remain here.
	RegisterDialogue( "diag_sp_postBattery2_WD141b_01_01_mcor_bt", "diag_sp_postBattery2_WD141b_01_01_mcor_bt", PRIORITY_NO_QUEUE )
	// Until I am mobile, I will assist you through your helmet radio when possible.
	RegisterDialogue( "diag_sp_pilotLink_WD143_05_01_mcor_bt", "diag_sp_pilotLink_WD143_05_01_mcor_bt", PRIORITY_NO_QUEUE )

	// Pilot, my mapping systems have been restored.
	RegisterRadioDialogue( "diag_sp_postBattery2_WD141b_03_01_mcor_bt", "diag_sp_postBattery2_WD141b_03_01_mcor_bt", PRIORITY_NO_QUEUE, "#NPC_BT_NAME", TEAM_MILITIA )
	// The ambush of the 9th Militia Fleet has landed us far off course from our original destination.
	RegisterRadioDialogue( "diag_sp_postBattery2_WD141b_04_01_mcor_bt", "diag_sp_postBattery2_WD141b_04_01_mcor_bt", PRIORITY_NO_QUEUE, "#NPC_BT_NAME", TEAM_MILITIA )
	// We are located in hostile territory. Be careful. We cannot stay here long.
	RegisterRadioDialogue( "diag_sp_postBattery2_WD141b_05_01_mcor_bt", "diag_sp_postBattery2_WD141b_05_01_mcor_bt", PRIORITY_NO_QUEUE, "#NPC_BT_NAME", TEAM_MILITIA )

	// Pilot, your suit has an emergency cloaking ability. This can help you survive dangerous situations.
	RegisterRadioDialogue( "diag_sp_postBattery2_WD141b_06_01_mcor_bt", "diag_sp_postBattery2_WD141b_06_01_mcor_bt", PRIORITY_NO_QUEUE, "#NPC_BT_NAME", TEAM_MILITIA )

	// Pilot, our location has been compromised.
	RegisterRadioDialogue( "diag_sp_pilotLink_WD140_01_01_mcor_bt", "diag_sp_pilotLink_WD140_01_01_mcor_bt", PRIORITY_NO_QUEUE, "#NPC_BT_NAME", TEAM_MILITIA )
	// Those drones are IMC scouts.
	RegisterDialogue( "diag_sp_pilotLink_WD140_02_01_mcor_bt", "diag_sp_pilotLink_WD140_02_01_mcor_bt", PRIORITY_NO_QUEUE )
	// Enemy reinforcements will be on their way.
	RegisterDialogue( "diag_sp_pilotLink_WD140_03_01_mcor_bt", "diag_sp_pilotLink_WD140_03_01_mcor_bt", PRIORITY_NO_QUEUE )
	// We must complete the neural link immediately. Please install the final battery.
	RegisterDialogue( "diag_sp_pilotLink_WD140_04_01_mcor_bt", "diag_sp_pilotLink_WD140_04_01_mcor_bt", PRIORITY_NO_QUEUE )
	// Power at full capacity.
	RegisterDialogue( "diag_sp_pilotLink_WD143_07_01_mcor_bt", "diag_sp_pilotLink_WD143_07_01_mcor_bt", PRIORITY_NO_QUEUE )
	// Pilot, we must first establish a neural link in order to proceed.
	RegisterDialogue( "diag_sp_pilotLink_WD141_64_01_mcor_bt", "diag_sp_pilotLink_WD141_64_01_mcor_bt", PRIORITY_NO_QUEUE )
	// Please embark when ready.
	RegisterDialogue( "diag_sp_pilotLink_WD141_66_01_mcor_bt", "diag_sp_pilotLink_WD141_66_01_mcor_bt", PRIORITY_NO_QUEUE )

	// Protocol 1: Link To Pilot
	RegisterDialogue( "diag_sp_pilotLink_WD141_40_01_mcor_bt", "diag_sp_pilotLink_WD141_40_01_mcor_bt", PRIORITY_NO_QUEUE )
	// Establishing neural link.
	RegisterDialogue( "diag_sp_pilotLink_WD143_08_01_mcor_bt", "diag_sp_pilotLink_WD143_08_01_mcor_bt", PRIORITY_NO_QUEUE )
	// Pilot-Titan link complete... Rifleman Jack Cooper - you are now confirmed as Acting Pilot of BT-7274.
	RegisterDialogue( "diag_sp_pilotLink_WD141_41_01_mcor_bt", "diag_sp_pilotLink_WD141_41_01_mcor_bt", PRIORITY_NO_QUEUE )

	// Protocol 2: Uphold The Mission
	RegisterDialogue( "diag_sp_pilotLink_WD141_42_01_mcor_bt", "diag_sp_pilotLink_WD141_42_01_mcor_bt", PRIORITY_NO_QUEUE )
	// Our orders are to resume Special Operation #217 - Rendezvous with Major Anderson of the SRS.
	RegisterDialogue( "diag_sp_pilotLink_WD141_46_01_mcor_bt", "diag_sp_pilotLink_WD141_46_01_mcor_bt", PRIORITY_NO_QUEUE )
	// I am detecting incoming enemy forces.
	RegisterDialogue( "diag_sp_extra_GB101_19_01_mcor_bt", "diag_sp_extra_GB101_19_01_mcor_bt", PRIORITY_NO_QUEUE )

	// Protocol 3: Protect The Pilot
	RegisterDialogue( "diag_sp_pilotLink_WD141_44_01_mcor_bt", "diag_sp_pilotLink_WD141_44_01_mcor_bt", PRIORITY_NO_QUEUE )

	// missing line
	// Transferring controls to Pilot;
	// RegisterDialogue( "diag_gs_titanBt_embark_02", "diag_gs_titanBt_embark_02", PRIORITY_NO_QUEUE )

	// Re-initializing critical systems...
	RegisterDialogue( "diag_sp_pilotLink_WD143a_01_01_mcor_bt", "diag_sp_pilotLink_WD143a_01_01_mcor_bt", PRIORITY_NO_QUEUE )
	// Vortex shield online.
	RegisterDialogue( "diag_sp_pilotLink_WD143a_02_01_mcor_bt", "diag_sp_pilotLink_WD143a_02_01_mcor_bt", PRIORITY_NO_QUEUE )
	// The Vortex shield catches incoming rounds and missiles. Release the button to launch any captured objects back at the enemy.
	RegisterDialogue( "diag_sp_pilotLink_WD143a_03_01_mcor_bt", "diag_sp_pilotLink_WD143a_03_01_mcor_bt", PRIORITY_NO_QUEUE )
	// Pilot, the Acolyte Pod is online. This shoulder mounted rocket pod will lock onto multiple enemy targets. The longer you hold down the button, the more locks you will achieve.
	RegisterDialogue( "diag_sp_pilotLink_WD143a_04_01_mcor_bt", "diag_sp_pilotLink_WD143a_04_01_mcor_bt", PRIORITY_NO_QUEUE )
	// Neural link complete. Primary Weapon Control and Motion Link reestablished.
	RegisterDialogue( "diag_sp_pilotLink_WD143a_05_01_mcor_bt", "diag_sp_pilotLink_WD143a_05_01_mcor_bt", PRIORITY_NO_QUEUE )

	// Pilot, enemy Titanfall detected.
	RegisterDialogue( "diag_sp_pilotLink_WD143a_07_01_mcor_bt", "diag_sp_pilotLink_WD143a_07_01_mcor_bt", PRIORITY_NO_QUEUE )
	// We will have to fight our way to safety. Get ready
	RegisterDialogue( "diag_sp_pilotLink_WD143b_07_01_mcor_bt", "diag_sp_pilotLink_WD143b_07_01_mcor_bt", PRIORITY_NO_QUEUE )
	// Well done, Pilot. Our combat effectiveness rating has increased.
	RegisterDialogue( "diag_sp_postFight_WD171_02_01_mcor_bt", "diag_sp_postFight_WD171_02_01_mcor_bt", PRIORITY_NO_QUEUE )

	// Pilot, I detect more IMC salvage teams on the way.
	RegisterDialogue( "diag_sp_postFight_WD171a_01_01_mcor_bt", "diag_sp_postFight_WD171a_01_01_mcor_bt", PRIORITY_NO_QUEUE )
	// Our only chance of survival is to uphold our mission of rendezvousing with Major Anderson. Until then, you and I are on our own.
	RegisterDialogue( "diag_sp_postFight_WD171a_03_01_mcor_bt", "diag_sp_postFight_WD171a_03_01_mcor_bt", PRIORITY_NO_QUEUE )
	// Marking your HUD
	RegisterDialogue( "diag_sp_postFight_WD171a_03a_01_mcor_bt", "diag_sp_postFight_WD171a_03a_01_mcor_bt", PRIORITY_NO_QUEUE )
	// We must move quickly
	RegisterDialogue( "diag_sp_postFight_WD171a_03b_01_mcor_bt", "diag_sp_postFight_WD171a_03b_01_mcor_bt", PRIORITY_NO_QUEUE )

	// In order to survive, we must keep moving.
	RegisterDialogue( "diag_sp_extra_SE812_02_01_mcor_bt", "diag_sp_extra_SE812_02_01_mcor_bt", PRIORITY_NO_QUEUE )


	// Picking up weapons from enemy Titans gives us access to their full loadouts, should we choose to equip them.
	// RegisterDialogue( "diag_sp_pilotLink_WD143a_08_01_mcor_bt", "diag_sp_pilotLink_WD143a_08_01_mcor_bt", PRIORITY_NO_QUEUE )

//  #### ##     ##  ######      ######   ########  ##     ## ##    ## ########  ######
//   ##  ###   ### ##    ##    ##    ##  ##     ## ##     ## ###   ##    ##    ##    ##
//   ##  #### #### ##          ##        ##     ## ##     ## ####  ##    ##    ##
//   ##  ## ### ## ##          ##   #### ########  ##     ## ## ## ##    ##     ######
//   ##  ##     ## ##          ##    ##  ##   ##   ##     ## ##  ####    ##          ##
//   ##  ##     ## ##    ##    ##    ##  ##    ##  ##     ## ##   ###    ##    ##    ##
//  #### ##     ##  ######      ######   ##     ##  #######  ##    ##    ##     ######

	// There is still a Pilot in this sector!
	RegisterDialogue( "diag_sp_batteryC_WD161_10_01_imc_grunt1", "diag_sp_batteryC_WD161_10_01_imc_grunt1", PRIORITY_NO_QUEUE )
	// I thought those bloody mercs got all of them. What the hell do we pay them for?
	RegisterDialogue( "diag_sp_batteryC_WD161_11_01_imc_grunt2", "diag_sp_batteryC_WD161_11_01_imc_grunt2", PRIORITY_NO_QUEUE )

	RegisterDialogue( "diag_sp_patrolchat_WD701_01_01_mcor_grunt1", "diag_sp_patrolchat_WD701_01_01_mcor_grunt1", PRIORITY_NO_QUEUE )
	RegisterDialogue( "diag_sp_patrolchat_WD701_02_01_mcor_grunt2", "diag_sp_patrolchat_WD701_02_01_mcor_grunt2", PRIORITY_NO_QUEUE )
	RegisterDialogue( "diag_sp_patrolchat_WD701_03_01_mcor_grunt1", "diag_sp_patrolchat_WD701_03_01_mcor_grunt1", PRIORITY_NO_QUEUE )
	RegisterDialogue( "diag_sp_patrolchat_WD701_04_01_imc_grunt2", "diag_sp_patrolchat_WD701_04_01_imc_grunt2", PRIORITY_NO_QUEUE )
	RegisterDialogue( "diag_sp_patrolchat_WD701_05_01_imc_grunt1", "diag_sp_patrolchat_WD701_05_01_imc_grunt1", PRIORITY_NO_QUEUE )
	RegisterDialogue( "diag_sp_patrolchat_WD701_06_01_imc_grunt2", "diag_sp_patrolchat_WD701_06_01_imc_grunt2", PRIORITY_NO_QUEUE )
	RegisterDialogue( "diag_sp_batteryA_WD122_01_01_mcor_grunt1", "diag_sp_batteryA_WD122_01_01_mcor_grunt1", PRIORITY_NO_QUEUE )
	RegisterDialogue( "diag_sp_batteryA_WD122_01_01_mcor_grunt2", "diag_sp_batteryA_WD122_01_01_mcor_grunt2", PRIORITY_NO_QUEUE )
	RegisterDialogue( "diag_sp_batteryA_WD122_01_01_mcor_grunt3", "diag_sp_batteryA_WD122_01_01_mcor_grunt3", PRIORITY_NO_QUEUE )
	RegisterDialogue( "diag_sp_batteryA_WD122_04_01_imc_grunt1", "diag_sp_batteryA_WD122_04_01_imc_grunt1", PRIORITY_NO_QUEUE )
	RegisterDialogue( "diag_sp_batteryA_WD122_05_01_imc_grunt3", "diag_sp_batteryA_WD122_05_01_imc_grunt3", PRIORITY_NO_QUEUE )
	RegisterDialogue( "diag_sp_patrolchat_WD703_01_01_mcor_grunt5", "diag_sp_patrolchat_WD703_01_01_mcor_grunt5", PRIORITY_NO_QUEUE )
	RegisterDialogue( "diag_sp_patrolchat_WD703_02_01_mcor_grunt6", "diag_sp_patrolchat_WD703_02_01_mcor_grunt6", PRIORITY_NO_QUEUE )
	RegisterDialogue( "diag_sp_patrolchat_WD703_03_01_mcor_grunt5", "diag_sp_patrolchat_WD703_03_01_mcor_grunt5", PRIORITY_NO_QUEUE )
	RegisterDialogue( "diag_sp_patrolchat_WD702_01_01_mcor_grunt3", "diag_sp_patrolchat_WD702_01_01_mcor_grunt3", PRIORITY_NO_QUEUE )
	RegisterDialogue( "diag_sp_patrolchat_WD702_02_01_mcor_grunt4", "diag_sp_patrolchat_WD702_02_01_mcor_grunt4", PRIORITY_NO_QUEUE )
	RegisterDialogue( "diag_sp_patrolchat_WD702_03_01_mcor_grunt3", "diag_sp_patrolchat_WD702_03_01_mcor_grunt3", PRIORITY_NO_QUEUE )

		// final fight dude
	RegisterRadioDialogue( "diag_imc_pilot6_wildsEndBattle", "diag_imc_pilot6_wildsEndBattle", PRIORITY_NO_QUEUE, "#NPC_TITAN_STRYDER_ROCKET", TEAM_IMC, false )

	// titan damage lines
	RegisterRadioDialogue( "diag_imc_pilot6_hc_lostChicket5_09", "diag_imc_pilot6_hc_lostChicket5_09", PRIORITY_NO_QUEUE, "#NPC_TITAN_STRYDER_ROCKET", TEAM_IMC, false )
	RegisterRadioDialogue( "diag_imc_pilot6_hc_lostChicket3_06", "diag_imc_pilot6_hc_lostChicket3_06", PRIORITY_NO_QUEUE, "#NPC_TITAN_STRYDER_ROCKET", TEAM_IMC, false )
	RegisterRadioDialogue( "diag_imc_pilot6_hc_lostChicket1_02", "diag_imc_pilot6_hc_lostChicket1_02", PRIORITY_NO_QUEUE, "#NPC_TITAN_STRYDER_ROCKET", TEAM_IMC, false )

	// player damage lines
	RegisterRadioDialogue( "diag_imc_pilot6_hc_plyrLostChicklet_06", "diag_imc_pilot6_hc_plyrLostChicklet_06", PRIORITY_NO_QUEUE, "#NPC_TITAN_STRYDER_ROCKET", TEAM_IMC, false )
	RegisterRadioDialogue( "diag_imc_pilot6_hc_plyrLostChicklet_13", "diag_imc_pilot6_hc_plyrLostChicklet_13", PRIORITY_NO_QUEUE, "#NPC_TITAN_STRYDER_ROCKET", TEAM_IMC, false )

}