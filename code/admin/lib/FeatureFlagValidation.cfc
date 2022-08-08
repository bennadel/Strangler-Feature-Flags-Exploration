component
	output = false
	hint = "I provide validation methods for the feature flag inputs."
	{

	/**
	* I test the given description.
	*/
	public void function testDescription( required string description ) {

		if ( description.len() > 300 ) {

			throw(
				type = "FeatureFlag.Description.TooLong",
				message = "FeatureFlag description is too long.",
				extendedInfo = serializeJson({
					value: description.len(),
					maxLength: 300
				})
			);

		}

	}


	/**
	* I test the given fall-through variantRef.
	*/
	public void function testFallthroughVariantRef(
		required array variants,
		required numeric fallthroughVariantRef
		) {

		if ( ! variants.isDefined( fallthroughVariantRef ) ) {

			throw(
				type = "FeatureFlag.FallthroughVariantRef.OutOfBounds",
				message = "FeatureFlag fall-through variant ref does not match a defined variant.",
				extendedInfo = serializeJson({
					value: fallthroughVariantRef,
					range: "1..#variants.len()#"
				})
			);

		}

	}


	/**
	* I test the given key.
	*/
	public void function testKey( required string key ) {

		if ( ! key.len() ) {

			throw(
				type = "FeatureFlag.Key.Empty",
				message = "FeatureFlag key cannot be empty."
			);

		}

		if ( key.len() > 50 ) {

			throw(
				type = "FeatureFlag.Key.TooLong",
				message = "FeatureFlag key is too long.",
				extendedInfo = serializeJson({
					value: key.len(),
					maxLength: 50
				})
			);

		}

	}


	/**
	* I test the given multi-rollout against the given variants. 
	*/
	public void function testMultiRollout(
		required array variants,
		required struct rollout
		) {

		ensureProperty( "FeatureFlag.Rule.Rollout", rollout, "distribution", "array" );

		var percentTotal = 0;

		for ( var portion in rollout.distribution ) {

			testMultiRolloutPortion( variants, portion );

			percentTotal += portion.percent;

		}

		if ( percentTotal != 100 ) {

			throw(
				type = "FeatureFlag.Rule.Rollout.PercentTotal.Invalid",
				message = "FeatureFlag multi-rollout percent total must be 100.",
				extendedInfo = serializeJson({
					value: percentTotal
				})
			);

		}

	}


	/**
	* I test the given multi-rollout portion against the given variants. 
	*/
	public void function testMultiRolloutPortion(
		required array variants,
		required struct portion
		) {

		ensureProperty( "FeatureFlag.Rule.Rollout.Distribution", portion, "variantRef", "integer" );
		ensureProperty( "FeatureFlag.Rule.Rollout.Distribution", portion, "percent", "integer" );

		if ( ! variants.isDefined( portion.variantRef ) ) {

			throw(
				type = "FeatureFlag.Rule.Rollout.Distribution.VariantRef.OutOfBounds",
				message = "Multi-rollout variant ref does not match a defined variant.",
				extendedInfo = serializeJson({
					value: portion.variantRef,
					range: "1..#variants.len()#"
				})
			);

		}

		if ( ( portion.percent < 0 ) || ( portion.percent > 100 ) ) {

			throw(
				type = "FeatureFlag.Rule.Rollout.Distribution.Percent.Invalid",
				message = "Multi-rollout percent portion must be between 0 and 100.",
				extendedInfo = serializeJson({
					value: portion.percent
				})
			);

		}

	}


	/**
	* I test the given name.
	*/
	public void function testName( required string name ) {

		if ( ! name.len() ) {

			throw(
				type = "FeatureFlag.Name.Empty",
				message = "FeatureFlag name cannot be empty."
			);

		}

		if ( name.len() > 50 ) {

			throw(
				type = "FeatureFlag.Name.TooLong",
				message = "FeatureFlag name is too long.",
				extendedInfo = serializeJson({
					value: name.len(),
					maxLength: 50
				})
			);

		}

	}


	/**
	* I test the given rollout against the given variants. 
	*/
	public void function testRollout(
		required array variants,
		required struct rollout
		) {

		ensureProperty( "FeatureFlag.Rule.Rollout", rollout, "type", "string" );

		switch ( rollout.type ) {
			case "Multi":
				testMultiRollout( variants, rollout );
			break;
			case "Single":
				testSingleRollout( variants, rollout );
			break;
			default:
				throw(
					type = "FeatureFlag.Rule.Rollout.Type.NotSupported",
					message = "FeatureFlag rollout type is not supported.",
					extendedInfo = serializeJson({
						value: rollout.type
					})
				);
			break;
		}

	}


	/**
	* I test the given rule against the given variants.
	*/
	public void function testRule(
		required array variants,
		required struct rule
		) {

		ensureProperty( "FeatureFlag.Rule", rule, "tests", "array" );
		ensureProperty( "FeatureFlag.Rule", rule, "rollout", "struct" );

		testTests( rule.tests );
		testRollout( variants, rule.rollout );

	}


	/**
	* I test the given rules against the given variants.
	*/
	public void function testRules(
		required array variants,
		required array rules
		) {

		for ( var rule in rules ) {

			testRule( variants, rule );

		}

	}


	/**
	* I test the given single-rollout against the given variants. 
	*/
	public void function testSingleRollout(
		required array variants,
		required struct rollout
		) {

		ensureProperty( "FeatureFlag.Rule.Rollout", rollout, "variantRef", "integer" );

		if ( ! variants.isDefined( rollout.variantRef ) ) {

			throw(
				type = "FeatureFlag.Rule.Rollout.VariantRef.OutOfBounds",
				message = "Single-rollout variant ref does not match a defined variant.",
				extendedInfo = serializeJson({
					value: rollout.variantRef,
					range: "1..#variants.len()#"
				})
			);

		}

	}


	/**
	* I test the given test.
	*/
	public void function testTest( required struct test ) {

		ensureProperty( "FeatureFlag.Rule.Test", test, "type", "string" );

		switch ( test.type ) {
			case "UserKey":
				testUserKeyTest( test );
			break;
			case "UserProperty":
				testUserPropertyTest( test );
			break;
			default:
				throw(
					type = "FeatureFlag.Rule.Test.Type.NotSupported",
					message = "FeatureFlag test type is not supported.",
					extendedInfo = serializeJson({
						value: test.type
					})
				);
			break;
		}

	}


	/**
	* I test the given operation.
	*/ 
	public void function testTestOperation( required struct operation ) {

		ensureProperty( "FeatureFlag.Rule.Test.Operation", operation, "operator", "string" );
		ensureProperty( "FeatureFlag.Rule.Test.Operation", operation, "values", "array" );

		testTestOperator( operation.operator );

		for ( var value in operation.values ) {

			if ( ! isSimpleValue( value ) ) {

				throw(
					type = "FeatureFlag.Rule.Test.Operation.Value.NotSupported",
					message = "FeatureFlag operands must be simple values.",
					extendedInfo = serializeJson({
						operator: operation.operator
					})
				);

			}

		}

	}


	/**
	* I test the given operator.
	*/
	public void function testTestOperator( required string operator ) {

		switch ( operator ) {
			case "Contains":
			case "EndsWith":
			case "GreaterThan":
			case "LessThan":
			case "MatchesRegex":
			case "NotContains":
			case "NotEndsWith":
			case "NotMatchesRegex":
			case "NotOneOf":
			case "NotStartsWith":
			case "OneOf":
			case "StartsWith":
				return;
			break;
			default:
				throw(
					type = "FeatureFlag.Rule.Test.Operation.Operator.NotSupported",
					message = "FeatureFlag test operator not supported.",
					extendedInfo = serializeJson({
						value: operator,
						expects: [ "Contains", "EndsWith", "GreaterThan", "LessThan", "MatchesRegex", "NotContains", "NotEndsWith", "NotMatchesRegex", "NotOneOf", "NotStartsWith", "OneOf", "StartsWith" ]
					})

				);
			break;
		}

	}


	/**
	* I test the given tests.
	*/
	public void function testTests( required array tests ) {

		for ( var test in tests ) {

			testTest( test );

		}

	}


	/**
	* I test the given variant type.
	*/
	public void function testType( required string type ) {

		switch ( type ) {
			case "Any":
			case "Boolean":
			case "Numeric":
			case "String":
				return;
			break;
			default:
				throw(
					type = "FeatureFlag.Type.NotSupported",
					message = "FeatureFlag type is not supported.",
					extendedInfo = serializeJson({
						value: type,
						expects: [ "Boolean", "Numeric", "String", "Any" ]
					})
				);
			break;
		}

	}


	/**
	* I test the given user-key test.
	*/
	public void function testUserKeyTest( required struct test ) {

		ensureProperty( "FeatureFlag.Rule.Test", test, "operation", "struct" );

		testTestOperation( test.operation );

	}


	/**
	* I test the given user-property test.
	*/
	public void function testUserPropertyTest( required struct test ) {

		ensureProperty( "FeatureFlag.Rule.Test", test, "userProperty", "string" );
		ensureProperty( "FeatureFlag.Rule.Test", test, "operation", "struct" );

		if ( ! test.userProperty.len() ) {

			throw(
				type = "FeatureFlag.Rule.Test.UserProperty.Empty",
				message = "FeatureFlag user property cannot be empty."
			);

		}

		testTestOperation( test.operation );

	}


	/**
	* I test the given variant against the given type.
	*/
	public void function testVariant(
		required string type,
		required any variant
		) {

		// If the type is "any", then the value has to be serializable. The only way to
		// verify this is to try and serialize the value and see if we get an error.
		if ( type == "Any" ) {

			try {

				serializeJson( variant );
				return;

			} catch ( any error ) {

				throw(
					type = "FeatureFlag.Variant.NotSerializable",
					message = "Variant value of type [Any] cannot be serialized."
				);

			}
			
		}

		// CAUTION: Since ColdFusion auto-casts values on-the-fly, the following checks
		// really only determine if the given variant can be cast to the given type - it
		// doesn't really ensure that the variant is the correct NATIVE type. As such,
		// variant values should be explicitly cast to the correct NATIVE type during data
		// persistence.
		if (
			( ( type == "Boolean" ) && isBoolean( variant ) ) ||
			( ( type == "Numeric" ) && isNumeric( variant ) ) ||
			( ( type == "String" ) && isValid( "string", variant ) )
			) {

			return;

		}

		var variantValue = isSimpleValue( variant )
			? variant
			: "{Complex Object}"
		;

		throw(
			type = "FeatureFlag.Variant.IncorrectType",
			message = "Variant value does not match feature flag type.",
			extendedInfo = serializeJson({
				value: variantValue,
				expects: type
			})
		);

	}


	/**
	* I test the given variants against the given type.
	*/
	public void function testVariants(
		required string type,
		required array variants
		) {

		for ( var variant in variants ) {

			testVariant( type, variant );

		}

	}


	/**
	* I throw a not-found error for the given key.
	*/
	public void function throwNotFoundError( required string key ) {

		throw(
			type = "FeatureFlag.NotFound",
			message = "Feature flag with key not found.",
			extendedInfo = serializeJson({
				value: key
			})
		);

	}

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I use the isValid() built-in function to ensure that the given property exists and
	* is of the expected type.
	*/
	private void function ensureProperty(
		required string containerPath,
		required struct container,
		required string propertyName,
		required string propertyType
		) {

		if ( ! isKeyInStructWithCase( container, propertyName ) ) {

			throw(
				type = "#containerPath#.#ucfirst( propertyName )#.Missing",
				message = "FeatureFlag is missing a required property.",
				extendedInfo = serializeJson({
					value: propertyName
				})
			);

		}

		if ( ! isValid( propertyType, container[ propertyName ] ) ) {

			throw(
				type = "#containerPath#.#ucfirst( propertyName )#.IncorrectType",
				message = "FeatureFlag property is an incorrect type.",
				extendedInfo = serializeJson({
					value: container[ propertyName ],
					type: propertyType
				})
			);

		}

	}


	/**
	* I determine if the given key exists in the given struct using the given key-casing.
	*/
	private boolean function isKeyInStructWithCase(
		required struct targetContrainer,
		required string targetKey
		) {

		if ( ! targetContrainer.keyExists( targetKey ) ) {

			return( false );

		}

		// Since ColdFusion structs are inherently case-INSENSITIVE, just because the key
		// exists is in the struct, it doesn't mean that it is the "right key". As such,
		// we have to iterate over the struct keys and check them by-case.
		// --
		// NOTE: In Adobe ColdFusion, we could have used the structGetMetaData() function
		// for this. But, at this time, Lucee does not support this method. As such, we
		// have to brute force-it.
		for ( var key in targetContrainer.keyArray() ) {

			if ( ! compare( key, targetKey ) ) {

				return( true );

			}

		}

		return( false );

	}

}
