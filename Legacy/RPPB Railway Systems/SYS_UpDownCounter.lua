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
    simulator:setScreen(1, "3x3")
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
        simulator:setInputNumber(31, simulator:getSlider(1))        -- set input 31 to the value of slider 1

        simulator:setInputBool(32, simulator:getIsToggled(2))       -- make button 2 a toggle, for input.getBool(32)
        simulator:setInputNumber(32, simulator:getSlider(2) * 50)   -- set input 32 to the value from slider 2 * 50
    end;
end
---@endsection


--[====[ IN-GAME CODE ]====]

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!

ticks = 0

counterMin = property.getNumber("CounterMin")
counterMax = property.getNumber("CounterMax")
counterIncrement = property.getNumber("CounterIncrement")

function counterUpDown(min, max, startValue)
    return
    {
        clampMin = min,
        clampMax = max,
        value = startValue,

        update = function(this, bool, increment, min, max) -- bool is a boolean(on/off) value
            
            local increment = increment or 1
            this.clampMin = min or this.clampMin
            this.clampMax = max or this.clampMax

            -- test if we increment the value or decrement it
            if(bool and (this.value < this.clampMax  ))then -- if ON and not equal or above upper clamp
                this.value = this.value + increment

            elseif(not bool and (this.value > this.clampMin))then -- else if OFF (not ON) and not equal or under lower clamp
                this.value = this.value - increment
            end

            return this.value
        end,

        reset = function(this, min, max, startValue)
            this.clampMin = min or this.clampMin
            this.clampMax = max or this.clampMax
            this.value = startValue or 0

            return this.value
        end
    }
end

counter = counterUpDown(counterMin, counterMax, counterMin)

function onTick()
    engineState = input.getBool(1)
    updateState = input.getBool(2)

    if(not engineState)then
        output.setNumber(1, counter:reset(counterMin, counterMax, counterMin))
    else
        output.setNumber(1, counter:update(updateState, counterIncrement))
    end
end

