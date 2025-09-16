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
DARK_THEME = {{0, 0, 0}, {150, 150, 255}, {220, 220, 220}}

index = 0 -- {power display, car manager, route manager}

isPressed = false

function isPressedInRegion(isPressed,inputX, inputY, rectX, rectY, rectW, rectH)
	return isPressed and (inputX > rectX and inputY > rectY and inputX < rectX+rectW and inputY < rectY+rectH)
end

function onTick()
    isTouched = input.getBool(1)

    inputX = input.getNumber(3)
    inputY = input.getNumber(4)
    ---------------------------
    prevPressed = isPressedInRegion(isTouched, inputX, inputY, 0, 0, 8, 9)
    nextPressed = isPressedInRegion(isTouched, inputX, inputY, 56, 0, 8, 9)

    if(prevPressed and not isPressed)then
        index = index - 1
        if(index < 0)then
            index = 2
        end
        isPressed = true

    elseif(nextPressed and not isPressed)then
        index = index + 1
        if(index > 2)then
            index = 0
        end
        isPressed = true

    end

    if((not prevPressed and not nextPressed) and isPressed)then
       isPressed = false
    end

    output.setNumber(1, index)
end

function onDraw()
    screen.setColor(DARK_THEME[1][1], DARK_THEME[1][2], DARK_THEME[1][3])
    screen.drawClear()

    screen.setColor(DARK_THEME[2][1], DARK_THEME[2][2], DARK_THEME[2][3])
    screen.drawLine(0, 9, 64, 9)

    -- draw buttons
    screen.drawTriangleF(2,5, 5,2, 5,8)
    screen.drawTriangleF(61,5, 58,2, 58,8)

    -- title
    if(index == 0)then
        screen.drawText(10, 2, "POWER")

    elseif(index == 1)then
        screen.drawText(10, 2, "CAR")

    elseif(index == 2)then
        screen.drawText(10, 2, "ROUTE")

    end

end