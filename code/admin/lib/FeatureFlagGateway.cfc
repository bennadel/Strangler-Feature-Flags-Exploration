component
	accessors = true
	output = false
	hint = "I provide storage methods for the feature flag data. This component uses file-based storage, and persists all flag data to a JSON file. Access to the data file is synchronized."
	{

	// Define properties for dependency-injection.
	property dataFilepath;

	/**
	* I initialize the gateway.
	*/
	public void function init() {

		variables.gson = buildGson();

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I delete the feature flag with the given key.
	*/
	public void function deleteFeatureFlagByKey( required string key ) {

		withExclusiveLock(
			() => {

				var data = loadData();

				if ( data.keyExists( key ) ) {

					data.delete( key );
					saveData( data );
					
				}

			}
		);

	}


	/**
	* I return the feature flags that match the given filters. 
	*/
	public array function getFeatureFlagsByFilter( string key ) {

		var data = withReadOnlyLock(
			() => {

				return( loadData() );

			}
		);

		var results = [];

		loop
			key = "local._"
			value = "local.value"
			struct = data
			{

			if ( arguments.keyExists( "key" ) && ( key != value.key ) ) {

				continue;

			}

			results.append( value );

		}

		return( results );

	}


	/**
	* I save the feature flag with the given key. Any existing key will be overwritten.
	*/
	public void function saveFeatureFlag(
		required string key,
		required string name,
		required string description,
		required string type,
		required array variants,
		required array rules,
		required numeric fallthroughVariantRef,
		required boolean isEnabled
		) {

		withExclusiveLock(
			() => {

				var data = loadData();

				data[ key ] = [
					key: key,
					name: name,
					description: description,
					type: type,
					variants: variants,
					rules: rules,
					fallthroughVariantRef: fallthroughVariantRef,
					isEnabled: isEnabled
				];

				saveData( data );

			}
		);

	}

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I build the GSON instance for data serialization (so that the .json file is pretty-
	* printed and easy to debug).
	*/
	private any function buildGson() {

		var jarPaths = [
			expandPath( "/vendor/gson-2.9.0/gson-2.9.0.jar")
		];
		var gson = createObject( "java", "com.google.gson.GsonBuilder", jarPaths )
			.init()
			.setPrettyPrinting()
			.create()
		;

		return( gson );

	}


	/**
	* I return the lock name for synchronizing access to the data file.
	*/
	private string function getFileLockName() {

		return( "FeatureFlagGateway.dataFilePath" );

	}


	/**
	* I return the lock timeout for synchronizing access to the data file.
	*/
	private numeric function getFileLockTimeout() {

		return( 5 );

	}


	/**
	* I load the feature flag data from disk.
	*/
	private struct function loadData() {

		return( deserializeJson( fileRead( dataFilePath, "utf-8" ) ) );

	}


	/**
	* I save the given feature flag data to disk.
	*/
	private void function saveData( required struct data ) {

		fileWrite( dataFilePath, gson.toJson( data ), "utf-8" );

	}


	/**
	* I execute the given callback once an exclusive lock has been acquired. The results
	* of the callback execution are returned.
	*/
	private any function withExclusiveLock( required function callback ) {

		lock
			type = "exclusive"
			name = getFileLockName()
			timeout = getFileLockTimeout()
			{

			return( callback() );

		}

	}


	/**
	* I execute the given callback once a read-only lock has been acquired. The results of
	* the callback execution are returned.
	*/
	private any function withReadOnlyLock( required function callback ) {

		lock
			type = "readonly"
			name = getFileLockName()
			timeout = getFileLockTimeout()
			{

			return( callback() );

		}

	}

}
