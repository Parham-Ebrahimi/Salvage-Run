-- All gameplay tuning lives here. +Z is home; forward is the configured axis.
local C = {}
C.Schema = 1
C.World = { Forward = Vector3.new(0,0,-1), Lateral = Vector3.new(1,0,0), Width = 160, StageLength = 350, BaseWidth = 360, BaseDepth = 180, WallHeight = 32, WallThickness = 4, GroundThickness = 4, SafeLine = 0, CalmDistance = 20, BayZ = 28, BayDepth = 20, BayWidthFraction = .85, PlotZ = 132, PlotSpacing = 86, PlotSize = 76, PlotCount = 4, SpawnDistance = 10, SpawnSpacing = 14, StageMargin = 12, PropCount = 8, PropMaxSize = 19, PedestalSpacing = 15, PedestalRadius = 4, PedestalHeight = 2, ApproachDistance = 12 }
C.Physics = { Acceleration = 36, Braking = 65, ReverseFraction = .45, TurnRate = 2.7, FastTurnFraction = .43, Grip = 14, UprightResponsiveness = 35, UprightTorque = 1e8, FlipSeconds = 1.3, GroundRay = 8, Clearance = 2.2, MaxSlope = .4, BoostSpeed = 1.5, BoostDuration = 2, BoostCooldown = 8, BatteryCapacity = 4, BatteryRefill = .6, HopHeight = 8, HopCooldown = 2.5, PhaseDuration = 1, PickupRadius = 12, WideRadius = 1.5, ArmorFraction = .7, SpeedTolerance = 2.1, PositionAllowance = 15, InvalidSamples = 3, SeatGrace = 1.5, SpawnTimeout = 5, RoofHeight = 6, ChassisSize = Vector3.new(4,1,7), ShellMaxSize = 8, CameraDistance = 23, CameraHeight = 12, CameraLookAhead = 13, CameraSmoothing = 8, CameraFov = 72 }
C.VehicleNames = {"Skateboard","BMX Bike","Go-Kart","Dirt Bike","Quad ATV","Jeep","Armored Truck","Monster Truck","Hovercraft","Hover Bike"}
C.Vehicles = {}
local speeds = {40,48,56,64,70,76,80,86,94,104}
local hp = {100,160,250,400,650,1000,1600,2500,4000,6500}
local slots = {6,7,8,9,10,12,14,16,18,20}
local terms = {{"skateboard","longboard"},{"bmx","bicycle","bike"},{"go kart","kart"},{"dirt bike","motocross","motorcycle"},{"atv","quad bike","four wheeler"},{"jeep","offroad","safari jeep"},{"armored truck","swat truck","military truck"},{"monster truck","bigfoot truck"},{"hovercraft","hover car"},{"hover bike","sci fi bike","speeder"}}
local perks = {"none","Hop","Battery","Mud grip","Wide field","Armor","Smash","Crush","Hover","Phase dash"}
for i,name in C.VehicleNames do C.Vehicles[i] = {Id=i,Name=name,Speed=speeds[i],HP=hp[i],Slots=slots[i],Perk=perks[i],Search=terms[i],Asset="vehicle_"..i} end
C.Upgrades = { MaxLevel=5, Growth=1.6, Speed=.06, HP=.15, Cargo=1, Boost=.1, BaseCosts={25,160,1000,6000,36000,220000,1300000,8000000,48000000,280000000}, Tracks={"Speed","HP","Cargo","Boost"}, TradePrices={0,1000,6500,40000,250000,1500000,9000000,55000000,330000000,2000000000} }
C.Economy = { PassiveRate=.01, OfflineRate=.5, OfflineCap=8*60*60, PedestalStart=4, PedestalMax=12, PedestalBaseCost=2000, PedestalGrowth=4, Tick=1, CashCap=1e18 }
C.Pickup = { Density=12, Respawn=3, Light=0, Medium=.5, Heavy=1, MutationExtra=.75, Drain=1, ItemMaxSize=4.5, ItemHeight=.12, Animation=.65, NoiseRadius=45, CrateItems=3, CratesPerStage=2, CrateRespawn=30, CrateRadius=7 }
C.Enemies = { PerStage=5, Aggro=30, Leash=8, AttackRange=7, Windup=.65, Cooldown=1.7, Speed=23, DeepSpeedGrowth=1.5, PatrolRadius=12, ProjectileSpeed=25, ProjectileLife=3, ProjectileRadius=3, PuddleLife=5, PuddleRadius=6, PuddleInterval=3, ReturnSpeed=17, SmallStages={ [1]=true,[2]=true,[3]=true,[4]=true }, Tick=.1, NoiseDuration=3, VisualSize=5, FlashTime=.25, CrushRadius=6 }
C.Hazards = { Count=4, Width=18, Length=16, SlowFraction=.55, OilGrip=.35, DamageInterval=1, DamageFraction=.65, LaserPeriod=5, LaserOn=2.5, RiftPull=13, RiftRadius=22, WaterWidth=10, FallY=-8 }
C.Timing = { ServerTick=.1, Snapshot=.25, RemoteWindow=1, RemoteLimit=12, ActionCooldown=.15, FailureHold=2, DataSave=60, SessionLease=180, LoadRetries=4, RetryDelay=2, LockWait=6, ShutdownDeadline=25, AnnouncementSeconds=6, TipSeconds=12 }
C.Data = { Name="SalvageRun_v1", SaveRetries=3 }
C.Physics.ChassisDensity=2
C.Physics.ChassisFriction=0
C.Physics.ChassisFrictionWeight=100
C.Physics.PlayerJumpPower=50
C.Physics.PlayerJumpHeight=7.2
C.UI = { Font=Enum.Font.FredokaOne, TitleFont=Enum.Font.LuckiestGuy, Stroke=2.5, Corner=16, Shadow=4, Hover=1.05, Press=.92, Bounce=.12, Open=.25, Toast=3.5, MinimumTap=44, BaseViewport=Vector2.new(1280,720), Panel=Vector2.new(660,520), CargoSlot=48, CargoGap=5, Gold=Color3.fromRGB(255,204,58), Green=Color3.fromRGB(87,214,91), Blue=Color3.fromRGB(54,159,241), Red=Color3.fromRGB(238,76,92), Purple=Color3.fromRGB(163,94,241), Dark=Color3.fromRGB(24,32,53), Paper=Color3.fromRGB(241,248,255), Gray=Color3.fromRGB(159,167,185), WarningHP=.15, SmokeHP=.3, RevealsPerPage=1, FloatSeconds=.8, RotateSpeed=.45, StageFog=400, StageAtmosphere=.22 }
C.Sounds = { Click="rbxasset://sounds/electronicpingshort.wav", Pickup="rbxasset://sounds/electronicpingshort.wav", Bank="rbxasset://sounds/victory.wav", Fail="rbxasset://sounds/impact_water.mp3", Thump="rbxasset://sounds/impact_generic.mp3", Siren="rbxasset://sounds/uuhhh.mp3", Volume=.35 }
C.Mutations = {
 {Name="Normal",Odds=0,Multiplier=1,Color=Color3.fromRGB(156,166,179)},
 {Name="Chrome",Odds=25,Multiplier=2,Color=Color3.fromRGB(209,230,241)},
 {Name="Golden",Odds=150,Multiplier=5,Color=Color3.fromRGB(255,205,55)},
 {Name="Electrified",Odds=1000,Multiplier=15,Color=Color3.fromRGB(45,218,255)},
 {Name="Crystal",Odds=7500,Multiplier=50,Color=Color3.fromRGB(158,232,255)},
 {Name="Blue Flame",Odds=60000,Multiplier=200,Color=Color3.fromRGB(52,96,255)},
 {Name="Glitched",Odds=500000,Multiplier=1000,Color=Color3.fromRGB(255,65,211)},
 {Name="Void",Odds=5000000,Multiplier=5000,Color=Color3.fromRGB(113,43,187)},
}
C.Sizes = {{Name="Normal",Probability=.85,Multiplier=1,Scale=1},{Name="Big",Probability=.12,Multiplier=1.5,Scale=1.25},{Name="Huge",Probability=.027,Multiplier=3,Scale=1.6},{Name="Colossal",Probability=.003,Multiplier=10,Scale=2.5}}
C.Stages = {
 {Name="Grassland",Material=Enum.Material.Grass,Color=Color3.fromRGB(100,128,85),Fog=Color3.fromRGB(191,213,179),Multiplier=1,Damage=10,Hazard="Mud",Skulls=1,Props={"grass tuft","small rock","tree stump","wildflower"},Mob={"wild boar","boar"},Behaviors={"Chaser","Swarm"}},
 {Name="Scrap Yard",Material=Enum.Material.Asphalt,Color=Color3.fromRGB(107,111,117),Fog=Color3.fromRGB(177,182,191),Multiplier=5,Damage=19,Hazard="Oil",Skulls=1,Props={"junk pile","scrap pile","tire stack","chain link fence"},Mob={"rat"},Behaviors={"Swarm"}},
 {Name="Appliance Graveyard",Material=Enum.Material.Sand,Color=Color3.fromRGB(161,143,113),Fog=Color3.fromRGB(214,200,172),Multiplier=25,Damage=36,Hazard="Mud",Skulls=2,Props={"old fridge","washing machine","broken tv"},Mob={"dog","wolf"},Behaviors={"Chaser"}},
 {Name="Shipping Docks",Material=Enum.Material.DiamondPlate,Color=Color3.fromRGB(71,117,122),Fog=Color3.fromRGB(165,208,213),Multiplier=120,Damage=69,Hazard="Water",Skulls=2,Props={"cargo container","dock crane","anchor"},Mob={"crab"},Behaviors={"Chaser","Diver"}},
 {Name="Foundry",Material=Enum.Material.Basalt,Color=Color3.fromRGB(127,72,55),Fog=Color3.fromRGB(199,139,104),Multiplier=600,Damage=130,Hazard="Lava",Skulls=3,Props={"furnace","factory machine","smokestack"},Mob={"lava golem","rock golem","fire monster"},Behaviors={"Chaser","Hazard-maker"}},
 {Name="Restricted Zone",Material=Enum.Material.Grass,Color=Color3.fromRGB(106,110,69),Fog=Color3.fromRGB(180,190,149),Multiplier=3000,Damage=248,Hazard="Mud",Skulls=3,Props={"barbed wire","military tent","sandbags","watchtower"},Mob={"robot soldier","sentry turret","robot"},Behaviors={"Sentry","Chaser"}},
 {Name="Research Facility",Material=Enum.Material.Marble,Color=Color3.fromRGB(179,190,196),Fog=Color3.fromRGB(212,230,244),Multiplier=15000,Damage=470,Hazard="Laser",Skulls=4,Props={"lab equipment","server rack","computer desk"},Mob={"lab robot","android"},Behaviors={"Sentry","Diver"}},
 {Name="Containment",Material=Enum.Material.SmoothPlastic,Color=Color3.fromRGB(104,130,73),Fog=Color3.fromRGB(171,206,103),Multiplier=75000,Damage=894,Hazard="Acid",Skulls=4,Props={"containment tank","biohazard barrel","test tube"},Mob={"slime","mutant","zombie"},Behaviors={"Hazard-maker","Swarm"}},
 {Name="Crash Site",Material=Enum.Material.Basalt,Color=Color3.fromRGB(56,51,69),Fog=Color3.fromRGB(152,116,198),Multiplier=350000,Damage=1700,Hazard="Shards",Skulls=5,Props={"ufo","spaceship wreck","alien crystal"},Mob={"alien"},Behaviors={"Diver","Sentry"}},
 {Name="The Anomaly",Material=Enum.Material.Slate,Color=Color3.fromRGB(24,23,36),Fog=Color3.fromRGB(104,71,154),Multiplier=1700000,Damage=3230,Hazard="Rift",Skulls=5,Props={"floating rock","portal","glitch cube"},Mob={"shadow monster","void creature"},Behaviors={"Diver","Hazard-maker"}},
}
local names = {
 {"Tire","Television","Microwave","Toaster","Traffic Cone","Car Battery"},
 {"Washing Machine","Fridge","Arcade Cabinet","Old Computer","Oven","Vending Machine"},
 {"Generator","Engine Block","Oil Barrel","Industrial Fan","Toolbox","Forklift Part"},
 {"Anchor","Ship Wheel","Cargo Crate","Buoy","Outboard Motor","Dock Lamp"},
 {"Robot Arm","Furnace Core","Gear Assembly","Crucible","Steel Beam","Anvil"},
 {"Radar Dish","Field Radio","Satellite Dish","Ammo Crate","Night Vision Goggles","Mech Leg"},
 {"Server Rack","Microscope","Lab Centrifuge","Robot Head","Holo Projector","Quantum Drive"},
 {"Cryo Pod","Plasma Core","Containment Jar","Mutagen Canister","Biohazard Drum","Reactor Rod"},
 {"Alien Power Cell","Saucer Fragment","Alien Skull","Energy Crystal","Ray Gun","Alien Egg"},
 {"Glitch Cube","Floating Orb","Void Shard","Clock Fragment","Mirror Shard","Impossible Ring"},
}
C.Items={}; C.ItemsById={}
local classes={"Light","Medium","Heavy","Medium","Light","Heavy"}
local values={Light=20,Medium=50,Heavy=120}
for stage,row in names do
 for index,name in row do
  local id=string.lower(string.gsub(name," ","_")); local class=classes[index]
  local item={Id=id,DisplayName=name,Stage=stage,WeightClass=class,BaseValue=values[class],SpawnWeight=class=="Heavy" and 1 or 2,Asset="item_"..id}
  table.insert(C.Items,item); C.ItemsById[id]=item
 end
end
function C.Stats(id,levels)
 local v=C.Vehicles[id]; levels=levels or {}
 return {Speed=v.Speed*(1+C.Upgrades.Speed*(levels.Speed or 0)),HP=v.HP*(1+C.Upgrades.HP*(levels.HP or 0)),Slots=v.Slots+(levels.Cargo or 0),BoostDuration=C.Physics.BoostDuration*(1+C.Upgrades.Boost*(levels.Boost or 0)),BoostCooldown=C.Physics.BoostCooldown*(1-C.Upgrades.Boost*(levels.Boost or 0)),Radius=C.Physics.PickupRadius*(id>=5 and C.Physics.WideRadius or 1)}
end
function C.UpgradeCost(vehicle,level) return math.floor(C.Upgrades.BaseCosts[vehicle]*C.Upgrades.Growth^(level-1)+.5) end
function C.PedestalCost(count) return C.Economy.PedestalBaseCost*C.Economy.PedestalGrowth^(count-C.Economy.PedestalStart) end
return C
