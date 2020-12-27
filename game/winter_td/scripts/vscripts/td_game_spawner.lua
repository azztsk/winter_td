unit_abilities = {
	"creature_armor_bonus","creature_health_bonus",
	"creature_movespeed_bonus","creature_regeneration_bonus",
	"creature_evasion_bonus","creature_gold_bonus",
}
ground_unit ={
	
--	"models/courier/greevil/gold_greevil.vmdl",
--	{name = "", model = ""},
	{unit_name = "mega_greevil", model ="models/courier/gold_mega_greevil/gold_mega_greevil.vmdl"},
	{unit_name = "pudge_dog", model ="models/items/courier/butch_pudge_dog/butch_pudge_dog.vmdl"},
	{unit_name = "amphibian_kid", model ="models/items/courier/amphibian_kid/amphibian_kid.vmdl"},
	{unit_name = "bajie_pig", model ="models/items/courier/bajie_pig/bajie_pig.vmdl"},
	{unit_name = "bearzky", model ="models/items/courier/bearzky/bearzky.vmdl"},
	{unit_name = "blilly_bounceback", model ="models/items/courier/billy_bounceback/billy_bounceback.vmdl"},
	{unit_name = "blotto", model ="models/items/courier/blotto_and_stick/blotto.vmdl"},
	{unit_name = "broofus", model ="models/items/courier/boooofus_courier/boooofus_courier.vmdl"},
	{unit_name = "dokkaebi", model ="models/items/courier/dokkaebi_nexon_courier/dokkaebi_nexon_courier.vmdl"},
	{unit_name = "dc_demon", model ="models/items/courier/dc_demon/dc_demon.vmdl"},
	{unit_name = "faceless_rex", model ="models/items/courier/faceless_rex/faceless_rex.vmdl"},
	
}
fly_unit_model ={
	
--	"models/courier/greevil/gold_greevil_flying.vmdl",
	"models/courier/gold_mega_greevil/gold_mega_greevil_flying.vmdl",
	"models/items/courier/butch_pudge_dog/butch_pudge_dog_flying.vmdl",
	"models/items/courier/amphibian_kid/amphibian_kid_flying.vmdl",
	"models/items/courier/bajie_pig/bajie_pig_flying.vmdl",
	"models/items/courier/bearzky/bearzky_flying.vmdl",
	"models/items/courier/billy_bounceback/billy_bounceback_flying.vmdl",
	"models/items/courier/blotto_and_stick/blotto_flying.vmdl",
	"models/items/courier/boooofus_courier/boooofus_courier_flying.vmdl",
	"models/items/courier/dokkaebi_nexon_courier/dokkaebi_nexon_courier_flying.vmdl",
	"models/items/courier/dc_demon/dc_demon_flying.vmdl",
	"models/items/courier/faceless_rex/faceless_rex_flying.vmdl"
	
}
--[[
	CTDGameSpawner - A single unit spawner for Holdout.
]]
if CTDGameSpawner == nil then
	CTDGameSpawner = class({})
end

function CTDGameSpawner:ReadConfiguration( name, kv, gameRound , roundNumber, roundUnit, roundSpecial)
	self._gameRound = gameRound
	self._roundNumber = roundNumber
	self._roundUnit = roundUnit
	self._roundSpecial = roundSpecial
	self._dependentSpawners = {}
	self._szChampionNPCClassName = kv.ChampionNPCName or ""
	self._szGroupWithUnit = kv.GroupWithUnit or ""
	self._szName = name
	self._szNPCClassName = kv.NPCName or ""
	self._szSpawnerName = kv.SpawnerName or ""
	self._szWaitForUnit = kv.WaitForUnit or ""
	self._szWaypointName = kv.Waypoint or ""
	self._waypointEntity = nil

	self._nChampionLevel = tonumber( kv.ChampionLevel or 1 )
	self._nChampionMax = tonumber( kv.ChampionMax or 1 )
	self._nCreatureLevel = tonumber( kv.CreatureLevel or 1 )
	self._nTotalUnitsToSpawn = tonumber( kv.TotalUnitsToSpawn or 0 )
	self._nUnitsPerSpawn = tonumber( kv.UnitsPerSpawn or 1 )

	self._flChampionChance = tonumber( kv.ChampionChance or 0 )
	self._flInitialWait = tonumber( kv.WaitForTime or 0 )
	self._flSpawnInterval = tonumber( kv.SpawnInterval or 0 )
    
	self._bDontGiveGoal = ( tonumber( kv.DontGiveGoal or 0 ) ~= 0 )
	self._bDontOffsetSpawn = ( tonumber( kv.DontOffsetSpawn or 0 ) ~= 0 )
    self._bSpawnWhenNextDies = ( tonumber( kv.SpawnWhenNextDies or 0 ) ~= 0 )
    
    self._vAliveSpawnedUnits = {}
    
    
