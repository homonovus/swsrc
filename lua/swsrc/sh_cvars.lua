AddCSLuaFile()

if CLIENT then
	CreateClientConVar("swsrc_crosshair", "1", true)
	CreateClientConVar("swsrc_crosshaircolor", "0", true)
	CreateClientConVar("swsrc_dynamiccrosshair", "1", true)
	CreateClientConVar("swsrc_scalecrosshair", "1", true)
	CreateClientConVar("swsrc_crosshairscale", "0", true)
	CreateClientConVar("swsrc_crosshairalpha", "200", true)
	CreateClientConVar("swsrc_crosshairusealpha", "0", true)
	CreateClientConVar("swsrc_use_headbob", "1", true)
end

CreateConVar("swsrc_weapon_accuracy_model", "2", bit.bor(FCVAR_REPLICATED, FCVAR_ARCHIVE))
