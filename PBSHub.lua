
-- << VARIABLES >> --

local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
--local CoreGui = cloneref(game:GetService("CoreGui"))

local localPlayer = game:GetService("Players").LocalPlayer
local mouse = localPlayer:GetMouse()

local debounce = false
local paperTable = {}

local mouseAttachment = workspace.Terrain:FindFirstChild("Target")
if not mouseAttachment then
	mouseAttachment = Instance.new("Attachment", workspace.Terrain)
end
mouseAttachment.Name = "Target"
mouseAttachment.Visible = false

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
	task.spawn(function()		
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
	end)
end

local function makeWall(desiredCols, desiredRows)
	--[[
	local totalParts = #paperTable

	if totalParts == 0 then
		return
	end

	while not mouse.Hit or not mouse.Hit.Position do
		RunService.Heartbeat:Wait()
	end

	local startPos = mouse.Hit.Position
	local samplePart = paperTable[1]
	local partWidth = samplePart.Size.X
	local partHeight = samplePart.Size.Z

	local cols = desiredCols or math.ceil(math.sqrt(totalParts))
	local rows = desiredRows or math.ceil(totalParts / cols)

	local totalWidth = cols * partWidth
	local totalHeight = rows * partHeight

	local camForward = (camera.CFrame.LookVector * Vector3.new(1, 0, 1)).Unit
	local camRight = Vector3.new(-camForward.Z, 0, camForward.X).Unit

	local base = getAttachmentBase()

	for i = 1, totalParts do
		local part = paperTable[i]

		local col = (i - 1) % cols
		local row = math.floor((i - 1) / cols)

		local offsetX = (col * partWidth) - (totalWidth / 2) + (partWidth / 2)
		local offsetY = (row * partHeight) + (partHeight / 2)

		local targetPos = startPos + camRight * offsetX + Vector3.new(0, offsetY, 0)
		local targetRot = CFrame.lookAt(targetPos, targetPos + camForward) * CFrame.Angles(math.rad(-90), 0, 0)

		createAlignConstraint(part, targetPos, targetRot, base)
	end
	--]]
end


local function onInputBegan(input, processed)
	if processed then
		return
	end

	if debounce then 
		return
	end

	if input.KeyCode.Name == "E" then
		--makeWall()
		return
	end

	if input.KeyCode.Name == "Q" then
		activateTools()
		return
	end
end


-- << SETUP >> --

local function onRenderStepped()
	sethiddenproperty(localPlayer, "SimulationRadius", math.huge)	
	local hit = mouse.Hit
	
	if hit then
		local position = Vector3.new(hit.X, hit.Y + 2.5, hit.Z)
		mouseAttachment.Position = position
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

	local attachment = Instance.new("Attachment")
	attachment.Parent = child
	
	local alignPosition = Instance.new("AlignPosition")
	alignPosition.Attachment0 = attachment
	alignPosition.Attachment1 = mouseAttachment
	alignPosition.RigidityEnabled = true
	alignPosition.Parent = child

	
	--[[
	local bodyAngularVelocity = Instance.new("BodyAngularVelocity", child)    
        bodyAngularVelocity.P = "inf"
        bodyAngularVelocity.MaxTorque = Vector3.new("inf", "inf", "inf")
        bodyAngularVelocity.AngularVelocity = Vector3.new("inf", "inf", "inf")    
	]]--

	table.insert(paperTable, child)

	local index = #paperTable
	child.Destroying:Connect(function()
		table.remove(paperTable, index)
	end)
end

table.insert(_G.PBSHub.Connections, workspace.ChildAdded:Connect(onChildAdded))
table.insert(_G.PBSHub.Connections, UserInputService.InputBegan:Connect(onInputBegan))
table.insert(_G.PBSHub.Connections, RunService.RenderStepped:Connect(onRenderStepped))
