component
	output = false
	hint = "I define the application settings and event-handlers."
	{

	// Define the application settings.
	this.name = "StranglerDemo";
	this.applicationTimeout = createTimeSpan( 0, 1, 0, 0 );
	this.sessionManagement = false;
	this.serialization = {
		preserveCaseForStructKey: true
	};

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I run once to initialize the application.
	*/
	public void function onApplicationStart() {

		var thisDirectory = ( getDirectoryFromPath( getCurrentTemplatePath() ) );
		var dataDirectory = ( thisDirectory & "data/" )
		var dataFilepath = ( dataDirectory & "features.json" );

		application.strangler = new lib.Strangler()
			.setLoader( new lib.SyncLoader( dataFilepath ) )
		;

	}


	/**
	* I run once to initialize the request.
	*/
	public void function onRequestStart() {

		if ( url.keyExists( "init" ) ) {

			this.onApplicationStart();

		}

	}

}
