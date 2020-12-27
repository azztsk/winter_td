function PopupAlchemistGold(target, number, player)
    local symbol = 0 -- "+" presymbol
    local color = Vector(255, 200, 33) -- Gold
    local lifetime = 3
    local digits = string.len(number) + 1
    local particleName = "particles/units/heroes/hero_alchemist/alchemist_lasthit_msg_gold.vpcf"
    local particle = ParticleManager:CreateParticleForPlayer(particleName, PATTACH_CUSTOMORIGIN, target, player or target:GetPlayerOwner())
    ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 1, Vector(symbol, number, symbol))
    ParticleManager:SetParticleControl(particle, 2, Vector(lifetime, digits, 0))
    ParticleManager:SetParticleControl(particle, 3, color)
end