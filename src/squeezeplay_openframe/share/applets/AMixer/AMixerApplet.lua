--[[

AMixer - interface for amixer

(c) 2012, Will Szumski will@cowboycoders.org
(c) 2012, Adrian Smith, triode1@btinternet.com (several functions used from his EnhancedDigitalOuput)

--]]

local oo               = require("loop.simple")
local io               = require("io")
local os               = require("os")
local Applet           = require("jive.Applet")
local System           = require("jive.System")
local Framework        = require("jive.ui.Framework")
local SimpleMenu       = require("jive.ui.SimpleMenu")
local Textarea         = require("jive.ui.Textarea")
local Label            = require("jive.ui.Label")
local Popup            = require("jive.ui.Popup")
local Checkbox         = require("jive.ui.Checkbox")
local RadioGroup       = require("jive.ui.RadioGroup")
local RadioButton      = require("jive.ui.RadioButton")
local Slider           = require("jive.ui.Slider")
local Surface          = require("jive.ui.Surface")
local Task             = require("jive.ui.Task")
local Timer            = require("jive.ui.Timer")
local Icon             = require("jive.ui.Icon")
local Window           = require("jive.ui.Window")
local debug            = require("jive.utils.debug")
local Group           = require("jive.ui.Group")

local JIVE_VERSION     = jive.JIVE_VERSION
local appletManager    = appletManager

local STOP_SERVER_TIMEOUT = 10

local string, ipairs, tonumber, tostring, require, type, table, unpack, assert, math, pairs, tonumber = string, ipairs, tonumber, tostring, require, type, table, unpack, assert, math, pairs, tonumber

module(..., Framework.constants)
oo.class(_M, Applet)

applet = nil

function round(num, idp)
    local mult = 10^(idp or 0)
    if num >= 0 then return math.floor(num * mult + 0.5) / mult
    else return math.ceil(num * mult - 0.5) / mult end
end

local AlsaCapability = oo.class()

-- represents a capability of an simple alsa control 
--@param card integer card number that the control is associated with
--@param control table --  see_parseAmixerControls
--@param desc descibres what capability does, if nil overide getDescription()
function AlsaCapability:__init(args)
  
  local obj = oo.rawnew(self)
  log:debug('card: ', args.card)
  obj.card = args.card
  obj.control = args.control
  obj.desc = args.desc

  return obj

end

function AlsaCapability:getCard()
    return self.card -1
end

-- combines name and index
function AlsaCapability:getControlIdentifier()
    return '\'' .. self.control.name .. '\'' .. ',' .. self.control.index
end

function AlsaCapability:getStreamModifiers()
    if self.playblack then
        return 'playback'
    elseif self.capture then
        return 'capture'
    end
    return nil
end

-- overide and return a string containing suitable value
--function AlsaCapability:getValue()
--    return ''
--    
--end

function AlsaCapability:set(value)
    cmd = 'amixer -c ' .. self:getCard() .. ' set ' .. self:getControlIdentifier() .. ' ' .. (self:getStreamModifiers() and self:getStreamModifiers() .. ' ' or '')  .. value
    log:debug('executing cmd: ', cmd)
    os.execute(cmd .. ' > /dev/null')
end

-- returns open file descriptor, so you can parse output
function AlsaCapability:get()
    cmd = 'amixer -c ' .. self:getCard() .. ' get ' .. self:getControlIdentifier() .. ' ' .. (self:getStreamModifiers() and self:getStreamModifiers() .. ' ' or '')
    log:debug('executing cmd: ', cmd)
    local file = io.popen(cmd)
	
	if file == nil then
		log:error("the command," .. cmd .. ", failed")
		return nil
	end

    return file
    
end


function AlsaCapability:setPlayBlack()
    self.playblack = true
    self.capture = false
end

function AlsaCapability:setCapture()
    self.playblack = false
    self.capture = true
end

function AlsaCapability:getDescription()
    return self.desc
end

function AlsaCapability:getState()
    assert(true == false, 'override this method')
end


local PVolumeCapability = oo.class({},AlsaCapability)

function PVolumeCapability:__init(args)
    args.desc = applet:string("VOLUME_DESCRIPTION")
    super = oo.superclass(PVolumeCapability):__init(args)
    local obj = oo.rawnew(self,super)
    return obj
end

function PVolumeCapability:setVolumePercent(vol)
    assert(type(vol) == 'number', 'volume must be a number')
    assert(vol <= 100 and vol >= 0, 'volume must be between 0 and 100')
    self:set(vol .. '%')
end

