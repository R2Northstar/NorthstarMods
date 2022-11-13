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

void function MessageBuffer_Print(string inp)
{
	print(inp)
}

void function MessageBuffer_PrintTable(var inp)
{
	PrintTable(inp)
}

void function MessageBuffer_PrintArray(array<var> inp)
{
	foreach (x in inp) print(x)
}

void function MessageBuffer_PrintAsset(asset inp)
{
	print(inp)
}