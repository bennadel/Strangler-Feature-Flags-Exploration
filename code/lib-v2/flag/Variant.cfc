component
	output = false
	hint = "I provide a value to be served up as a feature flag evaluation."
	{

	this.TYPES.ANY = "ANY";
	this.TYPES.BOOLEAN = "BOOLEAN";
	this.TYPES.STRING = "STRING";
	this.TYPES.NUMERIC = "NUMERIC";

	/**
	* I initialize the variant with the given properties.
	*/
	public void function init(
		required string type,
		required any value
		) {

		variables.type = arguments.type;

		switch ( type ) {
			case this.TYPES.ANY:
				variables.value = arguments.value;
			break;
			case this.TYPES.BOOLEAN:
				variables.value = !! arguments.value;
			break;
			case this.TYPES.NUMERIC:
				variables.value = val( arguments.value );
			break;
			case this.TYPES.STRING:
				variables.value = toString( arguments.value );
			break;
			default:
				throwInvalidTypeError( arguments );
			break;
		}

	}

	// ---
	// PUBLIC METHODS.
	// ---


	DO WE ACTUALLY NEED TO HAVE DIFFERENT TYPES?!?!?!




	/**
	* I return the underlying value, regardless of its type.
	*/
	public any function getAnyValue() {

		return( value );

	}


	/**
	* I return the underlying Boolean value; or, thrown an error if the value is not a
	* Boolean.
	*/
	public boolean function getBooleanValue() {

		if ( isBooleanType() ) {

			return( value );

		}

		throwTypeMismatchError( this.TYPES.BOOLEAN );

	}


	/**
	* I return the underlying numeric value; or, thrown an error if the value is not
	* numeric.
	*/
	public numeric function getNumericValue() {

		if ( type == this.TYPES.NUMERIC ) {

			return( value );

		}

		throwTypeMismatchError( this.TYPES.NUMERIC );

	}


	/**
	* I return the underlying string value; or, thrown an error if the value is not a
	* string.
	*/
	public string function getStringValue() {

		if ( type == this.TYPES.STRING ) {

			return( value );

		}

		throwTypeMismatchError( this.TYPES.STRING );

	}


	/**
	* I determine if the underlying variant holds an any value.
	*/
	public boolean function isAnyType() {

		return( type == this.TYPES.ANY );

	}


	/**
	* I determine if the underlying variant holds a Boolean value.
	*/
	public boolean function isBooleanType() {

		return( type == this.TYPES.BOOLEAN );

	}


	/**
	* I determine if the underlying variant holds a numeric value.
	*/
	public boolean function isNumericType() {

		return( type == this.TYPES.NUMERIC );

	}


	/**
	* I determine if the underlying variant holds a string value.
	*/
	public boolean function isStringType() {

		return( type == this.TYPES.STRING );

	}


	/**
	* I determine if the variant type matches the given input.
	*/
	public boolean function isOfType( required string input ) {

		return( type == input );

	}

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I thrown an error for an unsupported variant type.
	*/
	private void function throwInvalidTypeError( required any errorContext ) {

		throw(
			type = "Strangler.Variant.InvalidType",
			message = "Variant type is not supported.",
			extendedInfo = serializeJson( arguments )
		);

	}


	/**
	* I thrown an error for a variant type mismatch.
	*/
	private void function throwTypeMismatchError( required string desiredType ) {

		throw(
			type = "Strangler.Variant.TypeMismatch",
			message = "Variant cannot be cast to the desired type.",
			detail = "Variant [#type#] cannot be cast to [#desiredType#]."
		);

	}

}
