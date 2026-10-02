local Players=game:GetService("Players")
local Input=game:GetService("UserInputService")
local Run=game:GetService("RunService")
local C=require(game.ReplicatedStorage.Shared.Config)
local F=require(game.ReplicatedStorage.Shared.Format)
local U=require(script.Parent.UIKit)
local M={Highlights={},Queue={},Selected=nil}
local function row(content,height)
 local r=U.New("Frame",{Size=UDim2.new(1,-12,0,height or 82),BackgroundColor3=Color3.fromRGB(220,233,248),BorderSizePixel=0},content);U.Round(r);return r
end
local function caption(parent,text,size,pos,color,title)
 local t=U.Label(parent,text,size,pos,title);t.TextColor3=color or C.UI.Paper;return t
end
function M.Close()
 if M.Page then M.Page:Destroy();M.Page=nil end;M.Screen=nil
end
function M.Open(name)
 local H=M.HUD;local s=H.Snapshot;if not s then return end
 if name=="garage" and s.State~="BASE" then H.Toast("Return to base to use Garage");return end
 M.Close();M.Screen=name
 local titles={garage="GARAGE",index="ITEM INDEX",inventory="YOUR FINDS",settings="SETTINGS",trade="TRADE UP",admin="OWNER TOOLS"}
 local backdrop,content,panel=U.Panel(H.Root,titles[name] or name,name=="trade" and C.UI.Purple or C.UI.Blue);M.Page=backdrop;M.Content=content
 backdrop.Destroying:Connect(function()if M.Page==backdrop then M.Page=nil;M.Screen=nil end end)
 local data=s.Data;local id=data.CurrentVehicle
 if name=="garage" then
  local r=row(content,94)
  caption(r,string.upper(C.Vehicles[id].Name),UDim2.fromScale(.6,.4),UDim2.fromScale(.03,.05),C.UI.Gold,true)
  local stats=C.Stats(id,data.Upgrades[tostring(id)])
  caption(r,F.Number(stats.Speed).." SPEED · "..F.Number(stats.HP).." HP · "..stats.Slots.." SLOTS",UDim2.fromScale(.9,.35),UDim2.fromScale(.04,.55))
  for _,track in C.Upgrades.Tracks do
   local level=data.Upgrades[tostring(id)][track];local r2=row(content,72)
   caption(r2,string.upper(track).."  "..level.."/"..C.Upgrades.MaxLevel,UDim2.fromScale(.52,.6),UDim2.fromScale(.03,.17))
   local text=level==C.Upgrades.MaxLevel and "MAX" or "$"..F.Number(C.UpgradeCost(id,level+1))
   U.Button(r2,text,level==C.Upgrades.MaxLevel and C.UI.Gray or C.UI.Green,UDim2.fromScale(.37,.66),UDim2.fromScale(.59,.14),function()H.Request("Upgrade",{Track=track})end)
  end
  local r2=row(content,64);U.Button(r2,id==#C.Vehicles and "FINAL VEHICLE" or "TRADE UP",C.UI.Purple,UDim2.fromScale(.94,.75),UDim2.fromScale(.03,.06),function()M.Open("trade")end)
 elseif name=="trade" then
  if id>=#C.Vehicles then caption(row(content,90),"YOU OWN THE FINAL VEHICLE!",nil,nil,C.UI.Gold,true);return end
  caption(row(content,82),C.Vehicles[id].Name.." → "..C.Vehicles[id+1].Name,nil,nil,C.UI.Gold,true)
  local levels=data.Upgrades[tostring(id)];local maxed=true;for _,track in C.Upgrades.Tracks do if levels[track]<C.Upgrades.MaxLevel then maxed=false end end
  caption(row(content,72),(maxed and "✓" or "○").."  MAX ALL FOUR UPGRADE TRACKS",nil,nil,maxed and C.UI.Green or C.UI.Red)
  caption(row(content,72),(data.DeepestBanked>=id and "✓" or "○").."  BANK A RUN FROM STAGE "..id,nil,nil,data.DeepestBanked>=id and C.UI.Green or C.UI.Red)
  caption(row(content,74),"Keep your finds, pedestals and older vehicles.\nNew vehicle starts with fresh upgrades.",nil,nil,C.UI.Paper)
  local r=row(content,70);U.Button(r,"UNLOCK · $"..F.Number(C.Upgrades.TradePrices[id+1]),C.UI.Green,UDim2.fromScale(.94,.72),UDim2.fromScale(.03,.08),function()H.Request("TradeUp",{})end)
 elseif name=="settings" then
  for _,key in {"AutoScrap","Music","SFX"} do
   local r=row(content,78);local value=data.Settings[key]
   caption(r,key=="AutoScrap" and "AUTO-SCRAP" or string.upper(key),UDim2.fromScale(.57,.62),UDim2.fromScale(.03,.17))
   U.Button(r,value and "ON" or "OFF",value and C.UI.Green or C.UI.Gray,UDim2.fromScale(.32,.65),UDim2.fromScale(.64,.15),function()H.Request("Settings",{Key=key,Value=not value})end)
  end
  caption(row(content,95),"Auto-scrap turns known plain finds into temporary Cash. Bring it home to keep it!",nil,nil,C.UI.Gold)
  if s.Admin then local r=row(content,64);U.Button(r,"OWNER TOOLS",C.UI.Purple,UDim2.fromScale(.94,.75),UDim2.fromScale(.03,.06),function()M.Open("admin")end) end
 elseif name=="index" then
  local found=0;for _ in data.Index do found+=1 end
  caption(row(content,54),tostring(math.floor(found/#C.Items*100)).."% COMPLETE · "..found.."/"..#C.Items,nil,nil,C.UI.Gold,true)
  for stage,stageCfg in C.Stages do
   local pool={};local known=0
   for _,item in C.Items do if item.Stage==stage then table.insert(pool,item);if data.Index[item.Id] then known+=1 end end end
   caption(row(content,48),stage.."  "..string.upper(stageCfg.Name).." · "..math.floor(known/#pool*100).."%",nil,nil,C.UI.Blue,true)
   local grid=row(content,245);grid.BackgroundTransparency=1
   for i,item in pool do
    local col=(i-1)%3;local line=math.floor((i-1)/3)
    local tile=U.New("Frame",{Size=UDim2.fromScale(.31,.46),Position=UDim2.fromScale(.015+col*.33,line*.5),BackgroundColor3=C.UI.Dark,BorderSizePixel=0},grid);U.Round(tile,10)
    local icon=U.Item(tile,item.Id,1,UDim2.fromScale(.65,.55),UDim2.fromScale(.175,.03))
    local discovery=data.Index[item.Id]
    if not discovery then icon.ImageColor3=Color3.fromRGB(28,35,48) end
    caption(tile,discovery and item.DisplayName or "???",UDim2.fromScale(.94,.22),UDim2.fromScale(.03,.58))
    for mutation,m in C.Mutations do local pip=U.New("Frame",{Size=UDim2.fromScale(.08,.10),Position=UDim2.fromScale(.08+(mutation-1)*.11,.86),BackgroundColor3=discovery and discovery[tostring(mutation)] and m.Color or C.UI.Gray,BackgroundTransparency=discovery and discovery[tostring(mutation)] and 0 or .8,BorderSizePixel=0},tile);U.Round(pip,10) end
   end
  end
 elseif name=="inventory" then
  local list={};for key,entry in data.Collection do table.insert(list,{Key=key,Entry=entry}) end
  table.sort(list,function(a,b)local x,y=a.Entry,b.Entry;return x.Mutation>y.Mutation or x.Mutation==y.Mutation and C.ItemsById[x.Item].Stage>C.ItemsById[y.Item].Stage end)
  caption(row(content,54),#list.." FINDS · CHOOSE ONE TO DISPLAY",nil,nil,C.UI.Gold,true)
  for _,record in list do
   local entry=record.Entry;local r=row(content,98)
   U.Item(r,entry.Item,entry.Mutation,UDim2.fromScale(.19,.85),UDim2.fromScale(.01,.05))
   caption(r,C.ItemsById[entry.Item].DisplayName.."\n"..C.Mutations[entry.Mutation].Name.." · "..C.Sizes[entry.Size].Name,UDim2.fromScale(.50,.52),UDim2.fromScale(.21,.04),C.Mutations[entry.Mutation].Color)
   local value=require(game.ReplicatedStorage.Shared.Config).ItemsById[entry.Item].BaseValue*C.Stages[C.ItemsById[entry.Item].Stage].Multiplier*C.Mutations[entry.Mutation].Multiplier*C.Sizes[entry.Size].Multiplier
   caption(r,"$"..F.Number(value*C.Economy.PassiveRate).."/sec · "..F.ExactOdds((C.Mutations[entry.Mutation].Odds>0 and C.Mutations[entry.Mutation].Odds or 1)/C.Sizes[entry.Size].Probability),UDim2.fromScale(.51,.32),UDim2.fromScale(.2,.64))
   U.Button(r,"PLACE",C.UI.Green,UDim2.fromScale(.23,.55),UDim2.fromScale(.74,.2),function()M.Placement(record.Key)end)
  end
  if #list==0 then caption(row(content,94),"Bank a haul to start your Collection!",nil,nil,C.UI.Paper) end
  if data.PedestalCount<C.Economy.PedestalMax then local r=row(content,68);U.Button(r,"PEDESTAL "..(data.PedestalCount+1).." · $"..F.Number(C.PedestalCost(data.PedestalCount)),C.UI.Green,UDim2.fromScale(.94,.74),UDim2.fromScale(.03,.08),function()H.Request("Pedestal",{})end) end
 elseif name=="admin" and s.Admin then
  for _,action in {{"GIVE $10K","Cash",{Amount=10000}},{"RESET DATA","Reset",{}},{"FORCE GOLDEN","ForceMutation",{Item="microwave",Mutation=3}}} do local r=row(content,64);U.Button(r,action[1],action[2]=="Reset" and C.UI.Red or C.UI.Purple,UDim2.fromScale(.94,.75),UDim2.fromScale(.03,.06),function()H.Request("Debug",{Command=action[2],Args=action[3]})end) end
  local fields={}
  for _,field in {{"VEHICLE 1–10","Vehicle","Id"},{"STAGE 1–10","Teleport","Stage"},{"MUTATION 1–8","ForceMutation","Mutation"}} do
   local r=row(content,72);local input=U.New("TextBox",{Size=UDim2.fromScale(.48,.67),Position=UDim2.fromScale(.03,.12),PlaceholderText=field[1],Text="",TextScaled=true,Font=C.UI.Font,BackgroundColor3=C.UI.Dark,TextColor3=C.UI.Paper},r);U.Round(input)
   U.Button(r,"SET",C.UI.Green,UDim2.fromScale(.4,.67),UDim2.fromScale(.56,.12),function()local n=tonumber(input.Text);if n then local args={[field[3]]=n};if field[2]=="ForceMutation" then args.Item="microwave" end;H.Request("Debug",{Command=field[2],Args=args})end end)
  end
 end
 M.Signature=M.DataSignature(s)
end
function M.DataSignature(s)
 local data=s.Data
 return game:GetService("HttpService"):JSONEncode({data.Upgrades,data.CurrentVehicle,data.Index,data.Collection,data.PedestalCount,data.Settings,data.DeepestBanked})
end
function M.Snapshot(s)
 if M.Screen and M.DataSignature(s)~=M.Signature then local pos=M.Content.CanvasPosition;M.Open(M.Screen);if M.Content then M.Content.CanvasPosition=pos end end
 if M.Selected and s.State~="BASE" then M.CancelPlacement() end
 if s.Plot then
  for _,plot in workspace.SalvageWorld.Plots:GetChildren() do local head=plot:FindFirstChild("OwnerHeadshot");if head then head.Enabled=plot:GetAttribute("Owner")~=Players.LocalPlayer.UserId end end
 end
end
function M.CancelPlacement()
 for _,h in M.Highlights do h:Destroy()end;M.Highlights={};M.Selected=nil
end
function M.Placement(key)
 local s=M.HUD.Snapshot;if s.State~="BASE" then M.HUD.Toast("Place your finds in base");return end
 M.Close();M.CancelPlacement();M.Selected=key
 for _,p in s.Plot.Pedestals:GetChildren() do if tonumber(p.Name)<=s.Data.PedestalCount then table.insert(M.Highlights,U.New("Highlight",{Adornee=p,FillColor=C.UI.Green,OutlineColor=C.UI.Green,FillTransparency=.7,DepthMode=Enum.HighlightDepthMode.AlwaysOnTop},p)) end end
 M.HUD.Toast("TAP ONE OF YOUR GLOWING PEDESTALS",C.UI.Green)
end
function M.Pedestal(index)
 local s=M.HUD.Snapshot
 if M.Selected then M.HUD.Request("Place",{Index=index,Key=M.Selected});M.CancelPlacement();return end
 local key=s.Data.Pedestals[tostring(index)];if not key then M.Open("inventory");return end
 M.Close();local page,content=U.Panel(M.HUD.Root,"PEDESTAL "..index,C.UI.Blue);M.Page=page
 for _,action in {"SWAP","REMOVE"} do local r=row(content,72);U.Button(r,action,action=="REMOVE" and C.UI.Red or C.UI.Green,UDim2.fromScale(.94,.72),UDim2.fromScale(.03,.08),function()if action=="REMOVE" then M.HUD.Request("Remove",{Index=index});M.Close() else M.Open("inventory")end end) end
end
function M.Reveal(card)
 M.Close();local mutation=C.Mutations[card.Mutation]
 local page,content,panel=U.Panel(M.HUD.Root,string.upper(mutation.Name).." FIND!",mutation.Color);M.Page=page;M.RevealPage=page
 local modelRow=row(content,180);modelRow.BackgroundColor3=C.UI.Dark
 local frame,model=U.Item(modelRow,card.Item,card.Mutation,UDim2.fromScale(.7,.94),UDim2.fromScale(.15,.03))
 if model then
  local rotation=0;local conn;conn=Run.RenderStepped:Connect(function(dt)if not model.Parent then conn:Disconnect();return end;rotation+=dt*C.UI.RotateSpeed;model:PivotTo(CFrame.Angles(0,rotation,0))end)
 end
 caption(row(content,64),C.ItemsById[card.Item].DisplayName.." · "..C.Sizes[card.Size].Name,nil,nil,mutation.Color,true)
 caption(row(content,60),F.ExactOdds(card.Odds).."  ·  "..card.Result,nil,nil,C.UI.Gold,true)
 local r=row(content,64)
 U.Button(r,"PLACE IT",C.UI.Green,UDim2.fromScale(.53,.76),UDim2.fromScale(.03,.07),function()M.Queue={};M.Placement(card.Key)end)
 U.Button(r,"NEXT",C.UI.Blue,UDim2.fromScale(.37,.76),UDim2.fromScale(.60,.07),function()M.NextReveal()end)
 page.Destroying:Connect(function()if M.RevealPage==page then M.RevealPage=nil;task.defer(function()if #M.Queue>0 then M.NextReveal()end end)end end)
 U.Sound("Bank")
end
function M.NextReveal()
 M.RevealPage=nil;M.Close();local card=table.remove(M.Queue,1);if card then M.Reveal(card)end
end
function M.Event(kind,p)
 if kind=="Banked" then M.Queue=p.Cards or {};M.NextReveal()
 elseif kind=="Offline" then M.Close();local page,content=U.Panel(M.HUD.Root,"WHILE YOU WERE GONE",C.UI.Gold);M.Page=page;caption(row(content,140),"+$"..F.Number(p.Cash),nil,nil,C.UI.Gold,true);caption(row(content,100),"Your displayed finds kept earning!",nil,nil,C.UI.Paper);U.Sound("Bank") end
end
function M.Init(hud)
 M.HUD=hud;hud.Open=M.Open
 if Run:IsStudio() then
  hud.Gui:GetAttributeChangedSignal("TestScreen"):Connect(function()local name=hud.Gui:GetAttribute("TestScreen");if name=="close" then M.Close()else M.Open(name)end end)
  hud.Gui:GetAttributeChangedSignal("TestReveal"):Connect(function()local raw=hud.Gui:GetAttribute("TestReveal");if type(raw)=="string" then M.Reveal(game:GetService("HttpService"):JSONDecode(raw))end end)
 end
 Input.InputBegan:Connect(function(input,processed)
  if processed or input.UserInputType~=Enum.UserInputType.MouseButton1 and input.UserInputType~=Enum.UserInputType.Touch then return end
  local s=hud.Snapshot;if not s or s.State~="BASE" then return end
  local ray=workspace.CurrentCamera:ScreenPointToRay(input.Position.X,input.Position.Y);local hit=workspace:Raycast(ray.Origin,ray.Direction*C.World.BaseWidth)
  if hit then local p=hit.Instance;while p and not p:GetAttribute("Index") do p=p.Parent end;if p and p:IsDescendantOf(s.Plot) and p:GetAttribute("Index")<=s.Data.PedestalCount then M.Pedestal(p:GetAttribute("Index"))end end
 end)
end
return M
