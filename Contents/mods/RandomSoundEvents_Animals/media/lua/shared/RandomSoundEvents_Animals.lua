if not getActivatedMods():contains("RandomSoundEvents") then return; end

--- Load RandomSoundEventsAPI
local RandomSoundEventsAPI = require 'RandomSoundEvents/Classes/RandomSoundEventsAPI';

local modName = "RandomSoundEvents_Animals";

--- Wolf Sound
RandomSoundEventsAPI.Add(modName, "Wolf", {
    { "Wolf1", 50 },
    { "Wolf2", 50 },
    { "Wolf3", 50 },
});

--- Bear Sound
RandomSoundEventsAPI.Add(modName, "Bear", {
    { "Bear1", 50 },
    { "Bear2", 50 },
    { "Bear3", 50 },
});
