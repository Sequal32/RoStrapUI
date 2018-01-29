-- Material Switches
-- @author Validark

-- Services
local ContentProvider = game:GetService("ContentProvider")

-- Load Libraries
local Resources = require(game:GetService("ReplicatedStorage"):WaitForChild("Resources"))
local Tween = Resources:LoadLibrary("Tween")
local Colors = Resources:LoadLibrary("Colors")

-- Import Math Functions
local ceil = math.ceil
local floor = math.floor

-- Constants
local DEFAULT_CHECKBOX_COLOR = "Cyan"

local ANIMATION_TIME = 0.175
local RIPPLE_TRANSPARENCY = 0.8
local RIPPLE_ENTER = 0.5
local RIPPLE_EXIT = 0.75

local CheckboxThemes = {
	Light = {
		ImageColor3 = Colors.Black;
		ImageTransparency = 0.46;
		DisabledTransparency = 0.74;
	};

	Dark = {
		ImageColor3 = Colors.White;
		ImageTransparency = 0.3;
		DisabledTransparency = 0.7;
	};
}

local SLICE_CHECKBOX = true -- Currently has no effect
local COMPLETE_ANIMATION = 0.9999 -- Not quite 1, so it won't fire next Animation

-- Derived Constants
local DEFAULT_CHECKBOX_COLOR3 = Colors[DEFAULT_CHECKBOX_COLOR][500]

-- Images
local RIPPLE_IMAGE = "rbxassetid://517259585"
local CHECKBOX_IMAGE_24 = "rbxassetid://1352842153"

-- Preload Images
ContentProvider:Preload(RIPPLE_IMAGE)
ContentProvider:Preload(CHECKBOX_IMAGE_24)

-- Object Data
local NO_SIZE = UDim2.new(0, 0, 0, 0)
local PART_SIZE = UDim2.new(0.9, 0, 0.9, 0)
local FULL_SIZE = UDim2.new(1, 0, 1, 0)
local RIPPLE_TARGET_SIZE = UDim2.new(2, 0, 2, 0)

local CHECKBOX_SIZE = UDim2.new(0, 24, 0, 24)
local CHECKBOX_SHRINK_SIZE = UDim2.new(0, 22, 0, 22)

local MIDDLE_ANCHOR = Vector2.new(0.5, 0.5)
local MIDDLE_POSITION = UDim2.new(0.5, 0, 0.5, 0)

local function DrawCheckmark(x, Grid)
--	ChangeCheckboxSize(PART_SIZE:Lerp(FULL_SIZE, x))

	for c = 1, -1, -2 do
		local a = floor(11 + x * (4 - 2*c - 11)) -- Lerp(11, 4 - 2*c, x)
		local d = c == 1 and 15 or -4

		for a = a, 10 do
			local b = -c*a + d
			local e

			if a == 2 and b == 13 then
				e = 0.18
			elseif a == 3 and b == 12 or a == 4 and b == 11 or a == 5 and b == 10 or a == 9 and (b == 5 or b == 6) then
				e = 0.36
			elseif a == 6 then
				if b == 2 then
					e = 0.18
				elseif b == 9 then
					e = 0.36
				end
			elseif a == 7 then
				if b == 3 then
					e = 0.35
				elseif b == 8 then
					e = 0.36
				end
			elseif a == 8 then
				if b == 4 then
					e = 0.35
				elseif b == 7 then
					e = 0.36
				end
			elseif a == 10 then
				if b == 5 or b == 6 then
					e = 0.99
				end
			end

			Grid[14 * (a - 1) + b].BackgroundTransparency = e
			Grid[14 * a + b].BackgroundTransparency = 0.99
			Grid[14 * (a + 1) + b].BackgroundTransparency = 1
			Grid[14 * (a + 1) + b + c].BackgroundTransparency = 0.5
		end
		Grid[a * (14 - c) + c + d].BackgroundTransparency = c == 1 and 0.5 or 0.51 -- 14 * a + -c * a + d + c
	end
	Grid[160].BackgroundTransparency = 0.5 -- 12, 6
