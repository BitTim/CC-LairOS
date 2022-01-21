local util = require("/Modules/util")

-- Extract to setings
local barColor = colors.gray
local textColor = colors.white
local appTextColor = colors.lightGray

local homeBtn = "()"
local taskBtn = "[]"

local minuteLength = 0.83

local log = nil

-- Create Module table
local M = {}

M.topBarWin = nil
M.lowBarWin = nil

M.homescreen = nil
M.taskmanager = nil

M.clickZones = {}

function M.init(iLog, topBarWin, lowBarWin, homescreen, taskmanager)
    log = iLog
    
    log.log("OVINIT", "Initializing overlay")
    M.topBarWin = topBarWin
    M.lowBarWin = lowBarWin
    M.homescreen = homescreen
    M.taskmanager = taskmanager
    log.log("OVINIT", "Finished")
end

function M.UI_drawOverlay(activeProcessTitle, topOnly)
    activeProcessTitle = activeProcessTitle or ""
    topOnly = topOnly or false
    
    log.log("OVDRAW", "Drawing overlay. Top only: " .. textutils.serialize(topOnly))
    
    -- ==== Print Upper Bar ====
    M.topBarWin.setCursorPos(1, 1)
    M.topBarWin.setTextColor(textColor)
    M.topBarWin.setBackgroundColor(barColor)
    
    log.log("OVDRAW", "Cleared top bar")
    
    -- Get Size of Monitor
    local w, h = M.topBarWin.getSize()
    
    -- Print App Name
    log.log("OVDRAW", "Printing app name")
    local titleString = activeProcessTitle .. " "
    M.topBarWin.setTextColor(appTextColor)
    M.topBarWin.write(titleString)
    M.topBarWin.setTextColor(textColor)
    
    -- Print Time and Day
    log.log("OVDRAW", "Printing date and time")
    local day = os.day()
    local rawDateString = "Day " .. day .. " " .. textutils.formatTime(os.time())
    local dateStr = util.alignTextRight(rawDateString, w - string.len(titleString))
    M.topBarWin.write(dateStr)
    
    log.log("OVDRAW", "Top bar finished")
    
    -- ==== Print Lower Bar ====
    if not topOnly then
        M.lowBarWin.setCursorPos(1, 1)
        M.lowBarWin.setTextColor(textColor)
        M.lowBarWin.setBackgroundColor(barColor)
        
        log.log("OVDRAW", "Cleared lower bar")
        
        M.clickZones = {}
        
        log.log("OVDRAW", "Cleared click zones")

        -- Print buttion offset
        local offset = (w - 6) / 2
        M.lowBarWin.write(string.rep(" ", offset))

        -- Print Home Button
        log.log("OVDRAW", "Printing home button")
        M.lowBarWin.setTextColor(textColor)

        log.log("OVDRAW", "Adding click zone, x: " .. offset .. ", y: 1, w: 2, h: 1")
        M.clickZones[#M.clickZones + 1] = {window = M.lowBarWin, x = offset, y = 1, w = 2, h = 1, action = M.clickEvent, actionArg = "home"}

        M.lowBarWin.write(homeBtn)
        M.lowBarWin.setTextColor(textColor)

        -- Print space
        M.lowBarWin.write("  ")

        -- Print Task Button
        log.log("OVDRAW", "Drawing task button")
        M.lowBarWin.setTextColor(textColor)
        
        log.log("OVDRAW", "Adding click zone, x: " .. offset + 4 .. ", y: 1, w: 2, h: 1")
        M.clickZones[#M.clickZones + 1] = {window = M.lowBarWin, x = offset + 4, y = 1, w = 2, h = 1, action = M.clickEvent, actionArg = "task"}

        M.lowBarWin.write(taskBtn)
        M.lowBarWin.setTextColor(textColor)

        -- Fill bar
        M.lowBarWin.write(string.rep(" ", offset))
        
        log.log("OVDRAW", "Lower Bar Finished")
    end

    -- ==== Reset colors for further drawings ====
    M.topBarWin.setBackgroundColor(colors.black)
    M.lowBarWin.setBackgroundColor(colors.black)
    
    log.log("OVDRAW", "Starting timer for date and time in top bar")
    os.startTimer(minuteLength)
    
    log.log("OVDRAW", "Finished")
end

function M.clickEvent(arg)
    log.log("OVCLICK", "Received click event with arg: " .. arg)

    if arg == "home" then os.queueEvent("sysui_open", "Home") end
    if arg == "task" then os.queueEvent("sysui_open", "Tasks") end
end

-- Return Module table
return M
