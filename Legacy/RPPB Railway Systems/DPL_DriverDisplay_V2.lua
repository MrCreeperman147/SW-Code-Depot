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

        -- NEW! button/slider options from the UI
        simulator:setInputBool(31, simulator:getIsClicked(1))       -- if button 1 is clicked, provide an ON pulse for input.getBool(31)
        simulator:setInputNumber(3, simulator:getSlider(1) * 1)

        simulator:setInputBool(32, simulator:getIsToggled(2))       -- make button 2 a toggle, for input.getBool(32)
        simulator:setInputNumber(31, simulator:getSlider(2) * 350)   -- set input 32 to the value from slider 2 * 50

        simulator:setInputNumber(30, simulator:getSlider(3) * 350)   -- set input 32 to the value from slider 2 * 50

    end;
end
---@endsection


--[====[ IN-GAME CODE ]====]

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!

DARK_THEME = {{0, 0, 0}, {220, 220, 220}, {150, 150, 255}}

function screen.segmentDisplay(colorArray, x, y, width, height, min, max, halved, posColorArray, negColorArray)
    return
    {
        colorArray = colorArray,
        posColorArray = posColorArray or {0, 0 , 200}, 
        negColorArray = negColorArray or {255, 239, 0},
        x = x,
        y = y,
        width = width,
        height = height,
    
        middle = height,
    
        min = math.abs(min),
        max = math.abs(max),
    
        halved = halved or false,
    
        vertical = true,
    
    
    
        draw = function (this, currentValue)
            currentValue = math.clamp(currentValue, -this.min, this.max)
    
            screen.setColor(this.colorArray[1], this.colorArray[2], this.colorArray[3])
    
            -- orientation
            if(this.width > this.height)then
                this.vertical = false
            end
    
            -- draw frame
            screen.drawRect(this.x, this.y, this.width, this.height)
    
            if(this.halved)then
                total = this.max + this.min
    
                if(this.vertical)then
                    this.middle = math.ceil(((total - this.min) * height) / total)
    
                    screen.drawLine(this.x, this.y + this.middle, this.x + this.width, this.y + this.middle)
    
                else
                    this.middle = math.ceil(((total - this.min) * width) / total)
    
                    screen.drawLine(this.x + this.middle, this.y, this.x + this.middle, this.y + this.height)
                end
            end
    
            -- animation
            if(this.vertical)then
                if(currentValue < 0)then
                    screen.setColor(this.negColorArray[1], this.negColorArray[2], this.negColorArray[3], 150)
    
                    needle = math.floor((currentValue * ((this.max + this.min) - this.middle)) / this.min)
                    screen.drawRectF(this.x + 1, this.y + this.middle + 1, this.width - 1, needle)
    
                    screen.setColor(this.negColorArray[1], this.negColorArray[2], this.negColorArray[3])
                    screen.drawLine(this.x + 1, this.y + this.middle + needle, this.x + this.width, this.y + this.middle + needle)
    
                end
                if(currentValue >= 0)then
                    screen.setColor(this.posColorArray[1], this.posColorArray[2], this.posColorArray[3], 150)
    
                    needle = math.floor((currentValue * (this.middle - 1)) / this.max)
                    screen.drawRectF(this.x + 1, this.y + this.middle, this.width - 1,  -needle)
    
                    screen.setColor(this.posColorArray[1], this.posColorArray[2], this.posColorArray[3])
                    screen.drawLine(this.x + 1, this.y + this.middle - needle, this.x + this.width, this.y + this.middle - needle)
                end
    
            else
                if(currentValue < 0)then
                    screen.setColor(this.negColorArray[1], this.negColorArray[2], this.negColorArray[3], 150)
    
                    needle = math.floor((currentValue * (((this.max + this.min) - this.middle) - 1)) / this.min)
                    screen.drawRectF(this.x + this.middle, this.y + 1, -needle, this.height - 2)
    
                    screen.setColor(this.negColorArray[1], this.negColorArray[2], this.negColorArray[3])
                    screen.drawLine(this.x + this.middle - needle, this.y + 1, this.x + this.middle - needle, this.y + this.height - 1)
    
                end
                if(currentValue >= 0)then
                    screen.setColor(this.posColorArray[1], this.posColorArray[2], this.posColorArray[3], 150)
    
                    needle = math.floor((currentValue * this.middle) / this.max)
                    screen.drawRectF(this.x + this.middle, this.y + 1, needle, this.height - 2)
    
                    screen.setColor(this.posColorArray[1], this.posColorArray[2], this.posColorArray[3])
                    screen.drawLine(this.x + this.middle + needle, this.y + 1, this.x + this.middle + needle, this.y + this.height - 1)
                end
    
            end
    
        end
    
    }
