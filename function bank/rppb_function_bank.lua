-- Author: MrCreeperman147
-- GitHub: <GithubLink>
-- Workshop: <WorkshopLink>

-- I like trains --

-- lua library for RPPB Systems Functions

--------------------------------------------------------
-- Lists
-- background, border, character

DARK_THEME = {{0, 0, 0}, {200, 200, 255}, {220, 220, 220}}
BTN_CLOSE_COLOR = {{160, 0, 0}, {220, 220, 220}, {0, 0, 0}}
BTN_OK_COLOR = {{0, 0, 200}, {220, 220, 220}, {150, 150, 255}}

POSITIVE_COLOR = {0, 0, 200}
NEGATIVE_COLOR = {255, 239, 0}
-- Destination Names

STATION_NAMES_SL = 
{
    "Endo",
    "Trinite",

    "Spycakes",
    "Donkk",
    "Key",
    "Camodo",

    "Sawyer North",

    "FJ",
    "Charlizard",
    "Mauve",
    "Thomas",
    "Albiebie"
}

STATION_NAME_NSO = 
{
    "North Sawyer",
    "South Sawyer",
    "Hoy Castle",
    "Hoy Town",
    "Fort Lewin",
    "Holt Town North",
    "Holt Town South",
    "Oneil",
    "City North",
    "City South"
}

--------------------------------------------------------

function isPressedInRegion(isPressed,inputX, inputY, rectX, rectY, rectW, rectH)
	return isPressed and (inputX > rectX and inputY > rectY and inputX < rectX+rectW and inputY < rectY+rectH)
end

function pid(p,i,d)
    return
    {
        p=p,i=i,d=d,E=0,D=0,I=0,
		run=function(s,sp,pv)
			local E,D,A
			E = sp-pv
			D = E-s.E
			A = math.abs(D-s.D)
			s.E = E
			s.D = D
			s.I = A<E and s.I +E*s.i or s.I*0.5
			return E*s.p +(A<E and s.I or 0) +D*s.d
		end
	}
end

function diyPID(p, i, d)
    return
    {   p=p, i=i, d=d, prevError = 0,
        run = function(this, sp, pv, loopDelay)
            local E, P, I, D, output
            
            E = sp - pv -- error

            P = this.p * E
            I = I + (E * this.i * loopDelay)
            D = this.d * (this.prevError - E) / loopDelay

            this.prevError = E
            output = P + I + D

            return output
        end
    }
end

function AFB(increment, speedMargin, integral, derivative)
    return
    {
        appliedThrottle = 0,
        pErr = 0,
        margin = speedMargin,
        increment = increment,
        I = integral,
        D = derivative,

        update = function (s, currentThrottle)
            s.appliedThrottle = currentThrottle
        end,

        run = function (s, targetSpeed, currentSpeed, wheelRPS, throttle)
            local err, speedMargin, currentMargin, delta

            -- calculate speed error
            err = targetSpeed - math.abs(currentSpeed)
            delta = err - s.pErr
            currentMargin = s.margin * throttle

            speedMargin = (math.abs(wheelRPS) * (math.pi)) - math.abs(currentSpeed)

            -- gotta calculate Proportionnal
            if(err > 0) then     -- speed too slow
                if(s.appliedThrottle < 0)then
                    s.appliedThrottle = 0
                end
                -- proprtional = s.increment * err
                -- integral = (integral + (err - delta)) * s.I
                -- derivative = (increment * (delta)) * s.D

                if(throttle > 0)then
                    if(speedMargin < currentMargin)then -- still got margin to accelerate ?
                        s.appliedThrottle = s.appliedThrottle + (s.increment * math.clamp(err - delta, -1, 1) * s.I)

                    elseif(speedMargin > currentMargin)then
                        s.appliedThrottle = s.appliedThrottle - (s.increment * math.clamp(err - delta, -1, 1) * s.I)

                    end
                end
            elseif(err < 0)then -- speed too fast
                s.appliedThrottle = s.appliedThrottle + (s.increment * math.clamp(err - delta, -1, 1) * s.I)

            end

            s.appliedThrottle = math.clamp(s.appliedThrottle + (s.increment * math.clamp(delta, -1, 0)) * s.D, -1, 1)
            s.pErr = err
            return s.appliedThrottle
        end
    }
end

