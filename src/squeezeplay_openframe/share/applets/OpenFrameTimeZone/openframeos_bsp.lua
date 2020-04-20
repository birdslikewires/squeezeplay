--[[
=head1 NAME

applets.JogglerSetupTZ.openframeos_bsp

=head1 DESCRIPTION

This module supports OpenFrameTimeZone applet, implementing time zone adjustment for OpenFrames.
The purpose is to replace the squeezeos_bsp module.

=head1 FUNCTIONS

Applet based on original SetupTZ 

=cut
--]]

local io              = require("io")
local openframeos     = {}

function openframeos.getTimezone()
	local success,result = capture('openframe_timezone.sh check')
	if success then 
		return result
	else
		return 'GMT'
	end
end

function openframeos.setTimezone(cmd)
	local success,result = capture('openframe_timezone.sh set ' .. cmd)
	if success then 
		return true
	else
		return false, result
	end
end

function openframeos.updateTimezone()
	local success,result = capture('openframe_timezone.sh update')
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

