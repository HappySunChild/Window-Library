local Player = game:GetService("Players").LocalPlayer

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = RunService:IsStudio() and Player.PlayerGui or game:GetService("CoreGui")

local function RandomString()
	local str = ""

	for i = 1, math.random(28, 36) do
		str = str .. string.char(math.random(28, 128))
	end

	return str
end

local function GetSeed(str)
	local seed = 0

	for i, byte in pairs({string.byte(str, 1, -1)}) do
		seed += byte * i
	end

	return seed
end

local function GetTextBounds(text, options)
	local params = Instance.new("GetTextBoundsParams")
	params.Size = options.Size
	params.Width = options.Width or math.huge
	params.Font = options.Font
	params.Text = text

	return TextService:GetTextBoundsAsync(params)
end

local function lerp(a, b, t)
	return a + (b - a) * t
end

local function totext(value)
	if typeof(value) == "Instance" then
		return value:GetFullName()
	end

	return tostring(value)
end

local function GetBrightness(color)
	local _, _, brightness = color:ToHSV()

	return brightness
end

local function SubtractColors(colorA, colorB)
	return Color3.new(math.clamp(colorA.R - colorB.R, 0, 1), math.clamp(colorA.G - colorB.G, 0, 1), math.clamp(colorA.B - colorB.B, 0, 1))
end

local creator = {}
creator.Instances = {}
creator.Connections = {}
creator.BorderId = "rbxassetid://2592362371"

function creator:Clear()
	for _, connection in pairs(creator.Connections) do
		connection:Disconnect()
	end

	for _, instance in pairs(creator.Instances) do
		instance:Destroy()
	end

	creator.Instances = {}
	creator.Connections = {}
end

function creator:Create(class, properties)
	properties = properties or {}

	local instance = Instance.new(class)
	for p, value in pairs(properties) do
		instance[p] = value
	end

	table.insert(creator.Instances, instance)

	return instance
end

function creator:Connect(event, callback)
	table.insert(creator.Connections, event:Connect(callback))
end

function creator:Hover(guiobject, arguments)
	arguments = arguments or {}

	local property = arguments.Property or "BorderColor3"
	local hover = arguments.Hover or guiobject
	local defaultColor = arguments.DefaultColor or guiobject[property]
	local hoverColor = arguments.HoverColor

	creator:Connect(hover.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			TweenService:Create(guiobject, TweenInfo.new(0.1), {[property] = hoverColor}):Play()
		end
	end)

	creator:Connect(hover.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			TweenService:Create(guiobject, TweenInfo.new(0.1), {[property] = defaultColor}):Play()
		end
	end)
end

function creator:Border(guiobject)
	local border1 = creator:Create("ImageLabel", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Image = creator.BorderId,
		ImageColor3 = Color3.fromRGB(60, 60, 60),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(2, 2, 62, 62),
		Name = "Border",
		Parent = guiobject
	})

	local border2 = creator:Create("ImageLabel", {
		Size = UDim2.new(1, -2, 1, -2),
		Position = UDim2.fromOffset(1, 1),
		BackgroundTransparency = 1,
		Image = creator.BorderId,
		ImageColor3 = Color3.new(0, 0, 0),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(2, 2, 62, 62),
		Name = "Border",
		Parent = guiobject
	})

	return border1, border2
end

local base = {}
base.__index = base
base.IsSection = false
base.Elements = {}
base.Menu = nil
base.Items = nil

local element = {}
element.__index = element
element.Type = ""
element.Value = nil
element.Element = nil
element.Menu = nil

local library = {}
library.BaseSize = UDim2.new(0, 600, 0, 400)
library.ComponentDragging = false
library.AspectRatio = 1.5
library.Colors = {
	Theme = Color3.new(0.113725, 0.721568, 1),
	Background = Color3.fromRGB(10, 10, 10),
	Main = Color3.fromRGB(30, 30, 30)
}
library.Theme = {}
library.Creator = creator
library.Base = nil
library.Slider = nil

-- ELEMENTS --