function DrivetrainController(increment, maxSpeed, maxMotorThrottle, speedMargin, integral, derivative, directDecelerationMultiplier)
    return
    {
        appliedThrottle = 0,

        maxMotorThrottle = maxMotorThrottle or 0.2,

        pErr = 0,
        margin = speedMargin or 20,
        increment = increment or 0.0001,

        I = math.clamp(integral, 0, increment) or 0.0001,
        D = math.clamp(derivative, 0, increment) or 0,

        maxSpeed = maxSpeed or (200 * 3.6),
        decelerationMultiplier = directDecelerationMultiplier or 10,

        -----------------------------------------------------------------
        setAppliedThrottle = function(this, currentThrottle)
            this.appliedThrottle = math.clamp(currentThrottle, -this.maxMotorThrottle, this.maxMotorThrottle)
        end,

        getAppliedThrottle = function(this)
            return this.appliedThrottle
        end,
        -----------------------------------------------------------------
     
        runDirect = function(this, wheelRPS, throttle, currentSpeed, brake, wheelSlip)
            local speedMargin, currentMargin

            currentMargin = this.margin * (throttle / 100)

            speedMargin = (math.abs(wheelRPS) * (math.pi)) - math.abs(currentSpeed)
            
            expectedSpeed = (throttle * (this.maxSpeed / 100)) * 3.6

            if(brake > 0)then
                this.appliedThrottle = 0
                
            elseif(currentSpeed > expectedSpeed or wheelSlip)then
                this.appliedThrottle = this.appliedThrottle - (this.increment * this.decelerationMultiplier)

            elseif(currentSpeed < expectedSpeed and speedMargin < currentMargin)then
                this.appliedThrottle = this.appliedThrottle + (this.increment * (throttle/100))

            elseif(throttle <= 0)then
                this.setAppliedThrottle(0)

            end

            return this.setAppliedThrottle(this.appliedThrottle), expectedSpeed
        end,

        runSimulated = function(this, wheelRPS, throttle, currentSpeed, brake, wheelSlip)
            -- appliedThrottle defined only by throttle
            -- increment = (increment * throttle) / 100
            -- maxAppliedThrottle 
            -- y = speed km/h

            -- y = (sqrt(x*((z/100)*z) * (x^2 / 10000)) * 3.6
            -- y = speed m/s
            -- x = throttle 0-100
            -- z = maxSpeed km/h
            local speedMargin, currentMargin

            currentMargin = this.margin * (throttle / 100)

            speedMargin = (math.abs(wheelRPS) * (math.pi)) - math.abs(currentSpeed)
            
            expectedSpeed = (math.sqrt(throttle*((this.maxSpeed/100)*this.maxSpeed)) * (throttle^2 / 10000))
            
            if(brake > 0)then
                this.appliedThrottle = 0    
            
            elseif(currentSpeed > expectedSpeed or wheelSlip)then
                this.appliedThrottle = this.appliedThrottle - (this.increment)

            elseif(currentSpeed < expectedSpeed and speedMargin < currentMargin)then
                this.appliedThrottle = this.appliedThrottle + ((this.increment * (throttle^2)) / 1000)

            elseif(throttle < 0)then
                this.appliedThrottle = this.appliedThrottle - (this.increment + ((this.increment * (throttle^2)) / 1000))

            end

            this.setAppliedThrottle(this.appliedThrottle)
            return this.appliedThrottle, expectedSpeed
        end,

        runDirectSelector = function(this, targetSpeed, currentSpeed, wheelRPS, throttle, brake, wheelSlip)
            -- proprtional = s.increment * err
            -- integral = (integral + (err - delta)) * s.I 
            -- derivative = (increment * (delta)) * s.D
            -- s.I and s.D are clamped by increment

            local err, speedMargin, currentMargin, errDelta, integral, derivative 

            -- calculate speed error
            err = targetSpeed - math.abs(currentSpeed)
            errDelta = this.pErr - err                  --derivative

            currentMargin = this.margin * (throttle / 100)

            speedMargin = (math.abs(wheelRPS) * (math.pi)) - math.abs(currentSpeed)


            integral = math.clamp((this.increment * (err - errDelta) * this.I), -this.increment, this.increment)
            derivative = math.clamp((this.increment * errDelta * this.D), -this.increment, this.increment)

            if(brake > 0)then
                this.appliedThrottle = 0
            
            elseif(wheelSlip)then
                this.appliedThrottle = this.appliedThrottle - (this.increment * this.decelerationMultiplier)
            
            elseif(err > 0)then -- too slow
                if(this.appliedThrottle < 0)then
                    this.setAppliedThrottle(0)
                end

                if(throttle > 0)then
                    if(speedMargin < currentMargin)then -- got enough margin to accelerate
                    
                        this.appliedThrottle = this.appliedThrottle + integral - derivative

                    elseif(speedMargin > currentMargin)then
                        this.appliedThrottle = this.appliedThrottle - integral + derivative

                    end
                end

            elseif(err < 0)then -- too fast
                this.appliedThrottle = this.appliedThrottle - integral + derivative

            end

            this.pErr = err
            this.setAppliedThrottle(this.appliedThrottle)
            return this.appliedThrottle
        end,

        runSimulatedSelector = function(this, targetSpeed, currentSpeed, wheelRPS, throttle, brake, wheelSlip)
            -- proprtional = s.increment * err
            -- integral = (integral + (err - delta)) * s.I 
            -- derivative = (increment * (delta)) * s.D
            -- s.I and s.D are clamped by increment

            local err, speedMargin, currentMargin, errDelta, simIncrement, integral, derivative


            err = targetSpeed - math.abs(currentSpeed)
            errDelta = this.pErr - err                  --derivative

            currentMargin = this.margin * (throttle / 100)

            speedMargin = (math.abs(wheelRPS) * (math.pi)) - math.abs(currentSpeed)

            simIncrement = ((this.increment * (throttle^2)) / 1000)

            integral = math.clamp((simIncrement * (err - errDelta) * this.I), -this.increment * 10, this.increment * 10)
            derivative = math.clamp((simIncrement * errDelta * this.D), -this.increment * 10, this.increment * 10)

            expectedSpeed = (math.sqrt(throttle*((this.maxSpeed/100)*this.maxSpeed)) * (throttle^2 / 10000))

            if(brake > 0)then
                this.appliedThrottle = 0
            
            elseif(throttle == 0 or wheelSlip)then
                this.appliedThrottle = this.appliedThrottle - this.increment

            elseif(err > 0)then
                if(throttle > 0)then
                    if(expectedSpeed < currentSpeed)then
                        this.appliedThrottle = this.appliedThrottle - this.increment

                    elseif(expectedSpeed > currentSpeed and speedMargin < currentMargin)then
                        this.appliedThrottle = this.appliedThrottle + integral - derivative

                    end
                elseif(throttle < 0)then
                    this.appliedThrottle = this.appliedThrottle - (this.increment + ((this.increment * (throttle^2)) / 1000))

                end
            elseif(err < 0)then
                this.appliedThrottle = this.appliedThrottle - integral + derivative

            end

            this.setAppliedThrottle(this.appliedThrottle)
            return this.appliedThrottle, expectedSpeed
        end
    }
end

function externalBtn(boolIndex, mode)
    return
    {
        MODE = mode,
        INDEX = boolIndex,
        CURRENT_TICK = 0,
        CURRENT_STATE = false,


        onTickUpdate = function (this)
            localState = input.getBool(this.INDEX)

            if (this.MODE == 0) then        -- pulse mode
                
                if(this.CURRENT_TICK > 0 and not localState)then
                    this.CURRENT_STATE = false
                    this.CURRENT_TICK = 0

                elseif(this.CURRENT_TICK == 0 and localState)then
                    this.CURRENT_STATE = true
                    this.CURRENT_TICK = this.CURRENT_TICK + 1

                elseif(this.CURRENT_TICK > 0 and localState)then
                    this.CURRENT_STATE = false
                    this.CURRENT_TICK = this.CURRENT_TICK + 1

                end
            
            elseif (this.MODE == 1) then    -- toggle mode

                if(this.CURRENT_TICK == 0 and localState)then
                    this.CURRENT_STATE = true

                elseif(this.CURRENT_STATE and not localState and this.CURRENT_TICK == 0)then
                    this.CURRENT_TICK = this.CURRENT_TICK + 1

                elseif(this.CURRENT_STATE and localState and this.CURRENT_TICK > 0)then
                    this.CURRENT_STATE = false
                    this.CURRENT_TICK = 0

                end

            elseif (this.MODE == 2) then    -- press mode
                this.CURRENT_STATE = localState
            end

            return this.CURRENT_STATE
        end
    }
end
------------------------------------------------------

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

                needle = (currentValue * ((this.max + this.min) - this.middle)) / this.min
                screen.drawRectF(this.x + 1, this.y + this.middle + 1, this.width - 1, needle)

                screen.setColor(this.negColorArray[1], this.negColorArray[2], this.negColorArray[3])
                screen.drawLine(this.x + 1, this.y + this.middle + needle, this.x + this.width, this.y + this.middle + needle)


            else
                screen.setColor(this.posColorArray[1], this.posColorArray[2], this.posColorArray[3], 150)

                needle = (currentValue * (this.middle - 1)) / this.max
                screen.drawRectF(this.x + 1, this.y + this.middle, this.width - 1,  -needle)

                screen.setColor(this.posColorArray[1], this.posColorArray[2], this.posColorArray[3])
                screen.drawLine(this.x + 1, this.y + this.middle - needle, this.x + this.width, this.y + this.middle - needle)
            end

        else
            if(currentValue < 0)then
                screen.setColor(this.negColorArray[1], this.negColorArray[2], this.negColorArray[3], 150)

                needle = (currentValue * (((this.max + this.min) - this.middle) - 1)) / this.min
                screen.drawRectF(this.x + this.middle, this.y + 1, -needle, this.height - 2)

                screen.setColor(this.negColorArray[1], this.negColorArray[2], this.negColorArray[3])
                screen.drawLine(this.x + this.middle - needle, this.y + 1, this.x + this.middle - needle, this.y + this.height - 1)

            else
                screen.setColor(this.posColorArray[1], this.posColorArray[2], this.posColorArray[3], 150)

                needle = (currentValue * this.middle) / this.max
                screen.drawRectF(this.x + this.middle, this.y + 1, needle, this.height - 2)

                screen.setColor(this.posColorArray[1], this.posColorArray[2], this.posColorArray[3])
                screen.drawLine(this.x + this.middle + needle, this.y + 1, this.x + this.middle + needle, this.y + this.height - 1)
            end

        end

    end

}
end

