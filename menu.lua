local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-------------------------------------------------
-- GUI
-------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "FullHub"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Parent = gui
frame.Size = UDim2.new(0, 300, 0, 360)
frame.Position = UDim2.new(0.5, -150, 0.5, -180)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.Active = true
frame.Draggable = true

Instance.new("UICorner", frame).CornerRadius = UDim.new(0,10)

-------------------------------------------------
-- TOP BAR
-------------------------------------------------
local top = Instance.new("Frame")
top.Parent = frame
top.Size = UDim2.new(1,0,0,35)
top.BackgroundColor3 = Color3.fromRGB(35,35,35)

Instance.new("UICorner", top).CornerRadius = UDim.new(0,10)

local title = Instance.new("TextLabel")
title.Parent = top
title.Size = UDim2.new(1,0,1,0)
title.BackgroundTransparency = 1
title.Text = "FULL HUB"
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
local speedOn = false
local espOn = false
local auraOn = false
local jumpOn = false

local NORMAL_SPEED = 16
local BOOST_SPEED = 120

-------------------------------------------------
-- BUTTONS
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

local speedBtn = makeButton("SPEED OFF", 0.12, Color3.fromRGB(255,170,0))
local espBtn = makeButton("ESP OFF", 0.28, Color3.fromRGB(0,170,255))
local auraBtn = makeButton("AURA OFF", 0.44, Color3.fromRGB(255,80,80))
local jumpBtn = makeButton("JUMP OFF", 0.60, Color3.fromRGB(120,120,255))
local tpBtn = makeButton("TP LOW HP", 0.76, Color3.fromRGB(200,200,200))

-------------------------------------------------
-- SPEED (FIXADO)
-------------------------------------------------
local function updateSpeed()
	local char = player.Character
	local hum = char and char:FindFirstChild("Humanoid")

	if hum then
		hum.WalkSpeed = speedOn and BOOST_SPEED or NORMAL_SPEED
	end
end

speedBtn.MouseButton1Click:Connect(function()
	speedOn = not speedOn
	speedBtn.Text = speedOn and "SPEED ON" or "SPEED OFF"
	updateSpeed()
end)

player.CharacterAdded:Connect(function()
	task.wait(0.5)
	updateSpeed()
end)

-------------------------------------------------
-- JUMP INFINITO
-------------------------------------------------
jumpBtn.MouseButton1Click:Connect(function()
	jumpOn = not jumpOn
	jumpBtn.Text = jumpOn and "JUMP ON" or "JUMP OFF"
end)

UIS.JumpRequest:Connect(function()
	if not jumpOn then return end

	local char = player.Character
	local hum = char and char:FindFirstChild("Humanoid")

	if hum then
		hum:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

-------------------------------------------------
-- TP LOW HP
-------------------------------------------------
local function getLowHP()
	local target = nil
	local lowest = math.huge

	for _,p in pairs(Players:GetPlayers()) do
		if p ~= player and p.Character then
			local hum = p.Character:FindFirstChild("Humanoid")

			if hum and hum.Health > 0 and hum.Health < lowest then
				lowest = hum.Health
				target = p
			end
		end
	end

	return target
end

tpBtn.MouseButton1Click:Connect(function()
	local t = getLowHP()

	if t and t.Character and player.Character then
		local r = player.Character:FindFirstChild("HumanoidRootPart")
		local tr = t.Character:FindFirstChild("HumanoidRootPart")

		if r and tr then
			r.CFrame = tr.CFrame + Vector3.new(0,3,0)
		end
	end
end)

-------------------------------------------------
-- ESP (OPTIMIZADO)
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
		if espOn and plr.Character and plr.Character:FindFirstChild("Head") then
			local hum = plr.Character:FindFirstChild("Humanoid")

			if hum then
				txt.Text = plr.Name.." | "..math.floor(hum.Health)
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
	espOn = not espOn
	espBtn.Text = espOn and "ESP ON" or "ESP OFF"
end)

-------------------------------------------------
-- AURA (SEM LAG PESADO)
-------------------------------------------------
RunService.RenderStepped:Connect(function()
	if not auraOn then return end

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
					hum:TakeDamage(4)
				end
			end
		end
	end
end)

auraBtn.MouseButton1Click:Connect(function()
	auraOn = not auraOn
	auraBtn.Text = auraOn and "AURA ON" or "AURA OFF"
end)
