--require("td_game_round")
function PathEnd(keys)
	local unit = keys.activator
    if (unit:IsOwnedByAnyPlayer() ) and unit  then
        -- Is player owned - Ignore

    else
		-- Is not owned by player - Terminate
		--TODO: add a particle
		local effect = "particles/units/heroes/hero_lina/lina_spell_laguna_blade_startpoint.vpcf"
		local pfx = ParticleManager:CreateParticle(effect, PATTACH_ABSORIGIN_FOLLOW, unit)
		ParticleManager:SetParticleControl(pfx, 0, unit:GetAbsOrigin()) -- Origin
		ParticleManager:ReleaseParticleIndex(pfx)
		
		EmitGlobalSound("Portal.Hero_Disappear")
		
		if unit:HasAbility("creature_boss") then
			GameRules.CTDGameMode:LifeLost(5)
		else
			GameRules.CTDGameMode:LifeLost(1)
		end

		GameRules.CTDGameMode:GetCurrentRound():OnEntityRemoved(unit)
		UTIL_Remove(unit)

	
    end
end
