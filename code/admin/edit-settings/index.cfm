<cfscript>

	// Setup the default request parameters.
	param name="url.key" type="string";
	param name="form.submitted" type="boolean" default="false";
	param name="form.name" type="string" default="";
	param name="form.description" type="string" default="";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	try {

		featureFlag = application.featureFlagService.getFeatureFlag( url.key );

	} catch ( FeatureFlag.NotFound error ) {

		location( url = "/admin/index.cfm", addToken = false );

	}

	// If the form hasn't been submitted, use the feature flag to initialize the data.
	if ( ! form.submitted ) {

		form.name = featureFlag.name;
		form.description = featureFlag.description;

	}

	errorMessage = "";

	if ( form.submitted ) {

		try {

			application.featureFlagService.updateFeatureFlagSettings(
				key = url.key,
				name = form.name.trim(),
				description = form.description.trim()
			);

			location( url = "/admin/index.cfm", addToken = false );

		} catch ( any error ) {

			errorMessage = application.errorService.getResponse( error ).message;

		}

	}

</cfscript>
<cfmodule template="/templates/layout.cfm" title="Update Feature Flag Settings">
<cfoutput>

	<cfif errorMessage.len()>

		<div class="error-message">
			#encodeForHtml( errorMessage )#
		</div>

	</cfif>

	<h2>
		<strong>Key</strong>:
		<code>#encodeForHtml( featureFlag.key )#</code>
	</h2>

	<form method="post">
		<input type="hidden" name="submitted" value="true" />

		<div class="entry">
			<label class="entry__label">
				Name:
			</label>
			<div class="entry__body">
				<input
					type="text"
					name="name"
					value="#encodeForHtmlAttribute( form.name )#"
					size="50"
					maxlength="50"
				/>
			</div>
		</div>
		<div class="entry">
			<label class="entry__label">
				Description:
			</label>
			<div class="entry__body">
				<input
					type="text"
					name="description"
					value="#encodeForHtmlAttribute( form.description )#"
					size="50"
					maxlength="300"
				/>
			</div>
		</div>

		<h2>
			Variants (ie, possible feature flag values)
		</h2>

		<p>
			<strong>Note</strong>: In order to help ensure the stability of your
			application, feature flag variants cannot be edited after they have been
			created. This way, the meaning of the feature flag can't suddenly change
			in the context of an existing application runtime.
		</p>

		<ol>
			<cfloop item="variant" array="#featureFlag.variants#">
				<li>
					#encodeForHtml( serializeJson( variant ) )#
				</li>
			</cfloop>
		</ol>

		<div class="buttons">
			<button type="submit" class="primary">
				Save Feature Flag
			</button>

			<a href="/admin/index.cfm" class="cancel">Cancel</a>
		</div>
	</form>

</cfoutput>
</cfmodule>
