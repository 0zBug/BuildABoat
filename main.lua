
makefolder("Saves")

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

local BuildABoat = {
    Zone = Zone,
    Materials = {
        Plastic = "Plastic",
        Wood = "SmoothWood",
        WoodPlanks = "Wood",
        Slate = "Coal",
        Concrete = "Concrete",
        Metal = "Metal",
        CorrodedMetal = "Rusted",
        DiamondPlate = "Titanium",
        Foil = "Bouncy",
        Grass = "Grass",
        Ice = "Ice",
        Brick = "Brick",
        Sand = "Sand",
        Fabric = "Fabric",
        Granite = "Obsidian",
        Marble = "Marble",
        Pebble = "Plastic",
        Cobblestone = "Stone",
        SmoohPlastic = "Plastic",
        Neon = "Neon",
        Glass = "Glass",
        ForceField = "Plastic"
    }
}

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
        Scale:InvokeServer(Block.Object.Parent, Size, Block.Object.CFrame)
    end,
    ["Position"] = function(Block, Position)
        Move(Block.Object.Parent, CFrame.new(Position) * (Block.Object.CFrame - Block.Object.CFrame.p))
    end,
    ["Orientation"] = function(Block, Orientation)
        Move(Block.Object.Parent, CFrame.new(Block.Object.Position) * CFrame.Angles(math.rad(Orientation.x), math.rad(Orientation.y), math.rad(Orientation.z)))
    end,
    ["CFrame"] = function(Block, CFrame)
        Move(Block.Object.Parent, CFrame)
    end,
    ["Color"] = function(Block, Color)
        Paint:InvokeServer({{Block.Object.Parent, Color}})
    end,
    ["Transparency"] = function(Block, Transparency)
        local Transparency = math.round(Transparency / 25) * 25

        local Start, Finish = Block.Object.Transparency / 25, Transparency / 25
        local Difference = Finish - Start

        if Difference > 0 then
            for i = 1, Difference do
                Screwdriver:InvokeServer("Transparency", {Block.Object.Parent})
            end
        elseif Difference < 0 then
            for i = 1, 3 - Difference  do
                Screwdriver:InvokeServer("Transparency", {Block.Object.Parent})
            end
        end
    end,
    ["Anchored"] = function(Block, Anchored)
        if Block.Object.Anchored ~= Anchored then
            PropertiesTool.Parent = Character
            Screwdriver:InvokeServer("Anchored", {Block.Object.Parent})
            PropertiesTool.Parent = Backpack
        end
    end,
    ["CanCollide"] = function(Block, CanCollide)
        if Block.Object.CanCollide ~= CanCollide then
            PropertiesTool.Parent = Character
            Screwdriver:InvokeServer("Collision", {Block.Object.Parent})
            PropertiesTool.Parent = Backpack
        end
    end,
    ["CastShadow"] = function(Block, CastShadow)
        if Block.Object.CastShadow ~= CastShadow then
            PropertiesTool.Parent = Character
            Screwdriver:InvokeServer("Cast Shadow", {Block.Object.Parent})
            PropertiesTool.Parent = Backpack
        end
    end,
    ["Material"] = function(Block, Material)
        if type(Material) ~= "string" then
            Material = Material.Name
        end

        Block.ActionFinished = false
        local New = BuildABoat.new(BuildABoat.Materials[tostring(Material)] .. "Block")
        New.Color = Block.Object.Color
        New.CFrame = Block.Object.CFrame
        New.CanCollide = Block.Object.CanCollide
        New.Anchored = Block.Object.Anchored
        New.CastShadow = Block.Object.CastShadow
        New.Transparency = Block.Object.Transparency

        task.wait(0.1)

        New.Size = Block.Object.Size

        Block:Destroy()
        
        task.wait(0.15)
        
        Block:Set(New)
		
        Block.ActionFinished = true
    end,
    ["Text"] = function(Block, Text)
        Block.Object.Parent.ClickDetector.Script.UpdateSignRE:FireServer(Text)
    end
}

function BuildABoat.Save(File)
    local Data = {}
	
    for _, Instance in next, Workspace:GetChildren() do
        if Instance:FindFirstChild("PPart") and Instance:FindFirstChild("Tag") and Instance.Tag.Value == LocalPlayer.Name then
            local Part = Instance.PPart
            table.insert(Data, string.format("%s,%s,%s,%s,%s", tostring(Part.Size), tostring(Part.CFrame * Zone.CFrame:Inverse()), tostring(Part.Color), tostring(Part.Transparency), Instance.Name))
        end
    end
	
    writefile("Saves/" .. File .. ".dat", table.concat(Data, "\n"))
end

local Number = 0
function BuildABoat.Load(File)
    local Data = string.split(readfile("Saves/" .. File .. ".dat"), "\n")
	
    for _, Data in next, Data do
        local d = string.split(Data, ",")
        local Size = Vector3.new(d[1], d[2], d[3])
        local CFrame = CFrame.new(d[4], d[5], d[6], d[7], d[8], d[9], d[10], d[11], d[12], d[13], d[14], d[15]) * Zone.CFrame
        local Color = Color3.new(d[16], d[17], d[18])
        local Transparency = tonumber(d[19]) * 100
        local Material = d[20]

        repeat task.wait() until Number < 25
		
        Number = Number + 1
        
        task.spawn(function()
            local Part = BuildABoat.new(Material)
            Part.Size = Size
            Part.Color = Color
            Part.Transparency = Transparency
            Part.CFrame = CFrame
				
            Number = Number - 1
        end)
		
        task.wait(0.01)
    end
end

function BuildABoat.new(Type)
    local Position = CFrame.new(math.random(-70, 70), math.random(-5000, 40) - 150, math.random(-70, 70))

    local Block
    local Connection = Workspace.DescendantAdded:Connect(function(Instance)
        if Instance.Name == "PPart" then
            task.wait(0.05)

            if (Instance.CFrame.p - (Zone.CFrame * Position).p).Magnitude < 1.73 then
                Block = Instance
            end
        end
    end)

    task.spawn(function()
        Build:InvokeServer(Type, LocalPlayer.Data[Type].Value, Zone, Position, true, 1, CFrame.new(), false)

        repeat task.wait() until Block ~= nil

        Connection:Disconnect()
    end)

    local Properties

    local Object = setmetatable({
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
        end,
        Set = function(self, Block)
            self.Object = Block.Object
        end
    }, {
    __index = Properties,
    __newindex = function(self, Key, Value)
        task.spawn(function()
            repeat task.wait() until self.Object

            Properties[Key] = Value

            if Edit[Key] then
                task.spawn(function()
                    if not self.ActionFinished then
                        repeat task.wait() until self.ActionFinished
                    end

                    self.ActionFinished = false

                    Edit[Key](self, Value)

                    self.ActionFinished = true
                end)
            end
        end)
        end
    })

    task.spawn(function()
        repeat task.wait() until Block ~= nil

        Properties = getproperties(Block)
        rawset(Object, "Object", Block)
    end)

    return Object
end

BuildABoat.Functions = Edit

return BuildABoat
