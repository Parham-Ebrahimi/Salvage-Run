-- Single source for world materials. Third-party stud maps approved temporarily.
-- Builders call InstallVariants in Studio; runtime renderers only call Apply.
local Style = {}
Style.PreviewTextureConfirmed = true -- Approved 2026-10-02; replace with owned upload before release.
Style.StudsPerTile = 1 -- One repeating square stud per world stud, independent of part size.
Style.Definitions = {
	Stud = {
		Name = "SalvageStud",
		BaseMaterial = Enum.Material.Plastic,
		ColorMap = "rbxassetid://10509831729",
		NormalMap = "rbxassetid://10509831753",
		RoughnessMap = "",
		MetalnessMap = "",
	},
	Trim = {
		Name = "SalvageDiamondPlate",
		BaseMaterial = Enum.Material.DiamondPlate,
		ColorMap = "rbxassetid://13966407837",
		NormalMap = "rbxassetid://13966458944",
		RoughnessMap = "rbxassetid://13966471557",
		MetalnessMap = "rbxassetid://13966447800",
	},
}

function Style.InstallVariants()
	local run = game:GetService("RunService")
	assert(run:IsStudio() and not run:IsRunning(), "Install materials in Studio Edit only")
	local service = game:GetService("MaterialService")
	for _, definition in Style.Definitions do
		local variant = service:FindFirstChild(definition.Name)
		assert(not variant or variant:IsA("MaterialVariant"), "Conflicting material name")
		if not variant then
			variant = Instance.new("MaterialVariant")
			variant.Name = definition.Name
		end
		variant.BaseMaterial = definition.BaseMaterial
		variant.MaterialPattern = Enum.MaterialPattern.Regular
		variant.StudsPerTile = Style.StudsPerTile
		for _, property in { "ColorMap", "NormalMap", "RoughnessMap", "MetalnessMap" } do
			variant[property] = definition[property]
		end
		variant.Parent = service
	end
end

function Style.Apply(part, role)
	assert(part:IsA("BasePart"), "Style.Apply expects a BasePart")
	assert(role == "Stud" or role == "Trim" or role == "Glow", "Unknown material role")
	-- Clear imported overlays on the instance being styled, never on its template.
	for _, child in part:GetChildren() do
		if child:IsA("Texture") or child:IsA("Decal") or child:IsA("SurfaceAppearance") then
			child:Destroy()
		elseif child:IsA("SpecialMesh") then
			child.TextureId = ""
		end
	end
	if part:IsA("MeshPart") then part.TextureID = "" end
	for _, face in { "TopSurface", "BottomSurface", "LeftSurface", "RightSurface", "FrontSurface", "BackSurface" } do
		part[face] = Enum.SurfaceType.Smooth
	end
	-- Only block Parts receive variants. MeshParts keep their geometry and color.
	if part:IsA("MeshPart") or (role ~= "Glow" and not (part:IsA("Part") and part.Shape == Enum.PartType.Block)) then
		part.MaterialVariant = ""
		part.Material = Enum.Material.SmoothPlastic
		part.Reflectance = 0
		return
	end
	if role == "Glow" then
		part.MaterialVariant = ""
		part.Material = Enum.Material.Neon
	else
		local definition = Style.Definitions[role]
		assert(game.MaterialService:FindFirstChild(definition.Name), "Build shared materials first")
		part.Material = definition.BaseMaterial
		part.MaterialVariant = definition.Name
	end
end

return Style
