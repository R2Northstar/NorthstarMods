global function DoMasterserverMessagePoll

void function DoMasterserverMessagePoll()
{
    
    if(GetGameState() != eGameState.Playing)
    {
        return
    }

    table msg = NSGetLastMasterserverMessage()
    if (msg.msgtype == "none")
    {
        return
    }
    
    switch(msg.msgtype)
    {
        case "announce":
            foreach(entity player in GetPlayerArray())
            {
                NSSendLargeMessageToPlayer( player, "北極星CN公告", msg.message , 9, "ui/wave_announcement.rpak" )
            }
            break
        case "ban":
            foreach(entity player in GetPlayerArray())
            {
                NSSendLargeMessageToPlayer( player, "北極星CN公告", "玩家UID:"+ msg.message +"已被封禁", 9, "ui/wave_announcement.rpak" )
            }
            break
    }
    
    return
}
