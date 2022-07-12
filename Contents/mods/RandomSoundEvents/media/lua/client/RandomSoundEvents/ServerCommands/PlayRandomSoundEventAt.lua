--- Load Client
local Client = require 'RandomSoundEvents/Client';

---Handle receiving PlayRandomSoundEventAt command from the server
---@param args table
function Client.Commands.PlayRandomSoundEventAt(args)
    Client.Log("Received event PlayRandomSoundEventAt " .. args.eventName  .. " " .. args.soundIndex);
    Client.Modules.RandomSoundEvents.PlayAt(args.modName, args.eventName, args.soundIndex, args.x, args.y, args.z);
end