end

function screen.drawAlerter(x, y, index)
    -- 0 Parking brake
    -- 1 Emergency brake
    -- 2 Wheel slip
    -- 3 Deadman alerter
    -- 4 Door Opened
    if (index == 0) then
        screen.setColor(0,0,200)
        screen.drawRectF(x, y, 8, 8)

        screen.setColor(255,255,255)
        screen.drawText(x + 2, y + 2, "P")

    elseif (index == 1) then
        screen.setColor(200,0,0)
        screen.drawRectF(x, y, 8, 8)

        screen.setColor(255,255,255)
        screen.drawText(x + 2, y + 2, "E")

    elseif (index == 2) then
        screen.setColor(200,0,0)
        screen.drawRectF(x, y, 8, 8)

        screen.setColor(255,255,255)
        screen.drawText(x + 2, y + 2, "W")

    elseif (index == 3) then
        screen.setColor(230,246,0)
        screen.drawRectF(x, y, 8, 8)

        screen.setColor(255,255,255)
        screen.drawText(x + 2, y + 2, "D")

    elseif (index == 4) then
        screen.setColor(0,180,0)
        screen.drawRectF(x, y, 8, 8)

        screen.setColor(255,255,255)
        screen.drawText(x + 2, y + 2, "D")
    end

    screen.setColor(255,255,255)
end

function screen.radialDisplay(colorArray, x, y, radius, width, min, max, offset, halved, posColorArray, negColorArray)
    return
    {
        colorArray = colorArray,
        posColorArray = posColorArray or {0, 0 , 200}, 
        negColorArray = negColorArray or {255, 239, 0},
        x = x,
        y = y,
        radius = radius,
        width = width,
    
        middle = 0, -- radian value
    
        min = math.abs(min),
        max = math.abs(max),
    
        offset = offset or 0,
        halved = halved or false,
    
        draw = function(this, currentValue)
            currentValue = math.clamp(currentValue, -this.min, this.max)
    

            -- draw frame
            screen.setColor(this.colorArray[1][1], this.colorArray[1][2], this.colorArray[1][3])

            screen.drawLineRadius(this.x, this.y, this.radius, 0 - (math.pi/2) - this.offset)
            screen.drawLineRadius(this.x, this.y, this.radius, 0 - (math.pi/2) + this.offset)
    
            -- 60° == math.pi/3
            total = this.min + this.max
            if(halved)then
                this.middle = ((total - this.max) * ((2*math.pi) - (math.pi/3))) / total
                screen.drawLineRadius(this.x, this.y, this.radius, this.middle + this.offset)
            end
            --screen.drawTriangleF(this.x, this.y, this.x + (this.radius * 1.5)  * math.cos(this.offset), this.y + (this.radius * 1.5) * math.sin(this.offset),  this.x + (this.radius * 1.5) * math.cos(this.offset - (math.pi/3)), this.y + (this.radius * 1.5) *(this.offset - (math.pi/3)))
    
            -- animate
            if(currentValue < 0)then
                screen.setColor(this.negColorArray[1], this.negColorArray[2], this.negColorArray[3])
                
                needle = (currentValue * (this.middle)) / this.min
                --screen.drawLineRadius(this.x, this.y, this.radius, this.middle + needle + this.offset)
    
            else
                screen.setColor(this.posColorArray[1], this.posColorArray[2], this.posColorArray[3])
    
                needle = (currentValue * ((5*math.pi)/3 - this.middle)) / this.max
                --screen.drawLineRadius(this.x, this.y, this.radius, this.middle + needle + this.offset)
    
            end
            screen.drawArc(this.x, this.y, this.radius + 1,-this.offset * (180/math.pi), (needle - this.middle - this.offset) * (180/math.pi), true, 1)

            screen.setColor(this.colorArray[1][1], this.colorArray[1][2], this.colorArray[1][3])
            screen.drawArc(this.x, this.y, this.radius, (5*math.pi/6) * (180/math.pi), -(5*math.pi/6) * (180/math.pi), false, 1)

            screen.setColor(this.colorArray[2][1], this.colorArray[2][2], this.colorArray[2][3])
            screen.drawArc(this.x, this.y, this.radius - this.width - 1, 0, 360, true, 1)
            screen.drawArc(this.x, this.y, this.radius + 1, 0, 360, false, 1)
            screen.drawArc(this.x, this.y, this.radius + 1.5, 0, 360, false, 1)
            screen.drawArc(this.x, this.y, this.radius + 2, 0, 360, false, 1)

        end
    }