function base:AddSection(name, position, size)
	if self.IsSection then
		warn("Can't have sections within sections.")
		return self
	end

	local menu = creator:Create("Frame", {
		BackgroundColor3 = library.Colors.Main,
		BorderColor3 = Color3.new(0, 0, 0),
		Position = position or UDim2.fromOffset(0, 0),
		Size = size or UDim2.fromOffset(100, 100),
		Parent = self.Items
	})

	local items = creator:Create("ScrollingFrame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, -6),
		Position = UDim2.fromOffset(0, 6),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ScrollBarThickness = 2,
		Parent = menu
	})

	local layout = creator:Create("UIListLayout", {
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 2),
		Parent = items
	})

	creator:Create("TextLabel", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 12, 0, 0),
		Size = UDim2.new(0, GetTextBounds(name, {Font = Font.fromEnum(Enum.Font.Code), Size = 15}).X + 5, 0, 3),
		BackgroundColor3 = library.Colors.Main, 
		BorderSizePixel = 0,
		Text = name,
		TextSize = 15,
		Font = Enum.Font.Code,
		TextColor3 = Color3.new(1, 1, 1),
		ZIndex = 5,
		Parent = menu
	})

	creator:Connect(layout.Changed, function()
		items.CanvasSize = UDim2.new(1, 0, 0, layout.AbsoluteContentSize.Y)
	end)

	creator:Border(menu)

	local section = setmetatable({}, base)
	section.IsSection = true
	section.Menu = menu
	section.Items = items

	return section
end

function base:AddToggle(name, default, callback)
	if not self.IsSection then
		return
	end

	local main = creator:Create("Frame", {
		LayoutOrder = #self.Elements + 1,
		Size = UDim2.new(1, 0, 0, 20),
		BackgroundTransparency = 1,
		Parent = self.Items
	})

	local tickbox = creator:Create("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 6, 0.5, 0),
		Size = UDim2.fromOffset(12, 12),
		BackgroundColor3 = default and library.Colors.Theme or library.Colors.Main,
		BorderColor3 = Color3.new(0, 0, 0),
		Parent = main
	})

	local title = creator:Create("TextLabel", {
		Position = UDim2.fromOffset(24, 0),
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = name,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextSize = 15,
		TextColor3 = default and Color3.fromRGB(235, 235, 235) or Color3.fromRGB(160, 160, 160),
		Font = Enum.Font.Code,
		Parent = main
	})

	local button = creator:Create("TextButton", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = "",
		Parent = main
	})

	creator:Border(tickbox)
	creator:Hover(tickbox, {Hover = button, HoverColor = library.Colors.Theme})

	local toggle = setmetatable({}, element)
	toggle.Element = button
	toggle.Menu = main
	toggle.Value = default or false
	toggle.Type = "Toggle"

	creator:Connect(button.MouseButton1Click, function()
		toggle.Value = not toggle.Value
		
		TweenService:Create(tickbox, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {BackgroundColor3 = toggle.Value and library.Colors.Theme or library.Colors.Main}):Play()

		if toggle.Value then
			table.insert(library.Theme, tickbox)
		else
			table.remove(library.Theme, table.find(library.Theme, tickbox))
		end

		if callback then
			pcall(callback, toggle.Value)
		end
	end)

	table.insert(self.Elements, toggle)

	return toggle
end

function base:AddDivider(text)
	if not self.IsSection then
		return
	end

	local main = creator:Create("Frame", {
		LayoutOrder = #self.Elements + 1,
		Size = UDim2.new(1, 0, 0, 18),
		BackgroundTransparency = 1,
		Parent = self.Items
	})

	creator:Create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(1, -14, 0, 1),
		BackgroundColor3 = Color3.fromRGB(167, 167, 167),
		BorderSizePixel = 0,
		Parent = main
	})

	creator:Create("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, GetTextBounds(text, {Font = Font.fromEnum(Enum.Font.Code), Size = 15}).X + 12, 0, 1),
		BackgroundColor3 = library.Colors.Main,
		BorderSizePixel = 0,
		TextColor3 = Color3.new(1, 1, 1),
		TextSize = 15,
		Font = Enum.Font.Code,
		Text = text,
		TextXAlignment = Enum.TextXAlignment.Center,
		Parent = main
	})

	local divider = setmetatable({}, element)
	divider.Element = main
	divider.Menu = main
	divider.Type = "Divider"

	table.insert(self.Elements, divider)

	return divider
