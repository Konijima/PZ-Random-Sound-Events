--- Load RandomSoundEvent
local RandomSoundEvent = require 'RandomSoundEvents/Classes/RandomSoundEvent';

--- Load RandomSoundEventList
local RandomSoundEventList = require 'RandomSoundEvents/Classes/RandomSoundEventList';

---@class RandomSoundEventsAPI
local RandomSoundEventsAPI = {};

---@param modName string
---@param eventName string
---@param soundList table
function RandomSoundEventsAPI.Add(modName, eventName, soundList)
    if #soundList > 0 then
        RandomSoundEventList[modName] = RandomSoundEventList[modName] or {};
        RandomSoundEventList[modName][eventName] = RandomSoundEvent:new(modName, eventName, soundList);

        print("RandomSoundEvents: Added [" .. eventName .. "] from mod [" .. modName .. "] containing [" .. tostring(#soundList) .. " sounds]");
    else
        print("RandomSoundEvents: Skipping [" .. eventName .. "] from mod [" .. modName .. "] cause sound list is empty!");
    end
end

return RandomSoundEventsAPI;
