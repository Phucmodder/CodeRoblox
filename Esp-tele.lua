local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local GetAllItems = ReplicatedStorage:WaitForChild("GetAllItems")

-- Cấu hình ESP
local ESPConfig = {
    Enabled = true,
    TextSize = 14,
    LineThickness = 1,
    BoxThickness = 2
}

-- Cấu hình Teleport
local TeleportConfig = {
    Speed = 300, -- Tốc độ teleport (mét mỗi lần)
    Delay = 1, -- Thời gian chờ giữa mỗi lần teleport
    Enabled = true
}

local ItemColors = {
    SilverChest = Color3.new(0.75, 0.75, 0.75),
    DiamondChest = Color3.new(0, 0.5, 1),
    Fruit = Color3.new(1, 0.5, 0),
    GoldChest = Color3.new(1, 0.84, 0)
}

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local espItems = {}

-- **Thông báo trên màn hình**
local function showNotification(msg, duration)
    local StarterGui = game:GetService("StarterGui")
    StarterGui:SetCore("SendNotification", {
        Title = "Thông báo",
        Text = msg,
        Duration = duration or 3
    })
end

-- **Bật NoClip để tránh va chạm**
local function enableNoClip()
    RunService.Stepped:Connect(function()
        for _, v in pairs(character:GetChildren()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end)
end
enableNoClip()

-- **Tạo ESP**
local function UpdateESP()
    for _, elements in pairs(espItems) do
        if ESPConfig.Enabled then
            local screenPos, onScreen = Camera:WorldToViewportPoint(elements.Position)
            
            elements.line.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
            elements.line.To = Vector2.new(screenPos.X, screenPos.Y)
            elements.line.Visible = true

            elements.box.Size = Vector2.new(40, 40)
            elements.box.Position = Vector2.new(screenPos.X - 20, screenPos.Y - 20)
            elements.box.Visible = true

            elements.text.Text = string.format("[ITEM] %s\n%.1f studs", 
                elements.Name, 
                (humanoidRootPart.Position - elements.Position).Magnitude
            )
            elements.text.Position = Vector2.new(screenPos.X, screenPos.Y + 20)
            elements.text.Visible = true
        else
            elements.line.Visible = false
            elements.box.Visible = false
            elements.text.Visible = false
        end
    end
end

local function AddESP(item)
    local color = ItemColors[item.Name] or Color3.new(1, 1, 1)

    espItems[item] = {
        Name = item.Name,
        Position = item.Position,
        line = Drawing.new("Line"),
        box = Drawing.new("Square"),
        text = Drawing.new("Text")
    }

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

-- **Lấy danh sách tất cả item từ server**
local function LoadAllItems()
    local allItems = GetAllItems:InvokeServer()
    
    for _, itemData in pairs(allItems) do
        AddESP(itemData)
    end
    showNotification("ESP đã bật! Đang quét toàn bộ server.", 5)
end

-- **Tìm item gần nhất**
local function getNearestItem()
    local nearestItem = nil
    local nearestDistance = math.huge

    for _, item in pairs(espItems) do
        local distance = (humanoidRootPart.Position - item.Position).Magnitude
        if distance < nearestDistance then
            nearestDistance = distance
            nearestItem = item
        end
    end

    return nearestItem
end

-- **Teleport Mượt Mà Không Bị Rollback**
local function smoothTeleport(targetPos)
    local distance = (humanoidRootPart.Position - targetPos).Magnitude
    local travelTime = distance / TeleportConfig.Speed

    local tweenInfo = TweenInfo.new(travelTime, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = CFrame.new(targetPos)})
    
    tween:Play()
    wait(travelTime + TeleportConfig.Delay)
end

-- **Auto Teleport**
local function startTeleport()
    showNotification("Auto Teleport Đã Bật!", 5)
    while TeleportConfig.Enabled do
        local item = getNearestItem()
        if item then
            print("Teleporting to:", item.Name, "at", item.Position)
            smoothTeleport(item.Position + Vector3.new(0, 5, 0)) -- Bay đến item
        else
            print("Không tìm thấy item, tiếp tục quét...")
        end
        wait(2)
    end
    showNotification("Auto Teleport Đã Tắt!", 3)
end

-- **Bật/Tắt ESP**
local function toggleESP()
    ESPConfig.Enabled = not ESPConfig.Enabled
    if ESPConfig.Enabled then
        showNotification("ESP Đã Bật!", 3)
    else
        showNotification("ESP Đã Tắt!", 3)
    end
end

-- **Bật/Tắt Teleport**
local function toggleTeleport()
    TeleportConfig.Enabled = not TeleportConfig.Enabled
    if TeleportConfig.Enabled then
        startTeleport()
    else
        showNotification("Auto Teleport Đã Tắt!", 3)
    end
end

-- **Auto cập nhật khi nhân vật hồi sinh**
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    enableNoClip()
end)

LoadAllItems()
RunService.Heartbeat:Connect(UpdateESP)
startTeleport()
