-- Author: MrCreeperman147
-- GitHub: <GithubLink>
-- Workshop: <WorkshopLink>

--I like trains--

-- lua library for common technical functions of RPPB systems 

--destList = {"spycakes", "donkk", "key", "camodo", "sawyern", "sawyers", "trinite", "endo", "fj", "charlizard", "mauve", "thomas", "albiebie", "clarke"}

function drawOverlay(h, w, hours, minutes, title)

    -- header
    screen.setColor(230,230,230)
    screen.drawLine(0, 7, w, 7)

    --time
    screen.drawText(1, 1, string.format("%02d", hours))
    screen.drawText(10, 1, ":")
    screen.drawText(13, 1, string.format("%02d", minutes))

    title = title or ""
    screen.drawTextBox(20, 1, 48, 5, title, 0)
    
end

-- math.clamp
function math.clamp(n, low, high) return math.min(math.max(n, low), high) end

-- PID controller
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

-- DIY PID
function diyPID(p, i, d)
    return
    {   p=p, i=i, d=d, prevError = 0,
        run = function(s, sp, pv, loopDelay)
            local E, P, I, D, output
            
            E = sp - pv -- error

            P = s.p * E -- proportional
            I = I + (E * s.i * loopDelay)
            D = s.d * (s.prevError - E) / loopDelay

            s.prevError = E
            output = P + I + D

            -- anti windup

            return output
        end
    }
end

-- AFB
function AFB(increment, marge, speedMargin)
    return
    {
        minI = increment - ((marge * increment) / 100),
        maxI = increment + ((marge * increment) / 100),
        appliedThrottle = 0, pErr = 0,
        circumference = math.pi * 1.25,

        update = function (s, currentThrottle)
            s.appliedThrottle = currentThrottle
        end,

        run = function (s, sp, pv, motorDelta, wheelRPS, throttle)
            local err, accErr, wheelSpeed, targetSpeed, speedErr

            -- calculate speed error
            err = math.clamp((sp - pv), -1, 1)
            
            -- calculate throttle delta error
            accErr = increment * motorDelta

            if(wheelRPS < 0) then
                
                targetSpeed = math.ceil(sp)
                wheelSpeed = math.ceil((wheelRPS * s.circumference))

            else
                targetSpeed = math.floor(sp)
                wheelSpeed = math.floor((wheelRPS * s.circumference))
            
            end
            speedErr = wheelSpeed - pv

            if(wheelSpeed ~= targetSpeed)then

                if(err > 0) then     -- speed too slow

                    if(not(accErr > s.maxI) or (((throttle >= s.appliedThrottle) and (speedErr < speedMargin)) and not((speedErr > speedMargin + 0.1) or (throttle < s.appliedThrottle))))then -- delta too low
                        s.appliedThrottle = math.clamp(s.appliedThrottle + (increment * err), -throttle, throttle)
                    end
                    
                elseif(err < 0 or accErr > s.maxI) then -- speed too fast
    
                    s.appliedThrottle = math.clamp(s.appliedThrottle + (increment * err), -throttle, throttle)  
                
                end
                
            end


            s.appliedThrottle = math.clamp(s.appliedThrottle + (0.5 * (err - s.pErr) / 100), -throttle, throttle)
            s.pErr = err
            return s.appliedThrottle
        end
    }
end

function screen.drawGaugeRadial(x, y, radius,  variable, maxVariable, label, decimal)

    decimal = decimal or 1

    screen.setColor(230,230,230)
    screen.drawCircle(x, y, radius)

    screen.drawLine(x, y, x + radius * math.cos((2*math.pi) + 2.5), y + radius * math.sin((2*math.pi) + 2.5))
    screen.drawLine(x, y, x + radius * math.cos(0.6*(2*math.pi) + 2.5), y + radius * math.sin(0.6*(2*math.pi) + 2.5))

    rad = (variable/maxVariable) * (2 * math.pi) + 2.5

    lineX = x + radius * math.cos(rad)
    lineY = y + radius * math.sin(rad)

    screen.setColor(200,0,0)
    screen.drawLine(x, y, lineX, lineY) 

    screen.setColor(0,0,0)
    screen.drawRectF(x, y, radius, radius)
    screen.setColor(10,0,0)
    screen.drawRectF(x + radius * math.cos((2*math.pi) + 2.5), y + radius * math.sin((2*math.pi) + 2.5), radius, radius / 2)

    screen.setColor(200,0,0)
    screen.drawText(x, y + 2, math.floor(variable / decimal))
    screen.setColor(230,230,230)
    screen.drawText(x - radius, y + 16, label)
end