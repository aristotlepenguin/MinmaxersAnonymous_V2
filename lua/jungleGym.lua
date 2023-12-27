local mod = MMAMod

local game = Game()
local grng = RNG()
local sfx = SFXManager()
local floorSaves = {}

local pickup_num = 1
local renderX = 30
local renderY = 30

local function locateRoom(roomtype)
    local currentLevel = game:GetLevel()
    --local rooms = currentLevel:GetRooms()
    --print(#rooms)
    for i=0, 168, 1 do
        local roomid = game:GetLevel():GetRoomByIdx(i)
        if roomid and roomid.Data and roomid.Data.Type > 1  then
            print(tostring(roomid.Data.Type) .. " - " .. tostring(i))
        end
        
        if roomid and roomid.Data and roomid.Data.Type == roomtype then
            return i
        end
    end
    return nil
end

function mod:DebugText()
    local player = Isaac.GetPlayer(0) --this one is OK
    local coords = player.Position
    local debug_str = tostring(coords)
    local hopeSpr = Sprite()
    hopeSpr:Load("gfx/005.100_collectible.anm2", true)
    hopeSpr:Play("PlayerPickup")
    hopeSpr:ReplaceSpritesheet(1, Isaac.GetItemConfig():GetCollectible(pickup_num).GfxFileName)
    --local pos = Vector(Isaac.GetScreenWidth()-30, Isaac.GetScreenHeight()-45)
    --local pos = Vector(85, Isaac.GetScreenHeight()-32)
    --hopeSpr:Render(pos)
    --Isaac.RenderText(debug_str, 100, 60, 1, 1, 1, 255)

end
mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.DebugText)


local function TabDeepCopy(tbl, secTbl)
        --local t = {}
        if type(tbl) ~= "table" or type(secTbl) ~= "table" then error("[1] is not a table",2) end
        for k, v in pairs(tbl) do
            if type(v) == "table" then
                secTbl[k] = TabDeepCopy(v)
            else
                secTbl[k] = v
            end
        end
    end


function mod:test_command(cmd, args)
    
    if cmd == "floorswap" then
        local cmdString = "stage " .. args
        Isaac.ExecuteCommand(cmdString)
        local bossID = locateRoom(RoomType.ROOM_BOSS)
        --print(bossID)
        if bossID then
            local clearRoom = game:GetLevel():GetRoomByIdx(bossID)
            clearRoom.Clear = true
            --local player = Isaac.GetPlayer(0)
            --player:UseCard(Card.CARD_EMPEROR, 2307)
            --print("used?")
            --game:GetRoom():SetClear(true)
            game:ChangeRoom(bossID, -1)
        end
    end
    if cmd == "roomtype" then
        local roomdesc = game:GetLevel():GetRoomByIdx(tonumber(args))
        if roomdesc and roomdesc.Data and roomdesc.Data.Type then
            print(roomdesc.Data.Type)
        else
            print("failed")
        end
    end
    if cmd == "copyroom" and args then
        local roomdesc = game:GetLevel():GetRoomByIdx(tonumber(args))
        floorSaves[args] = {}
        TabDeepCopy(roomdesc, floorSaves[args])
    end
    if cmd == "pasteroom" then
        local roomdesc = game:GetLevel():GetRoomByIdx(tonumber(args))
        if roomdesc and floorSaves[args] ~= nil then
            TabDeepCopy(roomdesc, floorSaves[args])
        end
        --floorSaves[args] = 
    end
    if cmd == "currenthearts" then
        local player = Isaac.GetPlayer(0)
        local rottenhearts = player:GetRottenHearts()
        local redhearts = player:GetHearts()
        print(redhearts)
        print(rottenhearts)
    end
    if cmd == "addhearts" then
        local player = Isaac.GetPlayer(0)
        player:AddHearts(1)
    end

    if cmd == "addcoins" then
        local player = Isaac.GetPlayer(0)
        player:AddCoins(1)
    end

    if cmd == "renderx" then
        renderX = mod:isNil(math.tointeger(args), 30)
    end

    if cmd == "rendery" then
        renderY = mod:isNil(math.tointeger(args), 30)
    end

    if cmd == "screenwidth" then
        print(Isaac.GetScreenWidth())
        print(Isaac.GetScreenHeight())
    end

    if cmd == "numplayers" then
        print(Game():GetNumPlayers())
    end
    if cmd == "printroom" then
        local player = Isaac.GetPlayer(0)
        print(Game():GetLevel():GetCurrentRoomIndex())
    end
end
mod:AddCallback(ModCallbacks.MC_EXECUTE_CMD, mod.test_command)