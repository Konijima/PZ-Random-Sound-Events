---@class Utils
local Utils = {};

---Check if running in singleplayer
---@return boolean
function Utils.IsSinglePlayer()
    return not isClient() and not isServer();
end

---Check if client is admin or debug
---@return boolean
function Utils.IsClientAdminOrDebug()
    return not isServer() and (isAdmin() or isDebugEnabled());
end

---Check if a mod is active
---@param modName string
---@return boolean
function Utils.IsModActive(modName)
    return getActivatedMods():contains(modName);
end

---Get a player object from a username
---@param username string
---@return IsoPlayer
function Utils.GetPlayerFromUsername(username)
    if isServer() then
        local players = getOnlinePlayers();
        for i = 0, players:size() - 1 do
            local player = players:get(i);
            if player:getUsername() == username then
                return player;
            end
        end
    end
    return getPlayerFromUsername(username);
end

---Check if xy2 is in range of xy1
---@param range number
---@param x1 number
---@param y1 number
---@param x2 number
---@param y2 number
function Utils.IsInRange(range, x1, y1, x2, y2)
    local dx = x1 - x2;
    local dy = y1 - y2;
    return dx * dx + dy * dy < range * range;
end

--- Get the amount of days the world exist
function Utils.GetWorldTotalDays()
    return getGameTime():getWorldAgeHours() / 24;
end

--- Run a function on each local player
---@param doFunction function Thefunction to call on each player
function Utils.ForEachLocalPlayer(doFunction)
    for playerNum = 0, 3 do
        local player = getSpecificPlayer(playerNum);
        if player then
            pcall(doFunction, player);
        end
    end
end

--- Play a world sound at position only if zombies are not deaf
---@param x number
---@param y number
---@param z number
---@param range number
---@param target IsoPlayer Can be set to nil
function Utils.PlayerWorldSoundAt(x, y, z, range, target)
    if not SandboxVars.RandomSoundEvents.deafZombies and range > 0 then
        addSound(target, x, y, z, range, range);
    end
end

return Utils;
