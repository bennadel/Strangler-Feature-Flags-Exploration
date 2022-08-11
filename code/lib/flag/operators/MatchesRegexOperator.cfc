component
	output = false
	hint = "I provide an operator that tests to see if a value matches against the given Java Regular Expression."
	{

	/**
	* I initialize the operator with the given target values (Java RegEx pattern text).
	*/
	public void function init( required array targetValues ) {

		variables.patterns = arguments.targetValues.map(
			( targetValue ) => {

				return( createObject( "java", "java.util.regex.Pattern" ).compile( toString( targetValue ) ) );

			}
		);

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I test the given value to see if it matches against the target Regular Expressions.
	* The test implicitly casts all values to a string.
	*/
	public boolean function testValue( required any value ) {

		if ( ! isSimpleValue( value ) ) {

			return( false );

		}

		for ( var pattern in patterns ) {

			if ( pattern.matcher( toString( value ) ).find() ) {

				return( true );

			}

		}

		return( false );

	}

}