function PVolumeCapability:getState()
    file = self:get()
    local volume = 'error'
    local upper = nil

    if not file then
        return volume
    end

    control = applet:_parseAmixerOutput(file).controls[1]
       
    for i,j in pairs(control) do
        log:debug(i)
        if type(i) == 'string' then
           if i:lower():find('volume$') and j then
                volume = j
                log:debug('volume: ', volume)
                upper = control['volume_upper_limit']
                log:debug('volume_upper_limit: ', upper)
                volume = round(volume * 100 / upper)
                log:debug('volume_percent: ', volume)
                volume = volume .. '%'
                break
           end 
        end

    end
   
    return volume  

end

local PSwitchCapability = oo.class({},AlsaCapability)

function PSwitchCapability:__init(args)
    args.desc = applet:string("MUTE_DESCRIPTION")
    super = oo.superclass(PSwitchCapability):__init(args)
    local obj = oo.rawnew(self,super)
    return obj
end

function PSwitchCapability:getState()
    local control_output = self:get()
    local state = 'error'

    if not control_output then
        return state
    end

    control = applet:_parseAmixerOutput(control_output).controls[1]
    
    if not control['state'] then
        return state
    end

    log:debug('state: ' , control.state)
    
    if control['state'] == 'on' then
        return applet:string('UNMUTED')
    end

    return applet:string('MUTED')     

end

function PSwitchCapability:setMuted(flag)
    if flag then
        self:set('mute')
        return
    end

    self:set('unmute') 

end

function PSwitchCapability:getMuted()
    local state = self:getState()
    if state == 'error' then
        log:error('unable to determined muted stated')
        return
    end
    
    if state == applet:string('MUTED') then
        return true
    end

    return false

end

function PSwitchCapability:toggle()
    local isMuted = self:getMuted()    

    if isMuted then
        return self:setMuted(false)
    end

    return self:setMuted(true)

end


local CapabilityHandler = oo.class()
local PVolumeHandler = oo.class({},CapabilityHandler)
local PSwitchHandler = oo.class({},CapabilityHandler)

function CapabilityHandler:__init(args)
  
  local obj = oo.rawnew(self)
  obj.card = args.card
  obj.control = args.control
  obj.capability = args.capability
  obj.callbacks = {}
  return obj

end

