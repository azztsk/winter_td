function InitGameInfoBox()
{
    SetRoundWaveData(CustomNetTables.GetTableValue("game_state", "round_wave_data"));
    SetRoundTimeToStart(CustomNetTables.GetTableValue("game_state", "round_time_to_start"));
    SetRoundCreepData(CustomNetTables.GetTableValue("game_state", "round_creep_data"));
    SetLivesRemaining(CustomNetTables.GetTableValue("game_state", "lives_remaining"));
}


function SetRoundWaveData(round_wave_data)
{
	var currentNumber = round_wave_data.roundData;
	var current = round_wave_data.currentTitle;
	var next = round_wave_data.nextTitle;
	var currentspecial = round_wave_data.currentSpecial;
	var nextspecial = round_wave_data.nextSpecial;

	var waveNumber = $( "#CurrentWaveNumber" );
	var nextwavetext = $( "#NextWaveText" );
	var currentwavetext = $("#CurrentWaveText");
	var nextwave = $("#NextWave");
	var currentwavetop = $("#CurrentWaveTop"); // Here if needed for later.
	var currentwavebot = $( "#CurrentWaveBot"); // Here if needed for later.


    //--------------- current wave ---------------
    
	waveNumber.text = currentNumber;

	if ( currentspecial == "#DOTA_Wintermaul_Round_Element_Air") //Air lvls
	{
		currentwavetext.style.color = "orange";
		//currentwavebot.style.color = "orange";

		currentwavetext.text = ("( Air )" + $.Localize( current ));
	}
	else if(currentspecial == "creature_regeneration_bonus") //Evasion lvls
	{
		currentwavetext.style.color = "light-green";
		//currentwavebot.style.color = "blue";

		currentwavetext.text = ("(Regeneration)" + $.Localize( current ));
	}
	else if(currentspecial == "creature_evasion_bonus") //Evasion lvls
	{
		currentwavetext.style.color = "teal";
		//currentwavebot.style.color = "blue";

		currentwavetext.text = ("(Dexterity)" + $.Localize( current ));
	}
	else if(currentspecial == "creature_armor_bonus") //Splitter lvls
	{
		currentwavetext.style.color = "brown";
		//currentwavebot.style.color = "blue";

		currentwavetext.text = ("(Toughness)" + $.Localize( current ));
	}
	else if(currentspecial == "creature_movespeed_bonus") //Haste lvls
	{
		currentwavetext.style.color = "#00C3FF";
		//currentwavebot.style.color = "blue";

		currentwavetext.text = ("(Haste)" + $.Localize( current ));
	}
	else if(currentspecial == "creature_health_bonus") //Boss lvls 
	{
		currentwavetext.style.color = "red";
		//currentwavebot.style.color = "red";

		currentwavetext.text = ("(Vitality)" + $.Localize( current ));
	}
	else if(currentspecial == "creature_gold_bonus") //Bonus lvls
	{
		currentwavetext.style.color = "yellow";
		//currentwavebot.style.color = "yellow";

		currentwavetext.text = ("(Bonus)" + $.Localize( current ));
	}
	else if(currentspecial == "creature_boss") //Bonus lvls
	{
		currentwavetext.style.color = "orange";
		//currentwavebot.style.color = "yellow";

		currentwavetext.text = ("(Boss)" + $.Localize( current ));
	}
	else //normal lvls
	{
		currentwavetext.style.color = "white";
		currentwavebot.style.color = "white";

		currentwavetext.text = $.Localize( current );
	}

    //--------------- next wave ---------------
    
	if ( nextspecial == "#DOTA_Wintermaul_Round_Element_Air") //Air lvls
	{
		nextwavetext.style.color = "orange";
		//currentwavebot.style.color = "orange";

		nextwavetext.text = ("( Air )" + $.Localize( next ));
	}
	else if(nextspecial == "creature_regeneration_bonus") //Evasion lvls
	{
		nextwavetext.style.color = "light-green";
		//currentwavebot.style.color = "blue";

		nextwavetext.text = ("(Regeneration)" + $.Localize( next ));
	}
	else if(nextspecial == "creature_evasion_bonus") //Evasion lvls
	{
		nextwavetext.style.color = "teal";
		//currentwavebot.style.color = "blue";

		nextwavetext.text = ("(Dexterity)" + $.Localize( next ));
	}
	else if(nextspecial == "creature_armor_bonus") //Splitter lvls
	{
		nextwavetext.style.color = "brown";
		//currentwavebot.style.color = "blue";

		nextwavetext.text = ("(Toughness)" + $.Localize( next ));
	}
	else if(nextspecial == "creature_movespeed_bonus") //Haste lvls
	{
		nextwavetext.style.color = "#00C3FF";
		//currentwavebot.style.color = "blue";

		nextwavetext.text = ("(Haste)" + $.Localize( next ));
	}
	else if(nextspecial == "creature_health_bonus") //Boss lvls 
	{
		nextwavetext.style.color = "red";
		//currentwavebot.style.color = "red";

		nextwavetext.text = ("(Vitality)" + $.Localize( next ));
	}
	else if(nextspecial == "creature_gold_bonus") //Bonus lvls
	{
		nextwavetext.style.color = "yellow";
		//currentwavebot.style.color = "yellow";

		nextwavetext.text = ("(Bonus)" + $.Localize( next ));
	}
	else if(nextspecial == "creature_boss") //Boss lvls 
	{
		nextwavetext.style.color = "orange";
		//currentwavebot.style.color = "red";

		nextwavetext.text = ("(Boss)" + $.Localize( next ));
	}
	else //normal lvls
	{
		nextwavetext.style.color = "white";
		nextwavetext.style.color = "white";

		nextwavetext.text = $.Localize( next );
	}
}

function SetRoundTimeToStart(round_time_to_start)
{
	var timertext = $( "#TimerText" );
	var timertime = $( "#TimerTime" );
	
	timertext.text = "Next wave will spawn in: ";
	timertime.text = round_time_to_start.value;
}

function SetRoundCreepData(creep_data)
{
	var timertext = $( "#TimerText" );
	var timertime = $( "#TimerTime" );
	
	timertext.text = "Creeps remaining: ";
	timertime.text = creep_data.enemiesremaining + " / " + creep_data.totalenemies;
}

function SetLivesRemaining(lives_remaining)
{
	var lifecolor;
	var lifetext = $( "#LifeNumber" );
	lifetext.text = lives_remaining.value;
	if (Number(lifetext.text) > 20)
	{
		lifecolor = "#ffe5e5";
	}
	else if (Number(lifetext.text) > 10)
	{
		lifecolor = "#ff6666";
	}
	else if (Number(lifetext.text) > 5)
	{
		lifecolor = "#ff3232";
	}
	else
	{
		lifecolor = "#7f0000";
	}
	lifetext.style.color = lifecolor;
}

function OnGameStateChanged( table_name, key, data )
{
    if (key == "lives_remaining")
    {
        SetLivesRemaining(data);
    }
    else if (key == "round_creep_data")
    {
        SetRoundCreepData(data);
    }
    else if (key == "round_time_to_start")
    {
        SetRoundTimeToStart(data);
    }
    else if (key == "round_wave_data")
    {
        SetRoundWaveData(data);
    }
    else
    {
        $.Msg("Unrecognised game_state key: " + key)
    }
}

CustomNetTables.SubscribeNetTableListener( "game_state", OnGameStateChanged );

(function () {
    InitGameInfoBox()
})();

