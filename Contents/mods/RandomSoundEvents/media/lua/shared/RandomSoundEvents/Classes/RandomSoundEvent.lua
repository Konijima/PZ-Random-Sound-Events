---@class RandomSoundEvent
local RandomSoundEvent = ISBaseObject:derive("RandomSoundEvent");

---@return boolean
function RandomSoundEvent:isDisabled()
    --local disabledMods = SandboxVars.RandomSoundEvents.disabledMods or "";
    --local disabled = luautils.split(disabledMods, ",");
    --for i = 1, #disabled do
    --    if disabled[i] == self.modName then
    --        return true;
    --    end
    --end
    return false;
end

---@return number
function RandomSoundEvent:getRandomSoundIndex()
    return ZombRand(1, #self.soundList + 1);
end

---@param soundIndex number
---@param x number
---@param y number
---@return boolean
function RandomSoundEvent:canPlay(soundIndex, player, x, y)
    local sound = self.soundList[soundIndex];
    if sound then
        local success, canPlay = pcall(sound.canPlay, x, y);
        if success then
            return canPlay;
        end
    end
end

---@param soundIndex number
---@param x number
---@param y number
function RandomSoundEvent:play(soundIndex, x, y)
    local sound = self.soundList[soundIndex];
    if sound then
        local emitter = getWorld():getFreeEmitter();
        if emitter then
            emitter:setPos(x, y, 0);
            local audio = emitter:playSoundImpl(sound.name, false, nil);

            if not SandboxVars.RandomSoundEvents.deafZombies and sound.range > 0 then
                addSound(nil, x, y, 0, sound.range, sound.range);
            end

            if sound.onPlay then
                pcall(sound.onPlay, sound.name, sound.range, x, y);
            end

            local audioTicks = 0;
            local function audioProcess()
                if not emitter:isPlaying(audio)then
                    if sound.onCompleted then
                        pcall(sound.onCompleted, sound.name, sound.range, x, y);
                    end
                    Events.OnTick.Remove(audioProcess);
                else
                    if sound.onUpdate then
                        pcall(sound.onUpdate, audioTicks, sound.name, sound.range, x, y);
                    end
                    audioTicks = audioTicks + 1;
                end
            end
            Events.OnTick.Add(audioProcess);
        end

    end
end

---@param modName string The name of the mod
---@param eventName string The unique name of this event
---@param soundList table Array of sounds to choose from for this event
function RandomSoundEvent:new(modName, eventName, soundList)
    local o = {};
    setmetatable(o, self);
    self.__index = self;

    o.modName = modName;
    o.eventName = eventName;
    o.soundList = {};

    -- Process sound list
    for _, soundEvent in ipairs(soundList) do
        if type(soundEvent[1]) ~= "string" then error(modName .. ":" .. eventName .. ": Sound param 1 (soundName) must be a string"); end
        local soundName = soundEvent[1];

        if soundEvent[2] and type(soundEvent[2]) ~= "number" then error(modName .. ":" .. eventName .. ": Sound param 2 (soundRange) must be a number"); end
        local soundRange = soundEvent[2] or 0;

        if soundEvent[3] and type(soundEvent[3]) ~= "function" then error(modName .. ":" .. eventName .. ": Sound param 3 (soundCanPlay) must be a function"); end
        local soundCanPlay = soundEvent[3] or function() return true; end;

        if soundEvent[4] and type(soundEvent[4]) ~= "function" then error(modName .. ":" .. eventName .. ": Sound param 4 (soundOnPlay) must be a function"); end
        local soundOnPlay = soundEvent[4] or nil;

        if soundEvent[5] and type(soundEvent[5]) ~= "function" then error(modName .. ":" .. eventName .. ": Sound param 5 (soundOnUpdate) must be a function"); end
        local soundOnUpdate = soundEvent[5] or nil;

        if soundEvent[6] and type(soundEvent[6]) ~= "function" then error(modName .. ":" .. eventName .. ": Sound param 6 (soundOnCompleted) must be a function"); end
        local soundOnCompleted = soundEvent[6] or nil;

        table.insert(o.soundList, {
            name = soundName,
            range = soundRange,
            canPlay = soundCanPlay,
            onPlay = soundOnPlay,
            onUpdate = soundOnUpdate,
            onCompleted = soundOnCompleted,
        });
    end

    return o;
end

return RandomSoundEvent;
