local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-------------------------------------------------
-- CONFIG
-------------------------------------------------
local jumpOn = false
local espOn = false

-------------------------------------------------
-- GUI (simples)
-------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "MiniHub"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Parent = gui
frame.Size = UDim2.new(0, 220, 0, 180)
frame.Position = UDim2.new(0.5, -110, 0.5, -90)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.Active = true
frame.Draggable = true

Instance.new("UICorner", frame).CornerRadius = UDim.new(0,10)

-------------------------------------------------
-- BOTÕES
-------------------------------------------------
local function btn(text, y, color)
	local b = Instance.new("TextButton")
	b.Parent = frame
	b.Size = UDim2.new(0.9,0,0,40)
	b.Position = UDim2.new(0.05,0,y,0)
	b.Text = text
	b.BackgroundColor3 = color
	b.TextColor3 = Color3.new(1,1,1)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 14
	return b
end

local jumpBtn = btn("JUMP OFF", 0.05, Color3.fromRGB(120,120,255))
local espBtn = btn("ESP LINE OFF", 0.38, Color3.fromRGB(0,170,255))
local tpBtn = btn("TP LOW HP", 0.71, Color3.fromRGB(200,200,200))

-------------------------------------------------
-- PULO INFINITO
-------------------------------------------------
jumpBtn.MouseButton1Click:Connect(function()
	jumpOn = not jumpOn
	jumpBtn.Text = jumpOn and "JUMP ON" or "JUMP OFF"
end)

UIS.JumpRequest:Connect(function()
	if not jumpOn then return end

	local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
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
			local hum = p.Character:FindFirstChildOfClass("Humanoid")

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
		local myRoot = player.Character:FindFirstChild("HumanoidRootPart")
		local tRoot = t.Character:FindFirstChild("HumanoidRootPart")

		if myRoot and tRoot then
			myRoot.CFrame = tRoot.CFrame + Vector3.new(0,3,0)
		end
	end
end)

-------------------------------------------------
-- ESP LINE (BEAM)
-------------------------------------------------
local function createESP(plr)
	local beam = Instance.new("Beam")

	local a0 = Instance.new("Attachment")
	local a1 = Instance.new("Attachment")

	RunService.RenderStepped:Connect(function()
		if not espOn then
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
	espBtn.Text = espOn and "ESP LINE ON" or "ESP LINE OFF"
end)
