--- Load Client
local Client = require 'RandomSoundEvents/Client';

--- Load RandomSoundEventList
local RandomSoundEventList = require 'RandomSoundEvents/Classes/RandomSoundEventList';

---@class ClientModuleTest
local ClientModuleRandomSoundEvents = {};

---Play a random sound event at
function ClientModuleRandomSoundEvents.PlayAt(modName, eventName, soundIndex, x, y, z)
    local randomSoundEvent = RandomSoundEventList[modName][eventName];
    if randomSoundEvent then
        randomSoundEvent:play(soundIndex, x, y, z);
    end
end

--- Add the module to the client Modules object
Client.Modules.RandomSoundEvents = ClientModuleRandomSoundEvents;
