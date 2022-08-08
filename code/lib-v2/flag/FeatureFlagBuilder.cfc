component
	output = false
	hint = ""
	{

	// ---
	// PUBLIC METHODS.
	// ---

	public com.bennadel.strangler.flag.FeatureFlag function build(
		required string key,
		required string name,
		required string description,
		required string variantType,
		required array variants,
		required array rules,
		required numeric fallthroughVariantRef,
		required boolean isEnabled
		) {

		var featureFlag = new FeatureFlag(
			key = key,
			name = name,
			description = description,
			variantType = variantType,
			variants = buildVariants( variantType, variants ),
			rules = buildRules( rules ),
			fallthroughVariantRef = fallthroughVariantRef,
			isEnabled = isEnabled
		);

		return( featureFlag );

	}

	// ---
	// PRIVATE METHODS.
	// ---

	private com.bennadel.strangler.flag.interfaces.Rollout function buildRollout( required struct rawRollout ) {

		if ( rawRollout.type == "Single" ) {

			return( new rollouts.SingleVariantRollout( rawRollout.variantRef ) );

		}

		return( new rollouts.MultiVariantRollout( rawRollout.variantRefs ) );

	}


	private array function buildRules( required array rawRules ) {

		var rules = rawRules.map(
			( rawRule ) => {

				return(
					new com.bennadel.strangler.flag.Rule(
						buildTests( rawRule.tests ),
						buildRollout( rawRule.rollout )
					)
				);

			}
		);

		return( rules );

	}


	private com.bennadel.strangler.flag.interfaces.Test function buildTest( required struct rawTest ) {

		switch ( rawTest.operation.operator ) {
			case "Contains":
				var operator = new com.bennadel.strangler.flag.operators.ContainsOperator( rawTest.operation.values );
			break;
			case "EndsWith":
				var operator = new com.bennadel.strangler.flag.operators.EndsWithOperator( rawTest.operation.values );
			break;
			case "GreaterThan":
				var operator = new com.bennadel.strangler.flag.operators.GreaterThanOperator( rawTest.operation.values );
			break;
			case "LessThan":
				var operator = new com.bennadel.strangler.flag.operators.LessThanOperator( rawTest.operation.values );
			break;
			case "MatchesRegex":
				var operator = new com.bennadel.strangler.flag.operators.MatchesRegexOperator( rawTest.operation.value );
			break;
			case "NotContains":
				var operator = new com.bennadel.strangler.flag.operators.NotContainsOperator( rawTest.operation.values );
			break;
			case "NotEndsWith":
				var operator = new com.bennadel.strangler.flag.operators.NotEndsWithOperator( rawTest.operation.values );
			break;
			case "NotMatchesRegex":
				var operator = new com.bennadel.strangler.flag.operators.NotMatchesRegexOperator( rawTest.operation.value );
			break;
			case "NotOneOf":
				var operator = new com.bennadel.strangler.flag.operators.NotOneOfOperator( rawTest.operation.values );
			break;
			case "NotStartsWith":
				var operator = new com.bennadel.strangler.flag.operators.NotStartsWithOperator( rawTest.operation.values );
			break;
			case "OneOf":
				var operator = new com.bennadel.strangler.flag.operators.OneOfOperator( rawTest.operation.values );
			break;
			case "StartsWith":
				var operator = new com.bennadel.strangler.flag.operators.StartsWithOperator( rawTest.operation.values );
			break;
			default:
				throw( type = "Strangler.FeatureFlagBuilder.InvalidOperator" );
			break;
		}

		switch ( rawTest.type ) {
			case "UserKey":
				return( new com.bennadel.strangler.flag.tests.UserKeyTest( operator ) );
			break;
			case "UserProperty":
				return( new com.bennadel.strangler.flag.tests.UserPropertyTest( rawTest.userProperty, operator ) );
			break;
			default:
				throw( type = "Strangler.FeatureFlagBuilder.InvalidTestType" );
			break;
		}

	}


	private array function buildTests( required array rawTests ) {

		var tests = rawTests.map(
			( rawTest ) => {

				return( buildTest( rawTest ) );

			}
		);

		return( tests );

	}


	private array function buildVariants(
		required string variantType,
		required array rawVariants
		) {

		var variants = rawVariants.map(
			( rawVariant ) => {

				return( new Variant( variantType, rawVariant ) );

			}
		);

		return( variants );

	}

}
