local V=require(script.VehicleController)
local H=require(script.HUDController)
local E=require(script.EffectsController)
local M=require(script.MenuController)
H.OnSnapshot=function(s)V.Set(s);M.Snapshot(s)end
H.OnFX=function(kind,p)E.Event(kind,p);M.Event(kind,p)end
V.Init();H.Init();E.Init(H,V);M.Init(H)
print("[SalvageRun] client ready")
