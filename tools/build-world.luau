-- Execute this repo file with Studio MCP in Edit mode; no managed scripts are edited.
local C=require(game.ReplicatedStorage.Shared.Config)
local old=workspace:FindFirstChild("SalvageWorld"); if old then old:Destroy() end
local world=Instance.new("Folder"); world.Name="SalvageWorld"; world.Parent=workspace
local function part(name,size,pos,color,material,parent)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.Position=pos;p.Color=color;p.Material=material or Enum.Material.SmoothPlastic;p.Anchored=true;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent or world;return p
end
local function sign(p,text,size)
 local gui=Instance.new("SurfaceGui");gui.Face=Enum.NormalId.Front;gui.PixelsPerStud=32;gui.Parent=p
 local label=Instance.new("TextLabel");label.Size=UDim2.fromScale(1,1);label.BackgroundTransparency=1;label.Text=text;label.TextColor3=Color3.new(1,1,1);label.TextScaled=true;label.Font=C.UI.TitleFont;label.Parent=gui
 local stroke=Instance.new("UIStroke");stroke.Thickness=C.UI.Stroke;stroke.Parent=label
 local pad=Instance.new("UIPadding");pad.PaddingTop=UDim.new(0,8);pad.PaddingBottom=UDim.new(0,8);pad.Parent=label
end
local W=C.World
part("BaseGround",Vector3.new(W.BaseWidth,W.GroundThickness,W.BaseDepth),Vector3.new(0,-W.GroundThickness/2,W.BaseDepth/2),Color3.fromRGB(195,204,205),Enum.Material.Concrete)
local bay=part("VehicleBay",Vector3.new(W.Width*W.BayWidthFraction,.16,W.BayDepth),Vector3.new(0,.08+W.BaySurfaceLift,W.BayZ),Color3.fromRGB(51,96,133),Enum.Material.Asphalt)
for x=-3,3 do part("BayMark",Vector3.new(.3,.04,W.BayDepth-4),Vector3.new(x*18,.18+W.BaySurfaceLift,W.BayZ),C.UI.Paper) end
local safe=part("SafeLine",Vector3.new(W.Width,.2,2),Vector3.new(0,.15+W.SafeSurfaceLift,W.SafeLine),C.UI.Green,Enum.Material.Neon);safe.CanCollide=false;safe.CanTouch=false
local plots=Instance.new("Folder");plots.Name="Plots";plots.Parent=world
for i=1,W.PlotCount do
 local f=Instance.new("Model");f.Name=tostring(i);f:SetAttribute("Owner",0);f.Parent=plots
 local x=(i-(W.PlotCount+1)/2)*W.PlotSpacing
 part("Ground",Vector3.new(W.PlotSize,.3,W.PlotSize),Vector3.new(x,.2,W.PlotZ),Color3.fromRGB(157,179,150),Enum.Material.Grass,f)
 for _,edge in {-1,1} do
  part("Border",Vector3.new(W.PlotSize,1,1),Vector3.new(x,.6,W.PlotZ+edge*W.PlotSize/2),Color3.fromRGB(220,229,213),nil,f)
  part("Border",Vector3.new(1,1,W.PlotSize),Vector3.new(x+edge*W.PlotSize/2,.6-W.PlotSideBorderDrop,W.PlotZ),Color3.fromRGB(220,229,213),nil,f)
 end
 local spawn=part("Home",Vector3.new(5,.2,5),Vector3.new(x,.4,W.PlotZ-22),C.UI.Paper,nil,f);spawn.Transparency=1;spawn.CanCollide=false
 local income=part("Income",Vector3.new(14,4,1),Vector3.new(x,4,W.PlotZ-37),Color3.fromRGB(47,78,59),nil,f);sign(income,"$0/sec")
 local pedestals=Instance.new("Folder");pedestals.Name="Pedestals";pedestals.Parent=f
 for j=1,C.Economy.PedestalMax do
  local col=(j-1)%4;local row=math.floor((j-1)/4)
  local p=part(tostring(j),Vector3.new(W.PedestalRadius*2,W.PedestalHeight,W.PedestalRadius*2),Vector3.new(x+(col-1.5)*W.PedestalSpacing,W.PedestalHeight/2+.4,W.PlotZ+row*W.PedestalSpacing-5),Color3.fromRGB(204,211,207),Enum.Material.Concrete,pedestals)
  p:SetAttribute("Index",j);p:SetAttribute("Plot",i);p.Transparency=j>C.Economy.PedestalStart and 1 or 0;p.CanCollide=j<=C.Economy.PedestalStart
 end
