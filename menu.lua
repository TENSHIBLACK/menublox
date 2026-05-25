--// MOBILE HUB V4 FINAL - ROBLOX LUAU

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- REMOVE MENU DUPLICADO
if player.PlayerGui:FindFirstChild("MobileHub") then
	player.PlayerGui.MobileHub:Destroy()
end

-- CHARACTER
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")

player.CharacterAdded:Connect(function(char)

	character = char
	humanoid = char:WaitForChild("Humanoid")
	hrp = char:WaitForChild("HumanoidRootPart")
end)

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "MobileHub"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player.PlayerGui

-- MAIN FRAME
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,170,0,280)
frame.Position = UDim2.new(0,10,0.5,-140)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.BackgroundTransparency = 0.1
frame.Active = true
frame.Draggable = true
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)

-- RGB BORDER
local stroke = Instance.new("UIStroke")
stroke.Thickness = 2
stroke.Parent = frame

local rgb = 0

RunService.RenderStepped:Connect(function()

	rgb += 0.002

	stroke.Color = Color3.fromHSV(rgb % 1,1,1)
end)

-- TITLE
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,-40,0,28)
title.Position = UDim2.new(0,8,0,5)
title.BackgroundTransparency = 1
title.Text = "MOBILE HUB"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.Parent = frame

-- MINIMIZE
local minimized = false

local minimize = Instance.new("TextButton")
minimize.Size = UDim2.new(0,26,0,26)
minimize.Position = UDim2.new(1,-30,0,6)
minimize.Text = "-"
minimize.TextScaled = true
minimize.Font = Enum.Font.GothamBold
minimize.BackgroundColor3 = Color3.fromRGB(35,35,35)
minimize.TextColor3 = Color3.new(1,1,1)
minimize.Parent = frame

Instance.new("UICorner", minimize).CornerRadius = UDim.new(1,0)

-- SCROLL
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1,-10,1,-42)
scroll.Position = UDim2.new(0,5,0,36)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 2
scroll.CanvasSize = UDim2.new(0,0,0,500)
scroll.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0,5)
layout.Parent = scroll

-- BUTTON CREATOR
local function createButton(text)

	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1,-4,0,34)
	button.BackgroundColor3 = Color3.fromRGB(35,35,35)
	button.TextColor3 = Color3.new(1,1,1)
	button.TextScaled = true
	button.Font = Enum.Font.GothamBold
	button.Text = text
	button.Parent = scroll

	Instance.new("UICorner", button).CornerRadius = UDim.new(0,10)

	return button
end

-- BUTTONS
local flyButton = createButton("FLY OFF")
local noclipButton = createButton("NOCLIP OFF")
local espButton = createButton("ESP OFF")
local unstickButton = createButton("DESGRUDAR")

-- PLAYER TITLE
local pTitle = Instance.new("TextLabel")
pTitle.Size = UDim2.new(1,0,0,25)
pTitle.BackgroundTransparency = 1
pTitle.Text = "PLAYERS"
pTitle.TextScaled = true
pTitle.Font = Enum.Font.GothamBold
pTitle.TextColor3 = Color3.new(1,1,1)
pTitle.Parent = scroll

-- PLAYER LIST
local playerList = Instance.new("ScrollingFrame")
playerList.Size = UDim2.new(1,-2,0,95)
playerList.BackgroundColor3 = Color3.fromRGB(28,28,28)
playerList.ScrollBarThickness = 2
playerList.CanvasSize = UDim2.new(0,0,0,0)
playerList.Parent = scroll

Instance.new("UICorner", playerList).CornerRadius = UDim.new(0,10)

local playerLayout = Instance.new("UIListLayout")
playerLayout.Padding = UDim.new(0,4)
playerLayout.Parent = playerList

-- FLY FIX MOBILE
local flying = false
local flyBV
local flyGyro
local flyConnection

flyButton.MouseButton1Click:Connect(function()

	flying = not flying

	if flying then

		flyButton.Text = "FLY ON"

		flyBV = Instance.new("BodyVelocity")
		flyBV.MaxForce = Vector3.new(999999,999999,999999)
		flyBV.Velocity = Vector3.zero
		flyBV.Parent = hrp

		flyGyro = Instance.new("BodyGyro")
		flyGyro.MaxTorque = Vector3.new(999999,999999,999999)
		flyGyro.P = 10000
		flyGyro.CFrame = workspace.CurrentCamera.CFrame
		flyGyro.Parent = hrp

		flyConnection = RunService.RenderStepped:Connect(function()

			if not flying then
				return
			end

			local cam = workspace.CurrentCamera
			local moveDir = humanoid.MoveDirection

			local moveVector =
				(cam.CFrame.LookVector * moveDir.Z) +
				(cam.CFrame.RightVector * moveDir.X)

			flyBV.Velocity =
				Vector3.new(
					moveVector.X * 60,
					0,
					moveVector.Z * 60
				)

			flyGyro.CFrame = cam.CFrame
		end)

	else

		flyButton.Text = "FLY OFF"

		if flyConnection then
			flyConnection:Disconnect()
			flyConnection = nil
		end

		if flyBV then
			flyBV:Destroy()
			flyBV = nil
		end

		if flyGyro then
			flyGyro:Destroy()
			flyGyro = nil
		end

		hrp.Velocity = Vector3.zero
	end
end)