end

function base:AddLabel(text)
	if not self.IsSection then
		return
	end

	local main = creator:Create("TextLabel", {
		LayoutOrder = #self.Elements + 1,
		Size = UDim2.new(1, 0, 0, 24),
		BackgroundTransparency = 1,
		TextSize = 15,
		Font = Enum.Font.Code,
		TextColor3 = Color3.new(1, 1, 1),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
		RichText = true,
		Parent = self.Items
	})

	creator:Create("UIPadding", {
		PaddingTop = UDim.new(0, 3),
		PaddingBottom = UDim.new(0, 3),
		PaddingLeft = UDim.new(0, 3),
		PaddingRight = UDim.new(0, 3),
		Parent = main
	})

	local labelElement = table.clone(element)
	labelElement.__newindex = function(t, index, value)
		if index:lower():match("text") then
			main.Text = tostring(value)
			main.Size = UDim2.new(1, 0, 0, GetTextBounds(main.Text, {Size = 15, Font = Font.fromEnum(Enum.Font.Code), Width = main.AbsoluteSize.X}).Y + 6)
		end
	end

	local label = setmetatable({}, labelElement)
	label.Element = main
	label.Menu = main
	label.Type = "Label"
	label.Text = text

	table.insert(self.Elements, label)

	return label
end

function base:AddButton(name, callback)
	if not self.IsSection then
		return
	end

	local main = creator:Create("Frame", {
		LayoutOrder = #self.Elements + 1,
		Size = UDim2.new(1, 0, 0, 28),
		BackgroundTransparency = 1,
		Parent = self.Items
	})

	local textbutton = creator:Create("TextButton", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(1, -12, 0, 20),
		BackgroundColor3 = library.Colors.Theme,
		BorderColor3 = Color3.new(0, 0, 0),
		Text = name,
		TextColor3 = GetBrightness(library.Colors.Theme) < 0.5 and Color3.new(1, 1, 1) or Color3.new(0, 0, 0),
		TextSize = 15,
		AutoButtonColor = false,
		Font = Enum.Font.Code,
		Parent = main
	})

	creator:Create("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(216, 216, 216)),
			ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
		}),
		Rotation = -90,
		Parent = textbutton
	})

	creator:Border(textbutton)
	creator:Hover(textbutton, {HoverColor = library.Colors.Theme})

	local button = setmetatable({}, element)
	button.Element = textbutton
	button.Menu = main
	button.Type = "Button"

	creator:Connect(textbutton.MouseButton1Click, function()
		coroutine.wrap(function()
			textbutton.BackgroundColor3 = SubtractColors(library.Colors.Theme, Color3.fromRGB(50, 50, 50))

			for _ = 1, 5 do
				RunService.RenderStepped:Wait()
			end

			textbutton.BackgroundColor3 = library.Colors.Theme
		end)()

		if callback then
			pcall(callback)
		end
	end)

	table.insert(library.Theme, textbutton)
end

