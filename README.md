# NorthstarMods

[Squirrel](http://www.squirrel-lang.org/squirreldoc/reference/index.html) scripts used to recreate server-side gamelogic and add [custom content](https://r2northstar.gitbook.io/r2northstar-wiki/using-northstar/gamemodes) to the game. 

## Contents:

Issues in this repository should be created if they are related to these domains:
- `Northstar.Client` - Localisation files, UI and client-side scripts.
- `Northstar.Coop` - Soon™.
- `Northstar.Custom` - Northstar custom content.
- `Northstar.CustomServer` - Server config files and scripts necessary for multiplayer.

## Notable differences from main gamemode_fd branch:

- Droz & Davis are way more talkative as they used to be in vanilla
- Several maps had their navmeshes rebuilt to mitigate enemies from idling on place
- Grunt Dropship spawn event
- Titanfall Block event (cut content from Respawn)
- Enemy Titans moves slower as they used to do in vanilla (Except Ronins and Mortars)
- Nuke Titans moves even slower, are unlikely to melee and always spawn with shields regardless difficulty set as they also do in vanilla
- Harvester have proper damage filters, meaning certain enemies will hit it harder, again similar to vanilla behavior
- Aside from Forwardbase Kodai, Homestead and Rise, all other maps works with custom wave data, Colony, Glitch and Boomtown included
- Configurable wave break time for players use the shop through the `fd_wave_buy_time` playlistvar
- During wave break time, players do not respawn on dropship, neither new connecting players
- Reapers will deploy ticks, despite them still not being able to parkour through the map, they still pose a high threat
- Fixed Autotitans not having overlay on them to see them through walls
- Fixed Offline turrets not having their yellow overlay
- Fixed the problem with players not getting instant full Titan Meter upon wave restart
