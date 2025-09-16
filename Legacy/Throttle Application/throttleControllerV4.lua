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
require("technicalscreen")

ticks = 0
appliedThrottle = 0
speedTarget = 0

maxLegalSpeed = property.getNumber("Max Legal Speed")
speedMargin = property.getNumber("Wheel Speed Margin")
throttleIncrement = property.getNumber("Throttle Increment")

afb = AFB(throttleIncrement, property.getNumber("Margin"), speedMargin)

function onTick()
    ticks = ticks + 1

    -- inputs
    -- Master Signal
    throttle = input.getNumber(1)
    reverser = input.getNumber(4)
    throttleMode = input.getNumber(5)
    cruiseSpeed = input.getNumber(6)

    --Local Signal
    currentSpeed = input.getNumber(29)
    
    absCurrentSpeed = math.abs(currentSpeed)

    yardSpeed = input.getNumber(30)

    motorDelta = input.getNumber(31)

    wheelRPS = input.getNumber(32)


    wheelSlip = input.getBool(32)


    speedErr = (math.pi * wheelRPS) - currentSpeed
    --Dynamic Brake mode or wheelSLip
    if(throttle <= 0 and absCurrentSpeed ~= 0 or wheelSlip)then
        
        -- calculate brake power according speed direction
        appliedThrottle = (appliedThrottle + throttleIncrement)

        -- get max throttle
        maxThrottle = ((math.clamp(absCurrentSpeed, 0, maxLegalSpeed) * 100) / maxLegalSpeed)/100

        -- clamp brake according current speed and throttle
        appliedThrottle = math.clamp(appliedThrottle, 0, maxThrottle)

        direction = 1
        -- check speed direction
        if(currentSpeed > 0)then
            direction = -1
        end

        --reduce appliedThrottle

        output.setNumber(1, appliedThrottle * direction)

    elseif(throttle > 0 and reverser ~= 0 and throttleMode == 0)then
        appliedThrottle = math.abs(appliedThrottle)

        --Normal mode

        if(not(throttle < appliedThrottle) and (speedErr < speedMargin)) and not((speedErr > speedMargin + 0.1) or (throttle < appliedThrottle))then

            appliedThrottle = math.clamp((appliedThrottle + throttleIncrement), 0, throttle)

        else

            appliedThrottle = math.clamp((appliedThrottle - throttleIncrement), 0, throttle)

        end


        output.setNumber(1, appliedThrottle * reverser)


    elseif (throttle > 0 and reverser ~= 0 and (throttleMode == 1 or throttleMode == 2)) then

        -- update afb
        afb:update(appliedThrottle)

        --Cruise mode and Yard Mode
        if(throttleMode == 1)then
            speedTarget = cruiseSpeed
        else
            speedTarget = yardSpeed
        end

        -- adjust appliedThrottle
        if((throttle >= appliedThrottle) and (speedErr < speedMargin)) and not((speedErr > speedMargin + 0.1) or (throttle < appliedThrottle))then

            appliedThrottle = afb:run(speedTarget * reverser, currentSpeed, motorDelta, wheelRPS, throttle)

        end


        output.setNumber(1, appliedThrottle)

    elseif(throttle == 0 or reverser == 0)then
        appliedThrottle = 0
        output.setNumber(1, 0)
    end
    
end



