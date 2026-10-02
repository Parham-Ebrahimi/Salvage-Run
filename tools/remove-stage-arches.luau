-- Atomic O2 edit. Caller runs the old gate first and passes the updated verifier.
return function(verify)
 assert(game.PlaceId==120476079479285 and not game:GetService("RunService"):IsRunning(),"Target Edit only")
 local stages=workspace.SalvageWorld.Stages
 local entries={}
 local backups=game.ServerStorage:FindFirstChild("ArtBackups") or Instance.new("Folder",game.ServerStorage)
 backups.Name="ArtBackups"
 local archive=Instance.new("Folder");archive.Name="StageArchesBeforeO2";archive.Parent=backups
 for i=1,10 do
  local stage=assert(stages:FindFirstChild(tostring(i)))
  local arch=assert(stage:FindFirstChild("Arch"),"Expected original arch "..i)
  local copy=arch:Clone();copy.Name="Stage"..i;copy.Parent=archive
  table.insert(entries,{Arch=arch,Parent=stage})
 end
 local ok,result=xpcall(function()
  for _,e in entries do e.Arch.Parent=nil end
  local checked=verify();assert(checked.Passed,"Post-removal verification failed")
  return checked
 end,debug.traceback)
 if not ok then
  for _,e in entries do e.Arch.Parent=e.Parent end
  archive:Destroy()
  return {Passed=false,RolledBack=true,Error=result}
 end
 for _,e in entries do e.Arch:Destroy() end
 result.TopOverlaps=nil
 return {Passed=true,RemovedModels=10,RemovedParts=50,RemovedSurfaceGuis=10,Backup=archive:GetFullName(),Inventory=result}
end