end

function screen.drawLineRadius(x, y, radius, radians)
    screen.drawLine(x, y, x + radius * math.cos(radians), y + radius * math.sin(radians))
end

function screen.drawArc(...) --x,y,radius,(angle1,angle2,filled,step) FROM Tajin
	local x,y,r,a1,a2,pie,step = ...
	a1 = a1 or 0
	a2 = a2 or 360
	step = step or 22.5
	if a2<a1 then a2,a1=a1,a2 end
	local a,px,py,ox,oy,ar = false,0,0,0,0,0
	repeat
		a = a and math.min(a+step,a2) or a1
		ar = (a-90) *math.pi /180
		px,py = x +r *math.cos(ar), y +r *math.sin(ar)
		if a~=a1 then
			if pie then
				screen.drawTriangleF(x,y, ox,oy, px,py)
			else
				screen.drawLine(ox,oy,px,py)
			end
		end
		ox,oy = px,py
	until(a>=a2)
end

function math.clamp(n, low, high) return math.min(math.max(n, low), high) end
-- constants
side = 64 -- screen side size
throttleDisplay = screen.segmentDisplay(DARK_THEME[3], 2, 4, 5, 57, -0.5, 0.5, true)
speedDisplay = screen.radialDisplay({DARK_THEME[3], DARK_THEME[1]}, 26, 32, 15, 4, 0, 350, 5*math.pi/6)
brakeDisplay = screen.segmentDisplay(DARK_THEME[3], 44, 4, 5, 57, 0, 1, false, {255, 239, 0})

function onTick()
    -- radial display section inputs
    currentSpeed = math.abs(input.getNumber(1))
    targetSpeed = input.getNumber(3)
    throttleMode = input.getNumber(5)

    -- throttleDisplay section inputs
    
    appliedThrottle = input.getNumber(6)

    -- brakeDisplay section inputs
    appliedBrake = math.abs(input.getNumber(4))

    -- alerter section inputs
    parkingBrake = input.getBool(32)
    emergencyBrake = input.getBool(3)
    deadman = input.getBool(31)         ----
    wheelSlip = input.getBool(5)
    door = input.getBool(30)            ----
end

function onDraw()
    -- init
    screen.setColor(DARK_THEME[1][1], DARK_THEME[1][2], DARK_THEME[1][3])
    screen.drawClear()

    -- throttleDisplay section (5px)
    throttleDisplay:draw(appliedThrottle)

    -- radial display section (31px)
    speedDisplay:draw(currentSpeed)
    screen.setColor(DARK_THEME[1][1], DARK_THEME[1][2], DARK_THEME[1][3])
    --screen.drawRectF(21, 41, 10, 6)
    --screen.drawRectF(19, 44, 14, 2)

    screen.setColor(DARK_THEME[2][1], DARK_THEME[2][2], DARK_THEME[2][3])
    screen.drawTextBox(8, 7, 36, 5, math.floor(currentSpeed * 3.6) .. "KM/H", 0)

    screen.setColor(41, 73, 255)
    screen.drawTextBox(8, 55, 36, 5, math.floor(targetSpeed * 3.6) .. "KM/H", 0)
    mode = "CRUISE"
    
    if(throttleMode == 131)then
        mode = "MANUAL"
        screen.setColor(0, 226, 50)
    end
    screen.drawTextBox(8, 48, 36, 5, mode, 0)

    -- appliedBrake section (5px)
    brakeDisplay:draw(appliedBrake)

    -- alerter section (10px)
    if(parkingBrake)then
        screen.drawAlerter(53, 4, 0)
    end
    if(emergencyBrake) then
        screen.drawAlerter(53, 14, 1)
    end
    if(wheelSlip) then
        screen.drawAlerter(53, 24, 2)
    end
    if(deadman) then
        screen.drawAlerter(53, 34, 3)
    end
    if(door) then
        screen.drawAlerter(53, 44, 4)
    end

    -- cleanup
    screen.setColor(255, 0, 0)
    --screen.drawLine(15, 21, 16, 21)
    screen.setColor(DARK_THEME[1][1], DARK_THEME[1][2], DARK_THEME[1][3])
    screen.drawLine(39, 24, 40, 24)

    --screen.drawLine(0, 21, 255, 21)
    --screen.drawLine(15, 0, 15, 255)
    --screen.drawLine(36, 0, 36, 255)

end



