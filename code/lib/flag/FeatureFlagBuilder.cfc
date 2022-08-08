component
	output = false
	hint = "I provide a way to construct a FeatureFlag instance from a set of raw data."
	{

	/**
	* I build a FeatureFlag from the given raw data.
	*/
	public any function build(
		required string key,
		required string name,
		required string description,
		required string type,
		required array variants,
		required array rules,
		required numeric fallthroughVariantRef,
		required boolean isEnabled
		) {

		var featureFlag = new FeatureFlag(
			key = key,
			name = name,
			description = description,
			type = type,
			variants = variants,
			rules = buildRules( rules ),
			fallthroughVariantRef = fallthroughVariantRef,
			isEnabled = isEnabled
		);

		return( featureFlag );

	}


	/**
	* I build a FeatureFlag from the given config.
	*/
	public any function fromConfig( required struct config ) {

		var featureFlag = build(
			key = config.key,
			name = config.name,
			description = config.description,
			type = config.type,
			variants = config.variants,
			rules = config.rules,
			fallthroughVariantRef = config.fallthroughVariantRef,
			isEnabled = config.isEnabled
		);

		return( featureFlag );

	}

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I build a Rollout from the given raw data.
	*/
	private any function buildRollout( required struct rawRollout ) {

		var rollout = ( rawRollout.type == "Single" )
			? new rollouts.SingleVariantRollout( rawRollout.variantRef )
			: new rollouts.MultiVariantRollout( rawRollout.distribution )
		;

		return( rollout );

	}


	/**
	* I build Rules from the given raw data.
	*/
	private array function buildRules( required array rawRules ) {

		var rules = rawRules.map(
			( rawRule ) => {

				var rule = new Rule(
					buildTests( rawRule.tests ),
					buildRollout( rawRule.rollout )
				);

				return( rule );

			}
		);

		return( rules );

	}


	/**
	* I build a Test from the given raw data.
	*/
	private any function buildTest( required struct rawTest ) {

		switch ( rawTest.operation.operator ) {
			case "Contains":
				var operator = new operators.ContainsOperator( rawTest.operation.values );
			break;
			case "EndsWith":
				var operator = new operators.EndsWithOperator( rawTest.operation.values );
			break;
			case "GreaterThan":
				var operator = new operators.GreaterThanOperator( rawTest.operation.values );
			break;
			case "LessThan":
				var operator = new operators.LessThanOperator( rawTest.operation.values );
			break;
			case "MatchesRegex":
				var operator = new operators.MatchesRegexOperator( rawTest.operation.value );
			break;
			case "NotContains":
				var operator = new operators.NotContainsOperator( rawTest.operation.values );
			break;
			case "NotEndsWith":
				var operator = new operators.NotEndsWithOperator( rawTest.operation.values );
			break;
			case "NotMatchesRegex":
				var operator = new operators.NotMatchesRegexOperator( rawTest.operation.value );
			break;
			case "NotOneOf":
				var operator = new operators.NotOneOfOperator( rawTest.operation.values );
			break;
			case "NotStartsWith":
				var operator = new operators.NotStartsWithOperator( rawTest.operation.values );
			break;
			case "OneOf":
				var operator = new operators.OneOfOperator( rawTest.operation.values );
			break;
			case "StartsWith":
				var operator = new operators.StartsWithOperator( rawTest.operation.values );
			break;
			default:
				throw( type = "Strangler.FeatureFlagBuilder.InvalidOperator" );
			break;
		}

		switch ( rawTest.type ) {
			case "UserKey":
				var test = new tests.UserKeyTest( operator );
			break;
			case "UserProperty":
				var test = new tests.UserPropertyTest( rawTest.userProperty, operator );
			break;
			default:
				throw( type = "Strangler.FeatureFlagBuilder.InvalidTestType" );
			break;
		}

		return( test );

	}


	/**
	* I build Tests from the given raw data.
	*/
	private array function buildTests( required array rawTests ) {

		var tests = rawTests.map(
			( rawTest ) => {

				return( buildTest( rawTest ) );

			}
		);

		return( tests );

	}

}
