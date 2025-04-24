

-- << VARIABLES >> --

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local localPlayer = game:GetService("Players").LocalPlayer
local mouse = localPlayer:GetMouse()

local debounce = false
local paperTable = {}


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

local function onInputBegan(input, processed)
	if processed then
		return
	end
	
	if input.KeyCode.Name ~= "Q" then
		return
	end
	
	if debounce then 
		return
	end

	localPlayer.ReplicationFocus = workspace
	activateTools()
end


-- << SETUP >> --

if not getgenv().Network then
	getgenv().Network = {
		BaseParts = {},
		Velocity = Vector3.new(14.46262424, 14.46262424, 14.46262424)
	}
	
	Network.RetainPart = function(Part)
		if typeof(Part) == "Instance" and Part:IsA("BasePart") and Part:IsDescendantOf(workspace) then
			table.insert(Network.BaseParts, Part)
			Part.CanCollide = false
		end
	end
end

local function onHeartbeat()
	local hit = mouse.Hit.Position    
	local mousePosition = Vector3.new(hit.X, hit.Y + 2.5, hit.Z)

	for _,child: BasePart in pairs(paperTable) do
		if not child then
			continue
		end

		sethiddenproperty(localPlayer, "SimulationRadius", math.huge)
                child.Position = mousePosition
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
	child.CustomPhysicalProperties = PhysicalProperties.new(0.0001, 0.0001, 0.0001, 0.0001, 0.0001)

	local bodyAngularVelocity = Instance.new("BodyAngularVelocity", child)    
	bodyAngularVelocity.P = "inf"
	bodyAngularVelocity.MaxTorque = Vector3.new("inf", "inf", "inf")
	bodyAngularVelocity.AngularVelocity = Vector3.new(100000000, 100000000, 100000000)    

	local Attachment0 = Instance.new("Attachment", child)
	local Attachment1 = localPlayer.Character.HumanoidRootPart.RootAttachment

	--[[
	local AlignPosition = Instance.new("AlignPosition")
        AlignPosition.MaxForce = "inf"
        AlignPosition.MaxVelocity = math.huge
        AlignPosition.Responsiveness = 200
        AlignPosition.Attachment0 = Attachment1
       	AlignPosition.Attachment1 = Attachment0
	]]--
		
	table.insert(paperTable, child)
end

local StarterGui = game:GetService("StarterGui")
StarterGui:SetCore("SendNotification", {
    Title = "PBS Hub by samopato",
    Text = "Loaded 👅👅👅",
    Icon = "rbxassetid://89210547385522",
    Duration = 5
})


workspace.ChildAdded:Connect(onChildAdded)
UserInputService.InputBegan:Connect(onInputBegan)
localPlayer.Backpack.ChildAdded:Connect(onToolAdded)
RunService.Heartbeat:Connect(onHeartbeat)
