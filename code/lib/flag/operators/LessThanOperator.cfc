component
	output = false
	hint = "I provide an operator that tests to see if a value is less than any one in a set of target values."
	{

	/**
	* I initialize the operator with the given target values.
	*/
	public void function init( required array targetValues ) {

		variables.targetValues = arguments.targetValues.map(
			( targetValue ) => {

				return( val( targetValue ) );

			}
		);

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I test the given value to see if it is less than any one of the set of target.
	*/
	public boolean function testValue( required any value ) {

		if ( ! isNumeric( value ) ) {

			return( false );

		}

		for ( var targetValue in targetValues ) {

			if ( value < targetValue ) {

				return( true );

			}

		}

		return( false );

	}

}
