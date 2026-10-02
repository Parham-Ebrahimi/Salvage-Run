param(
    [Parameter(Mandatory=$true)][string]$File,
    [string]$Invoke = ''
)
$ErrorActionPreference = 'Stop'
$repoRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$entryPath = [IO.Path]::GetFullPath((Join-Path $repoRoot $File))
if (-not $entryPath.StartsWith($repoRoot + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) { throw 'Entry must be inside this repo' }
$script:bundleModules = [ordered]@{}
$script:bundleVisiting = @{}
function Expand-RepoRequires([string]$Source) {
    $pattern = 'require\((?:game\.ReplicatedStorage\.Shared\.|script\.Parent\.)([A-Za-z][A-Za-z0-9_]*)\)'
    return [regex]::Replace($Source, $pattern, [System.Text.RegularExpressions.MatchEvaluator]{
        param($match)
        $moduleName = $match.Groups[1].Value
        if (-not $script:bundleModules.Contains($moduleName)) {
            if ($script:bundleVisiting[$moduleName]) { throw "Cyclic command dependency: $moduleName" }
            $script:bundleVisiting[$moduleName] = $true
            $modulePath = Join-Path $repoRoot "src/shared/$moduleName.luau"
            if (-not (Test-Path -LiteralPath $modulePath)) { throw "Missing shared command dependency: $moduleName" }
            $expanded = Expand-RepoRequires ([IO.File]::ReadAllText($modulePath))
            $script:bundleModules[$moduleName] = $expanded
            $script:bundleVisiting.Remove($moduleName)
        }
        return ('__repoRequire("' + $moduleName + '")')
    })
}
$entrySource = Expand-RepoRequires ([IO.File]::ReadAllText($entryPath))
$chunks = [Collections.Generic.List[string]]::new()
$chunks.Add('-- Generated from repo files by tools/command-bundle.ps1; do not hand-edit literals.')
$chunks.Add('local __factories, __values = {}, {}')
$chunks.Add('local function __repoRequire(name) if __values[name] == nil then __values[name] = assert(__factories[name], "Missing repo module "..name)() end return __values[name] end')
foreach ($moduleName in $script:bundleModules.Keys) {
    $chunks.Add('__factories["' + $moduleName + '"] = function()' + "`n" + $script:bundleModules[$moduleName] + "`nend")
}
$chunks.Add("local __entry = (function()`n$entrySource`nend)()")
if ($Invoke) { $chunks.Add($Invoke) } else { $chunks.Add('return __entry') }
[string]::Join("`n", $chunks)
