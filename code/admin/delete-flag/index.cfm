<cfscript>

	// Setup the default request parameters.
	param name="url.key" type="string";
	param name="form.submitted" type="boolean" default=false;

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	try {

		featureFlag = application.featureFlagService.getFeatureFlag( url.key );

	} catch ( FeatureFlag.NotFound error ) {

		location( url = "/admin/index.cfm", addToken = false );

	}

	errorMessage = "";

	if ( form.submitted ) {

		try {

			application.featureFlagService.deleteFeatureFlag( url.key );

			location( url = "/admin/index.cfm", addToken = false );

		} catch ( any error ) {

			errorMessage = application.errorService.getResponse( error ).message;

		}

	}

</cfscript>
<cfmodule template="/templates/layout.cfm" title="Delete Feature Flag">
<cfoutput>

	<cfif errorMessage.len()>

		<div class="error-message">
			#encodeForHtml( errorMessage )#
		</div>

	</cfif>

	<form method="post">
		<input type="hidden" name="submitted" value="true" />

		<ul>
			<li>
				<strong>Key</strong>:
				<code>#encodeForHtml( featureFlag.key )#</code>
			</li>
			<li>
				<strong>Name</strong>:
				#encodeForHtml( featureFlag.name )#<br />
			</li>
			<li>
				<strong>Description</strong>:
				#encodeForHtml( featureFlag.description )#
			</li>
		</ul>

		<div class="buttons">
			<button type="submit" class="primary">
				Delete Feature Flag
			</button>

			<a href="/admin/index.cfm" class="cancel">Cancel</a>
		</div>
	</form>

</cfoutput>
</cfmodule>