function base:AddTextbox(name, callback)
	if not self.IsSection then
		return
	end

	local main = creator:Create("Frame", {
		LayoutOrder = #self.Elements + 1,
		Size = UDim2.new(1, 0, 0, name and 44 or 28),
		BackgroundTransparency = 1,
		Parent = self.Items
	})

	local holder = creator:Create("Frame", {
		Position = UDim2.fromOffset(6, name and 20 or 4),
		Size = UDim2.new(1, -12, 0, 20),
		BackgroundColor3 = SubtractColors(library.Colors.Main, Color3.fromRGB(-20, -20, -20)),
		BorderColor3 = Color3.new(0, 0, 0),
		Parent = main
	})

	local box = creator:Create("TextBox", {
		Position = UDim2.fromOffset(4, 0),
		Size = UDim2.new(1, -4, 1, 0),
		BackgroundTransparency = 1,
		TextSize = 15,
		Text = "",
		Font = Enum.Font.Code,
		TextColor3 = Color3.new(1, 1, 1),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
		ClearTextOnFocus = false,
		Parent = holder
	})

	creator:Create("UIPadding", {
		PaddingTop = UDim.new(0, 3),
		PaddingRight = UDim.new(0, 1),
		Parent = box
	})

	creator:Hover(holder, {HoverColor = library.Colors.Theme})
	creator:Border(holder)

	if name then
		creator:Create("TextLabel", {
			Position = UDim2.new(0, 6, 0, 0),
			Size = UDim2.new(1, -6, 0, 18),
			BackgroundTransparency = 1,
			Text = name,
			TextSize = 15,
			Font = Enum.Font.Code,
			TextColor3 = Color3.fromRGB(210, 210, 210),
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = main
		})
	end

	local textbox = setmetatable({}, element)
	textbox.Type = "Textbox"
	textbox.Element = box
	textbox.Menu = main
	textbox.Value = ""

	creator:Connect(box.FocusLost, function()
		TweenService:Create(holder, TweenInfo.new(0.1), {BorderColor3 = Color3.new(0, 0, 0)}):Play()
		textbox.Value = box.Text

		if callback then
			pcall(callback, textbox.Value)
		end
	end)

	creator:Connect(box:GetPropertyChangedSignal("Text"), function()
		local tSize = GetTextBounds(box.Text, {Size = 15, Font = Font.fromEnum(Enum.Font.Code), Width = box.AbsoluteSize.X - 1})

		main.Size = UDim2.new(1, 0, 0, (name and 44 or 28) + (tSize.Y - 15))
		holder.Size = UDim2.new(1, -12, 0, 20 + (tSize.Y - 15))
	end)

	return textbox
end

function base:AddSlider(name, default, min, max, callback)
	if not self.IsSection then
		return
	end

	local main = creator:Create("Frame", {
		LayoutOrder = #self.Elements + 1,
		Size = UDim2.new(1, -6, 0, 40),
		BackgroundTransparency = 1,
		Parent = self.Items
	})

	local sldr = creator:Create("Frame", {
		Position = UDim2.new(0, 6, 0, 20),
		Size = UDim2.new(1, -6, 0, 16),
		BackgroundColor3 = SubtractColors(library.Colors.Main, Color3.fromRGB(-20, -20, -20)),
		BorderColor3 = Color3.new(0, 0, 0),
		Parent = main
	})

	local fill = creator:Create("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = library.Colors.Theme,
		BorderSizePixel = 0,
		Parent = sldr,
	})

	creator:Create("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(115, 115, 115)),
			ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
		}),
		Rotation = -90,
		Parent = fill
	})

	table.insert(library.Theme, fill)

	local title = creator:Create("TextLabel", {
		Position = UDim2.new(0, 6, 0, 0),
		Size = UDim2.new(1, -6, 0, 18),
		BackgroundTransparency = 1,
		Text = string.format("%s: %.2f", name, default or min or 0),
		TextSize = 15,
		Font = Enum.Font.Code,
		TextColor3 = Color3.fromRGB(210, 210, 210),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = main
	})

	creator:Hover(sldr, {HoverColor = library.Colors.Theme})
	creator:Border(sldr)

	local slider = setmetatable({}, element)
	slider.Menu = main
	slider.Element = sldr
	slider.Min = min or 0
	slider.Max = max or 1
	slider.Value = default or slider.Min
	slider.Type = "Slider"

	function slider:SetValue(percent)
		local v = lerp(slider.Min, slider.Max, percent)

		TweenService:Create(fill, TweenInfo.new(0.1), {Size = UDim2.new(percent, 0, 1, 0)}):Play()

		slider.Value = v
		title.Text = string.format("%s: %.2f", name, v)

		if callback then
			pcall(callback, v)
		end
	end

	creator:Connect(main.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			library.Slider = slider
		end
	end)

	creator:Connect(main.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			library.Slider = nil
		end
	end)

	slider:SetValue(slider.Value / slider.Max)

	return slider
end

