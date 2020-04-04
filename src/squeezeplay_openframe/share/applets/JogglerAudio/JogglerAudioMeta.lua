--[[
=head1 NAME

applets.JogglerAudio.JogglerAudioMeta - JogglerAudio Meta

=head1 DESCRIPTION

See L<applets.JogglerAudio.JogglerAudioApplet>.

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
		interface = 0,
		iifacelimit = 1,
	}
end


function registerApplet(meta)
	
	--jiveMain:addItem(meta:menuItem('appletJogglerAudio', 'home', "TITLE", function(applet, ...) applet:menu(...) end, 10))
	jiveMain:addItem(meta:menuItem('appletJogglerAudio', 'settingsAudio', "TITLE", function(applet, ...) applet:menu(...) end, 40))

end


--[[

=head1 LICENSE

Created by Andy Davison
birdslikewires.co.uk

This work is licensed under a Creative Commons Attribution-ShareAlike 3.0 Unported License.

=cut
--]]

