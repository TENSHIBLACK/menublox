local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "MobileHub"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- FRAME PRINCIPAL
local main = Instance.new("Frame")
main.Parent = gui
main.Size = UDim2.new(0.8,0,0.45,0)
main.Position = UDim2.new(0.1,0,0.25,0)
main.BackgroundColor3 = Color3.fromRGB(25,25,25)
main.BorderSizePixel = 0

local corner = Instance.new("UICorner", main)
corner.CornerRadius = UDim.new(0,12)

-- TOPO
local top = Instance.new("Frame")
top.Parent = main
top.Size = UDim2.new(1,0,0,40)
top.BackgroundColor3 = Color3.fromRGB(40,40,40)
top.BorderSizePixel = 0

local topCorner = Instance.new("UICorner", top)
topCorner.CornerRadius = UDim.new(0,12)

-- TITULO
local title = Instance.new("TextLabel")
title.Parent = top
title.Size = UDim2.new(1,0,1,0)
title.BackgroundTransparency = 1
title.Text = "Mobile Hub"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextScaled = true

-- BOTÃO
local button = Instance.new("TextButton")
button.Parent = main
button.Size = UDim2.new(0.7,0,0.2,0)
button.Position = UDim2.new(0.15,0,0.4,0)
button.BackgroundColor3 = Color3.fromRGB(0,170,255)
button.Text = "ATIVAR"
button.TextColor3 = Color3.new(1,1,1)
button.Font = Enum.Font.GothamBold
button.TextScaled = true

local btnCorner = Instance.new("UICorner", button)
btnCorner.CornerRadius = UDim.new(0,10)

button.MouseButton1Click:Connect(function()
	print("Botão mobile clicado")
end)

-- FECHAR
local close = Instance.new("TextButton")
close.Parent = top
close.Size = UDim2.new(0,35,0,35)
close.Position = UDim2.new(1,-40,0,2)
close.Text = "X"
close.TextScaled = true
close.Font = Enum.Font.GothamBold
close.BackgroundColor3 = Color3.fromRGB(255,60,60)
close.TextColor3 = Color3.new(1,1,1)

local closeCorner = Instance.new("UICorner", close)
closeCorner.CornerRadius = UDim.new(1,0)

close.MouseButton1Click:Connect(function()
	gui.Enabled = false
end)

-- DRAG MOBILE
local dragging = false
local dragStart
local startPos

top.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = main.Position
	end
end)

top.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

UIS.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.Touch then
		local delta = input.Position - dragStart

		main.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)
