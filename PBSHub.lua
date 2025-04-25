

-- << VARIABLES >> --

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local localPlayer = game:GetService("Players").LocalPlayer
local mouse = localPlayer:GetMouse()

local debounce = false
local paperTable = {}


-- << PART CLAIM >> --

local Folder = Instance.new("Folder", Workspace)
local Part = Instance.new("Part", Folder)
local Attachment1 = Instance.new("Attachment", Part)
Part.Anchored = true
Part.CanCollide = false
Part.Transparency = 1

local function ForcePart(v)
    if v:IsA("Part") and not v.Anchored and not v.Parent:FindFirstChild("Humanoid") and not v.Parent:FindFirstChild("Head") and v.Name ~= "Handle" then
        for _, x in next, v:GetChildren() do
            if x:IsA("BodyAngularVelocity") or x:IsA("BodyForce") or x:IsA("BodyGyro") or x:IsA("BodyPosition") or x:IsA("BodyThrust") or x:IsA("BodyVelocity") or x:IsA("RocketPropulsion") then
                x:Destroy()
            end
        end
        if v:FindFirstChild("Attachment") then
            v:FindFirstChild("Attachment"):Destroy()
        end
        if v:FindFirstChild("AlignPosition") then
            v:FindFirstChild("AlignPosition"):Destroy()
        end
        if v:FindFirstChild("Torque") then
            v:FindFirstChild("Torque"):Destroy()
        end
        v.CanCollide = false
        local Torque = Instance.new("Torque", v)
        Torque.Torque = Vector3.new(100000, 100000, 100000)
        local AlignPosition = Instance.new("AlignPosition", v)
        local Attachment2 = Instance.new("Attachment", v)
        Torque.Attachment0 = Attachment2
        AlignPosition.MaxForce = 9999999999999999
        AlignPosition.MaxVelocity = math.huge
        AlignPosition.Responsiveness = 200
        AlignPosition.Attachment0 = Attachment2
        AlignPosition.Attachment1 = Attachment1
    end
end

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

local function onRenderStepped()
	local hit = mouse.Hit.Position    
	local mousePosition = Vector3.new(hit.X, hit.Y + 2.5, hit.Z)

	for _,child: BasePart in pairs(paperTable) do
		if not child then
			continue
		end

		sethiddenproperty(localPlayer, "SimulationRadius", math.huge)
		child.Velocity = Vector3.new(math.random(1, 10), math.random(1, 10), math.random(1, 10))
                child.BodyPosition.Position = mousePosition
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

	local bodyPosition = Instance.new("BodyPosition", child)
        bodyPosition.D = 500
        bodyPosition.P = 15000
        bodyPosition.MaxForce = Vector3.new("inf", "inf", "inf")
	
	local bodyAngularVelocity = Instance.new("BodyAngularVelocity", child)    
	bodyAngularVelocity.P = "inf"
	bodyAngularVelocity.MaxTorque = Vector3.new("inf", "inf", "inf")
	bodyAngularVelocity.AngularVelocity = Vector3.new(1000000, 1000000, 1000000) 
		
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
RunService.RenderStepped:Connect(onRenderStepped)
