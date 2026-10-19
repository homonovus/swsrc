AddCSLuaFile()

SWEP.Base = "weapon_base"
SWEP.IsSWSrcWeapon = true

SWEP.AllowDrop = true

SWEP.Slot = 1
SWEP.SlotPos = 2

SWEP.Secondary.Ammo = ""
SWEP.Secondary.ClipSize = -1

SWEP.UseHands = true

local g_bSinglePlayer = game.SinglePlayer()

hook.Add("Initialize", "swsrc.ammo", function()
	game.AddAmmoType({
		name = "BULLET_PLAYER_50AE",
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE,
		force = 2400,
		minsplash = 10,
		maxsplash = 14,
	})
	game.AddAmmoType({
		name = "BULLET_PLAYER_762MM",
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE,
		force = 2400,
		minsplash = 10,
		maxsplash = 14,
	})
	game.AddAmmoType({
		name = "BULLET_PLAYER_556MM",
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE,
		force = 2400,
		minsplash = 10,
		maxsplash = 14,
	})
	game.AddAmmoType({
		name = "BULLET_PLAYER_556MM_BOX",
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE,
		force = 2400,
		minsplash = 10,
		maxsplash = 14,
	})
	game.AddAmmoType({
		name = "BULLET_PLAYER_338MAG",
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE,
		force = 2800,
		minsplash = 12,
		maxsplash = 16,
	})
	game.AddAmmoType({
		name = "BULLET_PLAYER_9MM",
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE,
		force = 2000,
		minsplash = 5,
		maxsplash = 10,
	})
	game.AddAmmoType({
		name = "BULLET_PLAYER_BUCKSHOT",
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE,
		force = 600,
		minsplash = 3,
		maxsplash = 6,
	})
	game.AddAmmoType({
		name = "BULLET_PLAYER_45ACP",
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE,
		force = 2100,
		minsplash = 6,
		maxsplash = 10,
	})
	game.AddAmmoType({
		name = "BULLET_PLAYER_357SIG",
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE,
		force = 2000,
		minsplash = 4,
		maxsplash = 8,
	})
	game.AddAmmoType({
		name = "BULLET_PLAYER_57MM",
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE,
		force = 2000,
		minsplash = 4,
		maxsplash = 8,
	})

	game.AddAmmoType({
		name = "swsrc_hegrenade",
		dmgtype = DMG_BLAST,
		maxcarry = 1,
	})
	game.AddAmmoType({
		name = "swsrc_flashbang",
		maxcarry = 2,
	})
	game.AddAmmoType({
		name = "swsrc_smokegrenade",
		maxcarry = 1,
	})
end)

SWEP.m_bDelayFire = true

function SWEP:Initialize()
	local selfTable = self:GetTable()

	self:SetHoldType(selfTable.HoldType or "pistol")
end

function SWEP:GetWpnData()
	local selfTable = self:GetTable()

	return util.KeyValuesToTable(selfTable.WeaponData, false, true)
end

function SWEP:SetupDataTables()
	self:NetworkVar("Bool", 0, "InReload")
	self:NetworkVar("Bool", 1, "DelayFire")
	self:NetworkVar("Bool", 2, "ResumeZoom")

	self:NetworkVar("Int", 0, "ShotsFired")
	self:NetworkVar("Int", 1, "LastZoom")

	self:NetworkVar("Float", 0, "DecreaseShotsFired")
	self:NetworkVar("Float", 1, "WeaponIdleTime")

	self:SetDelayFire(true)
end

function SWEP:GetPlayerOwner()
	local owner = self:GetOwner()
	if not (owner:IsValid() and owner:IsPlayer()) then return false end

	return owner
end

function SWEP:IsPistol(tbl)
	local selfTable = tbl or self:GetTable()

	return selfTable.GetWpnData(self).WeaponType == "Pistol"
end
function SWEP:IsAwp()
	return false
end

