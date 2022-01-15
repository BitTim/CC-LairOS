local util = require("/Modules/util")

-- Extract to setings
local rawHomeStr = "Home"
local accentColor = colors.green
local barColor = colors.gray
local minuteLength = 0.83

-- Create Module table
local M = {}

function M.UI_drawOverlay(parentTerm)
    --parentTerm.clear()

    -- ==== Print Upper Bar ====
    parentTerm.setCursorPos(1, 1)

    -- Get Size of Monitor
    local w, h = parentTerm.getSize()

    -- Print Home Button
    parentTerm.setBackgroundColor(accentColor)
    local homeStr = " " .. rawHomeStr .. " "
    parentTerm.write(homeStr)
    parentTerm.setBackgroundColor(barColor)

    -- Print Time and Day
    local day = os.day()
    local rawDateString = "Day " .. day .. " " .. textutils.formatTime(os.time()) .. " "
    local dateStr = util.alignTextRight(rawDateString, w - string.len(homeStr))
    parentTerm.write(dateStr)

    -- Reset colors for further drawings
    parentTerm.setBackgroundColor(colors.black)
    os.startTimer(minuteLength)
end

-- Return Module table
return M
