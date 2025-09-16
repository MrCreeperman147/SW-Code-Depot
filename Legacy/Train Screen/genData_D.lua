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
        simulator:setInputNumber(29, screenConnection.width)
        simulator:setInputNumber(30, screenConnection.height)
        simulator:setInputNumber(31, screenConnection.touchX)
        simulator:setInputNumber(32, screenConnection.touchY)

        -- NEW! button/slider options from the UI
        simulator:setInputBool(31, simulator:getIsClicked(1))       -- if button 1 is clicked, provide an ON pulse for input.getBool(31)
        simulator:setInputNumber(4, simulator:getSlider(1) * 60)        -- set input 31 to the value of slider 1

        simulator:setInputBool(32, simulator:getIsToggled(2))       -- make button 2 a toggle, for input.getBool(32)
        simulator:setInputNumber(5, simulator:getSlider(2) * 120)   -- set input 32 to the value from slider 2 * 50
        simulator:setInputNumber(6, simulator:getSlider(3) * 4000)   
        simulator:setInputNumber(7, simulator:getSlider(4) * 5)   

    end;
end
---@endsection


--[====[ IN-GAME CODE ]====]

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!

require("technicalscreen")

ticks = 0
function onTick()
    ticks = ticks + 1

    hours = math.floor(input.getNumber(1))
    minutes = math.floor(input.getNumber(2))

    rpm = input.getNumber(3) * 60
    temp = math.floor(input.getNumber(4))
    prod = math.floor(input.getNumber(5))
    --cons = math.floor(input.getNumber(7) * 10) / 10 --L/s

    iteration = math.floor(input.getNumber(6))
end

function onDraw()
    h = screen.getHeight()
    w = screen.getWidth()

    screen.setColor(0,0,0)
    screen.drawClear()

    drawOverlay(h, w, hours, minutes, "GEN "..iteration)

    -- rpm
    screen.setColor(230,230,230)
    screen.drawCircle(w/4, h/4 + 7, 12)

    screen.drawLine((w / 4), (h/4) + 7, (w/4) + 12 * math.cos((2*math.pi) + 2.5), (h/4) + 7 + 12 * math.sin((2*math.pi) + 2.5))
    screen.drawLine((w / 4), (h/4) + 7, (w/4) + 12 * math.cos(0.6*(2*math.pi) + 2.5), (h/4) + 7 + 12 * math.sin(0.6*(2*math.pi) + 2.5))

    radRPM = (rpm/6000) * (2 * math.pi) + 2.5

    lineX = ((w/4)) + 12 * math.cos(radRPM)
    lineY = (h/4) + 7 + 12 * math.sin(radRPM)

    screen.setColor(200,0,0)
    screen.drawLine((w / 4), (h / 4) + 7, lineX, lineY) 

    screen.setColor(0,0,0)
    screen.drawRectF(w/4, (h/4)+7, 12, 12)
    screen.drawRectF(6,30, 12, 7)

    screen.setColor(200,0,0)
    screen.drawText(w / 4, (h / 4) + 9, math.floor(rpm / 100))
    screen.setColor(230,230,230)
    screen.drawText((w / 4) - 12, (h / 4) + 16, "RPM")


    -- temp
    screen.setColor(230,230,230)
    screen.drawCircle((w/4) * 3, h/4 + 7, 12)

    screen.drawLine((w / 4) * 3, (h/4) + 7, (w/4) * 3 + 12 * math.cos((2*math.pi) + 2.5), (h/4) + 7 + 12 * math.sin((2*math.pi) + 2.5))
    screen.drawLine((w / 4) * 3, (h/4) + 7, (w/4) * 3+ 12 * math.cos(0.6*(2*math.pi) + 2.5), (h/4) + 7 + 12 * math.sin(0.6*(2*math.pi) + 2.5))

    radTemp = (temp/200) * (2 * math.pi) + 2.5

    lineX = ((w/4) * 3) + 12 * math.cos(radTemp)
    lineY = (h/4) + 7 + 12 * math.sin(radTemp)

    screen.setColor(200,0,0)
    screen.drawLine((w / 4) * 3, (h / 4) + 7, lineX, lineY) 

    screen.setColor(0,0,0)
    screen.drawRectF((w/4) * 3, (h/4)+7, 12, 12)
    screen.drawRectF(((w/4) * 3) - 10,30, 12, 7)

    screen.setColor(200,0,0)
    screen.drawText((w / 4 * 3), (h / 4) + 9, temp)
    screen.setColor(230,230,230)
    screen.drawText((w / 4) * 3 - 12, (h / 4) + 16, "TEMP")

    -- prod
    screen.drawText(4, (h/2)+7, "PROD")
    screen.drawTextBox((w / 4) * 3 - 12, (h/2)+7, 24, 5, prod, 0)

    -- cons
    --screen.drawText(4, (h/2)+14, "CONS")
    --screen.drawTextBox((w / 4) * 3 - 18, (h/2)+14, 36, 5,( math.floor(cons * 10)/10) .. "L/S", 0)

end
