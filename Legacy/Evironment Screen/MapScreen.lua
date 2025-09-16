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
        simulator:setInputNumber(1, simulator:getSlider(1) * 0.5)        -- set input 31 to the value of slider 1

        simulator:setInputBool(32, simulator:getIsToggled(2))       -- make button 2 a toggle, for input.getBool(32)
        simulator:setInputNumber(32, heading)   -- set input 32 to the value from slider 2 * 50
    end;
end
---@endsection


--[====[ IN-GAME CODE ]====]

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!

ticks = 0
function onTick()
    ticks = ticks + 1

    heading = ((input.getNumber(3)*(-1))*360+360)%360

    currentX = input.getNumber(4)
    currentY = input.getNumber(5)

    hours = math.floor(input.getNumber(1))
    minutes = math.floor(input.getNumber(2))
end

function onDraw()
    h = screen.getHeight()
    w = screen.getWidth()

    screen.setColor(0,0,0)
    screen.drawClear()


    -- draw map
    screen.drawMap(currentX, currentY, 1)

    -- draw user
    pixelX, pixelY = map.mapToScreen(currentX, currentX, 2, w, h, currentX, currentY)

    radHeading = (heading - 90)*(math.pi)/180
    lineaX = (w/2) + 4 * math.cos(radHeading)
    lineaY = (h/2) + 4 * math.sin(radHeading)

    radHeading = (heading - 90)*(math.pi)/180 - 10
    linebX = (w/2) + 4 * math.cos(radHeading)
    linebY = (h/2) + 4 * math.sin(radHeading)

    radHeading = (heading - 90)*(math.pi)/180 + 10
    linecX = (w/2) + 4 * math.cos(radHeading)
    linecY = (h/2) + 4 * math.sin(radHeading)

    screen.setColor(150,0,0)
    screen.drawTriangleF(lineaX, lineaY, linebX, linebY, linecX, linecY)

    --draw header
    screen.setColor(0,0,0)
    screen.drawRectF(0,0,w,7)

    screen.setColor(230,230,230)
    screen.drawText(1,1, math.floor(currentX))
    screen.drawText(w/2 + 5, 1,math.floor(currentY))

    --draw footer
    screen.setColor(0,0,0)
    screen.drawRectF(0,h-8, w, 8)

    screen.setColor(230,230,230)
    screen.drawText(1, h-7, string.format("%02d", hours))
    screen.drawText(10, h-7, ":")
    screen.drawText(13, h-7, string.format("%02d", minutes))

    screen.drawText(29, h-7, "MAP")

end



