local V=require(script.VehicleController)
local H=require(script.HUDController)
local E=require(script.EffectsController)
H.OnSnapshot=V.Set
H.OnFX=E.Event
V.Init();H.Init();E.Init(H,V)
print("[SalvageRun] client ready")
