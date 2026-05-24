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
frame.Size = UDim2.new(0, 320, 0, 360)
frame.Position = UDim2.new(0.5, -160, 0.5, -180)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.Active = true
frame.Draggable = true

Instance.new("UICorner", frame).CornerRadius = UDim.new(0,10)

-------------------------------------------------
-- TOP BAR
-------------------------------------------------
local top = Instance.new("Frame")
top.Parent = frame
top.Size = UDim2.new(1,0,0,35)
top.BackgroundColor3 = Color3.fromRGB(40,40,40)

Instance.new("UICorner", top).CornerRadius = UDim.new(0,10)

local title = Instance.new("TextLabel")
title.Parent = top
title.Size = UDim2.new(1,0,1,0)
title.BackgroundTransparency = 1
title.Text = "ULTIMATE HUB"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16

-------------------------------------------------
-- MINIMIZAR
-------------------------------------------------
local minimized = false

local miniBtn = Instance.new("TextButton")
miniBtn.Parent = top
miniBtn.Size = UDim2.new(0,30,0,30)
miniBtn.Position = UDim2.new(1,-35,0,2)
miniBtn.Text = "-"

local openBtn = Instance.new("TextButton")
openBtn.Parent = gui
openBtn.Size = UDim2.new(0,60,0,60)
openBtn.Position = UDim2.new(0,10,0.5,-30)
openBtn.Text = "OPEN"
openBtn.Visible = false

miniBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	frame.Visible = not minimized
	openBtn.Visible = minimized
end)

openBtn.MouseButton1Click:Connect(function()
	minimized = false
	frame.Visible = true
	openBtn.Visible = false
end)

-------------------------------------------------
-- CONFIG
-------------------------------------------------
local fly, esp, aura = false, false, false
local speed = 50
local jumpEnabled = false

-------------------------------------------------
-- BUTTON FACTORY
-------------------------------------------------
local function makeButton(text, y, color)
	local b = Instance.new("TextButton")
	b.Parent = frame
	b.Size = UDim2.new(0.85,0,0,35)
	b.Position = UDim2.new(0.075,0,y,0)
	b.Text = text
	b.BackgroundColor3 = color
	b.TextColor3 = Color3.new(1,1,1)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 14
	return b
end

local flyBtn = makeButton("FLY OFF", 0.1, Color3.fromRGB(0,255,120))
local espBtn = makeButton("ESP OFF", 0.22, Color3.fromRGB(0,170,255))
local auraBtn = makeButton("AURA OFF", 0.34, Color3.fromRGB(255,80,80))
local speedBtn = makeButton("SPEED OFF", 0.46, Color3.fromRGB(255,170,0))
local jumpBtn = makeButton("JUMP OFF", 0.58, Color3.fromRGB(120,120,255))
local tpBtn = makeButton("TP LOW HP", 0.70, Color3.fromRGB(200,200,200))

-------------------------------------------------
-- SPEED
-------------------------------------------------
speedBtn.MouseButton1Click:Connect(function()
	speed = speed == 50 and 120 or 50
	speedBtn.Text = speed == 50 and "SPEED OFF" or "SPEED ON"
end)

RunService.RenderStepped:Connect(function()
	local char = player.Character
	local hum = char and char:FindFirstChild("Humanoid")
	if hum then
		hum.WalkSpeed = speed
	end
end)

-------------------------------------------------
-- INFINITE JUMP
-------------------------------------------------
jumpBtn.MouseButton1Click:Connect(function()
	jumpEnabled = not jumpEnabled
	jumpBtn.Text = jumpEnabled and "JUMP ON" or "JUMP OFF"
end)

UIS.JumpRequest:Connect(function()
	if jumpEnabled then
		local char = player.Character
		local hum = char and char:FindFirstChild("Humanoid")
		if hum then
			hum:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end
end)

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
		local r = player.Character:FindFirstChild("HumanoidRootPart")
		local tr = t.Character:FindFirstChild("HumanoidRootPart")
		if r and tr then
			r.CFrame = tr.CFrame + Vector3.new(0,3,0)
		end
	end
end)

-------------------------------------------------
-- AURA
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
				txt.Text = plr.Name.." HP: "..math.floor(hum.Health)
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
-- FLY
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

				bv.Velocity = move * 60
			end
		end)
	else
		if hum then hum.PlatformStand = false end
		if bv then bv:Destroy() end
		if bg then bg:Destroy() end
	end
end)
