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

include("sh_penetration.lua")

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

-- these are only here for custom weapons to replicate logic of other "base" weapons
WEAPON_NONE = 0
WEAPON_P228 = 1
WEAPON_GLOCK = 2
WEAPON_SCOUT = 3
WEAPON_HEGRENADE = 4
WEAPON_XM1014 = 5
WEAPON_C4 = 6
WEAPON_MAC10 = 7
WEAPON_AUG = 8
WEAPON_SMOKEGRENADE = 9
WEAPON_ELITE = 10
WEAPON_FIVESEVEN = 11
WEAPON_UMP45 = 12
WEAPON_SG550 = 13

WEAPON_GALIL = 14
WEAPON_FAMAS = 15
WEAPON_USP = 16
WEAPON_AWP = 17
WEAPON_MP5NAVY = 18
WEAPON_M249 = 19
WEAPON_M3 = 20
WEAPON_M4A1 = 21
WEAPON_TMP = 22
WEAPON_G3SG1 = 23
WEAPON_FLASHBANG = 24
WEAPON_DEAGLE = 25
WEAPON_SG552 = 26
WEAPON_AK47 = 27
WEAPON_KNIFE = 28
WEAPON_P90 = 29

WEAPON_SHIELDGUN = 30 -- BOTPORT: Is this still needed?

WEAPON_KEVLAR = 31
WEAPON_ASSAULTSUIT = 32
WEAPON_NVG = 33

WEAPON_MAX = 34

WEAPONTYPE_KNIFE = 0
WEAPONTYPE_PISTOL = 1
WEAPONTYPE_SUBMACHINEGUN = 2
WEAPONTYPE_RIFLE = 3
WEAPONTYPE_SHOTGUN = 4
WEAPONTYPE_SNIPER_RIFLE = 5
WEAPONTYPE_MACHINEGUN = 6
WEAPONTYPE_C4 = 7
WEAPONTYPE_GRENADE = 8
WEAPONTYPE_UNKNOWN = 9

local s_weaponTypeInfo = {
	{WEAPONTYPE_KNIFE,         "Knife"},
	{WEAPONTYPE_PISTOL,        "Pistol"},
	{WEAPONTYPE_SUBMACHINEGUN, "Submachine Gun"}, -- First match is printable
	{WEAPONTYPE_SUBMACHINEGUN, "submachinegun"},
	{WEAPONTYPE_SUBMACHINEGUN, "smg"},
	{WEAPONTYPE_RIFLE,         "Rifle"},
	{WEAPONTYPE_SHOTGUN,       "Shotgun"},
	{WEAPONTYPE_SNIPER_RIFLE,  "Sniper Rifle"}, -- First match is printable
	{WEAPONTYPE_SNIPER_RIFLE,  "SniperRifle"},
	{WEAPONTYPE_MACHINEGUN,    "Machine Gun"}, -- First match is printable
	{WEAPONTYPE_MACHINEGUN,    "machinegun"},
	{WEAPONTYPE_MACHINEGUN,    "mg"},
	{WEAPONTYPE_C4,            "C4"},
	{WEAPONTYPE_GRENADE,       "Grenade"},
}

ITEM_FLAG_SELECTONEMPTY = bit.lshift(1, 0)
ITEM_FLAG_NOAUTORELOAD = bit.lshift(1, 1)
ITEM_FLAG_NOAUTOSWITCHEMPTY = bit.lshift(1, 2)
ITEM_FLAG_LIMITINWORLD = bit.lshift(1, 3)
ITEM_FLAG_EXHAUSTIBLE = bit.lshift(1, 4) -- A player can totally exhaust their ammo supply and lose this weapon
ITEM_FLAG_DOHITLOCATIONDMG = bit.lshift(1, 5) -- This weapon take hit location into account when applying damage
ITEM_FLAG_NOAMMOPICKUPS = bit.lshift(1, 6) -- Don't draw ammo pickup sprites/sounds when ammo is received
ITEM_FLAG_NOITEMPICKUP = bit.lshift(1, 7) -- Don't draw weapon pickup when this weapon is picked up by the player

