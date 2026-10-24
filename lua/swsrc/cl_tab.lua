list.Set("ContentCategoryIcons", language.GetPhrase("#spawnmenu.category.swsrc"), "games/16/cstrike.png")

local group_others = CreateClientConVar("swsrc_group_others", "1", true, false,
	"Whether or not to group other swsrc addons under the CS:S category", 0, 1)

local categoryMap = {
	[WEAPONTYPE_KNIFE] = "#spawnmenu.category.other",
	[WEAPONTYPE_PISTOL] = "#spawnmenu.category.swsrc_pistols",
	[WEAPONTYPE_SUBMACHINEGUN] = "#spawnmenu.category.swsrc_smgs",
	[WEAPONTYPE_RIFLE] = "#spawnmenu.category.swsrc_rifles",
	[WEAPONTYPE_SHOTGUN] = "#spawnmenu.category.swsrc_shotguns",
	[WEAPONTYPE_SNIPER_RIFLE] = "#spawnmenu.category.swsrc_snipers",
	[WEAPONTYPE_MACHINEGUN] = "#spawnmenu.category.swsrc_mgs",
	[WEAPONTYPE_C4] = "#spawnmenu.category.other",
	[WEAPONTYPE_GRENADE] = "#spawnmenu.category.swsrc_grenades",
	[WEAPONTYPE_UNKNOWN] = "#spawnmenu.category.other",
}
hook.Add("PopulateWeapons", "swsrc.spawnmenu", function(pnlContent, tree)
	timer.Simple(0, function()
		local weps = list.Get("Weapon")
		local cats = {}

		local targetCat = language.GetPhrase("#spawnmenu.category.swsrc")
		-- temp until i add strings
		if targetCat == "#spawnmenu.category.swsrc" then
			targetCat = "spawnmenu.category.swsrc"
		end

		for k, wep in pairs(weps) do
			if not wep.Spawnable then continue end
			if not weapons.IsBasedOn(k, "weapon_swsrc_base") then continue end

			local cat = language.GetPhrase(wep.Category) or "Other"
			if not isstring(cat) then cat = tostring(cat) end
			if cat:sub(1, 1) == "#" then
				cat = cat:sub(2)
			end

			local swep = weapons.Get(wep.ClassName)

			---@type number|string
			local subcat = WEAPONTYPE_UNKNOWN

			if swep then
				subcat = swep.CSWpnData.m_WeaponType or WEAPONTYPE_UNKNOWN
			end

			if categoryMap[subcat] then
				subcat = categoryMap[subcat]
			end

			cats[cat] = cats[cat] or {}
			cats[cat][subcat] = cats[cat][subcat] or {}

			table.insert(cats[cat][subcat], wep)
		end

		for _, node in next, tree:Root():GetChildNodes() do
			local nodeText = node:GetText()

			if nodeText ~= targetCat then
				if cats[nodeText] and group_others:GetBool() then
					local css_node
					for _, child_node in next, tree:Root():GetChildNodes() do
						if child_node:GetText() == targetCat then
							css_node = child_node
							break
						end
					end

					if IsValid(css_node) then
						css_node:InsertNode(node)
						node:SetDrawLines(true)
					end
				end

				continue
			end

			local subcats = cats[nodeText]
			if not subcats then continue end

			node.DoPopulate = function(self)
				if IsValid(self.PropPanel) then self.PropPanel:Remove() end

				self.PropPanel = vgui.Create("ContentContainer", pnlContent)
				self.PropPanel:SetVisible(false)
				self.PropPanel:SetTriggerSpawnlistChange(false)

				for name, subweps in SortedPairs(subcats) do
					if not table.IsEmpty(subweps) then
						---@diagnostic disable-next-line: param-type-mismatch
						local label = vgui.Create("ContentHeader", self.PropPanel)
						label:SetText(name)
						self.PropPanel:Add(label)
					end

					for _, ent in SortedPairsByMemberValue(subweps, "PrintName") do
						---@diagnostic disable-next-line: param-type-mismatch
						spawnmenu.CreateContentIcon(ent.ScriptedEntityType or "weapon", self.PropPanel, {
							nicename  = ent.PrintName or ent.ClassName,
							spawnname = ent.ClassName,
							material  = ent.IconOverride or ("entities/" .. ent.ClassName .. ".png"),
							admin     = ent.AdminOnly,
						})
					end
				end
			end
		end

		local FirstNode = tree:Root():GetChildNode(0)
		if IsValid(FirstNode) then
			FirstNode:InternalDoClick()
		end

		timer.Simple(0, function()
			tree:Root():ExpandRecurse(true)
		end)
	end)
end)
