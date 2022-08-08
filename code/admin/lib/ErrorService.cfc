component
	output = false
	hint = "I help translate application errors into appropriate response codes."
	{

	/**
	* I return the generic 400 Bad Request response.
	*/
	public struct function getGeneric400Response() {

		return({
			statusCode: 400,
			statusText: "Bad Request",
			type: "BadRequest",
			title: "Bad Request",
			message: "Sorry, your request could not be processed as-is. Please validate the information in your request and try submitting it again."
		});

	}


	/**
	* I return the generic 404 Not Found response.
	*/
	public struct function getGeneric404Response() {

		return({
			statusCode: 404,
			statusText: "Not Found",
			type: "NotFound",
			title: "Page Not Found",
			message: "Sorry, it seems that the page you requested either doesn't exist or has been moved to a new location."
		});

	}


	/**
	* I return the generic 422 Unprocessable Entity response.
	*/
	public struct function getGeneric422Response() {

		return({
			statusCode: 422,
			statusText: "Unprocessable Entity",
			type: "UnprocessableEntity",
			title: "Unprocessable Entity",
			message: "Sorry, your request data is incomplete. Please validate the information in your request and try submitting it again."
		});

	}


	/**
	* I return the generic 500 Server Error response.
	*/
	public struct function getGeneric500Response() {

		return({
			statusCode: 500,
			statusText: "Server Error",
			type: "ServerError",
			title: "Something Went Wrong",
			message: "Sorry, something seems to have gone terribly wrong while handling your request. I'll see if I can figure out what happened and fix it."
		});

	}


	/**
	* I return the error RESPONSE for the given error object. This will be the information
	* that is SAFE TO SHOW TO THE USER.
	*/
	public struct function getResponse( required any error ) {

		// Some errors include metadata about why the error was thrown. These data-points
		// can be used to generate a more insightful message for the user.
		var metadata = getErrorMetadata( error );

		// NOTE: The application actually throws MANY MORE ERRORS than those outlined in
		// the following switch statement. We only need to include the ones that are
		// "possible" for the user to produce through normal interactions. The rest of the
		// errors just need to be logged for the development team (ie, Me).
		switch ( error.type ) {
			case "FeatureFlag.Description.TooLong":
				return(
					as422({
						type: error.type,
						message: "Please use a shorter description for your feature flag. Descriptions can be up to #metadata.maxLength#-characters long."
					})
				);
			break;
			case "FeatureFlag.Key.Empty":
				return(
					as422({
						type: error.type,
						message: "Please provide a key for your feature flag."
					})
				);
			break;
			case "FeatureFlag.Key.TooLong":
				return(
					as422({
						type: error.type,
						message: "Please provide a shorter key for your feature flag. Keys can be up to #metadata.maxLength#-characters long."
					})
				);
			break;
			case "FeatureFlag.Name.Empty":
				return(
					as422({
						type: error.type,
						message: "Please provide a name for your feature flag."
					})
				);
			break;
			case "FeatureFlag.Name.TooLong":
				return(
					as422({
						type: error.type,
						message: "Please use a shorter name for your feature flag. Names can be up to #metadata.maxLength#-characters long."
					})
				);
			break;
			case "FeatureFlag.NotFound":
				return(
					as404({
						type: error.type
					})
				);
			break;
			case "FeatureFlag.Rule.Rollout.PercentTotal.Invalid":
				return(
					as422({
						type: error.type,
						message: "With a multi-distribution rollout, the percent allocation of all variants must add up to 100%."
					})
				);
			break;
			case "FeatureFlag.Rule.Test.UserProperty.Empty":
				return(
					as422({
						type: error.type,
						message: "Please enter a property for your user-property test."
					})
				);
			break;
			case "FormValidation":
				return(
					as400({
						type: error.type,
						message: error.message
					})
				);
			break;
			// Anything not handled by an explicit case becomes a generic 500 response.
			default:
				// TODO: Is this really the "right" place for logging? This component is
				// all about translating errors into user-facing responses - logging of
				// errors feels slightly off-brand. I should probably be performing the
				// logging in the same place that I am calling this component. But, for
				// the MVP of this exploration, this gets the job done.
				systemOutput( error, true, true );

				return( as500() );
			break;
		}

	}

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I generate a 400 response object for the given error attributes.
	*/
	private struct function as400( struct errorAttributes = {} ) {

		return( getGeneric400Response().append( errorAttributes ) );

	}


	/**
	* I generate a 404 response object for the given error attributes.
	*/
	private struct function as404( struct errorAttributes = {} ) {

		return( getGeneric404Response().append( errorAttributes ) );

	}


	/**
	* I generate a 422 response object for the given error attributes.
	*/
	private struct function as422( struct errorAttributes = {} ) {

		return( getGeneric422Response().append( errorAttributes ) );

	}


	/**
	* I generate a 500 response object for the given error attributes.
	*/
	private struct function as500( struct errorAttributes = {} ) {

		return( getGeneric500Response().append( errorAttributes ) );

	}


	/**
	* Some throw() commands OVERLOAD the "extendedInfo" property of an event to transmit
	* meta-data about why the error occurred up to the centralized error handler (ie, this
	* component). This methods attempts to deserialize the extendedInfo payload and return
	* the given structure. If the meta-data cannot be deserialized an empty struct is
	* returned.
	*/
	private struct function getErrorMetadata( required any error ) {

		try {

			if ( isJson( error.extendedInfo ) ) {

				return( deserializeJson( error.extendedInfo ) );

			} else {

				return( {} );

			}

		} catch ( any deserializationError ) {

			return( {} );

		}

	}

}
