include("shared.lua")

local xhair_enabled = GetConVar("swsrc_crosshair")
local cl_dynamiccrosshair = GetConVar("swsrc_dynamiccrosshair")
local cl_crosshairscale = GetConVar("swsrc_crosshairscale")
local cl_scalecrosshair = GetConVar("swsrc_scalecrosshair")
local cl_crosshaircolor = GetConVar("swsrc_crosshaircolor")
local cl_crosshairalpha = GetConVar("swsrc_crosshairalpha")
local cl_crosshairusealpha = GetConVar("swsrc_crosshairusealpha")

local SWITCH_color = {
	[0] = {50, 250, 50},
	{250, 50,  50},
	{50,  50,  250},
	{250, 250, 50},
	{50,  250, 250},
}

SWEP.m_iAmmoLastCheck = 0
function SWEP:DoDrawCrosshair(x, y)
	if not xhair_enabled:GetBool() then return end

	local selfTable = self:GetTable()

	local owner = self:GetPlayerOwner()
	if not owner then return end

	assert(owner == LocalPlayer() or LocalPlayer():GetObserverMode() == OBS_MODE_IN_EYE)

	local wdat = selfTable.GetWpnData(self)

	if wdat.WeaponType == "SniperRifle" then return end

	local m_flCrosshairDistance = 0

	local iDistance = tonumber(wdat.CrosshairMinDistance) or 0
	local iDeltaDistance = tonumber(wdat.CrosshairDeltaDistance) or 0

	if cl_dynamiccrosshair:GetBool() then
		if not owner:IsOnGround() then
			iDistance = iDistance * 2
		elseif bit.band(owner:GetFlags(), FL_DUCKING) ~= 0 then
			iDistance = iDistance * 0.5
		elseif owner:GetVelocity():Length() > 100 then
			iDistance = iDistance * 1.5
		end
	end

	if selfTable.GetShotsFired(self) > selfTable.m_iAmmoLastCheck then
		m_flCrosshairDistance = math.min(15, m_flCrosshairDistance + iDeltaDistance)
	elseif m_flCrosshairDistance > iDistance then
		m_flCrosshairDistance = m_flCrosshairDistance - 0.1 + m_flCrosshairDistance * 0.013
	end

	selfTable.m_iAmmoLastCheck = selfTable.GetShotsFired(self)

	if m_flCrosshairDistance < iDistance then
		m_flCrosshairDistance = iDistance
	end

	local sw, sh = ScrW(), ScrH()

	local crosshairScale = cl_crosshairscale:GetInt()
	if crosshairScale < 1 then
		if sh <= 600 then
			crosshairScale = 600
		elseif sh <= 768 then
			crosshairScale = 768
		else
			crosshairScale = 1200
		end
	end

	local scale
	if cl_scalecrosshair:GetBool() == false then
		scale = 1
	else
		scale = sh / crosshairScale
	end

	local iCrosshairDistance = math.ceil(m_flCrosshairDistance * scale)

	local iBarSize = (5 * (sw / 640)) + (iCrosshairDistance - iDistance) / 2
	iBarSize = math.max(1, iBarSize * scale)

	local iBarThickness = math.max(1, math.floor(scale + 0.5))

	local r, g, b = unpack(SWITCH_color[cl_crosshaircolor:GetInt()] or SWITCH_color[0])

	-- if user is using nightvision, make the crosshair red.
	--if nv then r,g,b = unpack(SWITCH_color[1]) end

	local useAlpha = cl_crosshairusealpha:GetBool()
	local alpha = math.Clamp(cl_crosshairalpha:GetInt(), 0, 255)
	surface.SetDrawColor(r, g, b, alpha)

	if not selfTable.m_iCrosshairTextureID then
		selfTable.m_iCrosshairTextureID = surface.GetTextureID("vgui/white_additive")
	end

	if not useAlpha then
		surface.SetDrawColor(r, g, b, 200)
		surface.SetTexture(selfTable.m_iCrosshairTextureID)
	end

	local iHalfScreenWidth = 0
	local iHalfScreenHeight = 0

	local iLeft = iHalfScreenWidth - (iCrosshairDistance + iBarSize)
	local iRight = iHalfScreenWidth + iCrosshairDistance + iBarThickness
	local iFarLeft = iBarSize
	local iFarRight = iBarSize

	local drawFunc = surface.DrawRect
	if not useAlpha --[[and not nv]] then
		drawFunc = surface.DrawTexturedRect
	end

	drawFunc(x + iLeft, y + iHalfScreenHeight, iFarLeft, iHalfScreenHeight + iBarThickness)
	drawFunc(x + iRight, y + iHalfScreenHeight, iFarRight, iHalfScreenHeight + iBarThickness)

	local iTop = iHalfScreenHeight - (iCrosshairDistance + iBarSize)
	local iBottom = iHalfScreenHeight + iCrosshairDistance + iBarThickness
	local iFarTop = iBarSize
	local iFarBottom = iBarSize

	drawFunc(x + iHalfScreenWidth, y + iTop, iHalfScreenWidth + iBarThickness, iFarTop)
	drawFunc(x + iHalfScreenWidth, y + iBottom, iHalfScreenWidth + iBarThickness, iFarBottom)

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
