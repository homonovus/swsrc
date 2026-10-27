AddCSLuaFile()

SWEP.Base = "weapon_swsrc_basegun"
DEFINE_BASECLASS(SWEP.Base)

SWEP.Category = "#spawnmenu.category.swsrc"
SWEP.SubCategory = "#spawnmenu.category.swsrc_pistols"

SWEP.PrintName = "Glock-18"
SWEP.Spawnable = true
SWEP.HoldType = "revolver"
SWEP.WorldModel = "models/weapons/w_pist_glock18.mdl"
SWEP.ViewModel = "models/weapons/cstrike/c_pist_glock18.mdl"
SWEP.IconOverride = "vgui/gfx/vgui/fav_weap/glock18"

SWEP.WeaponData = [=[WeaponData
{
	"MaxPlayerSpeed"		"250"
	"WeaponType"			"Pistol"
	"FullAuto"				0
	"WeaponPrice"			"400"
	"WeaponArmorRatio"		"1.05"
	"CrosshairMinDistance"		"8"
	"CrosshairDeltaDistance"	"3"
	"Team" 				"ANY"
	"BuiltRightHanded"		"0"
	"PlayerAnimationExtension" 	"pistol"
	"MuzzleFlashScale"		"1.0"

	"CanEquipWithShield"		"1"


	// Weapon characteristics:
	"Penetration"			"1"
	"Damage"			"25"
	"Range"				"4096"
	"RangeModifier"			"0.75"
	"Bullets"			"1"
	"CycleTime"			"0.15"

	// New accuracy model parameters
	"Spread"					0.00400
	"InaccuracyCrouch"			0.00750
	"InaccuracyStand"			0.01000
	"InaccuracyJump"			0.27750
	"InaccuracyLand"			0.05550
	"InaccuracyLadder"			0.01850
	"InaccuracyFire"			0.03167
	"InaccuracyMove"			0.01665

	"SpreadAlt"					0.00400
	"InaccuracyCrouchAlt"		0.00750
	"InaccuracyStandAlt"		0.01000
	"InaccuracyJumpAlt"			0.27750
	"InaccuracyLandAlt"			0.05550
	"InaccuracyLadderAlt"		0.01850
	"InaccuracyFireAlt"			0.02217
	"InaccuracyMoveAlt"			0.01665

	"RecoveryTimeCrouch"		0.21875
	"RecoveryTimeStand"			0.26249

	// Weapon data is loaded by both the Game and Client DLLs.
	"printname"			"#Cstrike_WPNHUD_Glock18"
	"viewmodel"			"models/weapons/v_pist_glock18.mdl"
	"playermodel"			"models/weapons/w_pist_glock18.mdl"
	"shieldviewmodel"		"models/weapons/v_shield_glock18_r.mdl"
	"anim_prefix"			"anim"
	"bucket"			"1"
	"bucket_position"		"1"

	"clip_size"			"20"

	"primary_ammo"			"BULLET_PLAYER_9MM"
	"secondary_ammo"		"None"

	"weight"			"5"
	"item_flags"			"0"

	// Sounds for the weapon. There is a max of 16 sounds per category (i.e. max 16 "single_shot" sounds)
	SoundData
	{
		//"reload"			"Default.Reload"
		//"empty"				"Default.ClipEmpty_Rifle"
		"single_shot"		"Weapon_Glock.Single"
	}

	// Weapon Sprite data is loaded by the Client DLL.
	TextureData
	{
		"weapon"
		{
				"font"		"CSweaponsSmall"
				"character"	"c"
		}
		"weapon_s"
		{
				"font"		"CSweapons"
				"character"	"c"
		}
		"ammo"
		{
				"font"		"CSTypeDeath"
				"character"		"R"
		}
		"crosshair"
		{
				"file"		"sprites/crosshairs"
				"x"			"0"
				"y"			"48"
				"width"		"24"
				"height"	"24"
		}
		"autoaim"
		{
				"file"		"sprites/crosshairs"
				"x"			"0"
				"y"			"48"
				"width"		"24"
				"height"	"24"
		}
	}
	ModelBounds
	{
		Viewmodel
		{
			Mins	"-8 -4 -14"
			Maxs	"17 9 -1"
		}
		World
		{
			Mins	"-1 -3 -3"
			Maxs	"11 4 4"
		}
	}
}]=]

