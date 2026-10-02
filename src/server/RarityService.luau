local C=require(game.ReplicatedStorage.Shared.Config)
local R={Random=Random.new()}
function R.Mutation()
 local roll=R.Random:NextNumber();local cumulative=0
 for i=#C.Mutations,2,-1 do cumulative+=1/C.Mutations[i].Odds;if roll<cumulative then return i end end
 return 1
end
function R.Size()
 local roll=R.Random:NextNumber();local cumulative=0
 for i,size in C.Sizes do cumulative+=size.Probability;if roll<cumulative then return i end end
 return #C.Sizes
end
function R.Value(itemId,mutation,size)
 local item=C.ItemsById[itemId]
 return item.BaseValue*C.Stages[item.Stage].Multiplier*C.Mutations[mutation].Multiplier*C.Sizes[size or 1].Multiplier
end
function R.Odds(mutation,size)
 return (C.Mutations[mutation].Odds>0 and C.Mutations[mutation].Odds or 1)/C.Sizes[size].Probability
end
return R
