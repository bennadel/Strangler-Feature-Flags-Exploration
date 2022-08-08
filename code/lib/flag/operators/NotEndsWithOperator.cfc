component
	output = false
	hint = "I provide an operator that tests to see if a value does not have one of the given suffixes."
	{

	/**
	* I initialize the operator with the given target values.
	*/
	public void function init( required array targetValues ) {

		variables.endsWithOperator = new EndsWithOperator( targetValues );

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I test the given value to see if it does not end with one of the set of target
	* values. The comparison implicitly casts all values to a string and is case-
	* insensitive.
	*/
	public boolean function testValue( required any value ) {

		// CAUTION: If the value is not a simple value, the following expression will
		// return True since the inverted operator returns False for non-simple values. I
		// am not entirely sure that I like this decision. But, since this is an edge-
		// case, I am going to wait and revisit it later.
		return( ! endsWithOperator.testValue( value ) );

	}

}