end

function CTDGameSpawner:_SearchSpawnTable( sSpawnName )
	local spawn
	for k,v in pairs(self._gameRound._gameMode._vSpawnsList) do
		if v.szSpawnerName == sSpawnName then
			spawn = v
		end
	end
	if spawn == nil then
		print("could not find ", sSpawnName)
	end
	return spawn
end

function CTDGameSpawner:PostLoad( spawnerList )
	self._waitForUnit = spawnerList[ self._szWaitForUnit ]
	if self._szWaitForUnit ~= "" and not self._waitForUnit then
		print( "%s has a wait for unit %s that is missing from the round data.", self._szName, self._szWaitForUnit )
	elseif self._waitForUnit then
		table.insert( self._waitForUnit._dependentSpawners, self )
	end

	self._groupWithUnit = spawnerList[ self._szGroupWithUnit ]
	if self._szGroupWithUnit ~= "" and not self._groupWithUnit then
		print ("%s has a group with unit %s that is missing from the round data.", self._szName, self._szGroupWithUnit )
	elseif self._groupWithUnit then
		table.insert( self._groupWithUnit._dependentSpawners, self )
	end
end


function CTDGameSpawner:Precache()
	PrecacheUnitByNameAsync( self._szNPCClassName, function( sg ) self._sg = sg end )
	if self._szChampionNPCClassName ~= "" then
		PrecacheUnitByNameAsync( self._szChampionNPCClassName, function( sg ) self._sgChampion = sg end )
	end
end


function CTDGameSpawner:Begin()
	self._nUnitsSpawnedThisRound = 0
	self._nChampionsSpawnedThisRound = 0
	self._nUnitsCurrentlyAlive = 0

	self._vecSpawnLocation = nil
	if self._szSpawnerName ~= "" then
		print("Spawning started")
		local entSpawner = Entities:FindByName( nil, self._szSpawnerName )
		if not entSpawner then
			print( string.format( "Failed to find spawner named %s for %s\n", self._szSpawnerName, self._szName ) )
		end
		self._vecSpawnLocation = entSpawner:GetAbsOrigin()
	end
	self._entWaypoint = nil
	if self._szWaypointName ~= "" and not self._bDontGiveGoal then
		self._entWaypoint = Entities:FindByName( nil, self._szWaypointName )
		if not self._entWaypoint then
			print( string.format( "Failed to find waypoint named %s for %s", self._szWaypointName, self._szName ) )
		end
	end

	if self._waitForUnit ~= nil or self._groupWithUnit ~= nil then
		self._flNextSpawnTime = nil
	else
		self._flNextSpawnTime = GameRules:GetGameTime() + self._flInitialWait
	end
end


function CTDGameSpawner:End()
	if self._sg ~= nil then
		UnloadSpawnGroupByHandle( self._sg )
		self._sg = nil
	end
	if self._sgChampion ~= nil then
		UnloadSpawnGroupByHandle( self._sgChampion )
		self._sgChampion = nil
	end
end


function CTDGameSpawner:ParentSpawned( parentSpawner )
	if parentSpawner == self._groupWithUnit then
		-- Make sure we use the same spawn location as parentSpawner.
		self:_DoSpawn()
	elseif parentSpawner == self._waitForUnit then
		if parentSpawner:IsFinishedSpawning() and self._flNextSpawnTime == nil then
			self._flNextSpawnTime = parentSpawner._flNextSpawnTime + self._flInitialWait
		end
	end
