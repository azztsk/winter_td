
function GetHealthBonus( keys )
	local caster = keys.caster
	local ability = keys.ability
	local health_multiplier = ability:GetSpecialValueFor("bonus_value")/100+1
	local hp = caster:GetMaxHealth()*health_multiplier
	caster:SetMaxHealth(hp)
	caster:SetBaseMaxHealth(hp)
	caster:SetHealth(hp)
end


