local ESPConfig = {
    Item = {
        Text = "[ITEM] ",
        Names = {"SilverChest", "DiamondChest", "Fruit", "GoldChest"}, -- Đã thêm GoldChest
        Enabled = true
    },
    TextSize = 14,
    LineThickness = 1,
    BoxThickness = 2
}

-- Bảng màu cho từng loại item
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

        -- Tính toán vị trí và khoảng cách (không giới hạn)
        local distance = (character.HumanoidRootPart.Position - primaryPart.Position).Magnitude
        local screenPos = Camera:WorldToViewportPoint(primaryPart.Position)
        
        -- Luôn hiển thị ESP bất kể vị trí
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
        
        -- Chọn màu theo tên item
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

-- Hàm quét vật phẩm tự động
local function ScanWorld()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if table.find(ESPConfig.Item.Names, obj.Name) then
            AddESP(obj)
        end
    end
end

-- Tự động cập nhật khi có vật phẩm mới
workspace.DescendantAdded:Connect(function(obj)
    if table.find(ESPConfig.Item.Names, obj.Name) then
        AddESP(obj)
    end
end)

-- Tự động xóa ESP khi vật phẩm biến mất
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
