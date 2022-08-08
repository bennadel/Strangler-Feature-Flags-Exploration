component
	implements = "com.bennadel.strangler.flag.interfaces.Rollout"
	output = false
	hint = "I provide a variant rollout that always returns the given variant reference."
	{

	/**
	* I initialize the variant rollout with the given variant reference.
	*/
	public void function init( required numeric variantRef ) {

		variables.variantRef = arguments.variantRef;

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I return the variant reference for the given user key.
	*/
	public numeric function getVariantRef( required string userKey ) {

		return( variantRef );

	}

}
