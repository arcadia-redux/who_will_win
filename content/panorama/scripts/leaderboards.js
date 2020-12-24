// Easy iteration of the leaderboard
let leaderboardPlacements = [
    $("#Rank1Row"),
    $("#Rank2Row"),
    $("#Rank3Row"),
    $("#Rank4Row"),
    $("#Rank5Row"),
    $("#Rank6Row"),
    $("#Rank7Row"),
    $("#Rank8Row"),
    $("#Rank9Row"),
    $("#Rank10Row"),
    $("#RankPlayerRow"),
]

function EditLeaderboards(data){
    $.Msg("leaderboards function - ping");

    // Filling leaderboard with current top players
    if(data.rounds != null){
        let leaderboardPanel = $("#LeaderboardsRoot");

        // Fringe case where we have less than 10 players playing the game :/
        /* I'm not even sure if data.rounds is an array or an object...
        for(let i = 0; i < Math.min(10, data.rounds.length); i++){

        }
        */
    }
}

function SetPlayerLeaderboards(playerPanel, data){

}

(function() {
	CustomNetTables.SubscribeNetTableListener("leaderboards", EditLeaderboards)

})()