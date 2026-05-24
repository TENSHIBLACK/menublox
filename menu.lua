local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-------------------------------------------------
-- GUI
-------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "DevHub"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Parent = gui
frame.Size = UDim2.new(0, 320, 0, 260)
frame.Position = UDim2.new(0.5, -160, 0.5, -130)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.Active = true
frame.Draggable = true

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

-------------------------------------------------
-- MINIMIZAR
-------------------------------------------------
local mini = Instance.new("TextButton")
mini.Parent = frame
mini.Size = UDim2.new(0,30,0,30)
mini.Position = UDim2.new(1,-35,0,5)
mini.Text = "-"
mini.BackgroundColor3 = Color3.fromRGB(255,170,0)

local openBtn = Instance.new("TextButton")
openBtn.Parent = gui
openBtn.Size = UDim2.new(0,60,0,60)
openBtn.Position = UDim2.new(0,10,0.5,-30)
openBtn.Text = "OPEN"
openBtn.Visible = false

local minimized = false
mini.MouseButton1Click:Connect(function()
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
-- TP LOW HP
-------------------------------------------------
local tpBtn = Instance.new("TextButton")
tpBtn.Parent = frame
tpBtn.Size = UDim2.new(0.85,0,0,40)
tpBtn.Position = UDim2.new(0.075,0,0.1,0)
tpBtn.Text = "TP LOW HP"

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
		player.Character:MoveTo(t.Character.HumanoidRootPart.Position + Vector3.new(0,3,0))
	end
end)

-------------------------------------------------
-- FLY
-------------------------------------------------
local flyBtn = Instance.new("TextButton")
flyBtn.Parent = frame
flyBtn.Size = UDim2.new(0.85,0,0,40)
flyBtn.Position = UDim2.new(0.075,0,0.3,0)
flyBtn.Text = "FLY OFF"

local flying = false
local bv, bg

local function startFly()
	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	flying = true

	bg = Instance.new("BodyGyro")
	bg.MaxTorque = Vector3.new(9e9,9e9,9e9)
	bg.Parent = hrp

	bv = Instance.new("BodyVelocity")
	bv.MaxForce = Vector3.new(9e9,9e9,9e9)
	bv.Parent = hrp

	RunService.RenderStepped:Connect(function()
		if flying then
			bg.CFrame = camera.CFrame

			local move = Vector3.zero
			if UIS:IsKeyDown(Enum.KeyCode.W) then move += camera.CFrame.LookVector end
			if UIS:IsKeyDown(Enum.KeyCode.S) then move -= camera.CFrame.LookVector end
			if UIS:IsKeyDown(Enum.KeyCode.A) then move -= camera.CFrame.RightVector end
			if UIS:IsKeyDown(Enum.KeyCode.D) then move += camera.CFrame.RightVector end

			bv.Velocity = move * 60
		end
	end)
end

local function stopFly()
	flying = false
	if bv then bv:Destroy() end
	if bg then bg:Destroy() end
end

flyBtn.MouseButton1Click:Connect(function()
	if flying then
		stopFly()
		flyBtn.Text = "FLY OFF"
	else
		startFly()
		flyBtn.Text = "FLY ON"
	end
end)

-------------------------------------------------
-- ESP VIDA + LINE
-------------------------------------------------
local espEnabled = true
local lines = {}

local function createESP(plr)
	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(0,100,0,40)
	billboard.AlwaysOnTop = true

	local text = Instance.new("TextLabel")
	text.Size = UDim2.new(1,0,1,0)
	text.BackgroundTransparency = 1
	text.TextColor3 = Color3.fromRGB(0,255,0)
	text.TextScaled = true
	text.Parent = billboard

	local line = Drawing and Drawing.new("Line") or nil

	RunService.RenderStepped:Connect(function()
		if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
			local hrp = plr.Character.HumanoidRootPart
			local hum = plr.Character:FindFirstChild("Humanoid")

			if hum then
				text.Text = plr.Name .. " HP: " .. math.floor(hum.Health)

				billboard.Parent = plr.Character.Head
				billboard.Adornee = plr.Character.Head
			end

			if line then
				local pos, vis = camera:WorldToViewportPoint(hrp.Position)
				if vis then
					line.From = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y)
					line.To = Vector2.new(pos.X, pos.Y)
					line.Color = Color3.fromRGB(255,0,0)
				end
			end
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
