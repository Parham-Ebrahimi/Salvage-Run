local C=require(game.ReplicatedStorage.Shared.Config)
local Rarity=require(script.Parent.RarityService)
local Collection=require(script.Parent.CollectionService)
local Stage=require(script.Parent.StageService)
local B={}
function B.Init(ctx)B.Ctx=ctx end
function B.Bank(player)
 local ctx=B.Ctx;local run=ctx.Runs[player];local data=ctx.Data.Profiles[player]
 -- Called only by the server's validated inward crossing; never exposed as a remote.
 if run.State~="RUNNING" or Stage.Depth(run.LastPosition)>0 or not run.PreviousPosition or Stage.Depth(run.PreviousPosition)<=0 then return false end
 if not ctx.Run.State(player,"BANKING") then return false end
 local haul=run.Cargo;local cash=run.Unbanked;run.Cargo={};run.Unbanked=0;run.BoostHeld=false
 local cards={}
 ctx.FX:FireClient(player,"Secured",{})
 ctx.Vehicle.Despawn(player,run);ctx.Run.Home(player)
 for _,record in haul do
  local size=Rarity.Size();local newType=data.Index[record.Item]==nil
  local earned,result,key=Collection.Award(data,record.Item,record.Mutation,size);cash+=earned
  if record.Mutation>1 then
   local odds=Rarity.Odds(record.Mutation,size)
   table.insert(cards,{Item=record.Item,Mutation=record.Mutation,Size=size,Odds=odds,Result=result,Key=key,Value=Rarity.Value(record.Item,record.Mutation,size),NewType=newType})
   if record.Mutation>=6 then ctx.FX:FireAllClients("Announcement",{Player=player.DisplayName,Item=record.Item,Mutation=record.Mutation,Size=size,Odds=odds}) end
  elseif newType then ctx.FX:FireClient(player,"NewIndex",{Item=record.Item}) end
 end
 data.Cash=math.clamp(data.Cash+cash,0,C.Economy.CashCap);data.HasBanked=true;data.DeepestBanked=math.max(data.DeepestBanked,run.Deepest)
 if ctx.Display then ctx.Display.Refresh(player) end
 ctx.FX:FireClient(player,"Banked",{Cash=cash,Cards=cards})
 print("[SalvageRun] run banked",player.UserId,os.clock()-run.Started,run.Deepest,#haul,cash)
 ctx.Run.State(player,"BASE");return true
end
return B
