--[[
=head1 NAME

applets.JogglerBacklight.JogglerBacklightMeta - JogglerBacklight meta-info

=head1 DESCRIPTION

See L<applets.JogglerBacklight.JogglerBacklightApplet>.

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

	os.execute("sqp_JogglerBacklight.sh 888")
	jiveMain:addItem(meta:menuItem('appletJogglerBacklight', 'screenSettings', "BACKLIGHT", function(applet, ...) applet:backlightSetting(...) end, nil, nil, "hm_settingsBrightness"))
	os.execute("[ ! -f $HOME/.squeezeplay/userpath/settings/JogglerBacklight.lua ] || sqp_JogglerBacklight.sh `cat $HOME/.squeezeplay/userpath/settings/JogglerBacklight.lua | awk -F\= {'print $3'} | awk -F\, {'print $1'}` &")
		
end
  


--[[

=head1 LICENSE

Created by Andy Davison
birdslikewires.co.uk

This file is made available under the following Creative Commons licence:

Attribution-ShareAlike 3.0 Unported (CC BY-SA 3.0).

Please see http://creativecommons.org/licenses/by-sa/3.0/ for details.

=cut
--]]
