---Euler QAngle -> Basis Vectors.  Each vector is optional
---@param angles Angle
---@param forward Vector
---@param right Vector?
---@param up Vector?
function swsrc.AngleVectors(angles, forward, right, up)
	local ry = math.rad(angles.y)
	local rp = math.rad(angles.p)
	local rr = math.rad(angles.r)

	local sy, cy = math.sin(ry), math.cos(ry)
	local sp, cp = math.sin(rp), math.cos(rp)
	local sr, cr = math.sin(rr), math.cos(rr)

	if forward ~= nil then
		forward.x = cp * cy
		forward.y = cp * sy
		forward.z = -sp
	end

	if right ~= nil then
		right.x = (-1 * sr * sp * cy + -1 * cr * -sy)
		right.y = (-1 * sr * sp * sy + -1 * cr * cy)
		right.z = -1 * sr * cp
	end

	if up ~= nil then
		up.x = (cr * sp * cy + -sr * -sy)
		up.y = (cr * sp * sy + -sr * cy)
		up.z = cr * cp
	end
end
