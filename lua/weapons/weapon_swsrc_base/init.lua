include("shared.lua")

local VECTOR_CONE_8DEGREES = Vector(0.06976, 0.06976, 0.06976)
function SWEP:GetBulletSpread()
	return VECTOR_CONE_8DEGREES
end

function SWEP:BulletWasFired(vecStart, vecEnd)
	return vecStart, vecEnd
end
