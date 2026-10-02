local C=require(game.ReplicatedStorage.Shared.Config)
local Rarity=require(script.Parent.RarityService)
local A={}
function A.Init(ctx)A.Ctx=ctx end
function A.CanCollect(player,record)
 local run=A.Ctx.Runs[player]
 return run and run.State=="RUNNING" and #run.Cargo<run.Stats.Slots
end
function A.Add(player,record)
 if not A.CanCollect(player,record) then return false end
 local run=A.Ctx.Runs[player];local data=A.Ctx.Data.Profiles[player]
 local scrap=data.Settings.AutoScrap and record.Mutation==1 and data.Index[record.Item]~=nil
 if scrap then run.Unbanked+=Rarity.Value(record.Item,record.Mutation,1)
 else table.insert(run.Cargo,{Item=record.Item,Mutation=record.Mutation}) end
 if #run.Cargo==run.Stats.Slots then print("[SalvageRun] cargo full",player.UserId) end
 return true,scrap
end
function A.Clear(player)local run=A.Ctx.Runs[player];run.Cargo={};run.Unbanked=0 end
return A
