
DEBUG_SPEW = 0
player_colors = {}
player_colors[1] = { 61, 210, 150 }    --              Teal
player_colors[3] = { 243, 201, 9 }     --              Yellow
player_colors[5] = { 197, 77, 168 }    --              Pink
player_colors[4] = { 255, 108, 0 }     --              Orange
player_colors[0] = { 52, 85, 255 }     --              Blue
player_colors[8] = { 101, 212, 19 }    --              Green
player_colors[9] = { 129, 83, 54 }     --              Brown
player_colors[7] = { 27, 192, 216 }    --              Cyan
player_colors[6] = { 199, 228, 13 }    --              Olive
player_colors[2] = { 140, 42, 244 }    --              Purple

GAME_START_GOLD = 50
ROUND_INCOME = 30
GOLD_INCOME_PERCENTAGE = 5

require('mechanics/attacks')


function CTDGameMode:InitGameMode()
	self._nRoundNumber = 1
	self._currentRound = nil
	self._flLastThinkGameTime = nil
	self._nCurrentSpawnerID = 1
	self._nLivesLeft = 40
	self._diff = {}
	self._diff["hp"] = 1
	self._diff["lives"] = 40

	self:_ReadGameConfiguration()
	self._szMainQuestTitle = "#DOTA_Quest_Wintermaul_Main_Title"

	GameRules:SetShowcaseTime( 0.0 ) 
	GameRules:SetSameHeroSelectionEnabled( true )
	GameRules:SetTimeOfDay( 0.75 )
	GameRules:SetHeroRespawnEnabled( false )
	GameRules:SetUseUniversalShopMode( false )
	GameRules:SetHeroSelectionTime( 30.0 )
	GameRules:SetStrategyTime(0.0)
	GameRules:SetPreGameTime( 25.0 )
	GameRules:SetPostGameTime( 30.0 )
	GameRules:SetTreeRegrowTime( 60.0 )
	GameRules:SetCreepMinimapIconScale( 0.7 )
	GameRules:SetRuneMinimapIconScale( 0.7 )
	GameRules:SetGoldPerTick( 0 )
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS,10)
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS,0)
	GameRules:GetGameModeEntity():SetRemoveIllusionsOnDeath( true )
	GameRules:GetGameModeEntity():SetTopBarTeamValuesOverride( true )
	GameRules:GetGameModeEntity():SetTopBarTeamValuesVisible( false )
	GameRules:GetGameModeEntity():SetFogOfWarDisabled ( true )

	GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 0.25 )
	GameRules:GetGameModeEntity():SetCameraDistanceOverride(1300)

	-- Register Listeners
	ListenToGameEvent( "npc_spawned", Dynamic_Wrap(CTDGameMode, "OnNpcSpawned"), self)
	ListenToGameEvent( "dota_player_pick_hero", Dynamic_Wrap( CTDGameMode, "OnPlayerPicked" ), self )
	ListenToGameEvent( "game_rules_state_change", Dynamic_Wrap( CTDGameMode, "OnGameRulesStateChange" ), self )
	ListenToGameEvent( "entity_killed", Dynamic_Wrap(CTDGameMode, "OnEntityKilled"), self)
	ListenToGameEvent( "player_reconnected", Dynamic_Wrap(CTDGameMode, "OnPlayerReconnect"), self)
	
	CustomGameEventManager:RegisterListener("diff_event", 
		function(eventSourceIndex, args) 
			self._diff["hp"] = args["hp"]
			self._diff["lives"] = args["lives"]
			self._nLivesLeft = self._diff["lives"]
			self._diff["endless"] = args["endless"] --use this to activate endless mode
			CustomNetTables:SetTableValue("game_state", "lives_remaining", {value = string.format("%d", args["lives"])})
		end 
	)
    
	-- DebugPrint
	Convars:RegisterConvar('debug_spew', tostring(DEBUG_SPEW), 'Set to 1 to start spewing debug info. Set to 0 to disable.', 1)

	-- Full units file to get the custom values
	GameRules.AbilityKV = LoadKeyValues("scripts/npc/npc_abilities_custom.txt")
  	GameRules.UnitKV = LoadKeyValues("scripts/npc/npc_units_custom.txt")
  	GameRules.HeroKV = LoadKeyValues("scripts/npc/npc_heroes_custom.txt")
  	GameRules.ItemKV = LoadKeyValues("scripts/npc/npc_items_custom.txt")
  	-- GameRules.Requirements = some tech tree
	
    -- Attack net table
    Attacks:Init()
	
  	-- Setup the Wintermaul Quest.
  	self.MainQuest = SpawnEntityFromTableSynchronous( "quest", {
  	 name = "MainQuest",
  	 title = self._szMainQuestTitle
  	 })

  	-- Text on the quest timer at start.
  	self.MainQuest:SetTextReplaceValue( QUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, self._nLivesLeft)
    
    -- Registering custom commands
    Convars:RegisterCommand( "wintermaul_set_round", function(...) return self:_SetRound( ... ) end, "Start playing a specific Wintermaul round", FCVAR_CHEAT )
    Convars:RegisterCommand( "wintermaul_set_lives_remaining", function(...) return self:_SetLivesRemaining( ... ) end, "Set the lives remaining for Wintermaul.", FCVAR_CHEAT )
    
    -- Setting default net-table values
    CustomNetTables:SetTableValue("game_state", "round_time_to_start", {value = 'Pre-game'})
    CustomNetTables:SetTableValue("game_state", "lives_remaining", {value = 'Pre-game'})
    CustomNetTables:SetTableValue("game_state", "round_wave_data", {
                                                                    roundData = "Pre-game",
                                                                    currentTitle = "Pre-game",
                                                                    nextTitle = "Pre-game",
                                                                    currentSpecial = "Pre-game",
                                                                    nextSpecial = "Pre-game",
		})
    CustomNetTables:SetTableValue("game_state", "round_creep_data", {enemiesremaining = "Pre-game", totalenemies = "Pre-game"})
    
	print( "Wintermaul is loaded." )
