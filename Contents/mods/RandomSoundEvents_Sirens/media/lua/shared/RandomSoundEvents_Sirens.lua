if not getActivatedMods():contains("RandomSoundEvents") then return; end

--- Load Utils and RandomSoundEventsAPI
local Utils = require 'RandomSoundEvents/Utils';
local RandomSoundEventsAPI = require 'RandomSoundEvents/Classes/RandomSoundEventsAPI';

local modName = "RandomSoundEvents_Sirens";

-- CAN PLAY
-- Server Function to validate if the sound event can play
local function canPlay(player, x, y)
    local worldAge = Utils.GetWorldTotalDays();
    return not SandboxVars.RandomSoundEvents_Sirens.disabled and 
            worldAge >= SandboxVars.RandomSoundEvents_Sirens.daysSinceApocalypse and 
            worldAge < SandboxVars.RandomSoundEvents_Sirens.daysSinceApocalypseEnd;
end

-- ON PLAY
-- Client Function triggered when the sound event start.
local function onPlay(soundName, soundRange, x, y)
    Utils.PlayerWorldSoundAt(x, y, 0, soundRange, nil);

    if SandboxVars.RandomSoundEvents_Sirens.disableFear then return; end
    Utils.ForEachLocalPlayer(function(player)

        if not player:isDead() and not player:isGodMod() then
            if Utils.IsInRange(soundRange, x, y, player:getX(), player:getY()) then
                local stats = player:getStats();
                local panic = stats:getPanic();
                local stress = stats:getStress();

                if player:HasTrait("Brave") then
                    stats:setPanic(panic + 10);
                    stats:setStress(stress + 0.10);
                else
                    if player:isAsleep() then player:setAsleep(false); end
                    stats:setPanic(panic + 20);
                    stats:setStress(stress + 0.20);
                end
            end
        end

    end);
end

-- ON UPDATE
-- Client Function triggered every tick during the sound event.
local function onUpdate(ticks, soundName, soundRange, x, y)
    if SandboxVars.RandomSoundEvents_Sirens.disableFear then return; end

    Utils.ForEachLocalPlayer(function(player)

        if not player:isDead() and not player:isGodMod() then

            if Utils.IsInRange(soundRange, x, y, player:getX(), player:getY()) then
                local gameTimeMultiplier = getGameTime():getMultiplier();
    
                -- Stress the un-brave player
                if not player:HasTrait("Brave") then
                    local stats = player:getStats();
                    local panic = stats:getPanic();
                    local stress = stats:getStress();

                    stats:setPanic(panic + 0.05 * gameTimeMultiplier);
                    stats:setStress(stress + 0.0005 * gameTimeMultiplier);
                end
            end

        end

    end);
end

-- ON COMPLETED
-- Client Function triggered when the sound event is completed.
local function onCompleted(soundName, soundRange, x, y)

end

--- Sirens Sound
--- { SoundName, Range, canPlayFunction, onPlayFunction, onUpdateFunction, onCompletedFunction },
RandomSoundEventsAPI.Add(modName, "Sirens", {
    { "Siren1", 750, canPlay, onPlay, onUpdate, onCompleted },
    { "Siren2", 750, canPlay, onPlay, onUpdate, onCompleted },
    { "Siren3", 750, canPlay, onPlay, onUpdate, onCompleted },
});
