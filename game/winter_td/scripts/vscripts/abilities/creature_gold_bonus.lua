
function GoldBonus( keys )
	local caster = keys.caster
	local ability = keys.ability
	local gold_multiplier = ability:GetSpecialValueFor("bonus_value")
	caster:SetMaximumGoldBounty(caster:GetMaximumGoldBounty()*gold_multiplier)				
	caster:SetMinimumGoldBounty(caster:GetMinimumGoldBounty()*gold_multiplier)
end


