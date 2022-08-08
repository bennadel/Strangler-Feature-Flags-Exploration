component
	implements = "com.bennadel.strangler.flag.interfaces.VariantAllocation"
	output = false
	hint = "I provide a variant allocation that returns variants using a weighted distribution."
	{

	/**
	* I initialize the variant allocation with the given variants. Each distribution is
	* expected to be a struct that contains the following keys:
	* 
	* - percent (an integer weight).
	* - variant (the variant to be allocated).
	* 
	* If the provided percents do not total 100, an error is thrown.
	*/
	public void function init( required array distributions ) {

		variables.distributions = arguments.distributions;
		variables.bucketIndex = buildBucketIndex();

		// The checksum algorithm interface returns a LONG value, which we cannot use with
		// the normal modulus operator. As such, we have to fallback to using BigInteger
		// to perform the modulus operation.
		variables.BigInteger = createObject( "java", "java.math.BigInteger" );

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I return the variant for the given user key.
	*/
	public com.bennadel.strangler.flag.Variant function getVariant( required string userKey ) {

		return( bucketIndex[ getUserBucket( userKey ) ] );

	}

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I flesh-out the index of variants using the given distributions. The index is an
	* array with 100 entries. Each entry in the array will match a bucket that holds a
	* given variant. The number of times a given variant is repeated within this index is
	* based on the weight of its distribution.
	*/
	private array function buildBucketIndex() {

		var index = [];
		var indexSize = 0;

		for ( var entry in distributions ) {

			var percent = entry.percent;
			var variant = entry.variant;

			if ( ( indexSize + percent ) > 100 ) {

				throwPercentageOverflowError();

			}

			for ( var i = 1 ; i <= percent ; i++ ) {

				index[ ++indexSize ] = variant;

			}

		}

		if ( indexSize != 100 ) {

			throwPercentageUnderflowError()

		}

		return( index );

	}


	/**
	* I compute the consistent CRC-32 checksum for the given user.
	*/
	private numeric function getChecksum( required string userKey ) {

		var checksum = createObject( "java", "java.util.zip.CRC32" )
			.init()
		;
		checksum.update( charsetDecode( userKey, "utf-8" ) );

		return( checksum.getValue() );

	}


	/**
	* I calculate the consistent bucket (1-100) for the given user.
	*/
	private numeric function getUserBucket( required string userKey ) {

		var checksum = BigInteger.valueOf( getChecksum( userKey ) );
		var bucketCount = BigInteger.valueOf( 100 );

		return( checksum.mod( bucketCount ) + 1 );

	}


	/**
	* I throw an error indicating that the distribution has too many weights.
	*/
	private void function throwPercentageOverflowError() {

		throw(
			type = "Strangler.MultiVariantAllocation.PercentageOverflow",
			message = "Multi-variant distribution totals greater than 100."
		);

	}


	/**
	* I throw an error indicating that the distribution has too few weights.
	*/
	private void function throwPercentageUnderflowError() {

		throw(
			type = "Strangler.MultiVariantAllocation.PercentageUnderflow",
			message = "Multi-variant distribution totals less than 100."
		);

	}

}
