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

function swsrc.WeaponClassFromString(weaponType)
	for _, info in ipairs(s_weaponTypeInfo) do
		if info[2] == weaponType then
			return info[1]
		end
	end

	return WEAPONTYPE_UNKNOWN
end

local function makeModeValues(pKeyValuesData, key, default)
	return {
		[0] = pKeyValuesData:GetFloat(key, default),
		[1] = pKeyValuesData:GetFloat(key .. "Alt", default),
	}
end
function swsrc.ParseWeaponData(WeaponData)
	local pKeyValuesData = swsrc.KeyValuesHelper(WeaponData or "", false, true)
	if not pKeyValuesData then return {} end

	local data = {
		szPrintName               = pKeyValuesData:GetString("printname"),
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

		m_WeaponType              = swsrc.WeaponClassFromString(pKeyValuesData:GetString("WeaponType", "")),

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

	return data
end

function swsrc.RegisterWeapon(WeaponData, SWEP)
	if not SWEP then return end
	if not WeaponData or WeaponData == "" then return end

	local data = swsrc.ParseWeaponData(WeaponData)

	SWEP.CSWpnData = data

	-- fill in swep vars
	SWEP.PrintName = data.szPrintName

	SWEP.Slot = data.iSlot
	SWEP.SlotPos = data.iPosition

	SWEP.Primary.Ammo = data.szAmmo1
	SWEP.Primary.ClipSize = data.iMaxClip1
	if data.iMaxClip1 == -1 then
		SWEP.Primary.DefaultClip = -1
	else
		SWEP.Primary.DefaultClip = data.iDefaultClip1
	end
	SWEP.Primary.Automatic = data.m_bFullAuto

	SWEP.Secondary.Ammo = data.szAmmo2
	SWEP.Secondary.ClipSize = data.iMaxClip2
	if data.iMaxClip2 == -1 then
		SWEP.Secondary.DefaultClip = -1
	else
		SWEP.Secondary.DefaultClip = data.iDefaultClip2
	end
	SWEP.Secondary.Automatic = data.m_bFullAuto

	-- let weapons override if desired
	if SWEP.OverrideData then
		SWEP.OverrideData(nil, SWEP)
	end
end

swsrc.RegisteredItems = {}
hook.Add("PreRegisterSWEP", "swsrc.register", function(swep, class)
	local BaseName = swep.Base
	if BaseName and class ~= "weapon_swsrc_basegun" then
		if
			(
				BaseName == "weapon_swsrc_base"
				or BaseName == "weapon_swsrc_basegun"
				or weapons.IsBasedOn(BaseName, "weapon_swsrc_base")
			) and swep.WeaponData
		then
			Msg("[swsrc] ")
			print("Registering " .. class)
			swsrc.RegisterWeapon(swep.WeaponData, swep)
			swsrc.RegisteredItems[class] = swep
		end
	end
end)
