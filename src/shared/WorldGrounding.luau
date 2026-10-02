-- Conservative world-space Part bounds, including rotated Parts and meshes.
local G={Tolerance=.3}
function G.Lowest(model)
 local low=math.huge
 for _,p in model:GetDescendants() do if p:IsA("BasePart") then
  for _,x in {-1,1} do for _,y in {-1,1} do for _,z in {-1,1} do
   low=math.min(low,p.CFrame:PointToWorldSpace(p.Size*Vector3.new(x,y,z)/2).Y)
  end end end
 end end
 assert(low<math.huge,"No prop bounds")
 return low
end
function G.Ground(model,floorY)
 local offset=floorY-G.Lowest(model)
 model:PivotTo(model:GetPivot()+Vector3.new(0,offset,0))
 return offset
end
function G.Check(world)
 local issues={};local checked=0
 for _,stage in world.Stages:GetChildren() do
  local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Include;params.FilterDescendantsInstances={stage.Ground}
  for _,model in stage.Props:GetChildren() do
   checked+=1
   local box=model:GetBoundingBox()
   local hit=workspace:Raycast(Vector3.new(box.Position.X,100,box.Position.Z),Vector3.new(0,-200,0),params)
   local low=G.Lowest(model);local gap=hit and low-hit.Position.Y
   if not gap or math.abs(gap)>G.Tolerance then table.insert(issues,{Model=model:GetFullName(),Lowest=low,Floor=hit and hit.Position.Y,Gap=gap,Reason=hit and "Bounds offset" or "No ground ray hit"}) end
  end
 end
 return {Checked=checked,WarningCount=#issues,Warnings=issues,Tolerance=G.Tolerance,Method="World-space oriented Part/mesh bounds and a floor-only downward ray"}
end
return G
