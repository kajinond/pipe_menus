--[[
--
-- Author: OndraK
--
-- This piece of lua code can be distributed under the terms of GNU GPL v3
--
--]]

local system = require "system"

local notification = {}

local notifier = 'notify-send'
local notifierOptions = '--expire-time=5000'

-- -- -- -- -- -- -- -- -- -- -- --
-- -- -- public functions  -- -- --
-- -- -- -- -- -- -- -- -- -- -- --
function notification.send(header, message, icon)
	os.execute(system.cmd(notifier, notifierOptions, header, message))
end

return notification

