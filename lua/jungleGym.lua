local mod = MMAMod

local game = Game()
local grng = RNG()
local sfx = SFXManager()
local floorSaves = {}

local rng = RNG()

local pickup_num = 1
local renderX = 30
local renderY = 30

local hiddenItemManager = require("lib.hidden_item_manager")


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
        renderX = math.tointeger(args) or 30
    end

    if cmd == "rendery" then
        renderY = math.tointeger(args) or 30
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
    if cmd == "currentrange" then
        local player = Isaac.GetPlayer(0)
        print(player.TearRange)
    end
    if cmd == "firelonglaser" then
        local player = Isaac.GetPlayer(0)
        EntityLaser.ShootAngle(1, player.Position, 45, 700, Vector(0, 0), player)
    end

    if cmd == "fireknife" then
        local player = Isaac.GetPlayer(0)
        local knife = player:FireKnife(player, 0, false, 2, 0)
        
        knife.CollisionDamage = knife.CollisionDamage * 0.3
		knife.Rotation = 45
        knife.Velocity = Vector(20, 0)
        --knife:Shoot(9300, 10000)
        knife:Update()
    end
    if cmd == "giveone" then
        local player = Isaac.GetPlayer(0)
        hiddenItemManager:Add(player, CollectibleType.COLLECTIBLE_ONE_UP)
    end
    if cmd == "checkone" then
        local player = Isaac.GetPlayer(0)
        local count = hiddenItemManager:CountStack(player, CollectibleType.COLLECTIBLE_ONE_UP, hiddenItemManager.kDefaultGroup)
        print(count)
    end

    if cmd == "freemans" then
        local player = Isaac.GetPlayer(0)
        local count = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_ONE_UP)
        print(count)
    end

    if cmd == "minmaxdebug" then
        if mod.DEBUG then
            mod.DEBUG = false
            print("MMA Debug is off.")
        else
            mod.DEBUG = true
            print("MMA Debug is on.")
        end
        
    end

    if cmd == "printallstats" then
        local player = Isaac.GetPlayer(0)
        print("range " .. tostring(player.TearRange))
        print("luck " .. tostring(player.Luck))
        print("tears " .. tostring(player.MaxFireDelay))
        print("damage " .. tostring(player.Damage))
        print("speed " .. tostring(player.MoveSpeed))
    end


    if cmd == "printmenuitem" then
        print(mod.MenuData.MaxieBossRush)
    end

    if cmd == "addnorthdoor" then
        local currentRoom = game:GetLevel():GetCurrentRoomIndex()
        local good = mod:openSpecialRedRoom_DS(currentRoom, DoorSlot.UP0, rng)
        print(good)
    end

    if cmd == "pickupcount" then
        local pickupList = Isaac.FindByType(5)
        print(#pickupList)
    end
   
    if cmd == "printtotalitems" then
        print(Isaac.GetItemConfig():GetCollectibles().Size-1)
    end

    if cmd == "checkItemState" then
        local pedestals = Isaac.FindByType(33)
        for i, pedestal in ipairs(pedestals) do
            print(pedestal.HitPoints)
            pedestal.HitPoints = 5
        end
    end

    if cmd == "hudoffset" then
        print(Options.HUDOffset)
    end

    if cmd == "testachievement" then
        mod:applyAchievement("testAch", 3200, "Mary Rose", "Burst her piles")
    end



end
mod:AddCallback(ModCallbacks.MC_EXECUTE_CMD, mod.test_command)

function mod:EnemyHit(entity, amount, damageflags, source, countdownframes)
    local player = entity:ToPlayer()
    if player == nil then
        return
    end
    mod:applyAchievement("getFucked", 6900, "GET FUCKED SCRUB", "Take more damage than yer mum")
end
--mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.EnemyHit, EntityType.ENTITY_PLAYER)

function mod:crashGame(card, player, useflags)
    local knife = player:FireKnife(player, 0, false, 1, 0)
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.crashGame, Card.CARD_EMPRESS)