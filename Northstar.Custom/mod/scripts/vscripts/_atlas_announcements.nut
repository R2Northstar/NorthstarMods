untyped

global function GetAtlasAnnouncement_Threaded 

const string ATLAS_ANNOUNCEMENT_SUFFIX = "/client/announcement"

void function GetAtlasAnnouncement_Threaded()
{
	string url = format( "%s%s", GetConVarString( "ns_masterserver_hostname" ), ATLAS_ANNOUNCEMENT_SUFFIX )
	printt( format( "Getting announcement data from %s", url ) )

	if ( !NSHttpGet( url, {}, OnRequestSuccess, OnRequestFailure ) )
		printt( "Failed to get announcement data! (request failed to start)" )
}

void function OnRequestSuccess( HttpRequestResponse response )
{
	if ( response.statusCode != 200 )
	{
		printt( format( "Failed to get announcement data! (Code: %i)\nReceived response: %s", response.statusCode, response.body ) )
		return
	}

	string announcement
	string announcementVersion
	
	table responseBody = DecodeJSON( response.body )

	if ( "announcement" in responseBody && typeof( responseBody[ "announcement" ] ) == "string" )
	{
		announcement = expect string( responseBody[ "announcement" ] )
	}
	else
	{
		printt( "Failed to parse announcement data! Couldnt parse \"announcement\" field,\n", response.body )
		return
	}

	if ( "announcementVersion" in responseBody && typeof( responseBody[ "announcementVersion" ] ) == "string" )
	{
		announcementVersion = expect string( responseBody[ "announcementVersion" ] )
	}
	else
	{
		printt( "Failed to parse announcement data! Couldnt parse \"announcementVersion\" field,\n", response.body )
		return
	}

	printt( "Successfully got announcement data!" )
	SetConVarString( "announcement", announcement )
	SetConVarString( "announcementVersion", announcementVersion )
}

void function OnRequestFailure( HttpRequestFailure response )
{
	printt( format( "Failed to get announcement data! (Code: %i)\nReceived response: %s", response.errorCode, response.errorMessage ) )
}
