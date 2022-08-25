
// Import core angular modules.
import { BrowserModule } from "@angular/platform-browser";
import { ErrorHandler } from "@angular/core";
import { FormsModule } from "@angular/forms";
import { HttpClientModule } from "@angular/common/http";
import { NgModule } from "@angular/core";
import { RouterModule } from "@angular/router";
import { Routes } from "@angular/router";

// Import application modules.
import { AppComponent } from "./app.component";
import { CreateViewComponent } from "./create-view/create-view.component";
import { DeleteViewComponent } from "./detail-view/delete-view/delete-view.component";
import { DetailViewComponent } from "./detail-view/detail-view.component";
import { ErrorMessageComponent } from "./shared/components/error-message/error-message.component";
import { ErrorService } from "./services/error.service";
import { InitialRenderDirective } from "./shared/directives/initial-render.directive";
import { LoaderComponent } from "./shared/components/loader/loader.component";
import { ListViewComponent } from "./list-view/list-view.component";
import { SettingsViewComponent } from "./detail-view/settings-view/settings-view.component";
import { TargetingViewComponent } from "./detail-view/targeting-view/targeting-view.component";

// ----------------------------------------------------------------------------------- //
// ----------------------------------------------------------------------------------- //

@NgModule({
	declarations: [
		AppComponent,
		CreateViewComponent,
		DeleteViewComponent,
		DetailViewComponent,
		ErrorMessageComponent,
		InitialRenderDirective,
		LoaderComponent,
		ListViewComponent,
		SettingsViewComponent,
		TargetingViewComponent
	],
	imports: [
		BrowserModule, // The browser module has to be imported first.
		FormsModule,
		HttpClientModule,
		RouterModule.forRoot(
			[
				{
					path: "",
					component: ListViewComponent
				},
				{
					path: "create",
					component: CreateViewComponent
				},
				{
					path: "feature-flag/:key",
					pathMatch: "prefix",
					component: DetailViewComponent,
					children: [
						{
							path: "",
							pathMatch: "full",
							redirectTo: "targeting"
						},
						{
							path: "delete",
							component: DeleteViewComponent
						},
						{
							path: "settings",
							component: SettingsViewComponent
						},
						{
							path: "targeting",
							component: TargetingViewComponent
						}
					]
				},
				{
					path: "**",
					redirectTo: "/"
				}
			],
			{
				useHash: true, // Use fragment-based routing, not push-state routing.
				paramsInheritanceStrategy: "always"
			}
		)
	],
	providers: [
		{
			provide: ErrorHandler,
			useClass: ErrorService
		}
	],
	bootstrap: [ AppComponent ]
})
export class AppModule {
	// ... 
}