function CapabilityHandler:addCallback(callback)
    assert(type(callback) == 'function', 'callback must be a function')
    self.callbacks[#self.callbacks + 1] = callback
end

function CapabilityHandler:_notifyAll(event)
    for i,j in ipairs (self.callbacks) do
        j(self,event)
    end
end

function CapabilityHandler:processEvent()
    assert(true == false, 'subclass must override')
end


function CapabilityHandler.getHandler(capability, card, control)
    if capability == 'pvolume' then
        return PVolumeHandler({capability=capability,card=card,control=control})
    elseif capability == 'pswitch' then
        return PSwitchHandler({capability=capability,card=card,control=control})
    else
        log:warn('unknown/ unimplemented capability: ', capability)
    end

end

function CapabilityHandler:getState()
    return self.capability:getState()
end

function CapabilityHandler:getDescription()
    return self.capability:getDescription()
end



function PVolumeHandler:__init(args)
    super = oo.superclass(PVolumeHandler):__init(args)
    local obj = oo.rawnew(self,super)
    obj.capability = PVolumeCapability({card = args.card, control = args.control})
    return obj
end

function PVolumeHandler:_setVolume(value)
    log:debug('slider value: ', value)   
    self.capability:setVolumePercent(tonumber(value))
    self:_notifyAll()
end

function PVolumeHandler:processEvent()
    local VOLUME_STEPS = 100
    local VOLUME_MAX = 100
    local VOLUME_STEP = VOLUME_MAX / VOLUME_STEPS
    local current_volume = tonumber(self:getState():match('%d+'))
    log:debug('current_volume: ', current_volume)
	local window = Window("text_list", applet:string("VOLUME_DESCRIPTION"), "settingstitle")

	self.slider = Slider("volume_slider", 0, VOLUME_STEPS, current_volume,
			     function(slider, value)
				     self:_setVolume(value)
			     end)

	self.slider:addListener(EVENT_KEY_PRESS,
				function(event)
					local code = event:getKeycode()
					if code == KEY_VOLUME_UP then
						self:_setVolume(self.slider:getValue() + 1)
						return EVENT_CONSUME
					elseif code == KEY_VOLUME_DOWN then
						self:_setVolume(self.slider:getValue() - 1)
						return EVENT_CONSUME
					end
					return EVENT_UNUSED
				end)


	window:addWidget(Group("slider_group", {
				     min = Icon("button_volume_min"),
				     slider = self.slider,
				     max = Icon("button_volume_max")
			     }))

    window:addListener(EVENT_WINDOW_POP,
      function(event)
        self:_notifyAll()    				
        
      end
    )    
    return window
end



function PSwitchHandler:__init(args)
    super = oo.superclass(PSwitchHandler):__init(args)
    local obj = oo.rawnew(self,super)
    obj.capability = PSwitchCapability({capability=args.capability,card = args.card, control = args.control})
    return obj
end


function PSwitchHandler:processEvent()
    self.capability:toggle()
    self:_notifyAll()
end

function PSwitchHandler:getDescription()
    muted = self.capability:getMuted()
    if muted then 
        return applet:string('UNMUTE')
    end
    return applet:string('MUTE')
end



function updateStartMenu(self,menu)

    menu:setHeaderWidget(Textarea("help_text", self:string("HELP_START")))

	local cards = self:_parseCards()
    self.current_card = self.current_card or 1
    len = table.getn(cards)

    local incrementCard = function()
        if self.current_card < len then
            self.current_card = self.current_card + 1
        else
            self.current_card = 1    
        end
        log:debug('current card :', self.current_card)
    end
	
    local items = {}

    items[#items+1] = {
	    text = cards[self.current_card].desc,
	    sound = "WINDOWSHOW",
	    callback = function(event, menuItem)
                        incrementCard()
                        self:updateStartMenu(menu) 
			       end,
    }

    for control_no, control in ipairs(cards[self.current_card].controls) do
        -- we only deal with playback devices for now
        if control.playback_channels then
            items[#items+1] = {
	            text = control.name,
	            sound = "WINDOWSHOW",
	            callback = function(event, menuItem)
                                self:controlHandler(self.current_card, control) 
			               end,
            }
        end
    end


    menu:setItems(items, #items)   
end

--function test_caps(self,card,control)
    --if control.name:lower() == 'master' then
    --    p = PVolumeCapability({card = card, control = control})
    --    p:setVolumePercent(20)
    --    log:debug(p:getState())
    --    a = PSwitchCapability({card = card, control = control})
    --    a:setMuted(true)
    --    log:debug('muted state: ', a:getMuted())
   --end
--end


function updateControlHandlerMenu(self,menu,card,control)

    local callback = function(handler,event) 
                        self:updateControlHandlerMenu(menu,card,control)   
                     end

    local items = {}

    for i, capability in ipairs(control.caps) do

        local handler = CapabilityHandler.getHandler(capability,card,control)
        
        if handler then
        
            items[#items+1] = {
	            text = handler:getDescription(),
	            sound = "WINDOWSHOW",
	            callback = function(event, menuItem)
                                handler:addCallback(callback)
                                rtn = handler:processEvent()  
                                if oo.instanceof(rtn,Window) then
                                    self:tieAndShowWindow(rtn)
                                end
			               end,
            }


        end

    end
    

    menu:setItems(items, #items) 


end

function controlHandler(self, card, control)
    log:debug('card', card, '\t', 'control', control.name)

	local window = Window("text_list", self:string("CAPABILITIES"))
	local menu = SimpleMenu("menu")
	window:addWidget(menu)
    
    self:updateControlHandlerMenu(menu,card,control)



	self:tieAndShowWindow(window)
	return window

end



function startMenu(self, menuItem)
    applet = self
	local window = Window("text_list", self:string("SELECT_CONTROL"))
	local menu = SimpleMenu("menu")
	window:addWidget(menu)

    self:updateStartMenu(menu)

	self:tieAndShowWindow(window)
	return window
end


--- paste


function pack(...)
    return arg
end

function string:split(sSeparator, nMax, bRegexp)
	assert(sSeparator ~= '')
	assert(nMax == nil or nMax >= 1)

	local aRecord = {}

	if self:len() > 0 then
		local bPlain = not bRegexp
		nMax = nMax or -1

		local nField=1 nStart=1
		local nFirst,nLast = self:find(sSeparator, nStart, bPlain)
		while nFirst and nMax ~= 0 do
			aRecord[nField] = self:sub(nStart, nFirst-1)
			nField = nField+1
			nStart = nLast+1
			nFirst,nLast = self:find(sSeparator, nStart, bPlain)
			nMax = nMax-1
		end
		aRecord[nField] = self:sub(nStart)
	end

	return aRecord
end


function _parseAmixerControls(self, card_no)
	local card_no = card_no or 0
	local t = nil
	
	local file = io.popen("amixer -c " .. card_no)
	
	if file == nil then
		log:error("the command, amixer -c " .. card_no .. ", failed")
		return t
	end

    t = self:_parseAmixerOutput(file)

    return t
	

end


function _parseAmixerOutput(self, file)

    local t ={}

	-- parsing helper functions
	local last
	local parse = function(regexp, opt)
		local tmp = last or file:read()
		if tmp == nil then
			return
		end
		local r =  pack(string.match(tmp, regexp))
        len = table.getn(r)
		if opt and len == 0 then
			last = tmp
		else
			last = nil
		end
        -- FIXME: why does return not return the multiple returns from unpack?
        -- for multiple returns unpack rtn
        if len == 0 then 
            return nil
        elseif len == 1 then
            return unpack(r)
        else
            return r
        end
	end

	local skip = function(number) 
		if last and number > 0 then
			last = nil
			number = number - 1
		end
		while number > 0 do
			file:read()
			number = number - 1
		end
	end

	local eof = function()
		if last then return false end
		last = file:read()
		return last == nil
	end

	local controls = {}

    local addControlInfo = function (key, val)
        if not val then
            return
        end
        controls[#controls][key] = val
    end

    local extractVolumeInfo = function(channel)
        local pattern = ':.-(%d+).*%[(on?f?f?)%].*'
        pattern = channel .. pattern
        local volume_info = parse(pattern,true) or false and skip(1)
        local volume, state
        if volume_info then
            volume, state = unpack(volume_info)
        else
            pattern = channel .. ':.*%[(on?f?f?)%].*'
            state = parse(pattern,true) or false and skip(1)
            pattern = channel .. ':.-(%d+).*'
            volume = parse(pattern,true) or false and skip(1)
        end
        return state, volume    
    end

	while not eof() do
        local info = parse('Simple mixer control%s+\'(.*)\',(%d+)')
        local name, index
        if info then
            name, index = unpack(info)
        end
        local caps = parse('Capabilities:%s+(.*)',true) or false and skip(1)
        if caps then
            caps = caps:split(' ')
        end
        local items = parse('Items:%s+(.*)', true) or false and skip(1)
        if items then
            items = items:gsub('\'','')
            items = items:split(' ')
        end
        local item0 = parse('Item0:%s+(.*)', true) or false and skip(1)
        if item0 then
            item0 = item0:gsub('\'','')
            item0 = item0:gsub(' ','')
        end
        
        local playback_channels = parse('Playback channels:%s+(.*)', true) or false and skip(1)
        local capture_channels = parse('Capture channels:%s+(.*)', true) or false and skip(1)
        local limit_info = parse('Limits:.-(%d+).-(%d+)',true) or false and skip(1)
        local lower_limit, upper_limit
        if limit_info then
            lower_limit, upper_limit = unpack(limit_info)
            log:debug('upper / lower volume limit: ' , lower_limit, '/' , upper_limit)    
        end
        local mono_state, mono_volume = extractVolumeInfo('Mono')
        local front_left_state, front_left_volume = extractVolumeInfo('Front Left')
        local front_right_state, front_right_volume = extractVolumeInfo('Front Right')

        state = mono_state or front_left_state or front_right_state

        if state then
            log:debug('state: ', state)
        end

        

        if name then
		    controls[#controls+1] = {name = name, }
        end
        -- only adds if non nil
        addControlInfo('index',index)
        addControlInfo('caps',caps)
        addControlInfo('playback_channels',playback_channels)
        addControlInfo('capture_channels',capture_channels)
        addControlInfo('state',state)
        addControlInfo('mono_volume',mono_volume)
        addControlInfo('volume_lower_limit',lower_limit)
        addControlInfo('volume_upper_limit', upper_limit)
        addControlInfo('front_left_volume',front_left_volume)
        addControlInfo('front_right_volume',front_right_volume)
        addControlInfo('items',items)
        addControlInfo('item0',item0)

	end
	
	t.controls = controls

	file:close()

	return t

end


function _parseCards(self)
	local t = {}

	local cards = io.open("/proc/asound/cards", "r")

	if cards == nil then
		log:error("/proc/asound/cards could not be opened")
		return
	end

	-- read and parse entries
	for line in cards:lines() do
		local num, id, desc = string.match(line, "(%d+)%s+%[(.-)%s+%]:%s+(.*)")
        if num then
            t[#t +1] = self:_parseAmixerControls(num)
            t[#t]['id'] = id
            t[#t]['desc'] = desc
        end
	end

	cards:close()

	return t
end




