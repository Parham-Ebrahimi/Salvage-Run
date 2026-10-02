local Tween=game:GetService("TweenService")
local Sound=game:GetService("SoundService")
local C=require(game.ReplicatedStorage.Shared.Config)
local U={Icons=require(script.Parent.Icons),SFX=true}
function U.New(class,props,parent)
 local x=Instance.new(class);for key,value in props or {} do x[key]=value end;x.Parent=parent;return x
end
function U.Sound(name)
 if not U.SFX then return end
 local s=U.New("Sound",{SoundId=C.Sounds[name] or C.Sounds.Click,Volume=C.Sounds.Volume},Sound);s:Play();game:GetService("Debris"):AddItem(s,C.UI.Toast)
end
function U.Round(obj,radius)U.New("UICorner",{CornerRadius=UDim.new(0,radius or C.UI.Corner)},obj)end
function U.Stroke(obj,color,width)U.New("UIStroke",{Color=color or C.UI.Dark,Thickness=width or C.UI.Stroke,ApplyStrokeMode=Enum.ApplyStrokeMode.Border},obj)end
function U.Label(parent,text,size,pos,title)
 local t=U.New("TextLabel",{BackgroundTransparency=1,Size=size or UDim2.fromScale(1,1),Position=pos or UDim2.new(),Text=text,TextColor3=Color3.new(1,1,1),Font=title and C.UI.TitleFont or C.UI.Font,TextSize=22,TextWrapped=true,TextScaled=true},parent)
 U.New("UIStroke",{Color=C.UI.Dark,Thickness=C.UI.Stroke,ApplyStrokeMode=Enum.ApplyStrokeMode.Contextual},t)
 return t
end
function U.Button(parent,text,color,size,pos,callback)
 local shadow=U.New("Frame",{Name="ButtonShadow",Size=size,Position=pos+UDim2.fromOffset(0,C.UI.Shadow),BackgroundColor3=(color or C.UI.Blue):Lerp(C.UI.Dark,.45),BorderSizePixel=0},parent);U.Round(shadow)
 local b=U.New("TextButton",{Name=text:gsub("[^%w]",""),Text="",AutoButtonColor=false,Size=size,Position=pos,BackgroundColor3=color or C.UI.Blue,BorderSizePixel=0},parent)
 U.Round(b);U.Stroke(b);U.New("UIGradient",{Color=ColorSequence.new((color or C.UI.Blue):Lerp(Color3.new(1,1,1),.25),color or C.UI.Blue),Rotation=90},b)
 U.Label(b,text,UDim2.fromScale(.9,.8),UDim2.fromScale(.05,.1))
 local scale=U.New("UIScale",{Scale=1},b)
 local function animate(n)Tween:Create(scale,TweenInfo.new(C.UI.Bounce,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale=n}):Play()end
 b.MouseEnter:Connect(function()animate(C.UI.Hover)end);b.MouseLeave:Connect(function()animate(1)end)
 b.MouseButton1Down:Connect(function()animate(C.UI.Press)end)
 b.Activated:Connect(function()animate(1);U.Sound("Click");if callback then callback() end end)
 b:GetPropertyChangedSignal("Visible"):Connect(function()shadow.Visible=b.Visible end)
 b.Destroying:Connect(function()shadow:Destroy()end)
 return b
end
function U.Icon(parent,name,size,pos)
 if U.Icons[name] then return U.New("ImageLabel",{BackgroundTransparency=1,Image=U.Icons[name],Size=size,Position=pos,ScaleType=Enum.ScaleType.Fit},parent) end
 -- Same-kit images may be pending moderation. Shape fallback still gives a readable icon.
 local f=U.New("Frame",{BackgroundColor3=name=="coin" and C.UI.Gold or C.UI.Paper,Size=size,Position=pos,BorderSizePixel=0},parent);U.Round(f,12);U.Stroke(f)
 U.New("UIAspectRatioConstraint",{AspectRatio=1},f)
 if name=="coin" then U.Round(f,100);U.Label(f,"$",UDim2.fromScale(.7,.7),UDim2.fromScale(.15,.15),true)
 else
  U.New("Frame",{BackgroundColor3=C.UI.Blue,BorderSizePixel=0,Size=UDim2.fromScale(.6,.2),Position=UDim2.fromScale(.2,.25)},f)
  U.New("Frame",{BackgroundColor3=C.UI.Blue,BorderSizePixel=0,Size=UDim2.fromScale(.6,.2),Position=UDim2.fromScale(.2,.55)},f)
 end
 return f
