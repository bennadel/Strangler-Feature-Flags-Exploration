component
	output = false
	hint = "I provide methods for manipulating the pending form data. This component is intend to be extended by a form-specific helper."
	{

	/**
	* I initialize the pending form data with the given, serialized value.
	*/
	public void function init(
		required struct formScope,
		required string dataKey,
		required struct defaultValue
		) {

		this.data = ( len( formScope[ dataKey ] ?: "" ) )
			? deserializeJson( formScope[ dataKey ] )
			: defaultValue
		;

		// Loop over the form scope and look for OBJECT PATHS. Any key that is an object
		// path should have its value stored into the pending data structure.
		for ( var key in formScope ) {

			if ( key.left( 1 ) == "." ) {

				setValue( key, formScope[ key ].trim() );

			}

		}

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I return the serialized value for the current, pending data structure.
	*/
	public string function getJson() {

		return( serializeJson( this.data ) );

	}


	/**
	* I take a dot-delimited object path, like ".contacts.3.number", and return the value
	* stored deep within the pending form data.
	*/
	public any function getValue( required string objectPath ) {

		// Here, we're using the .reduce() method to walk the dot-delimited segments
		// within the key path and traverse down into the data object. Each dot-delimited
		// segment represents a step down into a nested structure (or Array).
		var value = objectPath.listToArray( "." ).reduce(
			( reduction, segment ) => {

				return( reduction[ segment ] );

			},
			this.data
		);

		return( value );

	}


	/**
	* I take a dot-delimited object path, like ".contacts.3.number", and store a new value
	* deep within the pending form data.
	*/
	public void function setValue(
		required string objectPath,
		required any value
		) {

		// Again, we're using the .reduce() method to walk the dot-delimited segments
		// within the key path and traverse down into the data object. Only this time,
		// once we reach the LAST SEGMENT, we're going to treat it as a WRITE rather than
		// a READ.
		objectPath.listToArray( "." ).reduce(
			( reduction, segment, segmentIndex, segments ) => {

				// LAST SEGMENT becomes a write operation, not a read.
				if ( segmentIndex == segments.len() ) {

					reduction[ segment ] = value;

				}

				return( reduction[ segment ] );

			},
			this.data
		);

	}

}
