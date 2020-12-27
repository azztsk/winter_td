function PercentageDamage(keys)
	local caster = keys.caster
	local radius = keys.radius
	local target = keys.target
	local percentageDmg = target:GetHealth()*0.25
	local newHealth = target:GetHealth()-percentageDmg
	--print(caster,"; ",target,"; ",percentageDmg,"; ",newHealth)
	--if newHealth > 1 then
	local damageTable = {
		victim = target,
		attacker = caster,
		damage = percentageDmg,
		damage_type = DAMAGE_TYPE_PHYSICAL,
	}
	ApplyDamage(damageTable)
	--end
end