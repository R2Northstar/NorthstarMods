untyped

global function FullyHidePlayers
global function FullyShowPlayers

void function FullyHidePlayers()
{
    foreach( entity player in GetPlayerArray() )
    {
        StorePilotWeapons( player )
        player.Hide()
    }
}

void function FullyShowPlayers()
{
    foreach( entity player in GetPlayerArray() )
    {
        RetrievePilotWeapons( player )
        player.Show()
    }
}