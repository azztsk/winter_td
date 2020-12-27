-- called when a sell_tower_x ability is cast
require('libraries/buildinghelper')
function UpgradeTower(keys)
    local building = keys.caster
    local newBuildingName = keys.new_tower_name
    if building:GetHealth() == building:GetMaxHealth() then -- only allow selling if the building is fully built
        local newBuilding = BuildingHelper:UpgradeBuilding(building, newBuildingName)
        newBuilding.gold_cost = GameRules.AbilityKV[keys.ability:GetAbilityName()].AbilityGoldCost + building.gold_cost
    end
end