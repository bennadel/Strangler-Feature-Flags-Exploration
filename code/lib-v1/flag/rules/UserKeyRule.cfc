component
	implements = "com.bennadel.strangler.flag.interfaces.Rule"
	output = false
	hint = "I provide an rule that tests user keys."
	{

	/**
	* I initialize the rule with the given operator and variants.
	*/
	public void function init(
		required com.bennadel.strangler.flag.interfaces.Operator operator,
		required com.bennadel.strangler.flag.interfaces.VariantAllocation variantAllocation
		) {

		variables.operator = arguments.operator;
		variables.variantAllocation = arguments.variantAllocation;

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I test to see if the rule targets the given user. If so, the variant allocation is
	* returned with the match.
	*/
	public struct function testUser(
		required string userKey,
		required struct userProperties
		) {

		if ( operator.testValue( userKey ) ) {

			return({
				isMatch: true,
				variant: variantAllocation.getVariant( userKey )
			});

		}

		return({
			isMatch: false
		});

	}

}
