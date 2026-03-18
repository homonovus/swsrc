AddCSLuaFile()

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