local g_ItemFlags = {
	{"ITEM_FLAG_SELECTONEMPTY",     ITEM_FLAG_SELECTONEMPTY},
	{"ITEM_FLAG_NOAUTORELOAD",      ITEM_FLAG_NOAUTORELOAD},
	{"ITEM_FLAG_NOAUTOSWITCHEMPTY", ITEM_FLAG_NOAUTOSWITCHEMPTY},
	{"ITEM_FLAG_LIMITINWORLD",      ITEM_FLAG_LIMITINWORLD},
	{"ITEM_FLAG_EXHAUSTIBLE",       ITEM_FLAG_EXHAUSTIBLE},
	{"ITEM_FLAG_DOHITLOCATIONDMG",  ITEM_FLAG_DOHITLOCATIONDMG},
	{"ITEM_FLAG_NOAMMOPICKUPS",     ITEM_FLAG_NOAMMOPICKUPS},
	{"ITEM_FLAG_NOITEMPICKUP",      ITEM_FLAG_NOITEMPICKUP},
}

local pWeaponSoundCategories = {
	"empty",
	"single_shot",
	"single_shot_npc",
	"double_shot",
	"double_shot_npc",
	"burst",
	"reload",
	"reload_npc",
	"melee_miss",
	"melee_hit",
	"melee_hit_world",
	"special1",
	"special2",
	"special3",
	"taunt",
	"deploy",
}

Primary_Mode = 0
Secondary_Mode = 1

SWEP.m_bDelayFire = true

function SWEP:Initialize()
	local selfTable = self:GetTable()

	self:SetHoldType(selfTable.HoldType or "pistol")
	selfTable.ParseWeaponData(self)
end

local function makeModeValues(pKeyValuesData, key, default)
	return {
		[0] = pKeyValuesData:GetFloat(key, default),
		[1] = pKeyValuesData:GetFloat(key .. "Alt", default),
	}
end
local function WeaponClassFromString(weaponType)
	for _, info in ipairs(s_weaponTypeInfo) do
		if info[2] == weaponType then
			return info[1]
		end
	end

	return WEAPONTYPE_UNKNOWN
end

