AddCSLuaFile()

SWEP.Base = "weapon_swsrc_basegun"
DEFINE_BASECLASS(SWEP.Base)

SWEP.Category = "#spawnmenu.category.swsrc"
SWEP.SubCategory = "#spawnmenu.category.swsrc_rifles"

SWEP.PrintName = "FAMAS"
SWEP.Spawnable = true
SWEP.HoldType = "ar2"
SWEP.WorldModel = "models/weapons/w_rif_famas.mdl"
SWEP.ViewModel = "models/weapons/cstrike/c_rif_famas.mdl"
SWEP.IconOverride = "vgui/gfx/vgui/fav_weap/famas"

SWEP.WeaponData = [=[WeaponData
{
	"MaxPlayerSpeed"			"220"
	"WeaponType"			"Rifle"
	"FullAuto"				1
	"WeaponPrice"			"2250"
	"WeaponArmorRatio"		"1.4"
	"CrosshairMinDistance"		"4"
	"CrosshairDeltaDistance"	"3"
	"Team"				"CT"
	"BuiltRightHanded"		"1"
	"PlayerAnimationExtension"	"famas"
	"MuzzleFlashScale"		"1.3"
	"MuzzleFlashStyle"		"CS_MUZZLEFLASH_X"
	"CanEquipWithShield"		"0"


	// Weapon characteristics:
	"Penetration"			"2"
	"Damage"			"30"
	"Range"				"8192"
	"RangeModifier"			"0.96"
	"Bullets"			"1"
	"CycleTime"			"0.09"
	"AccuracyDivisor"		"215"
	"AccuracyOffset"		"0.3"
	"MaxInaccuracy"			"1.0"
	"TimeToIdle"			"1.1"
	"IdleInterval"			"20"

	// New accuracy model parameters
	"Spread"					0.00060
	"InaccuracyCrouch"			0.00412
	"InaccuracyStand"			0.00549
	"InaccuracyJump"			0.36527
	"InaccuracyLand"			0.07305
	"InaccuracyLadder"			0.09132
	"InaccuracyFire"			0.01186
	"InaccuracyMove"			0.06980

	"SpreadAlt"					0.00060
	"InaccuracyCrouchAlt"		0.00412
	"InaccuracyStandAlt"		0.00549
	"InaccuracyJumpAlt"			0.36527
	"InaccuracyLandAlt"			0.07305
	"InaccuracyLadderAlt"		0.09132
	"InaccuracyFireAlt"			0.00593
	"InaccuracyMoveAlt"			0.06980

	"RecoveryTimeCrouch"		0.30328
	"RecoveryTimeStand"			0.42460

	// Weapon data is loaded by both the Game and Client DLLs.
	"printname"			"#Cstrike_WPNHUD_Famas"
	"viewmodel"			"models/weapons/v_rif_famas.mdl"
	"playermodel"			"models/weapons/w_rif_famas.mdl"

	"anim_prefix"			"anim"
	"bucket"			"0"
	"bucket_position"		"0"

	"clip_size"			"25"

	"primary_ammo"			"BULLET_PLAYER_556MM"
	"secondary_ammo"		"None"

	"weight"			"75"
	"item_flags"			"0"

	// Sounds for the weapon. There is a max of 16 sounds per category (i.e. max 16 "single_shot" sounds)
	SoundData
	{
		//"reload"			"Weapon_AWP.Reload"
		//"empty"				"Default.ClipEmpty_Rifle"
		"single_shot"		"Weapon_FAMAS.Single"
	}

	// Weapon Sprite data is loaded by the Client DLL.
	TextureData
	{
		"weapon"
		{
				"font"		"CSweaponsSmall"
				"character"	"T"
		}
		"weapon_s"
		{
				"font"		"CSweapons"
				"character"	"T"
		}
		"ammo"
		{
				"font"		"CSTypeDeath"
				"character"		"N"
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
			Mins	"-6 -10 -15"
			Maxs	"23 7 0"
		}
		World
		{
			Mins	"-12 -8 -6"
			Maxs	"22 8 8"
		}
	}
}]=]

local kFamasBurstCycleTime = 0.075

function SWEP:OverrideData(tbl)
	-- TODO: cvar for cs:s slots?
	tbl.Slot = 2
end

function SWEP:GetWeaponID()
	return WEAPON_FAMAS
end

