component
	output = false
	hint = "I provide an operator that tests to see if a value matches against the given Java Regular Expression."
	{

	/**
	* I initialize the operator with the given Java Regular Expression text.
	*/
	public void function init( required string targetValue ) {

		variables.targetValue = arguments.targetValue;
		variables.pattern = createObject( "java", "java.util.regex.Pattern" )
			.compile( targetValue )
		;

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I test the given value to see if it matches against the target Regular Expression.
	* The test implicitly casts all values to a string.
	*/
	public boolean function testValue( required any value ) {

		if ( ! isSimpleValue( value ) ) {

			return( false );

		}

		return( pattern.matcher( toString( value ) ).find() );

	}

}
