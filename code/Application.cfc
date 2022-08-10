component
	output = false
	hint = "I define the application settings and event-handlers."
	{

	// Define the application settings.
	this.name = "StranglerDemoPublic";
	this.applicationTimeout = createTimeSpan( 1, 0, 0, 0 );
	this.sessionManagement = false;
	this.serialization = {
		preserveCaseForStructKey: true
	};

	this.directory = getDirectoryFromPath( getCurrentTemplatePath() );
	this.mappings = {
		"/data": ( this.directory & "data" ),
		"/lib": ( this.directory & "lib" )
	};

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I run once to initialize the application.
	*/
	public void function onApplicationStart() {

		var dataFilepath = expandPath( "/data/features.json" );

		application.strangler = new lib.Strangler()
			.setLoader( new lib.SyncLoader( dataFilepath ) )
		;

	}


	/**
	* I run once to initialize the request.
	*/
	public void function onRequestStart() {

		if ( shouldResetApplication() ) {

			this.onApplicationStart();

		}

	}

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I determine if the application should be reset using a URL flag.
	*/
	private boolean function shouldResetApplication() {

		return( url?.init == "strangler" );

	}

}