function base:AddDropdown(name, values, callback)
	if not self.IsSection then
		return
	end

	local main = creator:Create("Frame", {
		LayoutOrder = #self.Elements + 1,
		Size = UDim2.new(1, -6, 0, name and 48 or 30),
		BackgroundTransparency = 1,
		Parent = self.Items
	})

	local listbutton = creator:Create("TextButton", {
		Position = UDim2.new(0, 6, 0, name and 22 or 4),
		Size = UDim2.new(1, -6, 0, 22),
		BackgroundColor3 = SubtractColors(library.Colors.Main, Color3.fromRGB(-20, -20, -20)),
		BorderColor3 = Color3.new(0, 0, 0),
		Text = " " .. table.concat(values, ", "),
		TextSize = 15,
		Font = Enum.Font.Code,
		TextColor3 = Color3.new(1, 1, 1),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		AutoButtonColor = false,
		Parent = main
	})

	local arrow = creator:Create("ImageLabel", {
		Position = UDim2.new(1, -16, 0, 7),
		Size = UDim2.fromOffset(8, 8),
		Rotation = 90,
		BackgroundTransparency = 1,
		Image = "rbxassetid://4918373417",
		ImageColor3 = Color3.new(0.627450, 0.627450, 0.627450),
		ScaleType = Enum.ScaleType.Fit,
		ImageTransparency = 0.4,
		Parent = listbutton
	})

	local holder = creator:Create("TextButton", {
		ZIndex = 100,
		BackgroundColor3 = SubtractColors(library.Colors.Main, Color3.fromRGB(-10, -10, -10)),
		BorderColor3 = Color3.new(0, 0, 0),
		Text = "",
		AutoButtonColor = false,
		Visible = false,
		Parent = library.Base
	})

	local content = creator:Create("ScrollingFrame", {
		ZIndex = 100,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = Color3.new(0, 0, 0),
		ScrollingDirection = Enum.ScrollingDirection.Y,
		VerticalScrollBarInset = Enum.ScrollBarInset.Always,
		Parent = holder
	})

	local layout = creator:Create("UIListLayout", {
		Padding = UDim.new(0, 2),
		Parent = content
	})
	
	creator:Create("UIPadding", {
		PaddingTop = UDim.new(0, 4),
		PaddingBottom = UDim.new(0, 4),
		Parent = content
	})

	creator:Connect(layout.Changed, function()
		holder.Size = UDim2.new(0, listbutton.AbsoluteSize.X, 0, math.min(8 + layout.AbsoluteContentSize.Y), 22 * 5)
		content.CanvasSize = UDim2.new(0, 0, 0, 8 + layout.AbsoluteContentSize.Y)
	end)

	creator:Border(holder)
	creator:Border(listbutton)
	creator:Hover(listbutton, {HoverColor = library.Colors.Theme})

	if name then
		creator:Create("TextLabel", {
			Position = UDim2.new(0, 6, 0, 0),
			Size = UDim2.new(1, -6, 0, 18),
			BackgroundTransparency = 1,
			Text = name,
			TextSize = 15,
			Font = Enum.Font.Code,
			TextColor3 = Color3.fromRGB(210, 210, 210),
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = main
		})
	end

	local dropdown = setmetatable({}, element)
	dropdown.Type = "Dropdown"
	dropdown.Value = nil
	dropdown.Open = false
	dropdown.Values = {}
	dropdown.Labels = {}

	function dropdown:Close()
		TweenService:Create(arrow, TweenInfo.new(0.2), {Rotation = 90}):Play()

		self.Open = false

		holder.Visible = false
	end

	function dropdown:SetValue(value)
		dropdown.Value = value

		if callback then
			pcall(callback, value)
		end
	end
	
	function dropdown:AddValue(value)
		if table.find(self.Values, value) then
			return false
		end

		table.insert(self.Values, value)
	
		local label = creator:Create("TextLabel", {
			LayoutOrder = GetSeed(totext(value)),
			ZIndex = 100,
			Size = UDim2.new(1, 0, 0, 20),
			BackgroundTransparency = 1,
			Text = totext(value),
			TextSize = 15,
			Font = Enum.Font.Code,
			TextColor3 = Color3.fromRGB(210, 210, 210),
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = content
		})

		self.Labels[value] = label

		creator:Hover(label, {Property = "TextColor3", HoverColor = library.Colors.Theme})

		creator:Connect(label.InputBegan, function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				self:SetValue(value)
				self:Close()
			end
		end)
	end

	function dropdown:RemoveValue(value)
		local label = self.Labels[value]

		if label then
			label:Destroy()

			table.remove(self.Values, table.find(self.Values, value))
		end
	end

	creator:Connect(listbutton.MouseButton1Click, function()
		TweenService:Create(arrow, TweenInfo.new(0.2), {Rotation = -90}):Play()

		dropdown.Open = true
		
		local apos = main.AbsolutePosition
		holder.Position = UDim2.fromOffset(apos.X + 6, apos.Y + (name and 84 or 66) - 4)
		holder.Visible = true
	end)

	for i, v in pairs(values) do
		dropdown:AddValue(v)
	end

	return dropdown
