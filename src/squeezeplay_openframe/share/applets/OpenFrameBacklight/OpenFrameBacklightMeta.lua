--[[
=head1 NAME

applets.OpenFrameBacklight.OpenFrameBacklightMeta - OpenFrameBacklight meta-info

=head1 DESCRIPTION

See L<applets.OpenFrameBacklight.OpenFrameBacklightApplet>.

=head1 FUNCTIONS

See L<jive.AppletMeta> for a description of standard applet meta functions.

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
		backlight = 60,
	}
end


function registerApplet(meta)

	jiveMain:addItem(meta:menuItem('appletOpenFrameBacklight', 'screenSettings', "BACKLIGHT", function(applet, ...) applet:backlightSetting(...) end, nil, nil, "hm_settingsBrightness"))
	os.execute("[ ! -f $HOME/.squeezeplay/userpath/settings/OpenFrameBacklight.lua ] || of-backlight `cat $HOME/.squeezeplay/userpath/settings/OpenFrameBacklight.lua | awk -F\= {'print $3'} | awk -F\, {'print $1'}` &")
		
end
  


--[[

=head1 LICENSE

Created by Andrew Davison
birdslikewires.net

=cut
--]]
