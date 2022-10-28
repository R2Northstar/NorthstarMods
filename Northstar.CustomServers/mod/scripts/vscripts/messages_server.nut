untyped
globalize_all_functions

void function MessageLoop_Init()
{
    thread MessageLoop_Thread()
}

void function MessageLoop_Thread()
{
    while ( true )
    {
        WaitFrame()
        NSProcessMessages()
    }
}