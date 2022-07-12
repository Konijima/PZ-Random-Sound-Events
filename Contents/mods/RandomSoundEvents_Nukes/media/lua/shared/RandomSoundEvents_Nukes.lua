if not getActivatedMods():contains("RandomSoundEvents") then return; end

--- Load RandomSoundEventsAPI
local RandomSoundEventsAPI = require 'RandomSoundEvents/Classes/RandomSoundEventsAPI';

local modName = "RandomSoundEvents_Nukes";

--- Nukes Sound
RandomSoundEventsAPI.Add(modName, "Nukes", {
    { "Nuke1", 1000 },
    { "Nuke2", 1000 },
    { "Nuke3", 1000 },
});
