component
	implements = "com.bennadel.strangler.flag.interfaces.Operator"
	output = false
	hint = "I provide an operator that tests to see if a value is not a substring within a set of target values."
	{

	/**
	* I initialize the operator with the given target values.
	*/
	public void function init( required array targetValues ) {

		variables.containsOperator = new ContainsOperator( targetValues );

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I test the given value to see if it is not a substring within the set of target
	* values. The comparison implicitly casts all values to a string and is case-
	* insensitive.
	*/
	public boolean function testValue( required any value ) {

		// CAUTION: If the value is not a simple value, the following expression will
		// return True since the inverted operator returns False for non-simple values. I
		// am not entirely sure that I like this decision. But, since this is an edge-
		// case, I am going to wait and revisit it later.
		return( ! containsOperator.testValue( value ) );

	}

}
