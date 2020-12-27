if not Attacks then
    Attacks = class({})
end

function Attacks:Init()
    -- Build NetTable with the attacks enabled
    for name,values in pairs(GameRules.UnitKV) do
        if type(values)=="table" and values['AttacksEnabled'] then
            CustomNetTables:SetTableValue("attacks_enabled", name, {enabled = values['AttacksEnabled']})
        end
    end
end

-- Ground/Air Attack mechanics
function UnitCanAttackTarget( unit, target )
    if not target.IsCreature then return true end -- filter item drops
    local attacks_enabled = unit:GetKeyValue("AttacksEnabled")
    local target_type = target:HasFlyMovementCapability() and "air" or "ground"
  
    if not unit:HasAttackCapability() or unit:IsDisarmed() or target:IsInvulnerable() or target:IsAttackImmune() or not unit:CanEntityBeSeenByMyTeam(target) then
            return false
    end

    return string.match(attacks_enabled, target_type)
end