function SWEP:ParseWeaponData()
	local selfTable = self:GetTable()

	local pKeyValuesData = swsrc.KeyValuesHelper(selfTable.WeaponData or "")
	if not pKeyValuesData then return end

	local data = {
		szPrintName               = pKeyValuesData:GetString("printname", "!!! Missing printname on weapon"),
		szViewModel               = pKeyValuesData:GetString("viewmodel"),
		szWorldModel              = pKeyValuesData:GetString("playermodel"),
		szAnimationPrefix         = pKeyValuesData:GetString("anim_prefix"),
		iSlot                     = pKeyValuesData:GetInt("bucket", 0),
		iPosition                 = pKeyValuesData:GetInt("bucket_position", 0),
		iMaxClip1                 = pKeyValuesData:GetInt("clip_size", -1),
		iMaxClip2                 = pKeyValuesData:GetInt("clip2_size", -1),
		iWeight                   = pKeyValuesData:GetInt("weight", 0),

		iRumbleEffect             = pKeyValuesData:GetInt("rumble", -1),

		iFlags                    = pKeyValuesData:GetInt("item_flags", ITEM_FLAG_LIMITINWORLD),

		bShowUsageHint            = pKeyValuesData:GetBool("showusagehint", false),
		bAutoSwitchTo             = pKeyValuesData:GetBool("autoswitchto", true),
		bAutoSwitchFrom           = pKeyValuesData:GetBool("autoswitchfrom", true),
		m_bBuiltRightHanded       = pKeyValuesData:GetBool("BuiltRightHanded", true),
		m_bAllowFlipping          = pKeyValuesData:GetBool("AllowFlipping", true),
		m_bMeleeWeapon            = pKeyValuesData:GetBool("MeleeWeapon", false),

		szAmmo1                   = pKeyValuesData:GetString("primary_ammo", "None"),
		szAmmo2                   = pKeyValuesData:GetString("secondary_ammo", "None"),

		aShootSounds              = {},
		TextureData               = {},

		-- vvv CS:S specific vvv --

		m_flMaxSpeed              = pKeyValuesData:GetInt("MaxPlayerSpeed", 1),

		m_iWeaponPrice            = pKeyValuesData:GetInt("WeaponPrice", -1),

		m_flArmorRatio            = pKeyValuesData:GetFloat("WeaponArmorRatio", 1),
		m_iCrosshairMinDistance   = pKeyValuesData:GetInt("CrosshairMinDistance", 4),
		m_iCrosshairDeltaDistance = pKeyValuesData:GetInt("CrosshairDeltaDistance", 3),
		m_bCanUseWithShield       = pKeyValuesData:GetBool("CanEquipWithShield", false),
		m_flMuzzleScale           = pKeyValuesData:GetFloat("MuzzleFlashScale", 1),

		m_iPenetration            = pKeyValuesData:GetInt("Penetration", 1),
		m_iDamage                 = pKeyValuesData:GetInt("Damage", 42), -- Douglas Adams 1952 - 2001
		m_flRange                 = pKeyValuesData:GetFloat("Range", 8192),
		m_flRangeModifier         = pKeyValuesData:GetFloat("RangeModifier", 0.98),
		m_iBullets                = pKeyValuesData:GetInt("Bullets", 1),
		m_flCycleTime             = pKeyValuesData:GetFloat("CycleTime", 0.15),
		m_bAccuracyQuadratic      = pKeyValuesData:GetBool("AccuracyQuadratic", false),
		m_flAccuracyDivisor       = pKeyValuesData:GetFloat("AccuracyDivisor", -1), -- -1 = off
		m_flAccuracyOffset        = pKeyValuesData:GetFloat("AccuracyOffset", 0),
		m_flMaxInaccuracy         = pKeyValuesData:GetFloat("MaxInaccuracy", 0),

		-- new accuracy model parameters
		m_fSpread                 = makeModeValues(pKeyValuesData, "Spread", 0),
		m_fInaccuracyCrouch       = makeModeValues(pKeyValuesData, "InaccuracyCrouch", 0),
		m_fInaccuracyStand        = makeModeValues(pKeyValuesData, "InaccuracyStand", 0),
		m_fInaccuracyJump         = makeModeValues(pKeyValuesData, "InaccuracyJump", 0),
		m_fInaccuracyLand         = makeModeValues(pKeyValuesData, "InaccuracyLand", 0),
		m_fInaccuracyLadder       = makeModeValues(pKeyValuesData, "InaccuracyLadder", 0),
		m_fInaccuracyImpulseFire  = makeModeValues(pKeyValuesData, "InaccuracyImpulseFire", 0),
		m_fInaccuracyMove         = makeModeValues(pKeyValuesData, "InaccuracyMove", 0),

		m_fInaccuracyReload       = pKeyValuesData:GetFloat("InaccuracyReload", 0),
		m_fInaccuracyAltSwitch    = pKeyValuesData:GetFloat("InaccuracyAltSwitch", 0),

		m_fRecoveryTimeCrouch     = pKeyValuesData:GetFloat("RecoveryTimeCrouch", 1),
		m_fRecoveryTimeStand      = pKeyValuesData:GetFloat("RecoveryTimeStand", 1),

		m_flTimeToIdleAfterFire   = pKeyValuesData:GetFloat("TimeToIdle", 2),
		m_flIdleInterval          = pKeyValuesData:GetFloat("IdleInterval", 20),

		m_iTeam                   = -1, -- dont care currently

		m_WrongTeamMsg            = pKeyValuesData:GetString("WrongTeamMsg", ""),
		m_szShieldViewModel       = pKeyValuesData:GetString("shieldviewmodel", ""),
		m_szAnimExtension         = pKeyValuesData:GetString("PlayerAnimationExtension", "m4"),

		m_flBotAudibleRange       = pKeyValuesData:GetFloat("BotAudibleRange", 2000),

		m_WeaponType              = WeaponClassFromString(pKeyValuesData:GetString("WeaponType", "")),

		m_bFullAuto               = pKeyValuesData:GetBool("FullAuto"),

		m_szAddonModel            = pKeyValuesData:GetString("AddonModel"),
		m_szDroppedModel          = pKeyValuesData:GetString("DroppedModel"),
		m_szSilencerModel         = pKeyValuesData:GetString("SilencerModel"),
	}

	data.iDefaultClip1 = pKeyValuesData:GetInt("default_clip", data.iMaxClip1)
	data.iDefaultClip2 = pKeyValuesData:GetInt("default_clip2", data.iMaxClip2)

	for _, flag in ipairs(g_ItemFlags) do
		local iVal = pKeyValuesData:GetInt(flag[1], -1)
		if iVal == 0 then
			data.iFlags = bit.band(data.iFlags, bit.bnot(flag[2]))
		elseif iVal == 1 then
			data.iFlags = bit.bor(data.iFlags, flag[2])
		end
	end

	if data.szAmmo1 == "None" then data.szAmmo1 = "" end
	data.iAmmoType = game.GetAmmoID(data.szAmmo1)
	if data.szAmmo2 == "None" then data.szAmmo2 = "" end
	data.iAmmo2Type = game.GetAmmoID(data.szAmmo2)

	local pSoundData = pKeyValuesData:FindKey("SoundData")
	if pSoundData then
		for i = 1, 16 do
			local soundname = pSoundData:GetString(pWeaponSoundCategories[i], "")
			if soundname ~= "" then
				data.aShootSounds[i] = soundname
			end
		end
	end

	local pTextureSection = pKeyValuesData:FindKey("TextureData")
	if pTextureSection then
		for key, pTemp in pTextureSection:IterValues() do
			if pTemp:GetString("font", "") ~= "" then
				data.TextureData[key] = {
					szShortName = key,
					bRenderedUsingFont = true,
					cCharacterInFont = pTemp:GetString("character", ""),
					szTextureFile = pTemp:GetString("font"),
				}
			else
				data.TextureData[key] = {
					-- i dont think anything in cs:s uses TextureFileRefs?
					szShortName = key,
					szTextureFile = pTemp:GetString("file"),
					bRenderedUsingFont = false,
					rc = {
						left = pTemp:GetInt("x", 0),
						top = pTemp:GetInt("y", 0),
						right = pTemp:GetInt("width", 0),
						bottom = pTemp:GetInt("height", 0),
					},
				}
			end
		end
	end

	data.m_iDefaultPrice = data.m_iWeaponPrice

	local pMuzzleFlashStyle = pKeyValuesData:GetString("MuzzleFlashStyle", "CS_MUZZLEFLASH_NORM")
	if pMuzzleFlashStyle == "CS_MUZZLEFLASH_X" then
		data.m_iMuzzleFlashStyle = 1
	elseif pMuzzleFlashStyle == "CS_MUZZLEFLASH_NONE" then
		data.m_iMuzzleFlashStyle = -1
	else
		data.m_iMuzzleFlashStyle = 0
	end

	selfTable.CSWpnData = data
