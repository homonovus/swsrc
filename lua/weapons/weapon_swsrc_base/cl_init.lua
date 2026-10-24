include("shared.lua")

local xhair_enabled = GetConVar("swsrc_crosshair")
local cl_dynamiccrosshair = GetConVar("swsrc_dynamiccrosshair")
local cl_crosshairspreadscale = GetConVar("swsrc_crosshairscale")
local cl_crosshairscale = GetConVar("swsrc_crosshairscale")
local cl_scalecrosshair = GetConVar("swsrc_scalecrosshair")
local cl_crosshaircolor = GetConVar("swsrc_crosshaircolor")
local cl_crosshairalpha = GetConVar("swsrc_crosshairalpha")
local cl_crosshairusealpha = GetConVar("swsrc_crosshairusealpha")
local cl_crosshairsize = GetConVar("swsrc_crosshairsize")
local cl_crosshairthickness = GetConVar("swsrc_crosshairthickness")
local cl_crosshairdot = GetConVar("swsrc_crosshairdot")
local cl_crosshaircolor_r = GetConVar("swsrc_crosshaircolor_r")
local cl_crosshaircolor_g = GetConVar("swsrc_crosshaircolor_g")
local cl_crosshaircolor_b = GetConVar("swsrc_crosshaircolor_b")

local weapon_debug_spread_show = GetConVar("swsrc_debug_spread_show")
local weapon_debug_spread_gap = GetConVar("swsrc_debug_spread_gap")

local cl_legacy_crosshair_recoil = GetConVar("swsrc_legacy_crosshair_recoil")
local cl_legacy_crosshair_scale = GetConVar("swsrc_legacy_crosshair_scale")

local SWITCH_color = {
	[0] = {50, 250, 50},
	{250, 50,  50},
	{50,  50,  250},
	{250, 250, 50},
	{50,  250, 250},
}

local function DrawCrosshairRect(x0, y0, x1, y1, bAdditive)
	if bAdditive then
		surface.DrawTexturedRect(x0, y0, x1, y1)
	else
		surface.DrawRect(x0, y0, x1, y1)
	end
end

