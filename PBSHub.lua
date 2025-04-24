

-- << VARIABLES >> --

local UserInputService = game:GetService("UserInputService")
local renderStepped = game:GetService("RunService").RenderStepped
local localPlayer = game:GetService("Players").LocalPlayer
local mouse = localPlayer:GetMouse()

local debounce = false
local toolTable = {}
local paperTable = {}


-- << MAIN >> --

local function activateTools()
	debounce = true

	warn("cu")
	
	for _,tool in pairs(toolTable) do
		tool.Parent = localPlayer.Character
		tool:Activate()
		task.wait(0.003)
		tool.Parent = localPlayer.Backpack
	end
	
	task.wait(0.75)
	
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
			Part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
			Part.CanCollide = false
		end
	end
	
	local function EnablePartControl()
		localPlayer.ReplicationFocus = workspace
		renderStepped:Connect(function()
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

local function onRenderStepped()
	local hit = mouse.Hit.Position    
	local mousePosition = Vector3.new(hit.X, hit.Y + 2.5, hit.Z)

	for _,child: BasePart in pairs(paperTable) do
		if not child then
			continue
		end
		
		child.AssemblyLinearVelocity = Vector3.new("inf", "inf", "inf")
		child.AssemblyAngularVelocity = Vector3.new("inf", "inf", "inf")
		child.BodyPosition.Position = mousePosition
	end
end 

local function onChildAdded(child: Instance)
	if child:IsA("BasePart") then
		local bodyPosition = Instance.new("BodyPosition")    
		bodyPosition.D = 500
		bodyPosition.P = 30000
		bodyPosition.MaxForce = Vector3.new("inf", "inf", "inf")
		bodyPosition.Position = mouse.Hit.Position
		bodyPosition.Parent = child

		local bodyAngularVelocity = Instance.new("BodyAngularVelocity")    
		bodyAngularVelocity.P = "inf"
		bodyAngularVelocity.MaxTorque = Vector3.new("inf", "inf", "inf")
		bodyAngularVelocity.AngularVelocity = Vector3.new(100000000, 100000000, 100000000)    
		bodyAngularVelocity.Parent = child
		
		table.insert(paperTable, child)
	end
end

local function onToolAdded(child: Instance)
	if not child:IsA("Tool") then
		return
	end
	
	if child.Name ~= "TpRoll" then
		return
	end
	
	table.insert(toolTable, child)
end

for _,v in pairs(localPlayer.Backpack:GetChildren()) do
	onToolAdded(v)
end

workspace.ChildAdded:Connect(onChildAdded)
UserInputService.InputBegan:Connect(onInputBegan)
localPlayer.Backpack.ChildAdded:Connect(onToolAdded)
renderStepped:Connect(onRenderStepped)
