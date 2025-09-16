-- Author: MrCreeperman147
-- GitHub: <GithubLink>
-- Workshop: <WorkshopLink>

--I like trains--

-- lua library for common weather functions of RPPB systems 

-- sun/moon
function drawSun(posX, posY, hours)

    if(hours < 19 and hours > 6) then
        screen.setColor(255,220,100)
        screen.drawCircleF(posX, posY, 10)
        
        screen.setColor(255,200,0)
        screen.drawCircle(posX, posY, 10)
    else

        screen.setColor(200,200,200)
        screen.drawCircleF(posX, posY, 10)
    
        screen.setColor(150,150,150)
        screen.drawCircle(posX, posY, 10)
        screen.drawCircle(posX+6, posY, 10)
    
        screen.setColor(0,0,0)
        screen.drawCircleF(posX+7, posY, 10)
    end


end
-- cloud
function drawCloud(posX, posY)

    screen.setColor(180, 180, 180)
    screen.drawCircleF(posX, posY, 10)
    screen.drawCircleF(posX-10, posY+4, 6)
    screen.drawCircleF(posX+10, posY+5, 5)
    screen.drawLine(posX - 7, posY + 9, posX + 7, posY + 9)

    screen.setColor(230, 230, 230)
    screen.drawCircleF(posX, posY, 9)
    screen.drawCircleF(posX-10, posY+4, 5)
    screen.drawCircleF(posX+10, posY+5, 4)



end


-- rain
function drawRain(posX, posY, level)


    if(level > 0)then

        drawCloud(posX, posY)

        screen.setColor(160,240,255)
        screen.drawLine(posX, posY + 12, posX - 2, posY + 20)
        if (level > 0.8) then
            screen.drawLine(posX - 12, posY + 12, posX - 14, posY + 20)
            screen.drawLine(posX - 8, posY + 12, posX - 10, posY + 20)
            screen.drawLine(posX - 4, posY + 12, posX - 6, posY + 20)
            screen.drawLine(posX, posY + 12, posX - 2, posY + 20)
            screen.drawLine(posX + 4, posY + 12, posX + 2, posY + 20)
            screen.drawLine(posX + 8, posY + 12, posX + 6, posY + 20)
            screen.drawLine(posX + 12, posY + 12, posX + 10, posY + 20)
        elseif (level > 0.5) then
            screen.drawLine(posX - 4, posY + 12, posX - 6, posY + 20)
            screen.drawLine(posX, posY + 12, posX - 2, posY + 20)
            screen.drawLine(posX + 4, posY + 12, posX + 2, posY + 20)
        elseif (level > 0.2) then
            screen.drawLine(posX - 4, posY + 12, posX - 6, posY + 20)
            screen.drawLine(posX + 4, posY + 12, posX + 2, posY + 20)
        end
    end
end
-- wind
function drawWind(posX, posY, speed)


    if(speed > 3)then
        drawCloud(posX, posY)
        screen.setColor(200,200,200)
        if (speed > 32) then
            screen.drawLine(posX - 17, posY, posX - 27, posY)
            screen.drawLine(posX - 17, posY + 4, posX - 27, posY + 4)
            screen.drawLine(posX - 16, posY + 8, posX - 26, posY + 8)
            screen.drawLine(posX - 11, posY - 4, posX - 21, posY - 4)
            screen.drawLine(posX - 9, posY - 8, posX - 19, posY - 8)


        elseif (speed > 16) then
            screen.drawLine(posX - 17, posY, posX - 27, posY)
            screen.drawLine(posX - 17, posY + 4, posX - 27, posY + 4)
            screen.drawLine(posX - 11, posY - 4, posX - 21, posY - 4)

        elseif (speed > 8) then
            screen.drawLine(posX - 16, posY - 2, posX - 26, posY - 2)
            screen.drawLine(posX - 17, posY + 2, posX - 27, posY + 2)
        end
    end

end

-- fog
function drawFog(posX, posY, level)

    if(level > 0.2)then  
        drawCloud(posX, posY)  
        screen.setColor(190,190,190,100)
        screen.drawLine(posX - 15, posY + 12, posX + 15, posY + 12)
        if (level > 0.8) then
            screen.drawLine(posX - 18, posY + 12, posX + 12, posY + 12)
            screen.drawLine(posX - 12, posY + 14, posX + 18, posY + 14)
            screen.drawLine(posX - 18, posY + 17, posX + 12, posY + 17)
            screen.drawLine(posX - 12, posY + 19, posX + 18, posY + 19)

        elseif (level > 0.6) then
            screen.drawLine(posX - 18, posY + 12, posX + 12, posY + 12)
            screen.drawLine(posX - 12, posY + 14, posX + 18, posY + 14)
            screen.drawLine(posX - 18, posY + 17, posX + 12, posY + 17)

        elseif (level > 0.4) then
            screen.drawLine(posX - 18, posY + 14, posX + 12, posY + 14)
            screen.drawLine(posX - 12, posY + 16, posX + 18, posY + 16)
        end
    end
end