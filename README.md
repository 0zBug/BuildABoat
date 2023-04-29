# BuildABoat

## Tools needed:
Paintbrush: Color
Tape Measure: Size, Position, Orientation, CFrame
Screwdriver: Transparency, Anchored, CanCollide, CastShadow

# Example
```lua
local Wood = BuildABoat.new("WoodBlock")
Wood.CFrame = Zone.CFrame * CFrame.new(0, 10, 0) * CFrame.Angles(0, math.rad(45), 0)
Wood.Size = Vector3.new(10, 10, 10)
Wood.Color = Color3.new(1, 0, 0)
Wood.Transparency = 30
```
