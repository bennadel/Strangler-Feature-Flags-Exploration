component
	accessors = true
	output = false
	hint = "I provide methods for reading feature flag values for a given user."
	{

	// Define properties for dependency-injection.
	property loader;

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I return the variant for the given feature.
	*/
	public any function getVariant(
		required string featureKey,
		required string userKey,
		required struct userProperties,
		required any defaultValue
		) {

		var index = loader.getFeatureFlags();

		// If the feature flag doesn't exist, it may be a developer error; or, it may mean
		// that we weren't able to load the rules from the underlying storage mechanism.
		if ( ! index.keyExists( featureKey ) ) {

			return( defaultValue );

		}

		var variant = index[ featureKey ]
			.getVariant( userKey, userProperties )
		;

		return( variant.value );

	}

}
