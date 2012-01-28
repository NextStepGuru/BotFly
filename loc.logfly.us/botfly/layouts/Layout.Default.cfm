<cfoutput>
	<!DOCTYPE HTML>
	<!--[if lt IE 7 ]> <html class="ie6"> <![endif]-->
	<!--[if IE 7 ]>    <html class="ie7"> <![endif]-->
	<!--[if IE 8 ]>    <html class="ie8"> <![endif]-->
	<!--[if IE 9 ]>    <html class="ie9"> <![endif]-->
	<!--[if (gt IE 9)|!(IE)]><!--> <html class=""> <!--<![endif]-->
		<head>
			#renderHeadAssets()#
			#renderHeaderAssets()#
			<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
		</head>
		<body>
			<div class="container">
				<article class='article'>
					<nav class='nav primary'>
						#renderView('includes/header')#
					</nav>
					#renderView()#
					<nav class="nav footer">
						#renderView('includes/footer')#
					</nav>
				</article>
				#renderFooterAssets()#
				#renderView('includes/google')#
			</div>
		</body>
	</html>
</cfoutput>
