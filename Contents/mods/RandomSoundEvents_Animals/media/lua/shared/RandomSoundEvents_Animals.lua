if not getActivatedMods():contains("RandomSoundEvents") then return; end

--- Load RandomSoundEventsAPI
local RandomSoundEventsAPI = require 'RandomSoundEvents/Classes/RandomSoundEventsAPI';

local modName = "RandomSoundEvents_Animals";

--- Wolf Sound
RandomSoundEventsAPI.Add(modName, "Wolf", {
    { "Wolf1", 100 },
    { "Wolf2", 100 },
    { "Wolf3", 100 },
});

--- Bear Sound
RandomSoundEventsAPI.Add(modName, "Bear", {
    { "Bear1", 100 },
    { "Bear2", 100 },
    { "Bear3", 100 },
});

--- Cat Sound
RandomSoundEventsAPI.Add(modName, "Cat", {
    { "Cat1", 100 },
});

--- Boar Sound
RandomSoundEventsAPI.Add(modName, "Boar", {
    { "Boar1", 100 },
    { "Boar2", 100 },
});

--- Hawk Sound
RandomSoundEventsAPI.Add(modName, "Hawk", {
    { "Hawk1", 100 },
    { "Hawk2", 100 },
});
