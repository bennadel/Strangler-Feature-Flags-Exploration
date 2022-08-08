component
	output = false
	hint = "I load the feature flag data synchronously."
	{

	public void function init( required string dataFilepath ) {

		variables.dataFilepath = arguments.dataFilepath;

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I return an index of feature flags (indexed by key).
	*/
	public struct function getFeatureFlags() {

		var builder = new flag.FeatureFlagBuilder();

		try {

			var index = loadData().map(
				( key, value ) => {

					return( builder.fromConfig( value ) );

				}
			);

			return( index );

		} catch ( any error ) {

			return( {} );

		}

	}

	// ---
	// PRIVATE METHODS.
	// ---

	private struct function loadData()
		cachedWithin = "request"
		{

		return( deserializeJson( fileRead( dataFilepath, "utf-8" ) ) );

	}

}
