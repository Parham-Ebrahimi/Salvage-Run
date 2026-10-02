-- Mocked DataStore integration checks; no network, players, or Play session.
-- Caller passes a factory that evaluates DataService with these dependencies.
return function(factory)
	local results={}
	local config={Schema=1,Data={Name="SalvageRun_v1",SaveRetries=3},Timing={SessionLease=180,StudioLockReclaim=10,StudioLockRenew=5,DataSave=60,LoadRetries=4,RetryDelay=2,LockWait=6,ShutdownDeadline=25},Economy={PedestalStart=4,PedestalMax=12,CashCap=1e18},Vehicles={{},{}},Upgrades={Tracks={"Speed","HP","Cargo","Boost"},MaxLevel=5}}
	local function copy(value)
		if type(value)~="table" then return value end
		local out={};for k,v in value do out[k]=copy(v) end;return out
	end
	local function environment(studio,record)
		local e={Now=1000,Record=copy(record),Warnings={},Queue={},Guid=0,Config=config}
		local store={}
		function store:UpdateAsync(_,transform)
			local nextRecord=transform(copy(e.Record))
			if nextRecord then e.Record=copy(nextRecord) end
			return nextRecord and copy(nextRecord) or nil
		end
		local http={GenerateGUID=function()e.Guid+=1;return "guid"..e.Guid end,JSONEncode=function(_,v)return copy(v)end,JSONDecode=function(_,v)return copy(v)end}
		e.game={JobId="mock-server",GetService=function(_,name)
			if name=="DataStoreService" then return {GetDataStore=function(_,name)e.StoreName=name;return store end} end
			if name=="HttpService" then return http end
			if name=="RunService" then return {IsStudio=function()return studio end} end
			error("Unexpected service "..name)
		end,BindToClose=function(_,fn)e.Close=fn end}
		e.os={time=function()return e.Now end,clock=function()return e.Now end}
		e.warn=function(message)table.insert(e.Warnings,message)end
		e.task={spawn=function(fn,...)table.insert(e.Queue,{Fn=fn,Args={...}})end,wait=function(seconds)
			if e.PeriodicProbe then e.Interval=seconds;coroutine.yield();return end
			e.Now+=seconds or .1
			if #e.Queue>1 then local work=table.remove(e.Queue,2);work.Fn(table.unpack(work.Args)) end
		end}
		e.Player={UserId=42,Kick=function(_,message)e.Kicked=message end}
		return e
	end
	local function locked(age,user,legacy)
		local lock={Token="foreign-server:old",Expires=1000-age+180}
		if not legacy then lock.UserId=user or 42;lock.UpdatedAt=1000-age;lock.JobId="foreign-server" end
		return {Data={Cash=123},Lock=lock}
	end
	local function pass(name)table.insert(results,name)end
	local e=environment(true,locked(10));local d=factory(e)
	assert(d.Load(e.Player).Cash==123 and e.Record.Lock.Token~="foreign-server:old" and e.Record.Lock.UserId==42)
	assert(e.StoreName=="SalvageRun_v1_Studio");pass("Studio same-user lock reclaimed at 10 seconds; data preserved")
	e=environment(true,locked(0));d=factory(e);assert(d.Load(e.Player) and #e.Warnings==2)
	assert(e.Now==1012 and e.Warnings[1]:find("owner=foreign-server:old",1,true) and e.Warnings[1]:find("age=0.0s",1,true));pass("Fresh Studio lock refused/logged until stale; retry reclaims at 12 seconds")
	e=environment(true,locked(10,42,true));d=factory(e);assert(d.Load(e.Player).Cash==123);pass("Legacy Studio lock age inferred from 180-second lease")
	e=environment(true,locked(20,99));d=factory(e);assert(d.Load(e.Player)==nil and e.Kicked and e.Record.Lock.Token=="foreign-server:old");pass("Different-user unexpired Studio lock remains protected")
	e=environment(false,locked(20));d=factory(e);assert(d.Load(e.Player)==nil and e.Kicked and #e.Warnings==0)
	assert(e.StoreName=="SalvageRun_v1" and e.Record.Lock.Token=="foreign-server:old");pass("Production refuses 20-second foreign lock; namespace unchanged")
	e=environment(false,locked(181));d=factory(e);assert(d.Load(e.Player).Cash==123)
	assert(e.Record.Lock.Expires==1180 and e.Record.Lock.UserId==nil and e.Record.Lock.UpdatedAt==nil);pass("Production expired lock behavior and record shape unchanged")
	d.Release(e.Player);assert(e.Record.Lock==nil and e.Record.Data.Cash==123 and d.Profiles[e.Player]==nil);pass("PlayerRemoving release path saves data and clears lock")
	e=environment(true,nil);d=factory(e);assert(d.Load(e.Player));d.Init();assert(e.Close);e.Close();assert(e.Record.Lock==nil);pass("BindToClose saves and clears lock")
	e=environment(true,nil);d=factory(e);assert(d.Load(e.Player));local oldToken=e.Record.Lock.Token
	e.Record.Lock.Token="new-owner";e.Record.Data.Cash=456;assert(d.Save(e.Player,false)==false and e.Record.Data.Cash==456 and e.Record.Lock.Token=="new-owner");assert(oldToken~="new-owner");pass("Displaced session cannot overwrite new owner")
	for _,studio in {false,true}do
		e=environment(studio,nil);d=factory(e);d.Init();e.PeriodicProbe=true
		assert(coroutine.resume(coroutine.create(e.Queue[1].Fn)))
		assert(e.Interval==(studio and 5 or 60))
	end
	pass("Renewal intervals: Studio 5 seconds, production 60 seconds")
	return {Passed=true,Checks=results,RealDataStoreAccess=false,PlayStarted=false}
end