function screen.segmentDisplayV2(colorArray, x, y, width, height, min, max, halved)
    return
    {
        colorArray = colorArray,

        x = x,
        y = y,
        width = width,
        height = height,
    
        middle = height,
    
        min = math.abs(min),
        max = math.abs(max),
    
        halved = halved or false,
    
        vertical = true,
    
    
    
        draw = function (this, currentValue, gaugeColor)
            currentValue = math.clamp(currentValue, -this.min, this.max)
    
            screen.setColor(this.colorArray[1], this.colorArray[2], this.colorArray[3])
    
            -- orientation
            if(this.width > this.height)then
                this.vertical = false
            end

            if(not this.vertical)then
                this.middle = width
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
    
                    screen.drawLine(this.x + (this.width - this.middle), this.y, this.x + (this.width - this.middle), this.y + this.height)
                end
            end
    
            -- animation
            if(this.vertical)then
                if(currentValue < 0)then
                    screen.setColor(gaugeColor[1], gaugeColor[2], gaugeColor[3], 150)
    
                needle = (currentValue * ((this.max + this.min) - this.middle)) / this.min
                    screen.drawRectF(this.x + 1, this.y + this.middle + 1, this.width - 1, needle)
    
                    screen.setColor(gaugeColor[1], gaugeColor[2], gaugeColor[3])
                    screen.drawLine(this.x + 1, this.y + this.middle + needle, this.x + this.width, this.y + this.middle + needle)
    
    
                else
                    screen.setColor(gaugeColor[1], gaugeColor[2], gaugeColor[3], 150)
    
                    needle = (currentValue * (this.middle - 1)) / this.max
                    screen.drawRectF(this.x + 1, this.y + this.middle, this.width - 1,  -needle)
    
                    screen.setColor(gaugeColor[1], gaugeColor[2], gaugeColor[3])
                    screen.drawLine(this.x + 1, this.y + this.middle - needle, this.x + this.width, this.y + this.middle - needle)
                end
    
            else
                if(currentValue < 0)then
                    needle = (currentValue * (this.width - this.middle - 1)) / this.min

                    screen.setColor(gaugeColor[1], gaugeColor[2], gaugeColor[3], 150)    
                    screen.drawRectF(this.x + (this.width - this.middle) - 0.5, this.y + 1, needle, this.height - 1)
    
                    screen.setColor(gaugeColor[1], gaugeColor[2], gaugeColor[3])
                    screen.drawLine(this.x + (this.width - this.middle) + needle, this.y + 1, this.x + (this.width - this.middle) + needle, this.y + this.height)
    
                else
                    needle = (currentValue * (this.middle - 1)) / this.max

                    screen.setColor(gaugeColor[1], gaugeColor[2], gaugeColor[3], 150)    
                    screen.drawRectF(this.x + (this.width - this.middle) + 1, this.y + 1, needle - 1, this.height - 1)
    
                    screen.setColor(gaugeColor[1], gaugeColor[2], gaugeColor[3])
                    screen.drawLine(this.x + (this.width - this.middle) + needle, this.y + 1, this.x + (this.width - this.middle) + needle, this.y + this.height)
                end
    
            end
    
        end
    
    }
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

        screen.setColor(this.colorArray[1][1], this.colorArray[1][2], this.colorArray[1][3])

        -- draw frame
        screen.drawCircle(this.x, this.y, this.radius)
        screen.drawLineRadius(this.x, this.y, this.radius, 0 + this.offset)
        screen.drawLineRadius(this.x, this.y, this.radius, (5*math.pi)/3 + this.offset)

        -- 60° == math.pi/3
        total = this.min + this.max
        if(halved)then
            this.middle = ((total - this.max) * ((2*math.pi) - (math.pi/3))) / total
            screen.drawLineRadius(this.x, this.y, this.radius, this.middle + this.offset)
        end

        screen.setColor(this.colorArray[1][1], this.colorArray[1][2], this.colorArray[1][3])
        screen.drawCircle(this.x, this.y, this.radius - this.width)

        screen.setColor(this.colorArray[2][1], this.colorArray[2][2], this.colorArray[2][3])
        screen.drawCircleF(this.x, this.y, this.radius - this.width - 1)

        --screen.drawTriangleF(this.x, this.y, this.x + (this.radius * 1.5)  * math.cos(this.offset), this.y + (this.radius * 1.5) * math.sin(this.offset),  this.x + (this.radius * 1.5) * math.cos(this.offset - (math.pi/3)), this.y + (this.radius * 1.5) *(this.offset - (math.pi/3)))

        -- animate
        if(currentValue < 0)then
            screen.setColor(this.negColorArray[1], this.negColorArray[2], this.negColorArray[3])
            
            needle = (currentValue * (this.middle)) / this.min
            screen.drawLineRadius(this.x, this.y, this.radius - 1, this.middle + needle + this.offset)

        else
            screen.setColor(this.posColorArray[1], this.posColorArray[2], this.posColorArray[3])

            needle = (currentValue * ((5*math.pi)/3 - this.middle)) / this.max
            screen.drawLineRadius(this.x, this.y, this.radius - 1, this.middle + needle + this.offset)

        end
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

