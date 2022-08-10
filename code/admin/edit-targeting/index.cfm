<cfscript>

	// With every FORM POST, the current, serialized version of our pending data is going
	// to be posted back to the server. The ACTION values will then describe how we want
	// to mutate this post-back data on each rendering.
	param name="form.data" type="string" default="";

	// Setup the default request parameters.
	param name="url.key" type="string";
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

	try {

		featureFlag = application.featureFlagService.getFeatureFlag( url.key );

	} catch ( FeatureFlag.NotFound error ) {

		location( url = "/admin/index.cfm", addToken = false );

	}

	// The PendingForm() provides helper functions that make it easy to access and change
	// properties deep within the pending data structure.
	pending = new PendingForm( form, featureFlag );
	errorMessage = "";

	try {

		switch ( form.action ) {
			case "addUserKeyTest":

				pending.addUserKeyTest( form.actionPath );

			break;
			case "addUserPropertyTest":

				pending.addUserPropertyTest( form.actionPath );

			break;
			case "addValue":

				pending.addValue( form.actionPath );

			break;
			case "moveRuleUp":

				pending.moveRuleUp( form.actionIndex );

			break;
			case "newRule":

				pending.addRule();

			break;
			case "removeRule":

				pending.removeRule( form.actionIndex );

			break;
			case "removeTest":

				pending.removeTest( form.actionPath, form.actionIndex );

			break;
			case "removeValue":

				pending.removeValue( form.actionPath, form.actionIndex );

			break;
			case "save":

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

				application.featureFlagService.updateFeatureFlagTargeting(
					key = featureFlag.key,
					rules = preparedData.rules,
					fallthroughVariantRef = preparedData.fallthroughVariantRef,
					isEnabled = preparedData.isEnabled
				);

				location( url = "/admin/index.cfm?dataChanged=true", addToken = false );

			break;
			case "switchRolloutToMulti":

				pending.switchRolloutToMulti( form.actionPath );

			break;
			case "switchRolloutToSingle":

				pending.switchRolloutToSingle( form.actionPath );

			break;
		}

	} catch ( any error ) {

		errorMessage = application.errorService.getResponse( error ).message;

	}

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	enabledOptions = [
		{ value: true, label: "Enabled" },
		{ value: false, label: "Disabled" }
	];

	operatorOptions = [
		{ value: "OneOf", label: "Is One Of" },
		{ value: "NotOneOf", label: "Is Not One Of" },
		{ value: "EndsWith", label: "Ends With" },
		{ value: "NotEndsWith", label: "Does Not End With" },
		{ value: "StartsWith", label: "Starts With" },
		{ value: "NotStartsWith", label: "Does Not Start With" },
		{ value: "Contains", label: "Contains Substring" },
		{ value: "NotContains", label: "Does Not Contain Substring" },
		{ value: "GreaterThan", label: "Is Greater Than" },
		{ value: "LessThan", label: "Is Less Than" },
		{ value: "MatchesRegex", label: "Matches Regular Expression" },
		{ value: "NotMatchesRegex", label: "Does Not Match Regular Expression" }
	];

	percentOptions = [];

	for ( i = 0 ; i <= 100 ; i++ ) {

		percentOptions.append({
			value: i,
			label: "#i#%"
		});

	}

	variantRefOptions = featureFlag.variants.map(
		( value, i ) => {

			return({
				value: i,
				label: serializeJson( value )
			});

		}
	);

	// To make it easier to render the form inputs let's get a direct reference to the
	// pending form data structure. There's no benefit to going through the "pending"
	// component if we're not going to be manipulating abstract object paths.
	data = pending.data;

