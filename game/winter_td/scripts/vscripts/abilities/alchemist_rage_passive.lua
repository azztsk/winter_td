LinkLuaModifier("modifier_alchemist_rage_passive", "abilities/alchemist_rage_passive", LUA_MODIFIER_MOTION_NONE)

alchemist_rage_passive = class({})

function alchemist_rage_passive:GetIntrinsicModifierName()
	return "modifier_alchemist_rage_passive"
end

modifier_alchemist_rage_passive = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
--	GetAttributes 			= function(self) return MODIFIER_ATTRIBUTE_MULTIPLE end,
	DeclareFunctions		= function(self) return 
		{MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS} end,
})

function modifier_alchemist_rage_passive:GetActivityTranslationModifiers()
	return "chemical_rage"
end