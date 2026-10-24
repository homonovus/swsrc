AddCSLuaFile()

if CLIENT then
	CreateClientConVar("swsrc_crosshair", "1", true)
	CreateClientConVar("swsrc_crosshaircolor", "0", true, false,
		"Set crosshair color: 0=green, 1=red, 2=blue, 3=yellow, 4=cyan, 5=custom")
	CreateClientConVar("swsrc_dynamiccrosshair", "1", true, false,
		"Enables dynamic crosshair; 0=off, 1=normal behavior (based on actual weapon accuracy), 2=legacy simulated dynamic behavior, 3=legacy simulated static behavior")
	CreateClientConVar("swsrc_crosshairspreadscale", "0.3", true)
	CreateClientConVar("swsrc_scalecrosshair", "1", true)
	CreateClientConVar("swsrc_crosshairscale", "0", true)
	CreateClientConVar("swsrc_crosshairalpha", "200", true)
	CreateClientConVar("swsrc_crosshairusealpha", "0", true)
	CreateClientConVar("swsrc_crosshairsize", "5", true)
	CreateClientConVar("swsrc_crosshairthickness", "0.5", true)
	CreateClientConVar("swsrc_crosshairdot", "0", true)
	CreateClientConVar("swsrc_crosshaircolor_r", "50", true)
	CreateClientConVar("swsrc_crosshaircolor_g", "250", true)
	CreateClientConVar("swsrc_crosshaircolor_b", "50", true)

	CreateClientConVar("swsrc_debug_spread_show", "0", false, false,
		"Enables display of weapon accuracy; 1: show accuracy box, 2: show box with recoil offset")
	CreateClientConVar("swsrc_debug_spread_gap", "0.67", false)

	CreateClientConVar("swsrc_legacy_crosshair_recoil", "0", true, false,
		"Enable legacy framerate dependent crosshair recoil")
	CreateClientConVar("swsrc_legacy_crosshair_scale", "0", true, false, "Enable legacy crosshair scaling")

	CreateClientConVar("swsrc_clean_scope", "0", true)

	CreateClientConVar("swsrc_use_headbob", "1", true)
end

CreateConVar("sv_showimpacts_time", "4", FCVAR_REPLICATED, "Duration bullet impact indicators remain before disappearing")

CreateConVar("swsrc_weapon_accuracy_model", "2", bit.bor(FCVAR_REPLICATED, FCVAR_ARCHIVE))
CreateConVar("swsrc_weapon_accuracy_logging", "0", bit.bor(FCVAR_REPLICATED, FCVAR_ARCHIVE))
CreateConVar("swsrc_knife_damage_scale", "100")
