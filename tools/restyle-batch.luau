-- Return a Studio Edit batch runner. Pass ONE stage number and the canonical
-- tools/verify-world.luau as a callback. No yielding during apply/verify/rollback.
-- Stop for the user's Roblox save after a successful batch; never loop stages.
local Style = require(game.ReplicatedStorage.Shared.VisualStyle)
local faces = { "TopSurface", "BottomSurface", "LeftSurface", "RightSurface", "FrontSurface", "BackSurface" }
local properties = { "Material", "MaterialVariant", "Reflectance", "CustomPhysicalProperties", "Color", "Size", "CFrame", "TopSurface", "BottomSurface", "LeftSurface", "RightSurface", "FrontSurface", "BackSurface" }
local function snapshot(p)
	local values = {}
	for _, key in properties do values[key] = p[key] end
	if p:IsA("MeshPart") then values.TextureID = p.TextureID end
	return { Part = p, Values = values, Physics = p.CurrentPhysicalProperties }
end
local function unchanged(entry, visualMayChange)
	local p, values = entry.Part, entry.Values
	local keys = visualMayChange and { "Color", "Size", "CFrame" } or properties
	for _, key in keys do
		if key == "CustomPhysicalProperties" and p[key] ~= nil and values[key] ~= nil then
			for _, field in { "Density", "Friction", "Elasticity", "FrictionWeight", "ElasticityWeight" } do
				assert(math.abs(p[key][field] - values[key][field]) < .00001, "Unexpected physics change")
			end
		else assert(p[key] == values[key], "Unexpected change: " .. p:GetFullName() .. "." .. key) end
	end
	if p:IsA("MeshPart") then assert(p.TextureID == values.TextureID, "Unexpected mesh texture change") end
