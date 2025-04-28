
-- << VARIABLES >> --

local InsertService = game:GetService("InsertService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local localPlayer = Players.LocalPlayer

if not _G.PBSHub then	
	_G.PBSHub = {
		Window = nil,
		Connetions = {},

		-- // Wall
		WallAutoGenerate = false,
		WallSizeX = 5,
		WallSizeY = 4,
		WallType = "Paper",

		-- // Magnet
		MagnetFollowMouse = true,
		MagnetMode = "Paper"
	}
else
	_G.PBSHub.Window:Close()
	
	for _,conn in pairs(_G.PBSHub.Connections) do
		conn:Disconnect()
	end
end

-- << FUNCTIONS >> --

local function generatePaper()
	local backpack = localPlayer.Backpack
	
	for _, tool in next, backpack:GetChildren() do
		if tool.Name == "TpRoll" then
			tool.Parent = localPlayer.Character
			tool:Activate()
			tool.Parent = backpack
		end
	end
end


local function createSection(Parent, Title)
	local Region = Parent:Region({
		Border = true,
		BorderColor = _G.PBSHub.Window:GetThemeKey("Border"),
		BorderThickness = 1,
		CornerRadius = UDim.new(0, 5)
	})

	Region:Label({
		Text = Title
	})

	return Region
end

-- << MAIN >> --

local function generateWall()
	generatePaper()
end


local function attackTarget()
	generatePaper()
end

-- << INTERFACE >> --

local ReGui = loadstring(game:HttpGet('https://raw.githubusercontent.com/depthso/Dear-ReGui/refs/heads/main/ReGui.lua'))()
local PrefabsId = "rbxassetid://" .. ReGui.PrefabsId
ReGui:Init({
	Prefabs = InsertService:LoadLocalAsset(PrefabsId)
})

_G.PBSHub.Window = ReGui:Window({
	Title = "PBS Script",
	Size = UDim2.new(0, 400, 0, 250),
	NoClose = true,
}):Center()


-- // Wall

local wallSection = createSection(_G.PBSHub.Window, "Walls")

wallSection:Checkbox({
	Label = "AutoWallEnabled",
	Value = _G.PBSHub.WallAutoGenerate,
	Callback = function(self, value)
		_G.PBSHub.WallAutoGenerate = value
	end,
})
	
	
wallSection:InputInt({
	Label = "WallSizeX",
	Value = _G.PBSHub.WallSizeX,
	Maximum = 100,
	Minimum = 1,
	Callback = function(self, value)
		_G.PBSHub.WallSizeX = value
	end
})


wallSection:InputInt({
	Label = "WallSizeY",
	Value = _G.PBSHub.WallSizeY,
	Maximum = 100,
	Minimum = 1,
	Callback = function(self, value)
		_G.PBSHub.WallSizeY = value
	end
})


wallSection:Combo({
	Label = "WallType",
	Selected = _G.PBSHub.WallType,
	Items = { "Paper", "Door" },
	Callback = function(self, value)
		_G.PBSHub.WallType = value
	end
})


wallSection:Button({
	Label = "Generate Wall",
	Callback = function()
		generateWall()
	end
})


-- // Magnet

local magnetSection = createSection(_G.PBSHub.Window, "Walls")

magnetSection:Checkbox({
	Label = "FollowMouse",
	Value = _G.PBSHub.MagnetFollowMouse,
	Callback = function(self, value)
		_G.PBSHub.MagnetFollowMouse = value
	end,
})


magnetSection:Combo({
	Label = "MagnetMode",
	Selected = _G.PBSHub.MagnetMode,
	Items = { "All", "Wet Floor Sign", "Doors", "Papers" },
	Callback = function(self, value)
		_G.PBSHub.MagnetMode = value
	end,
})


magnetSection:Combo({
	Label = "Target",
	PlaceHolder = "JustinBiever79070",
	Items = function() return Players:GetPlayers() end,
	Callback = function(self, value)
	end,
})


magnetSection:Button({
	Label = "Attack Target",
	Selected = Players:GetPlayers()[1],
	Items = function() return Players:GetPlayers() end,
	Callback = function()
		attackTarget()
	end,
})
