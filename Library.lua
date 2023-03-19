local Player = game:GetService("Players").LocalPlayer

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = RunService:IsStudio() and Player.PlayerGui or game:GetService("CoreGui")
local Debris = game:GetService("Debris")

local function RandomString()
	local str = ""
	
	for i = 1, math.random(28, 36) do
		str = str .. string.char(math.random(28, 128))
	end
	
	return str
end

local function GetTextBounds(text)
	local params = Instance.new("GetTextBoundsParams")
	params.Size = 14
	params.Width = math.huge
	params.Font = Font.fromEnum(Enum.Font.SourceSans)
	params.Text = text
	
	return TextService:GetTextBoundsAsync(params)
end

local function Spawner(callback, ...)
	return coroutine.wrap(callback)(...)
end

local configBase = {}
configBase.__index = configBase

local windowC = {}
windowC.BaseSize = UDim2.new(0, 600, 0, 350)
windowC.ComponentDragging = false

function windowC.new(title: string, toggleKeybind: Enum.KeyCode, animate: boolean?)
	-- Base Gui --
	
	local Gui = Instance.new("ScreenGui")
	local Main = Instance.new("Frame")
	local Title = Instance.new("TextLabel")
	local UIPadding = Instance.new("UIPadding")
	local TabScroll = Instance.new("ScrollingFrame")
	local UIListLayout = Instance.new("UIListLayout")
	local TabItems = Instance.new("Frame")
	local Padding = Instance.new("UIPadding")
	local Scale = Instance.new("UIScale")
	
	local seed = 0
	
	for i, byte in pairs({string.byte(title, 1, title:len())}) do
		seed += byte
	end
	
	math.randomseed(seed)
	
	Gui.Name = RandomString()
	Gui.Parent = CoreGui
	Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	Gui.DisplayOrder = 16^6
	Gui.ResetOnSpawn = false

	Main.Name = "Main"
	Main.Parent = Gui
	Main.AnchorPoint = Vector2.new(0.5, 0.5)
	Main.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	Main.BorderSizePixel = 0
	Main.Position = UDim2.new(0.5, 0, 0.5, 0)
	Main.Size = UDim2.new(0, 1, 0, 1)
	Main.ClipsDescendants = true

	Title.Name = "Title"
	Title.Parent = Main
	Title.BackgroundColor3 = Color3.fromRGB(57, 57, 57)
	Title.BorderSizePixel = 0
	Title.Size = UDim2.new(1, 0, 0, 17)
	Title.Font = Enum.Font.Code
	Title.Text = title
	Title.TextColor3 = Color3.fromRGB(255, 255, 255)
	Title.TextSize = 16.000
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.TextYAlignment = Enum.TextYAlignment.Top

	UIPadding.Parent = Title
	UIPadding.PaddingLeft = UDim.new(0, 2)

	TabScroll.Name = "TabScroll"
	TabScroll.Parent = Main
	TabScroll.Active = true
	TabScroll.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
	TabScroll.BorderSizePixel = 0
	TabScroll.Position = UDim2.new(0, 0, 0, 17)
	TabScroll.Size = UDim2.new(1, 0, 0, 17)
	TabScroll.CanvasSize = UDim2.new(1, 0, 0, 0)
	TabScroll.ScrollBarThickness = 0

	UIListLayout.Parent = TabScroll
	UIListLayout.FillDirection = Enum.FillDirection.Horizontal
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout.Padding = UDim.new(0, 3)

	TabItems.Name = "TabItems"
	TabItems.Parent = Main
	TabItems.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	TabItems.BackgroundTransparency = 1.000
	TabItems.Position = UDim2.new(0, 0, 0, 34)
	TabItems.Size = UDim2.new(1, 0, 1, -34)

	Padding.Name = "Padding"
	Padding.Parent = TabItems
	Padding.PaddingBottom = UDim.new(0, 5)
	Padding.PaddingLeft = UDim.new(0, 4)
	Padding.PaddingRight = UDim.new(0, 4)
	Padding.PaddingTop = UDim.new(0, 5)
	
	Scale.Name = "Scale"
	Scale.Parent = Main
	Scale.Scale = 1
	
	if animate then
		Spawner(function()
			TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut), {Size = UDim2.new(0, 1, 0, windowC.BaseSize.Y.Offset)}):Play()
			task.wait(0.5)
			TweenService:Create(Main, TweenInfo.new(0.7, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut), {Size = windowC.BaseSize}):Play()
		end)
	else
		Main.Size = windowC.BaseSize
	end
	
	local window = {}
	window.Menu = Gui
	window.Tabs = {}
	window.Dragging = false
	window.WindowDragStart = Main.Position
	window.WindowScaleStart = Scale.Scale
	window.MouseDragStart = Vector2.zero
	window.DragConnection = RunService.RenderStepped:Connect(function(dt)
		if window.Dragging and not windowC.ComponentDragging then
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
				-- adjust scale
				local mousePos = UserInputService:GetMouseLocation()
				local scale = (mousePos.X - window.MouseDragStart.X) / 1000 + window.WindowScaleStart
				
				Scale.Scale = scale
			else
				local delta = UserInputService:GetMouseLocation() - window.MouseDragStart
				TweenService:Create(Main, TweenInfo.new(0.1, Enum.EasingStyle.Quint), {Position = window.WindowDragStart + UDim2.fromOffset(delta.X, delta.Y)}):Play()
			end
		end
	end)
	
	Main.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			window.WindowDragStart = Main.Position
			window.MouseDragStart = UserInputService:GetMouseLocation()
			window.WindowScaleStart = Scale.Scale
			window.Dragging = true
		end
	end)
	
	Main.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			window.Dragging = false
		end
	end)
	
	function window:AddTab(name: string)
		local TabButton = Instance.new("TextButton")
		local TabMenu = Instance.new("Frame")
		
		TabButton.Parent = TabScroll
		TabButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
		TabButton.BorderSizePixel = 0
		TabButton.Size = UDim2.new(0, 0, 1, 0)
		TabButton.ClipsDescendants = true
		TabButton.AutoButtonColor = false
		TabButton.LayoutOrder = #window.Tabs
		TabButton.Font = Enum.Font.SourceSans
		TabButton.Text = name
		TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		TabButton.TextSize = 14.000

		TabMenu.Name = name
		TabMenu.Parent = TabItems
		TabMenu.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		TabMenu.BackgroundTransparency = 1.000
		TabMenu.BorderSizePixel = 0
		TabMenu.Size = UDim2.new(1, 0, 1, 0)
		
		Spawner(function() -- animate
			task.wait(#window.Tabs * 0.05)
			
			local animation = TweenService:Create(TabButton, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {Size = UDim2.new(0, GetTextBounds(name).X + 10, 1, 0)})
			animation:Play()
			
			animation.Completed:Connect(function()
				TabScroll.CanvasSize = UDim2.fromOffset(UIListLayout.AbsoluteContentSize.X, 0)
			end)
		end)
		
		local self = setmetatable({}, configBase)
		self.Menu = TabMenu
		self.Elements = {}
		self.Selected = false
		self.Sectioned = false
		
		function self:Select()
			self.Selected = true
			TabMenu.Visible = true
			Title.Text = string.format("%s - %s", title, name)
			
			TweenService:Create(TabButton, TweenInfo.new(0.1, Enum.EasingStyle.Quint), {BackgroundColor3 = Main.BackgroundColor3}):Play()
			
			for i, otab in pairs(window.Tabs) do
				if otab ~= self then
					otab:Deselect()
				end
			end
		end
		
		function self:Deselect()
			self.Selected = false
			TabMenu.Visible = false
			
			TweenService:Create(TabButton, TweenInfo.new(0.1, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(45, 45, 45)}):Play()
		end
		
		TabButton.MouseEnter:Connect(function() -- enter
			TweenService:Create(TabButton, TweenInfo.new(0.1, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.new(0.309804, 0.309804, 0.309804)}):Play()
		end)
		
		TabButton.MouseLeave:Connect(function()
			TweenService:Create(TabButton, TweenInfo.new(0.1, Enum.EasingStyle.Quint), {BackgroundColor3 = self.Selected and Main.BackgroundColor3 or Color3.fromRGB(45, 45, 45)}):Play()
		end)
		
		TabButton.MouseButton1Click:Connect(function()
			self:Select()
		end)
		
		-- select first tab
		
		if #window.Tabs == 0 then
			self:Select()
		end
		
		table.insert(window.Tabs, self)
		
		return self
	end
	
	function window:Destroy()
		Debris:AddItem(Gui, 0)
		window.DragConnection:Disconnect()
	end
	
	return window
end

function configBase:AddButton(text: string, callback: () -> nil)
	local Button = Instance.new("TextButton")
	local Corner = Instance.new("UICorner")
	local Stroke = Instance.new("UIStroke")

	Button.Name = "Button"
	Button.Parent = self.Menu
	Button.BackgroundColor3 = Color3.fromRGB(58, 58, 58)
	Button.Size = UDim2.new(1, 0, 0, 20)
	Button.Font = Enum.Font.SourceSans
	Button.Text = text
	Button.TextColor3 = Color3.fromRGB(235, 235, 235)
	Button.TextSize = 17.000
	Button.TextWrapped = true

	Corner.CornerRadius = UDim.new(0, 2)
	Corner.Name = "Corner"
	Corner.Parent = Button

	Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	Stroke.Color = Color3.fromRGB(235, 235, 235)
	Stroke.Transparency = 0.45
	Stroke.Name = "Stroke"
	Stroke.Parent = Button

	Button.MouseButton1Click:Connect(function()
		pcall(callback)
	end)
	
	local button = {}
	button.Menu = Button
	
	table.insert(self.Elements, button)
	
	return button
end

function configBase:AddSlider(name: string, min: number, max: number, default: number, callback: (number) -> nil)
	local Slider = Instance.new("Frame")
	local Stroke = Instance.new("UIStroke")
	local Corner = Instance.new("UICorner")
	local Label = Instance.new("TextLabel")
	local Slide = Instance.new("Frame")

	Slider.Name = "Slider"
	Slider.Parent = self.Menu
	Slider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	Slider.ClipsDescendants = true
	Slider.Size = UDim2.new(1, 0, 0, 20)

	Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	Stroke.Color = Color3.fromRGB(235, 235, 235)
	Stroke.Transparency = 0.45
	Stroke.Name = "Stroke"
	Stroke.Parent = Slider

	Corner.CornerRadius = UDim.new(0, 2)
	Corner.Name = "Corner"
	Corner.Parent = Slider
	
	Label.Name = "Label"
	Label.Parent = Slider
	Label.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Label.BackgroundTransparency = 1.000
	Label.Size = UDim2.new(1, 0, 1, 0)
	Label.Font = Enum.Font.SourceSans
	Label.Text = string.format("%s - %.2f", name, default or min)
	Label.TextColor3 = Color3.fromRGB(255, 255, 255)
	Label.TextSize = 17.000
	Label.TextWrapped = true
	
	Slide.Name = "Slide"
	Slide.Parent = Slider
	Slide.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
	Slide.BorderSizePixel = 0
	Slide.Size = UDim2.new((default or min) / max, 0, 1, 0)
	Slide.ZIndex = -2

	local connection = nil
	
	local slider = {}
	slider.Menu = Slider
	slider.Value = default or min
	
	Slider.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			windowC.ComponentDragging = true
			
			connection = RunService.RenderStepped:Connect(function(dt)
				local position = UserInputService:GetMouseLocation()
				local delta = math.clamp((position.X - Slider.AbsolutePosition.X) / Slider.AbsoluteSize.X, 0, 1)
				
				slider.Value = min + (max - min) * delta
				
				TweenService:Create(Slide, TweenInfo.new(0.1, Enum.EasingStyle.Quart), {Size = UDim2.new(delta, 0, 1, 0)}):Play()
				Label.Text = string.format("%s - %.2f", name, min + (max - min) * Slide.Size.X.Scale) -- it looks cooler ok
				
				pcall(callback, slider.Value)
			end)
		end
	end)
	
	Slider.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			windowC.ComponentDragging = false
			
			connection:Disconnect()
		end
	end)
	
	table.insert(self.Elements, slider)
	
	return slider