end
local walls=Instance.new("Folder");walls.Name="Walls";walls.Parent=world
for _,side in {-1,1} do
 part("BaseWall",Vector3.new(W.WallThickness,W.WallHeight,W.BaseDepth),Vector3.new(side*W.BaseWidth/2,W.WallHeight/2,W.BaseDepth/2),Color3.fromRGB(69,81,88),Enum.Material.Concrete,walls)
 part("Shoulder",Vector3.new((W.BaseWidth-W.Width)/2,W.WallHeight,W.WallThickness),Vector3.new(side*(W.BaseWidth+W.Width)/4,W.WallHeight/2,0),Color3.fromRGB(69,81,88),Enum.Material.Concrete,walls)
 for stage=1,#C.Stages do
  part("StripWall",Vector3.new(W.WallThickness,W.WallHeight,W.StageLength),Vector3.new(side*W.Width/2,W.WallHeight/2,-(stage-.5)*W.StageLength),C.Stages[stage].Color:Lerp(Color3.new(.2,.2,.25),.65),Enum.Material.Concrete,walls)
 end
end
part("BackWall",Vector3.new(W.BaseWidth,W.WallHeight,W.WallThickness),Vector3.new(0,W.WallHeight/2,W.BaseDepth),Color3.fromRGB(69,81,88),Enum.Material.Concrete,walls)
part("EndWall",Vector3.new(W.Width,W.WallHeight,W.WallThickness),Vector3.new(0,W.WallHeight/2,-#C.Stages*W.StageLength),C.UI.Dark,Enum.Material.Concrete,walls)
local stages=Instance.new("Folder");stages.Name="Stages";stages.Parent=world
local assets=game.ReplicatedStorage.SalvageAssets
local missing={}
for i,s in C.Stages do
 local f=Instance.new("Folder");f.Name=tostring(i);f.Parent=stages
 local start=-(i-1)*W.StageLength
 local floor=part("Ground",Vector3.new(W.Width,W.GroundThickness,W.StageLength),Vector3.new(0,-W.GroundThickness/2,start-W.StageLength/2),s.Color,s.Material,f);floor:SetAttribute("Stage",i)
 -- Owner O2: no stage-start arch, flag or stage-name sign. Stage names
 -- remain in Config; StageService uses position rather than entrance models.
 local props=Instance.new("Folder");props.Name="Props";props.Parent=f
 for k=1,W.PropCount do
  local key=s.Props[(k-1)%#s.Props+1];local template=assets:FindFirstChild(key)
  local x=(k%2==0 and 1 or -1)*(W.Width/2-21);local z=start-40-math.floor((k-1)/2)*78
  if template then
   local m=template:Clone();m.Name=key;m.Parent=props
   local _,size=m:GetBoundingBox();m:ScaleTo(math.min(W.PropMaxSize/math.max(size.X,size.Y,size.Z),1))
   local _,scaled=m:GetBoundingBox();m:PivotTo(CFrame.new(x,scaled.Y/2,z)*CFrame.Angles(0,k*.7,0))
   for _,p in m:GetDescendants() do if p:IsA("BasePart") then p.CanCollide=true end end
  else
   table.insert(missing,key);part("MISSING "..key,Vector3.new(7,5,5),Vector3.new(x,2.5,z),s.Color:Lerp(Color3.new(.5,.5,.5),.35),Enum.Material.Metal,props)
  end
 end
 if i==4 then for _,side in {-1,1} do local water=part("WaterEdge",Vector3.new(C.Hazards.WaterWidth,.4,W.StageLength-8),Vector3.new(side*(W.Width/2-C.Hazards.WaterWidth/2),.2,start-W.StageLength/2),Color3.fromRGB(44,148,172),Enum.Material.Glass,f);water.Transparency=.35 end end
 if i==10 then
  for n=1,14 do part("Grid",Vector3.new(W.Width,.03,.12),Vector3.new(0,.03,start-n*24),Color3.fromRGB(104,63,164),Enum.Material.Neon,f) end
  for n=-3,3 do part("Grid",Vector3.new(.12,.03,W.StageLength),Vector3.new(n*24,.03,start-W.StageLength/2),Color3.fromRGB(104,63,164),Enum.Material.Neon,f) end
 end
end
local baseplate=workspace:FindFirstChild("Baseplate");if baseplate then baseplate:Destroy() end
local spawn=workspace:FindFirstChild("SpawnLocation");if spawn then spawn.Position=Vector3.new(-129,1,W.PlotZ-22);spawn.Transparency=1;spawn.CanCollide=false end
local lighting=game:GetService("Lighting");lighting.ClockTime=14;lighting.Brightness=2;lighting.Ambient=Color3.fromRGB(120,130,145);lighting.OutdoorAmbient=Color3.fromRGB(140,150,165)
local atmosphere=lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere",lighting);atmosphere.Density=.18;atmosphere.Color=C.Stages[1].Fog
return {stages=#C.Stages,plots=#plots:GetChildren(),worldInstances=#world:GetDescendants(),missing=missing}
