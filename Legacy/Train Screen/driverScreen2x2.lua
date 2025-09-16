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
        simulator:setInputBool(2, simulator:getIsToggled(1))       -- if button 1 is clicked, provide an ON pulse for input.getBool(1)
        simulator:setInputNumber(1, simulator:getSlider(1))         -- set input 1 to the value of slider 1

        simulator:setInputBool(3, simulator:getIsToggled(1))      
        simulator:setInputNumber(6, simulator:getSlider(2) * 200)        

        simulator:setInputBool(8, simulator:getIsToggled(1))     
        simulator:setInputNumber(10, simulator:getSlider(3) * 200)       

        simulator:setInputBool(9, simulator:getIsToggled(1))       -- make button 2 a toggle, for input.getBool(32)
        simulator:setInputNumber(32, simulator:getSlider(2) * 50)   -- set input 32 to the value from slider 2 * 50

        simulator:setInputBool(6, simulator:getIsToggled(1))      
        simulator:setInputBool(7, simulator:getIsToggled(1))      

    end;
end
---@endsection


--[====[ IN-GAME CODE ]====]

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!

ticks = 0
require("driverscreen")

function onTick()
    ticks = ticks + 1

    parkingBrake = input.getBool(2)
    emergBrake = input.getBool(3)
    deadman = input.getBool(8)

    wheelSlip = input.getBool(9)

    doorLeft = input.getBool(4)
    doorRight = input.getBool(5)

    throttle = input.getNumber(1)

    autoBrake = input.getNumber(3)
    trainBrake = input.getNumber(9)

    reverser = input.getNumber(4)
    cruiseSpeed = input.getNumber(6) * 3.6
    currentSpeed = input.getNumber(10) * 3.6

end

function onDraw()
    w = screen.getWidth()
    h = screen.getHeight()

    screen.setColor(0,0,0)
    screen.drawClear()

    -- draw borders
    screen.setColor(255,255,255)
    screen.drawLine(16,0,16,h)
    screen.drawLine(0, h-16,w , h-16)

    -- Train Brakes
        printValue("TB", math.floor(trainBrake * 10) / 10, 1, 5, 255,255,255)

    -- Automatic Brakes
        printValue("AB", math.floor(autoBrake * 10) / 10, 1, 22, 255,255,255)

    -- Driving data display

        -- draw circle display
        screen.drawCircle( (w / 2) + 8, (h / 2) - 8, 20)
        screen.drawCircle( (w / 2) + 8, (h / 2) - 8, 15)

        screen.drawLine((w / 2) + 8, (h / 2) - 8, (w/2) + 8 + 20 * math.cos((2*math.pi)/ 3), (h/2) - 8 + 20 * math.sin((2*math.pi)/ 3))
        screen.drawLine((w / 2) + 8, (h / 2) - 8, (w/2) + 8 + 20 * math.cos(math.pi / 3), (h/2) - 8 + 20 * math.sin(math.pi / 3))

        -- draw lines and text
        -- throttle
        screen.setColor(200,0,0)
        radThrottle = (throttle / 1.2)*(2*math.pi) + (2*math.pi / 3)

        lineX = (w/2) + 8 + 20 * math.cos(radThrottle)
        lineY = (h/2) - 8 + 20 * math.sin(radThrottle)

        screen.drawLine((w / 2) + 8, (h / 2) - 8, lineX, lineY) 

        -- current speed
        screen.setColor(255,255,255)
        radCurrentSpeed = (currentSpeed/370)*(2*math.pi) + (2*math.pi / 3)

        lineX = (w/2) + 8 + 20 * math.cos(radCurrentSpeed)
        lineY = (h/2) - 8 + 20 * math.sin(radCurrentSpeed)

        screen.drawLine((w / 2) + 8, (h / 2) - 8, lineX, lineY) 

        -- cruise speed
        screen.setColor(0,0,150)

        radCruiseSpeed = (cruiseSpeed/370)*(2*math.pi) + (2*math.pi / 3)

        lineX = (w/2) + 8 + 20 * math.cos(radCruiseSpeed)
        lineY = (h/2) - 8 + 20 * math.sin(radCruiseSpeed)


        screen.drawLine((w / 2) + 8, (h / 2) - 8, lineX, lineY) 


        -- erase drawing lines
        screen.setColor(0,0,0)
        screen.drawCircleF( (w / 2) + 8, (h / 2) - 8, 14)

        --screen.setColor(10,10,10) debug
        screen.drawRectF((w/2) + 1, (h / 2) + 4, 14, 8)
        screen.drawRectF((w/2), (h / 2) + 6, 16, 2)
        screen.drawRectF((w/2) - 1, (h / 2) + 8, 18, 3)

        -- draw current speed
        screen.setColor(255,255,255)
        if (currentSpeed > 160 or reverser == -1) then
            screen.setColor(200,0,0)
        end
        screen.drawTextBox((w / 2) - 4, 15 ,25, 5, math.floor(currentSpeed * 10) / 10, 0)

        -- draw speed selector
        screen.setColor(0,0,150)
        screen.drawTextBox((w / 2) - 4, 21 ,25, 5, math.floor(cruiseSpeed * 10) / 10, 0)

        -- draw throttle power
        screen.setColor(200,0,0)
        screen.drawTextBox((w / 2) - 4, 27 ,25, 5, math.floor(throttle * 1000) / 10, 0)

    -- State Icons
        -- Parking Brakes
        if (parkingBrake) then
            drawAlerter(18,h-11,0)
        end

        -- Emergency Brakes
        if (emergBrake) then
            drawAlerter(27,h-11,1)
        end
        -- SIFA
        if (deadman) then
            drawAlerter(36,h-11,3)
        end
        -- Doors
        if (doorLeft or doorRight) then
            drawAlerter(45,h-11,4)
        end
        -- Wheel Slip
        if (wheelSlip) then
            drawAlerter(54,h-11,2)
        end

        
end



