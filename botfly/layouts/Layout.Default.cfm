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
			<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1">
		</head>
		<body>
			<div class="container">
				<header class="header">
					#renderView('includes/header')#
				</header>
				<cfif !getPlugin("MessageBox").isEmpty()>
					<div class="MessageBox">#getPlugin("MessageBox").renderit()#</div>
				</cfif>
				<div id="main">
					<article class="article">
					#renderView()#
					</article>
				</div>
				<footer class="footer">
					#renderView('includes/footer')#
				</footer>
			</div>
			#renderFooterAssets()#
			#renderView('includes/google')#
		</body>
	</html>
</cfoutput>
