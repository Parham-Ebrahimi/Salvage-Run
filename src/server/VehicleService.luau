local Physics=game:GetService("PhysicsService")
local C=require(game.ReplicatedStorage.Shared.Config)
local Stage=require(script.Parent.StageService)
local V={}
function V.Init(ctx)
 V.Ctx=ctx
 for _,name in {"SalvageVehicles","SalvagePlayers"} do pcall(function()Physics:RegisterCollisionGroup(name)end) end
 Physics:CollisionGroupSetCollidable("SalvageVehicles","SalvageVehicles",false)
 Physics:CollisionGroupSetCollidable("SalvagePlayers","SalvageVehicles",false)
 Physics:CollisionGroupSetCollidable("SalvagePlayers","SalvagePlayers",false)
 local f=Instance.new("Folder");f.Name="RunVehicles";f.Parent=workspace;V.Folder=f
end
function V.Character(character)
 local function ghost(p)if p:IsA("BasePart") then p.CollisionGroup="SalvagePlayers" end end
 for _,p in character:GetDescendants() do ghost(p) end;character.DescendantAdded:Connect(ghost)
end
local function weld(root,p)
 p.Anchored=false;p.Massless=true;p.CanCollide=false;p.CanTouch=false;p.CollisionGroup="SalvageVehicles"
 local w=Instance.new("WeldConstraint");w.Part0=root;w.Part1=p;w.Parent=p
end
function V.Spawn(player,run,id,data)
 local stats=C.Stats(id,data.Upgrades[tostring(id)])
 local x=player.Character.HumanoidRootPart.Position:Dot(C.World.Lateral)
 local spawn=Stage.Position(1,x,C.World.SpawnDistance,C.Physics.Clearance)
 for attempt=0,C.World.PlotCount do
  local blocked=false
  for _,r in V.Ctx.Runs do if r.Vehicle and (r.Vehicle.PrimaryPart.Position-spawn).Magnitude<C.World.SpawnSpacing then blocked=true end end
  if not blocked then break end
  spawn=Stage.Position(1,math.clamp(x+(attempt%2==0 and 1 or -1)*math.ceil((attempt+1)/2)*C.World.SpawnSpacing,-C.World.Width/2+C.World.StageMargin,C.World.Width/2-C.World.StageMargin),C.World.SpawnDistance,C.Physics.Clearance)
  if attempt==C.World.PlotCount then return false,"Bay exit busy" end
 end
 local m=Instance.new("Model");m.Name="Vehicle_"..player.UserId;m:SetAttribute("Owner",player.UserId);m:SetAttribute("VehicleId",id)
 local root=Instance.new("Part");root.Name="Chassis";root.Size=C.Physics.ChassisSize;root.Transparency=1;root.CustomPhysicalProperties=PhysicalProperties.new(C.Physics.ChassisDensity,C.Physics.ChassisFriction,0,C.Physics.ChassisFrictionWeight,1);root.CollisionGroup="SalvageVehicles";root.CFrame=CFrame.lookAt(spawn,spawn+C.World.Forward);root.Parent=m;m.PrimaryPart=root
 local template=game.ReplicatedStorage.SalvageAssets:FindFirstChild(C.Vehicles[id].Asset)
 if template then
  local shell=template:Clone();shell.Name="Shell";shell.Parent=m
  local _,size=shell:GetBoundingBox();shell:ScaleTo(C.Physics.ShellMaxSize/math.max(size.X,size.Y,size.Z))
  shell:PivotTo(root.CFrame)
  for _,p in shell:GetDescendants() do if p:IsA("BasePart") then weld(root,p) end end
 else root.Transparency=0;root.Color=C.UI.Blue end
 local seat=Instance.new("VehicleSeat");seat.Name="DriverSeat";seat.Size=Vector3.new(2,1,2);seat.CFrame=root.CFrame*CFrame.new(0,1,0);seat.Transparency=1;seat.MaxSpeed=stats.Speed;seat.Torque=0;seat.TurnSpeed=0;seat.HeadsUpDisplay=false;seat.Parent=m;weld(root,seat)
 local a=Instance.new("Attachment");a.Parent=root
 local align=Instance.new("AlignOrientation");align.Name="Upright";align.Mode=Enum.OrientationAlignmentMode.OneAttachment;align.Attachment0=a;align.MaxTorque=C.Physics.UprightTorque;align.Responsiveness=C.Physics.UprightResponsiveness;align.CFrame=root.CFrame.Rotation;align.Parent=root
 for key,value in stats do m:SetAttribute(key,value) end
 m:SetAttribute("HP",stats.HP);m:SetAttribute("BoostUntil",0);m:SetAttribute("BoostReady",0);m:SetAttribute("PhaseUntil",0);m:SetAttribute("HopAt",0);m:SetAttribute("Slow",1);m:SetAttribute("Grip",1)
 m.Parent=V.Folder
 run.Vehicle=m;run.Seat=seat;run.Id=id;run.Stats=stats;run.HP=stats.HP;run.LastPosition=root.Position;run.LastSample=os.clock();run.Started=os.clock();run.Deepest=1;run.Invalid=0;run.Battery=C.Physics.BatteryCapacity
 local humanoid=player.Character:FindFirstChildOfClass("Humanoid");humanoid.JumpPower=0;humanoid.JumpHeight=0
 player.Character:PivotTo(seat.CFrame*CFrame.new(0,2,0));seat:Sit(humanoid);root:SetNetworkOwner(player)
 return true
