local Utility = {}
local UI = {}

local CornerSize = UDim.new(0,8)--UDim.new(0,6)
local ScrollSmoothness = 0.2
	--[[local DefaultTheme = {
		Scheme = Color3.fromRGB(35, 175, 100);
		Background = Color3.fromRGB(40, 40, 40);
		Topbar = Color3.fromRGB(30, 30, 30);
		Content = Color3.fromRGB(50, 50, 50);
		ScrollbarTrack = Color3.fromRGB(40, 40, 40);
		Text = Color3.fromRGB(255, 255, 255);
		Item = Color3.fromRGB(50, 50, 50);
	}]]
local DefaultTheme = {
	Scheme = Color3.fromRGB(38, 175, 136);
	Background = Color3.fromRGB(31, 32, 40);
	Topbar = Color3.fromRGB(22, 23, 30);
	Content = Color3.fromRGB(41, 41, 50);
	ScrollbarTrack = Color3.fromRGB(33, 34, 40);
	Text = Color3.fromRGB(255, 255, 255);
	Item = Color3.fromRGB(51, 51, 60);
}

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local TextService = game:GetService("TextService")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

function Utility:Tween(obj,Info,Props)
	assert(obj ~= nil,"No object given.")
	assert(Props ~= nil,"No properties given.")

	local _Tween = TweenService:Create(obj,Info or TweenInfo.new(1,Enum.EasingStyle.Linear),Props)
	_Tween:Play()
	return _Tween
end
function Utility:CallCallback(Callback,...)
	local s,r = pcall(Callback,...)
	if not s then
		warn(r)
	end
	return s == true and r ~= false
end
function Utility:IsColorDark(Color)
	return math.sqrt(
		0.299 * (Color.R ^ 2) +
			0.587 * (Color.G ^ 2) +
			0.114 * (Color.B ^ 2)
	) < 0.5
end
function Utility:EditThemeStyle(Theme,Style,Color)
	local Copy = {}
	for Style,Color in pairs(Theme) do
		Copy[Style] = Theme[Style]
	end

	if typeof(Color) == "string" then
		Copy[Style] = Theme[Color]
	else
		Copy[Style] = Color
	end

	return Copy
end

local Styles = {}
function Utility:ApplyTheme(obj,Property,Theme,Style,Function)
	if not Theme then Theme = DefaultTheme end

	assert(obj ~= nil,"No object given.")
	assert(Property ~= nil,"No property given.")
	assert(Style ~= nil,"No style given.")
	if typeof(Style) == "string" then
		assert(Theme[Style] ~= nil,"Style "..tostring(Style).." does not exist.")
	end

	if Function then
		obj[Property] = Function()
	else
		obj[Property] = Theme[Style]
	end

	if not Styles[obj] then Styles[obj] = {} end
	Styles[obj][Property] = {Style,Function}
end
function Utility:UpdateTheme(NewTheme)
	for obj,Data in pairs(Styles) do
		for Property,StyleData in pairs(Data) do
			if StyleData[2] then
				StyleData[2]()
			else
				obj[Property] = NewTheme[StyleData[1]]
			end
		end
	end
end
function Utility:UpdateThemeColor(NewTheme,Style)
	for obj,Data in pairs(Styles) do
		for Property,StyleData in pairs(Data) do
			if StyleData[1] == Style then
				if StyleData[2] then
					obj[Property] = StyleData[2]()
				else
					obj[Property] = NewTheme[StyleData[1]]
				end
			end
		end
	end
end

function Utility:Drag(Dragger,Move)
	local Dragging = false
	local DragInput,MousePos,FramePos

	Dragger.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			Dragging = true
			MousePos = Input.Position
			FramePos = Move.Position

			Input.Changed:Connect(function()
				if Input.UserInputState == Enum.UserInputState.End then
					Dragging = false
				end
			end)
		end
	end)

	Dragger.InputChanged:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseMovement then
			DragInput = Input
		end
	end)

	UIS.InputChanged:Connect(function(Input)
		if Input == DragInput and Dragging then
			local Delta = Input.Position - MousePos
			Move.Position = UDim2.new(FramePos.X.Scale,math.clamp(FramePos.X.Offset + Delta.X,0,Workspace.CurrentCamera.ViewportSize.X - Move.AbsoluteSize.X),FramePos.Y.Scale,math.clamp(FramePos.Y.Offset + Delta.Y,36,Workspace.CurrentCamera.ViewportSize.Y - Move.AbsoluteSize.Y))
		end
	end)
end
function Utility:SyncCanvasSize(Scroll,UIList)
	UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		Scroll.CanvasSize = UDim2.new(Scroll.CanvasSize.X.Scale,Scroll.CanvasSize.X.Offset,0,UIList.AbsoluteContentSize.Y)
	end)
	Scroll.CanvasSize = UDim2.new(Scroll.CanvasSize.X.Scale,Scroll.CanvasSize.X.Offset,0,UIList.AbsoluteContentSize.Y)
end
function Utility:SyncSize(Frame,UIList)
	UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		Frame.Size = UDim2.new(Frame.Size.X.Scale,Frame.Size.X.Offset,0,UIList.AbsoluteContentSize.Y)
	end)
	Frame.Size = UDim2.new(Frame.Size.X.Scale,Frame.Size.X.Offset,0,UIList.AbsoluteContentSize.Y)
end
function Utility:Corner(obj,Radius)
	assert(obj ~= nil,"No object given.")

	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = Radius
	Corner.Parent = obj
	return Corner
end
function Utility:RemoveCorner(obj,Face,Corner)
	assert(obj ~= nil,"No object given.")
	assert(Face ~= nil,"No face given.")
	assert(Corner ~= nil,"No UICorner or CornerRadius given.")

	local Blocker = Instance.new("Frame")
	Blocker.BorderSizePixel = 0
	Blocker.ZIndex = -math.huge
	Blocker.Parent = obj

	obj.Changed:Connect(function()
		Blocker.BackgroundColor3 = obj.BackgroundColor3
	end)
	Blocker.BackgroundColor3 = obj.BackgroundColor3

	local function GetRadius()
		if typeof(Corner) == "UDim" then
			return Corner.Offset
		else
			return Corner.CornerRadius.Offset
		end
	end

	if Face == Enum.NormalId.Top then
		Blocker.AnchorPoint = Vector2.new(0,0)
		Blocker.Position = UDim2.new(0,0,0,0)
		Blocker.Size = UDim2.new(1,0,0,GetRadius())
	elseif Face == Enum.NormalId.Right then
		Blocker.AnchorPoint = Vector2.new(1,0)
		Blocker.Position = UDim2.new(1,0,0,0)
		Blocker.Size = UDim2.new(0,GetRadius(),1,0)
	elseif Face == Enum.NormalId.Bottom then
		Blocker.AnchorPoint = Vector2.new(0,1)
		Blocker.Position = UDim2.new(0,0,1,0)
		Blocker.Size = UDim2.new(1,0,0,GetRadius())
	elseif Face == Enum.NormalId.Left then
		Blocker.AnchorPoint = Vector2.new(0,0)
		Blocker.Position = UDim2.new(0,0,0,0)
		Blocker.Size = UDim2.new(0,GetRadius(),1,0)
	else
		Blocker:Destroy()
		error("Invalid face.")
	end

	return Blocker
