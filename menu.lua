local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "SimpleHub"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- FRAME
local frame = Instance.new("Frame")
frame.Parent = gui
frame.Size = UDim2.new(0, 300, 0, 220)
frame.Position = UDim2.new(0.5, -150, 0.5, -110)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

-- TITLE
local title = Instance.new("TextLabel")
title.Parent = frame
title.Size = UDim2.new(1,0,0,40)
title.BackgroundTransparency = 1
title.Text = "SIMPLE HUB"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 18

-- TP BUTTON
local tpButton = Instance.new("TextButton")
tpButton.Parent = frame
tpButton.Size = UDim2.new(0.85,0,0,50)
tpButton.Position = UDim2.new(0.075,0,0.3,0)
tpButton.Text = "TP LOW HP"
tpButton.BackgroundColor3 = Color3.fromRGB(0,170,255)
tpButton.TextColor3 = Color3.new(1,1,1)
tpButton.Font = Enum.Font.GothamBold
tpButton.TextSize = 16
Instance.new("UICorner", tpButton).CornerRadius = UDim.new(0,8)

-- FLY BUTTON
local flyButton = Instance.new("TextButton")
flyButton.Parent = frame
flyButton.Size = UDim2.new(0.85,0,0,50)
flyButton.Position = UDim2.new(0.075,0,0.6,0)
flyButton.Text = "FLY OFF"
flyButton.BackgroundColor3 = Color3.fromRGB(0,255,120)
flyButton.TextColor3 = Color3.new(1,1,1)
flyButton.Font = Enum.Font.GothamBold
flyButton.TextSize = 16
Instance.new("UICorner", flyButton).CornerRadius = UDim.new(0,8)

-------------------------------------------------
-- TP LOW HP
-------------------------------------------------
local function getLowestHP()
	local lowest
	local hp = math.huge

	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character then
			local hum = plr.Character:FindFirstChild("Humanoid")
			local root = plr.Character:FindFirstChild("HumanoidRootPart")

			if hum and root and hum.Health > 0 then
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
		local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")

		if hrp and targetRoot then
			hrp.CFrame = targetRoot.CFrame + Vector3.new(0,3,0)
		end
	end
end

tpButton.MouseButton1Click:Connect(tpLowHP)

-------------------------------------------------
-- FLY SYSTEM
-------------------------------------------------
local flying = false
local bodyGyro
local bodyVelocity
local speed = 70

local function startFly()
	flying = true

	bodyGyro = Instance.new("BodyGyro")
	bodyGyro.MaxTorque = Vector3.new(9e9,9e9,9e9)
	bodyGyro.P = 9e4
	bodyGyro.CFrame = hrp.CFrame
	bodyGyro.Parent = hrp

	bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = Vector3.new(9e9,9e9,9e9)
	bodyVelocity.Parent = hrp

	RunService.RenderStepped:Connect(function()
		if flying then
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
