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

function AFB(increment, speedMargin, derivative)
    return
    {
        appliedThrottle = 0,
        pErr = 0,
        margin = speedMargin,
        increment = increment,
        D = derivative,

        update = function (s, currentThrottle)
            s.appliedThrottle = currentThrottle
        end,

        run = function (s, targetSpeed, currentSpeed, wheelRPS, throttle)
            local err, speedMargin

            -- calculate speed error
            err = targetSpeed - math.abs(currentSpeed)

            speedMargin = (math.abs(wheelRPS) * (math.pi)) - math.abs(currentSpeed)

            -- gotta calculate Proportionnal
            if(err > 0) then     -- speed too slow
                if(s.appliedThrottle < 0)then
                    s.appliedThrottle = 0
                end

                if(throttle > 0)then
                    if(speedMargin < (s.margin * throttle))then -- still got margin to accelerate ?
                        s.appliedThrottle = s.appliedThrottle + (s.increment * math.clamp(err, -1, 1))

                    elseif(speedMargin > (s.margin * throttle))then
                        s.appliedThrottle = s.appliedThrottle - (s.increment * math.clamp(err, -1, 1))

                    end
                end

            elseif(err < 0)then -- speed too fast
                s.appliedThrottle = s.appliedThrottle + (s.increment * math.clamp(err, -1, 1))

            end

            --s.integralTotal = s.integralTotal + (s.I * err)
            s.appliedThrottle = math.clamp(s.appliedThrottle + ((s.increment * s.D) * math.clamp(err - s.pErr, -1, 0)), -1, 1)
            s.pErr = err
            return s.appliedThrottle
        end
    }
end

function math.clamp(n, low, high) return math.min(math.max(n, low), high) end

appliedThrottle = 0
appliedBrake = 0

speedMargin = property.getNumber("Wheel Speed Margin")
throttleIncrement = property.getNumber("Throttle Increment")
afbDampeningMultiplier = property.getNumber("AFB Dampening Multiplier")

afb = AFB(throttleIncrement, speedMargin, afbDampeningMultiplier)

function onTick()
    -- inputs
    --Local Inputs

    throttle = input.getNumber(27)
    reverser = input.getNumber(28)
    throttleMode = input.getNumber(29)
    speedTarget = input.getNumber(30)
    currentSpeed = input.getNumber(31)
    wheelRPS = input.getNumber(32)

    brakeEvent = input.getBool(31)
    wheelSlip = input.getBool(32)


    speedErr = ((math.pi) * math.abs(wheelRPS)) - math.abs(currentSpeed)
    maxMarginSpeed = speedMargin * throttle
    -- if wheel slip
    if(wheelSlip)then
        if(appliedThrottle > 0 )then
            appliedThrottle = appliedThrottle - throttleIncrement
        else
            appliedBrake = appliedBrake + throttleIncrement
        end

    -- elif throttle > 0 and reverser != 0 and no brake
    elseif (throttle > 0 and reverser ~= 0) then
        -- if manual mode
        if(throttleMode == 0)then

            if(brakeEvent)then
                appliedThrottle = appliedThrottle - throttleIncrement
            
            elseif(speedErr < maxMarginSpeed)then
                appliedThrottle = appliedThrottle + throttleIncrement
            end

        -- else if cruise mode case
        else
            afb:update(appliedThrottle)
            
            if(throttleMode == 2)then
                speedTarget = property.getNumber("Yard Speed") / 3.6
            end

            -- calculate applied throttle
            appliedThrottle = afb:run(speedTarget, currentSpeed, wheelRPS, throttle)
            appliedBrake = math.abs(math.clamp(appliedThrottle, -1, 0))
        end
    -- else (default case)
    elseif(throttle == 0)then
        appliedThrottle = 0
        appliedBrake = 0
    end

    output.setNumber(1, math.clamp(appliedThrottle, 0, 1) * reverser)
    output.setNumber(2, appliedBrake)
end



