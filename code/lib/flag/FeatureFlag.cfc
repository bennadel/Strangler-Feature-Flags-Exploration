component
	output = false
	hint = "I provide a feature flag that uses state and rules to target users for a set of variants."
	{

	/**
	* I initialize the feature flag with the given properties.
	* 
	* CAUTION: This component does not perform any type of validation on the given data.
	* It assumes that the data in question is simply the reconstructed version of the
	* sanitized data that has already been validated and managed through an external
	* administration module.
	*/
	public void function init(
		required string key,
		required string name,
		required string description,
		required string type,
		required array variants,
		required array rules,
		required numeric fallthroughVariantRef,
		required boolean isEnabled
		) {

		variables.key = arguments.key;
		variables.name = arguments.name;
		variables.description = arguments.description;
		variables.type = arguments.type;
		variables.variants = arguments.variants;
		variables.rules = arguments.rules;
		variables.fallthroughVariantRef = arguments.fallthroughVariantRef;
		variables.isEnabled = arguments.isEnabled;

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
	* I get the variant response targeted at the given user configuration.
	*/
	public struct function getVariant(
		required string userKey,
		required struct userProperties
		) {

		if ( ! isEnabled ) {

			return(
				buildVariantResult(
					fallthroughVariantRef,
					"Feature flag not enabled, fall-through variant used."
				)
			);

		}

		loop
			index = "local.ruleIndex"
			value = "local.rule"
			array = rules
			{

			var variantRef = rule.testUser( userKey, userProperties );

			if ( variantRef ) {

				return(
					buildVariantResult(
						variantRef,
						"Feature flag targeting matched on rule #ruleIndex#."
					)
				);

			}

		}

		return(
			buildVariantResult(
				fallthroughVariantRef,
				"Feature flag did not target user, fall-through variant used."
			)
		);

	}

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I build the metadata structure to be used as the targeting result.
	*/
	private struct function buildVariantResult(
		required numeric variantRef,
		required string reason
		) {

		return({
			name: name,
			key: key,
			type: type,
			ref: variantRef,
			value: variants[ variantRef ],
			reason: reason
		});

	}

}