end

function CTDGameSpawner:AreThereSpawnedUnitsAlive()
    for k,v in pairs(self._vAliveSpawnedUnits) do
        if v:IsNull() then
            table.remove(self._vAliveSpawnedUnits, k)
        end
    end
    return #self._vAliveSpawnedUnits > 0
end


function CTDGameSpawner:Think()
	if not self._flNextSpawnTime or (self._bSpawnWhenNextDies and self:AreThereSpawnedUnitsAlive()) then
		return
	end

	if GameRules:GetGameTime() >= self._flNextSpawnTime then
		self:_DoSpawn()
		for _,s in pairs( self._dependentSpawners ) do
			s:ParentSpawned( self )
		end

		if self:IsFinishedSpawning() then
			self._flNextSpawnTime = nil
		else
			self._flNextSpawnTime = self._flNextSpawnTime + self._flSpawnInterval
		end
	end
end

function CTDGameSpawner:GetTotalUnitsToSpawn()
	return self._nTotalUnitsToSpawn
end


function CTDGameSpawner:IsFinishedSpawning()
	return ( self._nTotalUnitsToSpawn <= self._nUnitsSpawnedThisRound ) or ( self._groupWithUnit ~= nil )
end


function CTDGameSpawner:_GetSpawnLocation()
	if self._groupWithUnit then
		return self._groupWithUnit:_GetSpawnLocation()
	else
		return self._vecSpawnLocation
	end
end


function CTDGameSpawner:_GetSpawnWaypoint()
	if self._groupWithUnit then
		return self._groupWithUnit:_GetSpawnWaypoint()
	else
		return self._entWaypoint
	end
end


function CTDGameSpawner:_UpdateSpawn( index )
	self._vecSpawnLocation = Vector( 0, 0, 0 )
	self._entWaypoint = nil

	self:_GetSpawnerInfoByIndex(index)
end

function CTDGameSpawner:IsSpawningFinished()
    return self._nTotalUnitsToSpawn == self._nUnitsSpawnedThisRound
end

function CTDGameSpawner:_GetSpawnerInfoByIndex( index )
	local spawnInfo = self._gameRound._gameMode._vSpawnsList[ index ]
	if spawnInfo == nil then
		print( string.format( "Failed to get random spawn info for spawner %s.", self._szName ) )
		return
	end
	self:UpdateSpawnerInfo(spawnInfo)
end

function CTDGameSpawner:UpdateSpawnerInfo(spawnInfo)
	local entSpawner = Entities:FindByName( nil, spawnInfo.szSpawnerName )
	if not entSpawner then
		print( string.format( "Failed to find spawner named %s for %s.", spawnInfo.szSpawnerName, self._szName ) )
		return
	end
	self._vecSpawnLocation = entSpawner:GetAbsOrigin()

	if not self._bDontGiveGoal then
		self._entAirWaypoint = Entities:FindByName( nil, spawnInfo.szAirWaypoint )
		if not self._entAirWaypoint then
			print( string.format( "Failed to find a waypoint named %s for %s.", spawnInfo.szFirstWaypoint, self._szName ) )
			return
		end
	end
	
	if not self._bDontGiveGoal then
		self._entGroundWaypoint = Entities:FindByName( nil, spawnInfo.szGroundWaypoint )
		if not self._entGroundWaypoint then
			print( string.format( "Failed to find a waypoint named %s for %s.", spawnInfo.szFirstWaypoint, self._szName ) )
			return
		end
	end
end

