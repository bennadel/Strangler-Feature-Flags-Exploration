component
	output = false
	hint = "I provide methods for ...."
	{

	public void function init( required array featureFlags ) {

		variables.featureFlags = arguments.featureFlags;
		variables.featureFlagIndex = buildIndex();

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I return the any variant for the given feature.
	*/
	public any function getAnyVariant(
		required string featureKey,
		required string userKey,
		required struct userProperties,
		required boolean defaultValue
		) {

		if ( ! featureFlagIndex.keyExists( featureKey ) ) {

			return( defaultValue );

		}

		var value = featureFlagIndex[ featureKey ]
			.getVariant( userKey, userProperties )
			.getAnyValue()
		;

		return( value );

	}


	/**
	* I return the Boolean variant for the given feature.
	*/
	public boolean function getBooleanVariant(
		required string featureKey,
		required string userKey,
		required struct userProperties,
		required boolean defaultValue
		) {

		if ( ! featureFlagIndex.keyExists( featureKey ) ) {

			return( defaultValue );

		}

		// EDGE CASE: If the feature serves a non-Boolean value, accessing the variant
		// will thrown an error. In that case, let's return the default value.
		try {

			var value = featureFlagIndex[ featureKey ]
				.getVariant( userKey, userProperties )
				.getBooleanValue()
			;

		} catch ( any error ) {
dump( error );
abort;
			return( defaultValue );

		}

		return( value );

	}


	/**
	* I return the numeric variant for the given feature.
	*/
	public numeric function getNumericVariant(
		required string featureKey,
		required string userKey,
		required struct userProperties,
		required numeric defaultValue
		) {

		if ( ! featureFlagIndex.keyExists( featureKey ) ) {

			return( defaultValue );

		}

		// EDGE CASE: If the feature serves a non-numeric value, accessing the variant
		// will thrown an error. In that case, let's return the default value.
		try {

			var value = featureFlagIndex[ featureKey ]
				.getVariant( userKey, userProperties )
				.getNumericValue()
			;

		} catch ( any error ) {

			return( defaultValue );

		}

		return( value );

	}


	/**
	* I return the string variant for the given feature.
	*/
	public string function getStringVariant(
		required string featureKey,
		required string userKey,
		required struct userProperties,
		required string defaultValue
		) {

		if ( ! featureFlagIndex.keyExists( featureKey ) ) {

			return( defaultValue );

		}

		// EDGE CASE: If the feature serves a non-string value, accessing the variant will
		// thrown an error. In that case, let's return the default value.
		try {

			var value = featureFlagIndex[ featureKey ]
				.getVariant( userKey, userProperties )
				.getStringValue()
			;

		} catch ( any error ) {

			return( defaultValue );

		}

		return( value );

	}

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I build an index of the given feature flags using the id property.
	*/
	private struct function buildIndex() {

		var index = {};

		for ( var featureFlag in featureFlags ) {

			index[ featureFlag.getKey() ] = featureFlag;

		}

		return( index );

	}

}