function screen.window(x, y , width, height, colorArray)
    return
    {
        X = x,
        Y = y,

        WIDTH = width,
        HEIGHT = height,

        COLOR_ARRAY = colorArray,

        draw = function(this)

            -- draw background
            screen.setColor(colorArray[1][1], colorArray[1][2], colorArray[1][3])
            screen.drawRectF(this.X, this.Y, this.WIDTH, this.HEIGHT)
            
            -- draw borders
            screen.setColor(colorArray[2][1], colorArray[2][2], colorArray[2][3])
            screen.drawRect(this.X, this.Y, this.WIDTH, this.HEIGHT)

            screen.setColor(0,0,0)
        end,
        
        isClicked = function(this, inputX, inputY)

            return (inputX > this.X and inputY > this.Y and inputX < this.X + this.WIDTH and inputY < this.Y + this.HEIGHT)
        end
    }
end

function screen.button(x, y, width, height, colorArray, text)
    return
    {
        WINDOW = screen.window(x, y, width, height, colorArray),

        X = x,
        Y = y,

        WIDTH = width,
        HEIGHT = height,

        COLOR_ARRAY = colorArray,

        TEXT = text,

        draw = function(this)
            this.WINDOW:draw()

            screen.setColor(colorArray[3][1], colorArray[3][2], colorArray[3][3])
            screen.drawTextBox(this.X + 2, this.Y + 1, this.WIDTH - 1, this.HEIGHT - 1, this.TEXT, 0, 0)
            
            screen.setColor(0,0,0)

        end,

        isClicked = function(this, inputX, inputY)
            
            return this.WINDOW:isClicked(inputX, inputY)
        end
    }
