if not getActivatedMods():contains("RandomSoundEvents") then return; end

--- Load Utils and RandomSoundEventsAPI
local Utils = require 'RandomSoundEvents/Utils';
local RandomSoundEventsAPI = require 'RandomSoundEvents/Classes/RandomSoundEventsAPI';

local modName = "RandomSoundEvents_Nukes";

local function getBurnProtectionItemList()
    return luautils.split(SandboxVars.RandomSoundEvents_Nukes.burnProtectionItems, ";");
end

local function getSicknessProtectionItemList()
    return luautils.split(SandboxVars.RandomSoundEvents_Nukes.sicknessProtectionItems, ";");
end

local function isPlayerProtectedFromBurn(playerObj, bodyPart)
    local itemTypes = getBurnProtectionItemList();
    for i = 1, #itemTypes do
        if Utils.IsItemEquippedAndNotBroken(playerObj, itemTypes[i]) then
            return true;
        end
    end
end

local function isPlayerProtectedFromSickness(playerObj)
    local itemTypes = getSicknessProtectionItemList();
    for i = 1, #itemTypes do
        if Utils.IsItemEquippedAndNotBroken(playerObj, itemTypes[i]) then
            return true;
        end
    end
end

-- CAN PLAY
-- Server Function to validate if the sound event can play
local function canPlay(player, x, y)
    local worldAge = Utils.GetWorldTotalDays();
    return not SandboxVars.RandomSoundEvents_Nukes.disabled and 
            worldAge >= SandboxVars.RandomSoundEvents_Nukes.daysSinceApocalypse and 
            worldAge < SandboxVars.RandomSoundEvents_Nukes.daysSinceApocalypseEnd;
end

-- ON PLAY
-- Client Function triggered when the sound event start.
local function onPlay(soundName, soundRange, x, y)
    Utils.PlayerWorldSoundAt(x, y, 0, soundRange, nil);
    
    if SandboxVars.RandomSoundEvents_Nukes.disableFear then return; end
    Utils.ForEachLocalPlayer(function(player)
    
        if not player:isDead() and not player:isGodMod() then

            if Utils.IsInRange(soundRange, x, y, player:getX(), player:getY()) then
                local stats = player:getStats();
                local panic = stats:getPanic();
                local stress = stats:getStress();

                if player:HasTrait("Brave") then
                    stats:setPanic(panic + 10);
                    stats:setStress(stress + 0.10);

                    if not SandboxVars.RandomSoundEvents_Nukes.disableSpeech then
                        player:Say( getText("IGUI_RSE_Nukes_Say_" .. ZombRand(1, 12) ) );
                        Utils.PlayerWorldSoundAt(player:getX(), player:getY(), player:getZ(), 10, player);
                    end
                else
                    if not SandboxVars.RandomSoundEvents_Nukes.disableWakingUp and player:isAsleep() then
                        player:setAsleep(false);
                        player:setAsleepTime(0.0);
                        UIManager.FadeIn(player:getPlayerNum(), 1);
                    end
                    stats:setPanic(panic + 20);
                    stats:setStress(stress + 0.20);

                    if not SandboxVars.RandomSoundEvents_Nukes.disableSpeech then
                        player:SayShout( getText("IGUI_RSE_Nukes_Shout_" .. ZombRand(1, 14) ) );
                        Utils.PlayerWorldSoundAt(player:getX(), player:getY(), player:getZ(), 20, player);
                    end
                end
            end

        end

    end);
end

-- ON UPDATE
-- Client Function triggered every tick during the sound event.
local function onUpdate(ticks, soundName, soundRange, x, y)

    Utils.ForEachLocalPlayer(function(player)

        if not player:isDead() and not player:isGodMod() then

            if Utils.IsInRange(soundRange, x, y, player:getX(), player:getY()) then
                local gameTimeMultiplier = getGameTime():getMultiplier();
    
                -- Make player sick if not inside a building or vehicle
                if not player:getCurrentBuilding() and not player:getVehicle() then
                    local body = player:getBodyDamage();
    
                    -- Give sickness
                    if not SandboxVars.RandomSoundEvents_Nukes.disableSickness then
                        local sickness = body:getFoodSicknessLevel();
                        if ticks > 120 and sickness < 50 then
                            local multiplier = 1;
                            if player:HasTrait("Resilient") then
                                multiplier = 0.5;
                            end
                            if not isPlayerProtectedFromSickness(player) then
                                body:setFoodSicknessLevel(sickness + 0.02 * multiplier * gameTimeMultiplier);
                            end
                        end
                    end
    
                    -- Burn body parts
                    if not SandboxVars.RandomSoundEvents_Nukes.disableBurning then
                        local parts = body:getBodyParts();
                        for i = 0, parts:size() - 1 do
                            local bodyPart = parts:get(i);
                            local burn = bodyPart:getBurnTime();
                            local rand1, rand2 = ZombRand(30000), ZombRand(30000);
                            if ticks > 120 and burn == 0 and rand1 == rand2 then
                                if not isPlayerProtectedFromBurn(player, bodyPart) then
                                    bodyPart:setBurnTime(1);
        
                                    if not SandboxVars.RandomSoundEvents_Nukes.disableSpeech then
                                        player:SayShout( getText("IGUI_RSE_Nukes_Burn_1", BodyPartType.getDisplayName(bodyPart:getType())) );
                                        Utils.PlayerWorldSoundAt(player:getX(), player:getY(), player:getZ(), 20, player);
                                    end
                                end
                            end
                        end
                    end
                end
    
                -- Stress the un-brave player
                if not SandboxVars.RandomSoundEvents_Nukes.disableFear then
                    if not player:HasTrait("Brave") then
                        local stats = player:getStats();
                        local panic = stats:getPanic();
                        local stress = stats:getStress();
    
                        stats:setPanic(panic + 0.05 * gameTimeMultiplier);
                        stats:setStress(stress + 0.0005 * gameTimeMultiplier);
                    end
                end
            end

        end

    end);
end

-- ON COMPLETED
-- Client Function triggered when the sound event is completed.
local function onCompleted(soundName, soundRange, x, y)

    Utils.ForEachLocalPlayer(function(player)
    
        if not player:isDead() and not player:isGodMod() then
            if Utils.IsInRange(soundRange, x, y, player:getX(), player:getY()) then
                -- Increment player NukesSurvived stat
                local modData = player:getModData();
                modData.RandomSoundEvents = modData.RandomSoundEvents or {};
                modData.RandomSoundEvents.NukesSurvived = modData.RandomSoundEvents.NukesSurvived or 0;
                modData.RandomSoundEvents.NukesSurvived = modData.RandomSoundEvents.NukesSurvived + 1;
            end
        end

    end);
end

--- Nukes Sound
--- { SoundName, Range, canPlayFunction, onPlayFunction, onUpdateFunction, onCompletedFunction },
RandomSoundEventsAPI.Add(modName, "Nukes", {
    { "Nuke1", 1000, canPlay, onPlay, onUpdate, onCompleted },
    { "Nuke2", 1000, canPlay, onPlay, onUpdate, onCompleted },
    { "Nuke3", 1000, canPlay, onPlay, onUpdate, onCompleted },
});