function SWEP:OverrideData(tbl)
	-- TODO: cvar for cs:s slots?
	tbl.Slot = 1
end

function SWEP:GetWeaponID()
	return WEAPON_GLOCK
end

function SWEP:SetupWeaponHoldTypeForAI(t)
	-- change player holdtypes
	self.ActivityTranslate[ACT_MP_RELOAD_STAND] = ACT_HL2MP_GESTURE_RELOAD_PISTOL
	self.ActivityTranslate[ACT_MP_RELOAD_CROUCH] = ACT_HL2MP_GESTURE_RELOAD_PISTOL

	BaseClass.SetupWeaponHoldTypeForAI(self, t)

	-- change NPC holdtypes
end

local kGlockBurstCycleTime = 0.06

function SWEP:SetupDataTables()
	BaseClass.SetupDataTables(self)

	self:NetworkVar("Bool", "BurstMode")
	self:NetworkVar("Int", "BurstShotsRemaining")
	self:NetworkVar("Float", "NextBurstShot")
	self:NetworkVar("Float", "LastFire")

	self:SetBurstMode(false)
	self:SetBurstShotsRemaining(0)
	self:SetNextBurstShot(0)
	self:SetLastFire(CurTime())
	self:SetAccuracy(0.9)
end

function SWEP:Deploy()
	self:SetBurstShotsRemaining(0)
	self:SetNextBurstShot(0)
	self:SetAccuracy(0.9)

	return BaseClass.Deploy(self)
end

function SWEP:SecondaryAttack()
	local selfTable = self:GetTable()

	local owner = selfTable.GetPlayerOwner(self)
	if not owner then return end

	if selfTable.GetBurstMode(self) then
		owner:PrintMessage(HUD_PRINTCENTER, "#Cstrike_TitlesTXT_Switch_To_SemiAuto")
		selfTable.SetBurstMode(self, false)
		selfTable.SetWeaponMode(self, Primary_Mode)
	else
		owner:PrintMessage(HUD_PRINTCENTER, "#Cstrike_TitlesTXT_Switch_To_BurstFire")
		selfTable.SetBurstMode(self, true)
		selfTable.SetWeaponMode(self, Secondary_Mode)
	end

	self:SetNextSecondaryFire(CurTime() + 0.3)
end

local weapon_accuracy_model = GetConVar("swsrc_weapon_accuracy_model")
local weapon_accuracy_noinaccuracy = GetConVar("swsrc_weapon_accuracy_noinaccuracy")
function SWEP:GetInaccuracy()
	if weapon_accuracy_noinaccuracy:GetBool() then return 0 end

	local selfTable = self:GetTable()

	if weapon_accuracy_model:GetInt() == 1 then
		local owner = selfTable.GetPlayerOwner(self)
		if not owner then return 0 end

		local m_flAccuracy = selfTable.GetAccuracy(self)
		if selfTable.GetBurstMode(self) then
			if not owner:IsOnGround() then
				return 1.2 * (1 - m_flAccuracy)
			elseif owner:GetVelocity():Length2D() > 5 then
				return 0.185 * (1 - m_flAccuracy)
			elseif owner:IsDucking() then
				return 0.095 * (1 - m_flAccuracy)
			else
				return 0.3 * (1 - m_flAccuracy)
			end
		else
			if not owner:IsOnGround() then
				return 1 - m_flAccuracy
			elseif owner:GetVelocity() > 5 then
				return 0.165 * (1 - m_flAccuracy)
			elseif owner:IsDucking() then
				return 0.075 * (1 - m_flAccuracy)
			else
				return 0.1 * (1 - m_flAccuracy)
			end
		end
	else
		return BaseClass.GetInaccuracy(self)
	end
end

