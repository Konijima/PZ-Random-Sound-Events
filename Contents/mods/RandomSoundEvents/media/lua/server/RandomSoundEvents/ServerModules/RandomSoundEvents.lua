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

local cooldown = 0;
local _lastMinute;

local function setRandomCooldown(min, max)
    cooldown = getGameTime():getMinutesStamp() + ZombRand(min or SandboxVars.RandomSoundEvents.minCooldownMinutes, max or SandboxVars.RandomSoundEvents.maxCooldownMinutes);
end

--- Set intial random cooldown
setRandomCooldown();

local function onTick()

    --- Print time left for next event
    if _lastMinute ~= getGameTime():getMinutesStamp() then
        _lastMinute = getGameTime():getMinutesStamp();
        if isDebugEnabled() then
            Server.Log(tostring( cooldown - _lastMinute ));
        end
    end

    -- Wait the cooldown in minutes
    if cooldown > getGameTime():getMinutesStamp() then
        return;
    end

    -- Pick random online player
    local randomPlayer = ServerModuleRandomSoundEvents.GetRandomOnlinePlayer();
    if not randomPlayer then
        if isDebugEnabled() then
            Server.Log("No player online, skipping...");
        end
        setRandomCooldown();
        return;
    end

    -- Pick random sound event
    local randomSoundEvent = ServerModuleRandomSoundEvents.GetRandomSoundEvent();
    if not randomSoundEvent or randomSoundEvent:isDisabled() then
        if isDebugEnabled() then
            Server.Log("GetRandomSoundEvent returned nil...");
        end
        setRandomCooldown(1, 1);
        return;
    end

    local soundIndex = randomSoundEvent:getRandomSoundIndex();
    if not soundIndex or soundIndex <= 0 then
        if isDebugEnabled() then
            Server.Log("getRandomSoundIndex return " .. tostring(soundIndex) .. " for mod [" .. randomSoundEvent.modName .. "] event ["  .. randomSoundEvent.eventName .. "]")
        end
        setRandomCooldown(1, 1);
        return;
    end

    local soundEvent = randomSoundEvent.soundList[soundIndex];
    if not soundEvent then
        if isDebugEnabled() then
            Server.Log("Invalid sound, skipping...");
        end
        setRandomCooldown(1, 1);
        return;
    end

    -- Get position and add random range
    local x, y = randomPlayer:getX(), randomPlayer:getY();
    x = x + ZombRand(-soundEvent.range, soundEvent.range);
    y = y + ZombRand(-soundEvent.range, soundEvent.range);

    -- Check if sound is in a building
    local square = getSquare(x, y, 0);
    if square and square:getBuilding() then
        if isDebugEnabled() then
            Server.Log("Sound is in a building, skipping...");
        end
        return; -- square is a building let try again
    end

    -- Check if the sound can be played
    if not randomSoundEvent:canPlay(soundIndex, randomPlayer, x, y) then
        if isDebugEnabled() then
            Server.Log("Sound cant play, skipping...");
        end
        setRandomCooldown(1, 1);
        return;
    end

    -- Send random sound event to clients
    ServerModuleRandomSoundEvents.SendRandomSoundEventAt(randomSoundEvent, soundIndex, x, y, 0);

    -- Set random cooldown
    setRandomCooldown();
end

--- Run on server or singleplayer
if not isClient() then
    Events.OnTick.Add(onTick);
end

--- /reloadlua server/RandomSoundEvents/ServerModules/RandomSoundEvents.lua
