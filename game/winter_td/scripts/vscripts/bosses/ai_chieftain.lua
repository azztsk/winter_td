function Spawn( entityKeyValues )
	ABILITY_stun = thisEntity:FindAbilityByName( "chieftain_stomp" )
	--math.randomseed(GameRules:GetGameTime())
	EmitGlobalSound("Hero_ElderTitan.EchoStomp")
	EmitGlobalSound("elder_titan_elder_levelup_15")
	thisEntity:SetContextThink( "ChieftainThink", ChieftainThink, 14 )
end

function ChieftainThink()
	if thisEntity:IsNull() or not thisEntity:IsAlive() then
		return nil -- deactivate this think function
	end

	t = math.random(14, 20)
	local radius = ABILITY_stun:GetSpecialValueFor("%stomp_radius")
	local targets = FindUnitsInRadius(
		thisEntity:GetTeam(), 
		thisEntity:GetAbsOrigin(), 
		nil, 
		100,
		DOTA_UNIT_TARGET_TEAM_ENEMY, 
		DOTA_UNIT_TARGET_ALL, 
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_ANY_ORDER, 
		false)

	if #targets > 0 then
		thisEntity:CastAbilityNoTarget(ABILITY_stun, -1)
		return t
	end
	return t 
end
