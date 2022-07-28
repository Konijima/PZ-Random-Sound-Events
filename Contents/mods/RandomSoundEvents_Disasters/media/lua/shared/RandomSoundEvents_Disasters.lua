if not getActivatedMods():contains("RandomSoundEvents") then return; end

--- Load RandomSoundEventsAPI
local Utils = require 'RandomSoundEvents/Utils';
local RandomSoundEventsAPI = require 'RandomSoundEvents/Classes/RandomSoundEventsAPI';

local modName = "RandomSoundEvents_Disasters";

-- CAN PLAY
-- Server Function to validate if the sound event can play
local function canPlay(player, x, y)
    local worldAge = getGameTime():getWorldAgeHours() / 24;
    return not SandboxVars.RandomSoundEvents_Disasters.disabled and worldAge >= SandboxVars.RandomSoundEvents_Disasters.daysSinceApocalypse and worldAge < SandboxVars.RandomSoundEvents_Disasters.daysSinceApocalypseEnd;
end

-- ON PLAY
-- Client Function triggered when the sound event start.
local function onPlay(soundName, soundRange, x, y)
    if SandboxVars.RandomSoundEvents_Disasters.disableFear then return; end

    for playerNum = 0, 3 do
        local player = getSpecificPlayer(playerNum);
        if player and not player:isDead() and not player:isGodMod() then
            if Utils.IsInRange(soundRange, x, y, player:getX(), player:getY()) then
                local stats = player:getStats();
                local panic = stats:getPanic();
                local stress = stats:getStress();

                if player:HasTrait("Brave") then
                    stats:setPanic(panic + 10);
                    stats:setStress(stress + 0.10);

                    if not SandboxVars.RandomSoundEvents_Disasters.disableSpeech then
                        player:Say( getText("IGUI_RSE_Disasters_Say_" .. ZombRand(1, 12) ) );
                        addSound(player, player:getX(), player:getY(), player:getZ(), 10, 10);
                    end
                else
                    if player:isAsleep() then player:setAsleep(false); end
                    stats:setPanic(panic + 20);
                    stats:setStress(stress + 0.20);

                    if not SandboxVars.RandomSoundEvents_Disasters.disableSpeech then
                        player:SayShout( getText("IGUI_RSE_Disasters_Shout_" .. ZombRand(1, 14) ) );
                        addSound(player, player:getX(), player:getY(), player:getZ(), 20, 20);
                    end
                end
            end
        end
    end
end

-- ON UPDATE
-- Client Function triggered every tick during the sound event.
local function onUpdate(ticks, soundName, soundRange, x, y)

end

-- ON COMPLETED
-- Client Function triggered when the sound event is completed.
local function onCompleted(soundName, soundRange, x, y)
    for i = 0, 3 do
        local player = getSpecificPlayer(i);
        if player and not player:isDead() and not player:isGodMod() then
            if Utils.IsInRange(soundRange, x, y, player:getX(), player:getY()) then
                -- Increment player DisastersSurvived stat
                local modData = player:getModData();
                modData.RandomSoundEvents = modData.RandomSoundEvents or {};
                modData.RandomSoundEvents.DisastersSurvived = modData.RandomSoundEvents.DisastersSurvived or 0;
                modData.RandomSoundEvents.DisastersSurvived = modData.RandomSoundEvents.DisastersSurvived + 1;
            end
        end
    end
end

--- EarthQuakes Sounds
RandomSoundEventsAPI.Add(modName, "EarthQuakes", {
    { "EarthQuake1", 1000, canPlay, onPlay, onUpdate, onCompleted },
    { "EarthQuake2", 1000, canPlay, onPlay, onUpdate, onCompleted },
});
