--[[
=head1 NAME

applets.OpenFrameTimeZone.openframe_bsp

=head1 DESCRIPTION

This module supports the applet implementing timezone adjustment for OpenFrames.
It implements the functionality of the squeezeos_bsp module where necessary.

=head1 FUNCTIONS

Applet based on original SetupTZ 

=cut
--]]

local io            = require("io")
local openframeos   = {}

function openframeos.getTimezone()
	local success,result = capture('openframe_timezone.sh current')
	if success then 
		return result
	else
		return 'GMT'
	end
end

function openframeos.setTimezone(timezone)
	local success,result = capture('openframe_timezone.sh apply ' .. timezone)
	if success then 
		return true
	else
		return false, result
	end
end

-- Allows output of shell scripts to be captured.
function capture(cmd)
	local shell = io.popen(cmd, 'r')
	if shell == nil then
		return false, "ERROR"
	end
	local result = shell:read('*a')
	shell:close()
	return true, result
end

return openframeos

--[[

=head1 LICENSE

Created by Heiko Steinwender

This work is licensed under a Creative Commons Attribution-ShareAlike 3.0 Unported License.

=cut
--]]

