local F={}
function F.Number(n)
 if math.abs(n)>=1e9 then return string.format("%.1fB",n/1e9) elseif math.abs(n)>=1e6 then return string.format("%.1fM",n/1e6) elseif math.abs(n)>=1e3 then return string.format("%.1fK",n/1e3) end
 return tostring(math.floor(n+.5))
end
function F.Odds(n) return "1 in "..F.Number(n) end
function F.Rate(n)
 if math.abs(n)>=1000 then return F.Number(n) end
 return string.format("%.2f",n):gsub("0+$",""):gsub("%.$","")
end
function F.ExactOdds(n)
 local s=tostring(math.floor(n+.5)); local out=s:reverse():gsub("(%d%d%d)","%1,"):reverse():gsub("^,","")
 return "1 in "..out
end
return F
