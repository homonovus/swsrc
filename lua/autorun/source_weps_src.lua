local swsrc = swsrc or {}
_G.swsrc = swsrc

include("swsrc/classes/KeyValues.lua")
include("swsrc/sh_cvars.lua")
include("swsrc/sh_player.lua")
include("swsrc/sh_util.lua")

hook.Add("SetupMove", "swsrc.movement", function(ply, move, cmd)
	if not ply:IsValid() then return end

	local plyTable = ply:GetTable()

	local wep = ply:GetActiveWeapon()

	-- shootpos behind 1 tick according to swcs
	plyTable.m_vSavedShootPos = ply:GetShootPos()

	if ply:GetNWBool("m_bIsDefusing", false) then
		move:SetMaxClientSpeed(1)
		move:SetMaxSpeed(1)

		-- remove IN_JUMP
		move:SetButtons(bit.band(move:GetButtons(), bit.bnot(IN_JUMP)))
	end

	if wep:IsValid() then
		local wepTable = wep:GetTable()
		if wepTable.IsSWSrcWeapon then
			local flMaxSpeed = wepTable.GetMaxSpeed and wepTable.GetMaxSpeed(wep) or 250
			local mult = flMaxSpeed / 250
			if mult < 0 then
				mult = 1
			end

			-- freeze
			if flMaxSpeed == 0 then
				move:SetMaxClientSpeed(1)
				move:SetMaxSpeed(1)
			else
				move:SetMaxClientSpeed(move:GetMaxClientSpeed() * mult)
				move:SetMaxSpeed(move:GetMaxSpeed() * mult)
			end

			-- TODO: all of the above is from swcs, see if theres any more that needs to be copied
			--       or anything else cs:s does
		end
	end
end)

if CLIENT then
	list.Set("ContentCategoryIcons", language.GetPhrase("#spawnmenu.category.swsrc"), "games/16/cstrike.png")
end
