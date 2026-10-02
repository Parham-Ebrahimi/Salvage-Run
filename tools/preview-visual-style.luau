-- Studio Edit: isolated two-row comparison. No rollout.
-- User-supplied Row B map and confirmation flag belong in VisualStyle.
local Style = require(game.ReplicatedStorage.Shared.VisualStyle)
assert(game:GetService("RunService"):IsStudio() and not game:GetService("RunService"):IsRunning(), "Edit only")
local old = workspace:FindFirstChild("VisualStylePreview")
if old then old:Destroy() end
Style.InstallVariants()
local group = Instance.new("Model")
group.Name = "VisualStylePreview"
group:SetAttribute("ApprovalPending", true)
group.Parent = workspace
local function makeRow(group, builtIn)
local origin = Vector3.new(225, 42, 65) + Vector3.new(builtIn and -9 or 9, 0, 0)
local neutral = Color3.fromRGB(175, 185, 195)
local function sample(name, size, offset, role)
	local p = Instance.new("Part")
	p.Name = name
	p.Anchored = true
	p.Size = size
	p.Position = origin + offset
	p.Color = neutral
	p.Parent = group
	Style.Apply(p, role or "Stud")
	return p
end
sample("Floor", Vector3.new(14, 1, 12), Vector3.zero)
sample("Wall", Vector3.new(14, 8, 1), Vector3.new(0, 4.5, -5.5))
sample("Box", Vector3.new(4, 4, 4), Vector3.new(-3.5, 2.5, 1))
local template = game.ReplicatedStorage.SalvageAssets["small rock"]:FindFirstChildWhichIsA("MeshPart", true)
assert(template, "Expected audited small-rock MeshPart")
local mesh = template:Clone()
for _, d in mesh:GetDescendants() do
	if d:IsA("LuaSourceContainer") or d:IsA("JointInstance") or d:IsA("Constraint") or d:IsA("BillboardGui") then d:Destroy() end
end
mesh.Name = "MeshPart"
mesh.Anchored = true
mesh.Size = Vector3.new(4, 4, 4)
mesh.CFrame = CFrame.new(origin + Vector3.new(3.5, 2.5, 1))
mesh.Color = neutral
mesh.Parent = group
Style.Apply(mesh, "Stud")
local faces = { "TopSurface", "BottomSurface", "LeftSurface", "RightSurface", "FrontSurface", "BackSurface" }
for _, p in group:GetChildren() do
 if builtIn and p:IsA("Part") then p.Material = Enum.Material.Plastic; p.MaterialVariant = "" end
 for _, face in faces do p[face] = builtIn and p:IsA("Part") and Enum.SurfaceType.Studs or Enum.SurfaceType.Smooth end
end
if builtIn then
 group:SetAttribute("SurfaceMethod", "SurfaceType.Studs on all six faces")
else
 group:SetAttribute("TextureIdPending", not Style.PreviewTextureConfirmed)
 group:SetAttribute("CurrentUnapprovedColorMap", Style.Definitions.Stud.ColorMap)
end
local anchor = Instance.new("Part")
anchor.Name = "LabelAnchor"; anchor.Size = Vector3.new(.1,.1,.1)
anchor.Transparency = 1; anchor.CanCollide = false; anchor.Anchored = true
anchor.Position = group.Wall.Position + Vector3.new(0,6,0); anchor.Parent = group
local gui = Instance.new("BillboardGui")
gui.Size = UDim2.fromOffset(280,50); gui.AlwaysOnTop = true; gui.Parent = anchor
local label = Instance.new("TextLabel")
label.Size = UDim2.fromScale(1,1); label.BackgroundColor3 = Color3.fromRGB(20,25,30)
label.BackgroundTransparency = .15; label.TextColor3 = Color3.new(1,1,1)
label.TextScaled = true; label.Font = Enum.Font.GothamBold
label.Text = builtIn and "A · Built-in studs" or (Style.PreviewTextureConfirmed and "B · MaterialVariant" or "B · Texture ID pending")
label.Parent = gui
end
for _, name in { "RowA", "RowB" } do
 local row = Instance.new("Model"); row.Name = name; row.Parent = group
 makeRow(row, name == "RowA")
end
local camera = workspace.CurrentCamera
camera.CFrame = CFrame.lookAt(Vector3.new(225,54,91), Vector3.new(225,46,64))
camera.Focus = CFrame.new(225,46,64)
game:GetService("Selection"):Set({ group })
local maps, loads = {}, {}
for _, definition in Style.Definitions do
	for _, property in { "ColorMap", "NormalMap", "RoughnessMap", "MetalnessMap" } do
		if definition[property] ~= "" then table.insert(maps, definition[property]) end
	end
end
game:GetService("ContentProvider"):PreloadAsync(maps, function(id, status)
	table.insert(loads, { Id = id, Status = tostring(status) })
end)
return { Group = group:GetFullName(), StudsPerTile = Style.StudsPerTile, Rows = 2, SamplesPerRow = 4, TextureIdPending = not Style.PreviewTextureConfirmed, TextureLoads = loads, ApprovalPending = true }
