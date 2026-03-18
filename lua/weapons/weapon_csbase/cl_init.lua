include("shared.lua")

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