end

function configBase:AddToggle(name: string, default: boolean, callback: (boolean) -> nil)
	local Toggle = Instance.new("Frame")
	local Label = Instance.new("TextLabel")
	local Display = Instance.new("Frame")
	local Padding = Instance.new("UIPadding")
	local Button = Instance.new("TextButton")
	
	Toggle.Name = "Toggle"
	Toggle.Parent = self.Menu
	Toggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	Toggle.BackgroundTransparency = 1.000
	Toggle.ClipsDescendants = true
	Toggle.Size = UDim2.new(1, 0, 0, 20)
	
	Label.Name = "Label"
	Label.Parent = Toggle
	Label.AnchorPoint = Vector2.new(1, 0)
	Label.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Label.BackgroundTransparency = 1.000
	Label.Position = UDim2.new(1, 0, 0, 0)
	Label.Size = UDim2.new(1, -15, 1, 0)
	Label.Font = Enum.Font.Code
	Label.Text = name
	Label.TextColor3 = Color3.fromRGB(255, 255, 255)
	Label.TextSize = 14.000
	Label.TextWrapped = true
	Label.TextXAlignment = Enum.TextXAlignment.Left
	
	Display.Name = "Display"
	Display.Parent = Toggle
	Display.AnchorPoint = Vector2.new(0, 0.5)
	Display.BackgroundColor3 = (default and Color3.fromRGB(101, 119, 240) or Color3.fromRGB(58, 58, 58))
	Display.BorderColor3 = Color3.fromRGB(30, 30, 30)
	Display.BorderSizePixel = 1
	Display.Position = UDim2.new(0, 0, 0.5, 0)
	Display.Size = UDim2.new(0, 10, 0, 10)
	
	Padding.Name = "Padding"
	Padding.Parent = Toggle
	Padding.PaddingLeft = UDim.new(0, 4)
	
	Button.Name = "Button"
	Button.Parent = Toggle
	Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Button.BackgroundTransparency = 1.000
	Button.BorderSizePixel = 0
	Button.Size = UDim2.new(1, 0, 1, 0)
	Button.ZIndex = 3
	Button.AutoButtonColor = false
	Button.Font = Enum.Font.SourceSans
	Button.Text = ""
	Button.TextColor3 = Color3.fromRGB(0, 0, 0)
	Button.TextSize = 1.000
	
	local toggle = {}
	toggle.Menu = Toggle
	toggle.Value = default or false
	
	Button.MouseButton1Click:Connect(function()
		toggle.Value = not toggle.Value
		
		TweenService:Create(Display, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundColor3 = (toggle.Value and Color3.fromRGB(101, 119, 240) or Color3.fromRGB(58, 58, 58))}):Play()
		
		pcall(callback, toggle.Value)
	end)
	
	table.insert(self.Elements, toggle)
	
	
	return toggle
