local C=require(game.ReplicatedStorage.Shared.Config)
local Stage=require(script.Parent.StageService)
local D={}
function D.IsOwner(player)
 return game.CreatorType==Enum.CreatorType.User and player.UserId==game.CreatorId
end
function D.Init(ctx)
 D.Ctx=ctx
 local bridge=Instance.new("BindableFunction");bridge.Name="SalvageDebug";bridge.Parent=game.ServerStorage
 bridge.OnInvoke=function(action,args)
  if not game:GetService("RunService"):IsStudio() then return {Error="Studio only"} end
  local player=game.Players:GetPlayers()[1];if not player then return {Error="No test player"} end
  return D.Execute(player,action,args,true)
 end
 if game:GetService("RunService"):IsStudio() then
  bridge:GetAttributeChangedSignal("Command"):Connect(function()
   local raw=bridge:GetAttribute("Command");local ok,result=pcall(function()
    local cmd=game:GetService("HttpService"):JSONDecode(raw)
    local player=game.Players:GetPlayers()[1]
    if not player then return {Error="No player"} end
    return D.Execute(player,cmd.Action,cmd.Args or {},true)
   end)
   bridge:SetAttribute("Result",game:GetService("HttpService"):JSONEncode({Success=ok,Result=result,Command=raw}))
  end)
 end
