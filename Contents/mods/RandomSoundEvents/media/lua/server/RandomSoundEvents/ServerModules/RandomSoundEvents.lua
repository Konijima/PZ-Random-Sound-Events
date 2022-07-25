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
        soundIndex = soundIndex,
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
    cooldown = ZombRand(SandboxVars.RandomSoundEvents.minCooldown, SandboxVars.RandomSoundEvents.maxCooldown);
end

local function onTick()

    -- Don't run for client
    if not isServer() and not Server.Utils.IsSinglePlayer() then
        Server.Log("Client side detected, disabling OnTick!");
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
        Server.Log("No player online, skipping...");
        -- No player online, then just wait a bit
        cooldown = ZombRand(SandboxVars.RandomSoundEvents.minCooldown, SandboxVars.RandomSoundEvents.maxCooldown);
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

    local soundEvent = randomSoundEvent.soundList[soundIndex];
    if not soundEvent then
        Server.Log("Invalid sound, skipping...");
        cooldown = ZombRand(60, 120);
        return;
    end

    -- Get position and add random range
    local x, y = randomPlayer:getX(), randomPlayer:getY();
    x = x + ZombRand(-soundEvent.range, soundEvent.range);
    y = y + ZombRand(-soundEvent.range, soundEvent.range);

    -- Check if sound is in a building
    local square = getSquare(x, y, 0);
    if square and square:getBuilding() then
        Server.Log("Sound is in a building, skipping...");
        return; -- square is a building let try again
    end

    -- Check if the sound can be played
    if not randomSoundEvent:canPlay(soundIndex, randomPlayer, x, y) then
        Server.Log("Sound cant play, skipping...");
        cooldown = ZombRand(60, 120);
        return;
    end

    -- Send random sound event to clients
    ServerModuleRandomSoundEvents.SendRandomSoundEventAt(randomSoundEvent, soundIndex, x, y, 0);

    -- Set random cooldown
    cooldown = ZombRand(SandboxVars.RandomSoundEvents.minCooldown, SandboxVars.RandomSoundEvents.maxCooldown);

end
Events.OnTick.Add(onTick);

--- /reloadlua server/RandomSoundEvents/ServerModules/RandomSoundEvents.lua
