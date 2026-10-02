local C=require(game.ReplicatedStorage.Shared.Config)
local Rarity=require(script.Parent.RarityService)
local K={}
function K.Init(ctx)K.Ctx=ctx end
function K.Award(data,item,mutation,size)
 local key=item..":"..mutation;local existing=data.Collection[key]
 local value=Rarity.Value(item,mutation,size);local cash=0;local result="NEW"
 if existing then
  if size>existing.Size then cash=value-Rarity.Value(item,mutation,existing.Size);result="UPGRADED";existing.Size=size
  else cash=value;result="DUPLICATE" end
 else data.Collection[key]={Item=item,Mutation=mutation,Size=size};cash=mutation==1 and value or 0 end
 data.Index[item]=data.Index[item] or {};data.Index[item][tostring(mutation)]=true
 return cash,result,key,data.Collection[key]
end
function K.Place(player,index,key)
 local ctx=K.Ctx;local run=ctx.Runs[player];local data=ctx.Data.Profiles[player];local plot=ctx.Plots[player]
 if run.State~="BASE" or type(index)~="number" or index~=math.floor(index) or index<1 or index>data.PedestalCount then return false,"Choose one of your pedestals" end
 if key~=nil and (type(key)~="string" or not data.Collection[key]) then return false,"You do not own that find" end
 local pedestal=plot.Pedestals:FindFirstChild(tostring(index));local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
 if not root or (root.Position-pedestal.Position).Magnitude>C.World.PlotSize then return false,"Walk back to your plot" end
 if key then for slot,placed in data.Pedestals do if placed==key then data.Pedestals[slot]=nil end end end
 data.Pedestals[tostring(index)]=key
 if ctx.Display then ctx.Display.Refresh(player) end
 ctx.FX:FireClient(player,"Placed",{Index=index,Key=key});print("[SalvageRun] placement",player.UserId,index,key)
 return true
end
function K.Income(data)
 local total=0
 for _,key in data.Pedestals do local entry=data.Collection[key];if entry then total+=Rarity.Value(entry.Item,entry.Mutation,entry.Size)*C.Economy.PassiveRate end end
 return total
end
return K
