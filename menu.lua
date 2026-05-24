local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-------------------------------------------------
-- GUI
-------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "UltimateHub"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Parent = gui
frame.Size = UDim2.new(0, 300, 0, 320)
frame.Position = UDim2.new(0.5, -150, 0.5, -160)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.Active = true
frame.Draggable = true

Instance.new("UICorner", frame).CornerRadius = UDim.new(0,10)

-------------------------------------------------
-- TITLE
-------------------------------------------------
local title = Instance.new("TextLabel")
title.Parent = frame
title.Size = UDim2.new(1,0,0,40)
title.BackgroundTransparency = 1
title.Text = "ULTIMATE HUB"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16

-------------------------------------------------
-- STATES
-------------------------------------------------
local fly, esp, aura = false, false, false
local speed = 60

-------------------------------------------------
-- CREATE BUTTON FUNCTION
-------------------------------------------------
local function makeButton(text, posY, color)
	local b = Instance.new("TextButton")
	b.Parent = frame
	b.Size = UDim2.new(0.85,0,0,40)
	b.Position = UDim2.new(0.075,0,posY,0)
	b.Text = text
	b.BackgroundColor3 = color
	b.TextColor3 = Color3.new(1,1,1)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 14
	return b
end

-------------------------------------------------
-- BUTTONS
-------------------------------------------------
local flyBtn = makeButton("FLY OFF", 0.15, Color3.fromRGB(0,255,120))
local espBtn = makeButton("ESP OFF", 0.35, Color3.fromRGB(0,170,255))
local auraBtn = makeButton("AURA OFF", 0.55, Color3.fromRGB(255,80,80))
local tpBtn = makeButton("TP LOW HP", 0.75, Color3.fromRGB(255,170,0))

-------------------------------------------------
-- TP LOW HP
-------------------------------------------------
local function getLow()
	local target, hp = nil, math.huge

	for _,p in pairs(Players:GetPlayers()) do
		if p ~= player and p.Character then
			local h = p.Character:FindFirstChild("Humanoid")
			if h and h.Health < hp then
				hp = h.Health
				target = p
			end
		end
	end

	return target
end

tpBtn.MouseButton1Click:Connect(function()
	local t = getLow()
	if t and t.Character and player.Character then
		local root = player.Character:FindFirstChild("HumanoidRootPart")
		local tRoot = t.Character:FindFirstChild("HumanoidRootPart")

		if root and tRoot then
			root.CFrame = tRoot.CFrame + Vector3.new(0,3,0)
		end
	end
end)

-------------------------------------------------
-- ESP
-------------------------------------------------
local function createESP(plr)
	local bb = Instance.new("BillboardGui")
	bb.Size = UDim2.new(0,100,0,40)
	bb.AlwaysOnTop = true

	local txt = Instance.new("TextLabel")
	txt.Parent = bb
	txt.Size = UDim2.new(1,0,1,0)
	txt.BackgroundTransparency = 1
	txt.TextColor3 = Color3.fromRGB(0,255,0)
	txt.TextScaled = true

	RunService.RenderStepped:Connect(function()
		if esp and plr.Character and plr.Character:FindFirstChild("Head") then
			local hum = plr.Character:FindFirstChild("Humanoid")

			if hum then
				txt.Text = plr.Name.." | HP: "..math.floor(hum.Health)
				bb.Parent = plr.Character.Head
			end
		else
			bb.Parent = nil
		end
	end)
end

for _,p in pairs(Players:GetPlayers()) do
	if p ~= player then
		createESP(p)
	end
end

Players.PlayerAdded:Connect(function(p)
	task.wait(1)
	createESP(p)
end)

espBtn.MouseButton1Click:Connect(function()
	esp = not esp
	espBtn.Text = esp and "ESP ON" or "ESP OFF"
end)

-------------------------------------------------
-- AURA (DAMAGE)
-------------------------------------------------
RunService.RenderStepped:Connect(function()
	if not aura then return end

	local char = player.Character
	if not char then return end

	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	for _,p in pairs(Players:GetPlayers()) do
		if p ~= player and p.Character then
			local hrp = p.Character:FindFirstChild("HumanoidRootPart")
			local hum = p.Character:FindFirstChild("Humanoid")

			if hrp and hum and hum.Health > 0 then
				if (root.Position - hrp.Position).Magnitude <= 10 then
					hum:TakeDamage(5)
				end
			end
		end
	end
end)

auraBtn.MouseButton1Click:Connect(function()
	aura = not aura
	auraBtn.Text = aura and "AURA ON" or "AURA OFF"
end)

-------------------------------------------------
-- FLY (STABLE)
-------------------------------------------------
local flying = false
local bv, bg

flyBtn.MouseButton1Click:Connect(function()
	flying = not flying
	flyBtn.Text = flying and "FLY ON" or "FLY OFF"

	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local hum = char and char:FindFirstChild("Humanoid")

	if flying then
		if hum then hum.PlatformStand = true end

		bg = Instance.new("BodyGyro")
		bg.MaxTorque = Vector3.new(9e9,9e9,9e9)
		bg.Parent = hrp

		bv = Instance.new("BodyVelocity")
		bv.MaxForce = Vector3.new(9e9,9e9,9e9)
		bv.Parent = hrp

		RunService.RenderStepped:Connect(function()
			if flying and hrp then
				bg.CFrame = camera.CFrame

				local move = Vector3.zero

				if UIS:IsKeyDown(Enum.KeyCode.W) then move += camera.CFrame.LookVector end
				if UIS:IsKeyDown(Enum.KeyCode.S) then move -= camera.CFrame.LookVector end
				if UIS:IsKeyDown(Enum.KeyCode.A) then move -= camera.CFrame.RightVector end
				if UIS:IsKeyDown(Enum.KeyCode.D) then move += camera.CFrame.RightVector end

				bv.Velocity = move * speed
			end
		end)
	else
		if hum then hum.PlatformStand = false end
		if bv then bv:Destroy() end
		if bg then bg:Destroy() end
	end
end)