end

function screen.modal(x, y, width, height, colorArray)
    return
    {
        BTN_CLOSE_COLOR = {{160, 0, 0}, {220, 220, 220}, {0, 0, 0}},

        WINDOW = screen.window(x, y, width, height, colorArray),
        BTN_CLOSE = screen.button(x + width - 5, y , 5, 5, BTN_CLOSE_COLOR, ""),

        X = x,
        Y = y,

        WIDTH = width,
        HEIGHT = height,

        COLOR_ARRAY = colorArray,

        draw = function(this)
            this.WINDOW:draw()
            this.BTN_CLOSE:draw()
        end,

        isClicked = function(this, inputX, inputY)
            return (this.BTN_CLOSE:isClicked(inputX, inputY) or not this.WINDOW:isClicked(inputX, inputY))
        end
    }
end

function screen.alerter(x, y, width, height, colorArray, text)
    return
    {
        BTN_OK_COLOR = {{0, 0, 200}, {220, 220, 220}, {150, 150, 255}},

        WINDOW = screen.modal(x, y, width, height, colorArray),

        OK_BTN = screen.button((x + width) / 2, y + height - 10, 12, 8, BTN_OK_COLOR, "OK"),

        X = x,
        Y = y,

        WIDTH = width,
        HEIGHT = height,

        COLOR_ARRAY = colorArray,

        TEXT = text,

        draw = function(this)
            this.WINDOW:draw()
            this.OK_BTN:draw()

            screen.setColor(this.COLOR_ARRAY[3][1], this.COLOR_ARRAY[3][2], this.COLOR_ARRAY[3][3])
            screen.drawTextBox(this.X + 2, this.Y + 1, this.WIDTH - 1, this.HEIGHT - 9, this.TEXT, 0, 0)

            screen.setColor(0,0,0)
        end,

        okIsClicked = function(this, inputX, inputY)
            return this.OK_BTN:isClicked(inputX, inputY)
        end,

        isClicked = function(this, inputX, inputY)
            return this.WINDOW:isClicked(inputX, inputY)
        end
    }