SWEP.m_iAmmoLastCheck = 0
function SWEP:DoDrawCrosshair(x, y)
	if not xhair_enabled:GetBool() then return end

	local selfTable = self:GetTable()

	local owner = self:GetPlayerOwner()
	if not owner then return end

	assert(owner == LocalPlayer() or LocalPlayer():GetObserverMode() == OBS_MODE_IN_EYE)

	local col = cl_crosshaircolor:GetInt()
	local r, g, b = unpack(SWITCH_color[col] or SWITCH_color[0])
	if col == 5 then
		r = cl_crosshaircolor_r:GetInt()
		g = cl_crosshaircolor_g:GetInt()
		b = cl_crosshaircolor_b:GetInt()
	end

	-- if user is using nightvision, make the crosshair red.
	--if nv then r,g,b = unpack(SWITCH_color[1]) end

	local bAdditive = cl_crosshairusealpha:GetBool() -- or nv
	local alpha = math.Clamp(cl_crosshairalpha:GetInt(), 0, 255)
	surface.SetDrawColor(r, g, b, alpha)

	if not selfTable.m_iCrosshairTextureID then
		selfTable.m_iCrosshairTextureID = surface.GetTextureID("vgui/white_additive")
	end

	if not bAdditive then
		surface.SetDrawColor(r, g, b, 200)
		surface.SetTexture(selfTable.m_iCrosshairTextureID)
	end

	local wdat = selfTable.CSWpnData

	local bCrosshairVisible = wdat.m_WeaponType ~= WEAPONTYPE_SNIPER_RIFLE
	if not bCrosshairVisible and not weapon_debug_spread_show:GetBool() then return true end

	local fHalfFov = math.rad(owner:GetFOV())

	local m_flCrosshairDistance = 0
	local iCrosshairDistance = 0
	local iBarSize = math.floor(ScreenScaleH(cl_crosshairsize:GetFloat()))
	local iBarThickness = math.max(1, math.floor(ScreenScaleH(cl_crosshairthickness:GetFloat())))

	local dynamic = cl_dynamiccrosshair:GetInt()
	local mode = selfTable.GetWeaponMode(self)
	if dynamic == 0 then
		-- static crosshair
		local fSpread = wdat.m_fSpread[mode] + wdat.m_fInaccuracyStand[mode] * 320 / math.tan(fHalfFov)
		iCrosshairDistance = math.max(0, math.floor(ScreenScaleH(fSpread * cl_crosshairspreadscale:GetFloat())))
	elseif dynamic == 1 then
		local fSpread = (selfTable.GetInaccuracy(self) + selfTable.GetSpread(self)) * 320 / math.tan(fHalfFov)
		iCrosshairDistance = math.max(0, math.floor(ScreenScaleH(fSpread * cl_crosshairspreadscale:GetFloat())))
	elseif dynamic == 2 or dynamic == 3 then
		local fCrosshairDistanceGoal = wdat.m_iCrosshairMinDistance

		if dynamic == 2 then
			if not owner:IsOnGround() then
				fCrosshairDistanceGoal = fCrosshairDistanceGoal * 2
			elseif bit.band(owner:GetFlags(), FL_DUCKING) ~= 0 then
				fCrosshairDistanceGoal = fCrosshairDistanceGoal * 0.5
			elseif owner:GetVelocity():Length() > 100 then
				fCrosshairDistanceGoal = fCrosshairDistanceGoal * 1.5
			end
		end

		local iDeltaDistance = wdat.m_iCrosshairDeltaDistance
		if selfTable.GetShotsFired(self) > selfTable.m_iAmmoLastCheck then
			fCrosshairDistanceGoal = fCrosshairDistanceGoal + iDeltaDistance
		end

		selfTable.m_iAmmoLastCheck = selfTable.GetShotsFired(self)

		if m_flCrosshairDistance > fCrosshairDistanceGoal then
			if not cl_legacy_crosshair_recoil:GetBool() then
				-- .44888 on the next line makes the decay very close to what old method produces at 100fps.
				m_flCrosshairDistance = Lerp(math.exp(-FrameTime() / 0.44888), fCrosshairDistanceGoal, m_flCrosshairDistance)
			else
				m_flCrosshairDistance = m_flCrosshairDistance - 0.1 + m_flCrosshairDistance * 0.013
			end
		end

		m_flCrosshairDistance = math.Clamp(m_flCrosshairDistance, fCrosshairDistanceGoal, 25)

		if cl_legacy_crosshair_scale:GetBool() then
			local crosshairScale = cl_crosshairscale:GetInt()
			if crosshairScale < 1 then
				local sh = ScrH()
				if sh <= 600 then
					crosshairScale = 600
				elseif sh <= 768 then
					crosshairScale = 768
				else
					crosshairScale = 1200
				end
			end

			local scale
			if not cl_scalecrosshair:GetBool() then
				scale = 1
			else
				scale = ScrH() / crosshairScale
			end

			iCrosshairDistance = math.floor(m_flCrosshairDistance * scale)

			iBarSize = ScreenScale(5)
			iBarSize = math.max(1, math.floor(iBarSize * scale))
			iBarThickness = math.max(1, math.floor(scale + 0.5))
		else
			iCrosshairDistance = math.floor(m_flCrosshairDistance * ScrH() / 1200)
		end
	end

	if bCrosshairVisible then
		-- draw horizontal crosshair lines
		local iLeft = -(iCrosshairDistance + iBarSize)
		local iRight = iCrosshairDistance + iBarThickness
		local iFarLeft = iBarSize
		local iFarRight = iBarSize
		DrawCrosshairRect(x + iLeft, y, iFarLeft, iBarThickness, bAdditive)
		DrawCrosshairRect(x + iRight, y, iFarRight, iBarThickness, bAdditive)

		-- draw vertical crosshair lines
		local iTop = -(iCrosshairDistance + iBarSize)
		local iBottom = iCrosshairDistance + iBarThickness
		local iFarTop = iBarSize
		local iFarBottom = iBarSize
		DrawCrosshairRect(x, y + iTop, iBarThickness, iFarTop, bAdditive)
		DrawCrosshairRect(x, y + iBottom, iBarThickness, iFarBottom, bAdditive)

		-- draw dot
		if cl_crosshairdot:GetBool() then
			local x0 = iBarThickness / 2
			local x1 = iBarThickness
			local y0 = iBarThickness / 2
			local y1 = iBarThickness
			DrawCrosshairRect(x + x0, y + y0, x1, y1, bAdditive)
		end
	end

	-- show accuracy brackets
	local spreadShow = weapon_debug_spread_show:GetInt()
	if spreadShow == 1 or spreadShow == 2 then
		if spreadShow == 2 then
			local punchAngles = owner:GetViewPunchAngles()
			local vecDirShooting = Vector()
			swsrc.AngleVectors(punchAngles, vecDirShooting)

			local iOffsetX = math.floor(ScreenScaleH(vecDirShooting.y * 320 / math.tan(fHalfFov)))
			local iOffsetY = math.floor(ScreenScaleH(vecDirShooting.z * 320 / math.tan(fHalfFov)))

			x = y - iOffsetX
			y = y - iOffsetY
		end

		r, g, b = unpack(SWITCH_color[3])
		surface.SetDrawColor(r, g, b, alpha)

		local iBarThickness = math.max(1, math.floor(ScreenScaleH(cl_crosshairthickness:GetFloat())))

		local fSpreadDistance = (selfTable.GetInaccuracy(self) + selfTable.GetSpread(self)) * 320 / math.tan(fHalfFov)
		local iSpreadDistance = math.floor(ScreenScaleH(fSpreadDistance))

		-- draw vertical spread lines
		local iInnerLeft = -iSpreadDistance
		local iInnerRight = iSpreadDistance
		local iOuterLeft = iBarThickness
		local iOuterRight = iBarThickness
		local iInnerTop = -iSpreadDistance
		local iInnerBottom = iSpreadDistance
		local iOuterTop = iBarThickness
		local iOuterBottom = iBarThickness

		local iGap = math.ceil(weapon_debug_spread_gap:GetFloat() * iSpreadDistance)

		-- draw horizontal lines
		DrawCrosshairRect(x + iOuterLeft, y + iOuterTop, iGap, iInnerTop, bAdditive)
		DrawCrosshairRect(x + iGap, y + iOuterTop, iOuterRight, iInnerTop, bAdditive)
		DrawCrosshairRect(x + iOuterLeft, y + iInnerBottom, iGap, iOuterBottom, bAdditive)
		DrawCrosshairRect(x + iGap, y + iInnerBottom, iOuterRight, iOuterBottom, bAdditive)

		-- draw vertical lines
		DrawCrosshairRect(x + iOuterLeft, y + iOuterTop, iInnerLeft, iGap, bAdditive)
		DrawCrosshairRect(x + iOuterLeft, y + iGap, iInnerLeft, iOuterBottom, bAdditive)
		DrawCrosshairRect(x + iInnerRight, y + iOuterTop, iOuterRight, iGap, bAdditive)
		DrawCrosshairRect(x + iInnerRight, y + iGap, iOuterRight, iOuterBottom, bAdditive)
	end

	return true
