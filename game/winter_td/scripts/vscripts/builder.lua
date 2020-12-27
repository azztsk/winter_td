-- A build ability is used (not yet confirmed)
require("libraries/modifiers/modifier_no_health_bar")

LinkLuaModifier("modifier_no_health_bar", "libraries/modifiers/modifier_no_health_bar", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_attack_disabled", "libraries/modifiers/modifier_attack_disabled", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_silenced", "libraries/modifiers/modifier_silenced", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_autoattack", "towers/attack_modifiers", LUA_MODIFIER_MOTION_NONE)

function Build( event )
    local caster = event.caster
    local ability = event.ability
    local ability_name = ability:GetAbilityName()
    local building_name = ability:GetAbilityKeyValues()['UnitName']
    local gold_cost = ability:GetGoldCost(1) 
    local hero = caster:IsRealHero() and caster or caster:GetOwner()
    local playerID = hero:GetPlayerID()

    -- If the ability has an AbilityGoldCost, it's impossible to not have enough gold the first time it's cast
    -- Always refund the gold here, as the building hasn't been placed yet
    hero:ModifyGold(gold_cost, false, 0)

    -- Makes a building dummy and starts panorama ghosting
    BuildingHelper:AddBuilding(event)

    -- Additional checks to confirm a valid building position can be performed here
    event:OnPreConstruction(function(vPos)

        -- Check for minimum height if defined
        if not BuildingHelper:MeetsHeightCondition(vPos) then
            BuildingHelper:print("Failed placement of " .. building_name .." - Placement is below the min height required")
			CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerID), "error_minimum_height_condition_exceeded", {})
            return false
        end

        -- If not enough resources to queue, stop
        if PlayerResource:GetGold(playerID) < gold_cost then
            BuildingHelper:print("Failed placement of " .. building_name .." - Not enough gold!")
			CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerID), "error_not_enough_gold", {})
            return false
        end
    end)

    -- Position for a building was confirmed and valid
    event:OnBuildingPosChosen(function(vPos)
        -- Spend resources
        hero:ModifyGold(-gold_cost, false, 0)

        -- Play a sound
        EmitSoundOnClient("DOTA_Item.ObserverWard.Activate", PlayerResource:GetPlayer(playerID))
    end)

    -- The construction failed and was never confirmed due to the gridnav being blocked in the attempted area
    event:OnConstructionFailed(function()
        local playerTable = BuildingHelper:GetPlayerTable(playerID)
        local building_name = playerTable.activeBuilding
        BuildingHelper:print("Failed placement of " .. building_name)
		CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerID), "error_building_site_is_blocked", {})
    end)

    -- Cancelled due to ClearQueue
    event:OnConstructionCancelled(function(work)
        local building_name = work.name
        BuildingHelper:print("Cancelled construction of " .. building_name)

        -- Refund resources for this cancelled work
        if work.refund then
            hero:ModifyGold(gold_cost, false, 0)
        end
    end)
	
	event:OnConstructionWouldBlockPath(function(work)
        local playerTable = BuildingHelper:GetPlayerTable(playerID)
        local building_name = playerTable.activeBuilding
        BuildingHelper:print("Failed placement of " .. building_name .. " as it would block the path.")
        if work.refund then
            hero:ModifyGold(gold_cost, false, 0)
        end
		CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerID), "error_building_would_block_paths", {})
    end)

    -- A building unit was created
    event:OnConstructionStarted(function(unit)
        BuildingHelper:print("Started construction of " .. unit:GetUnitName() .. " " .. unit:GetEntityIndex())
        -- Play construction sound

        -- If it's an item-ability and has charges, remove a charge or remove the item if no charges left
        if ability.GetCurrentCharges and not ability:IsPermanent() then
            local charges = ability:GetCurrentCharges()
            charges = charges-1
            if charges == 0 then
                ability:RemoveSelf()
            else
                ability:SetCurrentCharges(charges)
            end
        end

        -- Give item to cancel
        unit.item_building_cancel = CreateItem("item_building_cancel", hero, hero)
        if unit.item_building_cancel then 
            unit:AddItem(unit.item_building_cancel)
            unit.gold_cost = gold_cost
        end

        -- FindClearSpace for the builder
        FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
        caster:AddNewModifier(caster, nil, "modifier_phased", {duration=0.03})

        -- Remove invulnerability on npc_dota_building baseclass
        unit:RemoveModifierByName("modifier_invulnerable")
		unit:AddNewModifier(unit, nil, "modifier_attack_disabled", {})
		unit:AddNewModifier(unit, nil, "modifier_silenced", {})
    end)

    -- A building finished construction
    event:OnConstructionCompleted(function(unit)
        BuildingHelper:print("Completed construction of " .. unit:GetUnitName() .. " " .. unit:GetEntityIndex())
        
        -- Play construction complete sound
        unit.state = "complete"
        -- Remove the item
        if unit.item_building_cancel then
            UTIL_Remove(unit.item_building_cancel)
        end

		unit:AddNewModifier(unit, nil, "modifier_no_health_bar", nil)
		unit:RemoveModifierByName("modifier_attack_disabled")
		unit:RemoveModifierByName("modifier_silenced")
		unit:AddNewModifier(unit, nil, "modifier_autoattack", {})
    end)

    -- These callbacks will only fire when the state between below half health/above half health changes.
    -- i.e. it won't fire multiple times unnecessarily.
    event:OnBelowHalfHealth(function(unit)
        BuildingHelper:print(unit:GetUnitName() .. " is below half health.")
    end)

    event:OnAboveHalfHealth(function(unit)
        BuildingHelper:print(unit:GetUnitName().. " is above half health.")        
    end)
