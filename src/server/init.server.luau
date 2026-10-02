local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local Heartbeat=game:GetService("RunService")
local C=require(RS.Shared.Config)
local ctx={Runs={},Plots={}}
local net=Instance.new("Folder");net.Name="SalvageNet";net.Parent=RS
for _,name in {"Request","Snapshot","FX"} do local e=Instance.new("RemoteEvent");e.Name=name;e.Parent=net;ctx[name]=e end
for key,name in {Data="DataService",Vehicle="VehicleService",Run="RunService",Debug="DebugService",Cargo="CargoService",Banking="BankingService",Collection="CollectionService",Collectible="CollectibleService"} do ctx[key]=require(script[name]) end
for _,service in {ctx.Data,ctx.Vehicle,ctx.Run,ctx.Debug,ctx.Cargo,ctx.Collection,ctx.Banking,ctx.Collectible} do service.Init(ctx) end
ctx.Enemy=require(script.EnemyService);ctx.Enemy.Init(ctx)
local function joined(player)
 local plot=nil
 for _,p in workspace.SalvageWorld.Plots:GetChildren() do if p:GetAttribute("Owner")==0 then plot=p;p:SetAttribute("Owner",player.UserId);break end end
 if not plot then player:Kick("All four plots are occupied. Please join another server.");return end
 ctx.Plots[player]=plot;ctx.Runs[player]={State="BASE",Cargo={},Unbanked=0};player:SetAttribute("RunState","BASE")
 local function character(char)
  ctx.Vehicle.Character(char);local h=char:WaitForChild("Humanoid");char:WaitForChild("HumanoidRootPart");ctx.Run.Home(player)
  h.Died:Connect(function()ctx.Run.Fail(player,"Driver died")end)
 end
 player.CharacterAdded:Connect(character);if player.Character then task.spawn(character,player.Character) end
 local data=ctx.Data.Load(player);if not data then return end
 if ctx.Display then ctx.Display.Join(player) end
end
Players.PlayerAdded:Connect(joined)
for _,p in Players:GetPlayers() do task.spawn(joined,p) end
Players.PlayerRemoving:Connect(function(player)
 local run=ctx.Runs[player];if run then ctx.Vehicle.Despawn(player,run) end
 if ctx.Display then ctx.Display.Leave(player) end
 if ctx.Plots[player] then ctx.Plots[player]:SetAttribute("Owner",0) end
 ctx.Runs[player]=nil;ctx.Plots[player]=nil;ctx.Data.Release(player)
end)
local function request(player,action,args)
 local run=ctx.Runs[player];local data=ctx.Data.Profiles[player]
 if not run or not data or type(action)~="string" or type(args)~="table" then return end
 local now=os.clock();if not run.RemoteAt or now-run.RemoteAt>=C.Timing.RemoteWindow then run.RemoteAt=now;run.RemoteCount=0 end
 run.RemoteCount+=1;if run.RemoteCount>C.Timing.RemoteLimit then return end
 if action~="Boost" and action~="Hop" and action~="Ready" and now-(run.ActionAt or 0)<C.Timing.ActionCooldown then return end
 run.ActionAt=now
 local ok,reason=false,nil
 if action=="Start" then ok,reason=ctx.Run.Start(player,args.Vehicle)
 elseif action=="Boost" then ok=ctx.Vehicle.Boost(player,run,args.Held)
 elseif action=="Hop" then ok=ctx.Vehicle.Hop(player,run)
 elseif action=="Debug" then ok,reason=ctx.Debug.Execute(player,args.Command,args.Args)
 elseif action=="Ready" then ok=true
 elseif ctx.Economy and action=="Upgrade" then ok,reason=ctx.Economy.Upgrade(player,args.Track)
 elseif ctx.Economy and action=="TradeUp" then ok,reason=ctx.Economy.TradeUp(player)
 elseif ctx.Economy and action=="Pedestal" then ok,reason=ctx.Economy.BuyPedestal(player)
 elseif ctx.Collection and action=="Place" then ok,reason=ctx.Collection.Place(player,args.Index,args.Key)
 elseif ctx.Collection and action=="Remove" then ok,reason=ctx.Collection.Place(player,args.Index,nil)
 elseif action=="Settings" then
  if run.State~="BASE" and args.Key=="AutoScrap" then reason="Change auto-scrap in base"
  elseif data.Settings[args.Key]~=nil and type(args.Value)=="boolean" then data.Settings[args.Key]=args.Value;ok=true end
 end
 if not ok and reason then ctx.FX:FireClient(player,"Toast",{Text=reason}) end
end
ctx.Request.OnServerEvent:Connect(function(player,action,args)
 local ok,err=pcall(request,player,action,args);if not ok then warn("[SalvageRun] rejected request",tostring(err)) end
end)
local elapsed,snapshot=0,0
Heartbeat.Heartbeat:Connect(function(dt)
 elapsed+=dt;snapshot+=dt
 if elapsed>=C.Timing.ServerTick then
  local step=math.min(elapsed,C.Timing.RemoteWindow);elapsed=0;ctx.Run.Step(step)
  if ctx.Enemy then ctx.Enemy.Step(step) end
  if ctx.Collectible then ctx.Collectible.Step(step) end
  if ctx.Economy then ctx.Economy.Step(step) end
 end
 if snapshot>=C.Timing.Snapshot then
  snapshot=0
  for player,run in ctx.Runs do
   local data=ctx.Data.Profiles[player]
   if data then ctx.Snapshot:FireClient(player,{Data=data,State=run.State,Cargo=run.Cargo,Unbanked=run.Unbanked,HP=run.HP,Stats=run.Stats,Stage=run.Stage,Vehicle=run.Vehicle,InBay=require(script.StageService).InBay(player),Battery=run.Battery,Plot=ctx.Plots[player],Admin=ctx.Debug.IsOwner(player),Scratch=ctx.Data.Sessions[player].Scratch}) end
  end
 end
end)
print("[SalvageRun] server ready")