end

function configBase:AddTextbox(name: string, callback: (string) -> nil)
	local Textbox = Instance.new("Frame")
	local Corner = Instance.new("UICorner")
	local Stroke = Instance.new("UIStroke")
	local TextBox = Instance.new("TextBox")

	Textbox.Name = "Textbox"
	Textbox.Parent = self.Menu
	Textbox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	Textbox.ClipsDescendants = true
	Textbox.Size = UDim2.new(1, 0, 0, 20)

	Corner.CornerRadius = UDim.new(0, 2)
	Corner.Name = "Corner"
	Corner.Parent = Textbox

	Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	Stroke.Color = Color3.fromRGB(235, 235, 235)
	Stroke.Transparency = 0.45
	Stroke.Name = "Stroke"
	Stroke.Parent = Textbox

	TextBox.Parent = Textbox
	TextBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	TextBox.BackgroundTransparency = 1.000
	TextBox.Size = UDim2.new(1, 0, 1, 0)
	TextBox.Font = Enum.Font.SourceSans
	TextBox.PlaceholderText = name
	TextBox.Text = ""
	TextBox.TextColor3 = Color3.fromRGB(243, 243, 243)
	TextBox.TextSize = 14.000
	
	local textbox = {}
	textbox.Menu = Textbox
	textbox.Value = ""
	
	TextBox.FocusLost:Connect(function()
		textbox.Value = TextBox.Text
		
		pcall(callback, textbox.Value)
	end)
	
	table.insert(self.Elements, textbox)
	
	return textbox