end

local function FillCenter(x, Grid)
--	ChangeCheckboxSize(FULL_SIZE:Lerp(PART_SIZE, x))
	
	local CurrentSize = 0.5 * floor(14*(2 - x)) -- Floor(Lerp(14, 7, x), 0.5)

	for i = 1, 14 - CurrentSize do
		for a = i, 15 - i do
			Grid[14 * (i - 1) + a].BackgroundTransparency = 0
			Grid[14 * (a - 1) + i].BackgroundTransparency = 0
			Grid[14 * ((15 - i) - 1) + a].BackgroundTransparency = 0
			Grid[14 * (a - 1) + 15 - i].BackgroundTransparency = 0
		end
	end

	if (CurrentSize + 0.5) % 1 == 0 then
		local i = 14.5 - CurrentSize
		for a = i, 15 - i do
			Grid[14 * (i - 1) + a].BackgroundTransparency = 0.5
			Grid[14 * (a - 1) + i].BackgroundTransparency = 0.5
			Grid[14 * ((15 - i) - 1) + a].BackgroundTransparency = 0.5
			Grid[14 * (a - 1) + 15 - i].BackgroundTransparency = 0.5
		end
	end

	if x == 1 then
		Grid.OpenTween = Tween.new(ANIMATION_TIME, "Deceleration", DrawCheckmark, Grid)
	end
end

local function EmptyCenter(x, Grid)
--	ChangeCheckboxSize(PART_SIZE:Lerp(FULL_SIZE, x))

	local CurrentSize = 0.5 * ceil(14 * x) -- Ceil(Lerp(0, 7, x), 0.5)

	for i = 1, CurrentSize do
		local Start = 8 - i
		local End = 7 + i

		for a = Start, End do
			Grid[14 * (Start - 1) + a].BackgroundTransparency = 1
			Grid[14 * (a - 1) + Start].BackgroundTransparency = 1
			Grid[14 * (End - 1) + a].BackgroundTransparency = 1
			Grid[14 * (a - 1) + End].BackgroundTransparency = 1
		end
	end

	if (CurrentSize + 0.5) % 1 == 0 then
		local i = 0.5 + CurrentSize
		local Start = 8 - i
		local End = 7 + i
		
		for a = Start, End do
			local BackgroundTransparency = 0.5 * (Grid.ImageTransparency + 1) -- CompoundTransparency
			Grid[14 * (Start - 1) + a].BackgroundTransparency = BackgroundTransparency
			Grid[14 * (a - 1) + Start].BackgroundTransparency = BackgroundTransparency
			Grid[14 * (End - 1) + a].BackgroundTransparency = BackgroundTransparency
			Grid[14 * (a - 1) + End].BackgroundTransparency = BackgroundTransparency
		end
	end
end

