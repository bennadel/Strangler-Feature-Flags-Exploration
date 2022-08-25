
// Import core angular modules.
import { ErrorHandler } from "@angular/core";
import { Injectable } from "@angular/core";

// ----------------------------------------------------------------------------------- //
// ----------------------------------------------------------------------------------- //

@Injectable({
	providedIn: "root"
})
export class ErrorService implements ErrorHandler {

	/**
	* I attempt to extract the human-friendly error message from the given error. However,
	* since there are no guarantees as to where in the application this error was thrown,
	* we will have to do some introspection in order to find the most appropriate error
	* message property to display.
	*/
	public getMessage( error: any ) : string {

		if ( this.isApiClientError( error ) ) {

			return( error.data.message );

		}

		return( "Sorry, we could not process your request." );

	}


	/**
	* I determine if the given error LOOKS LIKE an API Client error.
	*/
	public isApiClientError( error: any ) : boolean {

		return( !! error?.isApiClientError );

	}


	/**
	* I provide a centralized location for logging errors in Angular.
	*/
	public handleError( error: any ) : void {

		// NOTE: In the future, this could ALSO be used to push the errors to a remote log
		// aggregation API end-point or service.
		console.error( error );

	}
	
}