end

function screen.drawTextSmall(x,y,t)
    t=tostring(t)
    for i=1,t:len()do 
        local c=t:sub(i,i):upper():byte()*3-95 
        if c>193 then
            c=c-78
        end 
        c="0x"..string.sub("0000D0808F6F5FAB6D5B7080690096525272120222010168F9F5F1BBD9DBE2FDDBFBB8BCFBFEAF0A01A025055505289C69D7A7FB6699F96FB9FA869BF2F9F921EF69F11FCFF8F696FA4F9EFA55BB8F8F1FE1EF3FD2DC3CBFDF9086109F4841118406F90F09F6642",c,c+2)
        for j=0,11 do 
            if c&(1<<(11-j))>0 then 
                local b=x+j//4+i*4-4     
                screen.drawLine(b,y+j%4,b,y+j%4+1)
            end
        end     
    end 
end

function screen.setColor(array, alpha)
    alpha = alpha or 255
    screen.setColor(array[1], array[2], array[3], alpha)
end
------------------------------------------------------

function string.setChar(string, index, value)
    
    string1 = ""
    range = tostring(value):len() - 1


    if(index > 1)then
        string1 = string:sub(1, index - 1)
    end

    
    string3 = string:sub(index + range + 1)

    return string1 .. value .. string3
end

function string.getChar(string, index, range)
    range = range or string:len() - index
    return string:sub(index, index + range)
end

--------------------------------------------------------

function math.clamp(x, a, b)
    return x<a and a or x>b and b or x
end

--------------------------------------------------------

function timer()
    return
    {
        -- init
        TIMER = 0,
        DURATION = 0,

        set = function(this, duration)      -- set the timer, duration in seconds
            this.DURATION = duration * 60   -- convert in ticks
        end,

        update = function (this)            -- should be called at the start of onTick()
            local state = false
            this.TIMER = this.TIMER + 1

            if(this.TIMER == this.DURATION)then
                state = true
            end

            return state
        end,

        
        reset = function (this) -- reset the timer
            this.TIMER = 0
        end
    }
end

function counterUpDown(min, max, startValue)
    return
    {
        clampMin = min,
        clampMax = max,
        value = startValue,

        update = function(this, bool, increment, min, max) -- bool is a boolean(on/off) value
            
            local increment = increment or 1
            this.clampMin = min or this.clampMin
            this.clampMax = max or this.clampMax

            -- test if we increment the value or decrement it
            if(bool and (this.clampMax > this.value))then -- if ON and not equal or above upper clamp
                this.value = this.value + increment

            elseif(not bool and (this.clampMin < this.value))then -- else if OFF (not ON) and not equal or under lower clamp
                this.value = this.value - increment
            end

            return this.value
        end,

        reset = function(this, min, max, startValue)
            this.clampMin = min or this.clampMin
            this.clampMax = max or this.clampMax
            this.value = startValue or 0
        end
    }
end

--------------------------------------------------------
function station(name)
    return
    {
        NAME = name,
        PASSED = false,

        getName = function(this)
            return this.NAME
        end,

        setPassed = function(this, state)
            this.PASSED = state
        end,

        getPassed = function(this)
            return this.PASSED
        end
    }
end

