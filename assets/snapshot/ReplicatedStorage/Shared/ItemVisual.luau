local C=require(script.Parent.Config)
local I={}
function I.Apply(model,mutation)
 if mutation==1 then return end
 local m=C.Mutations[mutation];local primary=model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart",true)
 for _,p in model:GetDescendants() do
  if p:IsA("BasePart") then
   p.Color=mutation==8 and Color3.fromRGB(13,9,24) or m.Color
   p.Material=mutation==2 and Enum.Material.Metal or mutation==5 and Enum.Material.Glass or mutation>=6 and Enum.Material.Neon or Enum.Material.SmoothPlastic
   p.Reflectance=mutation==2 and .6 or mutation==3 and .2 or 0
   if mutation==5 then p.Transparency=math.max(.2,p.Transparency) end
  end
 end
 if not primary then return end
 if mutation>=3 then
  local h=Instance.new("Highlight");h.Name="MutationGlow";h.FillColor=m.Color;h.OutlineColor=m.Color;h.FillTransparency=.85;h.OutlineTransparency=.3;h.DepthMode=Enum.HighlightDepthMode.Occluded;h.Parent=model
  local light=Instance.new("PointLight");light.Color=m.Color;light.Range=C.Physics.PickupRadius;light.Brightness=mutation>=6 and 1.4 or .6;light.Parent=primary
 end
 if mutation>=4 then
  local e=Instance.new("ParticleEmitter");e.Name="MutationParticles";e.Texture="rbxasset://textures/particles/sparkles_main.dds";e.Color=ColorSequence.new(m.Color);e.LightEmission=1;e.Rate=mutation>=6 and 12 or 5;e.Lifetime=NumberRange.new(.4,.8);e.Speed=NumberRange.new(mutation==8 and -2 or 1,mutation==8 and -1 or 3);e.SpreadAngle=Vector2.new(180,180);e.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,.3),NumberSequenceKeypoint.new(1,0)});e.Parent=primary
 end
 if mutation==6 then local fire=Instance.new("Fire");fire.Color=m.Color;fire.SecondaryColor=Color3.fromRGB(160,220,255);fire.Size=4;fire.Heat=0;fire.Parent=primary end
 model:SetAttribute("Mutation",mutation)
end
function I.Clone(itemId,mutation,sizeIndex)
 local item=C.ItemsById[itemId];if not item then return nil end
 local template=game.ReplicatedStorage.SalvageAssets:FindFirstChild(item.Asset);if not template then return nil end
 local m=template:Clone();local _,size=m:GetBoundingBox()
 m:ScaleTo(C.Pickup.ItemMaxSize/math.max(size.X,size.Y,size.Z)*(sizeIndex and C.Sizes[sizeIndex].Scale or 1))
 I.Apply(m,mutation or 1);return m
end
return I
