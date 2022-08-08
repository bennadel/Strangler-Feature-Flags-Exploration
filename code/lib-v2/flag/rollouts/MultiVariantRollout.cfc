component
	implements = "com.bennadel.strangler.flag.interfaces.Rollout"
	output = false
	hint = "I provide a variant rollout that returns variant references using a weighted distribution."
	{

	/**
	* I initialize the variant rollout with the given variants. Each distribution is
	* expected to be a struct that contains the following keys:
	* 
	* - variantRef (the integer sort index).
	* - percent (an integer weight).
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
	* I return the variant reference for the given user key.
	*/
	public numeric function getVariantRef( required string userKey ) {

		return( bucketIndex[ getUserBucket( userKey ) ] );

	}

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I flesh-out the index of variant references using the given distributions. The index
	* is an array with 100 entries. Each entry in the array will match a bucket that holds
	* a given variant reference. The number of times a given variant reference is repeated
	* within this index is based on the weight of its distribution.
	*/
	private array function buildBucketIndex() {

		var index = [];
		var indexSize = 0;

		for ( var entry in distributions ) {

			var percent = entry.percent;
			var variantRef = entry.variantRef;

			for ( var i = 1 ; i <= percent ; i++ ) {

				index[ ++indexSize ] = variantRef;

			}

		}

		if ( indexSize != 100 ) {

			throwPercentageInvalidError()

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
	* I throw an error indicating that the distribution total is invalid.
	*/
	private void function throwPercentageInvalidError() {

		throw(
			type = "Strangler.MultiVariantRollout.PercentageInvalid",
			message = "Multi-variant rollout distribution total does not equal 100."
		);

	}

}
