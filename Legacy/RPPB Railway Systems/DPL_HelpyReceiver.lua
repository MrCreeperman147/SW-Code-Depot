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

transmitPin = property.getNumber("pin")

testObject = transmitStringTable()
testObject:init(8)

testObject:prepareExtract(transmitPin)

ticks = 0

helpyTable = {}

function onTick()
    helpyTable = testObject:extract(input.getNumber(transmitPin))
end

function onDraw()

    screen.setColor(200, 200, 200)
    screen.drawText(2, 2, testObject.STATE)
    
    for index, value in ipairs(helpyTable) do    
        screen.drawText(2, (index * 6) + 5, value)
    end


end
