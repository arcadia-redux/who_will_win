function Leaderboards(data){
    $.Msg("ping");
}

(function() {
	CustomNetTables.SubscribeNetTableListener("leaderboards", Leaderboards)

})()