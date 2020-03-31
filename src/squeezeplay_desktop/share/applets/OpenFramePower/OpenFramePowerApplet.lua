
--[[
=head1 NAME

applets.OpenFramePower.OpenFramePowerApplet

=head1 DESCRIPTION

OpenFramePower v1.00 (10th April 2012)

This applet replaces the standard Quit applet on an OpenFrame, providing more options.

=cut
--]]


-- Things we might be using.
local setmetatable, tonumber, tostring = setmetatable, tonumber, tostring

local os                     = require("os")
local io                     = require("io")
local oo                     = require("loop.simple")
local math                   = require("math")
local string                 = require("string")
local table                  = require("jive.utils.table")
local debug                  = require("jive.utils.debug")

local Applet                 = require("jive.Applet")
local System                 = require("jive.System")
local Checkbox               = require("jive.ui.Checkbox")
local Choice                 = require("jive.ui.Choice")
local Framework              = require("jive.ui.Framework")
local Event                  = require("jive.ui.Event")
local Icon                   = require("jive.ui.Icon")
local Label                  = require("jive.ui.Label")
local Button                 = require("jive.ui.Button")
local Popup                  = require("jive.ui.Popup")
local Group                  = require("jive.ui.Group")
local RadioButton            = require("jive.ui.RadioButton")
local RadioGroup             = require("jive.ui.RadioGroup")
local SimpleMenu             = require("jive.ui.SimpleMenu")
local Slider                 = require("jive.ui.Slider")
local Surface                = require("jive.ui.Surface")
local Textarea               = require("jive.ui.Textarea")
local Textinput              = require("jive.ui.Textinput")
local Window                 = require("jive.ui.Window")
local ContextMenuWindow      = require("jive.ui.ContextMenuWindow")
local Timer                  = require("jive.ui.Timer")

local appletManager = appletManager
local jiveMain		= jiveMain

module(..., Framework.constants)
oo.class(_M, Applet)


function menu(self, menuItem)

	local window = Window("text_list", self:string("TITLE"))
	
	headermsg = Textarea("help_text",  self:string("HEADER"))
		
	menu = SimpleMenu("menu", {

		{
			text = self:string("QUIT"),
			style = 'item_choice',
			sound = "WINDOWSHOW",
			callback = function(event, menuItem)
				log:info(self:string("Quitting"))
				os.execute('openframe_power.sh quit')
				Framework:quit()
			end
		},
	
		{
			text = self:string("REBOOT"),
			style = 'item_choice',
			sound = "WINDOWSHOW",
			callback = function(event, menuItem)
				log:info(self:string("Rebooting"))
				os.execute('openframe_power.sh reboot')
			end
		},
	
		{
			text = self:string("SHUTDOWN"),
			style = 'item_choice',
			sound = "WINDOWSHOW",
			callback = function(event, menuItem)
				log:info(self:string("Shutting Down"))
				os.execute('openframe_power.sh halt')
			end
		},
		
	})
	
	self.timer = Timer(10000,
		function()
			jiveMain:closeToHome(true, Window.transitionPushRight)
			end,
			true)
	self.timer:start()
	
	window:addWidget(menu)
	menu:setHeaderWidget(headermsg)
	self:tieAndShowWindow(window)
	return window
		
end


-- Allows output of shell scripts to be captured.
function os.capture(cmd)
  local f = io.popen(cmd, 'r')
  local s = f:read('*a')
  f:close()
  return s
end


--[[

=head1 LICENSE

Created by Andrew Davison
birdslikewires.net

This file is licensed under BSD. Please see the LICENSE file for details.

=cut
--]]