end

function base:InsertCustomGui(gui)
	gui.Parent = self.Items

	creator:Connect(gui:GetPropertyChangedSignal("Parent"), function()
		table.remove(self.Elements, table.find(self.Elements, gui))
	end)

	table.insert(self.Elements, gui)
end

-- MAIN --

function library:Init(title, toggleKey)
	creator:Clear()

	math.randomseed(GetSeed(title))

	local name = RandomString()

	if CoreGui:FindFirstChild(name) then
		CoreGui[name]:Destroy()
	end
	
	local window = {}
	window.Tabs = {}
	window.Dragging = false
	window.DragOffset = Vector2.new(0, 0)
	
	window.Gui = creator:Create("ScreenGui", {IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Global, DisplayOrder = 10000000, Parent = CoreGui, Name = name})
	window.Main = creator:Create("ImageLabel", {
		Position = UDim2.fromOffset(100, 100),
		Size = self.BaseSize,
		BackgroundColor3 = self.Colors.Main,
		ImageColor3 = self.Colors.Background,
		BorderColor3 = Color3.new(0, 0, 0),
		Image = "rbxassetid://5553946656",
		ScaleType = Enum.ScaleType.Tile,
		TileSize = UDim2.new(0, 100, 0, 100),
		Visible = true,
		Name = "Main",
		Parent = window.Gui
	})

	library.Base = window.Gui

	local topbar = creator:Create("Frame", {
		Size = UDim2.new(1, 0, 0, 47),
		BackgroundColor3 = self.Colors.Main,
		BorderColor3 = Color3.new(0, 0, 0),
		Name = "Topbar",
		Parent = window.Main
	})

	local tabScroll = creator:Create("ScrollingFrame", {
		Size = UDim2.new(1, 0, 0, 22),
		Position = UDim2.fromScale(0, 1),
		AnchorPoint = Vector2.new(0, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 0,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		Name = "Tabs",
		Parent = topbar
	})

	local tabList = creator:Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 1),
		Parent = tabScroll
	})

	local tabItems = creator:Create("Frame", {
		Size = UDim2.new(1, 0, 1, -48),
		Position = UDim2.new(0, 0, 0, 48),
		BackgroundTransparency = 1,

		Parent = window.Main
	})

	creator:Create("UIPadding", {
		PaddingLeft = UDim.new(0, 3),
		PaddingRight = UDim.new(0, 3),
		PaddingTop = UDim.new(0, 2),
		PaddingBottom = UDim.new(0, 0),
		Parent = tabScroll
	})

	creator:Create("UIPadding", {
		PaddingTop = UDim.new(0, 9),
		PaddingBottom = UDim.new(0, 5),
		PaddingLeft = UDim.new(0, 4),
		PaddingRight = UDim.new(0, 4),
		Parent = tabItems
	})

	creator:Create("TextLabel", {
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 0, 24),
		BackgroundTransparency = 1,
		Text = title,
		Font = Enum.Font.Code,
		TextSize = 18,
		TextColor3 = Color3.new(1, 1, 1),
		TextXAlignment = Enum.TextXAlignment.Left,
		Name = "Title",
		Parent = topbar
	})

	creator:Create("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 0, 47),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(51, 51, 51),
		Name = "TabBorder",
		Parent = topbar
	})

	table.insert(self.Theme, creator:Create("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 0, 24),
		BorderSizePixel = 0,
		Name = "TitleBorder",
		Parent = topbar
	}))

	creator:Border(window.Main)

	self:ApplyThemeColor()

	function window:AddTab(text)
		math.randomseed(GetSeed(text))

		local button = creator:Create("TextButton", {
			Size = UDim2.new(0, math.max(GetTextBounds(text, {Font = Font.fromEnum(Enum.Font.Code), Size = 14}).X + 5, 50), 1, 0),
			Font = Enum.Font.Code,
			BackgroundTransparency = 0.95,
			BackgroundColor3 = Color3.new(0, 0, 0),
			Text = text,
			TextSize = 14,
			BorderSizePixel = 0,
			TextColor3 = Color3.new(0.5, 0.5, 0.5),
			LayoutOrder = #window.Tabs,
			Name = RandomString(),
			Parent = tabScroll
		})
		
		local highlight = creator:Create("Frame", {
			Size = UDim2.new(0.5, 0, 0, 0),
			Position = UDim2.new(0.5, 0, 1, 0),
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundColor3 = library.Colors.Theme,
			BorderSizePixel = 0,
			ZIndex = 10,
			Parent = button
		})

		table.insert(library.Theme, highlight)

		local menu = creator:Create("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			Name = RandomString(),
			BackgroundTransparency = 1,
			Visible = false,
			Parent = tabItems
		})
		
		tabScroll.CanvasSize = UDim2.fromOffset(tabList.AbsoluteContentSize.X + 4, 0)

		local self = setmetatable({}, base)
		self.Selected = false
		self.Menu = button
		self.Items = menu

		function self:Select()
			self.Selected = true
			menu.Visible = true

			library.Theme.SelectedTab = button
			
			TweenService:Create(button, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {TextColor3 = library.Colors.Theme}):Play()
			TweenService:Create(highlight, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Size = UDim2.new(1, 0, 0, 1)}):Play()

			for _, otab in pairs(window.Tabs) do
				if otab ~= self then
					otab:Deselect()
				end
			end
		end

		function self:Deselect()
			self.Selected = false
			menu.Visible = false

			TweenService:Create(button, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {TextColor3 = Color3.new(0.5, 0.5, 0.5)}):Play()
			TweenService:Create(highlight, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 0, 0, 1)}):Play()
		end
		
		creator:Connect(button.MouseButton1Click, function()
			self:Select()
		end)

		creator:Connect(button.MouseEnter, function()
			if not self.Selected then
				TweenService:Create(button, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {TextColor3 = Color3.new(0.7, 0.7, 0.7)}):Play()
			end
		end)

		creator:Connect(button.MouseLeave, function()
			if not self.Selected then
				TweenService:Create(button, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {TextColor3 = Color3.new(0.5, 0.5, 0.5)}):Play()
			end
		end)

		if #window.Tabs == 0 then
			self:Select()
		end

		table.insert(window.Tabs, self)
		
		return self
	end

	creator:Connect(UserInputService.InputBegan, function(input)
		if input.KeyCode == toggleKey then
			window.Main.Visible = not window.Main.Visible
		end
	end)

	creator:Connect(UserInputService.InputChanged, function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			if window.Dragging then
				local offset = UserInputService:GetMouseLocation() + window.DragOffset
				window.Main.Position = UDim2.fromOffset(offset.X, math.max(offset.Y + 36, 0))
			end

			if library.Slider then
				local position = UserInputService:GetMouseLocation()
				local percent = math.clamp((position - library.Slider.Element.AbsolutePosition).X / library.Slider.Element.AbsoluteSize.X, 0, 1)

				library.Slider:SetValue(percent)
			end
		end
	end)

	creator:Connect(topbar.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			window.Dragging = true
			window.DragOffset = window.Main.AbsolutePosition - UserInputService:GetMouseLocation()
		end
	end)

	creator:Connect(topbar.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			window.Dragging = false
		end
	end)

	return window
end

function library:ApplyThemeColor(color)
	self.Colors.Theme = color or self.Colors.Theme

	for i, object in pairs(self.Theme) do
		if object.ClassName:lower():match("text") then
			object.TextColor3 = self.Colors.Theme
			continue
		end

		object.BackgroundColor3 = self.Colors.Theme
	end
end

return library