function SWEP:PrimaryAttack()
	local selfTable = self:GetTable()

	local owner = selfTable.GetPlayerOwner(self)
	if not owner then return end

	local flCycleTime = selfTable.GetBurstMode(self) and 0.5 or selfTable.CSWpnData.m_flCycleTime

	-- Mark the time of this shot and determine the accuracy modifier based on the last shot fired...
	local m_flAccuracy = selfTable.GetAccuracy(self)
	m_flAccuracy = m_flAccuracy - 0.275 * (0.325 - (CurTime() - selfTable.GetLastFire(self)))

	if m_flAccuracy > 0.9 then
		m_flAccuracy = 0.9
	elseif m_flAccuracy < 0.6 then
		m_flAccuracy = 0.6
	end

	selfTable.SetAccuracy(self, m_flAccuracy)
	selfTable.SetLastFire(self, CurTime())

	if self:Clip1() <= 0 then
		if selfTable.m_bFireOnEmpty then
			selfTable.PlayEmptySound(self, selfTable)
			self:SetNextPrimaryFire(CurTime() + 0.1)
			selfTable.m_bFireOnEmpty = false
		end

		return
	end

	selfTable.SetShotsFired(self, selfTable.GetShotsFired(self) + 1)

	self:SetClip1(self:Clip1() - 1)

	owner:MuzzleFlash()

	owner:SetAnimation(PLAYER_ATTACK1)

	selfTable.FX_FireBullets(self, Primary_Mode, CurTime())

	self:SetNextPrimaryFire(CurTime() + flCycleTime)
	self:SetNextSecondaryFire(CurTime() + flCycleTime)

	selfTable.SetWeaponIdleTime(self, CurTime() + 2.5)

	if selfTable.GetBurstMode(self) then
		selfTable.SetNextBurstShot(self, CurTime() + kGlockBurstCycleTime)
		selfTable.SetBurstShotsRemaining(self, 2)

		selfTable.SetWeaponAnim(self, ACT_VM_SECONDARYATTACK)
	else
		selfTable.SetWeaponAnim(self, ACT_VM_PRIMARYATTACK)
	end

	-- update accuracy
	selfTable.SetAccuracyPenalty(self,
		selfTable.GetAccuracyPenalty(self) + selfTable.CSWpnData.m_fInaccuracyFire[selfTable.GetWeaponMode(self)])
end

function SWEP:FireRemaining(tbl, fSpread)
	local selfTable = tbl or self:GetTable()

	local owner = selfTable.GetPlayerOwner(self)
	if not owner then return end

	if selfTable.GetBurstShotsRemaining(self) == 0 then return end

	if self:Clip1() <= 0 then
		self:SetClip1(0)
		selfTable.SetBurstShotsRemaining(self, 0)
		selfTable.SetNextBurstShot(self, 0)
		return
	end

	self:SetClip1(self:Clip1() - 1)

	local fInaccuracy = selfTable.GetInaccuracy(self)
	if weapon_accuracy_model:GetInt() == 1 then
		fInaccuracy = 0.05
	end

	-- NOTE: fixing an oversight that fSpread went unused at some point
	selfTable.FX_FireBullets(self, Secondary_Mode, selfTable.GetNextBurstShot(self), fInaccuracy, fSpread)

	owner:SetAnimation(PLAYER_ATTACK1)
	selfTable.SetShotsFired(self, selfTable.GetShotsFired(self) + 1)

	selfTable.SetBurstShotsRemaining(self, selfTable.GetBurstShotsRemaining(self) - 1)

	if selfTable.GetBurstShotsRemaining(self) > 0 then
		selfTable.SetNextBurstShot(self, selfTable.GetNextBurstShot(self) + kGlockBurstCycleTime)
	else
		selfTable.SetNextBurstShot(self, 0)
	end

	-- update accuracy
	selfTable.SetAccuracyPenalty(self,
		selfTable.GetAccuracyPenalty(self) + selfTable.CSWpnData.m_fInaccuracyFire[Secondary_Mode])
end

function SWEP:ProcessExtraActivities(tbl)
	local selfTable = tbl or self:GetTable()

	while selfTable.GetBurstShotsRemaining(self) > 0 and CurTime() >= selfTable.GetNextBurstShot(self) do
		if weapon_accuracy_model:GetInt() == 1 then
			selfTable.FireRemaining(self, selfTable, 0.05)
		else
			selfTable.FireRemaining(self)
		end
	end
end

function SWEP:Reload()
	local selfTable = self:GetTable()

	if selfTable.GetBurstShotsRemaining(self) ~= 0 then return true end

	if not BaseClass.Reload(self) then return false end

	selfTable.SetAccuracy(self, 0.9)
	return true
end
