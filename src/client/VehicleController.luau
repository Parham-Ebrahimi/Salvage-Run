local Players=game:GetService("Players")
local Run=game:GetService("RunService")
local Input=game:GetService("UserInputService")
local C=require(game.ReplicatedStorage.Shared.Config)
local V={Vehicle=nil,Speed=0,Yaw=0}
local request=game.ReplicatedStorage:WaitForChild("SalvageNet").Request
function V.Set(snapshot)
 local m=snapshot.State=="RUNNING" and snapshot.Vehicle or nil
 if m~=V.Vehicle then
  V.Vehicle=m;V.Speed=0;V.LastHop=0;V.Flipped=0;V.Cam=nil
  if m and m.PrimaryPart then local _,yaw=m.PrimaryPart.CFrame:ToOrientation();V.Yaw=yaw
  elseif os.clock()>(V.HoldUntil or 0) then local camera=workspace.CurrentCamera;camera.CameraType=Enum.CameraType.Custom;local char=Players.LocalPlayer.Character;if char then camera.CameraSubject=char:FindFirstChildOfClass("Humanoid") end end
 end
end
function V.Init()
 Input.InputBegan:Connect(function(input,processed)
  if processed or not V.Vehicle then return end
  if input.KeyCode==Enum.KeyCode.LeftShift then request:FireServer("Boost",{Held=true}) end
 end)
 Input.InputEnded:Connect(function(input)if input.KeyCode==Enum.KeyCode.LeftShift and V.Vehicle then request:FireServer("Boost",{Held=false}) end end)
 Input.JumpRequest:Connect(function()if V.Vehicle then request:FireServer("Hop",{}) end end)
 Run.PreSimulation:Connect(function(dt)
  local m=V.Vehicle;if not m or not m.Parent or not m.PrimaryPart then return end
  local root=m.PrimaryPart;local seat=m:FindFirstChild("DriverSeat");if not seat or not seat.Occupant then return end
  dt=math.min(dt,C.Timing.ServerTick)
  local now=workspace:GetServerTimeNow();local max=m:GetAttribute("Speed")*(now<m:GetAttribute("BoostUntil") and C.Physics.BoostSpeed or 1)*(m:GetAttribute("Slow") or 1)
  local reset=m:GetAttribute("ResetYaw") or 0
  if reset>(V.ResetAt or 0) then V.ResetAt=reset;local _,yaw=root.CFrame:ToOrientation();V.Yaw=yaw;V.Speed=0 end
  local throttle=seat.ThrottleFloat;local steer=seat.SteerFloat
  local target=throttle>=0 and throttle*max or throttle*max*C.Physics.ReverseFraction
  local brake=throttle*V.Speed<0 or throttle==0
  local accel=(brake and C.Physics.Braking or C.Physics.Acceleration)*dt
  V.Speed+=math.clamp(target-V.Speed,-accel,accel)
  local fraction=math.clamp(math.abs(V.Speed)/max,0,1)
  local turn=C.Physics.TurnRate*(1-fraction*(1-C.Physics.FastTurnFraction))
  -- Direct turning at low speeds, reversing follows the expected steering direction.
  V.Yaw-=steer*turn*dt*(V.Speed<-.5 and -1 or 1)
  local rotation=CFrame.Angles(0,V.Yaw,0)
  root.Upright.CFrame=rotation
  local desired=rotation.LookVector*V.Speed
  local current=root.AssemblyLinearVelocity;local horizontal=Vector3.new(current.X,0,current.Z)
  local grip=C.Physics.Grip*(m:GetAttribute("Grip") or 1)
  local velocity=horizontal:Lerp(desired,1-math.exp(-grip*dt))
  local y=current.Y
  local hop=m:GetAttribute("HopAt")
  if hop>V.LastHop then V.LastHop=hop;y=math.sqrt(2*workspace.Gravity*C.Physics.HopHeight) end
  root.AssemblyLinearVelocity=Vector3.new(velocity.X,y,velocity.Z)
  root.AssemblyAngularVelocity=Vector3.new(0,0,0)
  if root.CFrame.UpVector.Y<0 then
   V.Flipped+=dt
   if V.Flipped>=C.Physics.FlipSeconds then root.CFrame=CFrame.new(root.Position+Vector3.new(0,C.Physics.Clearance,0))*rotation;V.Flipped=0 end
  else V.Flipped=0 end
 end)
 Run:BindToRenderStep("SalvageFollow",Enum.RenderPriority.Camera.Value+1,function(dt)
  local m=V.Vehicle
  if not m or not m.Parent or not m.PrimaryPart then
   if V.HoldUntil and os.clock()>V.HoldUntil then V.HoldUntil=nil;workspace.CurrentCamera.CameraType=Enum.CameraType.Custom;local char=Players.LocalPlayer.Character;if char then workspace.CurrentCamera.CameraSubject=char:FindFirstChildOfClass("Humanoid") end end
   return
  end
  local root=m.PrimaryPart;local camera=workspace.CurrentCamera;camera.CameraType=Enum.CameraType.Scriptable;camera.FieldOfView=C.Physics.CameraFov
  local forward=CFrame.Angles(0,V.Yaw,0).LookVector
  local pos=root.Position-forward*C.Physics.CameraDistance+Vector3.new(0,C.Physics.CameraHeight,0)
  local look=root.Position+forward*C.Physics.CameraLookAhead
  local target=CFrame.lookAt(pos,look)
  V.Cam=V.Cam and V.Cam:Lerp(target,1-math.exp(-C.Physics.CameraSmoothing*dt)) or target
  camera.CFrame=V.Cam
 end)
end
return V
