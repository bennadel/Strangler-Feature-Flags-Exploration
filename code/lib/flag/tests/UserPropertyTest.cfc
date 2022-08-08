component
	output = false
	hint = "I provide a test that looks at user properties."
	{

	/**
	* I initialize the test with the given property and operator.
	*/
	public void function init(
		required string propertyKey,
		required any operator
		) {

		variables.propertyKey = arguments.propertyKey;
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

		return(
			userProperties.keyExists( propertyKey ) &&
			operator.testValue( userProperties[ propertyKey ] )
		);

	}

}
