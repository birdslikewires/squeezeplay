
--[[
=head1 NAME

applets.JogglerAudio.JogglerAudioApplet

=head1 DESCRIPTION

JogglerAudio v1.05 (13th February 2014)

This applet is used to configure the Joggler's audio interface.

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

	osplat = os.capture('sqp_JogglerUpdate.sh platform')

	local window = Window("text_list", self:string("TITLE"))

	local group = RadioGroup()
	
	local interface = self:getSettings()["interface"]
	
	if osplat == "sqpos" then
	
		local menu = SimpleMenu("menu", {
	
			{
				text = self:string("IFACEINT"),
				style = 'item_choice',
				check = RadioButton(
					"radio",
					group,
					function()
						os.execute("sqp_JogglerAudio.sh iface 0")
						self:getSettings()["interface"] = 0
						self:storeSettings()
						self:popupmsg('IFACEINTMSG',5000)
					end,
					(interface == 0)
				),
			},
		
			{
				text = self:string("IFACEEXT"),
				style = 'item_choice',
				check = RadioButton(
					"radio",
					group,
					function()
						os.execute("sqp_JogglerAudio.sh iface 1")
						self:getSettings()["interface"] = 1
						self:storeSettings()
						self:popupmsg('IFACEEXTMSG',5000)
					end,
					(interface == 1)
				),
			},
		
			-- No need for the limiter option, as we don't limit any more.
			-- Users can play with the AMixer applet to adjust levels now.
			--{
			--	text = self:string("IFACELIMIT"),
			--	sound = "WINDOWSHOW",
			--	callback = function(event, menuItem)
			--		self:ifacelimit(menuItem)
			--	end
			--},
		
			{
				text = self:string("IFACERESET"),
				style = 'item_choice',
				sound = "WINDOWSHOW",
				callback = function(event, menuItem)
					os.execute("sqp_JogglerAudio.sh reset")
					self:getSettings()["iifacelimit"] = 1
					self:getSettings()["interface"] = 0
					self:storeSettings()
					self:popupmsg('IFACERESETMSG',5000)
				end
			},
				
		})

		window:addWidget(menu)
		self:tieAndShowWindow(window)
		return window
		
	else
	
		local menu = SimpleMenu("menu", {

			{
				text = self:string("IFACEINT"),
				style = 'item_choice',
				check = RadioButton(
					"radio",
					group,
					function()
						os.execute("sqp_JogglerAudio.sh iface 0")
						self:getSettings()["interface"] = 0
						self:storeSettings()
						self:popupmsg('IFACEINTMSG',5000)
					end,
					(interface == 0)
				),
			},
	
			{
				text = self:string("IFACEEXT"),
				style = 'item_choice',
				check = RadioButton(
					"radio",
					group,
					function()
						os.execute("sqp_JogglerAudio.sh iface 1")
						self:getSettings()["interface"] = 1
						self:storeSettings()
						self:popupmsg('IFACEEXTMSG',5000)
					end,
					(interface == 1)
				),
			},
	
			{
				text = self:string("IFACERESET"),
				style = 'item_choice',
				sound = "WINDOWSHOW",
				callback = function(event, menuItem)
					os.execute("sqp_JogglerAudio.sh reset")
					self:getSettings()["interface"] = 0
					self:storeSettings()
					self:popupmsg('IFACERESETMSG',5000)
				end
			},
			
		})

		window:addWidget(menu)
		self:tieAndShowWindow(window)
		return window
		
	end
	
end


-- Define the internal interface limit screen
function ifacelimit(self, menuItem)
	local window = Window("text_list", menuItem.text)
	local textarea = Textarea("help_text", self:string("IFACELIMITMSG"))
	
	local iifacelimit = self:getSettings()["iifacelimit"]

	local group = RadioGroup()
	
	local menu = SimpleMenu("menu", {
		{
			text = self:string("DISABLED"),
			style = 'item_choice',
			check = RadioButton(
				"radio", group,
				function()
					os.execute("sqp_JogglerAudio.sh limiter disabled")
					self:getSettings()["iifacelimit"] = 0
					self:storeSettings()
				end,
				(iifacelimit == 0)
			),
		},


		{
			text = self:string("ENABLED"),
			style = 'item_choice',
			check = RadioButton(
				"radio", group,
				function()
					os.execute("sqp_JogglerAudio.sh limiter enabled")
					self:getSettings()["iifacelimit"] = 1
					self:storeSettings()
				end,
				(iifacelimit == 1)
			),
		},
	})

	window:addWidget(menu)
	menu:setHeaderWidget(textarea)
	self:tieAndShowWindow(window)
	return window;
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

