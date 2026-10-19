AddCSLuaFile()

local PLAYER = FindMetaTable("Player")

if CLIENT then
	local fov_desired = GetConVar("fov_desired")
	function PLAYER:GetDefaultFOV()
		return fov_desired:GetInt()
	end
else
	function PLAYER:GetDefaultFOV()
		return self:GetInternalVariable("m_iDefaultFOV")
	end
end

hook.Add("StartCommand", "swsrc.cmd", function(ply, cmd)
	local cmd_num = cmd:CommandNumber()
	if cmd_num ~= 0 then
		ply.m_LastUserCommand = cmd
		ply.m_LastUserCommandNumber = cmd_num
	end

	if ply:GetNWBool("m_bIsDefusing", false) then
		cmd:RemoveKey(IN_ATTACK)
	end
end)
