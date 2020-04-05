--[[
=head1 NAME

applets.OpenFrameAudioInterface.OpenFrameAudioInterfaceMeta - OpenFrameAudioInterface Meta

=head1 DESCRIPTION

See L<applets.OpenFrameAudioInterface.OpenFrameAudioInterfaceApplet>.

=cut
--]]

local os            = require("os")

local oo            = require("loop.simple")

local AppletMeta    = require("jive.AppletMeta")

local appletManager = appletManager
local jiveMain      = jiveMain


module(...)
oo.class(_M, AppletMeta)


function jiveVersion(meta)
	return 1, 1
end

function defaultSettings(meta)
	return {
		interface = 1,
	}
end


function registerApplet(meta)
	
	jiveMain:addItem(meta:menuItem('appletOpenFrameAudioInterface', 'settingsAudio', "TITLE", function(applet, ...) applet:menu(...) end, 20))

end


--[[

=head1 LICENSE

Created by Andrew Davison
birdslikewires.net

=cut
--]]

