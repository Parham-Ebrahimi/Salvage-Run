-- Read-only: returns every matching Part and every qualifying pair.
local Overlap=require(game.ReplicatedStorage.Shared.WorldOverlap)
return Overlap.Scan(workspace)
