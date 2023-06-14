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

-- local TrowelTool = GetTool("TrowelTool") (unneeded because you can move and rotate with the scale tool)
-- local Trowel = TrowelTool.OperationRF

local ScalingTool = GetTool("ScalingTool")
local Scale = ScalingTool.RF

local PaintingTool = GetTool("PaintingTool")
local Paint = PaintingTool.RF

local DeleteTool = GetTool("DeleteTool")
local Delete = DeleteTool.RF

local PropertiesTool = GetTool("PropertiesTool")
local Screwdriver = PropertiesTool.SetPropertieRF

local Block
Workspace.DescendantAdded:Connect(function(Instance)
    if Instance.Name == "PPart" then
        if Instance.Position == Zone.Position - Vector3.new(0, 200, 0) then
            Block = Instance
        end
    end
end)

local Edit = {
    ["Size"] = function(Block, Size)
        Scale:InvokeServer(Block, Size, Block.PPart.CFrame)
    end,
    ["Position"] = function(Block, Position)
        Scale:InvokeServer(Block, Block.PPart.Size, CFrame.new(Position) * (Block.PPart.CFrame - Block.PPart.CFrame.p))
    end,
    ["Orientation"] = function(Block, Orientation)
        Scale:InvokeServer(Block, Block.PPart.Size, CFrame.new(Block.PPart.Position) * CFrame.Angles(math.rad(Orientation.x), math.rad(Orientation.y), math.rad(Orientation.z)))
    end,
    ["CFrame"] = function(Block, CFrame)
        Scale:InvokeServer(Block, Block.PPart.Size, CFrame)
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
            Screwdriver:InvokeServer("Anchored", {Block})
        end
    end,
    ["CanCollide"] = function(Block, CanCollide)
        if Block.PPart.CanCollide ~= CanCollide then
            Screwdriver:InvokeServer("Collision", {Block})
        end
    end,
    ["CastShadow"] = function(Block, CastShadow)
        if Block.PPart.CastShadow ~= CastShadow then
            Screwdriver:InvokeServer("Cast Shadow", {Block})
        end
    end
}

local BuildABoat = {}

BuildABoat.Zone = Zone

function BuildABoat.new(Type)
    Build:InvokeServer(Type, LocalPlayer.Data[Type].Value, Zone, CFrame.new(0, -200, 0), true, 1, CFrame.new(), false)

    local Properties = getproperties(Block)

    return setmetatable({
        Object = Block,
        ActionFinished = true,
        Destroy = function(self) Delete:InvokeServer(self.Object) end,
        Remove = function(self) Delete:InvokeServer(self.Object) end
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

return BuildABoat
