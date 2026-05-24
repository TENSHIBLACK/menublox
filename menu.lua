local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "Hub"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Parent = gui
frame.Size = UDim2.new(0, 300, 0, 230)
frame.Position = UDim2.new(0.5, -150, 0.5, -115)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.BorderSizePixel = 0
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,10)

-- TOP
local top = Instance.new("Frame")
top.Parent = frame
top.Size = UDim2.new(1,0,0,35)
top.BackgroundColor3 = Color3.fromRGB(35,35,35)
Instance.new("UICorner", top).CornerRadius = UDim.new(0,10)

local title = Instance.new("TextLabel")
title.Parent = top
title.Size = UDim2.new(1,0,1,0)
title.BackgroundTransparency = 1
title.Text = "TP + FLY HUB"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16

-- BOTÃO TP
local tpButton = Instance.new("TextButton")
tpButton.Parent = frame
tpButton.Size = UDim2.new(0.8,0,0,45)
tpButton.Position = UDim2.new(0.1,0,0.35,0)
tpButton.Text = "TP Low HP"
tpButton.BackgroundColor3 = Color3.fromRGB(0,170,255)
tpButton.TextColor3 = Color3.new(1,1,1)
tpButton.Font = Enum.Font.GothamBold

Instance.new("UICorner", tpButton).CornerRadius = UDim.new(0,8)

-- BOTÃO FLY
local flyButton = Instance.new("TextButton")
flyButton.Parent = frame
flyButton.Size = UDim2.new(0.8,0,0,45)
flyButton.Position = UDim2.new(0.1,0,0.65,0)
flyButton.Text = "FLY OFF"
flyButton.BackgroundColor3 = Color3.fromRGB(0,255,120)
flyButton.TextColor3 = Color3.new(1,1,1)
flyButton.Font = Enum.Font.GothamBold

Instance.new("UICorner", flyButton).CornerRadius = UDim.new(0,8)

-- TP LOW HP
local function getLowestHP()
	local lowest, hp = nil, math.huge

	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character then
			local hum = plr.Character:FindFirstChild("Humanoid")
			local hrp = plr.Character:FindFirstChild("HumanoidRootPart")

			if hum and hrp and hum.Health > 0 then
				if hum.Health < hp then
					hp = hum.Health
					lowest = plr
				end
			end
		end
	end

	return lowest
end

local function tpLowHP()
	local target = getLowestHP()

	if target and target.Character then
		local myChar = player.Character
		local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
		local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")

		if myHRP and targetHRP then
			myHRP.CFrame = targetHRP.CFrame + Vector3.new(0,3,0)
		end
	end
end

tpButton.MouseButton1Click:Connect(tpLowHP)

-- FLY SYSTEM
local flying = false
local bodyGyro
local bodyVelocity

local speed = 60

local function startFly()
	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")

	if not hrp then return end

	flying = true

	bodyGyro = Instance.new("BodyGyro")
	bodyGyro.MaxTorque = Vector3.new(9e9,9e9,9e9)
	bodyGyro.P = 9e4
	bodyGyro.CFrame = hrp.CFrame
	bodyGyro.Parent = hrp

	bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = Vector3.new(9e9,9e9,9e9)
	bodyVelocity.Velocity = Vector3.zero
	bodyVelocity.Parent = hrp

	RunService.RenderStepped:Connect(function()
		if flying and hrp then
			bodyGyro.CFrame = workspace.CurrentCamera.CFrame

			local move = Vector3.zero

			if UIS:IsKeyDown(Enum.KeyCode.W) then
				move += workspace.CurrentCamera.CFrame.LookVector
			end
			if UIS:IsKeyDown(Enum.KeyCode.S) then
				move -= workspace.CurrentCamera.CFrame.LookVector
			end
			if UIS:IsKeyDown(Enum.KeyCode.A) then
				move -= workspace.CurrentCamera.CFrame.RightVector
			end
			if UIS:IsKeyDown(Enum.KeyCode.D) then
				move += workspace.CurrentCamera.CFrame.RightVector
			end

			bodyVelocity.Velocity = move * speed
		end
	end)
end

local function stopFly()
	flying = false

	if bodyGyro then bodyGyro:Destroy() end
	if bodyVelocity then bodyVelocity:Destroy() end
end

flyButton.MouseButton1Click:Connect(function()
	if flying then
		stopFly()
		flyButton.Text = "FLY OFF"
	else
		startFly()
		flyButton.Text = "FLY ON"
	end
end)

-- DRAG
local dragging, startPos, dragStart

top.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then

		dragging = true
		dragStart = input.Position
		startPos = frame.Position
	end
end)

UIS.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
	or input.UserInputType == Enum.UserInputType.Touch) then

		local delta = input.Position - dragStart

		frame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)
