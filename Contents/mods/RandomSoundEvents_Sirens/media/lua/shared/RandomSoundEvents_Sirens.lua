if not getActivatedMods():contains("RandomSoundEvents") then return; end

--- Load RandomSoundEventsAPI
local RandomSoundEventsAPI = require 'RandomSoundEvents/Classes/RandomSoundEventsAPI';

local modName = "RandomSoundEvents_Sirens";

--- Sirens Sound
RandomSoundEventsAPI.Add(modName, "Sirens", {
    { "Siren1", 750 },
    { "Siren2", 750 },
    { "Siren3", 750 },
});
