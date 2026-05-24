local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "MeuPainel"
gui.Parent = player:WaitForChild("PlayerGui")

-- FRAME PRINCIPAL
local main = Instance.new("Frame")
main.Parent = gui
main.Size = UDim2.new(0, 350, 0, 220)
main.Position = UDim2.new(0.5, -175, 0.5, -110)
main.BackgroundColor3 = Color3.fromRGB(25,25,25)
main.BorderSizePixel = 0

local corner = Instance.new("UICorner", main)
corner.CornerRadius = UDim.new(0,10)

-- TOPBAR
local top = Instance.new("Frame")
top.Parent = main
top.Size = UDim2.new(1,0,0,35)
top.BackgroundColor3 = Color3.fromRGB(35,35,35)
top.BorderSizePixel = 0

local topCorner = Instance.new("UICorner", top)
topCorner.CornerRadius = UDim.new(0,10)

-- TITULO
local title = Instance.new("TextLabel")
title.Parent = top
title.Size = UDim2.new(1,0,1,0)
title.BackgroundTransparency = 1
title.Text = "Meu Hub"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 18

-- BOTÃO
local button = Instance.new("TextButton")
button.Parent = main
button.Size = UDim2.new(0,200,0,45)
button.Position = UDim2.new(0.5,-100,0.5,-20)
button.Text = "Clique Aqui"
button.Font = Enum.Font.GothamBold
button.TextSize = 18
button.TextColor3 = Color3.new(1,1,1)
button.BackgroundColor3 = Color3.fromRGB(0,170,255)

local btnCorner = Instance.new("UICorner", button)
btnCorner.CornerRadius = UDim.new(0,8)

button.MouseButton1Click:Connect(function()
	print("Botão clicado!")
end)

-- BOTÃO FECHAR
local close = Instance.new("TextButton")
close.Parent = top
close.Size = UDim2.new(0,30,0,30)
close.Position = UDim2.new(1,-35,0,2)
close.Text = "X"
close.Font = Enum.Font.GothamBold
close.TextSize = 18
close.TextColor3 = Color3.new(1,1,1)
close.BackgroundColor3 = Color3.fromRGB(255,50,50)

local closeCorner = Instance.new("UICorner", close)
closeCorner.CornerRadius = UDim.new(1,0)

close.MouseButton1Click:Connect(function()
	main.Visible = false
end)

-- DRAG
local dragging
local dragInput
local dragStart
local startPos

top.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = main.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

top.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)

UIS.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		main.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)
