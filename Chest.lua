local Player = game.Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local Material = loadstring(game:HttpGet("https://raw.githubusercontent.com/VanThanhIOS/VanThanhLuxucu/refs/heads/main/main.txt"))()
 
local Hub = Material.Load({
	Title = "PhucModder and Híu Cày Thuê",
	Style = 3,
	SizeX = 275,
	SizeY = 230,
	Theme = "Light",
	ColorOverrides = {
		MainFrame = Color3.fromRGB(235,235,235)
	}
})
 
local Home = Hub.New({
	Title = "Home"
})
 
_G.Tween = nil
_G.Play = false
_G.CloseAllScript = false

local ToggleAutoChest = Home.Toggle({
	Text = " Auto Chest",
	Callback = function(Value)
		_G.Play = Value
	end,
	Enabled = _G.Play
})

 
game:GetService('RunService').Stepped:connect(function()
	if _G.Play then
		local HumanoidRootPart = Player.Character:WaitForChild("HumanoidRootPart")
		local Humanoid = Player.Character:WaitForChild("Humanoid")
		HumanoidRootPart.Velocity = Vector3.new(0,0,0)
		for i,v in pairs(Player.Character:GetDescendants()) do
			if v:IsA("BasePart") then
				v.CanCollide = false
			end
		end
		Humanoid.Sit = false
	end
end)
 
function Tween(Part)
	if _G.Tween then
		_G.Tween:Cancel()
	end
	local HumanoidRootPart = Player.Character:WaitForChild("HumanoidRootPart")
	_G.Tween = game:GetService("TweenService"):Create(HumanoidRootPart,TweenInfo.new((Part.Position-HumanoidRootPart.Position).magnitude/499,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut),{CFrame = Part.CFrame})
	_G.Tween:Play()
	local flying = true
	while game:GetService("RunService").Stepped:Wait() and flying and _G.Play do
		if _G.Play == false then
			_G.Tween:Cancel()
		end
		if (Part.Position-HumanoidRootPart.Position).magnitude < 500 then
			_G.Tween:Cancel()
			for i = 1,5 do
				HumanoidRootPart.CFrame = Part.CFrame
				wait()
			end
			flying = false
		end
	end
end
 
function TableNearToFarChests()
	local HumanoidRootPart = Player.Character:WaitForChild("HumanoidRootPart")
	local chests = {}
	local checkedchests = {}
	local function Check(v)
		for i,e in pairs(checkedchests) do
			if v == e then
				return false
			end
		end
		return true
	end
	local function A(tablec)
		local nearest
		local sus
		for i,v in pairs(tablec) do
			local real = Check(v)
			if real then
				if nearest then
					if (v.Position-HumanoidRootPart.Position).magnitude < nearest then
                        nearest = (v.Position-HumanoidRootPart.Position).magnitude
						sus = v
					end
				else
					nearest = (v.Position-HumanoidRootPart.Position).magnitude
                    sus = v
				end
			end
		end
		return sus
	end
	local function B(tablec)
		local C = A(tablec)
		if C then
			table.insert(checkedchests,C)
			B(tablec)
		end
		return checkedchests
	end
	for i,v in pairs(workspace:GetDescendants()) do
		if v.Name == "Rocket Fruit" or v.Name == "Spin Fruit" or v.Name == "Blade Fruit" or v.Name == "Spring Fruit" or v.Name == "Bomb Fruit" or v.Name == "Smoke Fruit" or v.Name == "Spike Fruit" or v.Name == "Flame Fruit" or v.Name == "Falcon Fruit" or v.Name == "Ice Fruit" or v.Name == "Sand Fruit" or v.Name == "Dark Fruit" or v.Name == "Diamond Fruit" or v.Name == "Light Fruit" or v.Name == "Rubber Fruit" or v.Name == "Barrier Fruit" or v.Name == "Ghost Fruit" or v.Name == "Magma Fruit" or v.Name == "Quake Fruit" or v.Name == "Buddha Fruit" or v.Name == "Love Fruit" or v.Name == "Spider Fruit" or v.Name == "Sound Fruit" or v.Name == "Phoenix Fruit" or v.Name == "Portal Fruit" or v.Name == "Rumble Fruit" or v.Name == "Pain Fruit" or v.Name == "Blizzard Fruit" or v.Name == "Gravity Fruit" or v.Name == "Mammoth Fruit" or v.Name == "T-Rex Fruit" or v.Name == "Dough Fruit" or v.Name == "Shadow Fruit" or v.Name == "Venom Fruit" or v.Name == "Control Fruit" or v.Name == "Gas Fruit" or v.Name == "Spirit Fruit" or v.Name == "Leopard Fruit" or v.Name == "Yeti Fruit" or v.Name == "Kitsune Fruit" or v.Name == "Dragon Fruit" or v.Name == "Dragon (East) Fruit" or v.Name == "Dragon (West) Fruit" or v.Name == "Chest" or v.Name == "Chest1" or v.Name == "Chest2" or v.Name == "Chest3" then
			table.insert(chests,v)
		end
	end
	B(chests)
	return chests,checkedchests
end
 
repeat wait() until game:IsLoaded()
 
while wait(1) do
	if _G.Play then
		local chests,checkedchests = TableNearToFarChests()
		for i,v in pairs(checkedchests) do
			Tween(v)
			if _G.Play == false then
				break
			end
		end
	else
		if _G.Tween then
			_G.Tween:Cancel()
		end
	end
end
