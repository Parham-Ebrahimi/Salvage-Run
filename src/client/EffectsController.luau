local Run=game:GetService("RunService")
local Players=game:GetService("Players")
local Tween=game:GetService("TweenService")
local C=require(game.ReplicatedStorage.Shared.Config)
local Visual=require(game.ReplicatedStorage.Shared.ItemVisual)
local U=require(script.Parent.UIKit)
local E={Rings={},Progress={},Animations={}}
local function burst(position,color)
 local p=U.New("Part",{Anchored=true,CanCollide=false,CanTouch=false,Transparency=1,Size=Vector3.one,Position=position},workspace)
 local emitter=U.New("ParticleEmitter",{Texture="rbxasset://textures/particles/sparkles_main.dds",Color=ColorSequence.new(color),LightEmission=1,Rate=0,Lifetime=NumberRange.new(.3,.6),Speed=NumberRange.new(5,9),SpreadAngle=Vector2.new(180,180)},p)
 emitter:Emit(16);game:GetService("Debris"):AddItem(p,1)
end
function E.Init(hud,vehicle)
 E.HUD=hud;E.Controller=vehicle
 local lighting=game:GetService("Lighting")
 E.Tint=U.New("ColorCorrectionEffect",{Name="StageTint",TintColor=Color3.new(1,1,1)},lighting)
 E.Warning=U.New("Frame",{Name="DangerPulse",BackgroundTransparency=1,Size=UDim2.fromScale(1,1),ZIndex=10,Visible=false},hud.Root)
 for _,pos in {UDim2.fromScale(0,0),UDim2.fromScale(.97,0)} do U.New("Frame",{Size=UDim2.fromScale(.03,1),Position=pos,BackgroundColor3=C.UI.Red,BackgroundTransparency=.5,BorderSizePixel=0},E.Warning) end
 E.Music=U.New("Sound",{Name="StageMusic",Volume=C.Sounds.Volume*.4,Looped=true},game:GetService("SoundService"))
 Run.RenderStepped:Connect(function(dt)E.Step(dt)end)
end
function E.Event(kind,p)
 local H=E.HUD
 if kind=="Pickup" then
  local m=Visual.Clone(p.Item,p.Mutation)
  if m then m.Parent=workspace;m:PivotTo(CFrame.new(p.Position));table.insert(E.Animations,{Model=m,Position=p.Position,Vehicle=p.Vehicle,At=os.clock(),Pickup=p}) end
 elseif kind=="Secured" then H.Toast("HAUL SECURED!",C.UI.Green);U.Sound("Bank")
 elseif kind=="NewIndex" then H.Toast("NEW FIND · "..C.ItemsById[p.Item].DisplayName,C.UI.Gold)
 elseif kind=="Announcement" then H.Toast(p.Player.." found "..C.Mutations[p.Mutation].Name.." "..C.ItemsById[p.Item].DisplayName.." · "..require(game.ReplicatedStorage.Shared.Format).ExactOdds(p.Odds),C.UI.Purple);U.Sound("Bank")
 elseif kind=="Death" then
  burst(p.Position,C.UI.Red)
  if p.UserId==Players.LocalPlayer.UserId then
   H.Toast("HAUL LOST",C.UI.Red);U.Sound("Fail");E.Controller.HoldUntil=os.clock()+C.Timing.FailureHold
  end
 elseif kind=="Placed" then U.Sound("Thump");H.Toast(p.Key and "FIND PLACED!" or "PEDESTAL CLEARED",C.UI.Green)
 elseif kind=="Smash" then burst(p.Position,C.UI.Gold);U.Sound("Thump")
 elseif kind=="TradeUp" then burst(Players.LocalPlayer.Character:GetPivot().Position,C.UI.Gold);H.Toast("UNLOCKED · "..C.Vehicles[p.Vehicle].Name,C.UI.Gold);U.Sound("Bank")
 end
