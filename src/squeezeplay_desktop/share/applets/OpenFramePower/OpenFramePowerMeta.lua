
--[[
=head1 NAME

applets.OpenFramePower.OpenFramePowerMeta - OpenFramePower Meta

=head1 DESCRIPTION

See L<applets.OpenFramePower.OpenFramePowerApplet>.

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
	
	jiveMain:addItem(meta:menuItem('appletOpenFramePower', 'home', "QUIT", function(applet, ...) applet:menu(...) end, 1010, nil, "hm_quit"))

end


--[[

=head1 LICENSE

Created by Andy Davison
birdslikewires.co.uk

This work is licensed under a Creative Commons Attribution-ShareAlike 3.0 Unported License.

=cut
--]]