function SWEP:SetWeaponAnim(idealAct, flPlaybackRate)
	local owner = self:GetOwner()
	local vm = owner:IsPlayer() and owner:GetViewModel() or self

	if not vm:IsValid() then return false end

	local idealSequence = vm:SelectWeightedSequence(idealAct)
	if idealSequence == nil or idealSequence == ACT_INVALID then return false end
	flPlaybackRate = isnumber(flPlaybackRate) and flPlaybackRate or 1

	self:SendWeaponAnim(idealAct)
	self:SendViewModelMatchingSequence(idealSequence)

	if owner:IsValid() and owner:IsPlayer() then
		vm:SendViewModelMatchingSequence(idealSequence)
		vm:SetPlaybackRate(flPlaybackRate)
	end

	-- Set the next time the weapon will idle
	self:SetWeaponIdleTime(CurTime() + (vm:SequenceDuration(idealSequence) * (1 / flPlaybackRate)))
	return true
end


function SWEP:WeaponIdle()
end

function SWEP:Reload()
	local selfTable = self:GetTable()

	local owner = selfTable.GetPlayerOwner(self)
	if not owner then return end

	selfTable.SetShotsFired(self, 0)

	self:DefaultReload(ACT_VM_RELOAD)
end

function SWEP:IsUseable()
	local owner = self:GetPlayerOwner()
	if not owner then return false end

	if self:Clip1() <= 0 then
		if self:Ammo1() <= 0 and self:GetMaxClip1() ~= -1 then
			-- clip is empty (or nonexistant) and the player has no more ammo of this type.
			return false
		end
	end

	return true
end

function SWEP:Think_ProcessPrimaryAttack(tbl)
	if self:Clip1() == 0 or (self:GetMaxClip1() == -1 and self:Ammo1() <= 0) then
		tbl.m_bFireOnEmpty = true
	end

	-- gameevent?

	self:PrimaryAttack()
end

function SWEP:Think_ProcessSecondaryAttack(tbl)
	if self:Clip2() ~= -1 and self:Ammo2() ~= 0 then
		tbl.m_bFireOnEmpty = true
	end

	self:SecondaryAttack()
	return true
end

function SWEP:Think_ProcessReloadAction(_)
	-- gameevent?

	self:Reload()
end

function SWEP:Think_ProcessIdleNoAction(tbl)
	if tbl.GetDelayFire(self) then
		tbl.SetDelayFire(self, false)

		if tbl.GetShotsFired(self) > 15 then
			tbl.SetShotsFired(self, 15)
		end

		tbl.SetDecreaseShotsFired(self, CurTime() + 0.4)
	end

	tbl.m_bFireOnEmpty = false

	if tbl.IsPistol(self, tbl) then
		tbl.SetShotsFired(self, 0)
	else
		if tbl.GetShotsFired(self) > 0 and tbl.GetDecreaseShotsFired(self) < CurTime() then
			tbl.SetDecreaseShotsFired(self, CurTime() + 0.0225)
			tbl.SetShotsFired(self, tbl.GetShotsFired(self) - 1)
		end
	end

	if tbl.IsUseable(self) or self:GetNextPrimaryFire() >= CurTime() then
		if
			self:Clip1() == 0
			--[[and bit.band(tbl.GetWeaponFlags(self), ITEM_FLAG_NOAUTORELOAD)]]
			and self:GetNextPrimaryFire() < CurTime()
		then
			self:Reload()
			return
		end
	end

	tbl.WeaponIdle(self)
end

function SWEP:Think()
	local selfTable = self:GetTable()

	local owner = selfTable.GetPlayerOwner(self)
	if not owner then return end

	if selfTable.GetInReload(self) and self:GetNextPrimaryFire() <= CurTime() then
		local clip1 = self:Clip1()
		local j = math.min(self:GetMaxClip1() - clip1, self:Ammo1())

		self:SetClip1(clip1 + j)
		owner:RemoveAmmo(j, self:GetPrimaryAmmoType())

		selfTable.SetInReload(self, false)
	end

	selfTable.m_bProcessActivities = true
end

