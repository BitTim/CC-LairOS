local util = require("/Modules/util")

-- Extract to setings
local barColor = colors.gray
local textColor = colors.white
local appTextColor = colors.lightGray
local clickedColor = colors.blue

local homeBtn = "()"
local taskBtn = "[]"

local minuteLength = 0.83

-- Create Module table
local M = {}

M.topBarWin = nil
M.lowBarWin = nil

function M.init(topBarWin, lowBarWin)
    M.topBarWin = topBarWin
    M.lowBarWin = lowBarWin
end

function M.UI_drawOverlay(activeProcessTitle, topOnly, homeClicked, taskClicked)
    activeProcessTitle = activeProcessTitle or ""
    topOnly = topOnly or false
    homeClicked = homeClicked or false
    taskClicked = taskClicked or false
    
    -- ==== Print Upper Bar ====
    M.topBarWin.clear()
    M.topBarWin.setCursorPos(1, 1)
    M.topBarWin.setTextColor(textColor)
    M.topBarWin.setBackgroundColor(barColor)
    
    -- Get Size of Monitor
    local w, h = M.topBarWin.getSize()
    
    -- Print App Name
    local titleString = activeProcessTitle .. " "
    M.topBarWin.setTextColor(appTextColor)
    M.topBarWin.write(titleString)
    M.topBarWin.setTextColor(textColor)
    
    -- Print Time and Day
    local day = os.day()
    local rawDateString = "Day " .. day .. " " .. textutils.formatTime(os.time())
    local dateStr = util.alignTextRight(rawDateString, w - string.len(titleString))
    M.topBarWin.write(dateStr)
    
    -- ==== Print Lower Bar ====
    if not topOnly then
        M.lowBarWin.clear()
        M.lowBarWin.setCursorPos(1, 1)
        M.lowBarWin.setTextColor(textColor)
        M.lowBarWin.setBackgroundColor(barColor)

        -- Print buttion offset
        local offset = (w - 6) / 2
        M.lowBarWin.write(string.rep(" ", offset))

        -- Print Home Button in according color
        if homeClicked == true then
            M.lowBarWin.setTextColor(clickedColor)
        end

        M.lowBarWin.write(homeBtn)
        M.lowBarWin.setTextColor(textColor)

        -- Print space
        M.lowBarWin.write("  ")

        -- Print Task Button in according color
        if taskClicked == true then
            M.lowBarWin.setTextColor(clickedColor)
        end

        M.lowBarWin.write(taskBtn)
        M.lowBarWin.setTextColor(textColor)

        -- Fill bar
        M.lowBarWin.write(string.rep(" ", offset))
    end

    -- ==== Reset colors for further drawings ====
    M.topBarWin.setBackgroundColor(colors.black)
    M.lowBarWin.setBackgroundColor(colors.black)
    os.startTimer(minuteLength)
end

-- Return Module table
return M
