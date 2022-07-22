untyped
globalize_all_functions

string function GetTableString( table t, string index, string defaultVal = "" )
{
    try
    {
    return expect string(t[index])
    }
    catch (ex)
    {

    }
    return defaultVal
}

int function GetTableInt( table t, string index, int defaultVal = 0 )
{
    try
    {
        return expect int(t[index])
    }
    catch (ex)
    {

    }
    return defaultVal
}

float function GetTableFloat( table t, string index, float defaultVal = 0.0 )
{
    try
    {
    return expect float(t[index])
    }
    catch (ex)
    {

    }
    return defaultVal
}

array function GetTableArray( table t, string index, array defaultVal = [] )
{
    try
    {
    return expect array(t[index])
    }
    catch (ex)
    {

    }
    return defaultVal
}

bool function GetTableBool( table t, string index, bool defaultVal = false )
{
    try
    {
    return expect bool(t[index])
    }
    catch (ex)
    {

    }
    return defaultVal
}

table function GetTableTable( table t, string index, table defaultVal = {} )
{
    try
    {
    return expect table(t[index])
    }
    catch (ex)
    {

    }
    return defaultVal
}
