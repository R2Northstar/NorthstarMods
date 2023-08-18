# Experimental Frontier Defense

Branch made to expand Frontier Defense feature set by adding back cut content while respecting the vanilla defaults of the game.

## Notable differences from main gamemode_fd branch:

- Droz & Davis are way more talkative as they used to be in vanilla
- Several maps had their navmeshes rebuilt to mitigate enemies from idling on place
- Grunt Dropship spawn event
- Titanfall Block event (cut content)
- Elite Titans variants (cut content)
- Enemy Titans moves slower as they used to do in vanilla (Except Ronins, Mortars and Elites)
- Enemy Titans will not melee the Harvester anymore as in vanilla
- Nuke Titans will never melee and always spawn with shields regardless difficulty set as they also do in vanilla
- Arc Titans have an option to use the Arc Cannon instead of Leadwall, making them similar to what they were in Titanfall 1
- Harvester have proper damage filters, meaning certain enemies will hit it harder, again similar to vanilla behavior
- Forwardbase Kodai, Homestead, Rise, Angel City and Drydock have waves based off vanilla spawns, all other maps utilizes custom waves
- During wave break time, players do not respawn on dropship, neither new connecting players, they will deploy via Drop Pod instead
- Reapers will deploy ticks, despite them still not being able to parkour through the map, they still pose a high threat
- Like in vanilla, Titan selection menu now only appears on match start, and players can still select another Titan during the entirety of Wave 1, after that, Titans selection locks and Wave Restarts does not bring the Titan selection menu anymore
- Fixes Autotitans not having overlay on them to see them through walls
- Fixes Offline turrets not having their yellow overlay, neither their repair sound
- Fixes the problem with players not getting instant full Titan Meter upon wave restart as vanilla does
- Fixes Grunts not being able to use their Anti-Titan weaponry
- Failsafe code that kills stuck Grunts and Stalkers inside geometry to prevent softlocking
- Properly setup the tutorial hints to appear only once per match, and not every time they attempt to trigger
- Some Live Fire Maps are playable, and have some differences on mechanics than normal maps

## Titanfall Block and Elite Titan Events

`Titanfall Block` is a mechanic where Davis will say he can't drop a Titan anymore in the middle of a wave, from that moment until the end of the wave all players will stop earning their Titan meters, if their meter is full and ready to call, it will empty and lock on 0%. Pilots with Titans will still remain with theirs, losing it is permanent. This mechanic brings up a whole new perspective for players whereas they should play more carefully with their Titans, and those who lost theirs should be aiding the others by stealing batteries from the enemies.

`Elite Titans` are buffed up variants of normal Titans, they are piloted by Grunts with the following properties:
- Uses Prime Titan models
- Not affected by the difficulty rules, meaning they will always spawn with a huge shield amount and an even bigger health pool
- No slower movement like the normal Titans
- Better accuracy
- Can use their Cores
- They can Execute Players
- Drop a Battery on Easy and Regular Difficulties or drop an Amped Battery in Hard, Master and Insane difficulties similar to campaign Titans

## Live Fire Gameplay Changes

- Deck, Township, UMA are playable
- Pilot-only gameplay
- Only 3 Waves with huge amounts of non-stop spawning enemies, infantry mostly
- Loadouts can be changed at any time during a wave in the Loadout Crates
- Droz and Davis helps players in person by guarding the Harvester
- Players recieve the double amount of money when completing a wave
- Players can have 3 Turrets instead of 2
- Players have no grenades
- Players have limited Anti-Titan ammo, restock possible at Loadout Crate
- Grunts will always have one shield captain in their squads and will always have Anti-Titan weapons
- Stalkers will always spawn with EPG independant of the difficulty setting
- Players have a single "public" Titan to use called 'Helper Titan', pilots approaching this Titan gains ownership, staying away clears it

## New console variables

Use these variables in your `autoexec_ns_server` cfg to control them:
- `ns_fd_allow_elite_titans` Default is 0, set to 1 to allow Elite Titans to spawn in
- `ns_fd_allow_true_shield_captains` Default is 0, set to 1 to allow Shield Captains from campaign to spawn in Master or Insane difficulty
- `ns_fd_allow_titanfall_block` Default is 0, setting to 1 will allow some maps to make usage of the Titanfall Block event
- `ns_fd_show_drop_points` Default is 0, setting to 1 will show Titanfall markers for spawning enemies akin to when you call your own Titan
- `ns_fd_grunt_primary_weapon` Array of weapons that Grunts are allowed to use, they will randomly chose one of those to spawn with
- `ns_fd_spectre_primary_weapon` Array of weapons that Spectres are allowed to use, they will randomly chose one of those to spawn with
- `ns_fd_grunt_at_weapon` Default is "mp_weapon_defender", set to another anti-titan weapon to make Grunts use them on Master or Insane difficulty
- `ns_fd_grunt_grenade` Default is "mp_weapon_frag_grenade", set to another grenade type to make Grunts use them
- `ns_fd_disable_respawn_dropship` Default is 0, setting to 1 makes players always respawn directly on ground nearby the Harvester or Shop
- `ns_fd_differentiate_ticks` Default is 0, setting to 1 will make Ticks from Drop Pod spawns to use the campaign model to tell players they counts towards wave completion
- `ns_fd_rodeo_highlight` Default is 1, setting to 0 disables the new behavior of pilots highlight becoming green whenever they rodeo any Titan
- `ns_fd_min_numplayers_to_start` Default is 1, this is the required amount of players in a match in order for the game to start the waves
- `ns_fd_arc_titans_uses_arc_cannon` Default is 0, setting it to 1 makes Arc Titans uses the Arc Cannon instead of Leadwall
- `ns_fd_easymode_smartpistol` Default is 0, setting it to 1 will make players have the Smart Pistol as secondary weapon in Easy difficulty mode
- `ns_reaper_warpfall_kill` Default is 1, set to 0 if you don't want Reapers to kill Titans on their Warpfall
- `ns_ronin_fair_phase` Default is 0, setting to 1 will make Ronin not kill himself if he materializes inside an enemy Titan from Phase Shift, instead he will only apply 5000 damage to the target titan

## Trivia hints for server hosters

These are playlist overrides you can include in your server settings to control better how the match will behave:
- You can actually force Grunts to use Anti-Titan weaponry outside Master and Insane difficulties, use `fd_grunt_at_weapon_users` with the amount of grunts you want to use AT weapons, can go from 1 to 4, this is based in the squads of Drop Pods, so 4 would be all Grunts using them
- You can also do the same to shield captains by using `fd_grunt_shield_captains`, same rules applies from above setting
- With this branch of Frontier Defense, it's possible to change the time between waves with `fd_wave_buy_time`, default is 60 seconds
- It's possible to enable the campaign behavior of picking up batteries by setting `rodeo_battery_disembark_to_pickup` to 0, so running over batteries as Titan picks them up
- It's also possible to enable the Titanfall 1 behavior of hacking spectres by setting `enable_spectre_hacking` to 1