end

function configBase:InsertCustomGui(gui: GuiBase) -- basically the same as reparenting straight to self.Menu
	gui.Parent = self.Menu
	
	local connection
	connection = gui:GetPropertyChangedSignal("Parent"):Connect(function()
		connection:Disconnect()
		
		table.remove(self.Elements, table.find(self.Elements, gui))
	end)
	
	table.insert(self.Elements, gui)
end

function configBase:AddSection(name: string, position: UDim2, size: UDim2)
	if not (self.Sectioned == false and #self.Elements > 0) then
		self.Sectioned = true
		
		local SectionMenu = Instance.new("Frame")
		local Title = Instance.new("TextLabel")
		local Items = Instance.new("Frame")
		local List = Instance.new("UIListLayout")
		local Padding = Instance.new("UIPadding")

		SectionMenu.Name = "Section"
		SectionMenu.Parent = self.Menu
		SectionMenu.BackgroundColor3 = Color3.fromRGB(62, 62, 62)
		SectionMenu.BorderColor3 = Color3.fromRGB(46, 46, 46)
		SectionMenu.BorderSizePixel = 2
		SectionMenu.ClipsDescendants = true
		SectionMenu.Size = size or UDim2.new(0, 100, 0, 100)
		SectionMenu.Position = position or UDim2.new(0, 0, 0, 0)

		Title.Name = "Title"
		Title.Parent = SectionMenu
		Title.AnchorPoint = Vector2.new(0.5, 0)
		Title.BackgroundColor3 = Color3.fromRGB(62, 62, 62)
		Title.BorderSizePixel = 0
		Title.Position = UDim2.new(0.5, 0, 0, 0)
		Title.Size = UDim2.new(0, 50, 0, 15)
		Title.Font = Enum.Font.SourceSans
		Title.Text = name
		Title.TextColor3 = Color3.fromRGB(255, 255, 255)
		Title.TextSize = 16.000

		Items.Name = "Items"
		Items.Parent = SectionMenu
		Items.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Items.BackgroundTransparency = 1.000
		Items.Position = UDim2.new(0, 0, 0, 15)
		Items.Size = UDim2.new(1, 0, 1, -15)

		List.Name = "List"
		List.Parent = Items
		List.SortOrder = Enum.SortOrder.LayoutOrder
		List.Padding = UDim.new(0, 5)

		Padding.Name = "Padding"
		Padding.Parent = Items
		Padding.PaddingBottom = UDim.new(0, 3)
		Padding.PaddingLeft = UDim.new(0, 3)
		Padding.PaddingRight = UDim.new(0, 3)
		Padding.PaddingTop = UDim.new(0, 3)
		
		local section = setmetatable({}, configBase)
		section.Elements = {}
		section.Menu = Items
		
		table.insert(self.Elements, section)
		
		return section
	else
		error("Can't have section and non-section elements in the same tab.")
	end
end

return windowC
