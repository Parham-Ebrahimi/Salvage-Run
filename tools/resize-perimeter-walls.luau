local G=require(game.ReplicatedStorage.Shared.WorldGeometry)
local Style=require(game.ReplicatedStorage.Shared.VisualStyle)
return function(verify)
 assert(game.PlaceId==120476079479285 and not game:GetService("RunService"):IsRunning(),"Target Edit only")
 local walls=workspace.SalvageWorld.Walls:GetChildren();assert(#walls==26)
 local snapshots={}
 for _,p in walls do
  assert(p:IsA("Part") and p.Shape==Enum.PartType.Block and p.Anchored and p.CanCollide)
  assert(#p:GetChildren()==0,"Unexpected wall descendants")
  table.insert(snapshots,{Part=p,Size=p.Size,CFrame=p.CFrame,Material=p.Material,Variant=p.MaterialVariant,
   Physics=p.CustomPhysicalProperties,CurrentPhysics=p.CurrentPhysicalProperties,Color=p.Color})
 end
 local ok,result=xpcall(function()
  for _,s in snapshots do
   local size,pos=G.ForWall(s.Part);s.Part.Size=size;s.Part.Position=pos
   Style.Apply(s.Part,"Stud");s.Part.CustomPhysicalProperties=s.CurrentPhysics
   assert(s.Part.Color==s.Color and s.Part.CanCollide and s.Part.Anchored)
   assert(math.abs(s.Part.Position.Y-s.Part.Size.Y/2)<.001,"Wall base moved")
  end
  local r=verify();assert(r.Passed,"Wall verification failed");return r
 end,debug.traceback)
 if not ok then
  for _,s in snapshots do local p=s.Part;p.Size=s.Size;p.CFrame=s.CFrame;p.Material=s.Material;p.MaterialVariant=s.Variant;p.CustomPhysicalProperties=s.Physics end
  return {Passed=false,RolledBack=true,Error=result}
 end
 return {Passed=true,Walls=26,Before={Height=32,Thickness=4,CenterY=16,BaseY=0},After={Height=48,Thickness=5,CenterY=24,BaseY=0,OutwardShift=.5},Inventory=result}
end
