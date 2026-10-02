-- Always restores the exact original world, even after a successful build test.
-- Pass repo build/verify functions from a generated command bundle.
return function(build, verify)
	assert(game:GetService("RunService"):IsStudio() and not game:GetService("RunService"):IsRunning(), "Edit only")
	assert(game.PlaceId==120476079479285, "Wrong place")
	assert(type(build)=="function" and type(verify)=="function", "Callbacks required")
	local original=assert(workspace:FindFirstChild("SalvageWorld"), "Missing world")
	assert(not workspace:FindFirstChild("Baseplate"), "Remove stale Baseplate before testing a build")
	local spawn=workspace:FindFirstChild("SpawnLocation")
	local spawnState=spawn and {CFrame=spawn.CFrame,Transparency=spawn.Transparency,CanCollide=spawn.CanCollide}
	local lighting=game:GetService("Lighting")
	local lightState={ClockTime=lighting.ClockTime,Brightness=lighting.Brightness,Ambient=lighting.Ambient,OutdoorAmbient=lighting.OutdoorAmbient}
	local atmosphere=lighting:FindFirstChildOfClass("Atmosphere")
	local airState=atmosphere and {Density=atmosphere.Density,Color=atmosphere.Color}
	local before=verify()
	assert(before.Passed, "Preflight structural/narrowed verification failed")
	original.Parent=nil
	local ok,result=xpcall(function()
		local built=build()
		assert(not built.missing or #built.missing==0, "Missing build templates")
		local checked=verify()
		assert(checked.Passed, "Built world structural/narrowed verification failed")
		checked.TopOverlaps=nil
		return {Build=built,Verify=checked}
	end,debug.traceback)
	local temporary=workspace:FindFirstChild("SalvageWorld")
	if temporary then temporary:Destroy() end
	original.Parent=workspace
	if spawnState then for k,v in spawnState do spawn[k]=v end end
	for k,v in lightState do lighting[k]=v end
	local currentAir=lighting:FindFirstChildOfClass("Atmosphere")
	if atmosphere then for k,v in airState do atmosphere[k]=v end
	elseif currentAir then currentAir:Destroy() end
	local restored=verify()
	assert(restored.Passed and workspace.SalvageWorld==original, "Original world restore verification failed")
	if not ok then return {Passed=false,Error=result,OriginalRestored=true} end
	result.Passed=true;result.OriginalRestored=true
	return result
end
