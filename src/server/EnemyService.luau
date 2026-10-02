local C=require(game.ReplicatedStorage.Shared.Config)
local Stage=require(script.Parent.StageService)
local N={Mobs={},Projectiles={},Puddles={},Clock=0}
function N.Init(ctx)
 N.Ctx=ctx;N.Folder=Instance.new("Folder");N.Folder.Name="StageEnemies";N.Folder.Parent=workspace
 for stage,s in C.Stages do
  for i=1,C.Enemies.PerStage do
   local template=game.ReplicatedStorage.SalvageAssets:FindFirstChild("mob_"..stage)
   if not template then warn("[SalvageRun] missing enemy visual",stage);continue end
   local m=template:Clone();m.Name=s.Mob[1];local _,size=m:GetBoundingBox();m:ScaleTo(C.Enemies.VisualSize/math.max(size.X,size.Y,size.Z))
   local _,scaled=m:GetBoundingBox();local behavior=s.Behaviors[(i-1)%#s.Behaviors+1]
   local y=scaled.Y/2+(behavior=="Diver" and C.Enemies.HoverHeight or 0)
   local home=Stage.Position(stage,i%2==0 and C.Enemies.HomeLateral or -C.Enemies.HomeLateral,C.Enemies.HomeStart+(i-1)*C.Enemies.HomeSpacing,y)
   m:PivotTo(CFrame.new(home));m:SetAttribute("Stage",stage);m:SetAttribute("Behavior",behavior);m:SetAttribute("State","PATROL");m.Parent=N.Folder
   for _,p in m:GetDescendants() do if p:IsA("BasePart") then p.Anchored=true;p.CanCollide=false;p.CanTouch=false end end
   local glow=Instance.new("Highlight");glow.Name="AttackTelegraph";glow.FillColor=C.UI.Red;glow.OutlineColor=C.UI.Red;glow.FillTransparency=.2;glow.Enabled=false;glow.Parent=m
   table.insert(N.Mobs,{Model=m,Stage=stage,Behavior=behavior,Home=home,Position=home,State="PATROL",Glow=glow,NextAttack=0,Windup=nil,Index=i,DeadUntil=0})
  end
 end
 N.Hazards=Instance.new("Folder");N.Hazards.Name="StageHazards";N.Hazards.Parent=workspace
 for stage,s in C.Stages do
  for i=1,C.Hazards.Count do
   local p=Instance.new("Part");p.Name=s.Hazard;p.Size=Vector3.new(C.Hazards.Width,.1,C.Hazards.Length);p.Anchored=true;p.CanCollide=false;p.CanTouch=false
   p.Position=Stage.Position(stage,(i%2==0 and 1 or -1)*(C.World.Width/4),C.Enemies.HomeStart+i*C.Enemies.HomeSpacing,.07)
   p.Color=s.Hazard=="Lava" and Color3.fromRGB(235,107,45) or s.Hazard=="Acid" and Color3.fromRGB(174,220,69) or s.Hazard=="Laser" and C.UI.Red or s.Hazard=="Rift" and C.UI.Purple or s.Hazard=="Water" and Color3.fromRGB(45,156,187) or s.Hazard=="Shards" and Color3.fromRGB(137,102,180) or Color3.fromRGB(86,73,51)
   p.Material=s.Hazard=="Lava" and Enum.Material.CrackedLava or s.Hazard=="Mud" and Enum.Material.Mud or Enum.Material.SmoothPlastic
   -- Explicit precedence: materials must always be enum items.
   if s.Hazard=="Laser" or s.Hazard=="Acid" or s.Hazard=="Rift" then p.Material=Enum.Material.Neon end
   if s.Hazard=="Laser" then p.Size=Vector3.new(C.World.Width*.55,C.Physics.RoofHeight,.2);p.Position=Vector3.new(0,C.Physics.RoofHeight/2,p.Position.Z) end
   p:SetAttribute("Stage",stage);p:SetAttribute("Type",s.Hazard);p:SetAttribute("Phase",i);p.Parent=N.Hazards
  end
 end
end
function N.Damage(player,amount,reason)
 local ctx=N.Ctx;local run=ctx.Runs[player]
 if not run or run.State~="RUNNING" or not run.Vehicle or workspace:GetServerTimeNow()<run.Vehicle:GetAttribute("PhaseUntil") then return end
 if run.Id>=6 then amount*=C.Physics.ArmorFraction end
 run.HP=math.max(0,run.HP-amount);run.Vehicle:SetAttribute("HP",run.HP)
 ctx.FX:FireClient(player,"Hit",{Damage=amount})
 if run.HP<=0 then ctx.Run.Fail(player,reason) end
end
local function move(mob,destination,speed,dt)
 local delta=destination-mob.Position
 if delta.Magnitude>0 then mob.Position=Stage.Clamp(mob.Stage,mob.Position+delta.Unit*math.min(delta.Magnitude,speed*dt)) end
end
function N.Target(mob)
 local best,dist=nil,C.Enemies.Aggro
 for player,run in N.Ctx.Runs do
  if run.State~="RUNNING" or run.Stage~=mob.Stage or not run.Vehicle then continue end
  local noise=run.NoiseAt and os.clock()-run.NoiseAt<C.Enemies.NoiseDuration and (run.NoisePosition-mob.Position).Magnitude<=C.Pickup.NoiseRadius
  local range=noise and C.Pickup.NoiseRadius or C.Enemies.Aggro
  local d=(run.LastPosition-mob.Position).Magnitude
  if (d<=range or player==mob.Target and d<=C.Enemies.Aggro+C.World.StageMargin) and (not best or d<dist) then best=player;dist=d end
 end
 return best
end
function N.Projectile(mob,target)
 local start=mob.Position;local delta=(target-start);if delta.Magnitude==0 then return end
 local p=Instance.new("Part");p.Name="TelegraphedBolt";p.Shape=Enum.PartType.Ball;p.Size=Vector3.one*C.Enemies.ProjectileRadius;p.Material=Enum.Material.Neon;p.Color=C.UI.Red;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.Position=start;p.Parent=N.Folder
 table.insert(N.Projectiles,{Part=p,Velocity=delta.Unit*C.Enemies.ProjectileSpeed,Stage=mob.Stage,Until=N.Clock+C.Enemies.ProjectileLife})
end
function N.Puddle(mob)
 local p=Instance.new("Part");p.Name="EnemyPuddle";p.Shape=Enum.PartType.Cylinder;p.Size=Vector3.new(.1,C.Enemies.PuddleRadius*2,C.Enemies.PuddleRadius*2);p.CFrame=CFrame.new(mob.Position.X,.15,mob.Position.Z)*CFrame.Angles(0,0,math.pi/2);p.Material=Enum.Material.Neon;p.Color=C.Stages[mob.Stage].Fog;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.Transparency=.3;p.Parent=N.Hazards
 table.insert(N.Puddles,{Part=p,Stage=mob.Stage,Until=N.Clock+C.Enemies.PuddleLife,Hit={}})
end
function N.Step(dt)
 N.Clock+=dt;local ctx=N.Ctx
 for _,mob in N.Mobs do
  if mob.DeadUntil>N.Clock then continue end
  if not mob.Model.Parent then continue end
  local target=N.Target(mob);mob.Target=target
  local run=target and ctx.Runs[target]
  if not target then
   mob.Windup=nil;mob.Glow.Enabled=false
   if (mob.Position-mob.Home).Magnitude>C.Enemies.AttackRange then mob.State="RETURN";move(mob,mob.Home,C.Enemies.ReturnSpeed,dt)
   else mob.State="PATROL";local offset=Vector3.new(math.sin(N.Clock*.4+mob.Index),0,math.cos(N.Clock*.4+mob.Index))*C.Enemies.PatrolRadius;move(mob,Stage.Clamp(mob.Stage,mob.Home+offset),C.Enemies.ReturnSpeed*.4,dt) end
  else
   local distance=(run.LastPosition-mob.Position).Magnitude
   if run.Id>=8 and C.Enemies.SmallStages[mob.Stage] and distance<C.Enemies.CrushRadius and run.LastPosition.Y<C.Hazards.HopClearance then
    mob.DeadUntil=N.Clock+C.Pickup.CrateRespawn;mob.Model:PivotTo(CFrame.new(mob.Home+Vector3.new(0,-C.World.WallHeight,0)));ctx.FX:FireAllClients("Smash",{Position=mob.Position});mob.Position=mob.Home;continue
   end
   if mob.Windup then
    mob.State="ATTACK"
    if N.Clock>=mob.Windup then
     if mob.Behavior=="Sentry" then N.Projectile(mob,mob.Aim)
     elseif mob.Behavior=="Hazard-maker" then N.Puddle(mob)
     elseif mob.Behavior=="Diver" then move(mob,Vector3.new(mob.Aim.X,mob.Position.Y,mob.Aim.Z),C.Enemies.Speed*C.Enemies.DiveSpeed,dt);if (run.LastPosition-Vector3.new(mob.Position.X,run.LastPosition.Y,mob.Position.Z)).Magnitude<=C.Enemies.AttackRange then N.Damage(target,C.Stages[mob.Stage].Damage,"Diver") end
     elseif distance<=C.Enemies.AttackRange*C.Enemies.AttackReach and run.LastPosition.Y<C.Hazards.HopClearance then N.Damage(target,C.Stages[mob.Stage].Damage,mob.Behavior) end
     mob.Windup=nil;mob.Glow.Enabled=false;mob.NextAttack=N.Clock+C.Enemies.Cooldown
    end
   else
    mob.State="CHASE"
    local range=C.Enemies.AttackRange
    if mob.Behavior=="Sentry" or mob.Behavior=="Diver" then range=C.Enemies.Aggro end
    if distance<=range and N.Clock>=mob.NextAttack then mob.State="ATTACK";mob.Glow.Enabled=true;mob.Windup=N.Clock+C.Enemies.Windup;mob.Aim=run.LastPosition
    elseif mob.Behavior~="Sentry" then
     local speed=(C.Enemies.Speed+(mob.Stage-1)*C.Enemies.DeepSpeedGrowth)*(mob.Behavior=="Swarm" and C.Enemies.SwarmSpeed or 1)
     move(mob,Vector3.new(run.LastPosition.X,mob.Home.Y,run.LastPosition.Z),speed,dt)
    end
   end
  end
  local forward=run and Vector3.new(run.LastPosition.X,mob.Position.Y,run.LastPosition.Z) or mob.Home
  if (forward-mob.Position).Magnitude<.01 then forward=mob.Position+C.World.Forward end
  mob.Model:PivotTo(CFrame.lookAt(mob.Position,forward));mob.Model:SetAttribute("State",mob.State)
 end
 for i=#N.Projectiles,1,-1 do
  local shot=N.Projectiles[i];local pos=shot.Part.Position+shot.Velocity*dt;shot.Part.Position=pos;local hit=false
  for player,run in ctx.Runs do if run.State=="RUNNING" and run.Stage==shot.Stage and (run.LastPosition-pos).Magnitude<C.Enemies.ProjectileRadius+C.Enemies.AttackRange/2 then N.Damage(player,C.Stages[shot.Stage].Damage,"Projectile");hit=true;break end end
  if hit or N.Clock>=shot.Until or Stage.Stage(pos)~=shot.Stage then shot.Part:Destroy();table.remove(N.Projectiles,i) end
 end
 for i=#N.Puddles,1,-1 do
  local puddle=N.Puddles[i]
  for player,run in ctx.Runs do if run.State=="RUNNING" and run.Stage==puddle.Stage and run.Id<9 and run.LastPosition.Y<C.Hazards.HopClearance and (run.LastPosition-puddle.Part.Position).Magnitude<C.Enemies.PuddleRadius and N.Clock-(puddle.Hit[player] or -math.huge)>=C.Hazards.DamageInterval then puddle.Hit[player]=N.Clock;N.Damage(player,C.Stages[puddle.Stage].Damage*C.Hazards.DamageFraction,"Puddle") end end
  if N.Clock>=puddle.Until then puddle.Part:Destroy();table.remove(N.Puddles,i) end
 end
 N.HazardStep()
end
function N.HazardStep()
 for player,run in N.Ctx.Runs do
  if run.State~="RUNNING" or not run.Vehicle then continue end
  local slow,grip=1,1
  run.Vehicle:SetAttribute("RiftCenter",nil)
  for _,p in N.Hazards:GetChildren() do
   local stage=p:GetAttribute("Stage");if not stage then continue end
   local kind=p:GetAttribute("Type");local active=kind~="Laser" or (N.Clock+p:GetAttribute("Phase"))%C.Hazards.LaserPeriod<C.Hazards.LaserOn
   if kind=="Laser" then p.Transparency=active and .15 or .92 end
   if stage~=run.Stage or not active then continue end
   local offset=run.LastPosition-p.Position
   local inside=math.abs(offset.X)<=p.Size.X/2 and math.abs(offset.Z)<=p.Size.Z/2
   if kind=="Rift" and offset.Magnitude<C.Hazards.RiftRadius then run.Vehicle:SetAttribute("RiftCenter",p.Position) end
   if not inside or run.LastPosition.Y>C.Hazards.HopClearance and kind~="Laser" then continue end
   if kind=="Mud" then if run.Id<4 then slow=C.Hazards.SlowFraction end
   elseif kind=="Oil" then grip=C.Hazards.OilGrip;run.Vehicle:SetAttribute("Oil",true)
   elseif run.Id<9 or kind=="Laser" or kind=="Shards" or kind=="Water" or kind=="Rift" then
    if N.Clock-(run.HazardHit or -math.huge)>=C.Hazards.DamageInterval then run.HazardHit=N.Clock;N.Damage(player,C.Stages[stage].Damage*C.Hazards.DamageFraction,kind) end
   end
  end
  if run.Stage==4 and math.abs(run.LastPosition.X)>C.World.Width/2-C.Hazards.WaterWidth and N.Clock-(run.HazardHit or -math.huge)>=C.Hazards.DamageInterval then run.HazardHit=N.Clock;N.Damage(player,C.Stages[4].Damage,"Water edge") end
  if run.Vehicle then run.Vehicle:SetAttribute("Slow",slow);run.Vehicle:SetAttribute("Grip",grip);if grip==1 then run.Vehicle:SetAttribute("Oil",false) end end
 end
end
return N
