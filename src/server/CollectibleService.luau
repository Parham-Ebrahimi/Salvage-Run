local Http=game:GetService("HttpService")
local C=require(game.ReplicatedStorage.Shared.Config)
local Visual=require(game.ReplicatedStorage.Shared.ItemVisual)
local Stage=require(script.Parent.StageService)
local Rarity=require(script.Parent.RarityService)
local L={Records={},Respawns={},Clock=0}
function L.Init(ctx)
 L.Ctx=ctx;L.Folder=Instance.new("Folder");L.Folder.Name="SalvageLoot";L.Folder.Parent=workspace
 L.Crates=Instance.new("Folder");L.Crates.Name="LootCrates";L.Crates.Parent=workspace
 for stage=1,#C.Stages do
  for _=1,C.Pickup.Density do L.Spawn(stage) end
  if stage>=3 then for index=1,C.Pickup.CratesPerStage do
   local p=Instance.new("Part");p.Name="Crate";p.Size=Vector3.new(5,5,5);p.Material=Enum.Material.WoodPlanks;p.Color=Color3.fromRGB(141,103,65);p.Anchored=true;p.Position=Stage.Position(stage,index%2==0 and 28 or -28,90+index*90,2.5);p.Parent=L.Crates;p:SetAttribute("Stage",stage);p:SetAttribute("Ready",0)
  end end
 end
end
function L.Choose(stage)
 local pool={};local total=0
 for _,item in C.Items do if item.Stage==stage then total+=item.SpawnWeight;table.insert(pool,item) end end
 local roll=Rarity.Random:NextNumber(0,total)
 for _,item in pool do roll-=item.SpawnWeight;if roll<=0 then return item.Id end end
 return pool[#pool].Id
end
function L.Spawn(stage,itemId,mutation,pos,bonus)
 itemId=itemId or L.Choose(stage);mutation=mutation or Rarity.Mutation()
 local model=Visual.Clone(itemId,mutation)
 if not model then warn("[SalvageRun] missing item template",itemId);return nil end
 pos=pos or Stage.Position(stage,Rarity.Random:NextNumber(-C.World.Width/2+C.World.StageMargin*2,C.World.Width/2-C.World.StageMargin*2),Rarity.Random:NextNumber(C.World.CalmDistance+10,C.World.StageLength-C.World.StageMargin),0)
 local _,size=model:GetBoundingBox();pos=Vector3.new(pos.X,size.Y/2+C.Pickup.ItemHeight,pos.Z)
 local id=Http:GenerateGUID(false);model.Name=id;model:SetAttribute("Item",itemId);model:SetAttribute("Mutation",mutation);model:SetAttribute("Stage",stage);model:SetAttribute("Progress",0)
 model:PivotTo(CFrame.new(pos));model.Parent=L.Folder
 for _,p in model:GetDescendants() do if p:IsA("BasePart") then p.Anchored=true;p.CanCollide=false;p.CanTouch=false end end
 local item=C.ItemsById[itemId]
 local record={Id=id,Item=itemId,Mutation=mutation,Stage=stage,Model=model,Position=pos,Duration=C.Pickup[item.WeightClass]+(mutation>1 and C.Pickup.MutationExtra or 0),Progress={},Bonus=bonus}
 L.Records[id]=record;return record
end
function L.Step(dt)
 L.Clock+=dt;local ctx=L.Ctx
 for id,record in L.Records do
  local progress=0;local claimed=false
  for player,run in ctx.Runs do
   local eligible=run.State=="RUNNING" and run.Vehicle and (run.LastPosition-record.Position).Magnitude<=run.Stats.Radius and ctx.Cargo.CanCollect(player,record)
   if eligible then record.Progress[player]=(record.Progress[player] or 0)+dt
   elseif record.Progress[player] then record.Progress[player]=math.max(0,record.Progress[player]-dt*math.max(record.Duration,dt)/C.Pickup.Drain) end
   local value=record.Progress[player] or 0
   progress=math.max(progress,record.Duration==0 and (eligible and 1 or 0) or value/record.Duration)
   if eligible and value>=record.Duration then
    local ok,scrap=ctx.Cargo.Add(player,record)
    if ok then
     claimed=true;L.Records[id]=nil;record.Model:Destroy()
     ctx.FX:FireAllClients("Pickup",{Item=record.Item,Mutation=record.Mutation,Position=record.Position,Vehicle=run.Vehicle,UserId=player.UserId,Slot=#run.Cargo,Scrap=scrap})
     run.NoiseAt=os.clock();run.NoisePosition=record.Position
     if not record.Bonus then table.insert(L.Respawns,{Stage=record.Stage,At=L.Clock+C.Pickup.Respawn}) end
     break
    end
   end
  end
  if not claimed then record.Model:SetAttribute("Progress",math.clamp(progress,0,1)) end
 end
 for i=#L.Respawns,1,-1 do if L.Respawns[i].At<=L.Clock then L.Spawn(L.Respawns[i].Stage);table.remove(L.Respawns,i) end end
 for _,crate in L.Crates:GetChildren() do
  if crate:GetAttribute("Ready")<=L.Clock and crate.Transparency==1 then crate.Transparency=0;crate.CanCollide=true end
  if crate.Transparency==1 then continue end
  for _,run in ctx.Runs do
   if run.State=="RUNNING" and run.Id>=7 and (run.LastPosition-crate.Position).Magnitude<=C.Pickup.CrateRadius then
    crate.Transparency=1;crate.CanCollide=false;crate:SetAttribute("Ready",L.Clock+C.Pickup.CrateRespawn)
    for n=1,C.Pickup.CrateItems do L.Spawn(crate:GetAttribute("Stage"),nil,nil,crate.Position+C.World.Lateral*(n-2)*4,true) end
    ctx.FX:FireAllClients("Smash",{Position=crate.Position});break
   end
  end
 end
end
return L
