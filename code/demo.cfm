<cfscript>

	users = [
		{ id: 1, name: "Leah Rankin", email: "leah@example.com", role: "admin" },
		{ id: 2, name: "Ayden Dillon", email: "ayden@example.com", role: "manager" },
		{ id: 3, name: "Alisa Lowery", email: "alisa@example.com", role: "designer" },
		{ id: 4, name: "Chante Carver", email: "chante@example.com", role: "manager" },
		{ id: 5, name: "Isla-Mae Villarreal", email: "isla-mae@example.com", role: "designer" },
		{ id: 6, name: "Piper Huff", email: "piper@acme.com", role: "admin" },
		{ id: 7, name: "Josie Pruitt", email: "josie@acme.com", role: "manager" },
		{ id: 8, name: "Tessa Corrigan", email: "tessa@acme.com", role: "designer" },
		{ id: 9, name: "Arya Sheridan", email: "arya@acme.com", role: "designer" },
		{ id: 10, name: "Mihai Sheppard", email: "mihai@acme.com", role: "designer" }
	];

	operationsKey = "OPERATIONS--log-level";
	productKey = "product-RAIN-123-cool-feature";

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

		<p>
			The two keys being checked are:
		</p>

		<ul>
			<li>
				<strong>Operations (ANY)</strong>: <code>#operationsKey#</code>
			</li>
			<li>
				<strong>Product (BOOLEAN)</strong>: <code>#productKey#</code>
			</li>
		</ul>

		<table width="100%" border="1" cellspacing="2" cellpadding="5">
		<thead>
			<tr>
				<th> ID </th>
				<th> User </th>
				<th> Role </th>
				<th> Operations </th>
				<th> Product </th>
			</tr>
		</thead>
		<tbody>
			<cfloop item="user" array="#users#">

				<cfscript>
					operationsVariant = application.strangler.getVariant(
						featureKey = operationsKey,
						userKey = user.id,
						userProperties = {
							name: user.name,
							email: user.email,
							role: user.role
						},
						defaultValue = { level: 50, name: "ERROR" }
					);
					productVariant = application.strangler.getVariant(
						featureKey = productKey,
						userKey = user.id,
						userProperties = {
							name: user.name,
							email: user.email,
							role: user.role
						},
						defaultValue = false
					);
				</cfscript>

				<tr>
					<td align="center">
						#encodeForHtml( user.id )#
					</td>
					<td>
						<strong>#encodeForHtml( user.name )#</strong><br />
						&lt;#encodeForHtml( user.email )#&gt;
					</td>
					<td align="center">
						#encodeForHtml( user.role )#
					</td>
					<td align="center">
						#encodeForHtml( serializeJson( operationsVariant ) )#
					</td>
					<td align="center">
						#encodeForHtml( serializeJson( productVariant ) )#
					</td>
				</tr>
			</cfloop>
		</tbody>
		</table>


		<!---
			When the Admin updates the feature flag data, it posts a message over to this
			demo frame letting us know. When that happens, let's refresh the page
			automatically in order to bring in the latest targeting rules for our demo.
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
