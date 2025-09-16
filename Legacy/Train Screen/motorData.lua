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
        simulator:setInputBool(31, simulator:getIsClicked(1))     -- if button 1 is clicked, provide an ON pulse for input.getBool(31)
        simulator:setInputNumber(3, simulator:getSlider(1))       -- set input 31 to the value of slider 1

        simulator:setInputBool(32, simulator:getIsToggled(2))     -- make button 2 a toggle, for input.getBool(32)
        simulator:setInputNumber(4, simulator:getSlider(2) * 7000) -- set input 32 to the value from slider 2 * 50
    end;
end
---@endsection


--[====[ IN-GAME CODE ]====]

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!

require("technicalscreen")

function onTick()

    hours = math.floor(input.getNumber(1))
    minutes = math.floor(input.getNumber(2))

    appliedThrottle = input.getNumber(3)
    prod = input.getNumber(4)
end

function onDraw()
    h = screen.getHeight()
    w = screen.getWidth()

    screen.setColor(0, 0, 0)
    screen.drawClear()

    drawOverlay(h, w, hours, minutes, "Motor")

    -- applied throttle
    screen.setColor(230, 230, 230)
    screen.drawRect(13, 13, 4, h - 19)

    screen.drawLine(8, 13, 13, 13)
    screen.drawLine(11, 36, 13, 36)
    screen.drawLine(8, 58, 13, 58)

    screen.drawText(3, 11, "1")

    screen.drawText(3, 34, ".")
    screen.drawText(6, 34, "5")

    screen.drawText(3, 56, "0")

    -- animation
    throttleLineY = math.floor((math.abs(appliedThrottle) * 100) * 45 / 100)

    if (appliedThrottle < 0) then
        screen.setColor(255, 239, 0)
    else
        screen.setColor(0, 0, 200)
    end

    screen.drawLine(14, (h - 6) - throttleLineY, 17, (h - 6) - throttleLineY)
    screen.drawText(19, (h - 6) - throttleLineY - 1, math.floor(math.abs(appliedThrottle) * 100))

    if (appliedThrottle < 0) then
        screen.setColor(255, 239, 0, 150)
    else
        screen.setColor(0, 0, 200, 150)
    end

    screen.drawRectF(14, (h - 6) - throttleLineY, 3, throttleLineY)

    -- prod
    screen.setColor(230, 230, 230)
    screen.drawRect(w - 18, 13, 4, h - 19)

    screen.drawLine(w - 9, 13, w - 15, 13)
    screen.drawLine(w - 12, 36, w - 15, 36)
    screen.drawLine(w - 9, 58, w - 15, 58)

    screen.drawText(w - 7, 11, "1")

    screen.drawText(w - 12, 34, ".")
    screen.drawText(w - 9, 34, "5")

    screen.drawText(w - 7, 56, "0")

    -- animation
    throttleLineY = math.floor(((prod * 100) / 7000) * 45 / 100)

    screen.setColor(0, 0, 200)

    screen.drawLine(w - 15, (h - 6) - throttleLineY, w - 18, (h - 6) - throttleLineY)


    value = math.floor(prod / 10)

    if(string.len(value) > 2)then
        screen.drawText(w - 33, (h - 6) - throttleLineY - 1, value)
    elseif (string.len(value) > 1) then
        screen.drawText(w - 28, (h - 6) - throttleLineY - 1, value)
    else
        screen.drawText(w - 23, (h - 6) - throttleLineY - 1, value)
    end

    screen.setColor(0, 0, 200, 150)

    screen.drawRectF(w - 18, (h - 6) - throttleLineY, 3, throttleLineY)
end
