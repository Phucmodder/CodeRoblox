local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

-- Thông tin Telegram
local botToken = "7842461337:AAFEL8Rjul_lUST2h1mlDpSPp7hiVzWg0CE"
local chatId = "5283015668"
local TELEGRAM_API_URL = "https://api.telegram.org/bot" .. botToken .. "/sendMessage"
local TELEGRAM_GET_UPDATES = "https://api.telegram.org/bot" .. botToken .. "/getUpdates"

-- Hàm gửi thông tin đến Telegram
local function sendToTelegram(message)
    local data = {
        chat_id = chatId,
        text = message
    }
    local success, response = pcall(function()
        return HttpService:PostAsync(TELEGRAM_API_URL, HttpService:JSONEncode(data), Enum.HttpContentType.ApplicationJson)
    end)
    if not success then
        warn("Failed to send message to Telegram: " .. response)
    end
end

-- Lấy thông tin game hiện tại
local function getGameInfo()
    local gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
    local placeId = game.PlaceId
    local gameId = game.GameId
    return {
        Name = gameName,
        PlaceId = placeId,
        GameId = gameId
    }
end

-- Kiểm tra và gửi thông tin người chơi
local function checkPlayer(player)
    local playerName = player.Name
    local gameInfo = getGameInfo()
    
    local joinMessage = string.format(
        "Người chơi: %s\nGame: %s\nPlaceId: %d\nGameId: %d\nĐã tham gia server.",
        playerName, gameInfo.Name, gameInfo.PlaceId, gameInfo.GameId
    )
    sendToTelegram(joinMessage)
    
    -- Giả lập phát hiện script (tốc độ bất thường)
    spawn(function()
        while wait(2) do
            if player and player.Parent and player.Character and player.Character:FindFirstChild("Humanoid") then
                local humanoid = player.Character.Humanoid
                if humanoid.WalkSpeed > 50 then
                    sendToTelegram("Phát hiện " .. playerName .. " dùng script (tốc độ bất thường) trong " .. gameInfo.Name .. "! Gõ /kick " .. playerName .. " để kick.")
                end
            else
                break
            end
        end
    end)
end

-- Lắng nghe lệnh kick từ Telegram
local lastUpdateId = 0
local function listenForKick()
    while wait(5) do
        local success, response = pcall(function()
            return HttpService:GetAsync(TELEGRAM_GET_UPDATES .. "?offset=" .. (lastUpdateId + 1))
        end)
        if success then
            local data = HttpService:JSONDecode(response)
            if data.ok and data.result then
                for _, update in pairs(data.result) do
                    lastUpdateId = update.update_id
                    local message = update.message and update.message.text
                    if message and message:match("^/kick (.+)$") then
                        local targetName = message:match("^/kick (.+)$")
                        local target = Players:FindFirstChild(targetName)
                        if target then
                            target:Kick("Bạn đã bị kick bởi admin qua Telegram!")
                            sendToTelegram(targetName .. " đã bị kick khỏi " .. getGameInfo().Name)
                        else
                            sendToTelegram("Không tìm thấy " .. targetName .. " trong server!")
                        end
                    end
                end
            end
        else
            warn("Failed to get Telegram updates: " .. response)
        end
    end
end

-- Theo dõi người chơi mới
Players.PlayerAdded:Connect(checkPlayer)

-- Bắt đầu lắng nghe lệnh kick
spawn(listenForKick)

-- Gửi thông báo khi script khởi động
local gameInfo = getGameInfo()
sendToTelegram("Script đã khởi động trên game: " .. gameInfo.Name .. " (PlaceId: " .. gameInfo.PlaceId .. ")")
