-- Server Play: prepare one 0/30/60-degree angle, then actual W for4.5s.
-- Observe the MotionTest* attributes. End via DriveTestEnd BEFORE stopping Play.
return function(angle)
 assert(game:GetService("RunService"):IsStudio() and game:GetService("RunService"):IsRunning())
 local b=game.ServerStorage.SalvageDebug
 b:SetAttribute("Command",game:GetService("HttpService"):JSONEncode({Action="WallFixture",Args={Angle=angle},Nonce=os.clock()}))
 task.wait(.2)
 local v=assert(workspace.RunVehicles:GetChildren()[1]);local root=v.PrimaryPart
 v:SetAttribute("MotionTestAngle",angle);v:SetAttribute("MotionTestMaxX",-72);v:SetAttribute("MotionTestMaxY",root.Position.Y);v:SetAttribute("MotionTestMaxSpeed",0)
 task.spawn(function()
  local finish=os.clock()+6
  while os.clock()<finish and v.Parent do
   v:SetAttribute("MotionTestMaxX",math.max(v:GetAttribute("MotionTestMaxX"),root.Position.X))
   v:SetAttribute("MotionTestMaxY",math.max(v:GetAttribute("MotionTestMaxY"),root.Position.Y))
   v:SetAttribute("MotionTestMaxSpeed",math.max(v:GetAttribute("MotionTestMaxSpeed"),root.AssemblyLinearVelocity.Magnitude))
   task.wait(.05)
  end
 end)
 return {Prepared=true,Angle=angle}
end
