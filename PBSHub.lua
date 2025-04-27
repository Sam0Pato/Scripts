-- << VARIABLES >> --
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local localPlayer = Players.LocalPlayer
local mouse = localPlayer:GetMouse()

local paperFolder = workspace:FindFirstChild("PaperFolder") or Instance.new("Folder", workspace)
paperFolder.Name = "PaperFolder"

local mousePositionAttachment = workspace.Terrain:FindFirstChild("Target") or Instance.new("Attachment", workspace.Terrain)
mousePositionAttachment.Name = "Target"

local mouseHitAttachment = workspace.Terrain:FindFirstChild("Hit") or Instance.new("Attachment", workspace.Terrain)
mouseHitAttachment.Name = "Hit"

local debounce = false
local autoWall = false

-- << LOADING >> --
if _G.PBSHub then
	for _, connection in pairs(_G.PBSHub.Connections) do
		connection:Disconnect()
	end
	StarterGui:SetCore("SendNotification", {
		Title = "PBS Hub Reloaded ☑",
		Icon = "rbxassetid://89210547385522",
		Text = "Successfully reloaded!",
		Duration = 3
	})
else
	_G.PBSHub = { Connections = {} }
	StarterGui:SetCore("SendNotification", {
		Title = "PBS Hub Loaded 🥵👅",
		Icon = "rbxassetid://83150944197304",
		Text = "Press E to toggle walls\nPress Q to activate tools",
		Duration = 3
	})
end

-- << NETWORK CONTROL >> --
if not getgenv().Network then
	getgenv().Network = {
		BaseParts = {},
		Velocity = Vector3.new(14.46, 14.46, 14.46)
	}

	function Network.RetainPart(part)
		if part:IsA("BasePart") and part:IsDescendantOf(workspace) then
			part.CanCollide = false
			table.insert(Network.BaseParts, part)
		end
	end

	local function EnablePartControl()
		localPlayer.ReplicationFocus = workspace
		RunService.Heartbeat:Connect(function()
			sethiddenproperty(localPlayer, "SimulationRadius", math.huge)
			for _, part in pairs(Network.BaseParts) do
				if part:IsDescendantOf(workspace) then
					part.Velocity = Network.Velocity
				end
			end
		end)
	end
	EnablePartControl()
end

-- << MAIN FUNCTIONS >> --
local function activateTools()
	if debounce then return end
	debounce = true

	local backpack = localPlayer.Backpack
	for _, tool in ipairs(backpack:GetChildren()) do
		if tool.Name == "TpRoll" then
			tool.Parent = localPlayer.Character
			tool:Activate()
			tool.Parent = backpack
		end
	end

	task.wait(0.8)
	debounce = false
end

local function createWall()
	if not autoWall or debounce then return end
	debounce = true

	activateTools()
	task.wait(0.2)

	local papers = paperFolder:GetChildren()
	if #papers == 0 then
		debounce = false
		return
	end

	local cam = workspace.CurrentCamera
	local forward = (cam.CFrame.LookVector * Vector3.new(1, 0, 1)).Unit
	local right = Vector3.new(-forward.Z, 0, forward.X).Unit
	local startPos = mouseHitAttachment.WorldPosition

	local cols = math.ceil(math.sqrt(#papers))
	local rows = math.ceil(#papers / cols)
	local partSize = papers[1].Size

	for i, part in ipairs(papers) do
		for _, obj in ipairs(part:GetChildren()) do
			if obj:IsA("AlignPosition") or obj:IsA("AlignOrientation") then
				obj:Destroy()
			end
		end

		local col = (i - 1) % cols
		local row = math.floor((i - 1) / cols)
		local offset = right * (col - cols/2) * partSize.X + Vector3.new(0, row * partSize.Y, 0)

		local alignPos = Instance.new("AlignPosition")
		alignPos.ApplyAtCenterOfMass = true
		alignPos.RigidityEnabled = true
		alignPos.Position = startPos + offset
		alignPos.Parent = part

		local alignOri = Instance.new("AlignOrientation")
		alignPos.RigidityEnabled = true
		alignOri.CFrame = CFrame.lookAt(alignPos.Position, alignPos.Position + forward)
		alignOri.Parent = part
	end

	task.wait(0.8)
	debounce = false
end

-- << INPUT HANDLING >> --
local function onInputBegan(input, processed)
	if processed then return end

	if input.KeyCode == Enum.KeyCode.E then
		autoWall = not autoWall
		StarterGui:SetCore("SendNotification", {
			Title = "Auto Wall",
			Text = autoWall and "ENABLED" or "DISABLED",
			Duration = 2
		})
	elseif input.KeyCode == Enum.KeyCode.Q then
		activateTools()
	end
end

-- << SETUP >> --

table.insert(_G.PBSHub.Connections, UserInputService.InputBegan:Connect(onInputBegan))
table.insert(_G.PBSHub.Connections, mouse.Button1Down:Connect(function()
	mouseHitAttachment.WorldPosition = mouse.Hit.Position
end))
table.insert(_G.PBSHub.Connections, workspace.DescendantAdded:Connect(function(child)
	if child:IsA("BasePart") and child.Name == "Paper" then
		child.Parent = paperFolder
		Network.RetainPart(child)
	end
end))
table.insert(_G.PBSHub.Connections, RunService.Heartbeat:Connect(function()
	sethiddenproperty(localPlayer, "SimulationRadius", math.huge)
	
	if autoWall then
		createWall()
	end
end))

-- << FINAL INIT >> --
localPlayer.ReplicationFocus = workspace
