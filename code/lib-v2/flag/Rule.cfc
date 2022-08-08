component
	output = false
	hint = "I provide an rule that has no test and always returns a variant reference."
	{

	/**
	* I initialize the rule with the given operator and rollout.
	*/
	public void function init(
		required array tests,
		required com.bennadel.strangler.flag.interfaces.Rollout rollout
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

			if ( ! test.testUser( userKey, userProperties ) ) {

				return( 0 );

			}

		}

		return( rollout.getVariantRef( userKey ) );

	}

}
