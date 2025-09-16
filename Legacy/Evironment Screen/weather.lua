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
        simulator:setInputNumber(31, simulator:getSlider(1))        -- set input 31 to the value of slider 1

        simulator:setInputBool(32, simulator:getIsToggled(2))       -- make button 2 a toggle, for input.getBool(32)
        simulator:setInputNumber(32, simulator:getSlider(2) * 50)   -- set input 32 to the value from slider 2 * 50
    end;
end
---@endsection


--[====[ IN-GAME CODE ]====]

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!
require("weatherscreen")

ticks = 0
function onTick()
    ticks = ticks + 1

    hours = math.floor(input.getNumber(1))
    minutes = math.floor(input.getNumber(2))

    windSpeed = input.getNumber(3)
    temp = input.getNumber(4)
    rain = input.getNumber(5)
    fog = input.getNumber(6)
end

function onDraw()
    h = screen.getHeight()
    w = screen.getWidth()
    
    screen.setColor(0,0,0)
    screen.drawClear()

    -- weather display
    drawSun(w/2 + 15, h/4 - 4, hours)
    drawWind(w/2, h/4, windSpeed)
    drawFog(w/2, h/4, fog)
    drawRain(w/2, h/4, rain)

    -- data display
    screen.setColor(230,230,230)
    screen.drawText(1, 39, "WIND")
    screen.drawText(20, 39, ":")
    screen.drawText(23, 39, math.floor(windSpeed).."m/s")

    screen.drawText(1, 45, "TEMP")
    screen.drawText(20, 45, ":")
    screen.drawText(23, 45, math.floor(temp).."C")

    --draw footer
    screen.setColor(0,0,0)
    screen.drawRectF(0,h-8, w, 8)

    screen.setColor(230,230,230)
    screen.drawText(1, h-7, string.format("%02d", hours))
    screen.drawText(10, h-7, ":")
    screen.drawText(13, h-7, string.format("%02d", minutes))

    screen.drawText(29, h-7,"WEATHER")
end