end

-- assign invincibility to the heroes
function CTDGameMode:OnNpcSpawned( keys )

	local unit = EntIndexToHScript( keys.entindex )
	if unit:IsRealHero() then
		-- add the invulnerable modifier to the hero
		unit:AddNewModifier(unit, nil, "modifier_invulnerable", nil)
		local player_id = unit:GetPlayerID()
		local point = Entities:FindByName( nil, "spawn_point_"..player_id )
		if point then 
			Timers:CreateTimer(0.01, function() unit:SetAbsOrigin(point:GetAbsOrigin()) end)			
			print("player_id = "..player_id)
			print(point)
		end
		
		for index=0,5 do
			if (unit:GetAbilityByIndex(index)==nil) then
				break
			else
				unit:GetAbilityByIndex(index):SetLevel(1)
				unit:SetAbilityPoints(0)
			end
		end
	end
end

-- Read and assign configurable keyvalues if applicable
function CTDGameMode:_ReadGameConfiguration()
	local kv = LoadKeyValues( "scripts/maps/td_config.txt" )
	kv = kv or {} -- Handle the case where there is not keyvalues file

	self._flPrepTimeBetweenRounds = tonumber( kv.PrepTimeBetweenRounds or 0 )

	self:_ReadSpawnsConfiguration( kv["Spawns"] )
	self:_ReadRoundConfigurations( kv["Waves"] )
end


