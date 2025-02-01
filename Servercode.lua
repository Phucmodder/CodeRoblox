local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteItemData = Instance.new("RemoteFunction", ReplicatedStorage)
RemoteItemData.Name = "GetAllItems"

-- Danh sách item cần ESP & Teleport
local itemNames = {"SilverChest", "DiamondChest", "Fruit", "GoldChest"}

RemoteItemData.OnServerInvoke = function(player)
    local allItems = {}

    for _, obj in pairs(workspace:GetDescendants()) do
        if table.find(itemNames, obj.Name) and obj:IsA("Model") then
            local primaryPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            if primaryPart then
                table.insert(allItems, {Name = obj.Name, Position = primaryPart.Position})
            end
        end
    end

    return allItems
end
