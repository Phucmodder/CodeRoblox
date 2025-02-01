local ESPConfig = {
    Item = {
        Text = "[ITEM] ",
        Names = {"SilverChest", "DiamondChest", "Fruit", "GoldChest"},
        Enabled = true
    },
    TextSize = 14,
    LineThickness = 1,
    BoxThickness = 2
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
local character = player.Character or player.CharacterAdded:Wait()
local espItems = {}

local function UpdateESP()
    for item, elements in pairs(espItems) do
        local primaryPart = item:IsA("Model") and item.PrimaryPart or item
        if not primaryPart or not primaryPart.Parent then
            elements.line:Remove()
            elements.box:Remove()
            elements.text:Remove()
            espItems[item] = nil
            continue
        end

        local distance = (character.HumanoidRootPart.Position - primaryPart.Position).Magnitude
        local screenPos = Camera:WorldToViewportPoint(primaryPart.Position)
        
        elements.line.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
        elements.line.To = Vector2.new(screenPos.X, screenPos.Y)
        elements.line.Visible = true

        elements.box.Size = Vector2.new(40, 40)
        elements.box.Position = Vector2.new(screenPos.X - 20, screenPos.Y - 20)
        elements.box.Visible = true

        elements.text.Text = string.format("%s%s\n%.1f studs", 
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

ScanWorld()
RunService.Heartbeat:Connect(UpdateESP)

local TeleportConfig = {
    Speed = 210,
    Enabled = true
}

local function getNearestItem()
    local nearestItem = nil
    local nearestDistance = math.huge

    for _, item in pairs(workspace:GetDescendants()) do
        if table.find(ESPConfig.Item.Names, item.Name) and item:IsA("Model") then
            local itemPart = item:FindFirstChildWhichIsA("BasePart")
            if itemPart then
                local distance = (character.HumanoidRootPart.Position - itemPart.Position).Magnitude
                if distance < nearestDistance then
                    nearestDistance = distance
                    nearestItem = itemPart
                end
            end
        end
    end

    return nearestItem
end

local function enableNoClip()
    game:GetService("RunService").Stepped:Connect(function()
        for _, v in pairs(character:GetChildren()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end)
end
enableNoClip()

local function teleportToItem(targetItem)
    while targetItem and targetItem.Parent do
        local targetPosition = targetItem.Position + Vector3.new(0, 5, 0)
        local direction = (targetPosition - character.HumanoidRootPart.Position).unit
        local distance = (targetPosition - character.HumanoidRootPart.Position).Magnitude
        
        while distance > TeleportConfig.Speed do
            character.HumanoidRootPart.CFrame = CFrame.new(character.HumanoidRootPart.Position + direction * TeleportConfig.Speed)
            wait(0.5)
            distance = (targetPosition - character.HumanoidRootPart.Position).Magnitude
        end
        
        character.HumanoidRootPart.CFrame = CFrame.new(targetPosition)
        wait(0.5)
    end
end

local function startTeleport()
    while TeleportConfig.Enabled do
        local item = getNearestItem()
        if item then
            print("Teleporting to:", item.Name, "at", item.Position)
            teleportToItem(item)
        else
            print("Không tìm thấy item, tiếp tục quét...")
        end
        wait(0)
    end
end

player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    enableNoClip()
    ScanWorld()
end)

startTeleport()
