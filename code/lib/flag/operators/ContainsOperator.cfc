component
	output = false
	hint = "I provide an operator that tests to see if a value is a substring within a set of target values."
	{

	/**
	* I initialize the operator with the given target values.
	*/
	public void function init( required array targetValues ) {

		variables.targetValues = arguments.targetValues.map(
			( targetValue ) => {

				return( toString( targetValue ) );

			}
		);

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I test the given value to see if it is a substring within the set of target values.
	* The comparison implicitly casts all values to a string and is case-insensitive.
	*/
	public boolean function testValue( required any value ) {

		if ( ! isSimpleValue( value ) ) {

			return( false );

		}

		for ( var targetValue in targetValues ) {

			if ( targetValue.findNoCase( value ) ) {

				return( true );

			}

		}

		return( false );

	}

}
