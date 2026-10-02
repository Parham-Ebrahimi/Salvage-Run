local DSS=game:GetService("DataStoreService")
local Http=game:GetService("HttpService")
local Studio=game:GetService("RunService"):IsStudio()
local C=require(game.ReplicatedStorage.Shared.Config)
local D={Profiles={},Sessions={}}
local store=nil
local storeOK,storeResult=pcall(function()return DSS:GetDataStore(C.Data.Name..(Studio and "_Studio" or ""))end)
if storeOK then store=storeResult end
local token=game.JobId..":"..Http:GenerateGUID(false)
function D.Default()
 return {Version=C.Schema,Cash=0,OwnedVehicles={["1"]=true},CurrentVehicle=1,Upgrades={["1"]={Speed=0,HP=0,Cargo=0,Boost=0}},Collection={},Pedestals={},PedestalCount=C.Economy.PedestalStart,Index={},Settings={AutoScrap=false,Music=true,SFX=true},DeepestBanked=0,LastOnline=os.time(),HasBanked=false}
end
local function normalize(data)
 local defaults=D.Default();if type(data)~="table" then return defaults end
 for key,value in defaults do if data[key]==nil or type(data[key])~=type(value) then data[key]=value end end
 data.Version=C.Schema;data.OwnedVehicles["1"]=true
 data.CurrentVehicle=math.clamp(math.floor(data.CurrentVehicle),1,#C.Vehicles)
 if not data.OwnedVehicles[tostring(data.CurrentVehicle)] then data.CurrentVehicle=1 end
 data.Cash=math.clamp(data.Cash,0,C.Economy.CashCap)
 data.PedestalCount=math.clamp(math.floor(data.PedestalCount),C.Economy.PedestalStart,C.Economy.PedestalMax)
 for id in data.OwnedVehicles do
  data.Upgrades[id]=data.Upgrades[id] or {}
  for _,track in C.Upgrades.Tracks do data.Upgrades[id][track]=math.clamp(tonumber(data.Upgrades[id][track]) or 0,0,C.Upgrades.MaxLevel) end
 end
 for i,key in data.Pedestals do if not data.Collection[key] or (tonumber(i) or math.huge)>data.PedestalCount then data.Pedestals[i]=nil end end
 return data
end
function D.Load(player)
 if not store then
  if Studio then local data=D.Default();D.Profiles[player]=data;D.Sessions[player]={Scratch=true};warn("[SalvageRun] Unpublished Studio place: scratch session, saving unavailable");return data end
  player:Kick("Your save could not be loaded. Please rejoin shortly.");return nil
 end
 local key="player_"..player.UserId
 local loaded=nil;local err=nil;local apiFailure=false
 for attempt=1,C.Timing.LoadRetries do
  local busy=false
  local ok,result=pcall(function()
   return store:UpdateAsync(key,function(record)
    record=type(record)=="table" and record or {}
    if record.Lock and record.Lock.Token~=token and record.Lock.Expires>os.time() then busy=true;return nil end
    record.Data=normalize(record.Data);record.Lock={Token=token,Expires=os.time()+C.Timing.SessionLease};return record
   end)
  end)
  if ok and result and not busy then loaded=result.Data;break end
  apiFailure=not ok;err=tostring(result)
  task.wait(busy and C.Timing.LockWait or C.Timing.RetryDelay)
 end
 if not loaded then
  -- Studio-only scratch sessions never write over persistent records on API failure.
  if Studio and apiFailure then loaded=D.Default();D.Sessions[player]={Scratch=true};warn("[SalvageRun] DataStore unavailable: Studio scratch session; persistence UNVERIFIED: "..tostring(err))
  else player:Kick("Your save is still open in another server or could not load. Please rejoin shortly.");return nil end
 else D.Sessions[player]={Key=key,Scratch=false,LastSave=os.clock()} end
 D.Profiles[player]=loaded
 return loaded
end
function D.Save(player,release)
 local session=D.Sessions[player];local data=D.Profiles[player]
 if not session or not data or session.Scratch then return session and session.Scratch end
 if session.Saving then
  if not release then return false end
  repeat task.wait() until not session.Saving
 end
 session.Saving=true
 data.LastOnline=os.time()
 local copy=Http:JSONDecode(Http:JSONEncode(data))
 local saved=false
 for attempt=1,C.Data.SaveRetries do
  local lockLost=false
  local ok=pcall(function()
   store:UpdateAsync(session.Key,function(record)
    if not record or not record.Lock or record.Lock.Token~=token then lockLost=true;return nil end
    return {Data=copy,Lock=not release and {Token=token,Expires=os.time()+C.Timing.SessionLease} or nil}
   end)
  end)
  if lockLost then session.Saving=false;player:Kick("Save session ownership changed. Rejoin to protect your progress.");return false end
  if ok then saved=true;session.LastSave=os.clock();break end
  task.wait(C.Timing.RetryDelay)
 end
 session.Saving=false
 if not saved then warn("[SalvageRun] Save failed for "..player.UserId) end
 return saved
end
function D.Release(player) D.Save(player,true);D.Profiles[player]=nil;D.Sessions[player]=nil end
function D.Init()
 task.spawn(function()while true do task.wait(C.Timing.DataSave);for player in D.Profiles do task.spawn(D.Save,player,false) end end end)
 game:BindToClose(function()
  local pending=0
  for player in D.Profiles do pending+=1;task.spawn(function()D.Save(player,true);pending-=1 end) end
  local deadline=os.clock()+C.Timing.ShutdownDeadline;while pending>0 and os.clock()<deadline do task.wait() end
 end)
end
return D
