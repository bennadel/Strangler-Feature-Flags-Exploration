component
	output = false
	hint = "I provide a test that looks at user keys."
	{

	/**
	* I initialize the test with the given operator.
	*/
	public void function init( required any operator ) {

		variables.operator = arguments.operator;

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I test to see if the operator targets the given user.
	*/
	public boolean function testUser(
		required string userKey,
		required struct userProperties
		) {

		return( operator.testValue( userKey ) );

	}

}
