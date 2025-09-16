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
        simulator:setInputNumber(1, simulator:getSlider(1) * 100)        -- set input 31 to the value of slider 1

        simulator:setInputBool(32, simulator:getIsToggled(2))       -- make button 2 a toggle, for input.getBool(32)
        simulator:setInputNumber(32, simulator:getSlider(2) * 50)   -- set input 32 to the value from slider 2 * 50
    end;
end
---@endsection


--[====[ IN-GAME CODE ]====]

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!

function math.clamp(n, low, high) return math.min(math.max(n, low), high) end

function DrivetrainController(_increment, _maxSpeed, _maxMotorThrottle, _speedMargin, _integral, _derivative, _directDecelerationMultiplier)
    return
    {
        appliedThrottle = 0,

        maxMotorThrottle = _maxMotorThrottle or 0.5,

        pErr = 0,
        margin = _speedMargin or 20,
        increment = _increment or 0.001,

        I = _integral or 20,
        D = _derivative or 0,

        maxSpeed = _maxSpeed or 200,
        decelerationMultiplier = _directDecelerationMultiplier or 10,

        -----------------------------------------------------------------
        getAppliedThrottle = function(self)
            return self.appliedThrottle
        end,

        setAppliedThrottle = function(self, currentThrottle)
            self.appliedThrottle = math.clamp(currentThrottle, 0, 1)
            return self.getAppliedThrottle(self)
        end,

        -----------------------------------------------------------------
     
        runDirect = function(self, wheelRPS, throttle, currentSpeed, brake, wheelSlip)
            local speedMargin, currentMargin

            currentMargin = self.margin * (throttle / 100)

            speedMargin = (math.abs(wheelRPS) * (math.pi)) - math.abs(currentSpeed)
            
            expectedSpeed = ((math.clamp(throttle, 0, 100) * self.maxSpeed) / 100) / 3.6

            if(brake > 0)then
                self.appliedThrottle = 0
                
            elseif((currentSpeed > expectedSpeed) or wheelSlip)then -- deceleration
                self.appliedThrottle = self.appliedThrottle - (self.increment * self.decelerationMultiplier)

            elseif(throttle > 0 and currentSpeed < expectedSpeed and speedMargin < currentMargin)then -- acceleration
                self.appliedThrottle = self.appliedThrottle + (self.increment * (throttle/100))
            end
            if(throttle < 0)then -- dynamic brake
                self.appliedThrottle = self.appliedThrottle + (self.increment * (throttle/100))

            end
            
            return self.setAppliedThrottle(self, self.appliedThrottle), expectedSpeed
        end,

        runDirectSelector = function(self, targetSpeed, currentSpeed, wheelRPS, throttle, brake, wheelSlip)
            -- proprtional = self.increment * err
            -- integral = (integral + (err - delta)) * self.I 
            -- derivative = (increment * (delta)) * self.D
            -- self.I and self.D are clamped by increment

            local err, speedMargin, currentMargin, errDelta, integral, derivative 

            -- calculate speed error
            err = targetSpeed - math.abs(currentSpeed)
            errDelta = self.pErr - err                  --derivative

            currentMargin = self.margin * (throttle / 100)

            speedMargin = (math.abs(wheelRPS) * (math.pi)) - math.abs(currentSpeed)


            integral = (self.increment * (throttle/100)) * (err - errDelta) * self.I
            derivative = (self.increment * (throttle/100)) * errDelta * self.D

            if(brake > 0)then
                self.appliedThrottle = 0
            
            elseif(wheelSlip)then
                self.appliedThrottle = self.appliedThrottle - (self.increment * self.decelerationMultiplier)
            
            elseif(err > 0)then -- too slow
                if(self.appliedThrottle < 0)then -- foolproof
                    self.appliedThrottle = 0

                end

                if(throttle > 0)then
                    if(speedMargin < currentMargin)then -- got enough margin to accelerate
                    
                        self.appliedThrottle = self.appliedThrottle + integral - derivative

                    elseif(speedMargin > currentMargin)then
                        self.appliedThrottle = self.appliedThrottle - integral + derivative

                    end
                elseif(throttle < 0)then -- dynamicBrake
                    self.appliedThrottle = self.appliedThrottle + (self.increment * (throttle/100))
                
                elseif(throttle == 0)then
                    self.appliedThrottle = self.appliedThrottle - (self.increment / 100)

                end

            elseif(err < 0)then -- too fast
                self.appliedThrottle = self.appliedThrottle + integral - derivative            
            end

            self.pErr = err

            
            return self.setAppliedThrottle(self, self.appliedThrottle), targetSpeed
        end,
    }
end


appliedThrottle = 0
expectedSpeed = 0

increment = property.getNumber("Throttle Increment")
maxSpeed = property.getNumber("Max Speed")
maxMotorThrottle = property.getNumber("Max Motor Throttle")
speedMargin = property.getNumber("Wheel Speed Margin")
Integral = property.getNumber("Controller Amplifying Multiplier")
Derivative = property.getNumber("Controller Dampening Multiplier")
decelerationMultiplier = property.getNumber("Direct Deceleration Multiplier")

afb = DrivetrainController(increment, maxSpeed, maxMotorThrottle, speedMargin, Integral, Derivative, decelerationMultiplier)

function onTick()
    -- inputs
    --Local Inputs

    throttle = input.getNumber(1)
    throttleMode = input.getNumber(2)
    targetSpeed = input.getNumber(3)
    currentSpeed = input.getNumber(4)
    wheelRPS = input.getNumber(5)
    brake = input.getNumber(6)

    wheelSlip = input.getBool(1)

    if(throttleMode == 0)then   -- direct manual
        appliedThrottle, expectedSpeed = afb:runDirect(wheelRPS, throttle, currentSpeed, brake, wheelSlip)

    elseif(throttleMode == 1)then   -- direct selector
        appliedThrottle, expectedSpeed = afb:runDirectSelector(targetSpeed, currentSpeed, wheelRPS, throttle, brake, wheelSlip)
        
    else        
        -- big no no case
        appliedThrottle = afb:setAppliedThrottle(0)
        expectedSpeed = 0

    end

    output.setNumber(1, appliedThrottle * maxMotorThrottle)
    output.setNumber(2, expectedSpeed)
end



