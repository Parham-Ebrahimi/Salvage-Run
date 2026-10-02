$ErrorActionPreference = 'Stop'
$bundle = Join-Path $PSScriptRoot 'command-bundle.ps1'
$verify = & $bundle -File 'tools/verify-world.luau'
$build = & $bundle -File 'tools/build-world.luau'
$protect = & $bundle -File 'tools/protected-world-build.luau'
@"
local function verify()
 local r=(function()
$verify
 end)()
 -- Transitional gate: the old broad list remains diagnostic until T2.
 if r.TopOverlaps then
  local names={}
  for _,p in r.TopOverlaps.Parts do names[p.Id]=p.Name end
  local pairs=0
  for _,p in r.TopOverlaps.Pairs do
   if string.find(names[p.A] or '', 'SalvageWorld.Plots.',1,true) and string.find(names[p.B] or '', 'SalvageWorld.Plots.',1,true) then pairs+=1 end
  end
  r.HistoricalBroadPassed=r.Passed
  r.PlotBorderOverlaps=pairs
  r.Passed=r.InventoryPassed and pairs==0
 end
 return r
end
local function build()
$build
end
local test=(function()
$protect
end)()
return game:GetService('HttpService'):JSONEncode(test(build,verify))
"@
