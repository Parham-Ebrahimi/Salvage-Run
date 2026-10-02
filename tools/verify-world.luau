-- Read-only Studio Edit verification. Execute this repo file with Studio MCP
-- immediately after every world mutation; do not start or stop a playtest.
assert(game:GetService("RunService"):IsStudio(), "Verify in Studio")
assert(not game:GetService("RunService"):IsRunning(), "Verify the saved Edit world, not temporary Play instances")
local errors={}
local function check(ok,message)if not ok then table.insert(errors,message)end end
local function child(parent,name,class)
 local obj=parent and parent:FindFirstChild(name)
 check(obj~=nil and (not class or obj:IsA(class)),(parent and parent:GetFullName() or "missing parent").."."..name.." missing/wrong type")
 return obj
end
local function count(parent)return parent and #parent:GetChildren() or 0 end
local function named(parent,name)
 local n=0;if parent then for _,p in parent:GetChildren()do if p.Name==name then n+=1 end end end;return n
end
check(workspace:FindFirstChild("Baseplate")==nil,"Workspace.Baseplate must be absent")
check(workspace.StreamingEnabled,"StreamingEnabled must be true")
local world=child(workspace,"SalvageWorld","Folder")
local base=child(world,"BaseGround","BasePart")
local bay=child(world,"VehicleBay","BasePart")
local safe=child(world,"SafeLine","BasePart")
if base then check(base.Anchored and base.CanCollide,"Base ground must be anchored/collidable");check(base.Size==Vector3.new(360,4,180),"Base ground size")end
if bay then check(math.abs(bay.Position.Z-28)<.01,"Vehicle Bay at Z=28");check(bay.Size.X==136 and bay.Size.Z==20,"Vehicle Bay footprint")end
if safe then check(safe.Size.X==160 and safe.Position.Z==0,"Safe Line covers the 160-stud entrance");check(not safe.CanCollide,"Safe Line must not obstruct inward banking")end
check(named(world,"BayMark")==7,"Seven Bay lane marks")
local plots=child(world,"Plots","Folder")
check(count(plots)==4,"Exactly four plots")
local pedestals=0
for i=1,4 do
 local plot=child(plots,tostring(i),"Model")
 child(plot,"Ground","BasePart");child(plot,"Home","BasePart")
 local sign=child(plot,"Income","BasePart")
 check(sign and sign:FindFirstChildWhichIsA("TextLabel",true)~=nil,"Plot "..i.." income sign label")
 check(named(plot,"Border")==4,"Plot "..i.." four borders")
 local peds=child(plot,"Pedestals","Folder")
 check(count(peds)==12,"Plot "..i.." has twelve provisioned pedestals")
 for j=1,12 do
  local p=child(peds,tostring(j),"BasePart")
  if p then pedestals+=1;check(p:GetAttribute("Index")==j and p:GetAttribute("Plot")==i,"Pedestal ownership/index metadata "..i..":"..j)
   check(p.Transparency==(j<=4 and 0 or 1),"Four initially visible pedestals for plot "..i)
   check(p.CanCollide==(j<=4),"Only initially available pedestals collide for plot "..i)
  end
 end
