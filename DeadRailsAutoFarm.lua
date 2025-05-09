-- Auto Farm + UI + Extra Panel for Dead Rails -- Made for yee_kunkun

-- Services local Players = game:GetService("Players") local RunService = game:GetService("RunService") local UserInputService = game:GetService("UserInputService")

-- References local Player = Players.LocalPlayer local Character = Player.Character or Player.CharacterAdded:Wait() local Humanoid = Character:WaitForChild("Humanoid") local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart") local Camera = workspace.CurrentCamera

-- Drawing UI Circle local fov = 136 local FOVring = Drawing.new("Circle") FOVring.Visible = false FOVring.Thickness = 2 FOVring.Color = Color3.fromRGB(128, 0, 128) FOVring.Filled = false FOVring.Radius = fov FOVring.Position = Camera.ViewportSize / 2

-- Feature Toggles local isAiming = false local AutoBond = false local ShowExtra = false local UnlockFOV = false local WalkSpeed = 16

-- Valid NPC and Bond Lists local validNPCs = {} local raycastParams = RaycastParams.new() raycastParams.FilterType = Enum.RaycastFilterType.Blacklist raycastParams.FilterDescendantsInstances = {Character}

-- UI Creation local ScreenGui = Instance.new("ScreenGui") ScreenGui.Parent = game.CoreGui

local function createButton(text, position, callback) local btn = Instance.new("TextButton") btn.Size = UDim2.new(0, 160, 0, 40) btn.Position = position btn.Text = text btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30) btn.TextColor3 = Color3.fromRGB(255, 255, 255) btn.Font = Enum.Font.GothamBold btn.TextSize = 14 btn.Parent = ScreenGui btn.MouseButton1Click:Connect(function() callback(btn) end) return btn end

-- Button Callbacks local aimbotBtn = createButton("AIMBOT: OFF", UDim2.new(0, 10, 0, 10), function(btn) isAiming = not isAiming btn.Text = "AIMBOT: " .. (isAiming and "ON" or "OFF") FOVring.Visible = isAiming end)

local bondBtn = createButton("AUTO BOND: OFF", UDim2.new(0, 10, 0, 60), function(btn) AutoBond = not AutoBond btn.Text = "AUTO BOND: " .. (AutoBond and "ON" or "OFF") end)

local extraBtn = createButton("EXTRA: OFF", UDim2.new(0, 10, 0, 110), function(btn) ShowExtra = not ShowExtra btn.Text = "EXTRA: " .. (ShowExtra and "ON" or "OFF") extraPanel.Visible = ShowExtra end)

-- Extra Panel local extraPanel = Instance.new("Frame") extraPanel.Size = UDim2.new(0, 200, 0, 120) extraPanel.Position = UDim2.new(0, 10, 0, 160) extraPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 20) extraPanel.Visible = false extraPanel.Parent = ScreenGui

local fovToggle = createButton("FOV UNLOCK: OFF", UDim2.new(0, 10, 0, 160), function(btn) UnlockFOV = not UnlockFOV btn.Text = "FOV UNLOCK: " .. (UnlockFOV and "ON" or "OFF") end) fovToggle.Parent = extraPanel fovToggle.Position = UDim2.new(0, 10, 0, 10)

-- Slider local sliderFrame = Instance.new("Frame") sliderFrame.Size = UDim2.new(0, 180, 0, 40) sliderFrame.Position = UDim2.new(0, 10, 0, 60) sliderFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50) sliderFrame.Parent = extraPanel

local bar = Instance.new("Frame") bar.Size = UDim2.new(1, 0, 0, 6) bar.Position = UDim2.new(0, 0, 0.5, -3) bar.BackgroundColor3 = Color3.fromRGB(120, 120, 120) bar.Parent = sliderFrame

local dot = Instance.new("Frame") dot.Size = UDim2.new(0, 10, 0, 20) dot.Position = UDim2.new(0, 0, 0, 10) dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255) dot.Parent = sliderFrame

local dragging = false

local function updateSpeed(xPos) local barWidth = sliderFrame.AbsoluteSize.X local relative = math.clamp((xPos - sliderFrame.AbsolutePosition.X) / barWidth, 0, 1) dot.Position = UDim2.new(relative, -5, 0, 10) WalkSpeed = math.floor(1 + relative * 199) Humanoid.WalkSpeed = WalkSpeed end

sliderFrame.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true updateSpeed(input.Position.X) end end)

UserInputService.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then updateSpeed(input.Position.X) end end)

UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

-- Functions local function isBond(item) return item:IsA("BasePart") and item.Name:lower():find("bond") end

local function findNearestBond() local nearest, dist = nil, math.huge for _, obj in ipairs(workspace:GetDescendants()) do if isBond(obj) then local d = (obj.Position - HumanoidRootPart.Position).Magnitude if d < dist then nearest = obj dist = d end end end return nearest end

local function collectBond(bond) if bond then Character:MoveTo(bond.Position + Vector3.new(0, 2, 0)) firetouchinterest(HumanoidRootPart, bond, 0) firetouchinterest(HumanoidRootPart, bond, 1) end end

local function predictPos(npc) local root = npc:FindFirstChild("HumanoidRootPart") local head = npc:FindFirstChild("Head") if root and head then return root.Position + (head.Position - root.Position) + root.Velocity * 0.02 end end

local function getTarget() local closest, dist = nil, math.huge local center = Camera.ViewportSize / 2 for _, npc in ipairs(validNPCs) do local pos = predictPos(npc) if pos then local screen, onScreen = Camera:WorldToViewportPoint(pos) if onScreen then local d = (Vector2.new(screen.X, screen.Y) - center).Magnitude if d < dist and d < fov then closest = npc dist = d end end end end return closest end

local function aimAt(pos) local cf = Camera.CFrame local dir = (pos - cf.Position).Unit Camera.CFrame = CFrame.new(cf.Position, cf.Position + cf.LookVector:Lerp(dir, 0.6)) end

-- Heartbeat Loop RunService.Heartbeat:Connect(function() if isAiming then local t = getTarget() if t then local pos = predictPos(t) if pos then aimAt(pos) end end end

if AutoBond then
    local bond = findNearestBond()
    if bond then
        collectBond(bond)
    end
end

if UnlockFOV then
    FOVring.Radius = fov * (Camera.ViewportSize.Y / 1080)
    FOVring.Position = Camera.ViewportSize / 2
end

end)

-- Update valid NPCs periodically local function isNPC(obj) return obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") end

local function refreshNPCs() validNPCs = {} for _, obj in ipairs(workspace:GetDescendants()) do if isNPC(obj) then table.insert(validNPCs, obj) end end end

refreshNPCs() workspace.DescendantAdded:Connect(function(obj) if isNPC(obj) then table.insert(validNPCs, obj) end end)

