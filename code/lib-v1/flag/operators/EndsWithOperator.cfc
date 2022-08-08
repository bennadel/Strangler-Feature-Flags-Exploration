component
	implements = "com.bennadel.strangler.flag.interfaces.Operator"
	output = false
	hint = "I provide an operator that tests to see if a value has one of the given suffixes."
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
	* I test the given value to see if it ends with one of the set of target values. The
	* comparison implicitly casts all values to a string and is case-insensitive.
	*/
	public boolean function testValue( required any value ) {

		if ( ! isSimpleValue( value ) ) {

			return( false );

		}

		value = toString( value );

		for ( var targetValue in targetValues ) {

			if ( value.len() < targetValue.len() ) {

				continue;

			}

			if ( value.right( targetValue.len() ) == targetValue ) {

				return( true );

			}

		}

		return( false );

	}

}
