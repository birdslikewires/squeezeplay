
--[[
=head1 NAME

applets.JogglerUpdate.JogglerUpdateMeta - JogglerUpdate Meta

=head1 DESCRIPTION

See L<applets.JogglerUpdate.JogglerUpdateApplet>.

=cut
--]]

--local os            = require("os")

local oo            = require("loop.simple")

local AppletMeta    = require("jive.AppletMeta")

local appletManager = appletManager
local jiveMain      = jiveMain


module(...)
oo.class(_M, AppletMeta)


function jiveVersion(meta)
	return 1, 1
end

--function defaultSettings(meta)
--	return {
--		somesetting = "disabled",
--	}
--end


function registerApplet(meta)
	
	--jiveMain:addItem(meta:menuItem('appletJogglerQuit', 'home', "TITLE", function(applet, ...) applet:menu(...) end, 10))
	jiveMain:addItem(meta:menuItem('appletJogglerQuit', 'settings', "TITLE", function(applet, ...) applet:menu(...) end, 20))

end


--[[

=head1 LICENSE

Created by Andy Davison
birdslikewires.co.uk

This work is licensed under a Creative Commons Attribution-ShareAlike 3.0 Unported License.

=cut
--]]

