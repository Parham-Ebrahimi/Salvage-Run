local Players=game:GetService("Players")
local Tween=game:GetService("TweenService")
local C=require(game.ReplicatedStorage.Shared.Config)
local F=require(game.ReplicatedStorage.Shared.Format)
local U=require(script.Parent.UIKit)
local H={Snapshot=nil}
local net=game.ReplicatedStorage:WaitForChild("SalvageNet")
function H.Request(action,args)net.Request:FireServer(action,args or {})end
function H.Toast(text,color)
 local label=U.Label(H.Root,text,UDim2.fromScale(.5,.085),UDim2.fromScale(.25,-.1),true);label.TextColor3=color or C.UI.Paper;label.ZIndex=50
 Tween:Create(label,TweenInfo.new(C.UI.Open,Enum.EasingStyle.Back),{Position=UDim2.fromScale(.25,.05)}):Play()
 task.delay(C.UI.Toast,function()if label.Parent then Tween:Create(label,TweenInfo.new(C.UI.Open),{Position=UDim2.fromScale(.25,-.1)}):Play();task.delay(C.UI.Open,function()label:Destroy()end)end end)
end
function H.Init()
 local gui=U.New("ScreenGui",{Name="SalvageHUD",ResetOnSpawn=false,IgnoreGuiInset=false,ZIndexBehavior=Enum.ZIndexBehavior.Global},Players.LocalPlayer:WaitForChild("PlayerGui"));H.Gui=gui
 H.Root=U.New("Frame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1},gui)
 H.Cash=U.Label(H.Root,"$0",UDim2.fromScale(.23,.07),UDim2.fromScale(.06,.025),true);H.Cash.TextColor3=C.UI.Gold;H.Cash.TextXAlignment=Enum.TextXAlignment.Left
 U.Icon(H.Root,"coin",UDim2.fromScale(.045,.07),UDim2.fromScale(.012,.025))
 H.Start=U.Button(H.Root,"START",C.UI.Green,UDim2.fromScale(.22,.105),UDim2.fromScale(.39,.68),function()if H.Snapshot then H.Request("Start",{Vehicle=H.Selected or H.Snapshot.Data.CurrentVehicle})end end);H.Start.Visible=false
 H.Picker=U.Button(H.Root,"SKATEBOARD",C.UI.Blue,UDim2.fromScale(.2,.07),UDim2.fromScale(.4,.8),function()
  local s=H.Snapshot;if not s then return end
  local list={};for i=1,#C.Vehicles do if s.Data.OwnedVehicles[tostring(i)] then table.insert(list,i) end end
  local current=table.find(list,H.Selected or s.Data.CurrentVehicle) or 1;H.Selected=list[current%#list+1];H.Picker.TextLabel.Text=string.upper(C.Vehicles[H.Selected].Name)
 end);H.Picker.Visible=false
 H.Tip=U.Label(H.Root,"Drive out, collect, come back",UDim2.fromScale(.45,.055),UDim2.fromScale(.275,.57))
 H.Run=U.New("Frame",{BackgroundTransparency=1,Size=UDim2.fromScale(.67,.18),Position=UDim2.fromScale(.5,.98),AnchorPoint=Vector2.new(.5,1),Visible=false},H.Root)
 H.HPBack=U.New("Frame",{Size=UDim2.fromScale(.62,.18),Position=UDim2.fromScale(.19,0),BackgroundColor3=C.UI.Dark,BorderSizePixel=0},H.Run);U.Round(H.HPBack)
 H.HP=U.New("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=C.UI.Green,BorderSizePixel=0},H.HPBack);U.Round(H.HP)
 H.HPText=U.Label(H.HPBack,"100 / 100",UDim2.fromScale(1,1));H.HPText.ZIndex=4
 H.Cargo=U.New("Frame",{BackgroundTransparency=1,Size=UDim2.fromScale(1,.5),Position=UDim2.fromScale(0,.25)},H.Run)
 H.Unbanked=U.Label(H.Run,"",UDim2.fromScale(1,.2),UDim2.fromScale(0,.78))
 H.Boost=U.Button(H.Root,"BOOST",C.UI.Purple,UDim2.fromScale(.13,.10),UDim2.fromScale(.84,.56),function()H.Request("Boost",{Held=true})end);H.Boost.Visible=false
 H.Boost.MouseButton1Up:Connect(function()H.Request("Boost",{Held=false})end)
 H.Hop=U.Button(H.Root,"HOP",C.UI.Blue,UDim2.fromScale(.13,.08),UDim2.fromScale(.84,.69),function()H.Request("Hop",{})end);H.Hop.Visible=false
 H.Menus={}
 for i,name in {"garage","index","inventory","settings"} do
  local frame=U.New("Frame",{Size=UDim2.fromScale(.058,.092),Position=UDim2.fromScale(.015,.15+(i-1)*.115),BackgroundTransparency=1},H.Root)
  U.New("UIAspectRatioConstraint",{AspectRatio=1},frame)
  local b=U.Button(frame,"",C.UI.Blue,UDim2.fromScale(1,1),UDim2.new(),function()if H.Open then H.Open(name)else H.Toast("Coming online")end end);b.Name=name
  U.Icon(b,name,UDim2.fromScale(.72,.72),UDim2.fromScale(.14,.1));U.Label(frame,string.upper(name),UDim2.fromScale(1.45,.25),UDim2.fromScale(-.225,.94))
  H.Menus[name]=frame
 end
 net.Snapshot.OnClientEvent:Connect(function(s)H.Update(s);if H.OnSnapshot then H.OnSnapshot(s) end end)
 net.FX.OnClientEvent:Connect(function(kind,payload)
  if kind=="Toast" then H.Toast(payload.Text) elseif kind=="Stage" then H.Toast(tostring(payload.Stage).." · "..C.Stages[payload.Stage].Name) elseif H.OnFX then H.OnFX(kind,payload) end
 end)
 H.Request("Ready",{})
end
function H.Update(s)
 local previous=H.Snapshot;H.Snapshot=s;U.SFX=s.Data.Settings.SFX
 H.Cash.Text="$"..F.Number(s.Data.Cash)
 if previous and s.Data.Cash>previous.Data.Cash then
  local l=U.Label(H.Root,"+$"..F.Number(s.Data.Cash-previous.Data.Cash),UDim2.fromScale(.16,.045),UDim2.fromScale(.085,.10));l.TextColor3=C.UI.Gold
  Tween:Create(l,TweenInfo.new(C.UI.FloatSeconds),{Position=UDim2.fromScale(.085,.065),TextTransparency=1}):Play();task.delay(C.UI.FloatSeconds,function()l:Destroy()end)
 end
 H.Start.Visible=s.State=="BASE" and s.InBay
 local owned=0;local best=1;for i=1,#C.Vehicles do if s.Data.OwnedVehicles[tostring(i)] then owned+=1;best=i end end
 if not H.Selected or (previous and previous.Data.CurrentVehicle~=s.Data.CurrentVehicle) then H.Selected=best end
 H.Picker.Visible=H.Start.Visible and owned>1;H.Picker.TextLabel.Text=string.upper(C.Vehicles[H.Selected].Name)
 H.Tip.Visible=not s.Data.HasBanked and s.State=="BASE"
 H.Run.Visible=s.State=="RUNNING";H.Boost.Visible=H.Run.Visible;H.Hop.Visible=H.Run.Visible and s.Data.CurrentVehicle>=2
 if s.Stats then
  H.HP.Size=UDim2.fromScale(math.clamp((s.HP or 0)/s.Stats.HP,0,1),1)
  H.HP.BackgroundColor3=(s.HP or 0)/s.Stats.HP<=C.UI.WarningHP and C.UI.Red or C.UI.Green
  H.HPText.Text=F.Number(s.HP or 0).." / "..F.Number(s.Stats.HP)
  local signature=tostring(s.Stats.Slots)..":"..#s.Cargo
  if H.CargoSignature~=signature then
   H.CargoSignature=signature;for _,x in H.Cargo:GetChildren() do x:Destroy() end
   local cols=math.min(s.Stats.Slots,10);local rows=math.ceil(s.Stats.Slots/cols)
   for i=1,s.Stats.Slots do
    local b=U.New("Frame",{Size=UDim2.fromScale(.94/cols,.9/rows),Position=UDim2.fromScale(.03+((i-1)%cols)/cols,math.floor((i-1)/cols)/rows),BackgroundColor3=s.Cargo[i] and C.Mutations[s.Cargo[i].Mutation].Color or C.UI.Dark,BackgroundTransparency=s.Cargo[i] and .05 or .2,BorderSizePixel=0},H.Cargo);U.Round(b,8);U.Stroke(b)
    if s.Cargo[i] then U.Item(b,s.Cargo[i].Item,s.Cargo[i].Mutation,UDim2.fromScale(.95,.95)) end
   end
  end
  H.Unbanked.Text=(#s.Cargo>=s.Stats.Slots and "FULL  ↑  RETURN HOME  " or "")..(#s.Cargo.."/"..s.Stats.Slots)..(s.Unbanked>0 and "  +$"..F.Number(s.Unbanked) or "")
 end
end
return H
