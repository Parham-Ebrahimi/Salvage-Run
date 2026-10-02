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
 elseif action=="Bay" and studioTest then player.Character:PivotTo(CFrame.new(0,3,C.World.BayZ));return true
 elseif action=="Start" and studioTest then return ctx.Run.Start(player,data.CurrentVehicle)
 elseif action=="Status" and studioTest then return {State=run.State,Cash=data.Cash,Cargo=#run.Cargo,Unbanked=run.Unbanked,HP=run.HP,Deepest=run.Deepest,Pos=run.Vehicle and tostring(run.Vehicle.PrimaryPart.Position),Stats=run.Stats,Scratch=ctx.Data.Sessions[player].Scratch,Data=data}
 elseif action=="ForceMutation" and ctx.Collectible and C.Mutations[args.Mutation] and C.ItemsById[args.Item] then
  local pos=run.Vehicle and run.Vehicle.PrimaryPart.Position+C.World.Forward*8 or Stage.Position(C.ItemsById[args.Item].Stage,0,30,0)
  ctx.Collectible.Spawn(C.ItemsById[args.Item].Stage,args.Item,args.Mutation,pos);return true
 elseif action=="Reset" and run.State=="BASE" then ctx.Data.Profiles[player]=ctx.Data.Default();if ctx.Display then ctx.Display.Refresh(player) end;return true
 end
 return false,"Invalid debug command"
end
return D