-- Verify valid spawns are defined and build a table with them from the keyvalues file
function CTDGameMode:_ReadSpawnsConfiguration( kvSpawns )
	self._vSpawnsList = {}
	if type( kvSpawns ) ~= "table" then
		return
	end
	for _,sp in pairs( kvSpawns ) do			-- Note "_" used as a shortcut to create a temporary throwaway variable
		table.insert( self._vSpawnsList, {
			szSpawnerName = sp.SpawnerName or "",
			szAirWaypoint = sp.AirWaypoint or "",
			szGroundWaypoint = sp.GroundWaypoint or ""
		} )
	end
	-- for k,v in pairs( self._vSpawnsList ) do
	-- 	print("key: ", k, "val: ", v.szSpawnerName, v.szFirstWaypoint)
	-- end
end

-- Set number of rounds without requiring index in text file
function CTDGameMode:_ReadRoundConfigurations( kv )
	self._vRounds = {}
	while true do
		local szRoundName = string.format("Wave%d", #self._vRounds + 1 )
		local kvRoundData = kv[ szRoundName ]
		if kvRoundData == nil then
			return
		end
		local roundObj = CTDlGameRound()

		roundObj:ReadConfiguration( kvRoundData, self, #self._vRounds + 1 )
		table.insert( self._vRounds, roundObj )
	end
end

function CTDGameMode:GetCurrentRound()
	return self._vRounds[self._nRoundNumber]
end

-- When game state changes set state in script
function CTDGameMode:OnGameRulesStateChange()
	local nNewState = GameRules:State_Get()

	if nNewState == DOTA_GAMERULES_STATE_STRATEGY_TIME then
		for i=0, DOTA_MAX_TEAM_PLAYERS do
			if PlayerResource:HasSelectedHero(i) == false then
	            local player = PlayerResource:GetPlayer(i)
	            if player then
	            	print("Randoming hero for player ", i)
	            	player:MakeRandomHeroSelection()
	            end
	        end
	    end
	elseif nNewState == DOTA_GAMERULES_STATE_PRE_GAME then
		CustomUI:DynamicHud_Create(0, "diffPan", "file://{resources}/layout/custom_game/choose_diff.xml", nil)
	end

	if nNewState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		self._flPrepTimeEnd = GameRules:GetGameTime() + self._flPrepTimeBetweenRounds
	end

	--insert ui element for 
end

-- sets ability points to 0 and sets skills to lvl1 at start.
function CTDGameMode:OnPlayerPicked( keys )
	for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
		if PlayerResource:IsValidTeamPlayer(nPlayerID) then
			PlayerResource:SetCustomPlayerColor(nPlayerID, player_colors[nPlayerID][1], player_colors[nPlayerID][2], player_colors[nPlayerID][3])
			if nPlayerID == 0 then
				PlayerResource:SetGold(nPlayerID, GAME_START_GOLD, false) --set a different player1 starting gold here if needed 
			else
				PlayerResource:SetGold(nPlayerID, GAME_START_GOLD, false)
			end
		end
	end
end


function CTDGameMode:_ThinkPrepTime()
	if GameRules:GetGameTime() >= self._flPrepTimeEnd then
		self._flPrepTimeEnd = nil
		if self._entPrepTimeQuest then
			UTIL_RemoveImmediate( self._entPrepTimeQuest )
			self._entPrepTimeQuest = nil
		end

		if self._nRoundNumber > #self._vRounds then
			GameRules:SetGameWinner( DOTA_TEAM_GOODGUYS )
			return false
		end
		self._currentRound = self._vRounds[ self._nRoundNumber ]


		-- should get from ._currentRound tbh -------------------------------- Use this to dictate what rounds get special treatment?
		self._currentRound:Begin()
		return
	end

	if not self._entPrepTimeQuest then
		self._vRounds[ self._nRoundNumber ]:Precache()
	end

	CustomNetTables:SetTableValue("game_state", "round_time_to_start", {value = string.format( "%.f", self._flPrepTimeEnd - GameRules:GetGameTime())})
end


-- this is the thinker. it thinks
-- Evaluate the state of the game
function CTDGameMode:OnThink()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		--self:_CheckForDefeat()
		--self:_ThinkLootExpiry()

		if self._flPrepTimeEnd ~= nil then
			self:_ThinkPrepTime()

		elseif self._currentRound ~= nil then
			self._currentRound:Think()
			if self._currentRound:IsFinished() then
				self._currentRound:End()
				self._currentRound = nil

				self._nRoundNumber = self._nRoundNumber + 1
				if self._nRoundNumber > #self._vRounds then
					self._nRoundNumber = 1
					GameRules:MakeTeamLose( DOTA_TEAM_BADGUYS )
				else
					self._flPrepTimeEnd = GameRules:GetGameTime() + self._flPrepTimeBetweenRounds --10
				end
			end
		end
	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then		-- Safe guard catching any state that may exist beyond DOTA_GAMERULES_STATE_POST_GAME
		return nil
	end
	return 1
end

function CTDGameMode:OnEntityKilled( event )
	-- The Unit that was Killed
	local killedUnit = EntIndexToHScript(event.entindex_killed)
	-- The Killing entity
	local killerEntity
	if event.entindex_attacker then
		killerEntity = EntIndexToHScript(event.entindex_attacker)
	end

	-- Player owner of the unit
	local player = killedUnit:GetPlayerOwner()
	
	if IsCustomBuilding(killedUnit) then
		 -- Building Helper grid cleanup
		BuildingHelper:RemoveBuilding(killedUnit, true)

		-- Check units for downgrades
		local building_name = killedUnit:GetUnitName()
		--[[
		-- Substract 1 to the player building tracking table for that name
		if player.buildings[building_name] then
			player.buildings[building_name] = player.buildings[building_name] - 1
		end

		-- possible unit downgrades
		for k,units in pairs(player.units) do
			CheckAbilityRequirements( units, player )
		end

		-- possible structure downgrades
		for k,structure in pairs(player.structures) do
			CheckAbilityRequirements( structure, player )
		end
		]]--
	end
end

function CTDGameMode:LifeLost(ammount)
	if self._nLivesLeft - ammount < 0 then
		self._nLivesLeft = 0
	else
		self._nLivesLeft = self._nLivesLeft - ammount
	end

	CustomNetTables:SetTableValue("game_state", "lives_remaining", {value = string.format("%d", self._nLivesLeft)})

	-- Update Quest UI
	self.MainQuest:SetTextReplaceValue( QUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, self._nLivesLeft)
	if self._nLivesLeft == 0 then
		GameRules:MakeTeamLose( DOTA_TEAM_GOODGUYS )
	end
end

function CTDGameMode:OnPlayerReconnect()
	-- Do nothing for now
end

-- Custom commands go here
function CTDGameMode:_SetRound( cmdName, roundNumber, delay )
	local nRoundToTest = tonumber( roundNumber )
	print (string.format( "Testing round %d", nRoundToTest ) )
	if nRoundToTest <= 0 or nRoundToTest > #self._vRounds then
		Msg( string.format( "Cannot test invalid round %d", nRoundToTest ) )
		return
	end

	if self._currentRound ~= nil then
		self._currentRound:End()
		self._currentRound = nil
	end

	self._flPrepTimeEnd = GameRules:GetGameTime() + self._flPrepTimeBetweenRounds
	self._nRoundNumber = nRoundToTest
	if delay ~= nil then
		self._flPrepTimeEnd = GameRules:GetGameTime() + tonumber( delay )
	end
end

function CTDGameMode:_SetLivesRemaining( cmdName, livesNumber)
	local nLivesToGet = tonumber( livesNumber )
	print (string.format( "Testing %d lives", nLivesToGet ) )
	if nLivesToGet <= 0 then
		Msg( string.format( "Cannot test invalid lives %d", nLivesToGet ) )
		return
	end
	self._nLivesLeft = nLivesToGet

	CustomNetTables:SetTableValue("game_state", "lives_remaining", {value = string.format("%d", self._nLivesLeft)})
end


