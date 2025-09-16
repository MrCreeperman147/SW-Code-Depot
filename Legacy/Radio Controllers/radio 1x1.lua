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
        simulator:setInputNumber(2, screenConnection.height)
        simulator:setInputNumber(3, screenConnection.touchX)
        simulator:setInputNumber(4, screenConnection.touchY)

        -- NEW! button/slider options from the UI
        simulator:setInputBool(31, simulator:getIsClicked(1))       -- if button 1 is clicked, provide an ON pulse for input.getBool(31)
        simulator:setInputNumber(31, simulator:getSlider(1))        -- set input 31 to the value of slider 1

        simulator:setInputNumber(2, simulator:getSlider(2) * 24)
        simulator:setInputNumber(3, simulator:getSlider(3) * 60)

    end;
end
---@endsection


--[====[ IN-GAME CODE ]====]

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!

ticks = 0
function onTick()
    ticks = ticks + 1

    channel = input.getNumber(1)

    localppt = input.getBool(1)
    ppt = input.getBool(2)
    mute = input.getBool(3)

    hours = math.floor(input.getNumber(2))
    minutes = math.floor(input.getNumber(3))

    signalStrenght = input.getNumber(4)
end

function onDraw()
    h = screen.getHeight()
    w = screen.getWidth()

    screen.setColor(0,0,0)
    screen.drawClear()

    -- time
    screen.setColor(255,255,255)
    screen.drawText(1, 1, string.format("%02d", hours))
    screen.drawText(10, 1, ":")
    screen.drawText(13, 1, string.format("%02d", minutes))

    -- signal strenght
    if( signalStrenght == 0 ) then
        screen.setColor(120, 120, 120) 
    else
        screen.setColor(0, 238, 8)
    end
    screen.drawLine(w - 8, 4, w - 8, 6)

    if( signalStrenght > 0.50 ) then
        screen.setColor(0, 238, 8)
    else
        screen.setColor(120, 120, 120)
    end
    screen.drawLine(w - 6, 3, w - 6, 6)

    if( signalStrenght > 0.75 ) then
        screen.setColor(0, 238, 8)
    else
        screen.setColor(120, 120, 120)
    end
    screen.drawLine(w - 4, 2, w - 4, 6)

    if( signalStrenght > 0.9 ) then
        screen.setColor(0, 238, 8)
    else
        screen.setColor(120, 120, 120)
    end
    screen.drawLine(w - 2, 1, w - 2, 6)

    -- RADIO
    screen.setColor(255,255,255)
    screen.drawRectF(0, 8, w, 7)
    screen.setColor(0,0,0)
    screen.drawTextBox(0, 9, w, 5, "RADIO", 0)

    --  channel

    screen.setColor(255,255,255)
    screen.drawTextBox(0, 17, w, 5, tostring(math.floor(channel)), 0)

    -- passive/ppt/mute
    screen.drawRectF(0, 24, w, 8)

    textOutput = "N/A"
    if (mute) then
        textOutput = "MUTE"
    
    elseif (ppt) then
        textOutput = "PPT"

    elseif (localppt) then
        textOutput = "LOCAL"

    elseif (signalStrenght > 0) then
        textOutput = "INCOM"
    end
    
    screen.setColor(0,0,0)
    screen.drawTextBox(0, 25, w, 5, textOutput, 0)
    
end