end

function SWEP:SetupDataTables()
	self:NetworkVar("Bool", 0, "InReload")
	self:NetworkVar("Bool", 1, "DelayFire")
	self:NetworkVar("Bool", 2, "ResumeZoom")

	self:NetworkVar("Int", 0, "ShotsFired")
	self:NetworkVar("Int", 1, "LastZoom")
	self:NetworkVar("Int", 2, "WeaponMode")

	self:NetworkVar("Float", 0, "DecreaseShotsFired")
	self:NetworkVar("Float", 1, "WeaponIdleTime")
	self:NetworkVar("Float", 2, "AccuracyPenalty")

	self:SetDelayFire(true)
	self:SetAccuracyPenalty(0)
	self:SetWeaponMode(Primary_Mode)
end

function SWEP:GetPlayerOwner()
	local owner = self:GetOwner()
	if not (owner:IsValid() and owner:IsPlayer()) then return false end

	return owner
end

function SWEP:IsPistol(tbl)
	local selfTable = tbl or self:GetTable()

	return selfTable.CSWpnData.m_WeaponType == WEAPONTYPE_PISTOL
end
function SWEP:IsFullAuto(tbl)
	local selfTable = tbl or self:GetTable()

	return selfTable.CSWpnData.m_bFullAuto
end

function SWEP:GetWeaponFlags(tbl)
	local selfTable = tbl or self:GetTable()
	return selfTable.CSWpnData.iFlags
end

--- Overwrite this
function SWEP:GetWeaponID()
	return WEAPON_NONE
end

