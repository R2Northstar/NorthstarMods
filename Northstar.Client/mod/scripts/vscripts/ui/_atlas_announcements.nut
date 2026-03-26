untyped

global function GetAtlasAnnouncement_Threaded 

const string ATLAS_ANNOUNCEMENT_SUFFIX = "/client/announcements"

void function GetAtlasAnnouncement_Threaded()
{
	// TODO: All Northstar.Client files are loaded before Northstar.Custom currently, so these have to be lambdas because this file is loaded
	// before sh_northstar_http_requests so the types used as function parameters cause compile errors.
	// A weird quirk of the squirrel compiler seems to be that it gathers global defs first, and compiles them after? So by the time it's compiling the innards of
	// GetAtlasAnnouncement_Threaded it knows about the types from sh_northstar_http_requests.
	// Anyway a solution to this would be to have sh_northstar_http_requests belong to some sort of Northstar.Core or Northstar.Shared. (Same with other APIs such as file IO)
	void functionref( HttpRequestResponse ) onRequestSuccess = void function( HttpRequestResponse response )
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

		// empty announcement
		if ( announcement == "" || announcementVersion == "" )
		{
			printt( "Found empty announcement data." )
			return
		}

		printt( "Successfully got announcement data!" )
		SetConVarString( "announcement", announcement )
		SetConVarString( "announcementVersion", announcementVersion )
	}

	void functionref( HttpRequestFailure ) onRequestFailure = void function( HttpRequestFailure response )
	{
		printt( format( "Failed to get announcement data! (Code: %i)\nReceived response: %s", response.errorCode, response.errorMessage ) )
	}

	while (true)
	{
		string url = format( "%s%s", GetConVarString( "ns_masterserver_hostname" ), ATLAS_ANNOUNCEMENT_SUFFIX )
		//printt( format( "Getting announcement data from %s", url ) )

		if ( !NSHttpGet( url, {}, onRequestSuccess, onRequestFailure ) )
			printt( "Failed to get announcement data! (request failed to start)" )

		wait 300 // check for a new announcement every 5 minutes, why not
	}
}
