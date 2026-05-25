--// MENU MOBILE COMPLETO - ROBLOX LUAU

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "MobileMenu"
gui.ResetOnSpawn = false
gui.Parent = player.PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,240,0,380)
frame.Position = UDim2.new(0,20,0.5,-190)
frame.BackgroundColor3 = Color3.fromRGB(35,35,35)
frame.Active = true
frame.Draggable = true
frame.Parent = gui

Instance.new("UICorner", frame)

-- TITULO
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,-50,0,40)
title.Position = UDim2.new(0,10,0,5)
title.BackgroundTransparency = 1
title.Text = "MENU MOBILE"
title.TextScaled = true
title.TextColor3 = Color3.new(1,1,1)
title.Parent = frame

-- BOTÃO MINIMIZAR
local minimized = false

local minimize = Instance.new("TextButton")
minimize.Size = UDim2.new(0,40,0,40)
minimize.Position = UDim2.new(1,-45,0,5)
minimize.Text = "-"
minimize.TextScaled = true
minimize.BackgroundColor3 = Color3.fromRGB(255,170,0)
minimize.Parent = frame

Instance.new("UICorner", minimize)

-- BOTÃO FLY
local flyButton = Instance.new("TextButton")
flyButton.Size = UDim2.new(0,200,0,50)
flyButton.Position = UDim2.new(0,20,0,55)
flyButton.Text = "FLY OFF"
flyButton.TextScaled = true
flyButton.BackgroundColor3 = Color3.fromRGB(0,170,255)
flyButton.Parent = frame

Instance.new("UICorner", flyButton)

-- BOTÃO DESGRUDAR
local unstick = Instance.new("TextButton")
unstick.Size = UDim2.new(0,200,0,50)
unstick.Position = UDim2.new(0,20,0,115)
unstick.Text = "DESGRUDAR"
unstick.TextScaled = true
unstick.BackgroundColor3 = Color3.fromRGB(255,80,80)
unstick.Parent = frame

Instance.new("UICorner", unstick)

-- TEXTO
local label = Instance.new("TextLabel")
label.Size = UDim2.new(1,0,0,30)
label.Position = UDim2.new(0,0,0,175)
label.BackgroundTransparency = 1
label.Text = "JOGADORES"
label.TextScaled = true
label.TextColor3 = Color3.new(1,1,1)
label.Parent = frame

-- LISTA
local scrolling = Instance.new("ScrollingFrame")
scrolling.Size = UDim2.new(0,200,0,150)
scrolling.Position = UDim2.new(0,20,0,210)
scrolling.BackgroundColor3 = Color3.fromRGB(50,50,50)
scrolling.CanvasSize = UDim2.new(0,0,0,0)
scrolling.Parent = frame

Instance.new("UICorner", scrolling)

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0,5)
layout.Parent = scrolling

-- FLY
local flying = false
local flyConnection

flyButton.MouseButton1Click:Connect(function()

	flying = not flying

	if flying then

		flyButton.Text = "FLY ON"

		flyConnection = RunService.RenderStepped:Connect(function()

			if humanoid and hrp then

				hrp.Velocity = humanoid.MoveDirection * 80 + Vector3.new(0,2,0)

			end
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

-- GRUDAR
local alignPosition
local alignOrientation
local attachment0
local attachment1

local function unstickPlayer()

	if alignPosition then
		alignPosition:Destroy()
		alignPosition = nil
	end

	if alignOrientation then
		alignOrientation:Destroy()
		alignOrientation = nil
	end

	if attachment0 then
		attachment0:Destroy()
		attachment0 = nil
	end

	if attachment1 then
		attachment1:Destroy()
		attachment1 = nil
	end
end

local function stickPlayer(target)

	unstickPlayer()

	if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then

		local targetHRP = target.Character.HumanoidRootPart

		attachment0 = Instance.new("Attachment")
		attachment0.Parent = hrp

		attachment1 = Instance.new("Attachment")
		attachment1.Parent = targetHRP

		alignPosition = Instance.new("AlignPosition")
		alignPosition.Attachment0 = attachment0
		alignPosition.Attachment1 = attachment1
		alignPosition.RigidityEnabled = true
		alignPosition.MaxForce = 999999
		alignPosition.Responsiveness = 200
		alignPosition.Parent = hrp

		alignOrientation = Instance.new("AlignOrientation")
		alignOrientation.Attachment0 = attachment0
		alignOrientation.Attachment1 = attachment1
		alignOrientation.RigidityEnabled = true
		alignOrientation.MaxTorque = 999999
		alignOrientation.Responsiveness = 200
		alignOrientation.Parent = hrp

		hrp.CFrame = targetHRP.CFrame * CFrame.new(0,0,2)
	end
end

unstick.MouseButton1Click:Connect(function()
	unstickPlayer()
end)

-- ATUALIZAR JOGADORES
local function refreshPlayers()

	for _, v in pairs(scrolling:GetChildren()) do
		if v:IsA("TextButton") then
			v:Destroy()
		end
	end

	for _, plr in pairs(Players:GetPlayers()) do

		if plr ~= player then

			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(1,-5,0,40)
			btn.Text = plr.Name
			btn.TextScaled = true
			btn.BackgroundColor3 = Color3.fromRGB(70,70,70)
			btn.Parent = scrolling

			Instance.new("UICorner", btn)

			btn.MouseButton1Click:Connect(function()
				stickPlayer(plr)
			end)
		end
	end

	task.wait()

	scrolling.CanvasSize = UDim2.new(
		0,
		0,
		0,
		layout.AbsoluteContentSize.Y + 10
	)
end

refreshPlayers()

Players.PlayerAdded:Connect(refreshPlayers)
Players.PlayerRemoving:Connect(refreshPlayers)

-- MINIMIZAR
local original = frame.Size

minimize.MouseButton1Click:Connect(function()

	minimized = not minimized

	if minimized then

		frame.Size = UDim2.new(0,240,0,50)

		flyButton.Visible = false
		unstick.Visible = false
		scrolling.Visible = false
		label.Visible = false

		minimize.Text = "+"

	else

		frame.Size = original

		flyButton.Visible = true
		unstick.Visible = true
		scrolling.Visible = true
		label.Visible = true

		minimize.Text = "-"
	end
end)