function SWEP:PlayEmptySound(tbl)
	local selfTable = tbl or self:GetTable()

	self:EmitSound(selfTable.IsPistol(self, selfTable) and "Default.ClipEmpty_Pistol" or "Default.ClipEmpty_Rifle")
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


function SWEP:WeaponIdle(_)
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
	--[[if self:Clip1() == 0 or (self:GetMaxClip1() == -1 and self:Ammo1() <= 0) then
		tbl.m_bFireOnEmpty = true
	end--]]

	if self:Clip1() == 0 and not tbl.m_bFireOnEmpty then return end

	if tbl.GetShotsFired(self) > 0 and not tbl.IsFullAuto(self, tbl) then return end

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

local weapon_accuracy_model = GetConVar("swsrc_weapon_accuracy_model")
function SWEP:Think_ProcessIdleNoAction(selfTable)
	if weapon_accuracy_model:GetInt() == 2 then
		if selfTable.GetShotsFired(self) > 0 and (not selfTable.IsFullAuto(self, selfTable) or self:Clip1() == 0) then
			selfTable.SetShotsFired(self, 0)
		end
	end

	if selfTable.GetDelayFire(self) then
		selfTable.SetDelayFire(self, false)

		if selfTable.GetShotsFired(self) > 15 then
			selfTable.SetShotsFired(self, 15)
		end

		selfTable.SetDecreaseShotsFired(self, CurTime() + 0.4)
	end

	selfTable.m_bFireOnEmpty = true

	if selfTable.IsPistol(self, selfTable) then
		selfTable.SetShotsFired(self, 0)
	else
		if selfTable.GetShotsFired(self) > 0 and selfTable.GetDecreaseShotsFired(self) < CurTime() then
			selfTable.SetDecreaseShotsFired(self, CurTime() + 0.0225)
			selfTable.SetShotsFired(self, selfTable.GetShotsFired(self) - 1)
		end
	end

	if selfTable.IsUseable(self) or self:GetNextPrimaryFire() >= CurTime() then
		if
			self:Clip1() == 0
			and bit.band(selfTable.GetWeaponFlags(self, selfTable), ITEM_FLAG_NOAUTORELOAD) == 0
			and self:GetNextPrimaryFire() < CurTime()
		then
			self:Reload()
			return
		end
	end

	selfTable.WeaponIdle(self, selfTable)
end

function SWEP:Think()
	local selfTable = self:GetTable()

	local owner = selfTable.GetPlayerOwner(self)
	if not owner then return end

	selfTable.UpdateAccuracyPenalty(self, selfTable)

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

	local wepTable = wep:GetTable()
	if not wep:IsValid() or not weapons.IsBasedOn(wepTable.ClassName, "weapon_swsrc_base") then return end

	if wepTable.m_bProcessActivities then
		wepTable.ProcessActivities(wep, wepTable)
		wepTable.m_bProcessActivities = false
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

	selfTable.ProcessExtraActivities(self, selfTable)

	local bInReload = selfTable.GetInReload(self)

	if bit.band(btns, IN_ATTACK2) ~= 0 and self:GetNextSecondaryFire() <= CurTime() then
		if selfTable.Think_ProcessSecondaryAttack(self, selfTable) then
			btns = bit.band(btns, bit.bnot(IN_ATTACK2))
		end
	elseif bit.band(btns, IN_ATTACK) ~= 0 and self:GetNextPrimaryFire() <= CurTime() then
		selfTable.Think_ProcessPrimaryAttack(self, selfTable)
	elseif
		bit.band(btns, IN_RELOAD) ~= 0
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

function SWEP:GetInaccuracy()
	local selfTable = self:GetTable()

	local owner = selfTable.GetPlayerOwner(self)
	if not owner then return 0 end

	local fMaxSpeed = selfTable.GetMaxSpeed(self)
	local mode = selfTable.GetWeaponMode(self)

	return selfTable.GetAccuracyPenalty(self) +
			math.Remap(owner:GetVelocity():Length2D(),
				fMaxSpeed * 0.34, -- CS_PLAYER_SPEED_DUCK_MODIFIER
				fMaxSpeed * 0.95,
				0.0, selfTable.CSWpnData.m_fInaccuracyMove[mode])