function SWEP:SetupDataTables()
	BaseClass.SetupDataTables(self)

	self:NetworkVar("Bool", "BurstMode")
	self:NetworkVar("Int", "BurstShotsRemaining")
	self:NetworkVar("Float", "NextBurstShot")

	self:SetBurstMode(false)
	self:SetBurstShotsRemaining(0)
	self:SetNextBurstShot(0)
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
		owner:PrintMessage(HUD_PRINTCENTER, "#Cstrike_TitlesTXT_Switch_To_FullAuto")
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
function SWEP:GetInaccuracy()
	local selfTable = self:GetTable()

	if weapon_accuracy_model:GetInt() == 1 then
		local fAutoPenalty = selfTable.GetBurstMode(self) and 0 or 0.01

		local owner = selfTable.GetPlayerOwner(self)
		if not owner then return 0 end

		local m_flAccuracy = selfTable.GetAccuracy(self)
		if not owner:IsOnGround() then
			return 0.03 + 0.3 * m_flAccuracy + fAutoPenalty
		elseif owner:GetVelocity():Length2D() > 140 then
			return 0.03 + 0.07 * m_flAccuracy + fAutoPenalty
		else
			return 0.02 * m_flAccuracy + fAutoPenalty
		end
	else
		return BaseClass.GetInaccuracy(self)
	end
end

function SWEP:ProcessExtraActivities(tbl)
	local selfTable = tbl or self:GetTable()

	if selfTable.GetBurstShotsRemaining(self) > 0 and CurTime() >= selfTable.GetNextBurstShot(self) then
		selfTable.FireRemaining(self, selfTable)
	end
end

function SWEP:FireRemaining(tbl)
	local selfTable = tbl or self:GetTable()

	self:SetClip1(self:Clip1() - 1)

	if self:Clip1() < 0 then
		self:SetClip1(0)
		selfTable.SetBurstShotsRemaining(self, 0)
		selfTable.SetNextBurstShot(self, 0)
		return
	end

	local owner = selfTable.GetPlayerOwner(self)
	if not owner then return end

	-- Famas burst mode
	selfTable.FX_FireBullets(self, Secondary_Mode, selfTable.GetNextBurstShot(self))

	selfTable.SetWeaponAnim(self, ACT_VM_PRIMARYATTACK)

	owner:MuzzleFlash()
	owner:SetAnimation(PLAYER_ATTACK1)

	selfTable.SetShotsFired(self, selfTable.GetShotsFired(self) + 1)

	selfTable.SetBurstShotsRemaining(self, selfTable.GetBurstShotsRemaining(self) - 1)
	if selfTable.GetBurstShotsRemaining(self) > 0 then
		selfTable.SetNextBurstShot(self, selfTable.GetNextBurstShot(self) + kFamasBurstCycleTime)
	else
		selfTable.SetNextBurstShot(self, 0)
	end

	-- update accuracy
	selfTable.SetAccuracyPenalty(self,
		selfTable.GetAccuracyPenalty(self) + selfTable.CSWpnData.m_fInaccuracyFire[Secondary_Mode])
end

function SWEP:PrimaryAttack()
	local selfTable = self:GetTable()

	local owner = selfTable.GetPlayerOwner(self)
	if not owner then return end

	-- don't fire underwater
	if owner:WaterLevel() == 3 then
		selfTable.PlayEmptySound(self, selfTable)
		self:SetNextPrimaryFire(CurTime() + 0.15)
		return
	end

	local flCycleTime = selfTable.CSWpnData.m_flCycleTime

	if selfTable.GetBurstMode(self) then
		flCycleTime = 0.55
		selfTable.SetBurstShotsRemaining(self, 2)
		selfTable.SetNextBurstShot(self, CurTime() + kFamasBurstCycleTime)
	end

	if not selfTable.CSBaseGunFire(self, flCycleTime, selfTable.GetWeaponMode(self)) then return end

	if owner:GetVelocity():Length2D() > 5 then
		selfTable.KickBack(self, 1, 0.45, 0.275, 0.05, 4, 2.5, 7)
	elseif not owner:IsOnGround() then
		selfTable.KickBack(self, 1.25, 0.45, 0.22, 0.18, 5.5, 4, 5)
	elseif owner:IsDucking() then
		selfTable.KickBack(self, 0.575, 0.325, 0.2, 0.011, 3.25, 2, 8)
	else
		selfTable.KickBack(self, 0.625, 0.375, 0.25, 0.0125, 3.5, 2.25, 8)
	end
end