end
function V.Despawn(player,run)
 if player.Character then local h=player.Character:FindFirstChildOfClass("Humanoid");if h then h.Sit=false;h.JumpPower=C.Physics.PlayerJumpPower;h.JumpHeight=C.Physics.PlayerJumpHeight end end
 if run.Vehicle then run.Vehicle:Destroy() end;run.Vehicle=nil;run.Seat=nil
end
function V.Boost(player,run,held)
 if run.State~="RUNNING" or not run.Vehicle then return false end
 local now=workspace:GetServerTimeNow();local m=run.Vehicle
 if run.Id>=3 then run.BoostHeld=held==true;return true end
 if now<m:GetAttribute("BoostReady") then return false end
 m:SetAttribute("BoostUntil",now+run.Stats.BoostDuration);m:SetAttribute("BoostReady",now+run.Stats.BoostCooldown)
 return true
end
function V.Hop(player,run)
 local now=workspace:GetServerTimeNow()
 if run.State~="RUNNING" or run.Id<2 or now-(run.HopLast or 0)<C.Physics.HopCooldown then return false end
 run.HopLast=now;run.Vehicle:SetAttribute("HopAt",now);return true
end
function V.Validate(player,run,dt)
 if not run.Vehicle or not run.Vehicle.Parent then return false,"Vehicle lost" end
 local root=run.Vehicle.PrimaryPart;local pos=root.Position
 local elapsed=math.min(os.clock()-run.LastSample,C.Timing.RemoteWindow)
 local max=run.Stats.Speed*C.Physics.BoostSpeed*C.Physics.SpeedTolerance
 local valid=pos.X==pos.X and pos.Y==pos.Y and pos.Z==pos.Z and (pos-run.LastPosition).Magnitude<=max*elapsed+C.Physics.PositionAllowance and root.AssemblyLinearVelocity.Magnitude<=max
 if not valid then
  run.Invalid+=1;root.AssemblyLinearVelocity=Vector3.zero;run.Vehicle:PivotTo(CFrame.lookAt(run.LastPosition,run.LastPosition+C.World.Forward));run.LastSample=os.clock()
  if run.Invalid>=C.Physics.InvalidSamples then return false,"Invalid movement" end
  return true,"REJECTED"
 end
 run.Invalid=0;run.PreviousPosition=run.LastPosition;run.LastPosition=pos;run.LastSample=os.clock()
 if pos.Y<C.Hazards.FallY or math.abs(pos.X)>C.World.Width/2+C.Physics.PositionAllowance then return false,"Out of bounds" end
 if os.clock()-run.Started>C.Physics.SeatGrace and (not run.Seat.Occupant or run.Seat.Occupant.Parent~=player.Character) then return false,"Driver left vehicle" end
 if root.CFrame.UpVector.Y<0 then
  run.FlippedSince=run.FlippedSince or os.clock()
  if os.clock()-run.FlippedSince>=C.Physics.FlipSeconds then
   run.Vehicle:PivotTo(CFrame.lookAt(pos+Vector3.new(0,C.Physics.Clearance,0),pos+C.World.Forward+Vector3.new(0,C.Physics.Clearance,0)));root.AssemblyAngularVelocity=Vector3.zero;run.FlippedSince=nil
  end
 else run.FlippedSince=nil end
 local now=workspace:GetServerTimeNow()
 if run.Id>=3 then
  if run.BoostHeld and run.Battery>0 then
   run.Battery=math.max(0,run.Battery-dt);run.Vehicle:SetAttribute("BoostUntil",now+dt*2)
   if run.Id>=10 and not run.WasBoosting then run.Vehicle:SetAttribute("PhaseUntil",now+C.Physics.PhaseDuration) end
  else run.Battery=math.min(C.Physics.BatteryCapacity,run.Battery+C.Physics.BatteryRefill*dt) end
  run.WasBoosting=run.BoostHeld and run.Battery>0
 end
 return true
end
return V
