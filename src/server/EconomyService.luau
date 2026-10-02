local C=require(game.ReplicatedStorage.Shared.Config)
local Collection=require(script.Parent.CollectionService)
local E={Elapsed=0}
function E.Init(ctx)E.Ctx=ctx end
function E.Upgrade(player,track)
 local ctx=E.Ctx;local run=ctx.Runs[player];local data=ctx.Data.Profiles[player]
 if run.State~="BASE" or not table.find(C.Upgrades.Tracks,track) then return false,"Upgrade in the base" end
 local levels=data.Upgrades[tostring(data.CurrentVehicle)]
 if levels[track]>=C.Upgrades.MaxLevel then return false,"Already maxed" end
 local cost=C.UpgradeCost(data.CurrentVehicle,levels[track]+1)
 if data.Cash<cost then return false,"Need $"..require(game.ReplicatedStorage.Shared.Format).Number(cost) end
 data.Cash-=cost;levels[track]+=1;ctx.FX:FireClient(player,"Toast",{Text=string.upper(track).." UPGRADED!"});return true
end
function E.TradeUp(player)
 local ctx=E.Ctx;local run=ctx.Runs[player];local data=ctx.Data.Profiles[player];local id=data.CurrentVehicle
 if run.State~="BASE" or id>=#C.Vehicles then return false,"Trade Up in the base" end
 if data.OwnedVehicles[tostring(id+1)] then return false,"Next vehicle already owned" end
 for _,track in C.Upgrades.Tracks do if data.Upgrades[tostring(id)][track]<C.Upgrades.MaxLevel then return false,"Max all four upgrade tracks first" end end
 if data.DeepestBanked<id then return false,"Bank a run from Stage "..id.." first" end
 local price=C.Upgrades.TradePrices[id+1];if data.Cash<price then return false,"Need $"..require(game.ReplicatedStorage.Shared.Format).Number(price) end
 data.Cash-=price;data.CurrentVehicle=id+1;data.OwnedVehicles[tostring(id+1)]=true;data.Upgrades[tostring(id+1)]={Speed=0,HP=0,Cargo=0,Boost=0}
 ctx.FX:FireClient(player,"TradeUp",{Vehicle=id+1});print("[SalvageRun] trade up",player.UserId,id+1);return true
end
function E.BuyPedestal(player)
 local ctx=E.Ctx;local data=ctx.Data.Profiles[player]
 if ctx.Runs[player].State~="BASE" or data.PedestalCount>=C.Economy.PedestalMax then return false,"Pedestals are full" end
 local cost=C.PedestalCost(data.PedestalCount);if data.Cash<cost then return false,"Need $"..require(game.ReplicatedStorage.Shared.Format).Number(cost) end
 data.Cash-=cost;data.PedestalCount+=1;ctx.Display.Refresh(player);return true
end
function E.Step(dt)
 E.Elapsed+=dt;if E.Elapsed<C.Economy.Tick then return end
 local elapsed=E.Elapsed;E.Elapsed=0
 for player,data in E.Ctx.Data.Profiles do data.Cash=math.min(C.Economy.CashCap,data.Cash+Collection.Income(data)*elapsed) end
end
return E
