component
	extends = "lib.BasePendingForm"
	output = false
	hint = "I provide methods for manipulating the pending feature flag data in a form."
	{

	/**
	* I initialize the pending form data with the given default structure.
	*/
	public void function init(
		required struct formScope, 
		required struct featureFlag
		) {

		super.init( formScope, "data", duplicate( featureFlag ) );

		variables.featureFlag = arguments.featureFlag;

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I add a new rule with no tests.
	*/
	public void function addRule() {

		this.data.rules.push([
			tests: [],
			rollout: [
				type: "Single",
				variantRef: 1
			]
		]);

	}


	/**
	* I add a new user-key test to the given tests collection.
	*/
	public void function addUserKeyTest( required string testsPath ) {

		getValue( testsPath ).append([
			type: "UserKey",
			operation: [
				operator: "OneOf",
				values: []
			]
		]);

	}


	/**
	* I add a new user-property test to the given tests collection.
	*/
	public void function addUserPropertyTest( required string testsPath ) {

		getValue( testsPath ).append([
			type: "UserProperty",
			userProperty: "",
			operation: [
				operator: "OneOf",
				values: []
			]
		]);

	}


	/**
	* I add a new target value to the given test operation.
	*/
	public void function addValue( required string operationPath ) {

		var operation = getValue( operationPath );

		// CAUTION: The "newValue" property isn't a part of the native feature flag data
		// structure, but our pending form is using it to keep a different newValue
		// property per test operation. This won't be included when the form data is being
		// prepared for the subsequent save.
		if ( operation.newValue.len() ) {

			operation.values.append( operation.newValue );
			operation.delete( "newValue" );
			operation.values.sort( "textNoCase" );

		}

	}


	/**
	* I move the rule at the given index up in priority.
	*/
	public void function moveRuleUp( required numeric ruleIndex ) {

		this.data.rules.swap( ruleIndex, ( ruleIndex - 1 ) );

	}


	/**
	* The goal of this method is to take the STRING-BASED FORM DATA and coerce it into the
	* data-types expected by the application core. This allows us to (more) gracefully
	* handle very form-specific data-type conversions that would otherwise be rejected
	* with a more generic message by the application layer.
	* 
	* ASIDE: We only need to do this because we're using FORM POSTs to build-up the data.
	* If we were using an API and / or a rich-client (such as Angular) to build up a JSON
	* payload, we wouldn't have to do this transformation here in the Controller.
	*/
	public struct function prepareForSave() {

		var isEnabled = !! this.data.isEnabled;
		var fallthroughVariantRef = val( this.data.fallthroughVariantRef );
		var rules = prepareRulesForSave( this.data.rules );

		return([
			rules: rules,
			fallthroughVariantRef: fallthroughVariantRef,
			isEnabled: isEnabled
		]);

	}


	/**
	* I remove the rule at the given index.
	*/
	public void function removeRule( required numeric ruleIndex ) {

		this.data.rules.deleteAt( ruleIndex );

	}


	/**
	* I remove the test at the given index.
	*/
	public void function removeTest(
		required string testsPath,
		required numeric testIndex
		) {

		getValue( testsPath ).deleteAt( testIndex );

	}


	/**
	* I remove the target value at the given index.
	*/
	public void function removeValue(
		required string valuesPath,
		required numeric valueIndex
		) {

		getValue( valuesPath ).deleteAt( valueIndex );

	}


	/**
	* I change the given rule to use a multi-value / weighted rollout.
	*/
	public void function switchRolloutToMulti( required string rulePath ) {

		getValue( rulePath ).rollout = [
			type: "Multi",
			distribution: featureFlag.variants.map(
				( variant, i ) => {

					// By default, let's give the entirety of the initial distribution to
					// the first variant. Then, the user can re-distribute the variants.
					var percent = ( i == 1 )
						? 100
						: 0
					;

					return([
						percent: percent,
						variantRef: i
					]);

				}
			)
		];

	}


	/**
	* I change the given rule to use a single-value rollout.
	*/
	public void function switchRolloutToSingle( required string rulePath ) {

		getValue( rulePath ).rollout = [
			type: "Single",
			variantRef: 1
		];

	}

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I prepare the given rollout strategy for data persistence.
	*/
	private struct function prepareRolloutForSave( required struct rawRollout ) {

		if ( rawRollout.type == "Single" ) {

			return([
				type: rawRollout.type,
				variantRef: val( rawRollout.variantRef )
			]);

		} else {

			return([
				type: rawRollout.type,
				distribution: rawRollout.distribution.map(
					( portion ) => {

						return([
							percent: val( portion.percent ),
							variantRef: val( portion.variantRef )
						]);

					}
				)
			]);

		}

	}


	/**
	* I prepare the given rule for data persistence.
	*/
	private struct function prepareRuleForSave( required struct rawRule ) {

		return([
			tests: prepareTestsForSave( rawRule.tests ),
			rollout: prepareRolloutForSave( rawRule.rollout )
		]);

	}


	/**
	* I prepare the given rules for data persistence.
	*/
	private array function prepareRulesForSave( required array rawRules ) {

		return( rawRules.map( prepareRuleForSave ) );

	}


	/**
	* I prepare the given test for data persistence.
	*/
	private struct function prepareTestForSave( required struct rawTest ) {

		if ( rawTest.type == "UserKey" ) {

			return([
				type: rawTest.type,
				operation: [
					operator: rawTest.operation.operator,
					values: rawTest.operation.values
				]
			]);

		} else {

			return([
				type: rawTest.type,
				userProperty: rawTest.userProperty,
				operation: [
					operator: rawTest.operation.operator,
					values: rawTest.operation.values
				]
			]);

		}

	}


	/**
	* I prepare the given tests for data persistence.
	*/
	private array function prepareTestsForSave( required array rawTests ) {

		return( rawTests.map( prepareTestForSave ) );

	}

}
