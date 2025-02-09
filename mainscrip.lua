local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local GuiService = game:GetService("GuiService")
local CoreGui = game:GetService("CoreGui")

-- 🔹 **Cấu hình link GitHub**
local KeyStorageUrl = "https://raw.githubusercontent.com/Phucmodder/CodeRoblox/refs/heads/main/Key.txt"  -- Thay USERNAME và REPO
local Script1Url = "https://raw.githubusercontent.com/Phucmodder/CodeRoblox/refs/heads/main/Esp.lua"
local Script2Url = "https://raw.githubusercontent.com/Phucmodder/CodeRoblox/refs/heads/main/Chest.lua"
local ThemeImageUrl = "https://raw.githubusercontent.com/Phucmodder/CodeRoblox/refs/heads/main/15413.jpg"  -- Thay bằng link ảnh theme của bạn

-- 🔹 **Lưu Key**
local function SaveKey(key)
    writefile("Key.txt", key)
end

local function LoadKey()
    if isfile("Key.txt") then
        return readfile("Key.txt")
    end
    return nil
end

-- 🔹 **Tạo GUI Menu Login**
local ScreenGui = Instance.new("ScreenGui", CoreGui)
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 350, 0, 200)
Frame.Position = UDim2.new(0.5, -175, 0.5, -100)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.BackgroundTransparency = 0.1
Frame.ClipsDescendants = true
Frame.ZIndex = 2
Frame.Visible = true

-- 🔹 **Bo góc menu**
local UICorner = Instance.new("UICorner", Frame)
UICorner.CornerRadius = UDim.new(0, 12)

-- 🔹 **Thêm ảnh nền**
local BackgroundImage = Instance.new("ImageLabel", Frame)
BackgroundImage.Size = UDim2.new(1, 0, 1, 0)
BackgroundImage.Position = UDim2.new(0, 0, 0, 0)
BackgroundImage.Image = ThemeImageUrl
BackgroundImage.ScaleType = Enum.ScaleType.Crop
BackgroundImage.BackgroundTransparency = 1

-- 🔹 **Phần giới thiệu**
local IntroText = Instance.new("TextLabel", Frame)
IntroText.Size = UDim2.new(1, -20, 0, 30)
IntroText.Position = UDim2.new(0.5, -150, 0, 10)
IntroText.Text = "Script Auto Farm Chest and Fruit được tạo bởi kênh Youtube\nPainter Mod và Híu Cày Thuê"
IntroText.TextColor3 = Color3.fromRGB(255, 255, 255) -- Màu chữ sáng đậm
IntroText.BackgroundTransparency = 1
IntroText.TextSize = 15
IntroText.TextWrapped = true
IntroText.Font = Enum.Font.SourceSansBold
IntroText.TextStrokeTransparency = 0.6  -- Độ trong suốt của viền (0 là không trong suốt)
IntroText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0) -- Màu viền chữ (đen)

-- 🔹 **Khung nhập key**
local TextBox = Instance.new("TextBox", Frame)
TextBox.Size = UDim2.new(0, 300, 0, 40)
TextBox.Position = UDim2.new(0.5, -150, 0.5, -20)
TextBox.PlaceholderText = "Nhập key..."
TextBox.Text = ""
TextBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TextBox.BorderSizePixel = 0
TextBox.TextSize = 16
TextBox.Font = Enum.Font.SourceSans
TextBox.ZIndex = 3

local UICornerTextBox = Instance.new("UICorner", TextBox)
UICornerTextBox.CornerRadius = UDim.new(0, 8)

-- 🔹 **Nút xác nhận**
local Button = Instance.new("TextButton", Frame)
Button.Size = UDim2.new(0, 150, 0, 40)
Button.Position = UDim2.new(0.5, -75, 0.7, 0)
Button.Text = "Xác Nhận"
Button.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
Button.TextColor3 = Color3.fromRGB(255, 255, 255)
Button.BorderSizePixel = 0
Button.TextSize = 16
Button.Font = Enum.Font.SourceSansBold
Button.ZIndex = 3

local UICornerButton = Instance.new("UICorner", Button)
UICornerButton.CornerRadius = UDim.new(0, 8)

-- 🔹 **Trạng thái**
local StatusLabel = Instance.new("TextLabel", Frame)
StatusLabel.Size = UDim2.new(0, 300, 0, 20)
StatusLabel.Position = UDim2.new(0.5, -150, 0.85, 0)
StatusLabel.Text = ""
StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextSize = 14
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.ZIndex = 3

-- 🔹 **Kiểm tra key**
local function CheckKey(key)
    local success, response = pcall(function()
        return game:HttpGet(KeyStorageUrl)
    end)
    
    if success and response then
        local validKeys = string.split(response, "\n")
        for _, v in ipairs(validKeys) do
            if key == v then
                return true
            end
        end
    end
    return false
end

-- 🔹 **Chạy Script**
local function RunScript(url)
    local success, response = pcall(function()
        return game:HttpGet(url)
    end)
    if success then
        loadstring(response)()
    end
end

-- 🔹 **Xử lý xác nhận key**
Button.MouseButton1Click:Connect(function()
    local inputKey = TextBox.Text
    if CheckKey(inputKey) then
        SaveKey(inputKey)
        ScreenGui:Destroy()
        
        -- 🔹 **Thông báo đã chạy script**
        local Notification = Instance.new("TextLabel", CoreGui)
        Notification.Size = UDim2.new(0, 400, 0, 50)
        Notification.Position = UDim2.new(0.5, -200, 0.1, 0)
        Notification.Text = "✅ Script đã được kích hoạt!"
        Notification.TextSize = 18
        Notification.TextColor3 = Color3.fromRGB(255, 255, 255)
        Notification.BackgroundTransparency = 0.5
        Notification.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        
        wait(3)
        Notification:Destroy()

        -- 🔹 **Chạy 2 script từ GitHub**
        RunScript(Script1Url)
        RunScript(Script2Url)
    else
        StatusLabel.Text = "❌ Key không hợp lệ!"
    end
end)

-- 🔹 **Tự động kiểm tra key đã lưu**
local SavedKey = LoadKey()
if SavedKey and CheckKey(SavedKey) then
    ScreenGui:Destroy()

    local Notification = Instance.new("TextLabel", CoreGui)
    Notification.Size = UDim2.new(0, 400, 0, 50)
    Notification.Position = UDim2.new(0.5, -200, 0.1, 0)
    Notification.Text = "✅ Script đã được kích hoạt!"
    Notification.TextSize = 18
    Notification.TextColor3 = Color3.fromRGB(255, 255, 255)
    Notification.BackgroundTransparency = 0.5
    Notification.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    
    wait(3)
    Notification:Destroy()

    -- 🔹 **Chạy 2 script từ GitHub**
    RunScript(Script1Url)
    RunScript(Script2Url)
end
