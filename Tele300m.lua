local ESPConfig = {
    Item = {
        Text = "[ITEM] ",
        Names = {"SilverChest", "DiamondChest", "Fruit", "GoldChest"},
        Enabled = true
    },
    TextSize = 14,
    LineThickness = 1,
    BoxThickness = 2,
    TeleportSpeed = 0.00000000001,
    MaxTeleportDistance = 250,
    TeleportDelay = 0
}

local ItemColors = {
    SilverChest = Color3.new(0.75, 0.75, 0.75),
    DiamondChest = Color3.new(0, 0.5, 1),
    Fruit = Color3.new(1, 0.5, 0),
    GoldChest = Color3.new(1, 0.84, 0)
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local player = Players.LocalPlayer
local espItems = {}
local noclipConnection = nil

-- Hệ thống quản lý nhân vật
local function getCurrentCharacter()
    return player.Character or player.CharacterAdded:Wait()
end

local function getHumanoidRootPart(character)
    return character:WaitForChild("HumanoidRootPart")
end

-- Cập nhật NoClip khi hồi sinh
local function setupNoClip(character)
    if noclipConnection then
        noclipConnection:Disconnect()
    end
    noclipConnection = RunService.Stepped:Connect(function()
        for _, v in pairs(character:GetChildren()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end)
end

-- Hệ thống ESP
local function UpdateESP()
    local character = getCurrentCharacter()
    local humanoidRootPart = getHumanoidRootPart(character)
    
    for item, elements in pairs(espItems) do
        local primaryPart = item:IsA("Model") and item.PrimaryPart or item
        if not primaryPart or not primaryPart.Parent then
            elements.line:Remove()
            elements.box:Remove()
            elements.text:Remove()
            espItems[item] = nil
            continue
        end

        local distance = (humanoidRootPart.Position - primaryPart.Position).Magnitude
        local screenPos = Camera:WorldToViewportPoint(primaryPart.Position)
        
        elements.line.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
        elements.line.To = Vector2.new(screenPos.X, screenPos.Y)
        elements.line.Visible = true

        elements.box.Size = Vector2.new(40, 40)
        elements.box.Position = Vector2.new(screenPos.X - 20, screenPos.Y - 20)
        elements.box.Visible = true

        elements.text.Text = string.format("%s%s\n%.1f met", 
            ESPConfig.Item.Text, 
            item.Name, 
            distance
        )
        elements.text.Position = Vector2.new(screenPos.X, screenPos.Y + 20)
        elements.text.Visible = true
    end
end

local function AddESP(item)
    if not espItems[item] then
        espItems[item] = {
            line = Drawing.new("Line"),
            box = Drawing.new("Square"),
            text = Drawing.new("Text")
        }

        local color = ItemColors[item.Name] or Color3.new(1, 1, 1)
        local elements = espItems[item]
        
        elements.line.Thickness = ESPConfig.LineThickness
        elements.line.Color = color
        
        elements.box.Thickness = ESPConfig.BoxThickness
        elements.box.Color = color
        elements.box.Filled = false
        
        elements.text.Size = ESPConfig.TextSize
        elements.text.Color = color
        elements.text.Outline = true
    end
end

-- Hệ thống quét vật phẩm
local function ScanWorld()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if table.find(ESPConfig.Item.Names, obj.Name) then
            AddESP(obj)
        end
    end
end

workspace.DescendantAdded:Connect(function(obj)
    if table.find(ESPConfig.Item.Names, obj.Name) then
        AddESP(obj)
    end
end)

workspace.DescendantRemoving:Connect(function(obj)
    if espItems[obj] then
        espItems[obj].line:Remove()
        espItems[obj].box:Remove()
        espItems[obj].text:Remove()
        espItems[obj] = nil
    end
end)

-- Hệ thống Teleport
local function getNearestItem()
    local character = getCurrentCharacter()
    local humanoidRootPart = getHumanoidRootPart(character)
    
    local nearestItem = nil
    local nearestDistance = math.huge

    for _, item in pairs(workspace:GetDescendants()) do
        if table.find(ESPConfig.Item.Names, item.Name) and item:IsA("Model") then
            local itemPart = item:FindFirstChildWhichIsA("BasePart")
            if itemPart and itemPart.Parent then
                local distance = (humanoidRootPart.Position - itemPart.Position).Magnitude
                if distance < nearestDistance then
                    nearestDistance = distance
                    nearestItem = itemPart
                end
            end
        end
    end
    return nearestItem
end

local function teleportToItem(targetItem)
    local character = getCurrentCharacter()
    local humanoidRootPart = getHumanoidRootPart(character)
    
    local startTime = tick()
    while targetItem and targetItem.Parent and (tick() - startTime) < 10 do
        if humanoidRootPart and targetItem then
            local direction = (targetItem.Position - humanoidRootPart.Position).Unit
            local distance = (targetItem.Position - humanoidRootPart.Position).Magnitude
            local stepDistance = math.min(distance, ESPConfig.MaxTeleportDistance)
            
            local newPosition = humanoidRootPart.Position + (direction * stepDistance)
            humanoidRootPart.CFrame = CFrame.new(newPosition)
            
            if distance <= 0 then
                break
            end
            
            task.wait(ESPConfig.TeleportDelay)
        end
    end
end

-- Khởi động hệ thống
player.CharacterAdded:Connect(function(character)
    setupNoClip(character)
    ScanWorld()
end)

setupNoClip(getCurrentCharacter())
ScanWorld()
RunService.Heartbeat:Connect(UpdateESP)

while true do
    local item = getNearestItem()
    if item then
        teleportToItem(item)
    end
    task.wait(0.5)
end
