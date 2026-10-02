local C=require(script.Parent.Config)
local G={}
function G.WallSpec(name,side,stage)
 local w=C.World
 local outward=(w.WallThickness-w.WallOriginalThickness)/2
 if name=="StripWall" then
  return Vector3.new(w.WallThickness,w.WallHeight,w.StageLength),Vector3.new(side*(w.Width/2+outward),w.WallHeight/2,-(stage-.5)*w.StageLength)
 elseif name=="BaseWall" then
  return Vector3.new(w.WallThickness,w.WallHeight,w.BaseDepth),Vector3.new(side*(w.BaseWidth/2+outward),w.WallHeight/2,w.BaseDepth/2)
 elseif name=="Shoulder" then
  return Vector3.new((w.BaseWidth-w.Width)/2,w.WallHeight,w.WallThickness),Vector3.new(side*(w.BaseWidth+w.Width)/4,w.WallHeight/2,-outward)
 elseif name=="BackWall" then
  return Vector3.new(w.BaseWidth,w.WallHeight,w.WallThickness),Vector3.new(0,w.WallHeight/2,w.BaseDepth+outward)
 elseif name=="EndWall" then
  return Vector3.new(w.Width,w.WallHeight,w.WallThickness),Vector3.new(0,w.WallHeight/2,-#C.Stages*w.StageLength-outward)
 end
 error("Unknown wall "..tostring(name))
end
function G.ForWall(p)
 local stage=math.clamp(math.floor(-p.Position.Z/C.World.StageLength)+1,1,#C.Stages)
 return G.WallSpec(p.Name,p.Position.X<0 and -1 or 1,stage)
end
return G
