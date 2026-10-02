local V=require(script.VehicleController)
local H=require(script.HUDController)
H.OnSnapshot=V.Set
V.Init();H.Init()
print("[SalvageRun] client ready")
