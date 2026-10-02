$ErrorActionPreference='Stop'
$repoRoot=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$data=[IO.File]::ReadAllText((Join-Path $repoRoot 'src/server/DataService.luau')).Replace('require(game.ReplicatedStorage.Shared.Config)','e.Config')
$tests=[IO.File]::ReadAllText((Join-Path $PSScriptRoot 'test-data-service.luau'))
$generated=@"
local tests=(function()
$tests
end)()
local function factory(e)
 local game,os,task,warn=e.game,e.os,e.task,e.warn
$data
end
local result=tests(factory)
assert(result.Passed)
for _,name in result.Checks do print('PASS '..name) end
"@
$testPath=Join-Path $PSScriptRoot '.bin/data-tests-generated.luau'
[IO.File]::WriteAllText($testPath,$generated)
& (Join-Path $PSScriptRoot '.bin/luau.exe') $testPath
if ($LASTEXITCODE -ne 0) { throw 'DataService mocked tests failed' }
