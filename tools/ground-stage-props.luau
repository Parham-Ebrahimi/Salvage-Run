local G=require(game.ReplicatedStorage.Shared.WorldGrounding)
return function(stageNumber,verify)
 assert(game.PlaceId==120476079479285 and not game:GetService("RunService"):IsRunning(),"Target Edit only")
 assert(verify().Passed,"Preflight failed")
 local stage=assert(workspace.SalvageWorld.Stages:FindFirstChild(tostring(stageNumber)))
 local entries={}
 for _,m in stage.Props:GetChildren() do table.insert(entries,{Model=m,Pivot=m:GetPivot()}) end
 assert(#entries==8)
 local changes={}
 local ok,result=xpcall(function()
  for _,e in entries do
   local offset=G.Ground(e.Model,stage.Ground.Position.Y+stage.Ground.Size.Y/2)
   if math.abs(offset)>.00001 then table.insert(changes,{Model=e.Model.Name,DeltaY=offset}) end
   assert(math.abs(G.Lowest(e.Model))<.0001,"Grounding mismatch")
  end
  local checked=verify();assert(checked.Passed,"Post-grounding gate failed");return checked
 end,debug.traceback)
 if not ok then for _,e in entries do e.Model:PivotTo(e.Pivot) end return {Passed=false,RolledBack=true,Error=result} end
 return {Passed=true,Stage=stageNumber,Changes=changes,Inventory=result}
end
