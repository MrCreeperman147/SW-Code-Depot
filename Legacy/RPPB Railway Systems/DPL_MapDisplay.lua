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
    simulator:setScreen(1, "1x1")
    simulator:setProperty("ExampleNumberProperty", 123)

    -- Runs every tick just before onTick; allows you to simulate the inputs changing
    ---@param simulator Simulator Use simulator:<function>() to set inputs etc.
    ---@param ticks     number Number of ticks since simulator started
    function onLBSimulatorTick(simulator, ticks)

        -- touchscreen defaults
        local screenConnection = simulator:getTouchScreen(1)
        simulator:setInputBool(1, screenConnection.isTouched)
        simulator:setInputNumber(1, screenConnection.width)
        simulator:setInputNumber(2, 65586)
        simulator:setInputNumber(3, 65586)
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
DARK_THEME = {{0, 0, 3}, {220, 220, 220}, {150, 150, 255}}

function onTick()
    heading = ((input.getNumber(1)*(-1))*360+360)%360

    currentX = input.getNumber(2)
    currentY = input.getNumber(3)
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
    lineaX = pixelX + 4 * math.cos(radHeading)
    lineaY = pixelY + 4 * math.sin(radHeading)

    radHeading = (heading - 90)*(math.pi)/180 - 10
    linebX = pixelX + 4 * math.cos(radHeading)
    linebY = pixelY + 4 * math.sin(radHeading)

    radHeading = (heading - 90)*(math.pi)/180 + 10
    linecX = pixelX + 4 * math.cos(radHeading)
    linecY = pixelY + 4 * math.sin(radHeading)

    screen.setColor(150,0,0)
    screen.drawTriangleF(lineaX, lineaY, linebX, linebY, linecX, linecY)

    if(w >= 64)then
        screen.setColor(DARK_THEME[1][1], DARK_THEME[1][2], DARK_THEME[1][3], 150)

        screen.drawRectF(0, 0, 37, 15)
        screen.setColor(DARK_THEME[2][1], DARK_THEME[2][2], DARK_THEME[2][3])
        screen.drawTextBox(1, 2, 35 , 5, "X:"..math.floor(currentX), 0)
        screen.drawTextBox(1, 8, 35, 5, "Y:"..math.floor(currentY), 0)

    end
end
