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
function setColor(array, alpha)
    alpha = alpha or 255
    screen.setColor(array[1], array[2], array[3], alpha)
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

helpy = textSlide(2, 10, 40, 2, 60)

function onTick()
    helpy:onTickUpdate()
end

function onDraw()
    helpy:drawTextSlide("North_Sawyer South_Sawyer Hoy_Castle Hoy_Town Fort_Lewin Holt_Town_North Holt_Town_South Oneil City_North City_South")
end
