component
	implements = "com.bennadel.strangler.flag.interfaces.Operator"
	output = false
	hint = "I provide an operator that tests to see if a value exists in a set of target values."
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
		variables.targetValueIndex = buildIndex();

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I test the given value to see if it exists in the set of target values. The
	* comparison implicitly casts all values to a string and is case-insensitive.
	*/
	public boolean function testValue( required any value ) {

		if ( ! isSimpleValue( value ) ) {

			return( false );

		}

		return( targetValueIndex.keyExists( value ) );

	}

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I build an index of the given target values. Each value is used as a KEY in the
	* index, which means that all target values are implicitly cast to a string.
	*/
	private struct function buildIndex() {

		var index = {};

		for ( var value in targetValues ) {

			index[ value ] = true;

		}

		return( index );

	}

}
