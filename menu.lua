--// MOBILE PANEL COMPLETO - ROBLOX LUAU

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MobileMenu"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 240, 0, 380)
frame.Position = UDim2.new(0, 20, 0.5, -190)
frame.BackgroundColor3 = Color3.fromRGB(35,35,35)
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

Instance.new("UICorner", frame)

-- TÍTULO
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -50, 0, 40)
title.Position = UDim2.new(0, 10, 0, 5)
title.BackgroundTransparency = 1
title.Text = "MENU MOBILE"
title.TextScaled = true
title.TextColor3 = Color3.new(1,1,1)
title.Parent = frame

-- BOTÃO MINIMIZAR
local minimized = false

local minimizeButton = Instance.new("TextButton")
minimizeButton.Size = UDim2.new(0,40,0,40)
minimizeButton.Position = UDim2.new(1,-45,0,5)
minimizeButton.Text = "-"
minimizeButton.TextScaled = true
minimizeButton.BackgroundColor3 = Color3.fromRGB(255,170,0)
minimizeButton.Parent = frame

Instance.new("UICorner", minimizeButton)

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
local unstickButton = Instance.new("TextButton")
unstickButton.Size = UDim2.new(0,200,0,50)
unstickButton.Position = UDim2.new(0,20,0,115)
unstickButton.Text = "DESGRUDAR"
unstickButton.TextScaled = true
unstickButton.BackgroundColor3 = Color3.fromRGB(255,80,80)
unstickButton.Parent = frame

Instance.new("UICorner", unstickButton)

-- TEXTO LISTA
local playersLabel = Instance.new("TextLabel")
playersLabel.Size = UDim2.new(1,0,0,30)
playersLabel.Position = UDim2.new(0,0,0,175)
playersLabel.BackgroundTransparency = 1
playersLabel.Text = "JOGADORES"
playersLabel.TextScaled = true
playersLabel.TextColor3 = Color3.new(1,1,1)
playersLabel.Parent = frame

-- LISTA DE JOGADORES
local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Size = UDim2.new(0,200,0,150)
scrollingFrame.Position = UDim2.new(0,20,0,210)
scrollingFrame.CanvasSize = UDim2.new(0,0,0,0)
scrollingFrame.BackgroundColor3 = Color3.fromRGB(50,50,50)
scrollingFrame.Parent = frame

Instance.new("UICorner", scrollingFrame)

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0,5)
layout.Parent = scrollingFrame

-- FLY
local flying = false
local bodyVelocity

flyButton.MouseButton1Click:Connect(function()

	flying = not flying

	if flying then

		flyButton.Text = "FLY ON"

		bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.MaxForce = Vector3.new(999999,999999,999999)
		bodyVelocity.Velocity = Vector3.zero
		bodyVelocity.Parent = humanoidRootPart

	else

		flyButton.Text = "FLY OFF"

		if bodyVelocity then
			bodyVelocity:Destroy()
			bodyVelocity = nil
		end
	end
end)

RunService.RenderStepped:Connect(function()

	if flying and bodyVelocity then

		local moveDirection = humanoid.MoveDirection

		bodyVelocity.Velocity = moveDirection * 70
	end
end)

-- SISTEMA GRUDAR
local currentWeld = nil

local function stickToPlayer(targetPlayer)

	if targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then

		local targetHRP = targetPlayer.Character.HumanoidRootPart

		if currentWeld then
			currentWeld:Destroy()
		end

		local weld = Instance.new("WeldConstraint")
		weld.Part0 = humanoidRootPart
		weld.Part1 = targetHRP
		weld.Parent = humanoidRootPart

		currentWeld = weld

		humanoidRootPart.CFrame = targetHRP.CFrame * CFrame.new(0,0,2)
	end
end

-- DESGRUDAR
unstickButton.MouseButton1Click:Connect(function()

	if currentWeld then
		currentWeld:Destroy()
		currentWeld = nil
	end
end)

-- ATUALIZAR LISTA
local function refreshPlayerList()

	for _, child in pairs(scrollingFrame:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	for _, plr in pairs(Players:GetPlayers()) do

		if plr ~= player then

			local button = Instance.new("TextButton")
			button.Size = UDim2.new(1,-5,0,40)
			button.Text = plr.Name
			button.TextScaled = true
			button.BackgroundColor3 = Color3.fromRGB(70,70,70)
			button.Parent = scrollingFrame

			Instance.new("UICorner", button)

			button.MouseButton1Click:Connect(function()
				stickToPlayer(plr)
			end)
		end
	end

	task.wait()

	scrollingFrame.CanvasSize = UDim2.new(
		0,
		0,
		0,
		layout.AbsoluteContentSize.Y + 10
	)
end

refreshPlayerList()

Players.PlayerAdded:Connect(refreshPlayerList)
Players.PlayerRemoving:Connect(refreshPlayerList)

-- MINIMIZAR MENU
local originalSize = frame.Size

minimizeButton.MouseButton1Click:Connect(function()

	minimized = not minimized

	if minimized then

		frame.Size = UDim2.new(0,240,0,50)

		flyButton.Visible = false
		unstickButton.Visible = false
		scrollingFrame.Visible = false
		playersLabel.Visible = false

		minimizeButton.Text = "+"

	else

		frame.Size = originalSize

		flyButton.Visible = true
		unstickButton.Visible = true
		scrollingFrame.Visible = true
		playersLabel.Visible = true

		minimizeButton.Text = "-"
	end
end)
