-- Author: MrCreeperman147
-- GitHub: <GithubLink>
-- Workshop: <WorkshopLink>

--I like trains--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey


--[====[ HOTKEYS ]====]
-- Press F6 to simulate this file
-- Press F7 to build the project, copy the output from /_build/out/ into the game to use
-- Remember to set your Author name etc. in the settings: CTRL+COMMA


--[====[ EDITABLE SIMULATOR CONFIG - *automatically removed from the F7 build output ]====]
---@section __LB_SIMULATOR_ONLY__
do
    ---@type Simulator -- Set properties and screen sizes here - will run once when the script is loaded
    simulator = simulator
    simulator:setScreen(1, "2x2")
    simulator:setProperty("ExampleNumberProperty", 123)

    -- Runs every tick just before onTick; allows you to simulate the inputs changing
    ---@param simulator Simulator Use simulator:<function>() to set inputs etc.
    ---@param ticks     number Number of ticks since simulator started
    function onLBSimulatorTick(simulator, ticks)

        -- touchscreen defaults
        local screenConnection = simulator:getTouchScreen(1)
        simulator:setInputBool(1, screenConnection.isTouched)
        simulator:setInputNumber(1, screenConnection.width)
        simulator:setInputNumber(2, screenConnection.height)
        simulator:setInputNumber(3, screenConnection.touchX)
        simulator:setInputNumber(4, screenConnection.touchY)

        -- NEW! button/slider options from the UI
        simulator:setInputBool(31, simulator:getIsClicked(1))       -- if button 1 is clicked, provide an ON pulse for input.getBool(31)
        simulator:setInputNumber(5, simulator:getSlider(1))        -- set input 31 to the value of slider 1

        simulator:setInputBool(32, simulator:getIsToggled(2))       -- make button 2 a toggle, for input.getBool(32)
        simulator:setInputNumber(32, simulator:getSlider(2) * 50)   -- set input 32 to the value from slider 2 * 50
    end;
end
---@endsection


--[====[ IN-GAME CODE ]====]

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!
DARK_THEME = {{0, 0, 0}, {200, 200, 255}, {220, 220, 220}}
POSITIVE_COLOR = {0, 0, 200}
NEGATIVE_COLOR = {255, 239, 0}

function screen.drawTextLower(x,y,t)
    t=tostring(t)
    for i=1,t:len()do 
        local c=t:sub(i,i):upper():byte()*3-95 
        if c>193 then
            c=c-78
        end 
        c="0x"..string.sub("0000D0808F6F5FAB6D5B7080690096525272120222010168F9F5F1BBD9DBE2FDDBFBB8BCFBFEAF0A01A025055505289C69D7A7FB6699F96FB9FA869BF2F9F921EF69F11FCFF8F696FA4F9EFA55BB8F8F1FE1EF3FD2DC3CBFDF9086109F4841118406F90F09F6642",c,c+2)
        for j=0,11 do 
            if c&(1<<(11-j))>0 then 
                local b=x+j//4+i*4-4     
                screen.drawLine(b,y+j%4,b,y+j%4+1)
            end
        end     
    end 
end

function math.clamp(x, a, b)
    return x<a and a or x>b and b or x
end

