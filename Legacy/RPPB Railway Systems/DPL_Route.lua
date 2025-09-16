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

-- background, border, character
DARK_THEME = {{0, 0, 0}, {200, 200, 255}, {220, 220, 220}}
BTN_CLOSE_COLOR = {{160, 0, 0}, {220, 220, 220}, {0, 0, 0}}
BTN_OK_COLOR = {{0, 0, 200}, {220, 220, 220}, {150, 150, 255}}

POSITIVE_COLOR = {0, 0, 200}
NEGATIVE_COLOR = {255, 239, 0}

STATIONS_ARCTIC = 
{
    "Endo",
    "Trinite",
}

STATIONS_SAWYER = {
    "Spycakes",
    "Donkk",
    "Key",
    "Camodo",
    "Sawyer North"
}

STATIONS_MEIER = {
    "FJ",
    "Charlizard",
    "Mauve",
    "Thomas",
    "Albiebie"
}

STATIONS_NSO = 
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

function window(x, y , width, height, colorArray)
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

function button(x, y, width, height, colorArray, text) -- herite de window
    return
    {
        WINDOW = window(x, y, width, height, colorArray),

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

function isPressedInRegion(isPressed,inputX, inputY, rectX, rectY, rectW, rectH)
	return isPressed and (inputX > rectX and inputY > rectY and inputX < rectX+rectW and inputY < rectY+rectH)
end

function setColor(array, alpha)
    alpha = alpha or 255
    screen.setColor(array[1], array[2], array[3], alpha)
end

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

function RouteConfig()
    return
    {
        STATIONS = {},
        ROUTE = {},
        PAGE = 0,
        CONF_LIST = 0,

        BTN_NEXT = button(8, 50, 23, 8, BTN_OK_COLOR, "NEXT"),
        BTN_PREV = button(35, 50, 23, 8, BTN_CLOSE_COLOR, "PREV"),

        IS_PRESSED = false,
        IS_PRESSED_CONF = false,


        init = function(this)
            this.ROUTE["arctic"] = STATIONS_ARCTIC
            this.ROUTE["sawyer"] = STATIONS_SAWYER
            this.ROUTE["nso"] = STATIONS_NSO
            this.ROUTE["meier"] = STATIONS_MEIER

            this.PAGE = 0
        end,

        onTickUpdate = function(this, isTouched, inputX, inputY)
            prevPage = isPressedInRegion(isTouched, inputX, inputY, 0, 0, 8, 9)
            nextPage = isPressedInRegion(isTouched, inputX, inputY, 56, 0, 8, 9)

            if(prevPage and not this.IS_PRESSED)then
                this.PAGE = this.PAGE - 1
                if(this.PAGE < 0)then
                    this.PAGE = 1
                end
                this.IS_PRESSED = true
        
            elseif(nextPage and not this.IS_PRESSED)then
                this.PAGE = this.PAGE + 1
                if(this.PAGE > 1)then
                    this.PAGE = 0
                end
                this.IS_PRESSED = true
        
            end
        
            if((not prevPage and not nextPage) and this.IS_PRESSED)then
                this.IS_PRESSED = false
            end

            if(main.PAGE == 0)then
        
            elseif(main.PAGE == 1)then
                prevList = isPressedInRegion(isTouched, inputX, inputY, 0, 8, 8, 9)
                nextList = isPressedInRegion(isTouched, inputX, inputY, 56, 8, 8, 9)

                if(prevList and not this.IS_PRESSED_CONF)then
                    this.CONF_LIST = this.CONF_LIST - 1
                    if(this.CONF_LIST < 0)then
                        this.CONF_LIST = 1
                    end
                    this.IS_PRESSED_CONF = true
            
                elseif(nextList and not this.IS_PRESSED_CONF)then
                    this.CONF_LIST = this.CONF_LIST + 1
                    if(this.CONF_LIST > 3)then
                        this.CONF_LIST = 0
                    end
                    this.IS_PRESSED_CONF = true
            
                end
            
                if((not prevList and not nextList) and this.IS_PRESSED_CONF)then
                    this.IS_PRESSED_CONF = false
                end
            end
        end,

        drawInit = function(this)
            setColor(DARK_THEME[1])
            screen.drawClear()

            setColor(DARK_THEME[2])
            screen.drawLine(0,8,w,8)

            setColor(DARK_THEME[3])
            screen.drawTriangleF(2,5, 5,2, 5,8)
            screen.drawTriangleF(61,5, 58,2, 58,8)

            title = "ROUTE"
            if(this.PAGE == 1)then
                title = "ROUTE CONF"
            end
            screen.drawTextBox(0, 2, w, 5, title, 0, 0)

        end,

        drawMain = function(this)
            -- init
            this:drawInit()

            -- route
            -- btn
            this.BTN_NEXT:draw()
            this.BTN_PREV:draw()

        end,

        drawConfig = function(this)
            -- init
            this:drawInit()
            h = screen.getHeight()
            w = screen.getWidth()

            setColor(DARK_THEME[2])
            screen.drawLine(0, 16, 64, 16)
            screen.drawTriangleF(2,13, 5,10, 5,16)
            screen.drawTriangleF(61,13, 58,10, 58,16)

            title = "Arctic"

            if(this.CONF_LIST == 1)then
                title = "Sawyer"

            elseif(this.CONF_LIST == 2)then
                title = "Meier"

            elseif(this.CONF_LIST == 3)then
                title = "NSO"

            end
            screen.drawTextBox(0, 10, w, 5, title, 0, 0)



        end,

        confRoute = function()
        end
    }
end

main = RouteConfig()
main:init()



function onTick()
    isTouched = input.getBool(1)
    inputX = input.getNumber(3)
    inputY = input.getNumber(4)

    main:onTickUpdate(isTouched, inputX, inputY)

end

function onDraw()
    if(main.PAGE == 0)then
        main:drawMain()

    elseif(main.PAGE == 1)then
        main:drawConfig()

    end

end
