-- Narrow-floor repair: preserve supporting floor Y, XZ alignment, sizes and
-- collision. Lift only Bay/marks and SafeLine to 0.30-stud top separation.
local C=require(game.ReplicatedStorage.Shared.Config)
return function(verify)
 assert(game.PlaceId==120476079479285 and not game:GetService("RunService"):IsRunning(),"Target Edit only")
 local w=workspace.SalvageWorld
 local targets={{Part=w.VehicleBay,Y=.08+C.World.BaySurfaceLift},{Part=w.SafeLine,Y=.15+C.World.SafeSurfaceLift}}
 for _,p in w:GetChildren() do if p.Name=="BayMark" then table.insert(targets,{Part=p,Y=.18+C.World.BaySurfaceLift}) end end
 assert(#targets==9,"Bay, SafeLine, seven marks")
 for _,e in targets do e.Before=e.Part.CFrame end
 local ok,result=xpcall(function()
  for _,e in targets do local p=e.Part;p.Position=Vector3.new(p.Position.X,e.Y,p.Position.Z) end
  local r=verify();assert(r.Passed,"Post-repair gate failed");return r
 end,debug.traceback)
 if not ok then for _,e in targets do e.Part.CFrame=e.Before end return {Passed=false,RolledBack=true,Error=result} end
 return {Passed=true,Parts=9,BayTop=.30,SafeLineTop=.30,GroundTop=0,Inventory=result}
end