end
return function(stageNumber, verifyInventory)
	assert(game:GetService("RunService"):IsStudio() and not game:GetService("RunService"):IsRunning(), "Edit only")
	assert(type(verifyInventory) == "function", "Pass canonical world verifier")
	assert(stageNumber % 1 == 0 and stageNumber >= 1 and stageNumber <= 10, "One valid stage per call")
	assert(Style.PreviewTextureConfirmed, "Texture is not approved")
	assert(verifyInventory().Passed, "World inventory/overlap verification failed before batch")
	local world = workspace.SalvageWorld
	local stage = assert(world.Stages:FindFirstChild(tostring(stageNumber)), "Missing stage")
	assert(not stage:GetAttribute("VisualStyleBatchComplete"), "Batch already completed; do not reapply")
	for _, definition in Style.Definitions do
		local variant = game.MaterialService:FindFirstChild(definition.Name)
		assert(variant and variant:IsA("MaterialVariant"), "Required variant missing")
		assert(variant.BaseMaterial == definition.BaseMaterial and variant.StudsPerTile == Style.StudsPerTile and variant.MaterialPattern == Enum.MaterialPattern.Regular, "Variant definition mismatch")
		for _, key in { "ColorMap", "NormalMap", "RoughnessMap", "MetalnessMap" } do assert(variant[key] == definition[key], "Variant map mismatch") end
	end
	local targets, targetSet, backups, untouched = {}, {}, {}, {}
	local function include(p, isArch)
		if p:IsA("Part") and p.Shape == Enum.PartType.Block then
			local role = p.Material == Enum.Material.Neon and "Glow" or (isArch and p.Material == Enum.Material.Metal and "Trim" or "Stud")
			table.insert(targets, { Part = p, Role = role })
			targetSet[p] = true
		end
	end
	for _, p in stage:GetDescendants() do if p:IsA("BasePart") then include(p, p:IsDescendantOf(stage.Arch)) end end
	local wallCount = 0
	for _, p in world.Walls:GetChildren() do
		if p.Name == "StripWall" and p:IsA("BasePart") and math.abs(p.Position.Z - stage.Ground.Position.Z) < .01 then include(p, false); wallCount += 1 end
	end
	assert(wallCount == 2 and targetSet[stage.Ground], "Stage floor and exactly two side walls required")
	for _, target in targets do
		local backup = snapshot(target.Part)
		backup.Children, backup.MeshTextures = {}, {}
		for _, child in target.Part:GetChildren() do
			if child:IsA("Texture") or child:IsA("Decal") or child:IsA("SurfaceAppearance") then
				assert(child.Archivable, "Overlay cannot be backed up")
				table.insert(backup.Children, assert(child:Clone(), "Overlay backup failed"))
			elseif child:IsA("SpecialMesh") then backup.MeshTextures[child] = child.TextureId end
		end
		table.insert(backups, backup)
	end
	for _, p in world:GetDescendants() do if p:IsA("BasePart") and not targetSet[p] then table.insert(untouched, snapshot(p)) end end
	local previousBatch = stage:GetAttribute("VisualStyleBatchComplete")
	local previousTexture = stage:GetAttribute("VisualStyleColorMap")
	local previousTile = stage:GetAttribute("VisualStyleStudsPerTile")
	local roles, inventory = { Stud = 0, Trim = 0, Glow = 0 }, nil
	local ok, failure = xpcall(function()
		for i, target in targets do
			Style.Apply(target.Part, target.Role)
			-- Preserve the old contact properties when changing the visual material.
			target.Part.CustomPhysicalProperties = backups[i].Physics
			roles[target.Role] += 1
		end
		for i, target in targets do
			unchanged(backups[i], true)
			local p = target.Part
			if target.Role == "Glow" then assert(p.Material == Enum.Material.Neon and p.MaterialVariant == "", "Glow mismatch")
			else assert(p.MaterialVariant == Style.Definitions[target.Role].Name, "Block variant mismatch") end
			for _, face in faces do assert(p[face] == Enum.SurfaceType.Smooth, "Unexpected surface studs") end
			for _, child in p:GetChildren() do assert(not child:IsA("Texture") and not child:IsA("Decal") and not child:IsA("SurfaceAppearance"), "Per-part texture remains") end
			local before, after = backups[i].Physics, p.CurrentPhysicalProperties
			for _, key in { "Density", "Friction", "Elasticity", "FrictionWeight", "ElasticityWeight" } do assert(math.abs(before[key] - after[key]) < .00001, "Physics changed") end
		end
		for _, entry in untouched do unchanged(entry, false) end
		stage:SetAttribute("VisualStyleBatchComplete", true)
		stage:SetAttribute("VisualStyleColorMap", Style.Definitions.Stud.ColorMap)
		stage:SetAttribute("VisualStyleStudsPerTile", Style.StudsPerTile)
		inventory = verifyInventory()
		assert(inventory.Passed, "World inventory/overlap verification failed after batch")
	end, debug.traceback)
	if not ok then
		local rollbackOk, rollbackError = pcall(function()
			for _, entry in backups do
				local p = entry.Part
				for _, key in properties do p[key] = entry.Values[key] end
				for _, child in p:GetChildren() do if child:IsA("Texture") or child:IsA("Decal") or child:IsA("SurfaceAppearance") then child:Destroy() end end
				for _, child in entry.Children do child.Parent = p end
				for mesh, texture in entry.MeshTextures do mesh.TextureId = texture end
			end
			stage:SetAttribute("VisualStyleBatchComplete", previousBatch)
			stage:SetAttribute("VisualStyleColorMap", previousTexture)
			stage:SetAttribute("VisualStyleStudsPerTile", previousTile)
			for _, entry in backups do unchanged(entry, false) end
			verifyInventory()
		end)
		return { Passed = false, Error = failure, RolledBack = rollbackOk, RollbackError = rollbackError, Stop = true }
	end
	for _, entry in backups do for _, child in entry.Children do child:Destroy() end end
	return { Passed = true, Stage = stageNumber, BlockParts = #targets, Roles = roles, SideWalls = wallCount, UntouchedPartsChecked = #untouched, Inventory = inventory, AwaitUserSave = true, Stop = true }
end
