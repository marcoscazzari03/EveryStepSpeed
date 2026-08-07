local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local portalFeedbackEvent =
	ReplicatedStorage:WaitForChild("PortalFeedback")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PortalUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 20
screenGui.Parent = playerGui

local currentPopup = nil

local function showLockedMessage(requiredLevel)
	-- Evita di avere più messaggi sovrapposti
	if currentPopup then
		currentPopup:Destroy()
		currentPopup = nil
	end

	local container = Instance.new("Frame")
	container.Name = "LockedPopup"
	container.AnchorPoint = Vector2.new(0.5, 0.5)
	container.Position = UDim2.fromScale(0.5, 0.42)
	container.Size = UDim2.fromOffset(460, 90)
	container.BackgroundColor3 = Color3.fromRGB(245, 245, 255)
	container.BorderSizePixel = 0
	container.Parent = screenGui

	currentPopup = container

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 18)
	corner.Parent = container

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 5
	stroke.Color = Color3.fromRGB(0, 0, 0)
	stroke.Parent = container

	local text = Instance.new("TextLabel")
	text.Name = "Message"
	text.BackgroundTransparency = 1
	text.Position = UDim2.fromOffset(15, 12)
	text.Size = UDim2.new(1, -30, 1, -24)
	text.Font = Enum.Font.Cartoon
	text.Text =
		"🔒 RICHIEDE LIVELLO "
		.. tostring(requiredLevel)
	text.TextColor3 = Color3.fromRGB(255, 95, 95)
	text.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	text.TextStrokeTransparency = 0
	text.TextScaled = true
	text.Parent = container

	-- Parte più piccolo
	container.Size = UDim2.fromOffset(360, 70)

	local appearTween = TweenService:Create(
		container,
		TweenInfo.new(
			0.22,
			Enum.EasingStyle.Back,
			Enum.EasingDirection.Out
		),
		{
			Size = UDim2.fromOffset(460, 90),
		}
	)

	appearTween:Play()

	task.wait(0.9)

	-- Il popup potrebbe essere già stato sostituito
	if not container.Parent then
		return
	end

	local fadeText = TweenService:Create(
		text,
		TweenInfo.new(0.3),
		{
			TextTransparency = 1,
			TextStrokeTransparency = 1,
		}
	)

	local fadeBox = TweenService:Create(
		container,
		TweenInfo.new(0.3),
		{
			BackgroundTransparency = 1,
		}
	)

	local fadeStroke = TweenService:Create(
		stroke,
		TweenInfo.new(0.3),
		{
			Transparency = 1,
		}
	)

	local moveTween = TweenService:Create(
		container,
		TweenInfo.new(
			0.3,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.In
		),
		{
			Position = UDim2.fromScale(0.5, 0.38),
		}
	)

	fadeText:Play()
	fadeBox:Play()
	fadeStroke:Play()
	moveTween:Play()

	moveTween.Completed:Wait()

	if currentPopup == container then
		currentPopup = nil
	end

	container:Destroy()
end

portalFeedbackEvent.OnClientEvent:Connect(function(requiredLevel)
	task.spawn(showLockedMessage, requiredLevel)
end)