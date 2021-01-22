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
        //let leaderboardPanel = $("#LeaderboardsRoot");

        // We assume that there are at *least* 10 players in the leaderboards
        let leaderboardEntries = data.rounds.entries();
        for(let i = 0; i < 10; i++){
            let rankSlot = leaderboardPlacements[i];
            SetPlayerLeaderboards(rankSlot, leaderboardEntries[i]);
        }
    }
}

function SetPlayerLeaderboards(playerPanel, data){
    var avatar = playerPanel.FindChildTraverse("RankBoxAvatarTOP");
    var username = playerPanel.FindChildTraverse("PlayerName");
    avatar.steamid = data.SteamId;
    username.steamid = data.SteamId;
}

(function() {
	CustomNetTables.SubscribeNetTableListener("leaderboards", EditLeaderboards)

})()