end

function SWEP:GetSpread()
	if weapon_accuracy_model:GetInt() == 1 then
		return 0
	end

	local selfTable = self:GetTable()
	local mode = selfTable.GetWeaponMode(self)

	return selfTable.CSWpnData.m_fSpread[mode]
end

function SWEP:GetMaxSpeed()
	return self:GetTable().CSWpnData.m_flMaxSpeed
end

function SWEP:CalculateNextAttackTime(fCycleTime)
	local fCurAttack = self:GetNextPrimaryFire()
	local fDeltaAttack = CurTime() - fCurAttack
	if fDeltaAttack < 0 or fDeltaAttack > engine.TickInterval() then
		fCurAttack = CurTime()
	end
	self:SetNextPrimaryFire(fCurAttack + fCycleTime)
	self:SetNextSecondaryFire(fCurAttack + fCycleTime)

	return fCurAttack
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
	if not owner then return false end

	self:SetHoldType(selfTable.HoldType)
	self:SetDeploySpeed(1) -- FIXME: cvar

	selfTable.SetDecreaseShotsFired(self, CurTime())

	selfTable.SetShotsFired(self, 0)
	selfTable.SetResumeZoom(self, false)
	selfTable.SetLastZoom(self, 0)

	if owner:GetFOV() ~= owner:GetDefaultFOV() then
		owner:SetFOV(0, 0.01)
	end

	selfTable.SetAccuracyPenalty(self, 0)

	local vm = owner:GetViewModel(self:ViewModelIndex())
	if vm:IsValid() then
		vm:SetPlaybackRate(self:GetDeploySpeed())
		selfTable.SetWeaponIdleTime(self, CurTime() + (self:SequenceDuration() * (1 / self:GetDeploySpeed())))

		local oPrim = self:GetNextPrimaryFire()
		local oSec = self:GetNextSecondaryFire()
		local idle = selfTable.GetWeaponIdleTime(self)
		self:SetNextPrimaryFire(oPrim < idle and idle or oPrim)
		self:SetNextSecondaryFire(oSec < idle and idle or oSec)
	end

	return true
end

function SWEP:OnDrop()
	local selfTable = self:GetTable()

	selfTable.SetInReload(self, false)
end


function SWEP:UpdateAccuracyPenalty(tbl)
	local selfTable = tbl or self:GetTable()

	local owner = selfTable.GetPlayerOwner(self)
	if not owner then return end

	local fNewPenalty = 0

	local wdat = selfTable.CSWpnData
	local mode = selfTable.GetWeaponMode(self)

	if owner:GetMoveType() == MOVETYPE_LADDER then
		fNewPenalty = fNewPenalty + wdat.m_fInaccuracyStand[mode] + wdat.m_fInaccuracyLadder[mode]
	elseif bit.band(owner:GetFlags(), FL_DUCKING) ~= 0 then
		fNewPenalty = fNewPenalty + wdat.m_fInaccuracyCrouch[mode]
	end

	if selfTable.GetInReload(self) then
		fNewPenalty = fNewPenalty + wdat.m_fInaccuracyReload
	end

	if fNewPenalty > selfTable.GetAccuracyPenalty(self) then
		selfTable.SetAccuracyPenalty(self, fNewPenalty)
	else
		local fDecayFactor = 0

		if owner:GetMoveType() == MOVETYPE_LADDER then
			fDecayFactor = math.log(10) / wdat.m_fRecoveryTimeStand
		elseif not owner:IsOnGround() then
			fDecayFactor = math.log(10) / (wdat.m_fRecoveryTimeCrouch * 3)
		elseif bit.band(owner:GetFlags(), FL_DUCKING) ~= 0 then
			fDecayFactor = math.log(10) / wdat.m_fRecoveryTimeCrouch
		else
			fDecayFactor = math.log(10) / wdat.m_fRecoveryTimeStand
		end

		selfTable.SetAccuracyPenalty(self,
			Lerp(math.exp(engine.TickInterval() * -fDecayFactor), fNewPenalty, selfTable.GetAccuracyPenalty(self)))
	end
end

function SWEP:PrimaryAttack()
	-- Derived classes should implement this and call CSBaseGunFire.
end