local function EraseCheckmark(x, Grid)
--	ChangeCheckboxSize(FULL_SIZE:Lerp(PART_SIZE, x))

	local XOffset, YOffset = Grid.XOffset, Grid.YOffset

	local a = ceil(8*x + 1) -- ceil(Lerp(1, 9, x))
	local b = 15 - a
	local ImageTransparency = Grid.ImageTransparency
	local HalfImageTransparency = 0.5 * (ImageTransparency + 1) -- CompoundTransparency

	for a = 2, a do
		local b = 15 - a
		a = a + XOffset
		b = b + YOffset

		local Object1 = Grid[14 * (a - 1) + b]
		local Object2 = Grid[14 * a + b]
		local Object3 = Grid[14 * (a + 1) + b]
		local Object4 = Grid[14 * (a + 1) + b + 1]
		local Object5 = Grid[14 * a + b + 1]

		if Object1 then Object1.BackgroundTransparency = ImageTransparency end
		if Object2 then Object2.BackgroundTransparency = ImageTransparency end
		if Object3 then Object3.BackgroundTransparency = HalfImageTransparency end
		if Object4 then Object4.BackgroundTransparency = ImageTransparency end
		if Object5 then Object5.BackgroundTransparency = ImageTransparency end
	end

	local c = ceil(4*x + 5) -- Lerp(5, 9, x)
	local d = c - 4

	for c = 6, c do
		local d = c - 4
		c = c + XOffset
		d = d + YOffset

		local Object1 = Grid[14 * (c - 1) + d]
		local Object2 = Grid[14 * c + d]
		local Object3 = Grid[14 * (c + 1) + d]
		local Object4 = Grid[14 * (c + 1) + d - 1]
		local Object5 = Grid[14 * c + d - 1]

		if Object1 then Object1.BackgroundTransparency = ImageTransparency end
		if Object2 then Object2.BackgroundTransparency = ImageTransparency end
		if Object3 then Object3.BackgroundTransparency = HalfImageTransparency end
		if Object4 then Object4.BackgroundTransparency = ImageTransparency end
		if Object5 then Object5.BackgroundTransparency = ImageTransparency end
	end

	local NewXOffset = floor(-5*x + 1) -- Lerp(1, -3 - 1, x)
	local NewYOffset = ceil(3*x - 1) -- Lerp(-1, 2, x)

	local XOffsetChange = XOffset - NewXOffset
	local YOffsetChange = NewYOffset - YOffset

	Grid.XOffset, Grid.YOffset = NewXOffset, NewYOffset

	-- Shift according to XOffsetChange and YOffsetChange
	for a = 1, XOffsetChange do
		for b = 1, 14 do
			for f = 1, 13 do
				Grid[14 * (f - 1) + b].BackgroundTransparency = Grid[14 * f + b].BackgroundTransparency
			end
		end
	end

	for a = 1, YOffsetChange do
		for b = 1, 14 do
			for f = 14, 2, -1 do
				Grid[14 * (b - 1) + f].BackgroundTransparency = Grid[14 * (b - 1) + f - 1].BackgroundTransparency
			end
			Grid[14 * (b - 1) + 1].BackgroundTransparency = ImageTransparency
		end
	end

	if x == 1 then
		local BackgroundTransparency = ImageTransparency
		for a = 1, 196 do
			Grid[a].BackgroundTransparency = BackgroundTransparency
		end
		Grid.OpenTween = Tween.new(ANIMATION_TIME, "Deceleration", EmptyCenter, Grid)
	end
end

-- Objects
local Ripple = Instance.new("ImageLabel")
Ripple.AnchorPoint = MIDDLE_ANCHOR
Ripple.BackgroundTransparency = 1
Ripple.Image = RIPPLE_IMAGE
Ripple.ImageTransparency = RIPPLE_TRANSPARENCY
Ripple.Name = "Ripple"
Ripple.Position = MIDDLE_POSITION

local CheckboxButton do
	CheckboxButton = Instance.new("TextButton")
	CheckboxButton.BackgroundTransparency = 1
	CheckboxButton.Text = ""
	CheckboxButton.Size = CHECKBOX_SIZE

	local Checkbox = Instance.new("ImageLabel")
	Checkbox.AnchorPoint = MIDDLE_ANCHOR
	Checkbox.BackgroundTransparency = 1
	Checkbox.Image = CHECKBOX_IMAGE_24
	Checkbox.ImageColor3 = Colors.Black
	Checkbox.ImageTransparency = CheckboxThemes.Light.ImageTransparency
	Checkbox.Name = "Checkbox"
	Checkbox.Size =  FULL_SIZE
	Checkbox.Position = MIDDLE_POSITION
	Checkbox.Parent = CheckboxButton

	if SLICE_CHECKBOX then
		Checkbox.ScaleType = "Slice"
		Checkbox.SliceCenter = Rect.new(5, 5, 19, 19)
	end

	for a = 1, 14 do
		local Existant = 14 * (a - 1)
		for b = 1, 14 do
			local Pixel = Instance.new("Frame")
			Pixel.BackgroundTransparency = 1
			Pixel.BorderSizePixel = 0
			Pixel.Name = Existant + b
			Pixel.Parent = CheckboxButton
			Pixel.Position = UDim2.new(0, b + 4, 0, a + 4)
			Pixel.Size = UDim2.new(0, 1, 0, 1)
		end
	end
