--[[
Wintermaul

	Underscore prefix such as "_function()" denotes a local function and is used to improve readability

	Variable Prefix Examples
		"fl"	Float
		"n"		Int
		"v"		Table
		"b"		Boolean
]]

if CTDGameMode == nil then
	_G.CTDGameMode = class({})		-- I believe the _G prefix specifies a global class
end

require('builder')

require('libraries/buildinghelper')
require('libraries/selection')
require('libraries/keyvalues')
require('libraries/notifications')
require('libraries/timers')
require('libraries/utility')

require("td_game_round")
require("td_game_spawner")
require('gamemode')

--essential. loads the unit and model needed into memory
function Precache( context )

	PrecacheUnitByNameSync("npc_dota_hero_elder_titan", context)
	PrecacheResource("particle","particles/units/heroes/hero_elder_titan/elder_titan_echo_stomp_physical.vpcf", context)
	PrecacheUnitByNameSync("npc_dota_hero_abaddon", context)
	PrecacheResource("particle","particles/econ/items/abaddon/abaddon_alliance/abaddon_aphotic_shield_alliance_explosion.vpcf", context)
	-- Model ghost and grid particles
	PrecacheResource("particle_folder", "particles/buildinghelper", context)
	PrecacheItemByNameSync("item_apply_modifiers", context)
	
	--Fire towers
	PrecacheUnitByNameSync("flare_tower", context)
	PrecacheUnitByNameSync("flame_dancer", context)
	PrecacheUnitByNameSync("meteor_watcher", context)
	PrecacheUnitByNameSync("blast_furnace", context)
	PrecacheUnitByNameSync("incinerator", context)
	PrecacheUnitByNameSync("flame_staff", context)

	PrecacheResource("particle","particles/base_attacks/ranged_badguy.vpcf", context)
	PrecacheResource("particle","particles/units/heroes/hero_jakiro/jakiro_macropyre_projectile.vpcf", context)
	PrecacheResource("particle","particles/units/heroes/hero_luna/luna_eclipse_impact.vpcf", context)
	PrecacheResource("particle","particles/units/heroes/hero_dragon_knight/dragon_knight_breathe_fire_b.vpcf", context)
	PrecacheResource("particle","particles/units/heroes/hero_lina/lina_base_attack.vpcf", context)
	PrecacheResource("particle","particles/units/heroes/hero_invoker/invoker_chaos_meteor.vpcf", context)
	
	--Crystal towers
	for index = 1,6 do
		PrecacheUnitByNameSync("tower_demon_"..index,context)
		PrecacheUnitByNameSync("tower_ice_"..index,context)
		PrecacheUnitByNameSync("tower_random_"..index,context)
		PrecacheUnitByNameSync("tower_ranger_"..index,context)
		PrecacheUnitByNameSync("tower_warrior_"..index,context)
		PrecacheUnitByNameSync("tower_gold_"..index,context)	
	end
	PrecacheUnitByNameSync("npc_dota_flying_unit",context)	
	PrecacheUnitByNameSync("npc_dota_boss_unit",context)	
	PrecacheUnitByNameSync("npc_dota_ground_unit",context)	
--alchemist towers
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_winter_wyvern.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_crystalmaiden.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_tusk.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_ancient_apparition.vsndevts", context )
--alchemist towers
	PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_sniper.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_sniper.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_rubick.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_rubick.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_alchemist.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_alchemist.vsndevts", context )
--mars towers
	PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_dragon_knight.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_dragon_knight.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_phantom_assassin.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_phantom_assassin.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_ursa.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_ursa.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_sven.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_sven.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_chaos_knight.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_chaos_knight.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_elder_titan.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_elder_titan.vsndevts", context )
--drow ranger towers
	PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_windrunner.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_windrunner.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_luna.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_luna.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_enchantress.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_enchantress.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_vengefulspirit.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_vengefulspirit.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_drowranger.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_drowranger.vsndevts", context )
	
	PrecacheResource("particle","particles/units/heroes/hero_tinker/tinker_laser.vpcf",context)
	PrecacheResource("particle","particles/units/heroes/hero_oracle/oracle_base_attack.vpcf",context)
	PrecacheResource("particle","particles/econ/items/enigma/enigma_geodesic/enigma_base_attack_eidolon_geodesic.vpcf",context)
	PrecacheResource("particle","particles/base_attacks/fountain_attack.vpcf",context)


	PrecacheResource("particle","particles/units/heroes/hero_morphling/morphling_base_attack.vpcf",context)
	PrecacheResource("particle","particles/base_attacks/ranged_hero.vpcf",context)
	PrecacheResource("particle","particles/units/heroes/hero_enchantress/enchantress_base_attack.vpcf",context)

	PrecacheResource("particle","particles/units/heroes/hero_enchantress/enchantress_base_attack.vpcf",context)
	
	print( "Precaching is complete." )
end

function Activate()
	Convars:SetBool("sv_cheats", true)
	--activates the mod.
	GameRules.CTDGameMode = CTDGameMode()
	--calls InitGameMode
	GameRules.CTDGameMode:InitGameMode()
end