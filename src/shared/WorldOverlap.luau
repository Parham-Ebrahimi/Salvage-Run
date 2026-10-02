-- Read-only potential top-surface overlap scan. Exact box footprint for level
-- block Parts; rotated, curved and mesh geometry uses conservative box bounds.
local O = { Tolerance = .05 }
local function cross(a, b, c)
	return (b.X-a.X)*(c.Z-a.Z)-(b.Z-a.Z)*(c.X-a.X)
end
local function hull(points)
	table.sort(points, function(a,b) return a.X == b.X and a.Z < b.Z or a.X < b.X end)
	local unique = {}
	for _, p in points do
		local last = unique[#unique]
		if not last or math.abs(last.X-p.X) > 1e-7 or math.abs(last.Z-p.Z) > 1e-7 then table.insert(unique,p) end
	end
	if #unique < 3 then return {} end
	local lower, upper = {}, {}
	for _, p in unique do
		while #lower >= 2 and cross(lower[#lower-1],lower[#lower],p) <= 1e-7 do table.remove(lower) end
		table.insert(lower,p)
	end
	for i=#unique,1,-1 do
		local p=unique[i]
		while #upper >= 2 and cross(upper[#upper-1],upper[#upper],p) <= 1e-7 do table.remove(upper) end
		table.insert(upper,p)
	end
	table.remove(lower);table.remove(upper)
	for _, p in upper do table.insert(lower,p) end
	return lower
end
local function intersects(a,b)
	if #a < 3 or #b < 3 then return false end
	for _, polygon in {a,b} do
		for i,p in polygon do
			local q=polygon[i % #polygon + 1]
			local nx,nz=-(q.Z-p.Z),q.X-p.X
			local length=math.sqrt(nx*nx+nz*nz);nx/=length;nz/=length
			local minA,maxA,minB,maxB=math.huge,-math.huge,math.huge,-math.huge
			for _,v in a do local dot=v.X*nx+v.Z*nz;minA=math.min(minA,dot);maxA=math.max(maxA,dot) end
			for _,v in b do local dot=v.X*nx+v.Z*nz;minB=math.min(minB,dot);maxB=math.max(maxB,dot) end
			if math.min(maxA,maxB)-math.max(minA,minB) <= 1e-5 then return false end
		end
	end
	return true
end
local function vector(v) return {v.X,v.Y,v.Z} end
function O.Scan(root,include)
	local entries={}
	for _,p in root:GetDescendants() do
		if p:IsA("BasePart") and not p:IsA("Terrain") and (not include or include(p)) then
			local points,top,minX,maxX,minZ,maxZ={},-math.huge,math.huge,-math.huge,math.huge,-math.huge
			for _,x in {-1,1} do for _,y in {-1,1} do for _,z in {-1,1} do
				local v=p.CFrame:PointToWorldSpace(p.Size*Vector3.new(x,y,z)/2)
				table.insert(points,{X=v.X,Z=v.Z});top=math.max(top,v.Y)
				minX=math.min(minX,v.X);maxX=math.max(maxX,v.X);minZ=math.min(minZ,v.Z);maxZ=math.max(maxZ,v.Z)
			end end end
			local exact=p:IsA("Part") and p.Shape==Enum.PartType.Block and math.abs(p.CFrame.UpVector.Y)>.99999 and not p:FindFirstChildWhichIsA("DataModelMesh")
			table.insert(entries,{Part=p,Path=p:GetFullName(),Top=top,Polygon=hull(points),MinX=minX,MaxX=maxX,MinZ=minZ,MaxZ=maxZ,Exact=exact})
		end
	end
	table.sort(entries,function(a,b)
		if a.Top~=b.Top then return a.Top<b.Top end
		if a.Path~=b.Path then return a.Path<b.Path end
		return tostring(a.Part.CFrame)<tostring(b.Part.CFrame)
	end)
	local pairs,matching={},{}
	for i,a in entries do
		for j=i+1,#entries do
			local b=entries[j];local delta=b.Top-a.Top
			if delta>O.Tolerance+1e-6 then break end
			if a.MaxX>b.MinX+1e-5 and b.MaxX>a.MinX+1e-5 and a.MaxZ>b.MinZ+1e-5 and b.MaxZ>a.MinZ+1e-5 and intersects(a.Polygon,b.Polygon) then
				matching[i]=true;matching[j]=true
				table.insert(pairs,{A=i,B=j,TopDifference=delta,BothVisible=a.Part.Transparency<1 and b.Part.Transparency<1,ExactBlockPair=a.Exact and b.Exact})
			end
		end
	end
	local parts={}
	for id,entry in entries do if matching[id] then
		local p=entry.Part
		table.insert(parts,{Id=id,Name=entry.Path,Class=p.ClassName,Position=vector(p.Position),Size=vector(p.Size),Orientation=vector(p.Orientation),Top=entry.Top,Material=tostring(p.Material),MaterialVariant=p.MaterialVariant,NewStudVariant=p.MaterialVariant=="SalvageStud",Visible=p.Transparency<1,ExactBlockFootprint=entry.Exact})
	end end
	return {Tolerance=O.Tolerance,ScannedParts=#entries,MatchingParts=#parts,PairCount=#pairs,Parts=parts,Pairs=pairs,Method="World box top + convex XZ footprint; edge-only contact excluded. Non-level/non-block shapes are conservative candidates."}
end
-- Narrowed T2 criterion. Thin named SafeLine is included explicitly even
-- though its Z face is <8; bay/base/plots and any other wide block are scanned.
function O.ScanFloors(root)
 local entries={}
 for _,p in root:GetDescendants() do
  if p:IsA("Part") and p.Shape==Enum.PartType.Block and p.Transparency<1 and math.abs(p.CFrame.UpVector.Y)>.99999 then
   local wide=p.Size.X>8 and p.Size.Z>8
   if wide or p.Name=="SafeLine" then
    local pts,top,bottom={},-math.huge,math.huge
    for _,x in {-1,1} do for _,y in {-1,1} do for _,z in {-1,1} do
     local v=p.CFrame:PointToWorldSpace(p.Size*Vector3.new(x,y,z)/2)
     table.insert(pts,{X=v.X,Z=v.Z});top=math.max(top,v.Y);bottom=math.min(bottom,v.Y)
    end end end
    table.insert(entries,{Part=p,Polygon=hull(pts),Top=top,Bottom=bottom})
   end
  end
 end
 local pairs={}
 for i,a in entries do for j=i+1,#entries do local b=entries[j]
  if intersects(a.Polygon,b.Polygon) then
   local gap=math.abs(a.Top-b.Top)
   local volume=math.min(a.Top,b.Top)-math.max(a.Bottom,b.Bottom)>1e-5
   if gap<.3-1e-6 or volume then
    table.insert(pairs,{A=a.Part:GetFullName(),B=b.Part:GetFullName(),TopDifference=gap,VolumesOverlap=volume,
     APosition=vector(a.Part.Position),ASize=vector(a.Part.Size),BPosition=vector(b.Part.Position),BSize=vector(b.Part.Size)})
   end
  end
 end end
 return {Passed=#pairs==0,PairCount=#pairs,ScannedParts=#entries,Pairs=pairs,TopGap=.3,Method="Visible level block slabs >8x8; SafeLine explicitly included; positive footprint area; close tops or intersecting volumes"}
end
return O