end
local stages=child(world,"Stages","Folder")
check(count(stages)==10,"Exactly ten stages")
local propCount=0
for i=1,10 do
 local stage=child(stages,tostring(i),"Folder")
 local ground=child(stage,"Ground","BasePart")
 if ground then check(ground.Anchored and ground.CanCollide,"Stage "..i.." anchored/collidable floor");check(ground.Size==Vector3.new(160,4,350),"Stage "..i.." floor size");check(ground.Position==Vector3.new(0,-2,-(i-.5)*350),"Stage "..i.." continuous floor position")end
 local arch=child(stage,"Arch","Model")
 check(named(arch,"Pillar")==2 and named(arch,"ArchLight")==2,"Stage "..i.." arch pillars/lights")
 local header=child(arch,"Header","BasePart")
 local text=header and header:FindFirstChildWhichIsA("TextLabel",true)
 check(text~=nil and text.Text:find(tostring(i),1,true)~=nil and text.Text:find("☠",1,true)~=nil,"Stage "..i.." numbered danger sign")
 local props=child(stage,"Props","Folder");check(count(props)==8,"Stage "..i.." eight props");propCount+=count(props)
 if props then for _,p in props:GetChildren()do check(p:IsA("Model") and p:FindFirstChildWhichIsA("BasePart",true)~=nil,"Stage "..i.." prop geometry: "..p.Name);check(p.Name:sub(1,8)~="MISSING ","Unresolved prop placeholder "..p.Name)end end
 if i==4 then check(named(stage,"WaterEdge")==2,"Stage 4 two water edges")end
 if i==10 then check(named(stage,"Grid")==21,"Stage 10 twenty-one neon grid strips")end
end
local walls=child(world,"Walls","Folder")
-- 26 walls in the whole map: 20 stage side walls, 2 base sides,
-- 2 entrance shoulders, 1 base back, 1 final end. Stage 10 has 3.
check(count(walls)==26,"Exactly 26 perimeter walls across the whole map")
check(named(walls,"StripWall")==20 and named(walls,"BaseWall")==2 and named(walls,"Shoulder")==2 and named(walls,"BackWall")==1 and named(walls,"EndWall")==1,"Perimeter wall categories")
local finalWalls=0
if walls then for _,p in walls:GetChildren()do
 check(p:IsA("BasePart") and p.CanCollide and p.Anchored,"Collidable anchored wall "..p.Name)
 if p:IsA("BasePart") then check(p.Size.Y==32,"32-stud wall height");if p.Position.Z<=-3150 then finalWalls+=1 end end
end end
check(finalWalls==3,"Stage 10 two side walls and final end wall")
local assets=child(game.ReplicatedStorage,"SalvageAssets","Folder")
check(count(assets)==113,"Exactly 113 audited templates")
local items,vehicles,mobs,props=0,0,0,0
if assets then for _,m in assets:GetChildren()do
 check(m:IsA("Model") and m:FindFirstChildWhichIsA("BasePart",true)~=nil,"Template geometry "..m.Name)
 for _,d in m:GetDescendants()do check(not d:IsA("LuaSourceContainer"),"Imported script left in "..m.Name)end
 if m.Name:sub(1,5)=="item_"then items+=1 elseif m.Name:sub(1,8)=="vehicle_"then vehicles+=1 elseif m.Name:sub(1,4)=="mob_"then mobs+=1 else props+=1 end
end end
check(items==60 and vehicles==10 and mobs==10 and props==33,"Template categories: 60 items, 10 vehicles, 10 mobs, 33 props")
for i=1,10 do child(assets,"vehicle_"..i,"Model");child(assets,"mob_"..i,"Model")end
check(game.Lighting:FindFirstChildOfClass("Atmosphere")~=nil,"Stage atmosphere exists")
local spawn=child(workspace,"SpawnLocation","SpawnLocation")
if spawn then check((spawn.Position-Vector3.new(-129,1,110)).Magnitude<.01,"Spawn on the first plot")end
local overlap=require(game.ReplicatedStorage.Shared.WorldOverlap).Scan(workspace)
assert(#errors==0,"WORLD INVENTORY FAILED:\n"..table.concat(errors,"\n"))
return {Passed=overlap.PairCount==0,InventoryPassed=true,TopOverlapCheckPassed=overlap.PairCount==0,TopOverlapCount=overlap.PairCount,TopOverlaps=overlap,PlaceId=game.PlaceId,Plots=count(plots),Pedestals=pedestals,Stages=count(stages),StageProps=propCount,Templates=count(assets),Items=items,Vehicles=vehicles,Mobs=mobs,PropTemplates=props,PerimeterWalls=count(walls),Stage10Walls=finalWalls,Baseplate=false,UIKits=game.ServerStorage:FindFirstChild("UIKits")~=nil}
