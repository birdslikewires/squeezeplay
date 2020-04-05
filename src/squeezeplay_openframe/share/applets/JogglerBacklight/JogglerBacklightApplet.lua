
--[[
=head1 NAME

applets.JogglerBacklight.JogglerBacklightApplet - For controlling display brightness on a Joggler.

=head1 DESCRIPTION

JogglerBacklight v1.01 (10th April 2012)

This applet adjusts the backlight level on an O2 Joggler.

=cut
--]]


-- stuff we use
local ipairs, pairs, tostring, tonumber = ipairs, pairs, tostring, tonumber

local os               = require("os")
local oo               = require("loop.simple")

local Applet           = require("jive.Applet")
local Timer            = require("jive.ui.Timer")
local Framework        = require("jive.ui.Framework")
local Window           = require("jive.ui.Window")
local RadioGroup       = require("jive.ui.RadioGroup")
local RadioButton      = require("jive.ui.RadioButton")
local Label            = require("jive.ui.Label")
local SimpleMenu       = require("jive.ui.SimpleMenu")
local System           = require("jive.System")
local Textarea         = require("jive.ui.Textarea")
local string           = require("string")
local table            = require("jive.utils.table")
local debug            = require("jive.utils.debug")
local Player           = require("jive.slim.Player")

local appletManager    = appletManager

local jnt = jnt
local jiveMain = jiveMain


module(..., Framework.constants)
oo.class(_M, Applet)



function backlightSetting(self, menuItem)

	local group = RadioGroup()

	local backlight = self:getSettings()["backlight"]

	local window = Window("text_list", "Backlight Level")
	window:addWidget(SimpleMenu("menu",
		{
			{
				text = self:string("BLAUTO"),
				style = 'item_choice',
				check = RadioButton(
					"radio",
					group,
					function()
						os.execute("sqp_JogglerBacklight.sh 999 &")
						self:getSettings()["backlight"] = 999
					end,
					(backlight == 999)
				),
			},
			{
				text = self:string("BL100"),
				style = 'item_choice',
				check = RadioButton(
					"radio",
					group,
					function()
						os.execute("sqp_JogglerBacklight.sh 100 &")
						self:getSettings()["backlight"] = 100
					end,
					(backlight == 100)
				),
			},
			{ 
				text = self:string("BL80"),
				style = 'item_choice',
				check = RadioButton(
					"radio",
					group,
					function()
					os.execute("sqp_JogglerBacklight.sh 80 &")
						self:getSettings()["backlight"] = 80
					end,
					(backlight == 80)
				),
			},
			{ 
				text = self:string("BL60"),
				style = 'item_choice',
				check = RadioButton(
					"radio",
					group,
					function()
					os.execute("sqp_JogglerBacklight.sh 60 &")
						self:getSettings()["backlight"] = 60
					end,
					(backlight == 60)
				),
			},
			{ 
				text = self:string("BL40"),
				style = 'item_choice',
				check = RadioButton(
					"radio",
					group,
					function()
					os.execute("sqp_JogglerBacklight.sh 40 &")
						self:getSettings()["backlight"] = 40
					end,
					(backlight == 40)
				),
			},
			{ 
				text = self:string("BL20"),
				style = 'item_choice',
				check = RadioButton(
					"radio",
					group,
					function()
					os.execute("sqp_JogglerBacklight.sh 20 &")
						self:getSettings()["backlight"] = 20
					end,
					(backlight == 20)
				),
			},
			{ 
				text = self:string("BL10"),
				style = 'item_choice',
				check = RadioButton(
					"radio",
					group,
					function()
					os.execute("sqp_JogglerBacklight.sh 10 &")
						self:getSettings()["backlight"] = 10
					end,
					(backlight == 10)
				),
			},
			{ 
				text = self:string("BL5"),
				style = 'item_choice',
				check = RadioButton(
					"radio",
					group,
					function()
					os.execute("sqp_JogglerBacklight.sh 5 &")
						self:getSettings()["backlight"] = 5
					end,
					(backlight == 5)
				),
			},
		}))

	window:addListener(EVENT_WINDOW_POP, function() self:storeSettings() end)

	self:tieAndShowWindow(window)
	return window
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