end

-- Called when the Cancel ability-item is used
function CancelBuilding( keys )
    local building = keys.unit
    local hero = building:GetOwner()
    local playerID = building:GetPlayerOwnerID()

    BuildingHelper:print("CancelBuilding "..building:GetUnitName().." "..building:GetEntityIndex())

    -- Refund here
    if building.gold_cost then
        hero:ModifyGold(building.gold_cost, false, 0)
    end

    -- Eject builder
    local builder = building.builder_inside
    if builder then
        BuildingHelper:ShowBuilder(builder)
    end

    building:ForceKill(true) --This will call RemoveBuilding
end


function UpgradeBuilding( event )
    local ability = event.ability
    local building = ability:GetCaster()
    local NewBuildingName = ability:GetAbilityKeyValues()['UnitName']
    local playerID = building:GetPlayerOwnerID()
    local hero = PlayerResource:GetSelectedHeroEntity(playerID)
    local gold_cost = ability:GetGoldCost(1)

    local newBuilding = BuildingHelper:UpgradeBuilding(building,NewBuildingName)
    newBuilding.state = "complete"

    
	if building.gold_cost then
		newBuilding.gold_cost = gold_cost + building.gold_cost
	end
--    PlayerResource:ModifyGold(hero,-gold_cost)
--    hero:ModifyGold(-gold_cost, false, 0)
--     PlayerResource:ModifyLumber(hero,-lumber_cost)
    for i=0, newBuilding:GetAbilityCount()-1 do
        local ability = newBuilding:GetAbilityByIndex(i)
        if ability then
            local constructionCompleModifiers = GetAbilityKV(ability:GetAbilityName(), "ConstructionCompleteModifiers")
            if constructionCompleModifiers then
                for k,modifier in pairs(constructionCompleModifiers) do
                    ability:ApplyDataDrivenModifier(newBuilding, newBuilding, modifier, {})
                end
            end
            local constructionStartModifiers = GetAbilityKV(ability:GetAbilityName(), "ConstructionStartModifiers")
            if constructionStartModifiers then
                for k,modifier in pairs(constructionStartModifiers) do
                    ability:ApplyDataDrivenModifier(newBuilding, newBuilding, modifier, {})
                end
            end
        end
    end
	
	newBuilding:AddNewModifier(newBuilding, nil, "modifier_no_health_bar", nil)
	newBuilding:AddNewModifier(newBuilding, nil, "modifier_autoattack", {})

--[[
    Timers:CreateTimer(buildTime,function()
        for key,value in pairs(hero.units) do
            UpdateUpgrades(value)
        end
        UpdateSpells(hero)
    end)
]]
    UTIL_Remove(building)
end

function CancelUpgradeBuilding( event )
    local building = event.caster
    local ability = event.ability
    local NewBuildingName = ability:GetAbilityKeyValues()['UnitName']
    local playerID = building:GetPlayerOwnerID()
    local hero = PlayerResource:GetSelectedHeroEntity(playerID)
    local gold_cost = ability:GetGoldCost(1)

    hero:ModifyGold(gold_cost, false, 0)

end
