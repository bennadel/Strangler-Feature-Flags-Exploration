component
	accessors = true
	output = false
	hint = "I provide service methods for feature flags."
	{

	// Define properties for dependency-injection.
	property gateway;
	property validation;

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I delete the feature flag with the given key.
	*/
	public void function deleteFeatureFlag( required string key ) {

		// NOTE: If the key doesn't exist, this is implicitly a No-Op.
		gateway.deleteFeatureFlagByKey( key );

	}


	/**
	* I get the feature flag with the given key.
	*/
	public struct function getFeatureFlag( required string key ) {

		var results = gateway.getFeatureFlagsByFilter( key = key );

		if ( ! results.len() ) {

			validation.throwNotFoundError( key );

		}

		return( results[ 1 ] );

	}


	/**
	* I return a collection of all feature flags.
	*/
	public array function getFeatureFlags() {

		var results = gateway.getFeatureFlagsByFilter().sort(
			( a, b ) => {

				return( compareNoCase( a.name, b.name ) );

			}
		);

		return( results );

	}


	/**
	* I return an index of all feature flags.
	*/
	public struct function getFeatureFlagsIndex() {

		var index = [:];

		// NOTE: Returns feature-flags in alphabetical order.
		for ( var featureFlag in getFeatureFlags() ) {

			index[ featureFlag.key ] = featureFlag;

		}

		return( index );

	}


	/**
	* I save the feature flag with the given key. Any existing key will be overwritten.
	*/
	public void function saveFeatureFlag(
		required string key,
		required string name,
		required string description,
		required string type,
		required array variants,
		required array rules,
		required numeric fallthroughVariantRef,
		required boolean isEnabled
		) {

		validation.testKey( key );
		validation.testName( name );
		validation.testDescription( description );
		validation.testType( type );
		validation.testVariants( type, variants );
		validation.testRules( variants, rules );
		validation.testFallthroughVariantRef( variants, fallthroughVariantRef );

		gateway.saveFeatureFlag( argumentCollection = arguments );

	}


	/**
	* I update the settings for the feature flag with the given key.
	*/
	public void function updateFeatureFlagSettings(
		required string key,
		required string name,
		required string description
		) {

		validation.testName( name );
		validation.testDescription( description );

		var featureFlag = getFeatureFlag( key );
		featureFlag.name = name;
		featureFlag.description = description;

		gateway.saveFeatureFlag( argumentCollection = featureFlag );

	}


	/**
	* I update the targeting for the feature flag with the given key.
	*/
	public void function updateFeatureFlagTargeting(
		required string key,
		required array rules,
		required numeric fallthroughVariantRef,
		required boolean isEnabled
		) {

		var featureFlag = getFeatureFlag( key );

		validation.testRules( featureFlag.variants, rules );
		validation.testFallthroughVariantRef( featureFlag.variants, fallthroughVariantRef );

		featureFlag.rules = rules;
		featureFlag.fallthroughVariantRef = fallthroughVariantRef;
		featureFlag.isEnabled = isEnabled;

		gateway.saveFeatureFlag( argumentCollection = featureFlag );

	}

}
