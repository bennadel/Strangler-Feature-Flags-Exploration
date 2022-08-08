component
	extends = "lib.BasePendingForm"
	output = false
	hint = "I provide methods for manipulating the pending create-flag form data."
	{

	/**
	* I initialize the pending form data with the given default structure.
	*/
	public void function init( required struct formScope ) {

		super.init(
			formScope,
			"data",
			{
				name: "",
				key: "",
				description: "",
				type: "Boolean",
				variants: [ false, true ],
				fallthroughVariantRef: 1
			}
		);

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I add a new, empty variant.
	*/
	public void function addVariant() {

		this.data.variants.append( "" );

	}


	/**
	* The goal of the method is to take the STRING-BASED FORM DATA and coerce it into the
	* data-types expected by the application core. This allows us to gracefully handle
	* very form-specific data-type conversions that would otherwise be rejected with a
	* more generic message by the application layer.
	* 
	* ASIDE: We only need to do this because we're using FORM POSTs to build-up the data.
	* If we were using an API and / or a rich-client (such as Angular) to build up a JSON
	* payload, we wouldn't have to do this transformation here in the Controller.
	*/
	public struct function prepareForSave() {

		var variants = this.data.variants.map(
			( rawVariant, i ) => {

				try {

					switch ( this.data.type ) {
						case "Any":
							return( deserializeJson( rawVariant ) );
						break;
						case "Boolean":
							return( !! rawVariant );
						break;
						case "Numeric":
							return( val( rawVariant ) );
						break;
						case "String":
							return( rawVariant.trim() );
						break;

					}

				} catch ( any error ) {

					throw(
						type = "FormValidation",
						message = "The variant [#rawVariant#] cannot be used with the selected type [#this.data.type#]. Please double-check your variant value."
					);

				}

			}
		);

		return([
			name: this.data.name.trim(),
			key: this.data.key.trim(),
			description: this.data.description.trim(),
			type: this.data.type,
			variants: variants,
			fallthroughVariantRef: val( this.data.fallthroughVariantRef )
		]);

	}


	/**
	* I remove the variant at the given index.
	*/
	public void function removeVariant( required numeric index ) {

		this.data.variants.deleteAt( index );

		// If we removed a variant that was marked as the fall-through ref, then we need
		// to reset the fall-through ref to be an in-bounds value.
		if ( ! this.data.variants.isDefined( this.data.fallthroughVariantRef ) ) {

			this.data.fallthroughVariantRef = 1;

		}

	}

}
