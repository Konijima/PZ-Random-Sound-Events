---@class RandomSoundEvent
local RandomSoundEvent = ISBaseObject:derive("RandomSoundEvent");

---@return boolean
function RandomSoundEvent:isDisabled()
    local disabledMods = SandboxVars.RandomSoundEvents.disabledMods or "";
    local disabled = luautils.split(disabledMods, ",");
    for i = 1, #disabled do
        if disabled[i] == self.modName then
            return true;
        end
    end
end

---@return number
function RandomSoundEvent:getRandomSoundIndex()
    return ZombRand(1, #self.soundList + 1);
end

---@param soundIndex number
---@param x number
---@param y number
---@param z number
function RandomSoundEvent:play(soundIndex, x, y, z)
    if isServer() then return; end

    local sound = self.soundList[soundIndex];
    if sound then
        z = z or 0;

        local soundName = sound;
        local attractRange = 0;

        if type(sound) == "table" then
            soundName = sound[1];
            attractRange = sound[2] or 0;
        end

        local emitter = getWorld():getFreeEmitter();
        emitter:setPos(x, y, z);
        emitter:playSoundImpl(soundName, nil);

        if not SandboxVars.RandomSoundEvents.deafZombies and attractRange > 0 then
            addSound(nil, x, y, z, attractRange, attractRange);
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
    o.soundList = soundList or {};

    return o;
end

return RandomSoundEvent;
