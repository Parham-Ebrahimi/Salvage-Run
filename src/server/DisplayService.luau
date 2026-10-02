local Players=game:GetService("Players")
local C=require(game.ReplicatedStorage.Shared.Config)
local F=require(game.ReplicatedStorage.Shared.Format)
local Visual=require(game.ReplicatedStorage.Shared.ItemVisual)
local Rarity=require(script.Parent.RarityService)
local Collection=require(script.Parent.CollectionService)
local D={}
function D.Init(ctx)D.Ctx=ctx end
function D.Join(player)
 local ctx=D.Ctx;local data=ctx.Data.Profiles[player];local plot=ctx.Plots[player]
 local elapsed=math.clamp(os.time()-data.LastOnline,0,C.Economy.OfflineCap)
 local reward=Collection.Income(data)*elapsed*C.Economy.OfflineRate
 data.Cash=math.clamp(data.Cash+reward,0,C.Economy.CashCap);data.LastOnline=os.time()
 if reward>0 then ctx.Offline=ctx.Offline or {};ctx.Offline[player]=reward end
 local head=Instance.new("BillboardGui");head.Name="OwnerHeadshot";head.Size=UDim2.fromOffset(64,64);head.StudsOffset=Vector3.new(0,5,0);head.Adornee=plot.Income;head:SetAttribute("Owner",player.UserId);head.Parent=plot
 local image=Instance.new("ImageLabel");image.Size=UDim2.fromScale(1,1);image.BackgroundTransparency=1;image.Parent=head
 task.spawn(function()local ok,url=pcall(Players.GetUserThumbnailAsync,Players,player.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size150x150);if ok and image.Parent then image.Image=url end end)
 D.Refresh(player)
end
function D.Refresh(player)
 local ctx=D.Ctx;local data=ctx.Data.Profiles[player];local plot=ctx.Plots[player];if not data or not plot then return end
 for _,p in plot.Pedestals:GetChildren() do
  local index=tonumber(p.Name);p.Transparency=index>data.PedestalCount and 1 or 0;p.CanCollide=index<=data.PedestalCount
  local old=p:FindFirstChild("Display");if old then old:Destroy() end
  local key=data.Pedestals[tostring(index)];local entry=key and data.Collection[key]
  p:SetAttribute("CollectionKey",key)
  if not entry then continue end
  local model=Visual.Clone(entry.Item,entry.Mutation,entry.Size);if not model then continue end
  model.Name="Display";local _,size=model:GetBoundingBox();local pos=p.Position+Vector3.new(0,p.Size.Y/2+size.Y/2,0);model:PivotTo(CFrame.new(pos));model:SetAttribute("DisplayPosition",pos);model.Parent=p
  local gui=Instance.new("BillboardGui");gui.Name="Nameplate";gui.Adornee=model.PrimaryPart;gui.Size=UDim2.fromOffset(240,100);gui.StudsOffset=Vector3.new(0,size.Y/2+2,0);gui.MaxDistance=C.World.ApproachDistance;gui.Enabled=false;gui.Parent=model
  local text=Instance.new("TextLabel");text.Size=UDim2.fromScale(1,1);text.BackgroundColor3=C.UI.Dark;text.BackgroundTransparency=.15;text.TextColor3=C.Mutations[entry.Mutation].Color;text.Font=C.UI.Font;text.TextSize=17;text.TextWrapped=true
  text.Text=C.ItemsById[entry.Item].DisplayName.."\n"..C.Mutations[entry.Mutation].Name.." · "..C.Sizes[entry.Size].Name.."\n"..F.ExactOdds(Rarity.Odds(entry.Mutation,entry.Size)).." · $"..F.Number(Rarity.Value(entry.Item,entry.Mutation,entry.Size)*C.Economy.PassiveRate).."/sec";text.Parent=gui
  local corner=Instance.new("UICorner");corner.CornerRadius=UDim.new(0,C.UI.Corner);corner.Parent=text
 end
 plot.Income.SurfaceGui.TextLabel.Text="$"..F.Rate(Collection.Income(data)).."/sec"
end
function D.Leave(player)
 local plot=D.Ctx.Plots[player];if not plot then return end
 local head=plot:FindFirstChild("OwnerHeadshot");if head then head:Destroy() end
 for _,p in plot.Pedestals:GetChildren() do local m=p:FindFirstChild("Display");if m then m:Destroy() end;p:SetAttribute("CollectionKey",nil);p.Transparency=tonumber(p.Name)>C.Economy.PedestalStart and 1 or 0;p.CanCollide=tonumber(p.Name)<=C.Economy.PedestalStart end
 plot.Income.SurfaceGui.TextLabel.Text="$0/sec"
end
return D