end
function E.Step(dt)
 local H=E.HUD;local s=H.Snapshot
 local ownedVehicle=s and s.State=="RUNNING" and s.Vehicle
 if ownedVehicle and ownedVehicle.PrimaryPart then
  if E.RingVehicle~=ownedVehicle then
   for _,p in E.Rings do p:Destroy() end;E.Rings={};E.RingVehicle=ownedVehicle
   for i=1,32 do table.insert(E.Rings,U.New("Part",{Size=Vector3.new(.14,.06,1),Anchored=true,CanCollide=false,CanTouch=false,Material=Enum.Material.Neon,Color=C.UI.Blue,Transparency=.5},workspace)) end
  end
  local center=ownedVehicle.PrimaryPart.Position;local radius=ownedVehicle:GetAttribute("Radius")
  for i,p in E.Rings do local angle=i/#E.Rings*math.pi*2;local pos=Vector3.new(center.X+math.cos(angle)*radius,.09,center.Z+math.sin(angle)*radius);p.Size=Vector3.new(.12,.04,radius*math.pi*2/#E.Rings);p.CFrame=CFrame.lookAt(pos,pos+Vector3.new(-math.sin(angle),0,math.cos(angle))) end
  local ratio=(s.HP or 0)/s.Stats.HP
  E.Warning.Visible=ratio<=C.UI.WarningHP
  if E.Warning.Visible then
   for _,p in E.Warning:GetChildren() do p.BackgroundTransparency=.45+.25*math.sin(os.clock()*7) end
   if os.clock()-(E.SirenAt or 0)>C.UI.Toast then E.SirenAt=os.clock();U.Sound("Siren") end
  end
  local chassis=ownedVehicle.PrimaryPart
  local smoke=chassis:FindFirstChild("DamageSmoke")
  if not smoke then smoke=U.New("Smoke",{Name="DamageSmoke",Color=C.UI.Dark,Size=3,Opacity=.3,Enabled=false},chassis) end
  smoke.Enabled=ratio<=C.UI.SmokeHP
 else
  for _,p in E.Rings do p:Destroy() end;E.Rings={};E.RingVehicle=nil;E.Warning.Visible=false
 end
 local stage=s and s.State=="RUNNING" and s.Stage or 1
 if stage and stage~=E.Stage then
  E.Stage=stage
  local cfg=C.Stages[stage];Tween:Create(E.Tint,TweenInfo.new(C.UI.Open),{TintColor=Color3.new(1,1,1):Lerp(cfg.Fog,.2)}):Play()
  game:GetService("Lighting").FogColor=cfg.Fog;game:GetService("Lighting").FogEnd=C.UI.StageFog
  local a=game:GetService("Lighting"):FindFirstChildOfClass("Atmosphere");if a then a.Color=cfg.Fog;a.Density=C.UI.StageAtmosphere end
  if C.Sounds.Music then E.Music.SoundId=C.Sounds.Music;E.Music.PlaybackSpeed=1+(stage-1)*.025;if s.Data.Settings.Music then E.Music:Play()end end
 end
 if s and not s.Data.Settings.Music then E.Music:Pause() elseif s and C.Sounds.Music and not E.Music.IsPlaying then E.Music:Resume() end
 local loot=workspace:FindFirstChild("SalvageLoot")
 if loot then
  for _,m in loot:GetChildren() do
   local progress=m:GetAttribute("Progress") or 0
   local gui=E.Progress[m]
   if progress>0 and m.PrimaryPart then
    if not gui then
     gui=U.New("BillboardGui",{Size=UDim2.fromOffset(44,44),StudsOffset=Vector3.new(0,3,0),AlwaysOnTop=true,Adornee=m.PrimaryPart},H.Gui);E.Progress[m]=gui
     local ring=U.New("Frame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1},gui);U.Round(ring,100);U.Stroke(ring,C.UI.Blue,4)
     U.Label(ring,"0%",UDim2.fromScale(.9,.5),UDim2.fromScale(.05,.25))
    end
    gui.Frame.TextLabel.Text=tostring(math.floor(progress*100)).."%"
    gui.Frame.UIStroke.Color=C.UI.Blue:Lerp(C.UI.Green,progress)
   elseif gui then gui:Destroy();E.Progress[m]=nil end
   if m:GetAttribute("Mutation")==7 then
    local glow=m:FindFirstChild("MutationGlow");if glow then glow.FillColor=Color3.fromHSV((os.clock()*2)%1,1,1) end
   end
  end
 end
 for m,gui in E.Progress do if not m.Parent then gui:Destroy();E.Progress[m]=nil end end
 for i=#E.Animations,1,-1 do
  local a=E.Animations[i];local t=math.clamp((os.clock()-a.At)/C.Pickup.Animation,0,1)
  local destination=a.Vehicle and a.Vehicle.Parent and a.Vehicle.PrimaryPart.Position or a.Position
  local pos=a.Position:Lerp(destination,t)+Vector3.new(0,math.sin(t*math.pi)*6,0)
  a.Model:PivotTo(CFrame.new(pos)*CFrame.Angles(0,t*math.pi*3,0));a.Model:ScaleTo(math.max(.02,1-t))
  if t>=1 then
   a.Model:Destroy();table.remove(E.Animations,i);burst(destination,C.Mutations[a.Pickup.Mutation].Color)
   if a.Pickup.UserId==Players.LocalPlayer.UserId then
    U.Sound("Pickup");local screen=workspace.CurrentCamera:WorldToViewportPoint(destination)
    local icon=U.Item(H.Root,a.Pickup.Item,a.Pickup.Mutation,UDim2.fromOffset(44,44),UDim2.fromOffset(screen.X,screen.Y));icon.ZIndex=15
    Tween:Create(icon,TweenInfo.new(C.UI.Open,Enum.EasingStyle.Quad),{Position=UDim2.fromScale(.5,.90),Size=UDim2.fromOffset(18,18)}):Play();task.delay(C.UI.Open,function()icon:Destroy()end)
   end
  end
 end
 local displays=workspace:FindFirstChild("SalvageWorld")
 if displays then
  local root=Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
  for _,plot in displays.Plots:GetChildren() do
   for _,pedestal in plot.Pedestals:GetChildren() do
    local m=pedestal:FindFirstChild("Display");if m then
     local angle=os.clock()*C.UI.RotateSpeed;local pos=m:GetAttribute("DisplayPosition")
     if pos then m:PivotTo(CFrame.new(pos)*CFrame.Angles(0,angle,0)) end
     local gui=m:FindFirstChild("Nameplate",true);if gui then gui.Enabled=root and (root.Position-pedestal.Position).Magnitude<=C.World.ApproachDistance or false end
    end
   end
  end
 end
end
return E
