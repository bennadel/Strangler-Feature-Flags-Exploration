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
		variables.variants = [];
		variables.rules = rules;
		variables.fallthroughVariantRef = 0;
		variables.isEnabled = arguments.isEnabled;

		setVariants( arguments.variants );
		setFallthroughVariantRef( arguments.fallthroughVariantRef );

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
	public struct function getVariant(
		required string userKey,
		required struct userProperties
		) {

		if ( isEnabled ) {

			for ( var rule in rules ) {

				var variantRef = rule.testUser( userKey, userProperties );

				if ( variantRef && variants.isDefined( variantRef ) ) {

					return({
						type: type,
						ref: variantRef,
						value: variants[ variantRef ]
					});

				}

			}

		}

		return({
			type: type,
			ref: fallthroughVariantRef,
			value: variants[ fallthroughVariantRef ]
		});

	}

	// ---
	// PRIVATE METHODS.
	// ---

	private void function setFallthroughVariantRef( required numeric newFallthroughVariantRef ) {

		if ( ! variants.isDefined( newFallthroughVariantRef ) ) {

			throw( type = "InvalidFallthroughVariantRef" );

		}

		fallthroughVariantRef = newFallthroughVariantRef;

	}


	private void function setVariants( required array newVariants ) {

		if ( ! newVariants.len() ) {

			throw( type = "NotEnoughVariants" );

		}

		variants.append( newVariants, true );

	}

}
