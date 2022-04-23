global function FullyHidePlayers
global function FullyShowPlayers

void function FullyHidePlayers()
{
    foreach( entity player in GetPlayerArray() )
    {
        foreach( entity weapon in GetPrimaryWeapons( player ) )
        {
            weapon.Hide()
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
            weapon.Show()
        }
        player.Show()
    }
}