end
function U.Panel(root,title,color)
 local backdrop=U.New("Frame",{Name=title,Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=.45,ZIndex=20},root)
 local panel=U.New("Frame",{Size=UDim2.fromScale(.66,.8),Position=UDim2.fromScale(.5,.5),AnchorPoint=Vector2.new(.5,.5),BackgroundColor3=C.UI.Paper,BorderSizePixel=0,ZIndex=21},backdrop);U.Round(panel);U.Stroke(panel,nil,4)
 U.New("UISizeConstraint",{MaxSize=C.UI.Panel,MinSize=Vector2.new(300,270)},panel)
 local header=U.New("Frame",{Size=UDim2.fromScale(1,.14),BackgroundColor3=color or C.UI.Blue,BorderSizePixel=0,ZIndex=22},panel);U.Round(header)
 U.Label(header,title,UDim2.fromScale(.8,.82),UDim2.fromScale(.04,.05),true).ZIndex=23
 local scale=U.New("UIScale",{Scale=.8},panel);Tween:Create(scale,TweenInfo.new(C.UI.Open,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale=1}):Play()
 local close=U.Button(panel,"X",C.UI.Red,UDim2.fromOffset(44,44),UDim2.new(1,-52,0,8),function()
  Tween:Create(scale,TweenInfo.new(C.UI.Bounce),{Scale=.8}):Play();task.delay(C.UI.Bounce,function()backdrop:Destroy()end)
 end);close.ZIndex=24;for _,x in close:GetDescendants() do if x:IsA("GuiObject") then x.ZIndex=25 end end
 local content=U.New("ScrollingFrame",{Size=UDim2.fromScale(.92,.8),Position=UDim2.fromScale(.04,.17),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=6,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(),ZIndex=22},panel)
 U.New("UIListLayout",{Padding=UDim.new(0,10),SortOrder=Enum.SortOrder.LayoutOrder},content)
 U.New("UIPadding",{PaddingLeft=UDim.new(0,5),PaddingRight=UDim.new(0,5),PaddingTop=UDim.new(0,5),PaddingBottom=UDim.new(0,10)},content)
 return backdrop,content,panel
end
function U.Item(parent,itemId,mutation,size,pos)
 local item=C.ItemsById[itemId];local asset=item and game.ReplicatedStorage.SalvageAssets:FindFirstChild(item.Asset)
 local frame=U.New("ViewportFrame",{Size=size,Position=pos or UDim2.new(),BackgroundTransparency=1,Ambient=Color3.new(.8,.8,.8),LightColor=Color3.new(1,1,1),LightDirection=Vector3.new(-1,-1,-1)},parent)
 if not asset then return frame end
 local model=asset:Clone();model.Parent=frame
 local _,bounds=model:GetBoundingBox();local distance=math.max(bounds.X,bounds.Y,bounds.Z)*1.8
 local camera=U.New("Camera",{CFrame=CFrame.lookAt(Vector3.new(distance*.7,distance*.5,distance),Vector3.zero()),FieldOfView=40},frame);frame.CurrentCamera=camera
 if mutation and mutation>1 then
  for _,p in model:GetDescendants() do if p:IsA("BasePart") then p.Color=C.Mutations[mutation].Color;p.Material=mutation==2 and Enum.Material.Metal or mutation==5 and Enum.Material.Glass or Enum.Material.Neon end end
 end
 return frame,model
end
return U
