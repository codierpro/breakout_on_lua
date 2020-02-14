NONE = 1
SINGLE_PYRAMID = 2
MULTI_PYRAMID = 3

-- per-row patterns
SOLID = 1           -- all colors the same in this row
ALTERNATE = 2       -- alternate colors
SKIP = 3            -- skip every other block
NONE = 4            -- no blocks this row

LevelMaker = Class{}

function LevelMaker:init()

end

function LevelMaker:createMap(level)
    local bricks = {}
    local numRows = math.random(1, 5)
    local numCols = math.random(7, 13)
    local highestTier = math.floor(level / 5)
    local highestColor = math.min(5, level % 5 + 1)

    for y = 1, numRows do
        local skipPattern = math.random(1, 2) == 1 and true or false

        local alternatePattern = math.random(1, 2) == 1 and true or false
        
        local alternateColor1 = math.random(1, highestColor)
        local alternateColor2 = math.random(1, highestColor)
        local alternateTier1 = math.random(0, highestTier)
        local alternateTier2 = math.random(0, highestTier)
        
        local skipFlag = math.random(2) == 1 and true or false

        local alternateFlag = math.random(2) == 1 and true or false

        local solidColor = math.random(1, highestColor)
        local solidTier = math.random(0, highestTier)

        for x = 1, numCols do

            if skipPattern and skipFlag then
                skipFlag = not skipFlag

                goto continue
            else
                skipFlag = not skipFlag
            end

            b = Brick(x * 32 - 24 + (13 - numCols) * 16, y * 16)

            if alternatePattern and alternateFlag then
                b.color = alternateColor1
                b.tier = alternateTier1
                alternateFlag = not alternateFlag
            else
                b.color = alternateColor2
                b.tier = alternateTier2
                alternateFlag = not alternateFlag
            end

            if not alternatePattern then
                b.color = solidColor
                b.tier = solidTier
            end 

            table.insert(bricks, b)

            ::continue::
        end
    end 

    if #bricks == 0 then
        return self.createMap(level)
    else
        return bricks
    end
end