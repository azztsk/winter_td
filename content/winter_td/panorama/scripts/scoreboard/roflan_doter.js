CustomNetTables.SubscribeNetTableListener( "kills", function( a, b, c ){
	$.Msg( b )
	if ("player_" + Players.GetLocalPlayer() == b ) {
	$.Msg( "LOL" )
	$( "#HeroScore" ).text = c.kills }
} )