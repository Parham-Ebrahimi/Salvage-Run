local assets=game.ReplicatedStorage.SalvageAssets
local names={"engine_block","crucible","quantum_drive","reactor_rod","alien_power_cell","impossible_ring"}
local made={}
local function piece(m,name,size,pos,color,shape)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.Position=pos;p.Color=color;p.Material=Enum.Material.Metal;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;if shape then p.Shape=shape end;p.Parent=m;return p
end
for _,id in names do
 local old=assets:FindFirstChild("item_"..id);if old then old:Destroy()end
 local m=Instance.new("Model");m.Name="item_"..id;m.Parent=assets
 local gray=Color3.fromRGB(95,109,122);local cyan=Color3.fromRGB(67,218,230)
 if id=="engine_block" then
  piece(m,"Block",Vector3.new(3,1.5,2),Vector3.zero,gray)
  for x=-1,1 do for _,z in {-1,1} do local p=piece(m,"Piston",Vector3.new(.8,.7,.7),Vector3.new(x,1,z*.7),Color3.fromRGB(161,173,179),Enum.PartType.Cylinder);p.CFrame=p.CFrame*CFrame.Angles(0,0,math.pi/2) end end
 elseif id=="crucible" then
  local p=piece(m,"Bowl",Vector3.new(2,3,3),Vector3.zero,gray,Enum.PartType.Cylinder);p.CFrame=CFrame.Angles(0,0,math.pi/2)
  local glow=piece(m,"MoltenMetal",Vector3.new(.1,2.6,2.6),Vector3.new(0,1.01,0),Color3.fromRGB(255,146,63),Enum.PartType.Cylinder);glow.CFrame=CFrame.new(glow.Position)*CFrame.Angles(0,0,math.pi/2);glow.Material=Enum.Material.Neon
 elseif id=="impossible_ring" then
  for i=1,16 do local a=i/16*math.pi*2;local p=piece(m,"TwistedRing",Vector3.new(.45,.45,.9),Vector3.new(math.cos(a)*1.9,math.sin(a)*1.9,math.sin(a*2)*.4),Color3.fromRGB(167,99,218));p.CFrame=CFrame.lookAt(p.Position,p.Position+Vector3.new(-math.sin(a),math.cos(a),0))*CFrame.Angles(0,0,a/2) end
 elseif id=="reactor_rod" then
  local p=piece(m,"Rod",Vector3.new(4,.6,.6),Vector3.zero,Color3.fromRGB(176,228,67),Enum.PartType.Cylinder);p.CFrame=CFrame.Angles(0,0,math.pi/2);p.Material=Enum.Material.Neon
  for _,y in {-2,2} do local cap=piece(m,"Cap",Vector3.new(.3,1,1),Vector3.new(0,y,0),gray,Enum.PartType.Cylinder);cap.CFrame=CFrame.new(cap.Position)*CFrame.Angles(0,0,math.pi/2) end
 elseif id=="alien_power_cell" then
  local p=piece(m,"Core",Vector3.new(1.3,2.6,1.3),Vector3.zero,Color3.fromRGB(155,101,219),Enum.PartType.Ball);p.Material=Enum.Material.Neon
  for _,y in {-1.3,1.3} do local cap=piece(m,"Cap",Vector3.new(.4,1.8,1.8),Vector3.new(0,y,0),gray,Enum.PartType.Cylinder);cap.CFrame=CFrame.new(cap.Position)*CFrame.Angles(0,0,math.pi/2) end
 else
  piece(m,"Housing",Vector3.new(3,2,3),Vector3.zero,gray)
  local p=piece(m,"QuantumCore",Vector3.new(1.8,1.8,1.8),Vector3.new(0,.8,0),cyan,Enum.PartType.Ball);p.Material=Enum.Material.Neon
  for _,x in {-1.6,1.6} do piece(m,"Fin",Vector3.new(.3,2.6,3.5),Vector3.new(x,0,0),Color3.fromRGB(51,65,85))end
 end
 m.PrimaryPart=m:FindFirstChildWhichIsA("BasePart");table.insert(made,id)
end
-- Use a real Toolbox UFO hull fragment instead of an unrelated search result.
local bad=assets:FindFirstChild("item_saucer_fragment");if bad then bad:Destroy()end
local source=assets.ufo:FindFirstChildWhichIsA("BasePart",true)
local fragment=Instance.new("Model");fragment.Name="item_saucer_fragment";source:Clone().Parent=fragment;fragment.PrimaryPart=fragment:FindFirstChildWhichIsA("BasePart");fragment.Parent=assets
local cf=fragment:GetBoundingBox();fragment:PivotTo(cf:Inverse()*fragment:GetPivot());fragment:SetAttribute("AssetId","162741606")
return {made=made,saucer="adapted from audited Roblox UFO hull",count=#assets:GetChildren()}