function CTDGameSpawner:_DoSpawn()
	--decide there are any units left to spawn
	if (self._nTotalUnitsToSpawn - self._nUnitsSpawnedThisRound) <= 0 then
		return
	elseif self._nUnitsSpawnedThisRound == 0 then
		print( string.format( "Started spawning %s at %.2f", self._szName, GameRules:GetGameTime() ) )
	end
	
	--decide how many units this spawner has left to spawn
	local nUnitsToSpawn = math.min( self._nUnitsPerSpawn, self._nTotalUnitsToSpawn - self._nUnitsSpawnedThisRound)

	spawnInfo = self:_SearchSpawnTable(self._szSpawnerName)
	self:UpdateSpawnerInfo(spawnInfo)
	
	--get the spawn location
	local vBaseSpawnLocation = self:_GetSpawnLocation()
	if not vBaseSpawnLocation then return end
	
	--spawn the units
	for iUnit = 1,nUnitsToSpawn do
		local bIsChampion = RollPercentage( self._flChampionChance )
		if self._nChampionsSpawnedThisRound >= self._nChampionMax then
			bIsChampion = false
		end

		local szNPCClassToSpawn = self._szNPCClassName
		if bIsChampion and self._szChampionNPCClassName ~= "" then
			szNPCClassToSpawn = self._szChampionNPCClassName
		end

		local vSpawnLocation = vBaseSpawnLocation

		local entUnit = CreateUnitByName( szNPCClassToSpawn, vSpawnLocation, true, nil, nil, DOTA_TEAM_BADGUYS )
        table.insert(self._vAliveSpawnedUnits, entUnit)
--		entUnit:SetMaxHealth(entUnit:GetMaxHealth() * self._gameRound._gameMode._diff["hp"])

		local round = self._roundNumber
		local gold = math.floor(round/5)+1
		local model = self._roundUnit.model
		local unit_name = self._roundUnit.unit_name
		entUnit:SetOriginalModel(model)
		entUnit:SetModel(model)
		entUnit:SetMaximumGoldBounty(gold)				
		entUnit:SetMinimumGoldBounty(gold)
		entUnit:SetUnitName(unit_name)
		
		local base_value = GAME_START_GOLD
		local value_sum = 0
		local income_sum = 0
		local dmg_kf = 7/10
		if round > 1 then
			local k = round - 1
			value_sum = 15*k*(k + 5)
			income_sum = 5*k*(k + 4)
		end
--		print(value_sum)
--		print(income_sum)
		local health =  (base_value + value_sum + income_sum)*dmg_kf*1.12^(round-1)/3
			entUnit:SetMaxHealth(health)
			entUnit:SetBaseMaxHealth(health)
			entUnit:SetHealth(health)
			entUnit:SetMaxHealth(entUnit:GetMaxHealth() * self._gameRound._gameMode._diff["hp"])
			
		local ability = self._roundSpecial
--		print(ability)
		ability = entUnit:AddAbility(ability)
		ability:SetLevel(1)
--		print(model)
--		print(unit_name)
--		print(round)
		
		if entUnit then
			if entUnit:IsCreature() then
				if bIsChampion then
					self._nChampionsSpawnedThisRound = self._nChampionsSpawnedThisRound + 1
					entUnit:CreatureLevelUp( ( self._nChampionLevel - 1 ) )
					entUnit:SetChampion( true )
					local nParticle = ParticleManager:CreateParticle( "heavens_halberd", PATTACH_ABSORIGIN_FOLLOW, entUnit )
					ParticleManager:ReleaseParticleIndex( nParticle )
					entUnit:SetModelScale( 1.1, 0 )
				else
					entUnit:CreatureLevelUp( self._nCreatureLevel - 1 )
				end
			end
			
			if entUnit:HasGroundMovementCapability() then
				self._entWaypoint = self._entGroundWaypoint
			elseif entUnit:HasFlyMovementCapability() then
				self._entWaypoint = self._entAirWaypoint
			end
			
			local entWp = self:_GetSpawnWaypoint()
			entUnit:SetInitialGoalEntity( entWp )

			self._nUnitsSpawnedThisRound = self._nUnitsSpawnedThisRound + 1
			self._nUnitsCurrentlyAlive = self._nUnitsCurrentlyAlive + 1
		end
	end
end


function CTDGameSpawner:StatusReport()
	print( string.format( "** Spawner %s", self._szNPCClassName ) )
	print( string.format( "%d of %d spawned", self._nUnitsSpawnedThisRound, self._nTotalUnitsToSpawn ) )
end
