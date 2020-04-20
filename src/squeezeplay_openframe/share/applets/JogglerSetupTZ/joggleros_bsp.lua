--[[
=head1 NAME

applets.JogglerSetupTZ.joggleros_bsp

=head1 DESCRIPTION

This modul supports the applet which implements a timezone adjustment for JogglerOS
purpose is to replace the squeezeos_bsp module

=head1 FUNCTIONS

Applet based on original SetupTZ 

=cut
--]]

local io            = require("io")
local joggleros     = {}

function joggleros.getTimezone()
	local success,result = capture('sqp_JogglerSetupTZ.sh current')
	if success then 
		return result
	else
		return 'GMT'
	end
end

function joggleros.setTimezone(cmd)
	local success,result = capture('sqp_JogglerSetupTZ.sh apply ' .. cmd)
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

return joggleros

--[[

=head1 LICENSE

Created by Heiko Steinwender

This work is licensed under a Creative Commons Attribution-ShareAlike 3.0 Unported License.

=cut
--]]

