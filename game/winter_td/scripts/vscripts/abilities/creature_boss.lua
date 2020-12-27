
function GetHealthBonus( keys )
	local caster = keys.caster
	local ability = keys.ability
	local health_multiplier = ability:GetSpecialValueFor("health_multiplier")
	local model_scale = ability:GetSpecialValueFor("model_scale")
	local hp = caster:GetMaxHealth()*health_multiplier

	caster:SetMaximumGoldBounty(caster:GetMaximumGoldBounty()*health_multiplier)				
	caster:SetMinimumGoldBounty(caster:GetMinimumGoldBounty()*health_multiplier)
	caster:SetMaxHealth(hp)
	caster:SetBaseMaxHealth(hp)
	caster:SetHealth(hp)
	caster:SetModelScale(model_scale)
end