function optionButton(colorArray, x, y, text)
    return
    {
        colorArray = colorArray,
        x = x,
        y = y,
        text = text,

        pxlSize = {(#text * 4) + 1, 4},

        isClicked = function(this, isTouched, inputX, inputY)
            local isClicked = false
            if(isPressedInRegion(isTouched, inputX, inputY, x - 1, y - 1, this.pxlSize[1] + 1, this.pxlSize[2] + 1))then
                isClicked = true
            end
            return isClicked
        end,

        draw = function(this, isClicked)
            if(isClicked)then
                screen.setColor(colorArray[2][1], colorArray[2][2], colorArray[2][3])
            else
                screen.setColor(colorArray[1][1], colorArray[1][2], colorArray[1][3])

            end
            screen.drawLine(x, y, x, y + this.pxlSize[2])

            screen.setColor(colorArray[1][1], colorArray[1][2], colorArray[1][3])
            screen.drawTextSmall(x + 2, y, this.text)
        end
    }
end

function textSlide(x, y, width, speed, pause, text_color, background_color)
    return
    {
        X = x,
        Y = y,
        WIDTH = width,
        HEIGHT = 5,
        TEXT = "",
        PIXEL_INDEX = 0,
        MAX_PIXEL_INDEX = 0,
        TEXT_SIZE = 0,
        TEXT_COLOR = text_color or {255, 255, 255},
        BACKGROUND_COLOR = background_color or {0, 0, 0},
        SPEED = speed or 1, -- tick/pxl
        HOLD = pause or 20,
        TICK = 0,
        HOLD_TICK = 0,

        onTickUpdate = function (this)
            
            if(this.TEXT_SIZE > this.WIDTH)then

                -- case 1 : hold start
                if(this.HOLD_TICK < this.HOLD)then
                    this.HOLD_TICK = this.HOLD_TICK + 1

                -- case 2 : slide
                elseif(this.HOLD_TICK == this.HOLD and this.PIXEL_INDEX < this.MAX_PIXEL_INDEX)then
                    if(this.TICK % this.SPEED == 0)then
                        this.PIXEL_INDEX = this.PIXEL_INDEX + 1
                    end
                    this.TICK = this.TICK + 1

                -- case 3 : hold end
                elseif(this.HOLD_TICK < this.HOLD * 2 and this.PIXEL_INDEX == this.MAX_PIXEL_INDEX)then
                    this.HOLD_TICK = this.HOLD_TICK + 1
                
                -- case 4 : reset
                elseif(this.HOLD_TICK == this.HOLD * 2)then
                    this.HOLD_TICK = 0
                    this.TICK = 0
                    this.PIXEL_INDEX = 0
                end

            end
        end,

        drawTextSlide = function (this, text)
            
            -- if new text
                -- set new text
                -- calculate text size
            if(this.TEXT ~= text)then
                this.TEXT = text
                this.TEXT_SIZE = this.TEXT:len() * 5

                this.MAX_PIXEL_INDEX = this.TEXT_SIZE - this.WIDTH - 2

            end
            -- draw text background 
            -- draw text at x - pixel_index
            -- cleanup head and tails of text so only width of text is visible

            setColor(this.BACKGROUND_COLOR)
            screen.drawRectF(this.X, this.Y, this.WIDTH, this.HEIGHT)

            setColor(this.TEXT_COLOR)
            screen.drawText(this.X - this.PIXEL_INDEX, this.Y, this.TEXT)

            setColor(this.BACKGROUND_COLOR)
            screen.drawRectF(this.X - this.PIXEL_INDEX, this.Y, this.PIXEL_INDEX, this.HEIGHT)
            screen.drawRectF(this.X + this.WIDTH, this.Y, 128, this.HEIGHT)
        end
    }
end

---------------------------------------------------------
function decimalToBinary(decimal, bits)
    binary = ""

    while decimal > 0 do
        binary = tostring(decimal & 1) .. binary
        decimal = decimal >> 1
    end

    while binary:len() < bits do
        binary = '0' .. binary
    end

    return binary
end

function binaryToDecimal(binary)
    return tonumber(binary, 2)
end

function stringToDecimalTable(value)
    tab = {}
    
    for i=1,value:len() do
      table.insert(tab, value:byte(i))
    end
    
    return tab
end

function decimalTableToString(decimalTable)
  stringValue = ""
  
  for i, v in ipairs(decimalTable) do
     stringValue = stringValue .. string.char(v)
  end  
  
  return stringValue
end

function encodeString(payload) -- string return integer table
    -- convert string to decimal table
    decimalTable = stringToDecimalTable(payload)
    binaryTable = {}
    packets = {}
    
    -- foreach decimal in decimal table
            -- convert to binary 8bits
    for index, value in ipairs(decimalTable) do
        table.insert(binaryTable, decimalToBinary(value, 8))
    end

    while (#binaryTable % 3 ~= 0) do
        table.insert(binaryTable, decimalToBinary(0, 8))
    end

    -- assemble binary into packets (3 binary into 1 packet)
    for i = 1, #binaryTable - 2, 3 do
        packet = binaryTable[i] .. binaryTable[i + 1] .. binaryTable[i + 2]
        table.insert(packets, binaryToDecimal(packet))
    end

    -- return packet table
    return packets
end

function decodeString(packets) -- table number return string
    payload = ""
    insertTable = {}

    for i, v in ipairs(packets) do

        value = decimalToBinary(v, 24)


        insertTable[1] = string.char(binaryToDecimal(string.getChar(value, 1, 7)))
        insertTable[2] = string.char(binaryToDecimal(string.getChar(value, 9, 7)))
        insertTable[3] = string.char(binaryToDecimal(string.getChar(value, 17, 7)))
    
        for i, v in ipairs(insertTable) do
            if(v ~= string.char(0))then
                payload = payload .. insertTable[i]
            end
        end
    end

	payload = string.getChar(payload, 1, payload:len() - 2)
    return payload
end

function transmitStringTable()
    return
    {
        NUM_BITS = 0,

        STRING_TABLE = {},
        CURRENT_PACKET = {},

        PIN = 1,

        START_TRANSMISSION = 0,
        START_TEXT = 0,
        END_TEXT = 0,
        END_TRANSMISSION = 0,

        TABLE_INDEX = 1,
        PACKET_INDEX = 1,

        STATE = 0,


        init = function(this, nbBits)
            this.NUM_BITS = nbBits

            this.START_TRANSMISSION = 1
            this.START_TEXT = 2
            this.END_TEXT = 3
            this.END_TRANSMISSION = 4
        end,

        prepareTransmission = function(this, stringTable, pin)
            this.STRING_TABLE = stringTable
            this.PIN = pin

            this.TABLE_INDEX = 1
            this.PACKET_INDEX = 1

            this.STATE = 1

            this.CURRENT_PACKET = {}
        end,

        transmit = function(this)           -- start transmission
            if(this.STATE == 1)then
                output.setNumber(this.PIN, this.START_TRANSMISSION)
                this.TABLE_INDEX = 1

                this.STATE = 2

            elseif(this.STATE == 2)then     -- start text
                output.setNumber(this.PIN, this.START_TEXT)
                this.CURRENT_PACKET = stringToDecimalTable(this.STRING_TABLE[this.TABLE_INDEX])
                this.PACKET_INDEX = 1
                this.STATE = 3

            elseif(this.STATE == 3)then     -- text
                if (this.PACKET_INDEX <= #this.CURRENT_PACKET) then
                    output.setNumber(this.PIN, this.CURRENT_PACKET[this.PACKET_INDEX])
                    this.PACKET_INDEX = this.PACKET_INDEX + 1
         
                elseif(this.PACKET_INDEX > #this.CURRENT_PACKET)then
                    this.STATE = 4
                end

            elseif(this.STATE == 4)then     -- end text
                output.setNumber(this.PIN, this.END_TEXT)

                if(this.TABLE_INDEX < #this.STRING_TABLE)then
                    this.TABLE_INDEX = this.TABLE_INDEX + 1
    
                    this.STATE = 2
                else
                    this.STATE = 5
                end

            elseif(this.STATE == 5)then     -- end transmission
                output.setNumber(this.PIN, this.END_TRANSMISSION)
                this.STATE = 0
            end

            return this.STATE
        end,

        prepareExtract = function(this, pin)
            this.PIN = pin
            this.STATE = 1

            this.STRING_TABLE = {}
            this.CURRENT_PACKET = {}
        end,

        extract = function(this, input)
            if(input == this.START_TRANSMISSION)then
                this.STRING_TABLE = {}

            elseif(input == this.START_TEXT)then
                this.CURRENT_PACKET = {}

            elseif(input == this.END_TEXT)then
                table.insert(this.STRING_TABLE, decodeString(this.CURRENT_PACKET))

            elseif(input == this.END_TRANSMISSION)then
                return this.STRING_TABLE

            else  -- a packet
                table.insert(this.CURRENT_PACKET, input)
            end
            
            return this.STRING_TABLE
        end
    }

end