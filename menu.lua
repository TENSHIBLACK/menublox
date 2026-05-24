local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-------------------------------------------------
-- GUI
-------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "FullHubFinal"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Parent = gui
frame.Size = UDim2.new(0, 320, 0, 380)
frame.Position = UDim2.new(0.5, -160, 0.5, -190)
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
title.Text = "FULL HUB PRO"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16

-------------------------------------------------
-- MINIMIZE
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
local noclipOn = false

local NORMAL_SPEED = 16
local BOOST_SPEED = 120

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

local speedBtn = makeButton("SPEED OFF", 0.10, Color3.fromRGB(255,170,0))
local espBtn = makeButton("ESP OFF", 0.22, Color3.fromRGB(0,170,255))
local auraBtn = makeButton("AURA OFF", 0.34, Color3.fromRGB(255,80,80))
local jumpBtn = makeButton("JUMP OFF", 0.46, Color3.fromRGB(120,120,255))
local tpBtn = makeButton("TP LOW HP", 0.58, Color3.fromRGB(200,200,200))
local noclipBtn = makeButton("NOCLIP OFF", 0.70, Color3.fromRGB(180,0,255))

-------------------------------------------------
-- SPEED FIX
-------------------------------------------------
local function applySpeed()
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.WalkSpeed = speedOn and BOOST_SPEED or NORMAL_SPEED
	end
end

speedBtn.MouseButton1Click:Connect(function()
	speedOn = not speedOn
	speedBtn.Text = speedOn and "SPEED ON" or "SPEED OFF"
	applySpeed()
end)

player.CharacterAdded:Connect(function(char)
	task.wait(0.3)
	applySpeed()
end)

-------------------------------------------------
-- JUMP
-------------------------------------------------
jumpBtn.MouseButton1Click:Connect(function()
	jumpOn = not jumpOn
	jumpBtn.Text = jumpOn and "JUMP ON" or "JUMP OFF"
end)

UIS.JumpRequest:Connect(function()
	if jumpOn then
		local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
	end
end)

-------------------------------------------------
-- TP LOW HP
-------------------------------------------------
local function getLow()
	local target, hp = nil, math.huge

	for _,p in pairs(Players:GetPlayers()) do
		if p ~= player and p.Character then
			local h = p.Character:FindFirstChildOfClass("Humanoid")
			if h and h.Health > 0 and h.Health < hp then
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
-- ESP + BEAM LINE (STUDIO SAFE)
-------------------------------------------------
local function createESP(plr)
	local beam = Instance.new("Beam")

	local a0 = Instance.new("Attachment")
	local a1 = Instance.new("Attachment")

	local bb = Instance.new("BillboardGui")
	bb.Size = UDim2.new(0,100,0,40)
	bb.AlwaysOnTop = true

	local txt = Instance.new("TextLabel")
	txt.Size = UDim2.new(1,0,1,0)
	txt.BackgroundTransparency = 1
	txt.TextColor3 = Color3.fromRGB(0,255,0)
	txt.TextScaled = true
	txt.Parent = bb

	RunService.RenderStepped:Connect(function()
		if not espOn then
			bb.Parent = nil
			beam.Enabled = false
			return
		end

		local char = plr.Character
		local myChar = player.Character

		if not char or not myChar then return end

		local head = char:FindFirstChild("Head")
		local myHead = myChar:FindFirstChild("Head")

		local hum = char:FindFirstChildOfClass("Humanoid")

		if head and myHead and hum then
			txt.Text = plr.Name.." | "..math.floor(hum.Health)
			bb.Parent = head

			a0.Parent = myHead
			a1.Parent = head

			beam.Attachment0 = a0
			beam.Attachment1 = a1
			beam.Color = ColorSequence.new(Color3.fromRGB(0,255,180))
			beam.Width0 = 0.1
			beam.Width1 = 0.1
			beam.Enabled = true
			beam.Parent = workspace.Terrain
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
-- AURA
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
			local hum = p.Character:FindFirstChildOfClass("Humanoid")

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

-------------------------------------------------
-- NOCLIP
-------------------------------------------------
noclipBtn.MouseButton1Click:Connect(function()
	noclipOn = not noclipOn
	noclipBtn.Text = noclipOn and "NOCLIP ON" or "NOCLIP OFF"
end)

RunService.Stepped:Connect(function()
	if noclipOn then
		local char = player.Character
		if char then
			for _,v in pairs(char:GetDescendants()) do
				if v:IsA("BasePart") then
					v.CanCollide = false
				end
			end
		end
	end
end)
