
--[[
=head1 NAME

applets.JogglerUpdates.JogglerUpdatesApplet

=head1 DESCRIPTION

JogglerUpdate v1.02 (10th May 2012)

This applet is used to update SqueezePlay on the O2 Joggler.

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
	
	id = os.capture('sqp_JogglerUpdate.sh id')
	verins = os.capture('sqp_JogglerUpdate.sh verins')
	verchk = os.capture('sqp_JogglerUpdate.sh verchk')
	
	majverins = string.sub(verins,1,1)
	minverins = string.sub(verins,2,3)
	majverchk = string.sub(verchk,1,1)
	minverchk = string.sub(verchk,2,3)
		
	if verchk ~= "" then

		log:info(verchk)

		if verchk == "NOUPDATE" then
	
			veravail = self:string("NOAVAIL")
			headermsg = Textarea("help_text", veravail)
			log:info(veravail)
	
			menu = SimpleMenu("menu", {

					{
						text = self:string("RETURN"),
						style = 'item_choice',
						sound = "WINDOWSHOW",
						callback = function(event, menuItem)
							jiveMain:closeToHome(true, Window.transitionPushRight)
						end
					},

			})		
	
			self.timer = Timer(5000,
				function()
					jiveMain:closeToHome(true, Window.transitionPushRight)
					end,
					true)
			self.timer:start()
	
			window:addWidget(menu)
			menu:setHeaderWidget(headermsg)
			self:tieAndShowWindow(window)
			return window
	
		elseif verchk == "NOMORE" then
	
			local window = Window("text_list", self:string("NOMORE"))
	
			osver = os.capture('sqp_JogglerUpdate.sh oschk')
			majoschk = string.sub(osver,1,1)
			minoschk = string.sub(osver,2,3)
	
			veravail = self:string("NOMOREMSG")
			headermsg = Textarea("help_text", veravail)
			log:info(veravail)
	
			menu = SimpleMenu("menu", {

					{
						text = self:string("RETURN"),
						style = 'item_choice',
						sound = "WINDOWSHOW",
						callback = function(event, menuItem)
							jiveMain:closeToHome(true, Window.transitionPushRight)
						end
					},

			})		
	
			self.timer = Timer(30000,
				function()
					jiveMain:closeToHome(true, Window.transitionPushRight)
					end,
					true)
			self.timer:start()
	
			window:addWidget(menu)
			menu:setHeaderWidget(headermsg)
			self:tieAndShowWindow(window)
			return window
	
		else
		
			-- Would be nice if this could be done via strings.txt for internationalisation, but it got cross.
			veravail = "Version " .. majverchk .. "." .. minverchk .. " is now available. This Joggler is currently running v" .. majverins .. "." .. minverins .. "."
			log:info(veravail)		
		
			headermsg = Textarea("help_text", veravail)
		
			menu = SimpleMenu("menu", {

					{
						text = self:string("CHANGELOG"),
						sound = "WINDOWSHOW",
						callback = function(event, menuItem)
							self:changelog(menuItem)
						end
					},

					{
						text = self:string("INSTALLUPDATE"),
						style = 'item_choice',
						sound = "WINDOWSHOW",
						callback = function(event, menuItem)
							log:info("Update in progress...")
							self:popupscreen('INSTALLINGUPDATE','REBOOTWARNING')
							appletManager:callService("disconnectPlayer")
							os.execute("xset -display :0.0 dpms 0 0 0")
							os.execute("sqp_JogglerUpdate.sh update " .. verchk .. "&")
						end
					},
				
			})
		
			window:addWidget(menu)
			menu:setHeaderWidget(headermsg)
			self:tieAndShowWindow(window)
			return window
			
		end
		
	else
	
		veravail = self:string("ERROR")
		headermsg = Textarea("help_text", veravail)
		log:info(veravail)
	
		menu = SimpleMenu("menu", {

				{
					text = self:string("RETURN"),
					style = 'item_choice',
					sound = "WINDOWSHOW",
					callback = function(event, menuItem)
						jiveMain:closeToHome(true, Window.transitionPushRight)
					end
				},

		})		
	
		self.timer = Timer(15000,
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
	
end


-- Define submenus.
function changelog(self)
	local window = Window("text_list", self:string("CHANGELOG"))
	--window:setAllowScreensaver(false)
	clog = os.capture("sqp_JogglerUpdate.sh clog " .. verins)
	local textarea = Textarea("text", clog)
	window:addWidget(textarea)
	self:tieAndShowWindow(window)
end


-- Allows output of shell scripts to be captured.
function os.capture(cmd)
  local f = io.popen(cmd, 'r')
  local s = f:read('*a')
  f:close()
  return s
end


-- This is a simple on-screen message.
function popupmsg(self, warning)

       log:info(self:string(warning))
 
       -- create a Popup object, using already established 'toast_popup_text' skin style
       local popupmessage = Popup('toast_popup_text')
 
       -- add message to popup
       local popupmessageMessage = Group("group", {
                       text = Textarea('toast_popup_textarea',self:string(warning)),
             })
       popupmessage:addWidget(popupmessageMessage)
 
       -- display the message for 4 seconds
       popupmessage:showBriefly(4000, nil, Window.transitionPushPopupUp, Window.transitionPushPopupDown)		

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


--[[

=head1 LICENSE

Created by Andy Davison
birdslikewires.co.uk

This work is licensed under a Creative Commons Attribution-ShareAlike 3.0 Unported License.

=cut
--]]

