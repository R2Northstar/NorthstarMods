untyped

global function FullyHidePlayers
global function FullyShowPlayers

void function FullyHidePlayers()
{
    foreach( entity player in GetPlayerArray() )
    {
        foreach( entity weapon in GetPrimaryWeapons( player ) )
        {
            weapon.DisableDraw()
        }
        player.Hide()
    }
}

void function FullyShowPlayers()
{
    foreach( entity player in GetPlayerArray() )
    {
        foreach( entity weapon in GetPrimaryWeapons( player ) )
        {
            weapon.EnableDraw()
        }
        player.Show()
    }
}