end

local bob_enabled = GetConVar("swsrc_use_headbob")
-- shared with swcs lol cope
local cl_bobcycle = CreateConVar("cl_bobcycle", "0.98", FCVAR_ARCHIVE, "the frequency at which the viewmodel bobs.", 0.1,
	2.0)
local cl_bob = CreateConVar("cl_bob", "0.002")
local cl_bobup = CreateConVar("cl_bobup", "0.5")

function SWEP:CalcViewmodelBob()
	local lateralBob, verticalBob = 0, 0

	local bobtime, lastbobtime, lastspeed, cycle = 0, 0, 0, 0

	local owner = self:GetPlayerOwner()

	local _bobup = cl_bobup:GetFloat()
	local _bobcycle = cl_bobcycle:GetFloat()
	if not owner or _bobcycle <= 0 or _bobup <= 0 or _bobup >= 1 then return lateralBob, verticalBob end

	local speed = owner:GetVelocity():Length2D()
	local flmaxSpeedDelta = math.max(0, (CurTime() - lastbobtime) * 320)

	speed = math.Clamp(speed, lastspeed - flmaxSpeedDelta, lastspeed + flmaxSpeedDelta)
	speed = math.Clamp(speed, -320, 320)

	lastspeed = speed

	local bob_offset = math.Remap(speed, 0, 320, 0, 1)

	bobtime = bobtime + (CurTime() - lastbobtime) * bob_offset
	lastbobtime = CurTime()

	--
	cycle = lastbobtime - math.floor(bobtime / _bobcycle) * _bobcycle
	cycle = cycle / _bobcycle

	if cycle < _bobup then
		cycle = math.pi * cycle / _bobup
	else
		cycle = math.pi + math.pi * (cycle - _bobup) / (1 - _bobup)
	end

	verticalBob = speed * 0.005
	verticalBob = verticalBob * 0.3 + verticalBob * 0.7 * math.sin(cycle)

	verticalBob = math.Clamp(verticalBob, -7, 4)

	cycle = bobtime - math.floor(bobtime / _bobcycle * 2) * _bobcycle * 2
	cycle = cycle / _bobcycle * 2

	if cycle < _bobup then
		cycle = math.pi * cycle / _bobup
	else
		cycle = math.pi + math.pi * (cycle - _bobup) / (1 - _bobup)
	end

	lateralBob = speed * 0.005
	lateralBob = lateralBob * 0.3 + lateralBob * 0.7 * math.sin(cycle)
	lateralBob = math.Clamp(lateralBob, -7, 4)

	return lateralBob, verticalBob
end

local VectorMA
do
	local VECTOR = FindMetaTable("Vector")
	---@diagnostic disable: need-check-nil
	local VUnpack = VECTOR.Unpack
	local VSetUnpacked = VECTOR.SetUnpacked
	---@diagnostic enable: need-check-nil

	VectorMA = function(start, scale, dir, dest)
		local startX, startY, startZ = VUnpack(start)
		local dirX, dirY, dirZ = VUnpack(dir)

		VSetUnpacked(dest,
			startX + scale * dirX,
			startY + scale * dirY,
			startZ + scale * dirZ
		)
	end
end

function SWEP:AddViewmodelBob(vm, pos, ang)
	local forward = ang:Forward()
	--local right = ang:Right()

	local lateralBob, verticalBob = self:CalcViewmodelBob()

	VectorMA(pos, verticalBob * 0.4, forward, pos)

	pos.z = pos.z + verticalBob * 0.1

	ang.r = ang.r + verticalBob * 0.5
	ang.p = ang.p - verticalBob * 0.4

	ang.y = ang.y - lateralBob * 0.3

	-- VectorMA(pos, lateralBob * 0.2, right, pos)
end

function SWEP:CalcViewModelView(vm, _, _, pos, ang)
	if bob_enabled:GetBool() then
		self:AddViewmodelBob(vm, pos, ang)
	end

	return pos, ang
end
