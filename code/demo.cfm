<cfscript>


</cfscript>
<cfcontent type="text/html; charset=utf-8" />
<cfoutput>

	<!doctype html>
	<html lang="en">
	<head>
		<meta charset="utf-8" />
		<meta name="viewport" content="width=device-width, initial-scale=1">
	</head>
	<body>

		<h1>
			Feature Flag Demo
		</h1>

		Hello, demo &mdash; #now()#

		<!---
			When the Admin updates the feature flag data, it posts a message over to this
			demo frame letting us know. When that happens, let's refresh the page
			automatically in order to bring in the latest targeting rules.
		--->
		<script type="text/javascript">

			window.top.addEventListener(
				"message",
				function handleMessage( event ) {

					if ( event.origin !== window.top.location.origin ) {

						return;

					}

					if ( event.data === "adminReloaded" ) {

						window.self.location.reload();

					}

				}
			);

		</script>
	
	</body>
	</html>

</cfoutput>