end

-- Enums
local Touch = Enum.UserInputType.Touch
local MouseButton1 = Enum.UserInputType.MouseButton1

-- Interface Metamethods
local function __namecall(self, ...)
	local self = getmetatable(self).__index
	local Button = self.__index
	local Arguments = {...}
	local Method = table.remove(Arguments)

	if Method == "Destroy" then
		self.Bindable:Destroy()
	elseif Method == "ChangeState" then
		if Arguments[1] == nil or not Arguments[1] == self.State then
			local InputObject = {UserInputType = MouseButton1}
			self.Down(InputObject)
			self.Up(InputObject)
		end
		return
	elseif Method == "TweenSize" or Method == "TweenSizeAndPosition" then
		return error("[Switch] The \"Size\" property is locked")
	end

	return Button(Method, unpack(Arguments)) -- Button[Method](Button, unpack(Arguments))
end

local function __newindex(self, i, v)
	local self = getmetatable(self).__index
	local Button = self.__index
	local Checkbox = Button.Checkbox
	
	if i == "State" then
		if self.State ~= v then
			self.State = v
			local Grid = self.Grid

			if Grid.OpenTween then
				Grid.OpenTween:Stop()
				Grid.OpenTween = nil
			end

			if v then
				local ImageColor3 = self.EnabledColor3
				local ImageTransparency = 0

				Checkbox.ImageColor3 = ImageColor3
				Checkbox.ImageTransparency = 0
				Grid.ImageTransparency = 0

				for a = 1, 196 do
					Grid[a].BackgroundColor3 = ImageColor3
				end

				FillCenter(COMPLETE_ANIMATION, Grid)
				DrawCheckmark(COMPLETE_ANIMATION, Grid)
			else
				local ImageColor3 = self.Theme.ImageColor3
				local ImageTransparency = self.Theme.ImageTransparency

				Checkbox.ImageColor3 = ImageColor3
				Checkbox.ImageTransparency = ImageTransparency
				Grid.ImageTransparency = ImageTransparency

				EraseCheckmark(COMPLETE_ANIMATION, Grid)
				EmptyCenter(COMPLETE_ANIMATION, Grid)
			end
		end
		return
	elseif i == "Size" then
		return error("[Switch] The \"Size\" property is locked")
	elseif i == "Theme" then
		v = v or "Light"
		local Theme = CheckboxThemes[v]
		if Theme then
			self.Theme = Theme
			if not self.State then
				Checkbox.ImageColor3 = Theme.ImageColor3
				Checkbox.ImageTransparency = Theme.ImageTransparency
			end
		else
			error("[Switch] Invalid theme")
		end
		return
	elseif i == "EnabledColor" then
		v = v or DEFAULT_CHECKBOX_COLOR
		local Color3Value = Colors[v]
		self.EnabledColor = v
		self.EnabledColor3 = type(Color3Value) == "table" and Color3Value[500] or Color3Value
		return
	elseif i == "EnabledColor3" then
		self.EnabledColor = "Unknown"
		self.EnabledColor3 = v
		return
	end

	Button[i] = v
end

-- Instantiator
local Switch = {}

