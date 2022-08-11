component
	output = false
	hint = "I provide a rule that provides a variant reference if a given set of tests pass for the given user."
	{

	/**
	* I initialize the rule with the given operator and rollout.
	*/
	public void function init(
		required array tests,
		required any rollout
		) {

		variables.tests = arguments.tests;
		variables.rollout = arguments.rollout;

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I test to see if the rule targets the given user. If so, the variant reference is
	* returned. Otherwise, returns zero.
	*/
	public numeric function testUser(
		required string userKey,
		required struct userProperties
		) {

		for ( var test in tests ) {

			// Within a Rule, all of the tests are AND'ed together. As such, if any of the
			// tests fail, the Rule is short-circuited.
			if ( ! test.testUser( userKey, userProperties ) ) {

				return( 0 );

			}

		}

		return( rollout.getVariantRef( userKey ) );

	}

}