end
function Utility:ScrollBar(Scroll)
	Scroll.TopImage = "http://www.roblox.com/asset/?id=4490132608"
	Scroll.MidImage = "http://www.roblox.com/asset/?id=4490132966"
	Scroll.BottomImage = "http://www.roblox.com/asset/?id=4490133158"
end
function Utility:ScrollTrack(Scroll,Theme)
	coroutine.wrap(function()
		if Scroll.Parent == nil then
			repeat Scroll.AncestryChanged:Wait() until Scroll.Parent ~= nil
		end

		if Scroll.Parent:FindFirstChild(Scroll.Name.."_TrackHolder") then
			Scroll.Parent:FindFirstChild(Scroll.Name.."_TrackHolder"):Destroy()
		end

		local TrackHolder = Instance.new("Frame",Scroll.Parent)
		TrackHolder.BackgroundTransparency = 1
		TrackHolder.Name = Scroll.Name.."_TrackHolder"

		local Track = Instance.new("ImageLabel",TrackHolder)
		Track.AnchorPoint = Vector2.new(1,0)
		Track.BackgroundTransparency = 1
		Track.BorderSizePixel = 1
		Track.Position = UDim2.new(1,0,0,0)
		Track.Image = "http://www.roblox.com/asset/?id=4490129735"
		Track.ScaleType = Enum.ScaleType.Slice
		Track.SliceCenter = Rect.new(0,2,4,6)
		Track.SliceScale = 1
		Track.TileSize = UDim2.new(1,0,1,0)
		Track.Name = "Track"

		Utility:ApplyTheme(Track,"ImageColor3",Theme,"ScrollbarTrack")

		local function Update()
			TrackHolder.Parent = Scroll.Parent
			TrackHolder.AnchorPoint = Scroll.AnchorPoint
			TrackHolder.Position = Scroll.Position
			TrackHolder.Rotation = Scroll.Rotation
			TrackHolder.Size = Scroll.Size
			TrackHolder.SizeConstraint = Scroll.SizeConstraint
			TrackHolder.Visible = Scroll.Visible
			TrackHolder.ZIndex = Scroll.ZIndex - 1

			Track.Size = UDim2.new(0,Scroll.ScrollBarThickness,1,0)
			Track.ZIndex = Scroll.ZIndex - 1
		end

		Update()
		TrackHolder.Changed:Connect(Update)
		Track.Changed:Connect(Update)
		Scroll.Changed:Connect(Update)
	end)()
end
function Utility:SmoothScroll(Scroll,Smoothness)
	coroutine.wrap(function()
		if Scroll.Parent == nil then
			repeat Scroll.AncestryChanged:Wait() until Scroll.Parent ~= nil
		end

		if Scroll.Parent:FindFirstChild(Scroll.Name.."_smoothinputframe") then
			Scroll.Parent:FindFirstChild(Scroll.Name.."_smoothinputframe"):Destroy()
		end

			--[[
				
				SmoothScroll
				smoother scrolling frames
				
				by Elttob
				
			]]

		Smoothness = Smoothness or 0.15
		Scroll.ScrollingEnabled = false

		-- create the 'input' scrolling frame, aka the scrolling frame which receives user input
		-- if smoothing is enabled, enable scrolling
		local input = Scroll:Clone()
		input:ClearAllChildren()
		input.BackgroundTransparency = 1
		input.ScrollBarImageTransparency = 1
		input.ZIndex = Scroll.ZIndex + 1
		input.Name = Scroll.Name.."_smoothinputframe"
		input.ScrollingEnabled = true
		input.Parent = Scroll.Parent

		-- keep input frame in sync with content frame
		local function syncProperty(prop)
			Scroll:GetPropertyChangedSignal(prop):Connect(function()
				if prop == "ZIndex" then
					-- keep the input frame on top!
					input[prop] = Scroll[prop] + 1
				else
					input[prop] = Scroll[prop]
				end
			end)
			input:GetPropertyChangedSignal(prop):Connect(function() -- Added by me ew cause yes
				if prop == "ZIndex" then
					if input[prop] - 1 ~= Scroll[prop] then
						input[prop] = Scroll[prop] + 1
					end
				else
					if input[prop] ~= Scroll[prop] then
						input[prop] = Scroll[prop]
					end
				end
			end)
		end

		syncProperty "CanvasSize"
		syncProperty "Position"
		syncProperty "Rotation"
		syncProperty "ScrollingDirection"
		syncProperty "ScrollBarThickness"
		syncProperty "BorderSizePixel"
		syncProperty "ElasticBehavior"
		syncProperty "SizeConstraint"
		syncProperty "ZIndex"
		syncProperty "BorderColor3"
		syncProperty "Size"
		syncProperty "AnchorPoint"
		syncProperty "Visible"

		-- create a render stepped connection to interpolate the content frame position to the input frame position
		local smoothConnection = game:GetService("RunService").RenderStepped:Connect(function(dt)
			local a = Scroll.CanvasPosition
			local b = input.CanvasPosition
			local c = math.min(Smoothness * (60 * dt),1) -- Made it use delta time - Ew
			local d = (b - a) * c + a
			Scroll.CanvasPosition = d
		end)

		-- destroy everything when the frame is destroyed
		Scroll.AncestryChanged:Connect(function()
			if Scroll.Parent == nil then
				input:Destroy()
				smoothConnection:Disconnect()
			end
		end)
	end)()
end