</cfscript>
<cfmodule template="/templates/layout.cfm" title="Feature Flag Targeting">
<cfoutput>

	<cfif errorMessage.len()>

		<div class="error-message">
			#encodeForHtml( errorMessage )#
		</div>

	</cfif>

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

		<div class="entry">
			<label class="entry__label">
				Targeting:
			</label>
			<div class="entry__body">

				<select name=".isEnabled">
					<cfloop item="option" array="#enabledOptions#">
						<option
							value="#encodeForHtmlAttribute( option.value )#"
							<cfif ( data.isEnabled == option.value )>selected</cfif>>
							#encodeForHtml( option.label )#
						</option>
					</cfloop>
				</select>

			</div>
		</div>
		<div class="entry">
			<label class="entry__label">
				Fall-through Variation
			</label>
			<div class="entry__body">

				<select name=".fallthroughVariantRef">
					<cfloop item="option" array="#variantRefOptions#">
						<option
							value="#encodeForHtmlAttribute( option.value )#"
							<cfif ( data.fallthroughVariantRef == option.value )>selected</cfif>>
							#encodeForHtml( option.label )#
						</option>
					</cfloop>
				</select>

			</div>
		</div>

		<h2>
			Rules
		</h2>

		<cfloop index="ruleIndex" item="rule" array="#data.rules#">

			<div class="rule">

				<h3>
					Rule #ruleIndex#
				</h3>

				<h4>
					Tests
				</h4>

				<cfif ! rule.tests.len()>
					<p class="no-tests">
						<strong>CAUTION:</strong> At this time, there are no tests.
						<strong>All users</strong> will match this rule.
					</p>
				</cfif>

				<cfloop index="testIndex" item="test" array="#rule.tests#">

					<div class="test">

						<div class="flex-bar">

							<cfif ( test.type == "UserKey" )>
								<input type="text" value="key" readonly size="15" />
							<cfelse>
								<input
									type="text"
									name=".rules.#ruleIndex#.tests.#testIndex#.userProperty"
									value="#encodeForHtmlAttribute( test.userProperty )#"
									placeholder="User Property..."
									size="15"
								/>
							</cfif>

							<select name=".rules.#ruleIndex#.tests.#testIndex#.operation.operator">
								<cfloop item="option" array="#operatorOptions#">
									<option
										value="#encodeForHtmlAttribute( option.value )#"
										<cfif ( test.operation.operator == option.value )>selected</cfif>>
										#encodeForHtml( option.label )#
									</option>
								</cfloop>
							</select>

							<input
								type="text"
								name=".rules.#ruleIndex#.tests.#testIndex#.operation.newValue"
								value=""
								size="10"
								x-enter-action="addValue : rules.#ruleIndex#.tests.#testIndex#.operation"
							/>

							<button
								type="submit"
								name="action"
								value="addValue : rules.#ruleIndex#.tests.#testIndex#.operation">
								Add Value
							</button>

							<button
								type="submit"
								name="action"
								value="removeTest : rules.#ruleIndex#.tests : #testIndex#">
								Remove Test
							</button>

						</div>

						<cfif test.operation.values.len()>
							<ul>
								<cfloop index="valueIndex" item="value" array="#test.operation.values#">
									<li>
										#encodeForHtml( value )#
										&mdash;
										<button
											type="submit"
											name="action"
											value="removeValue : rules.#ruleIndex#.tests.#testIndex#.operation.values : #valueIndex#"
											class="remove">
											Remove value
										</button>
									</li>
								</cfloop>
							</ul>
						</cfif>

					</div>

				</cfloop>

				<div class="button-bar">
					<button
						type="submit"
						name="action"
						value="addUserKeyTest : rules.#ruleIndex#.tests">
						Add User Key Test
					</button>
					<button
						type="submit"
						name="action"
						value="addUserPropertyTest : rules.#ruleIndex#.tests">
						Add User Property Test
					</button>
				</div>

				<hr />

				<h4>
					Rollout
				</h4>

				<cfif ( rule.rollout.type == "Single" )>

					<p>
						<select name=".rules.#ruleIndex#.rollout.variantRef">
							<cfloop item="option" array="#variantRefOptions#">
								<option
									value="#encodeForHtmlAttribute( option.value )#"
									<cfif ( rule.rollout.variantRef == option.value )>selected</cfif>>
									#encodeForHtml( option.label )#
								</option>
							</cfloop>
						</select>
					</p>

				</cfif>

				<cfif ( rule.rollout.type == "Multi" )>

					<ul>
						<cfloop index="portionIndex" item="portion" array="#rule.rollout.distribution#">
							<li>
								<select name=".rules.#ruleIndex#.rollout.distribution.#portionIndex#.percent">
									<cfloop item="option" array="#percentOptions#">
										<option
											value="#encodeForHtmlAttribute( option.value )#"
											<cfif ( portion.percent == option.value )>selected</cfif>>
											#encodeForHtml( option.label )#
										</option>
									</cfloop>
								</select>
								&rarr;
								#serializeJson( featureFlag.variants[ portion.variantRef ] )#
							</li>
						</cfloop>
					</ul>

				</cfif>

				<div class="button-bar">
					<cfif ( rule.rollout.type == "Single" )>
						<button
							type="submit"
							name="action"
							value="switchRolloutToMulti : rules.#ruleIndex#">
							Switch to Multi
						</button>
					<cfelse>
						<button
							type="submit"
							name="action"
							value="switchRolloutToSingle : rules.#ruleIndex#">
							Switch to Single
						</button>
					</cfif>
				</div>

				<hr />

				<div class="button-bar">
					<cfif ( ruleIndex gt 1 )>
						<button
							type="submit"
							name="action"
							value="moveRuleUp : _ : #ruleIndex#">
							Move Rule UP
						</button>
					</cfif>

					<button
						type="submit"
						name="action"
						value="removeRule : _ : #ruleIndex#">
						Remove Rule
					</button>
				</div>

			</div>

		</cfloop>

		<div class="button-bar">
			<button type="submit" name="action" value="newRule">
				Add Rule
			</button>
		</div>

		<div class="button-bar button-bar--primary">
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
		setupXEnterActions();
	</script>

</cfoutput>
</cfmodule>
