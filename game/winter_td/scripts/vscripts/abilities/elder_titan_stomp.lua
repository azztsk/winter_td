
function TitanStomp( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local stun_duration = ability:GetSpecialValueFor("stun_duration")
	local radius = ability:GetSpecialValueFor("radius")
	local damage = ability:GetSpecialValueFor("damage")

	EmitSoundOn("Hero_ElderTitan.EchoStomp",caster)
	
--	local effect = "particles/units/heroes/hero_centaur/centaur_warstomp.vpcf"
	local effect = "particles/units/heroes/hero_elder_titan/elder_titan_echo_stomp_physical.vpcf"
	local pfx = ParticleManager:CreateParticle(effect, PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(pfx, 0, caster:GetAbsOrigin()) -- Origin
--	ParticleManager:SetParticleControl(pfx, 1, Vector(radius, radius, radius)) -- Destination

	local enemies = FindUnitsInRadius(caster:GetTeam(), 
									caster:GetAbsOrigin(), 
									nil, 
									radius, 
									DOTA_UNIT_TARGET_TEAM_ENEMY, 
									DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 
									DOTA_UNIT_TARGET_FLAG_NONE, 
									FIND_ANY_ORDER, false)
	
	for i=1,#enemies do
		local enemy = enemies[i]
		ApplyDamage({victim = enemy, attacker = caster, ability = ability, damage_type = DAMAGE_TYPE_PHYSICAL, damage = damage})
--		ability:DealDamage(caster, enemy, damage, DAMAGE_TYPE_PHYSICAL, nil, ability)
		enemy:AddNewModifier(caster, ability, "modifier_stunned", {duration = stun_duration})
	end
end