function Utility:Ripple(Item,Position,Theme)
	local Ripple = Instance.new("Frame")
	Ripple.BackgroundColor3 = Theme.Scheme
	Ripple.BackgroundTransparency = 0.6
	Ripple.Position = UDim2.new(0,Position.X - Item.AbsolutePosition.X,0,Position.Y - Item.AbsolutePosition.Y)
	Ripple.Size = UDim2.new(0,0,0,0)
	Ripple.ZIndex = -math.huge
	Utility:Corner(Ripple,UDim.new(1,0))
	Ripple.Parent = Item

	coroutine.wrap(function()
		local Size = Item.AbsoluteSize.X > Item.AbsoluteSize.Y and (Item.AbsoluteSize.X * 1.5) or (Item.AbsoluteSize.Y * 1.5)

		Utility:Tween(Ripple,TweenInfo.new(1,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{
			BackgroundTransparency = 1;
			Position = UDim2.new(0.5,-Size/2,0.5,-Size/2);
			Size = UDim2.new(0,Size,0,Size);
		}).Completed:Wait()

		Ripple:Destroy()
	end)()

	return Ripple
end
function Utility:ItemError(Item)

end

function Utility:CreateItem(Name,Icon,Description,Theme,BackgroundStyle)
	local Item = Instance.new("Frame")
	local NameText = Instance.new("TextLabel")
	local IconImage = (Icon and Icon ~= "") and Instance.new("ImageLabel") or nil
	local DescriptionButton = (Description and Description ~= "") and Instance.new("ImageButton") or nil

	Item.Size = UDim2.new(1,0,0,36)
	Item.ClipsDescendants = true
	Utility:Corner(Item,CornerSize)
	Utility:ApplyTheme(Item,"BackgroundColor3",Theme,BackgroundStyle)

	NameText.AnchorPoint = Vector2.new(0,0.5)
	NameText.BackgroundTransparency = 1
	NameText.BorderSizePixel = 0
	NameText.Position = UDim2.new(0,IconImage ~= nil and 36 or 7.5,0,Item.AbsoluteSize.Y/2)
	NameText.Size = UDim2.new(1,-15,0,Item.AbsoluteSize.Y - 15)
	NameText.ZIndex = 0
	NameText.Font = Enum.Font.SourceSans
	NameText.Text = Name
	NameText.TextScaled = false
	NameText.TextSize = 18
	NameText.TextWrapped = true
	NameText.TextXAlignment = Enum.TextXAlignment.Left
	Utility:ApplyTheme(NameText,"TextColor3",Theme,"Text")
	NameText.Parent = Item

	if IconImage then
		IconImage.AnchorPoint = Vector2.new(0,0.5)
		IconImage.BackgroundTransparency = 1
		IconImage.BorderSizePixel = 0
		IconImage.Position = UDim2.new(0,7.5,0,Item.AbsoluteSize.Y/2)
		IconImage.Size = UDim2.new(1,-15,0,Item.AbsoluteSize.Y - 15)
		IconImage.ZIndex = 0
		IconImage.Image = Icon
		Utility:ApplyTheme(IconImage,"ImageColor3",Theme,(BackgroundStyle == "Scheme" and "Text" or "Scheme"))
		Instance.new("UIAspectRatioConstraint",IconImage)
		IconImage.Parent = Item
	end

	local OnDisplayDescription = nil
	if DescriptionButton then
		OnDisplayDescription = Instance.new("BindableEvent")

		DescriptionButton.AnchorPoint = Vector2.new(1,0.5)
		DescriptionButton.BackgroundTransparency = 1
		DescriptionButton.BorderSizePixel = 0
		DescriptionButton.Position = UDim2.new(1,-7.5,0,Item.AbsoluteSize.Y/2)
		DescriptionButton.Size = UDim2.new(1,-15,0,Item.AbsoluteSize.Y - 15)
		DescriptionButton.ZIndex = 2
		DescriptionButton.Image = "rbxassetid://8318429389"
		Utility:ApplyTheme(DescriptionButton,"ImageColor3",Theme,(BackgroundStyle == "Scheme" and "Text" or "Scheme"))
		Instance.new("UIAspectRatioConstraint",DescriptionButton)
		DescriptionButton.Parent = Item

		DescriptionButton.MouseButton1Click:Connect(function()
			OnDisplayDescription:Fire()
		end)
	end

	return Item,(OnDisplayDescription ~= nil and OnDisplayDescription.Event or nil)
end
function Utility:AddItemButton(Item)
	local Button = Instance.new("TextButton")

	Button.BackgroundTransparency = 1
	Button.BorderSizePixel = 0
	Button.Size = UDim2.new(1,0,1,0)
	Button.Text = ""
	Button.Parent = Item

	return Button
end

function UI:CreateLib(Title,Theme,Position)
	assert(Title ~= nil,"No title given.")

	local CurrentTheme = {}
	for n,v in pairs(Theme or DefaultTheme) do
		CurrentTheme[n] = v
	end
	
	local LibName = HttpService:GenerateGUID(false)
	local DisplayingDescription = false
	local OnClose = Instance.new("BindableEvent")

	local Gui = Instance.new("ScreenGui")
	local Main = Instance.new("Frame")
	local Topbar = Instance.new("Frame")
	local Header = Instance.new("TextLabel")
	local CloseButton = Instance.new("ImageButton")
	local Tabs = Instance.new("ScrollingFrame")
	local TabsUIList = Instance.new("UIListLayout")
	local Content = Instance.new("Frame")
	local Blur = Instance.new("Frame")
	local DescriptionHolder = Instance.new("Frame")
	local DescriptionText = Instance.new("TextLabel")

	local function ApplyTheme(obj,Property,Style,Function)
		return Utility:ApplyTheme(obj,Property,CurrentTheme,Style,Function)
	end
	local function CreateItem(Name,Icon,Description,BackgroundStyle)
		return Utility:CreateItem(Name,Icon,Description,CurrentTheme,BackgroundStyle)
	end
	local function DisplayDescription(Description,CanYeild)
		assert(Description ~= nil,"No description given.")

		if DisplayingDescription then
			if CanYeild == true then
				repeat RunService.RenderStepped:Wait() until DisplayingDescription == false
			else
				return
			end
		end

		DisplayingDescription = true

		pcall(function()
			local Info = TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.Out)

			DescriptionText.Text = Description

			Utility:Tween(Blur,Info,{
				BackgroundTransparency = 0.6;
			})
			Utility:Tween(DescriptionHolder,Info,{
				Position = UDim2.new(DescriptionHolder.Position.X.Scale,DescriptionHolder.Position.X.Offset,1,-10);
			}).Completed:Wait()

			task.wait(2)

			Utility:Tween(Blur,Info,{
				BackgroundTransparency = 1;
			})
			Utility:Tween(DescriptionHolder,Info,{
				Position = UDim2.new(DescriptionHolder.Position.X.Scale,DescriptionHolder.Position.X.Offset,1.5,0);
			}).Completed:Wait()
		end)

		DisplayingDescription = false
	end

	Gui.DisplayOrder = 2147483647
	Gui.Enabled = true
	Gui.IgnoreGuiInset = true
	Gui.Name = LibName
	Gui.ResetOnSpawn = false
	Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	pcall(function()
		Gui.OnTopOfCoreBlur = true
	end)

	Main.Size = UDim2.new(0,525,0,318)
	Main.ClipsDescendants = true
	Utility:Corner(Main,CornerSize)
	ApplyTheme(Main,"BackgroundColor3","Background")
	Main.Parent = Gui

	Topbar.Size = UDim2.new(1,0,0,36)
	Utility:RemoveCorner(Topbar,Enum.NormalId.Bottom,Utility:Corner(Topbar,CornerSize))
	ApplyTheme(Topbar,"BackgroundColor3","Topbar")
	Topbar.Parent = Main

	Header.AnchorPoint = Vector2.new(0,0.5)
	Header.BackgroundTransparency = 1
	Header.BorderSizePixel = 0
	Header.Position = UDim2.new(0,10,0.5,0)
	Header.Size = UDim2.new(1,-15,1,-15)
	Header.Font = Enum.Font.SourceSansSemibold
	Header.Text = Title
	Header.TextScaled = true
	Header.TextWrapped = true
	Header.TextXAlignment = Enum.TextXAlignment.Left
	ApplyTheme(Header,"TextColor3","Text")
	Header.Parent = Topbar

	CloseButton.AnchorPoint = Vector2.new(1,0.5)
	CloseButton.AutoButtonColor = false
	CloseButton.BackgroundTransparency = 1
	CloseButton.BorderSizePixel = 0
	CloseButton.Position = UDim2.new(1,-5,0.5,0)
	CloseButton.Size = UDim2.new(1,-10,1,-10)
	CloseButton.Image = "rbxassetid://8324551908"
	ApplyTheme(CloseButton,"ImageColor3","Text")
	Instance.new("UIAspectRatioConstraint",CloseButton)
	CloseButton.Parent = Topbar

	Tabs.AnchorPoint = Vector2.new(0,1)
	Tabs.BackgroundTransparency = 1
	Tabs.BorderSizePixel = 0
	Tabs.Position = UDim2.new(0,10,1,-10)
	Tabs.Size = UDim2.new(0,120,1,-56)
	Tabs.ClipsDescendants = true
	Tabs.CanvasSize = UDim2.new(0,0,0,0)
	Tabs.ScrollBarImageTransparency = 1
	Tabs.ScrollBarThickness = 0
	Utility:SmoothScroll(Tabs,ScrollSmoothness)
	ApplyTheme(Tabs,"ScrollBarImageColor3","Text")
	Tabs.Parent = Main

	TabsUIList.Padding = UDim.new(0,4)
	TabsUIList.FillDirection = Enum.FillDirection.Vertical
	TabsUIList.SortOrder = Enum.SortOrder.LayoutOrder
	TabsUIList.Parent = Tabs

	Content.AnchorPoint = Vector2.new(1,1)
	Content.Position = UDim2.new(1,0,1,0)
	Content.Size = UDim2.new(1,-Tabs.AbsoluteSize.X - 20,1,-Topbar.AbsoluteSize.Y)
	Utility:Corner(Content,CornerSize)
	Utility:RemoveCorner(Content,Enum.NormalId.Left,CornerSize)
	Utility:RemoveCorner(Content,Enum.NormalId.Top,CornerSize)
	ApplyTheme(Content,"BackgroundColor3","Content")
	Content.Parent = Main

	Blur.AnchorPoint = Vector2.new(0,1)
	Blur.BackgroundColor3 = Color3.fromRGB(0,0,0)
	Blur.BackgroundTransparency = 1
	Blur.BorderSizePixel = 0
	Blur.Position = UDim2.new(0,0,1,0)
	Blur.Size = UDim2.new(1,0,1,0)
	Blur.ZIndex = 2
	Utility:Corner(Blur,CornerSize)
	Blur.Parent = Main

	DescriptionHolder.AnchorPoint = Vector2.new(0.5,1)
	DescriptionHolder.Size = UDim2.new(1,-20,0,30)
	DescriptionHolder.Position = UDim2.new(0.5,0,1.5,0)
	DescriptionHolder.ZIndex = 3
	Utility:Corner(DescriptionHolder,CornerSize)
	ApplyTheme(DescriptionHolder,"BackgroundColor3","Scheme")
	DescriptionHolder.Parent = Main

	DescriptionText.AnchorPoint = Vector2.new(0.5,0.5)
	DescriptionText.BackgroundTransparency = 1
	DescriptionText.BorderSizePixel = 0
	DescriptionText.Position = UDim2.new(0.5,0,0.5,0)
	DescriptionText.Size = UDim2.new(1,-10,1,-10)
	DescriptionText.Font = Enum.Font.SourceSans
	DescriptionText.Text = ""
	DescriptionText.TextScaled = false
	DescriptionText.TextSize = 16
	DescriptionText.TextWrapped = true
	DescriptionText.TextXAlignment = Enum.TextXAlignment.Left
	ApplyTheme(DescriptionText,"TextColor3","Text")
	DescriptionText.Parent = DescriptionHolder

	Main.Position = Position or UDim2.new(0,Workspace.CurrentCamera.ViewportSize.X/2 - Main.AbsoluteSize.X/2,0,Workspace.CurrentCamera.ViewportSize.Y/2 - Main.AbsoluteSize.Y/2)
	Utility:Drag(Topbar,Main)

	if syn ~= nil then
		syn.protect_gui(Gui)
	end

	local SelectedTab = nil

	local Lib = {}
	Lib.Enabled = false
	Lib.OnClose = OnClose.Event

	function Lib:EnableUI(Enabled)
		if Enabled then
			Lib.Enabled = true

			if get_hidden_gui ~= nil then
				Gui.Parent = get_hidden_gui()
			else
				xpcall(function()
					Gui.Parent = game:GetService("CoreGui")
				end,function()
					Gui.Parent = Player:FindFirstChildWhichIsA("PlayerGui",true)
				end)
			end
		else
			Lib.Enabled = false
			Gui.Parent = nil
		end
	end
	function Lib:ToggleUI()
		return Lib:EnableUI(not Lib.Enabled)
	end
	function Lib:NewTab(Name,Data)
		Name = Name or "Tab "..tostring(#Tabs:GetChildren())
		if Content:FindFirstChild(Name) then error("Tab "..tostring(Name).." already exists.") end

		local First = #Tabs:GetChildren() == 1
		if First then
			SelectedTab = Name
		end

		local TabButton = Instance.new("TextButton")
		local ContentList = Instance.new("ScrollingFrame")
		local ContentUIList = Instance.new("UIListLayout")

		TabButton.AutoButtonColor = false
		TabButton.BackgroundTransparency = First and 0 or 1
		TabButton.LayoutOrder = #Tabs:GetChildren() - 1
		TabButton.Size = UDim2.new(1,0,0,30)
		TabButton.Font = Enum.Font.SourceSans
		TabButton.Text = Name
		TabButton.TextScaled = false
		TabButton.TextSize = 16
		TabButton.TextWrapped = true
		Utility:Corner(TabButton,CornerSize)
		ApplyTheme(TabButton,"BackgroundColor3","Scheme")
		ApplyTheme(TabButton,"TextColor3","Text")
		TabButton.Parent = Tabs

		ContentList.AnchorPoint = Vector2.new(0.5,0.5)
		ContentList.BackgroundTransparency = 1
		ContentList.BorderSizePixel = 0
		ContentList.Name = Name
		ContentList.Position = UDim2.new(0.5,0,0.5,0)
		ContentList.Size = UDim2.new(1,-20,1,-20)
		ContentList.Visible = First
		ContentList.ClipsDescendants = true
		ContentList.CanvasSize = UDim2.new(0,0,0,0)
		ContentList.ScrollBarThickness = 4
		Utility:ScrollBar(ContentList)
		Utility:ScrollTrack(ContentList,CurrentTheme)
		Utility:SmoothScroll(ContentList,ScrollSmoothness)
		ApplyTheme(ContentList,"ScrollBarImageColor3","Text")
		ContentList.Parent = Content

		ContentUIList.Padding = UDim.new(0,16)
		ContentUIList.FillDirection = Enum.FillDirection.Vertical
		ContentUIList.SortOrder = Enum.SortOrder.LayoutOrder
		ContentUIList.Parent = ContentList

		local Tab = {}

		function Tab:NewSection(Name,Description,Data)
			Name = Name or "Section"
			Data = Data or {}

			local SectionHolder = Instance.new("Frame")
			local SectionUIList = Instance.new("UIListLayout")
			local SectionHeader,OnDisplayDescription = CreateItem(Name,Data.Icon or nil,Description,"Scheme")

			SectionHolder.BackgroundTransparency = 1
			SectionHolder.BorderSizePixel = 0
			SectionHolder.LayoutOrder = 0
			SectionHolder.Size = UDim2.new(1,-ContentList.ScrollBarThickness - 10,0,0)
			SectionHolder.Parent = ContentList

			SectionUIList.Padding = UDim.new(0,8)
			SectionUIList.FillDirection = Enum.FillDirection.Vertical
			SectionUIList.SortOrder = Enum.SortOrder.LayoutOrder
			SectionUIList.Parent = SectionHolder

			SectionHeader.Visible = Data.Hidden or true
			SectionHeader.Parent = SectionHolder

			local Section = {}
			function Section:UpdateName(NewName)
				SectionHeader:FindFirstChildOfClass("TextLabel").Text = NewName
			end
			function Section:SetHidden(Hidden)
				SectionHeader.Visible = not Hidden
			end
			function Section:NewLabel(Name,Description,Data)
				Name = Name or "Label"
				Data = Data or {}

				local LabelItem,OnDisplayDescription = CreateItem(Name,Data.Icon or "rbxassetid://9177477893",Description,"Item")
				LabelItem.LayoutOrder = #SectionHolder:GetChildren() - 1
				LabelItem.Size = UDim2.new(LabelItem.Size.X.Scale, LabelItem.Size.X.Offset, LabelItem.Size.Y.Scale, LabelItem.Size.Y.Offset + (LabelItem.TextBounds.Y-LabelItem.TextSize))
				LabelItem.Parent = SectionHolder

				local Label = {}
				function Label:UpdateName(NewName)
					LabelItem:FindFirstChildOfClass("TextLabel").Text = NewName
				end
				function Label:UpdateIcon(NewIcon)
					LabelItem:FindFirstChildOfClass("ImageLabel").Image = NewIcon
				end

				if OnDisplayDescription then
					OnDisplayDescription:Connect(function()
						DisplayDescription(Description)
					end)
				end

				return Label
			end
			function Section:NewButton(Name,Description,Callback,Data)
				Name = Name or "Button"
				Callback = Callback or function() end
				Data = Data or {}

				local ButtonItem,OnDisplayDescription = CreateItem(Name,Data.Icon or "rbxassetid://8318711356",Description,"Item")
				local Input = Utility:AddItemButton(ButtonItem)

				ButtonItem.LayoutOrder = #SectionHolder:GetChildren() - 1
				ButtonItem.Parent = SectionHolder

				local Button = {}
				function Button:UpdateName(NewName)
					ButtonItem:FindFirstChildOfClass("TextLabel").Text = NewName
				end
				function Button:UpdateIcon(NewIcon)
					ButtonItem:FindFirstChildOfClass("ImageLabel").Image = NewIcon
				end

				Input.MouseButton1Click:Connect(function()
					if Utility:CallCallback(Callback) then
						Utility:Ripple(ButtonItem,Vector2.new(Mouse.X,Mouse.Y),CurrentTheme)
					else
						Utility:ItemError(ButtonItem)
					end
				end)

				if OnDisplayDescription then
					OnDisplayDescription:Connect(function()
						DisplayDescription(Description)
					end)
				end

				return Button
			end
			function Section:NewToggle(Name,Description,Callback,Data)
				local Changed = Instance.new("BindableEvent")
				Name = Name or "Toggle"
				Callback = Callback or function() end
				Data = Data or {}

				local State = Data.State or false

				local ToggleItem,OnDisplayDescription = CreateItem(Name,"rbxassetid://8318488758",Description,"Item")
				local Input = Utility:AddItemButton(ToggleItem)
				local Circle = ToggleItem:FindFirstChildOfClass("ImageLabel")
				local Checked = Instance.new("Frame")

				ToggleItem.LayoutOrder = #SectionHolder:GetChildren() - 1
				ToggleItem.Parent = SectionHolder

				Checked.AnchorPoint = Vector2.new(0.5,0.5)
				Checked.BackgroundTransparency = State == true and 0 or 1
				Checked.Position = UDim2.new(0.5,0,0.5,0)
				Checked.Size = UDim2.new(1,-12,1,-12)
				Utility:Corner(Checked,UDim.new(1,0))
				ApplyTheme(Checked,"BackgroundColor3","Scheme")
				Checked.Parent = Circle

				local Toggle = {}
				function Toggle:UpdateName(NewName)
					ToggleItem:FindFirstChildOfClass("TextLabel").Text = NewName
				end
				function Toggle:UpdateIcon(NewIcon)
					ToggleItem:FindFirstChildOfClass("ImageLabel").Image = NewIcon
				end
				function Toggle:SetState(NewState)
					State = NewState

					Utility:Tween(Checked,TweenInfo.new(0.2,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{
						BackgroundTransparency = State == true and 0 or 1;
					})

					return Utility:CallCallback(Callback,State)
				end
				function Toggle:GetState()
					return State
				end
				
				Toggle.Changed = Changed.Event
				
				Input.MouseButton1Click:Connect(function()
					if Toggle:SetState(not State) then
						Utility:Ripple(ToggleItem,Vector2.new(Mouse.X,Mouse.Y),CurrentTheme)
					else
						Utility:ItemError(ToggleItem)
					end
					Changed:Fire(State)
				end)

				if OnDisplayDescription then
					OnDisplayDescription:Connect(function()
						DisplayDescription(Description)
					end)
				end

				Toggle:SetState(State)
				return Toggle
			end
			function Section:NewSlider(Name,Description,Min,Max,Callback,Data)
				local Changed = Instance.new("BindableEvent")

				Name = Name or "Slider"
				Min = Min or 0
				Max = Max or 100
				Callback = Callback or function() end
				Data = Data or {}

				local Value = Data.Value or Min

				local SliderItem,OnDisplayDescription = CreateItem(Name,Data.Icon or "rbxassetid://8324589323",Description,"Item")
				local Input = Utility:AddItemButton(SliderItem)
				local SliderHolder = Instance.new("Frame")
				local SliderValue = Instance.new("Frame")

				local ItemSize = SliderItem.AbsoluteSize

				SliderItem.LayoutOrder = #SectionHolder:GetChildren() - 1
				SliderItem.Size = UDim2.new(1,0,0,ItemSize.Y + 12)
				SliderItem.Parent = SectionHolder

				SliderHolder.AnchorPoint = Vector2.new(0.5,1)
				SliderHolder.Position = UDim2.new(0.5,0,1,-6)
				SliderHolder.Size = UDim2.new(1,-12,0,6)
				SliderHolder.ClipsDescendants = true
				Utility:Corner(SliderHolder,UDim.new(1,0))
				ApplyTheme(SliderHolder,"BackgroundColor3","Item",function()
					return Color3.new(math.clamp(CurrentTheme.Item.R - 10/255,0,1),math.clamp(CurrentTheme.Item.G - 10/255,0,1),math.clamp(CurrentTheme.Item.B - 10/255,0,1))
				end)
				SliderHolder.Parent = SliderItem

				SliderValue.Size = UDim2.new(0,0,1,0)
				Utility:Corner(SliderValue,UDim.new(1,0))
				ApplyTheme(SliderValue,"BackgroundColor3","Scheme")
				SliderValue.Parent = SliderHolder

				local Slider = {}
				function Slider:UpdateName(NewName)
					SliderItem:FindFirstChildOfClass("TextLabel").Text = NewName
				end
				function Slider:UpdateIcon(NewIcon)
					SliderItem:FindFirstChildOfClass("ImageLabel").Image = NewIcon
				end
				function Slider:SetValue(NewValue)
					Value = math.clamp(NewValue,Min,Max)
					SliderValue.Size = UDim2.new(math.clamp((Value - Min)/(Max - Min),0,1),0,1,0)

					Utility:CallCallback(Callback,Value)
				end
				function Slider:GetValue()
					return Value
				end
				Slider.Changed = Changed.Event
				
				Input.MouseButton1Down:Connect(function()
					local MouseMove
					local MouseUp

					local function Update()
						Slider:SetValue((((Max - Min)/SliderHolder.AbsoluteSize.X) * (Mouse.X - SliderHolder.AbsolutePosition.X)) + Min)
						Changed:Fire(Value)
					end

					MouseMove = Mouse.Move:Connect(Update)
					MouseUp = UIS.InputEnded:Connect(function(Input)
						if Input.UserInputType == Enum.UserInputType.MouseButton1 then
							MouseMove:Disconnect()
							MouseUp:Disconnect()

							Update()
						end
					end)

					Update()
				end)

				if OnDisplayDescription then
					OnDisplayDescription:Connect(function()
						DisplayDescription(Description)
					end)
				end

				Slider:SetValue(Value)
				return Slider
			end
			function Section:NewTextBox(Name,Description,Callback,Data)
				local Changed = Instance.new("BindableEvent")

				Name = Name or "TextBox"
				Callback = Callback or function() end
				Data = Data or {}

				local TextBoxItem,OnDisplayDescription = CreateItem(Name,Data.Icon or "rbxassetid://9177467437",Description,"Item")
				local Input = Utility:AddItemButton(TextBoxItem)
				local TextBoxHolder = Instance.new("Frame")
				local TextBoxInstance = Instance.new("TextBox")

				local ItemSize = TextBoxItem.AbsoluteSize

				TextBoxItem.LayoutOrder = #SectionHolder:GetChildren() - 1
				TextBoxItem.Size = UDim2.new(1,0,0,ItemSize.Y + 30)
				TextBoxItem.Parent = SectionHolder

				TextBoxHolder.AnchorPoint = Vector2.new(0.5,1)
				TextBoxHolder.Position = UDim2.new(0.5,0,1,-6)
				TextBoxHolder.Size = UDim2.new(1,-12,0,24)
				TextBoxHolder.ClipsDescendants = true
				Utility:Corner(TextBoxHolder,CornerSize)
				ApplyTheme(TextBoxHolder,"BackgroundColor3","Item",function()
					return Color3.new(math.clamp(CurrentTheme.Item.R - 10/255,0,1),math.clamp(CurrentTheme.Item.G - 10/255,0,1),math.clamp(CurrentTheme.Item.B - 10/255,0,1))
				end)
				TextBoxHolder.Parent = TextBoxItem

				TextBoxInstance.AnchorPoint = Vector2.new(0.5,0.5)
				TextBoxInstance.BackgroundTransparency = 1
				TextBoxInstance.BorderSizePixel = 0
				TextBoxInstance.Position = UDim2.new(0.5,0,0.5,0)
				TextBoxInstance.Size = UDim2.new(1,-12,1,-12)
				TextBoxInstance.ClearTextOnFocus = Data.ClearTextOnFocus or false
				TextBoxInstance.MultiLine = false
				TextBoxInstance.PlaceholderText = Data.PlaceholderText or "..."
				TextBoxInstance.TextXAlignment = Enum.TextXAlignment.Left
				TextBoxInstance.TextScaled = true
				ApplyTheme(TextBoxInstance,"TextColor3","Text")
				TextBoxInstance.Parent = TextBoxHolder

				local TextBox = {}
				TextBox.Changed = Changed.Event
				function TextBox:UpdateName(NewName)
					TextBoxItem:FindFirstChildOfClass("TextLabel").Text = NewName
				end
				function TextBox:UpdateIcon(NewIcon)
					TextBoxItem:FindFirstChildOfClass("ImageLabel").Image = NewIcon
				end
				function TextBox:UpdatePlaceholderText(NewPlaceholderText)
					TextBoxInstance.PlaceholderText = NewPlaceholderText
				end
				function TextBox:SetValue(NewValue)
					TextBoxInstance.Text = NewValue

					Utility:CallCallback(Callback,NewValue)
				end
				function TextBox:GetValue()
					return TextBoxInstance.Text
				end

				local CallbackMode = Data.CallbackMode
				if CallbackMode == "OnEnterPressed" then
					TextBoxInstance.FocusLost:Connect(function(EnterPressed)
						if not EnterPressed then
							return
						end

						Utility:CallCallback(Callback,TextBoxInstance.Text)
						Changed:Fire(TextBoxInstance.Text)
					end)
					TextBoxInstance.ReturnPressedFromOnScreenKeyboard:Connect(function()
						Utility:CallCallback(Callback,TextBoxInstance.Text)
						Changed:Fire(TextBoxInstance.Text)
					end)
				elseif CallbackMode == "OnFocusLost" then
					TextBoxInstance.FocusLost:Connect(function()
						Utility:CallCallback(Callback,TextBoxInstance.Text)
						Changed:Fire(TextBoxInstance.Text)
					end)
				else
					TextBoxInstance:GetPropertyChangedSignal("Text"):Connect(function()
						Utility:CallCallback(Callback,TextBoxInstance.Text)
						Changed:Fire(TextBoxInstance.Text)
					end)
				end

				if OnDisplayDescription then
					OnDisplayDescription:Connect(function()
						DisplayDescription(Description)
					end)
				end

				TextBox:SetValue(Data.Value or "")
				return TextBox
			end
			function Section:NewColorPicker(Name,Description,Color,Callback,Data)
				local Changed = Instance.new("BindableEvent")
				Name = Name or "ColorPicker"
				Color = Color or Color3.new(1,1,1)
				Callback = Callback or function() end
				Data = Data or {}

				local h,s,v = 0,1,1

				local ColorPickerItem,OnDisplayDescription = CreateItem(Name,Data.Icon or "rbxassetid://9177457893",Description,"Item")
				local Input = Utility:AddItemButton(ColorPickerItem)
				local Preview = Instance.new("TextLabel")
				local ColorWheel = Instance.new("ImageButton")
				local ColorPickerImage = Instance.new("ImageLabel")
				local Value = Instance.new("TextButton")
				local ValueGradient = Instance.new("UIGradient")
				local ValueSlider = Instance.new("Frame")

				local ItemSize = ColorPickerItem.AbsoluteSize

				ColorPickerItem.LayoutOrder = #SectionHolder:GetChildren() - 1
				ColorPickerItem.Parent = SectionHolder

				Preview.AnchorPoint = Vector2.new(1,0.5)
				Preview.Position = UDim2.new(1,-36,0,ItemSize.Y/2)
				Preview.TextSize = 8
				Utility:Corner(Preview,UDim.new(1,0))
				Preview.Parent = ColorPickerItem

				ColorWheel.AutoButtonColor = false
				ColorWheel.BackgroundTransparency = 1
				ColorWheel.BorderSizePixel = 0
				ColorWheel.Position = UDim2.new(0,12,0,ItemSize.Y + 12)
				ColorWheel.Size = UDim2.new(0,128,0,128)
				ColorWheel.Image = "rbxassetid://6020299385"
				ColorWheel.Parent = ColorPickerItem

				ColorPickerImage.AnchorPoint = Vector2.new(0.5,0.5)
				ColorPickerImage.BackgroundTransparency = 1
				ColorPickerImage.BorderSizePixel = 0
				ColorPickerImage.Size = UDim2.new(0.09,0,0.09,0)
				ColorPickerImage.Image = "rbxassetid://3678860011"
				ColorPickerImage.Parent = ColorWheel

				Value.AutoButtonColor = false
				Value.BackgroundColor3 = Color3.new(1,1,1)
				Value.Position = UDim2.new(0,152,0,ItemSize.Y + 12)
				Value.Size = UDim2.new(0,30,0,128)
				Value.Text = ""
				Utility:Corner(Value,CornerSize)
				Value.Parent = ColorPickerItem

				ValueGradient.Rotation = 90
				ValueGradient.Parent = Value

				ValueSlider.AnchorPoint = Vector2.new(0.5,0.5)
				ValueSlider.Size = UDim2.new(1,6,0,6)
				Utility:Corner(ValueSlider,UDim.new(1,0))
				ApplyTheme(ValueSlider,"BackgroundColor3","Text")
				ValueSlider.Parent = Value

				local ColorPicker = {}
				ColorPicker.Changed = Changed.Event
				ColorPicker.Focused = false
				local function UpdatePreview()
					local Color = ColorPicker:GetColor()
					local Text = tostring(math.round(Color.R * 255))..", "..tostring(math.round(Color.G * 255))..", "..tostring(math.round(Color.B * 255))
					local TextSize = TextService:GetTextSize(Text,16,Enum.Font.SourceSans,Vector2.new(math.huge,math.huge))

					Preview.BackgroundColor3 = Color
					Preview.Size = UDim2.new(0,TextSize.X + 12,0,ItemSize.Y - 15)
					Preview.Text = Text
					Preview.TextColor3 = Utility:IsColorDark(Color) and Color3.new(1,1,1) or Color3.new(0,0,0)
				end
				local function UpdateColors()
					h = math.clamp((math.pi - math.atan2(ColorPickerImage.Position.Y.Offset - 64,ColorPickerImage.Position.X.Offset - 64)) / (math.pi * 2),0,1)
					s = math.clamp(math.abs((ColorPickerImage.AbsolutePosition - (ColorWheel.AbsolutePosition + Vector2.new(64,64))).Magnitude) / 64,0,1)
					v = math.clamp(1 - (ValueSlider.Position.Y.Offset / 128),0,1)

					UpdatePreview()
					if not ColorPicker.Focused then
						return
					end

					ValueGradient.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0,Color3.fromHSV(h,s,1)),
						ColorSequenceKeypoint.new(1,Color3.new(0,0,0))
					})
					Changed:Fire(Color3.fromHSV(h,s,1))

				end
				local function UpdatePickers()
					UpdatePreview()

					if not ColorPicker.Focused then
						return
					end

					local x = -math.cos(h * math.pi * 2) * s * 64
					local y = math.sin(h * math.pi * 2) * s * 64
					ColorPickerImage.Position = UDim2.new(0,x + 64,0,y + 64)

					ValueSlider.Position = UDim2.new(0.5,0,0,(1 - v) * 128)
					ValueGradient.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0,Color3.fromHSV(h,s,1)),
						ColorSequenceKeypoint.new(1,Color3.new(0,0,0))
					})
				end
				function ColorPicker:UpdateName(NewName)
					ColorPickerItem:FindFirstChildOfClass("TextLabel").Text = NewName
				end
				function ColorPicker:UpdateIcon(NewIcon)
					ColorPickerItem:FindFirstChildOfClass("ImageLabel").Image = NewIcon
				end
				function ColorPicker:SetFocused(Focused)
					if ColorPicker.Focused == Focused then
						return
					end
					ColorPicker.Focused = Focused

					UpdatePickers()
					Utility:Tween(ColorPickerItem,TweenInfo.new(0.2,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{
						Size = UDim2.new(1,0,0,ItemSize.Y + (Focused and 152 or 0))
					})
				end
				function ColorPicker:ToggleFocused()
					return ColorPicker:SetFocused(not ColorPicker.Focused)
				end
				function ColorPicker:SetColor(Color)
					h,s,v = Color:ToHSV()

					UpdatePickers()
					Utility:CallCallback(Callback,ColorPicker:GetColor())
				end
				function ColorPicker:GetColor()
					return Color3.fromHSV(h,s,v)
				end

				Input.MouseButton1Down:Connect(function()
					ColorPicker:ToggleFocused()
					Utility:Ripple(ColorPickerItem,Vector2.new(Mouse.X,Mouse.Y),CurrentTheme)
				end)
				ColorWheel.MouseButton1Down:Connect(function()
					local MouseMove
					local MouseUp

					local function Update()
						local ValueX = Mouse.X - ColorWheel.AbsolutePosition.X
						local ValueY = Mouse.Y - ColorWheel.AbsolutePosition.Y
						if (Vector2.new(ValueX,ValueY) - Vector2.new(64,64)).Magnitude > 64 then
							return
						end

						ColorPickerImage.Position = UDim2.new(0,ValueX,0,ValueY)
						UpdateColors()
						Utility:CallCallback(Callback,ColorPicker:GetColor())
					end

					MouseMove = Mouse.Move:Connect(Update)
					MouseUp = UIS.InputEnded:Connect(function(Input)
						if Input.UserInputType == Enum.UserInputType.MouseButton1 then
							MouseMove:Disconnect()
							MouseUp:Disconnect()

							Update()
						end
					end)

					Update()
				end)
				Value.MouseButton1Down:Connect(function()
					local MouseMove
					local MouseUp

					local function Update()
						local Value = Mouse.Y - Value.AbsolutePosition.Y
						if Value < 0 or Value > 128 then
							return
						end

						ValueSlider.Position = UDim2.new(0.5,0,0,Value)
						UpdateColors()
						Utility:CallCallback(Callback,ColorPicker:GetColor())
					end

					MouseMove = Mouse.Move:Connect(Update)
					MouseUp = UIS.InputEnded:Connect(function(Input)
						if Input.UserInputType == Enum.UserInputType.MouseButton1 then
							MouseMove:Disconnect()
							MouseUp:Disconnect()

							Update()
						end
					end)

					Update()
				end)

				if OnDisplayDescription then
					OnDisplayDescription:Connect(function()
						DisplayDescription(Description)
					end)
				end

				ColorPicker:SetColor(Color)
				return ColorPicker
			end
			function Section:NewDropdown(Name,Description,List,Callback,Data)
				Name = Name or "Dropdown"
				Data = Data or {}

				local Selectable = Data.Selectable or false
				local Selected = Selectable and Data.Selected
				local ButtonEvents = {}

				local DropdownItem,OnDisplayDescription = CreateItem(Name..(Selectable and " / "..tostring(Selected) or ""),Data.Icon or "rbxassetid://9185263957",Description,"Item")
				local Input = Utility:AddItemButton(DropdownItem)
				local Arrow = Instance.new("ImageLabel")
				local Holder = Instance.new("Frame")
				local UIList = Instance.new("UIListLayout")

				local ItemSize = DropdownItem.AbsoluteSize

				DropdownItem.LayoutOrder = #SectionHolder:GetChildren() - 1
				DropdownItem.Parent = SectionHolder

				Arrow.AnchorPoint = Vector2.new(1,0.5)
				Arrow.BackgroundTransparency = 1
				Arrow.BorderSizePixel = 0
				Arrow.Position = UDim2.new(1,-36,0,DropdownItem.AbsoluteSize.Y/2)
				Arrow.Size = UDim2.new(1,-15,0,DropdownItem.AbsoluteSize.Y - 15)
				Arrow.Image = "rbxassetid://9177111416"
				Instance.new("UIAspectRatioConstraint",Arrow)
				Arrow.Parent = DropdownItem

				Holder.AnchorPoint = Vector2.new(0.5,0)
				Holder.BackgroundTransparency = 1
				Holder.Position = UDim2.new(0.5,0,0,ItemSize.Y + 12)
				Holder.ClipsDescendants = true
				Holder.Parent = DropdownItem

				UIList.Padding = UDim.new(0,8)
				UIList.FillDirection = Enum.FillDirection.Vertical
				UIList.SortOrder = Data.SortOrder or Enum.SortOrder.LayoutOrder
				UIList.Parent = Holder

				local Dropdown = {}
				Dropdown.Focused = false
				function Dropdown:UpdateName(NewName)
					Name = NewName
					DropdownItem:FindFirstChildOfClass("TextLabel").Text = NewName..(Selectable and " / "..tostring(Selected) or "")
				end
				function Dropdown:UpdateIcon(NewIcon)
					DropdownItem:FindFirstChildOfClass("ImageLabel").Image = NewIcon
				end
				function Dropdown:SetFocused(Focused)
					if Dropdown.Focused == Focused then
						return
					end
					Dropdown.Focused = Focused

					Arrow.Rotation = Focused and 180 or 0
					Utility:Tween(DropdownItem,TweenInfo.new(0.2,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{
						Size = UDim2.new(1,0,0,ItemSize.Y + (Focused and (Holder.AbsoluteSize.Y + 24) or 0))
					})
				end
				function Dropdown:ToggleFocused()
					return Dropdown:SetFocused(not Dropdown.Focused)
				end
				function Dropdown:Refresh(List)
					for _,Event in ipairs(ButtonEvents) do
						Event:Disconnect()
					end
					table.clear(ButtonEvents)

					for _,Item in ipairs(Holder:GetChildren()) do
						if not Item:IsA("UIListLayout") then
							Item:Destroy()
						end
					end

					for Index,ItemName in ipairs(List) do
						local Button = Instance.new("TextButton")
						Button.Name = ItemName
						Button.AutoButtonColor = false
						Button.BackgroundTransparency = First and 0 or 1
						Button.LayoutOrder = #Holder:GetChildren() - 1
						Button.Size = UDim2.new(1,0,0,30)
						Button.ClipsDescendants = true
						Button.Font = Enum.Font.SourceSans
						Button.Text = ItemName
						Button.TextScaled = false
						Button.TextSize = 16
						Button.TextWrapped = true
						Utility:Corner(Button,CornerSize)
						ApplyTheme(Button,"BackgroundColor3","Scheme")
						ApplyTheme(Button,"TextColor3","Text")
						Button.Parent = Holder

						table.insert(ButtonEvents,Button.MouseButton1Down:Connect(function()
							Utility:Ripple(Button,Vector2.new(Mouse.X,Mouse.Y),Utility:EditThemeStyle(CurrentTheme,"Scheme",Utility:IsColorDark(CurrentTheme.Scheme) and Color3.new(1,1,1) or Color3.new(0,0,0)))

							if Selectable then
								Selected = ItemName
								Dropdown:SetFocused(false)
								DropdownItem:FindFirstChildOfClass("TextLabel").Text = Name.." / "..tostring(ItemName)
							end

							Utility:CallCallback(Callback,ItemName)
						end))
					end

					Holder.Size = UDim2.new(1,-24,0,UIList.AbsoluteContentSize.Y)
				end
				if Selectable then
					function Dropdown:GetSelected()
						return Selected
					end
				end

				Input.MouseButton1Down:Connect(function()
					Dropdown:ToggleFocused()
					Utility:Ripple(DropdownItem,Vector2.new(Mouse.X,Mouse.Y),CurrentTheme)
				end)

				if OnDisplayDescription then
					OnDisplayDescription:Connect(function()
						DisplayDescription(Description)
					end)
				end

				Dropdown:Refresh(List)
				return Dropdown
			end

			if OnDisplayDescription then
				OnDisplayDescription:Connect(function()
					DisplayDescription(Description)
				end)
			end

			Utility:SyncSize(SectionHolder,SectionUIList)
			return Section
		end

		TabButton.MouseButton1Click:Connect(function()
			if SelectedTab ~= Name then
				SelectedTab = Name

				for _,Tab in ipairs(Tabs:GetChildren()) do
					if Tab:IsA("TextButton") then
						Utility:Tween(Tab,TweenInfo.new(0.2,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{BackgroundTransparency = Tab == TabButton and 0 or 1})
					end
				end
				for _,TabContent in ipairs(Content:GetChildren()) do
					if TabContent:IsA("ScrollingFrame") then
						TabContent.Visible = TabContent == ContentList and true or false
					end
				end
			end
		end)

		Utility:SyncCanvasSize(ContentList,ContentUIList)

		return Tab
	end
	function Lib:UpdateThemeColor(Style,Color)
		assert(CurrentTheme[Style] ~= nil,"Style "..tostring(Style).." does not exist.")

		CurrentTheme[Style] = Color
		Utility:UpdateThemeColor(CurrentTheme,Style)
	end
	function Lib:Hint(...)
		return DisplayDescription(...)
	end

	CloseButton.MouseButton1Click:Connect(function()
		OnClose:Fire()
		Gui:Destroy()
	end)

	Utility:SyncCanvasSize(Tabs,TabsUIList)
	Lib:EnableUI(true)
	return Lib
end

return UI
