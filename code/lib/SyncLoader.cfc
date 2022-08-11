component
	output = false
	hint = "I load the feature flag data synchronously (and cache the data for the rest of the current request)."
	{

	/**
	* I initialize the loader for the given JSON data file.
	*/
	public void function init( required string dataFilepath ) {

		variables.dataFilepath = arguments.dataFilepath;
		variables.builder = new flag.FeatureFlagBuilder();

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I return an index of feature flags (indexed by key).
	*/
	public struct function getFeatureFlags()
		cacheWithin = "request"
		{

		var index = loadData().map(
			( key, value ) => {

				return( builder.fromConfig( value ) );

			}
		);

		return( index );

	}

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I load and parse the persisted data.
	*/
	private struct function loadData() {

		// CAUTION: Since we have no locking around this file access, there is going to be
		// access contention between other requests and the admin code as well. But, since
		// this is just a silly little demo, none of that will actually happen.
		return( deserializeJson( fileRead( dataFilepath, "utf-8" ) ) );

	}

}