function screen.segmentDisplayV2(colorArray, x, y, width, height, min, max, halved)
    return
    {
        colorArray = colorArray,

        x = x,
        y = y,
        width = width,
        height = height,
    
        middle = height,
    
        min = math.abs(min),
        max = math.abs(max),
    
        halved = halved or false,
    
        vertical = true,
    
    
    
        draw = function (this, currentValue, gaugeColor)
            currentValue = math.clamp(currentValue, -this.min, this.max)
    
            screen.setColor(this.colorArray[1], this.colorArray[2], this.colorArray[3])
    
            -- orientation
            if(this.width > this.height)then
                this.vertical = false
            end

            if(not this.vertical)then
                this.middle = width
            end
    
            -- draw frame
            screen.drawRect(this.x, this.y, this.width, this.height)
    
            if(this.halved)then
                total = this.max + this.min
    
                if(this.vertical)then
                    this.middle = math.ceil(((total - this.min) * height) / total)
    
                    screen.drawLine(this.x, this.y + this.middle, this.x + this.width, this.y + this.middle)
    
                else
                    this.middle = math.ceil(((total - this.min) * width) / total)
    
                    screen.drawLine(this.x + (this.width - this.middle), this.y, this.x + (this.width - this.middle), this.y + this.height)
                end
            end
    
            -- animation
            if(this.vertical)then
                if(currentValue < 0)then
                    screen.setColor(gaugeColor[1], gaugeColor[2], gaugeColor[3], 150)
    
                needle = (currentValue * ((this.max + this.min) - this.middle)) / this.min
                    screen.drawRectF(this.x + 1, this.y + this.middle + 1, this.width - 1, needle)
    
                    screen.setColor(gaugeColor[1], gaugeColor[2], gaugeColor[3])
                    screen.drawLine(this.x + 1, this.y + this.middle + needle, this.x + this.width, this.y + this.middle + needle)
    
    
                else
                    screen.setColor(gaugeColor[1], gaugeColor[2], gaugeColor[3], 150)
    
                    needle = (currentValue * (this.middle - 1)) / this.max
                    screen.drawRectF(this.x + 1, this.y + this.middle, this.width - 1,  -needle)
    
                    screen.setColor(gaugeColor[1], gaugeColor[2], gaugeColor[3])
                    screen.drawLine(this.x + 1, this.y + this.middle - needle, this.x + this.width, this.y + this.middle - needle)
                end
    
            else
                if(currentValue < 0)then
                    needle = (currentValue * (this.width - this.middle - 1)) / this.min

                    screen.setColor(gaugeColor[1], gaugeColor[2], gaugeColor[3], 150)    
                    screen.drawRectF(this.x + (this.width - this.middle) - 0.5, this.y + 1, needle, this.height - 1)
    
                    screen.setColor(gaugeColor[1], gaugeColor[2], gaugeColor[3])
                    screen.drawLine(this.x + (this.width - this.middle) + needle, this.y + 1, this.x + (this.width - this.middle) + needle, this.y + this.height)
    
                else
                    needle = (currentValue * (this.middle - 1)) / this.max

                    screen.setColor(gaugeColor[1], gaugeColor[2], gaugeColor[3], 150)    
                    screen.drawRectF(this.x + (this.width - this.middle) + 1, this.y + 1, needle - 1, this.height - 1)
    
                    screen.setColor(gaugeColor[1], gaugeColor[2], gaugeColor[3])
                    screen.drawLine(this.x + (this.width - this.middle) + needle, this.y + 1, this.x + (this.width - this.middle) + needle, this.y + this.height)
                end
    
            end
    
        end
    
    }
end

helpy = screen.segmentDisplayV2(DARK_THEME[2], 20, 32, 50, 5, -0.5, 1, true)

segmentGen1 = screen.segmentDisplayV2(DARK_THEME[2], 3, 12, 4, 42, 0, 4000)

segmentTotalPower = screen.segmentDisplayV2(DARK_THEME[2], 37, 18, 23, 4, 0, 1)
segmentAppliedPower = screen.segmentDisplayV2(DARK_THEME[2], 37, 29, 23, 4, 0, 1)

segmentBrake = screen.segmentDisplayV2(DARK_THEME[2], 37, 50, 23, 4, 0, 1)

function onTick()
    gen1 = input.getNumber(1)           -- 0 - 4000

    totalEffort = input.getNumber(4)    -- 0 - 1
    appliedEffort = input.getNumber(5)  -- 0 - 1

    brake = input.getNumber(6)          -- 0 - 1
end


function onDraw()
    -- gen
    segmentGen1:draw(gen1, POSITIVE_COLOR)

    screen.setColor(DARK_THEME[2][1], DARK_THEME[2][2], DARK_THEME[2][3])
    screen.drawTextLower(4, 56, "1")

    screen.drawTextLower(9, 51, "0")
    screen.drawTextLower(9, 12, "4000")
    screen.drawTextLower(9, 32, "GEN")

    -- pwr
    currentColor = POSITIVE_COLOR

    if(totalEffort < 0)then
        currentColor = NEGATIVE_COLOR
    end
    segmentTotalPower:draw(totalEffort, currentColor)

    currentColor = POSITIVE_COLOR

    if(appliedEffort < 0)then
        currentColor = NEGATIVE_COLOR
    end
    segmentAppliedPower:draw(appliedEffort, currentColor)

    screen.setColor(DARK_THEME[2][1], DARK_THEME[2][2], DARK_THEME[2][3])
    screen.drawTextLower(37, 12, "PWR")
    screen.drawTextLower(37, 24, "0")
    screen.drawTextLower(58, 24, "1")

    -- brake
    segmentBrake:draw(brake, NEGATIVE_COLOR)
    screen.setColor(DARK_THEME[2][1], DARK_THEME[2][2], DARK_THEME[2][3])
    screen.drawTextLower(37, 45, "BRAKE")
    screen.drawTextLower(37, 56, "0")
    screen.drawTextLower(58, 56, "1")

end
