component
	output = false
	hint = "I define the application settings and event handlers."
	{

	// Define application settings.
	this.name = "StranglerAdmin";
	this.applicationTimeout = createTimeSpan( 1, 0, 0, 0 );
	this.sessionManagement = false;
	this.serialization = {
		preserveCaseForStructKey: true
	};

	this.directory = getDirectoryFromPath( getCurrentTemplatePath() );
	this.mappings = {
		"/lib": ( this.directory & "lib" ),
		"/templates": ( this.directory & "templates" ),
		"/vendor": ( this.directory & "vendor" )
	};

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I run once to initialize the application.
	*/
	public void function onApplicationStart() {

		var thisDirectory = ( getDirectoryFromPath( getCurrentTemplatePath() ) );
		var dataDirectory = ( thisDirectory & "../data/" )
		var dataFilepath = ( dataDirectory & "features.json" );

		application.errorService = new lib.ErrorService();
		application.featureFlagGateway = new lib.FeatureFlagGateway()
			.setDataFilepath( dataFilepath )
		;
		application.featureFlagValidation = new lib.FeatureFlagValidation();
		application.featureFlagService = new lib.FeatureFlagService()
			.setGateway( application.featureFlagGateway )
			.setValidation( application.featureFlagValidation )
		;

		ensureDemoFlags( dataFilepath );

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
	* I create a base set of feature flags for the demo.
	*/
	private void function ensureDemoFlags( required string dataFilepath ) {

		// NOTE: Since the feature flag data is not being committed to git, we need to
		// make sure the empty file exists before we start to interact with the
		// application.
		if ( ! fileExists( dataFilepath ) ) {

			fileWriteLine( dataFilepath, serializeJson( {} ) );

		}

		var index = application.featureFlagService.getFeatureFlagsIndex();

		if ( ! index.keyExists( "OPERATIONS--log-level" ) ) {

			application.featureFlagService.saveFeatureFlag(
				key = "OPERATIONS--log-level",
				name = "Operations: Log-Level",
				description = "I determine the lowest log-level that is captured.",
				type = "Any",
				variants = [
					{
						level: 10,
						name: "TRACE"
					},
					{
						level: 20,
						name: "DEBUG"
					},
					{
						level: 30,
						name: "INFO"
					},
					{
						level: 40,
						name: "WARN"
					},
					{
						level: 50,
						name: "ERROR"
					}
				],
				rules = [],
				fallthroughVariantRef = 5, // ERROR.
				isEnabled = false
			);

		}

	}


	/**
	* I determine if the application should be reset using a URL flag.
	*/
	private boolean function shouldResetApplication() {

		return( url?.init == "strangler" );

	}

}
