<cfscript>

	// This is not intended to be a super robust API. I am only trying to provide enough
	// infrastructure to get a simple Angular front-end working. The entire API is being
	// implemented by this single controller template. However, unlike the other CFML
	// controllers in this proof-of-concept, this one applies much less pre-workflow
	// validation since it is expecting the Angular front-end to provide the right data
	// structures composed of the right data-types. To be clear, the workflow layer is
	// stile providing all the necessary validation to ensure nothing bad happens to the
	// persisted data; but, there's no "massaging" of inputs.

	apiResponse = {
		statusText: "OK",
		statusCode: 200,
		data: {}
	};

	try {

		param name="url.action" type="string";

		// --------------------------------------------------------------------------- //
		// --------------------------------------------------------------------------- //

		requestData = getHttpRequestData();
		// If there is content in the body, and it appears to be JSON (JavaScript Object
		// Notation), deserialize it and use it as the request body. We know that the API
		// client is going to be posting JSON payloads.
		requestBody = isJsonRequest()
			? deserializeJson( requestData.content )
			: {}
		;

		// --------------------------------------------------------------------------- //
		// --------------------------------------------------------------------------- //

		switch ( url.action ) {
			case "createFeatureFlag":

				assertHttpMethod( "POST" );
				param name="requestBody.key" type="string";
				param name="requestBody.name" type="string";
				param name="requestBody.description" type="string";
				param name="requestBody.type" type="string";
				param name="requestBody.variants" type="array";
				param name="requestBody.fallthroughVariantRef" type="numeric";

				application.featureFlagService.saveFeatureFlag(
					key = requestBody.key,
					name = requestBody.name,
					description = requestBody.description,
					type = requestBody.type,
					variants = requestBody.variants,
					rules = [],
					fallthroughVariantRef = requestBody.fallthroughVariantRef,
					isEnabled = false
				);

			break;
			case "deleteFeatureFlag":

				assertHttpMethod( "DELETE" );
				param name="url.key" type="string";

				application.featureFlagService.deleteFeatureFlag( url.key );

			break;
			case "getFeatureFlag":

				assertHttpMethod( "GET" );
				param name="url.key" type="string";

				apiResponse.data.featureFlag = application.featureFlagService.getFeatureFlag( url.key );

			break;
			case "getFeatureFlags":

				assertHttpMethod( "GET" );

				apiResponse.data.featureFlags = application.featureFlagService.getFeatureFlags();

			break;
			case "updateFeatureFlagSettings":

				assertHttpMethod( "POST" );
				param name="url.key" type="string";
				param name="requestBody.name" type="string";
				param name="requestBody.description" type="string";

				application.featureFlagService.updateFeatureFlagSettings(
					key = url.key,
					name = requestBody.name,
					description = requestBody.description
				);

			break;
			case "updateFeatureFlagTargeting":

				assertHttpMethod( "POST" );
				param name="url.key" type="string";
				param name="requestBody.rules" type="array";
				param name="requestBody.fallthroughVariantRef" type="numeric";
				param name="requestBody.isEnabled" type="boolean";

				application.featureFlagService.updateFeatureFlagTargeting(
					key = url.key,
					rules = requestBody.rules,
					fallthroughVariantRef = requestBody.fallthroughVariantRef,
					isEnabled = requestBody.isEnabled
				);

			break;
			default:

				throw( type = "API.UnsupportedAction" );

			break;
		}

	} catch ( any error ) {

		errorResponse = application.errorService.getResponse( error );

		apiResponse.statusText = errorResponse.statusText;
		apiResponse.statusCode = errorResponse.statusCode;
		apiResponse.data = {
			type: errorResponse.type,
			message: errorResponse.message,
			// This flag indicates that the error response came from our servers, and not
			// from some intermediary failure, like a reverse-proxy error or and network
			// error. The client-side can check this before blindly rendering the returned
			// error message (though, encoding it for HTML of course).
			strangler: true
		};

		// CAUTION: You would !!! NEVER DO THIS IN A PRODUCTION APPLICATION !!!; but, by
		// returning the root cause of the error in the API response, it makes debugging
		// easier. But, TO BE CLEAR, this exposes sensitive information about your server.
		apiResponse.data.rootCause = error;

	}

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	cfheader(
		statusText = apiResponse.statusText,
		statusCode = apiResponse.statusCode
	);

	// Reset the output buffer and return the API response (JSON).
	cfcontent(
		type = "application/json; charset=utf-8",
		variable = serializeResponseData( apiResponse.data )
	);

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	/**
	* I assert that the current request matches the given method. If not, an error is
	* thrown.
	*/
	public void function assertHttpMethod( required string method ) {

		if ( requestData.method != method ) {

			throw( type = "API.BadMethod" );

		}

	}


	/**
	* I determine if the current request contains a JSON payload (or rather, is reporting
	* itself to contain a JSON payload).
	*/
	public boolean function isJsonRequest() {

		return(
			requestData.content.len() &&
			requestData.headers[ "Content-Type" ].reFindNoCase( "(application|text)/(x-)?json" )
		);

	}


	/**
	* I serialize the response data in preparation for the CFContent tag.
	*/
	public binary function serializeResponseData( required any data ) {

		return( charsetDecode( serializeJson( data ), "utf-8" ) );

	}

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //
	// For Simple Command-line Testing in Chrome Dev Tools.
	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	/*
	fetch(
		"/admin/api/index.cfm?action=getFeatureFlags",
		{
			"method": "GET",
			"headers": {},
			"body": null
		}
	);

	fetch(
		"/admin/api/index.cfm?action=getFeatureFlag&key=OPERATIONS--log-level",
		{
			"method": "GET",
			"headers": {},
			"body": null
		}
	);

	fetch(
		"/admin/api/index.cfm?action=createFeatureFlag",
		{
			"method": "POST",
			"headers": {
				"Content-Type": "application/json"
			},
			"body": JSON.stringify({
				key: "TEST--my-new-flag",
				name: "TEST: My New Flag",
				description: "Just testing the API",
				type: "Boolean",
				variants: [ false, true ],
				fallthroughVariantRef: 1
			})
		}
	);

	fetch(
		"/admin/api/index.cfm?action=updateFeatureFlagSettings&key=TEST--my-new-flag",
		{
			"method": "POST",
			"headers": {
				"Content-Type": "application/json"
			},
			"body": JSON.stringify({
				name: "TEST: My New Flag",
				description: "Just testing the API (edited via API)"
			})
		}
	);

	fetch(
		"/admin/api/index.cfm?action=updateFeatureFlagTargeting&key=TEST--my-new-flag",
		{
			"method": "POST",
			"headers": {
				"Content-Type": "application/json"
			},
			"body": JSON.stringify({
				rules: [
					{
						tests: [
							{
								type: "UserKey",
								operation: {
									operator: "OneOf",
									values: [ "101", "202", "303" ]
								}
							}
						],
						rollout: {
							type: "Single",
							variantRef: 2
						}
					},
					{
						tests: [],
						rollout: {
							type: "Multi",
							distribution: [
								{
									percent: 50,
									variantRef: 1
								},
								{
									percent: 50,
									variantRef: 2
								}
							]
						}
					}
				],
				fallthroughVariantRef: 1,
				isEnabled: true
			})
		}
	);

	fetch(
		"/admin/api/index.cfm?action=deleteFeatureFlag&key=TEST--my-new-flag",
		{
			"method": "DELETE"
		}
	);
	*/

</cfscript>
