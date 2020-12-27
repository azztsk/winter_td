
function GiveGoldPerAttack( event )
	local caster = event.caster
	local ability = event.ability	
	local gold_per_tick = ability:GetSpecialValueFor("gold_per_attack")

	PlayerResource:ModifyGold( caster:GetPlayerOwnerID(), gold_per_tick, false, 0 )
	
    pidx = ParticleManager:CreateParticleForTeam("particles/msg_fx/msg_xp.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster, caster:GetTeamNumber())
    ParticleManager:SetParticleControl(pidx, 1, Vector(0, gold_per_tick, 0))
    ParticleManager:SetParticleControl(pidx, 2, Vector(3, 2, 0))
    ParticleManager:SetParticleControl(pidx, 3, Vector(255,255,20))
	
--	SendOverheadEventMessage( target, OVERHEAD_ALERT_GOLD, target, gold_per_tick, nil )

end


