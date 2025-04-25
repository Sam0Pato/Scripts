
-- << VARIABLES >> --

local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")

local localPlayer = game:GetService("Players").LocalPlayer
local mouse = localPlayer:GetMouse()

local debounce = false
local paperTable = {}


-- << LOADING >> --

if _G.PBSHub then
	for _, connection in pairs(_G.PBSHub.Connections) do	
		connection:Disconnect()
	end

	StarterGui:SetCore("SendNotification", {
		Title = "PBS Hub by samopato",
		Text = "RELOADED ☑",
		Icon = "rbxassetid://89210547385522",
		Duration = 5
	})
else
	StarterGui:SetCore("SendNotification", {
		Title = "PBS Hub by samopato",
		Text = "Loaded 👅👅👅",
		Icon = "rbxassetid://89210547385522",
		Duration = 3
	})

	_G.PBSHub = { Connections = {} }
end


-- << PART CLAIM >> --

if not getgenv().Network then
	getgenv().Network = {
		BaseParts = {},
		Velocity = Vector3.new(14.46262424, 14.46262424, 14.46262424)
	}

	Network.RetainPart = function(Part)
		if typeof(Part) == "Instance" and Part:IsA("BasePart") and Part:IsDescendantOf(Workspace) then
			table.insert(Network.BaseParts, Part)
			Part.CustomPhysicalProperties = PhysicalProperties.new(0.0001, 0.0001, 0.0001, 0.0001, 0.0001)
			Part.CanCollide = false
		end
	end

	local function EnablePartControl()
		localPlayer.ReplicationFocus = workspace

		RunService.Heartbeat:Connect(function()
			sethiddenproperty(localPlayer, "SimulationRadius", math.huge)
			for _, Part in pairs(Network.BaseParts) do
				if Part:IsDescendantOf(workspace) then
					Part.Velocity = Network.Velocity
				end
			end
		end)
	end

	EnablePartControl()
end


-- << MAIN >> --

local function activateTools()
	debounce = true

	local backpack = localPlayer.Backpack

	for _, tool in ipairs(backpack:GetChildren()) do
		if tool.Name ~= "TpRoll" then
			continue
		end

		tool.Parent = localPlayer.Character	
		task.spawn(function()
			tool:Activate()
			tool.Parent = backpack
		end)
	end

	task.wait(1)

	debounce = false
end


local function makeWall(desiredCols, desiredRows)
	local totalParts = #paperTable
	
	if totalParts == 0 then
		return
	end

	local startPos = mouse.Hit.Position
	local samplePart = paperTable[1]
	local partWidth = samplePart.Size.Z 
	local partHeight = samplePart.Size.X

	local cols = desiredCols or math.ceil(math.sqrt(totalParts))
	local rows = desiredRows or math.ceil(totalParts / cols)

	local totalWidth = cols * partWidth
	local totalHeight = rows * partHeight

	local camForward = (camera.CFrame.LookVector * Vector3.new(1, 0, 1)).Unit
	local camRight = Vector3.new(-camForward.Z, 0, camForward.X).Unit

	for i = 1, totalParts do
		local part = paperTable[i]

		local col = (i - 1) % cols
		local row = math.floor((i - 1) / cols)

		local offsetX = (col * partHeight) - (totalWidth / 2) + (partHeight / 2)
		local offsetY = (row * partWidth) + (partWidth / 2)

		local pos = startPos + camRight * offsetX + Vector3.new(0, offsetY, 0)

		local faceCFrame = CFrame.lookAt(pos, pos + camForward)
		part.CFrame = faceCFrame * CFrame.Angles(math.rad(-90), 0, 0)

		part.Anchored = true
	end
end


local function onInputBegan(input, processed)
	if processed then
		return
	end

	if debounce then 
		return
	end

	if input.KeyCode.Name == "E" then
		makeWall()
		return
	end

	if input.KeyCode.Name == "Q" then
		activateTools()
		return
	end

	localPlayer.ReplicationFocus = workspace
end


-- << SETUP >> --

local function onRenderStepped()
	local hit = mouse.Hit.Position    
	local mousePosition = Vector3.new(hit.X, hit.Y + 2.5, hit.Z)

	for _,child: BasePart in pairs(paperTable) do
		if not child then
			continue
		end

		sethiddenproperty(localPlayer, "SimulationRadius", math.huge)
		--child.Velocity = Vector3.new(math.random(1, 100), math.random(1, 100), math.random(1, 100))
		--child.BodyPosition.Position = mousePosition
	end
end 

local function onChildAdded(child: Instance)
	if not child:IsA("BasePart") then
		return
	end

	if not string.find(child.Name, localPlayer.Name) then
		return
	end

	child.CanCollide = false
	child.CanQuery = false
	child.CanTouch = false

	--[[
	
	local bodyPosition = Instance.new("BodyPosition", child)
	bodyPosition.D = 300
	bodyPosition.P = 75000
	bodyPosition.MaxForce = Vector3.new("inf", "inf", "inf")

	local bodyAngularVelocity = Instance.new("BodyAngularVelocity", child)    
	bodyAngularVelocity.P = "inf"
	bodyAngularVelocity.MaxTorque = Vector3.new("inf", "inf", "inf")
	bodyAngularVelocity.AngularVelocity = Vector3.new(0, "inf", 0) 

	]]--
	
	local index = #paperTable + 1

	child.Destroying:Connect(function()
		table.remove(paperTable, index)
	end)

	table.insert(paperTable, child)
end

table.insert(_G.PBSHub.Connections, workspace.ChildAdded:Connect(onChildAdded))
table.insert(_G.PBSHub.Connections, UserInputService.InputBegan:Connect(onInputBegan))
table.insert(_G.PBSHub.Connections, localPlayer.Backpack.ChildAdded:Connect(onToolAdded))
table.insert(_G.PBSHub.Connections, RunService.RenderStepped:Connect(onRenderStepped))
