<cfscript>

	// With every FORM POST, the current, serialized version of our pending data is going
	// to be posted back to the server. The ACTION values will then describe how we want
	// to mutate this post-back data on each rendering.
	param name="form.data" type="string" default="";

	// Setup the default request parameters.
	param name="form.action" type="string" default="";
	param name="form.actionPath" type="string" default="";
	param name="form.actionIndex" type="string" default="0";

	// The action properties define how we mutate the pending form data.
	if ( form.action.find( ":" ) ) {

		parts = form.action.listToArray( ": " );

		form.action = parts[ 1 ];
		form.actionPath = parts[ 2 ];
		form.actionIndex = val( parts[ 3 ] ?: 0 );

	}

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	// The PendingForm() provides helper functions that make it easy to access and change
	// properties deep within the pending data structure.
	pending = new PendingForm( form );
	errorMessage = "";

	switch ( form.action ) {
		case "addVariant":

			pending.addVariant();

		break;
		case "removeVariant":

			pending.removeVariant( form.actionIndex );

		break;
		case "save":

			try {

				// Right now, the pending form data is all string-based since all form
				// inputs are submitted as string values. Before we interact with the
				// application layer, we have to coerce the string values into the
				// appropriate data types for the underlying data-model.
				// --
				// ASIDE: If we had a rich-client user interface (UI), like Angular, that
				// was posting the configuration data as a JSON payload, our controller
				// wouldn't have to do this. Our preparation-for-save workflow is a
				// byproduct of the fact that we are using FORM POST-backs as the means to
				// build-up and aggregate the data.
				preparedData = pending.prepareForSave();

				application.featureFlagService.saveFeatureFlag(
					key = preparedData.key,
					name = preparedData.name,
					description = preparedData.description,
					type = preparedData.type,
					variants = preparedData.variants,
					rules = [],
					fallthroughVariantRef = preparedData.fallthroughVariantRef,
					isEnabled = false
				);

				location(
					url = "/admin/edit-targeting/index.cfm?key=#encodeForUrl( preparedData.key )#",
					addToken = false
				);

			} catch ( any error ) {

				errorMessage = application.errorService.getResponse( error ).message;

			}

		break;
	}

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	typeOptions = [
		{ value: "Boolean", label: "Boolean" },
		{ value: "Numeric", label: "Numeric" },
		{ value: "String", label: "String" },
		{ value: "Any", label: "Any (serializable value)" }
	];

	// To make it easier to render the form inputs let's get a direct reference to the
	// pending form data structure. There's no benefit to going through the "pending"
	// component if we're not going to be manipulating abstract object paths.
	data = pending.data;

</cfscript>
<cfmodule template="/templates/layout.cfm" title="Create Feature Flag">
<cfoutput>

	<cfif errorMessage.len()>

		<div class="error-message">
			#encodeForHtml( errorMessage )#
		</div>

	</cfif>

	<form method="post">

		<input
			type="hidden"
			name="data"
			value="#encodeForHtmlAttribute( pending.getJson() )#"
		/>

		<!---
			When a form is submitted with the ENTER KEY, the browser will implicitly
			use the first submit button in the DOM TREE order as the button that
			triggered the submit. Since we are using MULTIPLE SUBMIT buttons to drive
			object manipulation, let's add a NON-VISIBLE submit as the first element in
			the form so that the browser uses this one as the default submit. That said,
			since we don't want to render this one, we're moving it off-screen.
		--->
		<button type="submit" name="action" value="save" tabindex="-1" class="visually-hidden">
			Save Feature Flag
		</button>

		<h2>
			Settings
		</h2>

		<div class="entry">
			<label class="entry__label">
				Name:
			</label>
			<div class="entry__body">
				<input
					type="text"
					name=".name"
					value="#encodeForHtmlAttribute( data.name )#"
					size="50"
					maxlength="50"
				/>
			</div>
		</div>
		<div class="entry">
			<label class="entry__label">
				Key:
			</label>
			<div class="entry__body">
				<input
					type="text"
					name=".key"
					value="#encodeForHtmlAttribute( data.key )#"
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
					name=".description"
					value="#encodeForHtmlAttribute( data.description )#"
					size="50"
					maxlength="300"
				/>
			</div>
		</div>
		<div class="entry">
			<label class="entry__label">
				Type:
			</label>
			<div class="entry__body">
				<select name=".type">
					<cfloop item="option" array="#typeOptions#">
						<option
							value="#encodeForHtmlAttribute( option.value )#"
							<cfif ( data.type == option.value )>selected</cfif>>
							#encodeForHtml( option.label )#
						</option>
					</cfloop>
				</select>
			</div>
		</div>

		<h2>
			Variants (ie, possible feature flag values)
		</h2>

		<ol class="variants-list">
			<cfloop index="i" item="variant" array="#data.variants#">
				<li class="variants-list__item">

					<input
						type="text"
						name=".variants.#i#"
						value="#encodeForHtmlAttribute( variant )#"
						size="30"
					/>

					<label>
						<input
							type="radio"
							name=".fallthroughVariantRef"
							value="#i#"
							<cfif ( data.fallthroughVariantRef == i )>checked</cfif>
						/>
						Fall-through variant
					</label>

					<!---
						Each feature flag needs to have 2 variants to be meaningful
						(what's the point of putting code behind a value that will never
						change). As such, only show the remove action if we're on the 3rd+
						variant option.
					--->
					<cfif ( i gt 2 )>
						&mdash;
						<button
							type="submit"
							name="action"
							value="removeVariant : _ : #i#"
							class="remove">
							Remove variant
						</button>
					</cfif>

				</li>
			</cfloop>
		</ol>

		<p>
			<button type="submit" name="action" value="addVariant">
				Add variant
			</button>
		</p>

		<div class="buttons">
			<button type="submit" name="action" value="save" class="primary">
				Save Feature Flag
			</button>

			<a href="/admin/index.cfm" class="cancel">Cancel</a>
		</div>

	</form>

	<!---
		Add a little bit of JavaScript to maintain the current scroll offset across form
		submissions. This creates a slightly better user experience.
	--->
	<script type="text/javascript">
		setupFormScroll();
	</script>

</cfoutput>
</cfmodule>
