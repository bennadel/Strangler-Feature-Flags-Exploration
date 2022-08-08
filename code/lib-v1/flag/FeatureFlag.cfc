component
	output = false
	hint = "I provide a feature flag that uses state and rules to target users for a set of variants."
	{

	/**
	* I initialize the feature flag with the given properties.
	*/
	public void function init(
		required string key,
		required string name,
		required string description,
		required boolean isEnabled,
		required com.bennadel.strangler.flag.Variant disabledVariant,
		required com.bennadel.strangler.flag.interfaces.VariantAllocation defaultVariantAllocation,
		required array rules
		) {

		variables.key = arguments.key;
		variables.name = arguments.name;
		variables.description = arguments.description;
		variables.isEnabled = arguments.isEnabled;
		variables.disabledVariant = arguments.disabledVariant;
		variables.defaultVariantAllocation = arguments.defaultVariantAllocation;
		variables.rules = arguments.rules;

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I return the key of the feature flag.
	*/
	public string function getKey() {

		return( key );

	}


	/**
	* I get the variant targeted at the given user configuration.
	*/
	public com.bennadel.strangler.flag.Variant function getVariant(
		required string userKey,
		required struct userProperties
		) {

		if ( ! isEnabled ) {

			return( disabledVariant );

		}

		for ( var rule in rules ) {

			var result = rule.testUser( userKey, userProperties );

			if ( result.isMatch ) {

				return( result.variant );

			}

		}

		return( defaultVariantAllocation.getVariant( userKey ) );

	}

}
