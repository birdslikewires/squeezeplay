
--[[
=head1 NAME

applets.OpenFrameAudioInterface.OpenFrameAudioInterfaceApplet

=head1 DESCRIPTION

OpenFrameAudioInterface v1.06 (5th April 2020)

This applet is used to configure the OpenFrame's audio interface.

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
local Keyboard               = require("jive.ui.Keyboard")

local appletManager = appletManager
local jiveMain		= jiveMain

module(..., Framework.constants)
oo.class(_M, Applet)


-- Define the initial menu.
function menu(self, menuItem)

	local window = Window("text_list", self:string("TITLE"))

	local group = RadioGroup()
	
	local interface = self:getSettings()["interface"]
	
	local menu = SimpleMenu("menu", {

		{
			text = self:string("IFACEINTDIRECT"),
			style = 'item_choice',
			check = RadioButton(
				"radio",
				group,
				function()
					os.execute("openframe_audiointerface.sh 0 direct")
					self:getSettings()["interface"] = 0
					self:storeSettings()
					self:popupmsg('IFACEINTDIRECTMSG',8000)
				end,
				(interface == 0)
			),
		},

		{
			text = self:string("IFACEINTSHARED"),
			style = 'item_choice',
			check = RadioButton(
				"radio",
				group,
				function()
					os.execute("openframe_audiointerface.sh 0 shared")
					self:getSettings()["interface"] = 1
					self:storeSettings()
					self:popupmsg('IFACEINTSHAREDMSG',8000)
				end,
				(interface == 1)
			),
		},

		{
			text = self:string("IFACEEXTDIRECT"),
			style = 'item_choice',
			check = RadioButton(
				"radio",
				group,
				function()
					os.execute("openframe_audiointerface.sh 1 direct")
					self:getSettings()["interface"] = 2
					self:storeSettings()
					self:popupmsg('IFACEEXTDIRECTMSG',8000)
				end,
				(interface == 2)
			),
		},
	
		{
			text = self:string("IFACEEXTSHARED"),
			style = 'item_choice',
			check = RadioButton(
				"radio",
				group,
				function()
					os.execute("openframe_audiointerface.sh 1 shared")
					self:getSettings()["interface"] = 3
					self:storeSettings()
					self:popupmsg('IFACEEXTSHAREDMSG',8000)
				end,
				(interface == 3)
			),
		},
	
		{
			text = self:string("IFACERESET"),
			style = 'item_choice',
			sound = "WINDOWSHOW",
			callback = function(event, menuItem)
				os.execute("openframe_audiointerface.sh 0 shared")
				self:getSettings()["interface"] = 1
				self:storeSettings()
				self:popupmsg('IFACERESETMSG',5000)
			end
		},
			
	})

	window:addWidget(menu)
	self:tieAndShowWindow(window)
	return window
	
end


-- This is a full screen message. Use self.popup:hide() to get rid.
function popupscreen(self, warning, subwarning)

	log:info(self:string(warning))

    self.popup = Popup("waiting_popup")

	-- prevent exiting from the spinny
	self.popup:setAllowScreensaver(false)
	self.popup:setAlwaysOnTop(true)
	self.popup:setAutoHide(false)
	self.popup:ignoreAllInputExcept()

    self.popup:addWidget(Icon("icon_connecting"))
    self.popup:addWidget(Label("text", self:string(warning)))
    self.popup:addWidget(Label("subtext", self:string(subwarning)))
    self:tieAndShowWindow(self.popup)

end


-- Allows output of shell scripts to be captured.
function os.capture(cmd)
  local f = io.popen(cmd, 'r')
  local s = f:read('*a')
  f:close()
  return s
end

-- This is a simple on-screen message.
function popupmsg(self, msg, time)

       log:info(self:string(msg))
 
       -- create a Popup object, using already established 'toast_popup_text' skin style
       local popupmessage = Popup('toast_popup_text')
 
       -- add message to popup
       local popupmessageMessage = Group("group", {
                       text = Textarea('toast_popup_textarea',self:string(msg)),
             })
       popupmessage:addWidget(popupmessageMessage)
 
       -- display the message for 4 seconds
       popupmessage:showBriefly(time, nil, Window.transitionPushPopupUp, Window.transitionPushPopupDown)		

end


--[[

=head1 LICENSE

Created by Andy Davison
birdslikewires.co.uk

This work is licensed under a Creative Commons Attribution-ShareAlike 3.0 Unported License.

=cut
--]]

