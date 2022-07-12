--- Load Server
local Server = require 'RandomSoundEvents/Server';

--- Load RandomSoundEventList
local RandomSoundEventList = require 'RandomSoundEvents/Classes/RandomSoundEventList';

---@class ServerModuleRandomSoundEvents
local ServerModuleRandomSoundEvents = {};

---Get a random online player
function ServerModuleRandomSoundEvents.GetRandomOnlinePlayer()
    if Server.Utils.IsSinglePlayer() then
        return getPlayer();
    end
    local onlinePlayers = getOnlinePlayers();
    if onlinePlayers:size() > 0 then
        local index = ZombRand(onlinePlayers:size());
        return onlinePlayers:get(index);
    end
end

---Get a random sound event
function ServerModuleRandomSoundEvents.GetRandomSoundEvent()
    local modNames = {};
    for modName, _ in pairs(RandomSoundEventList) do
        table.insert(modNames, modName);
    end

    local randomModNameIndex = ZombRand(1, #modNames + 1);
    local randomModEvents = RandomSoundEventList[modNames[randomModNameIndex]];

    local eventNames = {};
    for eventName, _ in pairs(randomModEvents) do
        table.insert(eventNames, eventName);
    end

    local randomEventNameIndex = ZombRand(1, #eventNames + 1);

    return randomModEvents[eventNames[randomEventNameIndex]];
end

---Send a random sound event to a position
function ServerModuleRandomSoundEvents.SendRandomSoundEventAt(randomSoundEvent, soundIndex, x, y, z)
    local args = {
        modName = randomSoundEvent.modName,
        eventName = randomSoundEvent.eventName,
        soundIndex = randomSoundEvent:getRandomSoundIndex(),
        x = x,
        y = y,
        z = z,
    };

    Server.SendCommand("PlayRandomSoundEventAt", args);
    Server.Log("Sent PlayRandomSoundEventAt " .. args.eventName .. " " .. args.eventName  .. " sound index " .. args.soundIndex);
end

--- Add the module to the server Modules object
Server.Modules.RandomSoundEvents = ServerModuleRandomSoundEvents;

------------------------------------------------------------------------------------------------------------------------

local ticks = 0;
local cooldown = 0;

if Server.Utils.IsSinglePlayer() then
    cooldown = ZombRand(500, 5000);
end

local function onTick()

    if not isServer() and not Server.Utils.IsSinglePlayer() then
        Events.OnTick.Remove(onTick);
        return;
    end

    -- Wait the cooldown
    if cooldown > 0 then
        cooldown = cooldown - 1;
        return;
    end

    -- Limit updates to every 30 ticks
    if ticks < 30 then
        ticks = ticks + 1;
        return;
    end
    ticks = 0;

    -- Pick random online player
    local randomPlayer = ServerModuleRandomSoundEvents.GetRandomOnlinePlayer();
    if not randomPlayer then
        -- No player online, then just wait a bit
        cooldown = ZombRand(500, 1000);
        return;
    end

    -- Pick random sound event
    local randomSoundEvent = ServerModuleRandomSoundEvents.GetRandomSoundEvent();
    if not randomSoundEvent or randomSoundEvent:isDisabled() then
        Server.Log("GetRandomSoundEvent returned nil...");
        cooldown = ZombRand(60, 120);
        return;
    end

    local soundIndex = randomSoundEvent:getRandomSoundIndex();
    if not soundIndex or soundIndex <= 0 then
        Server.Log("getRandomSoundIndex return " .. tostring(soundIndex) .. " for mod [" .. randomSoundEvent.modName .. "] event ["  .. randomSoundEvent.eventName .. "]")
        cooldown = ZombRand(60, 120);
        return;
    end

    -- Get position and add random range
    local x, y = randomPlayer:getX(), randomPlayer:getY();
    local soundRange = type(randomSoundEvent.soundList[soundIndex]) == "table" and randomSoundEvent.soundList[soundIndex][2] / 2 or 50;
    x = x + ZombRand(-soundRange, soundRange);
    y = y + ZombRand(-soundRange, soundRange);

    -- Send random sound event to clients
    ServerModuleRandomSoundEvents.SendRandomSoundEventAt(randomSoundEvent, soundIndex, x, y, 0);

    -- Set random cooldown
    cooldown = ZombRand(SandboxVars.RandomSoundEvents.minCooldown or 500, SandboxVars.RandomSoundEvents.maxCooldown or 2000);

end
Events.OnTick.Add(onTick);

--- /reloadlua server/RandomSoundEvents/ServerModules/RandomSoundEvents.lua