SWEP.m_bProcessActivities = false
hook.Add("PlayerTick", "swsrc.ProcessActivities", function(ply)
	if not IsValid(ply) then return end
	local wep = ply:GetActiveWeapon()

	local tbl = wep:GetTable()
	if not wep:IsValid() or not weapons.IsBasedOn(tbl.ClassName, "weapon_swsrc_base") then return end

	if tbl.m_bProcessActivities then
		tbl.ProcessActivities(wep, tbl)
		tbl.m_bProcessActivities = false
	end
end)

function SWEP:ProcessExtraActivities(_)
end

function SWEP:ProcessActivities(tbl)
	local selfTable = tbl or self:GetTable()

	local owner = selfTable.GetPlayerOwner(self)
	if not owner then return end

	local cmd
	if g_bSinglePlayer then
		cmd = owner.m_LastUserCommand
	elseif owner == GetPredictionPlayer() then
		cmd = owner:GetCurrentCommand()

		owner.m_LastUserCommand = cmd
		owner.m_LastUserCommandNumber = cmd:CommandNumber()
	else
		cmd = owner.m_LastUserCommand
	end

	local o_btns = owner:GetInternalVariable("m_nButtons")
	local btns = g_bSinglePlayer and o_btns or (cmd and cmd:GetButtons() or o_btns)

	selfTable.m_bProcessingActivities = true

	selfTable.ProcessExtraActivities(self, tbl)

	local bInReload = selfTable.GetInReload(self)

	if bit.band(btns, IN_ATTACK2) ~= 0 and self:GetNextSecondaryFire() <= CurTime() then
		if selfTable.Think_ProcessSecondaryAttack(self, selfTable) then
			btns = bit.band(btns, bit.bnot(IN_ATTACK2))
		end
	elseif bit.band(btns, IN_ATTACK) ~= 0 and self:GetNextPrimaryFire() <= CurTime() then
		selfTable.Think_ProcessPrimaryAttack(self, selfTable)
	elseif
		bit.band(btns, IN_RELOAD)
		and self:GetMaxClip1() ~= -1
		and not bInReload
		and self:GetNextPrimaryFire() < CurTime()
	then
		selfTable.Think_ProcessReloadAction(self, selfTable)
	elseif bit.band(btns, bit.bor(IN_ATTACK, IN_ATTACK2)) == 0 then
		selfTable.Think_ProcessIdleNoAction(self, selfTable)
	end

	selfTable.m_bProcessingActivities = false
end

function SWEP:GetMaxSpeed()
	return tonumber(self:GetTable().GetWpnData(self).MaxPlayerSpeed)
end

function SWEP:Holster()
	local selfTable = self:GetTable()
	local owner = selfTable.GetPlayerOwner(self)

	if not owner then return true end

	if owner:GetFOV() ~= owner:GetDefaultFOV() then
		owner:SetFOV(0, 0.01)
	end

	return true
end

function SWEP:Deploy()
	local selfTable = self:GetTable()

	local owner = selfTable.GetPlayerOwner(self)
	if not owner then return true end

	self:SetHoldType(selfTable.HoldType)
	self:SetDeploySpeed(1)

	selfTable.SetShotsFired(self, 0)
	selfTable.SetResumeZoom(self, false)
	selfTable.SetLastZoom(self, 0)

	if owner:GetFOV() ~= owner:GetDefaultFOV() then
		owner:SetFOV(0, 0.01)
	end

	local vm = owner:GetViewModel(self:ViewModelIndex())
	if vm:IsValid() then
		vm:SetPlaybackRate(self:GetDeploySpeed())
		selfTable.SetWeaponIdleTime(self, CurTime() + (self:SequenceDuration() * (1 / self:GetDeploySpeed())))

		local oPrim = self:GetNextPrimaryFire()
		local oSec = self:GetNextSecondaryFire()
		self:SetNextPrimaryFire(oPrim < self:GetWeaponIdleTime() and self:GetWeaponIdleTime() or oPrim)
		self:SetNextSecondaryFire(oSec < self:GetWeaponIdleTime() and self:GetWeaponIdleTime() or oSec)
	end

	return true
end

function SWEP:OnDrop()
	local selfTable = self:GetTable()

	selfTable.SetInReload(self, false)
end
