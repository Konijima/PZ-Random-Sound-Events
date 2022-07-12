if not getActivatedMods():contains("RandomSoundEvents") then return; end

--- Load RandomSoundEventsAPI
local RandomSoundEventsAPI = require 'RandomSoundEvents/Classes/RandomSoundEventsAPI';

local modName = "RandomSoundEvents_Disasters";

--- EarthQuakes Sounds
RandomSoundEventsAPI.Add(modName, "EarthQuakes", {
    { "EarthQuake1", 1000 },
    { "EarthQuake2", 1000 },
});