-- NOCLIP
local noclip = false

noclipButton.MouseButton1Click:Connect(function()

	noclip = not noclip

	noclipButton.Text =
		noclip and "NOCLIP ON" or "NOCLIP OFF"
end)

RunService.Stepped:Connect(function()

	if noclip and character then

		for _, v in pairs(character:GetDescendants()) do

			if v:IsA("BasePart") then
				v.CanCollide = false
			end
		end
	end
end)

-- ESP
local espEnabled = false
local espTable = {}

local function removeESP()

	for _, v in pairs(espTable) do

		if v then
			v:Destroy()
		end
	end

	espTable = {}
end

local function createESP(plr)

	if plr == player then
		return
	end

	if plr.Character then

		local hl = Instance.new("Highlight")
		hl.FillTransparency = 0.5
		hl.OutlineTransparency = 0
		hl.Parent = plr.Character

		table.insert(espTable, hl)
	end
end

espButton.MouseButton1Click:Connect(function()

	espEnabled = not espEnabled

	espButton.Text =
		espEnabled and "ESP ON" or "ESP OFF"

	if espEnabled then

		for _, plr in pairs(Players:GetPlayers()) do
			createESP(plr)
		end

	else

		removeESP()
	end
end)

-- STICK PLAYER
local alignPos
local alignOri
local att0
local att1

local function unstick()

	if alignPos then alignPos:Destroy() end
	if alignOri then alignOri:Destroy() end
	if att0 then att0:Destroy() end
	if att1 then att1:Destroy() end
end

unstickButton.MouseButton1Click:Connect(function()
	unstick()
end)

local function stick(plr)

	unstick()

	if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then

		local target = plr.Character.HumanoidRootPart

		att0 = Instance.new("Attachment", hrp)
		att1 = Instance.new("Attachment", target)

		alignPos = Instance.new("AlignPosition")
		alignPos.Attachment0 = att0
		alignPos.Attachment1 = att1
		alignPos.MaxForce = 999999
		alignPos.Responsiveness = 200
		alignPos.RigidityEnabled = true
		alignPos.Parent = hrp

		alignOri = Instance.new("AlignOrientation")
		alignOri.Attachment0 = att0
		alignOri.Attachment1 = att1
		alignOri.MaxTorque = 999999
		alignOri.Responsiveness = 200
		alignOri.RigidityEnabled = true
		alignOri.Parent = hrp
	end
end

-- PLAYERS
local function refreshPlayers()

	for _, v in pairs(playerList:GetChildren()) do

		if v:IsA("TextButton") then
			v:Destroy()
		end
	end

	for _, plr in pairs(Players:GetPlayers()) do

		if plr ~= player then

			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(1,-4,0,30)
			btn.BackgroundColor3 = Color3.fromRGB(45,45,45)
			btn.TextColor3 = Color3.new(1,1,1)
			btn.Font = Enum.Font.GothamBold
			btn.TextScaled = true
			btn.Text = plr.Name
			btn.Parent = playerList

			Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)

			btn.MouseButton1Click:Connect(function()

				if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then

					hrp.CFrame =
						plr.Character.HumanoidRootPart.CFrame
						* CFrame.new(0,0,3)

					stick(plr)
				end
			end)
		end
	end

	task.wait()

	playerList.CanvasSize =
		UDim2.new(0,0,0,playerLayout.AbsoluteContentSize.Y + 10)
end

refreshPlayers()

Players.PlayerAdded:Connect(refreshPlayers)
Players.PlayerRemoving:Connect(refreshPlayers)

-- MINIMIZE
local originalSize = frame.Size

minimize.MouseButton1Click:Connect(function()

	minimized = not minimized

	if minimized then

		scroll.Visible = false

		TweenService:Create(
			frame,
			TweenInfo.new(0.2),
			{Size = UDim2.new(0,170,0,38)}
		):Play()

		minimize.Text = "+"

	else

		scroll.Visible = true

		TweenService:Create(
			frame,
			TweenInfo.new(0.2),
			{Size = originalSize}
		):Play()

		minimize.Text = "-"
	end
end)