function Switch.new(Type, Parent)
	-- Types
	-- Checkbox, Radio, Toggle

	-- SelectionGained()
	-- Fired when the GuiObject is being focused on with the Gamepad selector.
	-- SelectionLost()
	-- Fired when the Gamepad selector stops focusing on the GuiObject.

	local LastRipple

	local Bindable = Instance.new("BindableEvent")
	local Button = CheckboxButton:Clone()
	local Checkbox = Button.Checkbox
	Button.Parent = Parent

	local Grid = {
		XOffset = 0;
		YOffset = 0;
	}

	-- Track pixel grid
	for a = 1, 14 do
		local Existant = 14 * (a - 1)
		for b = 1, 14 do
			Grid[Existant + b] = Button[Existant + b]
		end
	end

	local self = {
		-- Public
		Grid = Grid;
		Theme = CheckboxThemes.Light;
		State = false;
		Disabled = false;
		StateChanged = Bindable.Event;
		EnabledColor = DEFAULT_CHECKBOX_COLOR;
		EnabledColor3 = DEFAULT_CHECKBOX_COLOR3;
		
		-- Private
		Bindable = Bindable;

		-- Protected
		__index = Button;
	}
	
	local Interactable = newproxy(true)
	local Metatable = getmetatable(Interactable)
	Metatable.__index = setmetatable(self, self)
	Metatable.__namecall = __namecall
	Metatable.__newindex = __newindex
	__newindex(Interactable, "Parent", Parent)

	function self.Down(InputObject)
		if InputObject.UserInputType == MouseButton1 or InputObject.UserInputType == Touch then
			if LastRipple then
				Tween(LastRipple, "ImageTransparency", 1, "Deceleration", RIPPLE_EXIT, false, true)
			end
			
			local Ripple = Ripple:Clone()

			if self.State then
				Ripple.ImageColor3 = self.EnabledColor3
			else
				Ripple.ImageColor3 = self.Theme.ImageColor3
				Ripple.ImageTransparency = (1 - RIPPLE_TRANSPARENCY) * self.Theme.ImageTransparency + RIPPLE_TRANSPARENCY
			end

			Ripple.ZIndex = Button.ZIndex + 1
			Ripple.Parent = Button

			LastRipple = Ripple
			Tween(Ripple, "Size", RIPPLE_TARGET_SIZE, "Deceleration", RIPPLE_ENTER)
		end
	end

	function self.Up(InputObject)
		if InputObject.UserInputType == MouseButton1 or InputObject.UserInputType == Touch then
			if LastRipple then
				local Checked = not self.State
				self.State = Checked
				Bindable:Fire(Checked)

				if Grid.OpenTween then
					Grid.OpenTween:Stop()
					Grid.OpenTween = nil
				end

				if Checked then
					Checkbox.ImageColor3 = self.EnabledColor3
					Checkbox.ImageTransparency = 0
					Grid.ImageTransparency = 0

					for a = 1, 196 do
						local Pixel = Grid[a]
						Pixel.BackgroundColor3 = self.EnabledColor3
						Pixel.BackgroundTransparency = 1
					end

					Grid.OpenTween = Tween.new(ANIMATION_TIME, "Deceleration", FillCenter, Grid)
				else
					local ImageColor3 = self.Theme.ImageColor3
					local ImageTransparency = self.Theme.ImageTransparency

					Checkbox.ImageColor3 = ImageColor3
					Checkbox.ImageTransparency = ImageTransparency
					Grid.ImageTransparency = ImageTransparency

					for a = 1, 196 do
						local Pixel = Grid[a]
						Pixel.BackgroundColor3 = ImageColor3
						Pixel.BackgroundTransparency = (1 - ImageTransparency) * Pixel.BackgroundTransparency + ImageTransparency -- CompoundTransparency
					end

					Grid.XOffset, Grid.YOffset = 0, 0
					Grid.OpenTween = Tween.new(ANIMATION_TIME, "Standard", EraseCheckmark, Grid)
				end
			end
		end

		if LastRipple then
			Tween(LastRipple, "ImageTransparency", 1, "Deceleration", RIPPLE_EXIT, false, true)
			LastRipple = nil
		end
	end

	Button.InputBegan:Connect(self.Down)
	Button.InputEnded:Connect(self.Up)

	Button:GetPropertyChangedSignal("ZIndex"):Connect(function()
		local ZIndex = Button.ZIndex
		Checkbox.ZIndex = ZIndex + 1
		for a = 1, 196 do
			Grid[a].ZIndex = ZIndex + 2
		end
	end)

	return Interactable
end

return Switch
