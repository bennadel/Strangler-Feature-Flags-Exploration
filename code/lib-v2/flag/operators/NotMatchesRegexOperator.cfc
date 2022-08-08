component
	implements = "com.bennadel.strangler.flag.interfaces.Operator"
	output = false
	hint = "I provide an operator that tests to see if a value does not match against the given Java Regular Expression."
	{

	/**
	* I initialize the operator with the given Java Regular Expression text.
	*/
	public void function init( required string targetValue ) {

		variables.matchesRegexOperator = new MatchesRegexOperator( targetValue );

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I test the given value to see if it does not matche against the target Regular
	* Expression. The test implicitly casts all values to a string.
	*/
	public boolean function testValue( required any value ) {

		// CAUTION: If the value is not a simple value, the following expression will
		// return True since the inverted operator returns False for non-simple values. I
		// am not entirely sure that I like this decision. But, since this is an edge-
		// case, I am going to wait and revisit it later.
		return( ! matchesRegexOperator.testValue( value ) );

	}

}
