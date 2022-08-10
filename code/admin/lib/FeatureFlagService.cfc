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

		// LEAKY ABSTRACTION: Since we are currently storing the feature flag data in a
		// flat JSON file, there's no underlying mechanism that enforces data types and
		// value coercion at persistence time. As such, I'm jumping through a few more
		// hoops here to both VALIDATE and TRANSFORM the USER-PROVIDED inputs in order to
		// make sure that everything is of the expected type and interface. Normally, my
		// "test" functions wouldn't return data; but, in this case, they are returning
		// the sanitize data, prepared for persistence.
		key = validation.testKey( key );
		name = validation.testName( name );
		description = validation.testDescription( description );
		type = validation.testType( type );
		variants = validation.testVariants( type, variants );
		rules = validation.testRules( variants, rules );
		fallthroughVariantRef = validation.testFallthroughVariantRef( variants, fallthroughVariantRef );
		isEnabled = validation.testIsEnabled( isEnabled );

		gateway.saveFeatureFlag(
			key = key,
			name = name,
			description = description,
			type = type,
			variants = variants,
			rules = rules,
			fallthroughVariantRef = fallthroughVariantRef,
			isEnabled = isEnabled
		);

	}


	/**
	* I update the settings for the feature flag with the given key.
	*/
	public void function updateFeatureFlagSettings(
		required string key,
		required string name,
		required string description
		) {

		var featureFlag = getFeatureFlag( key );
		// LEAKY ABSTRACTION: Since we are currently storing the feature flag data in a
		// flat JSON file, there's no underlying mechanism that enforces data types and
		// value coercion at persistence time. As such, I'm jumping through a few more
		// hoops here to both VALIDATE and TRANSFORM the USER-PROVIDED inputs in order to
		// make sure that everything is of the expected type and interface. Normally, my
		// "test" functions wouldn't return data; but, in this case, they are returning
		// the sanitize data, prepared for persistence.
		featureFlag.name = validation.testName( name );
		featureFlag.description = validation.testDescription( description );

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
		// LEAKY ABSTRACTION: Since we are currently storing the feature flag data in a
		// flat JSON file, there's no underlying mechanism that enforces data types and
		// value coercion at persistence time. As such, I'm jumping through a few more
		// hoops here to both VALIDATE and TRANSFORM the USER-PROVIDED inputs in order to
		// make sure that everything is of the expected type and interface. Normally, my
		// "test" functions wouldn't return data; but, in this case, they are returning
		// the sanitize data, prepared for persistence.
		featureFlag.rules = validation.testRules( featureFlag.variants, rules );
		featureFlag.fallthroughVariantRef = validation.testFallthroughVariantRef( featureFlag.variants, fallthroughVariantRef );
		featureFlag.isEnabled = validation.testIsEnabled( isEnabled );

		gateway.saveFeatureFlag( argumentCollection = featureFlag );

	}

}
