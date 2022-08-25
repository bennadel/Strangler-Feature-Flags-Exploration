
// Import core angular modules.
import { enableProdMode } from "@angular/core";
import { platformBrowserDynamic } from "@angular/platform-browser-dynamic";

// Import application modules.
import { AppModule } from "./app/app.module";
import { environment } from "./environments/environment";

// ----------------------------------------------------------------------------------- //
// ----------------------------------------------------------------------------------- //

if ( environment.production ) {

	enableProdMode();

}

platformBrowserDynamic()
	.bootstrapModule( AppModule )
	.catch(
		( error ) => {

			console.error( error );

		}
	)
;
