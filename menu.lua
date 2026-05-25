--// MOBILE HUB COMPLETO - ROBLOX LUAU

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "MobileHub"
gui.ResetOnSpawn = false
gui.Parent = player.PlayerGui

-- RGB EFFECT
local rgb = 0

-- MAIN FRAME
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,260,0,500)
frame.Position = UDim2.new(0,20,0.5,-250)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.Active = true
frame.Draggable = true
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0,16)

-- STROKE RGB
local stroke = Instance.new("UIStroke")
stroke.Thickness = 3
stroke.Parent = frame

-- TITLE
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,-60,0,45)
title.Position = UDim2.new(0,15,0,5)
title.BackgroundTransparency = 1
title.Text = "MOBILE HUB"
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.TextColor3 = Color3.new(1,1,1)
title.Parent = frame

-- MINIMIZE
local minimized = false

local minimize = Instance.new("TextButton")
minimize.Size = UDim2.new(0,40,0,40)
minimize.Position = UDim2.new(1,-45,0,5)
minimize.Text = "-"
minimize.Font = Enum.Font.GothamBold
minimize.TextScaled = true
minimize.BackgroundColor3 = Color3.fromRGB(40,40,40)
minimize.TextColor3 = Color3.new(1,1,1)
minimize.Parent = frame

Instance.new("UICorner", minimize).CornerRadius = UDim.new(1,0)

-- SCROLL
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1,-20,1,-70)
scroll.Position = UDim2.new(0,10,0,60)
scroll.CanvasSize = UDim2.new(0,0,0,700)
scroll.ScrollBarThickness = 4
scroll.BackgroundTransparency = 1
scroll.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0,8)
layout.Parent = scroll

-- BUTTON CREATOR
local function createButton(text)

	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1,-10,0,50)
	button.BackgroundColor3 = Color3.fromRGB(35,35,35)
	button.TextColor3 = Color3.new(1,1,1)
	button.Font = Enum.Font.GothamBold
	button.TextScaled = true
	button.Text = text
	button.Parent = scroll

	Instance.new("UICorner", button).CornerRadius = UDim.new(0,14)

	return button
end

-- BUTTONS
local flyButton = createButton("FLY OFF")
local noclipButton = createButton("NOCLIP OFF")
local espButton = createButton("ESP OFF")
local unstickButton = createButton("DESGRUDAR")

-- PLAYER TITLE
local playerTitle = Instance.new("TextLabel")
playerTitle.Size = UDim2.new(1,-10,0,40)
playerTitle.BackgroundTransparency = 1
playerTitle.Text = "JOGADORES"
playerTitle.TextScaled = true
playerTitle.Font = Enum.Font.GothamBold
playerTitle.TextColor3 = Color3.new(1,1,1)
playerTitle.Parent = scroll

-- PLAYER LIST
local playerFrame = Instance.new("Frame")
playerFrame.Size = UDim2.new(1,-10,0,250)
playerFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
playerFrame.Parent = scroll

Instance.new("UICorner", playerFrame).CornerRadius = UDim.new(0,14)

local playerScroll = Instance.new("ScrollingFrame")
playerScroll.Size = UDim2.new(1,-10,1,-10)
playerScroll.Position = UDim2.new(0,5,0,5)
playerScroll.CanvasSize = UDim2.new(0,0,0,0)
playerScroll.BackgroundTransparency = 1
playerScroll.Parent = playerFrame

local playerLayout = Instance.new("UIListLayout")
playerLayout.Padding = UDim.new(0,5)
playerLayout.Parent = playerScroll

-- RGB LOOP
RunService.RenderStepped:Connect(function()

	rgb += 0.005

	stroke.Color = Color3.fromHSV(rgb % 1,1,1)
end)

-- FLY SYSTEM
local flying = false
local flyConnection

flyButton.MouseButton1Click:Connect(function()

	flying = not flying

	if flying then

		flyButton.Text = "FLY ON"

		flyConnection = RunService.RenderStepped:Connect(function()

			local cam = workspace.CurrentCamera

			local move = humanoid.MoveDirection

			local direction =
				(cam.CFrame.LookVector * move.Z) +
				(cam.CFrame.RightVector * move.X)

			hrp.Velocity = direction * 80 + Vector3.new(0,2,0)
		end)

	else

		flyButton.Text = "FLY OFF"

		if flyConnection then
			flyConnection:Disconnect()
			flyConnection = nil
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
local espObjects = {}

local function createESP(plr)

	if plr == player then
		return
	end

	local highlight = Instance.new("Highlight")
	highlight.FillTransparency = 0.5
	highlight.OutlineTransparency = 0
	highlight.Parent = plr.Character

	espObjects[plr] = highlight
end

local function removeESP()

	for _, esp in pairs(espObjects) do
		if esp then
			esp:Destroy()
		end
	end

	espObjects = {}
end

espButton.MouseButton1Click:Connect(function()

	espEnabled = not espEnabled

	espButton.Text =
		espEnabled and "ESP ON" or "ESP OFF"

	if espEnabled then

		for _, plr in pairs(Players:GetPlayers()) do

			if plr.Character then
				createESP(plr)
			end
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

local function stickToPlayer(target)

	unstick()

	if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then

		local targetHRP = target.Character.HumanoidRootPart

		att0 = Instance.new("Attachment", hrp)
		att1 = Instance.new("Attachment", targetHRP)

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

-- PLAYER LIST
local function refreshPlayers()

	for _, v in pairs(playerScroll:GetChildren()) do

		if v:IsA("TextButton") then
			v:Destroy()
		end
	end

	for _, plr in pairs(Players:GetPlayers()) do

		if plr ~= player then

			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(1,-5,0,45)
			btn.BackgroundColor3 = Color3.fromRGB(45,45,45)
			btn.TextColor3 = Color3.new(1,1,1)
			btn.TextScaled = true
			btn.Font = Enum.Font.GothamBold
			btn.Text = "TP "..plr.Name
			btn.Parent = playerScroll

			Instance.new("UICorner", btn).CornerRadius = UDim.new(0,12)

			btn.MouseButton1Click:Connect(function()

				if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then

					hrp.CFrame =
						plr.Character.HumanoidRootPart.CFrame
						* CFrame.new(0,0,3)

					stickToPlayer(plr)
				end
			end)
		end
	end

	task.wait()

	playerScroll.CanvasSize =
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

		TweenService:Create(
			frame,
			TweenInfo.new(0.25),
			{Size = UDim2.new(0,260,0,50)}
		):Play()

		scroll.Visible = false

		minimize.Text = "+"

	else

		TweenService:Create(
			frame,
			TweenInfo.new(0.25),
			{Size = originalSize}
		):Play()

		scroll.Visible = true

		minimize.Text = "-"
	end
end)