end
function D.Execute(player,action,args,studioTest)
 local ctx=D.Ctx;local data=ctx.Data.Profiles[player];local run=ctx.Runs[player]
 if not data or not run or (not studioTest and not D.IsOwner(player)) or type(args)~="table" then return false,"Owner only" end
 if action=="Cash" and type(args.Amount)=="number" and args.Amount==args.Amount then data.Cash=math.clamp(data.Cash+args.Amount,0,C.Economy.CashCap);return true
 elseif action=="Vehicle" and C.Vehicles[args.Id] and run.State=="BASE" then
  data.OwnedVehicles[tostring(args.Id)]=true;data.CurrentVehicle=args.Id;data.Upgrades[tostring(args.Id)]={Speed=0,HP=0,Cargo=0,Boost=0};return true
 elseif action=="Teleport" and C.Stages[args.Stage] then
  local pos=Stage.Position(args.Stage,0,C.World.CalmDistance+C.World.SpawnDistance,C.Physics.Clearance)
  if run.State=="RUNNING" then run.Vehicle:PivotTo(CFrame.lookAt(pos,pos+C.World.Forward));run.Vehicle.PrimaryPart.AssemblyLinearVelocity=Vector3.zero;run.LastPosition=pos;run.LastSample=os.clock();run.Deepest=math.max(run.Deepest,args.Stage)
  else player.Character:PivotTo(CFrame.new(pos)) end;return true
 elseif action=="DriveTestBegin" and studioTest and run.State=="BASE" then
  if D.DriveBackup then return false,"Test already active" end
  D.DriveBackup={Player=player,Current=data.CurrentVehicle,Owned=data.OwnedVehicles["10"],Upgrades=data.Upgrades["10"]}
  data.OwnedVehicles["10"]=true;data.CurrentVehicle=10;data.Upgrades["10"]={Speed=0,HP=0,Cargo=0,Boost=0}
  player.Character:PivotTo(CFrame.new(0,3,C.World.BayZ));return ctx.Run.Start(player,10)
 elseif action=="DriveTestEnd" and studioTest and D.DriveBackup and D.DriveBackup.Player==player then
  local b=D.DriveBackup;data.CurrentVehicle=b.Current;data.OwnedVehicles["10"]=b.Owned;data.Upgrades["10"]=b.Upgrades;D.DriveBackup=nil
  if run.State=="RUNNING" then ctx.Run.Fail(player,"Driving test complete") end
  return true
 elseif action=="WallFixture" and studioTest and run.State=="RUNNING" and (args.Angle==0 or args.Angle==30 or args.Angle==60) then
  local pos=Vector3.new(-72,C.Physics.Clearance,-1)
  local angle=math.rad(args.Angle);local dir=Vector3.new(math.cos(angle),0,-math.sin(angle))
  run.Vehicle:PivotTo(CFrame.lookAt(pos,pos+dir));run.Vehicle.PrimaryPart.AssemblyLinearVelocity=Vector3.zero
  run.LastPosition=pos;run.PreviousPosition=pos;run.LastSample=os.clock();run.Stage=1
  run.Vehicle:SetAttribute("ResetYaw",workspace:GetServerTimeNow());return true
 elseif action=="EntryFixture" and studioTest and run.State=="RUNNING" and C.Stages[args.Stage] then
  local pos=Stage.Position(args.Stage,10,-5,C.Physics.Clearance)
  run.Vehicle:PivotTo(CFrame.lookAt(pos,pos+C.World.Forward));run.Vehicle.PrimaryPart.AssemblyLinearVelocity=Vector3.zero
  run.LastPosition=pos;run.PreviousPosition=pos;run.LastSample=os.clock();run.Stage=math.max(0,args.Stage-1)
  run.Vehicle:SetAttribute("ResetYaw",workspace:GetServerTimeNow());return {Stage=args.Stage,StartDepth=Stage.Depth(pos)}
 elseif action=="Bay" and studioTest then player.Character:PivotTo(CFrame.new(0,3,C.World.BayZ));return true
 elseif action=="Start" and studioTest then return ctx.Run.Start(player,data.CurrentVehicle)
 elseif action=="Status" and studioTest then return {State=run.State,Cash=data.Cash,Cargo=#run.Cargo,Unbanked=run.Unbanked,HP=run.HP,Deepest=run.Deepest,Pos=run.Vehicle and tostring(run.Vehicle.PrimaryPart.Position),Stats=run.Stats,Scratch=ctx.Data.Sessions[player].Scratch,Data=data}
 elseif action=="ForceMutation" and ctx.Collectible and C.Mutations[args.Mutation] and C.ItemsById[args.Item] then
  local pos=run.Vehicle and run.Vehicle.PrimaryPart.Position+C.World.Forward*8 or Stage.Position(C.ItemsById[args.Item].Stage,0,30,0)
  ctx.Collectible.Spawn(C.ItemsById[args.Item].Stage,args.Item,args.Mutation,pos);return true
 elseif action=="Reset" and run.State=="BASE" then ctx.Data.Profiles[player]=ctx.Data.Default();if ctx.Display then ctx.Display.Refresh(player) end;return true
 elseif action=="PickupFixture" and studioTest and run.State=="RUNNING" then
  for id,record in ctx.Collectible.Records do if record.Stage==1 then record.Model:Destroy();ctx.Collectible.Records[id]=nil end end
  for _,item in C.Items do if item.Stage==1 then ctx.Collectible.Spawn(1,item.Id,1,run.LastPosition+C.World.Lateral*(table.find(C.Items,item)%3-1)*2,true) end end
  return true
 elseif action=="CashMath" and studioTest then
  local total=0;for _,entry in data.Collection do if entry.Mutation==1 then total+=require(script.Parent.RarityService).Value(entry.Item,entry.Mutation,entry.Size) end end
  return {Expected=total,Actual=data.Cash}
 elseif action=="RepositionHome" and studioTest and run.State=="RUNNING" then
  local pos=Stage.Position(1,0,C.World.SpawnDistance,C.Physics.Clearance);run.Vehicle:PivotTo(CFrame.lookAt(pos,pos+C.World.Forward));run.Vehicle.PrimaryPart.AssemblyLinearVelocity=Vector3.zero;run.LastPosition=pos;run.LastSample=os.clock();run.Vehicle:SetAttribute("ResetYaw",workspace:GetServerTimeNow());return true
 elseif action=="DangerFixture" and studioTest and run.State=="RUNNING" then
  local pos=Stage.Position(3,0,C.Enemies.HomeStart,C.Physics.Clearance)
  run.Vehicle:PivotTo(CFrame.lookAt(pos,pos+C.World.Forward));run.Vehicle.PrimaryPart.AssemblyLinearVelocity=Vector3.zero;run.LastPosition=pos;run.LastSample=os.clock();run.Vehicle:SetAttribute("ResetYaw",workspace:GetServerTimeNow());run.Deepest=3
  for _,mob in ctx.Enemy.Mobs do if mob.Stage==3 then mob.Position=pos+C.World.Lateral*10;mob.Home=mob.Position;break end end
  run.Unbanked=123;return {Started=os.clock(),Cargo=#run.Cargo,Unbanked=run.Unbanked}
 elseif action=="RarityMath" and studioTest then
  local rarity=require(script.Parent.RarityService);local values={}
  for mutation=1,#C.Mutations do table.insert(values,{Mutation=C.Mutations[mutation].Name,Value=rarity.Value("microwave",mutation,4),Odds=rarity.Odds(mutation,4)}) end
  return {GoldenColossal=rarity.Odds(3,4),GoldenValue=rarity.Value("microwave",3,4),Values=values}
 elseif action=="OwnershipFixture" and studioTest then
  local collection=ctx.Collection;local cash,results=0,{}
  for _,item in {"tire","television","microwave","toaster"} do local earned,result,key=collection.Award(data,item,2,1);cash+=earned;table.insert(results,{Key=key,Result=result})end
  data.Cash+=cash;return results
 elseif action=="DuplicateMath" and studioTest then
  local temp=ctx.Data.Default();local out={}
  for _,size in {1,1,2,1,4} do local cash,result=ctx.Collection.Award(temp,"microwave",3,size);table.insert(out,{Size=size,Cash=cash,Result=result})end
  return out
 elseif action=="IncomeCheck" and studioTest then
  return {Income=ctx.Collection.Income(data),Sign=ctx.Plots[player].Income.SurfaceGui.TextLabel.Text,Pedestals=data.Pedestals}
 elseif action=="OfflineFixture" and studioTest and run.State=="BASE" then
  local before=data.Cash;data.LastOnline=os.time()-C.Economy.OfflineCap*2
  ctx.Display.Leave(player);ctx.Display.Join(player)
  return {Expected=ctx.Collection.Income(data)*C.Economy.OfflineCap*C.Economy.OfflineRate,Actual=data.Cash-before}
 elseif action=="PlaceFixture" and studioTest then
  ctx.Run.Home(player);local i=0
  for key in data.Collection do i+=1;if i>4 then break end;ctx.Collection.Place(player,i,key)end
  return {Income=ctx.Collection.Income(data),Sign=ctx.Plots[player].Income.SurfaceGui.TextLabel.Text,Pedestals=data.Pedestals}
 elseif action=="UpgradeFixture" and studioTest then
  local before=C.Stats(data.CurrentVehicle,data.Upgrades[tostring(data.CurrentVehicle)]);data.Cash+=10000
  for _,track in C.Upgrades.Tracks do ctx.Economy.Upgrade(player,track)end
  return {Before=before,After=C.Stats(data.CurrentVehicle,data.Upgrades[tostring(data.CurrentVehicle)]),Levels=data.Upgrades[tostring(data.CurrentVehicle)]}
 elseif action=="TradeFixture" and studioTest and run.State=="BASE" then
  local id=data.CurrentVehicle;data.Cash+=100000
  for _,track in C.Upgrades.Tracks do while data.Upgrades[tostring(id)][track]<C.Upgrades.MaxLevel do local ok=ctx.Economy.Upgrade(player,track);if not ok then break end end end
  local ok,reason=ctx.Economy.TradeUp(player);return {Traded=ok,Reason=reason,Current=data.CurrentVehicle,Owned=data.OwnedVehicles,Collection=data.Collection,Pedestals=data.Pedestals}
 elseif action=="Save" and studioTest then return ctx.Data.Save(player,false)
 end
 return false,"Invalid debug command"
end
return D
