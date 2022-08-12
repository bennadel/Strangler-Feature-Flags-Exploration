/**
* NOTE: I do NOT LOVE the names of the methods in this component. A feature flag is
* represented by a complex data structure that includes arrays and nested structures. I
* needed to come up with names of methods that validate specific branches of this object
* complex object graph. I didn't have a nice way to do this; so, I just brute-forced it by
* using names that reflected the PATH of the target value within the overall object graph.
*/
component
	output = false
	hint = "I provide validation methods for the feature flag inputs."
	{

	/**
	* I test the given description.
	*/
	public string function testDescription( required string description ) {

		description = canonicalizeInput( description );

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

		return( description );

	}


	/**
	* I test the given fall-through variantRef.
	*/
	public numeric function testFallthroughVariantRef(
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

		return( val( fallthroughVariantRef ) );

	}


	/**
	* I test the given enabled flag.
	*/
	public boolean function testIsEnabled( required boolean isEnabled ) {

		return( !! isEnabled );

	}


	/**
	* I test the given key.
	*/
	public string function testKey( required string key ) {

		key = canonicalizeInput( key );

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

		return( key );

	}


	/**
	* I test the given name.
	*/
	public string function testName( required string name ) {

		name = canonicalizeInput( name );

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

		return( name );

	}


	/**
	* I test the given rules against the given variants.
	*/
	public array function testRules(
		required array variants,
		required array rules
		) {

		rules = rules.map(
			( rule ) => {

				return( testRulesX( variants, rule ) );

			}
		);

		return( rules );

	}


	/**
	* I test the given rule against the given variants.
	*/
	public struct function testRulesX(
		required array variants,
		required struct rule
		) {

		ensureProperty( "FeatureFlag.Rule", rule, "tests", "array" );
		ensureProperty( "FeatureFlag.Rule", rule, "rollout", "struct" );

		return([
			tests: testRulesXTests( rule.tests ),
			rollout: testRulesXRollout( variants, rule.rollout )
		]);

	}





	/**
	* I test the given rollout against the given variants.
	*/
	public struct function testRulesXRollout(
		required array variants,
		required struct rollout
		) {

		ensureProperty( "FeatureFlag.Rule.Rollout", rollout, "type", "string" );

		switch ( rollout.type ) {
			case "Multi":
				return( testRulesXRolloutAsMulti( variants, rollout ) );
			break;
			case "Single":
				return( testRulesXRolloutAsSingle( variants, rollout ) );
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
	* I test the given multi-rollout against the given variants.
	*/
	public struct function testRulesXRolloutAsMulti(
		required array variants,
		required struct rollout
		) {

		ensureProperty( "FeatureFlag.Rule.Rollout", rollout, "distribution", "array" );

		return([
			type: "Multi",
			distribution: testRulesXRolloutAsMultiDistribution( variants, rollout.distribution )
		]);

	}


	/**
	* I test the given multi-rollout distribution against the given variants.
	*/
	public array function testRulesXRolloutAsMultiDistribution(
		required array variants,
		required array distribution
		) {

		var percentTotal = 0;
		var distribution = distribution.map(
			( portion ) => {

				percentTotal += portion.percent;

				return( testRulesXRolloutAsMultiDistributionX( variants, portion ) );

			}
		);

		if ( percentTotal != 100 ) {

			throw(
				type = "FeatureFlag.Rule.Rollout.PercentTotal.Invalid",
				message = "FeatureFlag multi-rollout percent total must be 100.",
				extendedInfo = serializeJson({
					value: percentTotal
				})
			);

		}

		return( distribution );

	}


	/**
	* I test the given multi-rollout portion against the given variants.
	*/
	public struct function testRulesXRolloutAsMultiDistributionX(
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

		return([
			variantRef: val( portion.variantRef ),
			percent: val( portion.percent )
		]);

	}


	/**
	* I test the given single-rollout against the given variants.
	*/
	public struct function testRulesXRolloutAsSingle(
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

		return([
			type: "Single",
			variantRef: val( rollout.variantRef )
		]);

	}


	/**
	* I test the given tests.
	*/
	public array function testRulesXTests( required array tests ) {

		tests = tests.map(
			( test ) => {

				return( testRulesXTestsX( test ) );

			}
		);

		return( tests );

	}


	/**
	* I test the given test.
	*/
	public struct function testRulesXTestsX( required struct test ) {

		ensureProperty( "FeatureFlag.Rule.Test", test, "type", "string" );

		switch ( test.type ) {
			case "UserKey":
				return( testRulesXTestsXasUserKey( test ) );
			break;
			case "UserProperty":
				return( testRulesXTestsXasUserProperty( test ) );
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
	* I test the given user-key test.
	*/
	public struct function testRulesXTestsXasUserKey( required struct test ) {

		ensureProperty( "FeatureFlag.Rule.Test", test, "operation", "struct" );

		return([
			type: "UserKey",
			operation: testRulesXTestsXOperation( test.operation )
		]);

	}


	/**
	* I test the given user-property test.
	*/
	public struct function testRulesXTestsXasUserProperty( required struct test ) {

		ensureProperty( "FeatureFlag.Rule.Test", test, "userProperty", "string" );
		ensureProperty( "FeatureFlag.Rule.Test", test, "operation", "struct" );

		return([
			type: "UserProperty",
			userProperty: testRulesXTestsXasUserPropertyUserProperty( test.userProperty ),
			operation: testRulesXTestsXOperation( test.operation )
		]);

	}


	/**
	* I test the given user property.
	*/
	public string function testRulesXTestsXasUserPropertyUserProperty( required string userProperty ) {

		userProperty = canonicalizeInput( userProperty );

		if ( ! userProperty.len() ) {

			throw(
				type = "FeatureFlag.Rule.Test.UserProperty.Empty",
				message = "FeatureFlag user property cannot be empty."
			);

		}

		if ( userProperty.len() > 50 ) {

			throw(
				type = "FeatureFlag.Rule.Test.UserProperty.TooLong",
				message = "FeatureFlag user property too long.",
				extendedInfo = serializeJson({
					value: userProperty.len(),
					maxLength: 50
				})
			);

		}

		return( userProperty );

	}


	/**
	* I test the given operation.
	*/ 
	public struct function testRulesXTestsXOperation( required struct operation ) {

		ensureProperty( "FeatureFlag.Rule.Test.Operation", operation, "operator", "string" );
		ensureProperty( "FeatureFlag.Rule.Test.Operation", operation, "values", "array" );

		return([
			operator: testRulesXTestsXOperationOperator( operation.operator ),
			values: testRulesXTestsXOperationValues( operation.operator, operation.values )
		]);

	}


	/**
	* I test the given operation operator.
	*/
	public string function testRulesXTestsXOperationOperator( required string operator ) {

		operator = canonicalizeInput( operator );

		var validValues = [
			"Contains",
			"EndsWith",
			"GreaterThan",
			"LessThan",
			"MatchesRegex",
			"NotContains",
			"NotEndsWith",
			"NotMatchesRegex",
			"NotOneOf",
			"NotStartsWith",
			"OneOf",
			"StartsWith"
		];

		for ( var value in validValues ) {

			if ( value == operator ) {

				// NOTE: We are returning the internally-defined value in order to ensure
				// the appropriate character-casing on the persisted value.
				return( value );

			}

		}

		throw(
			type = "FeatureFlag.Rule.Test.Operation.Operator.NotSupported",
			message = "FeatureFlag test operator not supported.",
			extendedInfo = serializeJson({
				value: operator,
				expects: validValues
			})

		);

	}


	/**
	* I test the given operation values.
	*/
	public array function testRulesXTestsXOperationValues(
		required string operator,
		required array values
		) {

		values = values.map(
			( value ) => {

				if ( ! isSimpleValue( value ) ) {

					throw(
						type = "FeatureFlag.Rule.Test.Operation.Value.NotSupported",
						message = "FeatureFlag operands must be simple values."
					);

				}

				value = canonicalizeInput( value );

				return( value );

			}
		);

		// For RegularExpression-based operations, we need to confirm that each test value
		// can be compiled down to a Java RegEx Pattern instance.
		if (
			( operator == "MatchesRegex" ) ||
			( operator == "NotMatchesRegex" )
			) {

			for ( var value in values ) {

				try {

					createObject( "java", "java.util.regex.Pattern" )
						.compile( toString( value ) )
					;

				} catch ( any error ) {

					throw(
						type = "FeatureFlag.Rule.Test.Operation.Value.InvalidRegExPattern",
						message = "FeatureFlag operand cannot be compiled as a Java RegEx pattern.",
						extendedInfo = serializeJson({
							value: value
						})
					);

				}

			}

		}

		return( values );

	}


	/**
	* I test the given variant type.
	*/
	public string function testType( required string type ) {

		var validValues = [ "Any", "Boolean", "Numeric", "String" ];

		for ( var value in validValues ) {

			if ( value == type ) {

				// NOTE: We are returning the internally-defined value in order to ensure
				// the appropriate character-casing on the persisted value.
				return( value );

			}

		}

		throw(
			type = "FeatureFlag.Type.NotSupported",
			message = "FeatureFlag type is not supported.",
			extendedInfo = serializeJson({
				value: type,
				expects: validValues
			})
		);

	}


	/**
	* I test the given variants against the given type.
	*/
	public array function testVariants(
		required string type,
		required array variants
		) {

		variants = variants.map(
			( variant ) => {

				return( testVariantsX( type, variant ) );

			}
		);

		return( variants );

	}


	/**
	* I test the given variant against the given type.
	*/
	public any function testVariantsX(
		required string type,
		required any variant
		) {

		if ( ( type == "Boolean" ) && isBoolean( variant ) ) {

			return( !! variant );

		} else if ( ( type == "Numeric" ) && isNumeric( variant ) ) {

			return( val( variant ) );

		} else if ( ( type == "String" ) && isValid( "string", variant ) ) {

			return( toString( variant ) );

		} else if ( type == "Any" ) {

			// If the type is "any", then the value has to be serializable. The only way
			// to verify this is to try and serialize the variant and see if we get an
			// error.
			try {

				serializeJson( variant );
				return( variant );

			} catch ( any error ) {

				throw(
					type = "FeatureFlag.Variant.NotSerializable",
					message = "Variant value of type [Any] cannot be serialized."
				);

			}
				
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
	* I return the canonicalized version of the given input.
	*/
	private string function canonicalizeInput( required string input ) {

		input = input.trim();

		try {

			// NOTE: In earlier versions of Lucee, canonicalizing an empty string would
			// return NULL. As such, I'm using Elvis operator to always return a string.
			var cleanedInput = ( canonicalize( input, true, true ) ?: "" );

			// We don't just want to canonicalize the input, we want to block data that
			// changes due to the canonicalization process. This way, we can inform the
			// user about the issue rather than silently storing a value that differs from
			// the one that the user provided.
			if ( input != cleanedInput ) {

				throw( type = "InputMismatch" );

			}

			return( cleanedInput );

		} catch ( any error ) {

			throw(
				type = "FeatureFlag.MaliciousInput",
				message = "FeatureFlag contains suspicious encoding."
			);

		}

	}


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

		if ( ! container.keyExists( propertyName ) ) {

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

}
