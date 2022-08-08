component
	implements = "com.bennadel.strangler.flag.interfaces.VariantAllocation"
	output = false
	hint = "I provide a variant allocation that always returns the given variant."
	{

	/**
	* I initialize the variant allocation with the given variant.
	*/
	public void function init( required Variant variant ) {

		variables.variant = arguments.variant;

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I return the variant for the given user key.
	*/
	public com.bennadel.strangler.flag.Variant function getVariant( required string userKey ) {

		return( variant );

	}

}
