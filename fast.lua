local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character
local Backpack = LocalPlayer.Backpack

local Team = tostring(LocalPlayer.TeamColor)
local Zone = Workspace[Team .. "Zone"]

local function GetTool(Tool)
    return Character:FindFirstChild(Tool) or Backpack:FindFirstChild(Tool)
end

local BuildTool = GetTool("BuildingTool")
local Build = BuildTool.RF 

local TrowelTool = GetTool("TrowelTool")
local Trowel = TrowelTool.OperationRF

local ScalingTool = GetTool("ScalingTool")
local Scale = ScalingTool.RF

local PaintingTool = GetTool("PaintingTool")
local Paint = PaintingTool.RF

local DeleteTool = GetTool("DeleteTool")
local Delete = DeleteTool.RF

local BindTool = GetTool("BindTool")
local Bind = BindTool.RF

local PropertiesTool = GetTool("PropertiesTool")
local Screwdriver = PropertiesTool.SetPropertieRF

local function Move(Block, CFrame)
	if string.sub(Block.Name, -5, -1) ~= "Block" then
		TrowelTool.Parent = Character
		
		Trowel:InvokeServer({Block}, Block.PPart.CFrame, CFrame, "Move")
		
		TrowelTool.Parent = Backpack
	else
		Scale:InvokeServer(Block, Block.PPart.Size, CFrame)
	end
end

local Edit = {
    ["Size"] = function(Block, Size)
        Scale:InvokeServer(Block, Size, Block.PPart.CFrame)
    end,
    ["Position"] = function(Block, Position)
    	Move(Block, CFrame.new(Position) * (Block.PPart.CFrame - Block.PPart.CFrame.p))
    end,
    ["Orientation"] = function(Block, Orientation)
   		Move(Block, CFrame.new(Block.PPart.Position) * CFrame.Angles(math.rad(Orientation.x), math.rad(Orientation.y), math.rad(Orientation.z)))
	end,
    ["CFrame"] = function(Block, CFrame)
    	Move(Block, CFrame)
    end,
    ["Color"] = function(Block, Color)
        Paint:InvokeServer({{Block, Color}})
    end,
    ["Transparency"] = function(Block, Transparency)
        local Transparency = math.round(Transparency / 25) * 25

        local Start, Finish = Block.PPart.Transparency / 25, Transparency / 25
        local Difference = Finish - Start

        if Difference > 0 then
            for i = 1, Difference do
                Screwdriver:InvokeServer("Transparency", {Block})
            end
        elseif Difference < 0 then
            for i = 1, 3 - Difference  do
                Screwdriver:InvokeServer("Transparency", {Block})
            end
        end
    end,
    ["Anchored"] = function(Block, Anchored)
        if Block.PPart.Anchored ~= Anchored then
        	PropertiesTool.Parent = Character
            Screwdriver:InvokeServer("Anchored", {Block})
            PropertiesTool.Parent = Backpack
        end
    end,
    ["CanCollide"] = function(Block, CanCollide)
        if Block.PPart.CanCollide ~= CanCollide then
        	PropertiesTool.Parent = Character
            Screwdriver:InvokeServer("Collision", {Block})
            PropertiesTool.Parent = Backpack
        end
    end,
    ["CastShadow"] = function(Block, CastShadow)
        if Block.PPart.CastShadow ~= CastShadow then
        	PropertiesTool.Parent = Character
            Screwdriver:InvokeServer("Cast Shadow", {Block})
            PropertiesTool.Parent = Backpack
        end
    end,
    ["Text"] = function(Block, Text)
		Block.ClickDetector.Script.UpdateSignRE:FireServer(Text)
    end
}

local BuildABoat = {}

BuildABoat.Zone = Zone

function BuildABoat.new(Type)
	local Position = CFrame.new(math.random(-70, 70), math.random(-50, 40) - 150, math.random(-70, 70))
	
	local Block
	local Connection = Workspace.DescendantAdded:Connect(function(Instance)
	    if Instance.Name == "PPart" then
	    	task.wait(0.05)
	    	
	        if (Instance.CFrame.p - (Zone.CFrame * Position).p).Magnitude < 1.73 then
	            Block = Instance
	        end
	    end
	end)

    Build:InvokeServer(Type, LocalPlayer.Data[Type].Value, Zone, Position, true, 1, CFrame.new(), false)

	repeat task.wait() until Block ~= nil

	Connection:Disconnect()
	
    local Properties = getproperties(Block)

    return setmetatable({
        Object = Block,
        ActionFinished = true,
        Destroy = function(self) Delete:InvokeServer(self.Object.Parent) end,
        Remove = function(self) Delete:InvokeServer(self.Object.Parent) end,
        Link = function(self, Link)
        	local Link = Link.Object.Parent
        	
			Bind:InvokeServer({Link:FindFirstChild("BindWait") or Link:FindFirstChild("BindFire")}, self.Object.Parent, -1, false)
		end,
		Unlink = function(self, Link)
			local Link = Link.Object.Parent
			
			Bind:InvokeServer({Link:FindFirstChild("BindWait") or Link:FindFirstChild("BindFire")}, self.Object.Parent, -1, true)
		end,
		Activate = function(self)
			for _, Instance in next, self.Object.Parent:GetDescendants() do
				if Instance:IsA("ClickDetector") then
					fireclickdetector(Instance)
				end
			end
		end
    }, {
        __index = Properties,
        __newindex = function(self, Key, Value)
            Properties[Key] = Value

            if Edit[Key] then
                task.spawn(function()
                    repeat task.wait() until self.ActionFinished == true

                    self.ActionFinished = false

                    Edit[Key](self.Object.Parent, Value)

                    self.ActionFinished = true
                end)
            end
        end
    })
end
