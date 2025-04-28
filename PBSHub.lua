
-- << VARIABLES >> --

local InsertService = game:GetService("InsertService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local localPlayer = Players.LocalPlayer
local window = nil

if not _G.PBSHub then
	_G.PBSHub = {
		Window = nil,
		Connections = {},

		-- // Wall
		WallAutoGenerate = false,
		WallSizeX = 5,
		WallSizeY = 4,
		WallType = 1,

		-- // Magnet
		MagnetFollowMouse = true,
		MagnetMode = 4
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
		BorderColor = window:GetThemeKey("Border"),
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

window = ReGui:Window({ Title = "PBS Hub", Size = UDim2.fromOffset(400, 275) }):Center()
_G.PBSHub.Window = window


-- // Wall

local wallSection = createSection(window, "Walls")

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
	Items = { "Paper", "Door" },
	Selected = _G.PBSHub.WallType,
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

local magnetSection = createSection(window, "Walls")

magnetSection:Checkbox({
	Label = "FollowMouse",
	Value = _G.PBSHub.MagnetFollowMouse,
	Callback = function(self, value)
		_G.PBSHub.MagnetFollowMouse = value
	end,
})


magnetSection:Combo({
	Label = "MagnetMode",
	Items = { "All", "Wet Floor Sign", "Doors", "Papers" },
	Selected = _G.PBSHub.MagnetMode,
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
	Callback = function()
		attackTarget()
	end,
})
