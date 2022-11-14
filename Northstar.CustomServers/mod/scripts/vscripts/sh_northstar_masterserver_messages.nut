global function InitMasterserverMessage
global function RegisterMasterserverMessageCallback
void function RegisterMasterserverMessageCallback()
{
    #if SERVER
        AddCallback_GameStateEnter( eGameState.Playing, InitMasterserverMessage )
    #endif
}


void function InitMasterserverMessage(){
    thread ThreadedMasterserverMessage()
}

void function ThreadedMasterserverMessage()
{
    while(true)
    {
        DoMasterserverMessagePoll()
        WaitFrame()
    }
}

void function DoMasterserverMessagePoll()
{
    if(GetGameState() != eGameState.Playing)
    {
        return
    } // only start listening when game is running 

    string jsonstring = NSGetLastMasterserverMessage()
    if (jsonstring == "none")
    {
        return
    }
    table msg = DecodeJSON(jsonstring)
    string msgtype
    if("type" in msg)
    {
        msgtype = expect string(msg["type"])
    }

    switch(msgtype)
    {   
        case "large":
            if("title" in msg && "content" in msg && "duration" in msg && "picture" in msg)
            {
                string title = expect string(msg["title"])
                string content = expect string(msg["content"])
                float duration = expect float(msg["duration"])
                string picture = expect string(msg["picture"])
                foreach(entity player in GetPlayerArray())
                {
                    NSSendLargeMessageToPlayer( player, title, content , duration, picture )
                }
            }
            break
        case "info":
            
            if("title" in msg && "content" in msg)
            {
                string title = expect string(msg["title"])
                string content = expect string(msg["content"])
                foreach(entity player in GetPlayerArray())
                {
                    NSSendInfoMessageToPlayer( player,  content )
                }
            }
            break
        case "popup":
            if("title" in msg && "content" in msg)
            {
                string title = expect string(msg["title"])
                string content = expect string(msg["content"])
                foreach(entity player in GetPlayerArray())
                {
                    NSSendPopUpMessageToPlayer( player,  content )
                }
            }
            break
        case "announcement":
            if("title" in msg && "content" in msg && "color" in msg && "priority" in msg&& "style" in msg)
            {
                string title = expect string(msg["title"])
                string content = expect string(msg["content"])
                array colorarr = expect array(msg["color"])
                vector color = <expect float(colorarr[0]),expect float(colorarr[1]),expect float(colorarr[2])>
                int priority = expect int(msg["priority"]) 
                int style = expect int(msg["style"])
                if(style >8)
                    return

                foreach(entity player in GetPlayerArray())
                {
                    
                    NSSendAnnouncementMessageToPlayer( player, title,  content, color, priority, style )
                }
            }
            break
        case "status":
            if("title" in msg && "content" in msg && "duration" in msg)
            {
                string title = expect string(msg["title"])
                string content = expect string(msg["content"])
                float duration = expect float(msg["duration"])
                foreach(entity player in GetPlayerArray())
                {
                    NSCreateStatusMessageOnPlayer( player, title,  content,"placeholder_status_id" )
                    
                }
                wait duration
                foreach(entity player in GetPlayerArray())
                {
                    NSDeleteStatusMessageOnPlayer( player,"placeholder_status_id" )
                }
            }
        
    }
    
    return
}
