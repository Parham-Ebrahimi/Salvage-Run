local C=require(game.ReplicatedStorage.Shared.Config)
local S={}
function S.Depth(pos) return (pos-Vector3.new(0,0,C.World.SafeLine)):Dot(C.World.Forward) end
function S.Stage(pos)
 local depth=S.Depth(pos)
 if depth<0 or depth>=#C.Stages*C.World.StageLength or math.abs(pos:Dot(C.World.Lateral))>C.World.Width/2 then return 0 end
 return math.floor(depth/C.World.StageLength)+1
end
function S.InBay(player)
 local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
 if not root then return false end
 return math.abs(root.Position:Dot(C.World.Lateral))<=C.World.Width*C.World.BayWidthFraction/2 and math.abs(root.Position.Z-C.World.BayZ)<=C.World.BayDepth/2 and root.Position.Y>=0 and root.Position.Y<C.World.WallHeight
end
function S.Position(stage,x,depth,y) return C.World.Lateral*x+C.World.Forward*((stage-1)*C.World.StageLength+depth)+Vector3.new(0,y or 0,0) end
function S.Clamp(stage,pos)
 local depth=math.clamp(S.Depth(pos),(stage-1)*C.World.StageLength+C.Enemies.Leash,stage*C.World.StageLength-C.Enemies.Leash)
 local x=math.clamp(pos:Dot(C.World.Lateral),-C.World.Width/2+C.World.StageMargin,C.World.Width/2-C.World.StageMargin)
 return C.World.Forward*depth+C.World.Lateral*x+Vector3.new(0,pos.Y,0)
end
return S
