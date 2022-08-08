component
	implements = "com.bennadel.strangler.flag.interfaces.Operator"
	output = false
	hint = "I provide an operator that tests to see if a value does not exist in a set of target values."
	{

	/**
	* I initialize the operator with the given target values.
	*/
	public void function init( required array targetValues ) {

		variables.isOneOfOperator = new IsOneOfOperator( targetValues );

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I test the given value to see if it does not exist in the set of target values. The
	* comparison implicitly casts all values to a string and is case-insensitive.
	*/
	public boolean function testValue( required any value ) {

		return( ! isOneOfOperator.testValue( value ) );

	}

}
