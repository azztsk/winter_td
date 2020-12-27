function DiffCheck(diff){
	$("#diffPan").style.visibility = "collapse";
	var hp = diff == "easy" ? .75 : diff == "medium" ? 1 : diff == "hard" ? 1.25 : diff == "insane" ? 1.5 : diff == "perfection" ? 1.5 : 1;
	var lives = diff == "easy" ? 40 : diff == "medium" ? 40 : diff == "hard" ? 20 : diff == "insane" ? 10 : diff == "perfection" ? 1 : 40;
	var endless = diff == "unlimited" ? true : false;
	$.Msg("Selected difficulty: ", diff); 
	//Insert message to be shared to every player
	GameEvents.SendCustomGameEventToServer("diff_event", {"hp" : hp, "lives" : lives, "endless": endless});
}

function DiffDefault(args){
	$("#diffPan").style.visibility = "collapse";
}

GameEvents.Subscribe( "diff_default", DiffDefault);