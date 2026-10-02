local C=require(game.ReplicatedStorage.Shared.Config)
local Stage=require(script.Parent.StageService)
local R={}
local allowed={BASE={SPAWNING=true},SPAWNING={RUNNING=true,BASE=true},RUNNING={BANKING=true,FAILED=true},BANKING={BASE=true},FAILED={BASE=true}}
function R.Init(ctx)R.Ctx=ctx end
function R.State(player,state)
 local run=R.Ctx.Runs[player]
 if not run or not allowed[run.State][state] then return false end
 run.State=state;player:SetAttribute("RunState",state);return true
end
function R.Start(player,id)
 local ctx=R.Ctx;local run=ctx.Runs[player];local data=ctx.Data.Profiles[player]
 if not run or not data or run.State~="BASE" or not Stage.InBay(player) or type(id)~="number" or id~=math.floor(id) or not C.Vehicles[id] or not data.OwnedVehicles[tostring(id)] then return false,"Stand in the Vehicle Bay to START" end
 R.State(player,"SPAWNING");run.Cargo={};run.Unbanked=0;data.CurrentVehicle=id
 local ok,spawned,err=pcall(ctx.Vehicle.Spawn,player,run,id,data)
 if not ok or not spawned then ctx.Vehicle.Despawn(player,run);R.State(player,"BASE");return false,err or tostring(spawned) end
 R.State(player,"RUNNING");print("[SalvageRun] run started",player.UserId,id);return true
end
function R.Home(player)
 local plot=R.Ctx.Plots[player]
 if plot and player.Character then player.Character:PivotTo(plot.Home.CFrame*CFrame.new(0,3,0)) end
end
function R.Fail(player,reason)
 local ctx=R.Ctx;local run=ctx.Runs[player]
 if not run or run.State~="RUNNING" then return end
 R.State(player,"FAILED");run.Cargo={};run.Unbanked=0;run.BoostHeld=false
 local pos=run.Vehicle and run.Vehicle.PrimaryPart.Position or Vector3.zero
 ctx.FX:FireAllClients("Death",{Position=pos,UserId=player.UserId})
 if run.Vehicle then run.Vehicle.PrimaryPart.AssemblyLinearVelocity=Vector3.zero;run.Vehicle.PrimaryPart.Anchored=true end
 print("[SalvageRun] run failed",player.UserId,reason,os.clock()-run.Started,run.Deepest)
 task.delay(C.Timing.FailureHold,function()
  if ctx.Runs[player]~=run then return end
  ctx.Vehicle.Despawn(player,run)
  if player.Parent then player:LoadCharacterAsync();R.Home(player);R.State(player,"BASE") end
 end)
end
function R.Step(dt)
 local ctx=R.Ctx
 for player,run in ctx.Runs do
  if run.State~="RUNNING" then continue end
  local valid,reason=ctx.Vehicle.Validate(player,run,dt)
  if not valid then R.Fail(player,reason);continue end
  if reason=="REJECTED" then continue end
  local stage=Stage.Stage(run.LastPosition)
  if stage>0 then
   run.Deepest=math.max(run.Deepest,stage)
   if run.Stage~=stage then run.Stage=stage;ctx.FX:FireClient(player,"Stage",{Stage=stage}) end
  end
  if run.PreviousPosition and Stage.Depth(run.PreviousPosition)>0 and Stage.Depth(run.LastPosition)<=0 then
   if ctx.Banking then ctx.Banking.Bank(player) end
  end
 end
end
return R
