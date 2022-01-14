util = require("/Modules/util")

-- Extract to setings
local username = "User"
local rawHomeStr = "Home"
local accentColor = colors.green
local barColor = colors.gray

-- Create Module table
local M = {}

function M.UI_drawOverlay()
    term.clear()
    
    -- ==== Print Upper Bar ====
    term.setCursorPos(1, 1)
    
    -- Get Size of Monitor
    local w, h = term.getSize()
    
    -- Print Home Button
    term.setBackgroundColor(accentColor)
    local homeStr = " " .. rawHomeStr .. " "
    term.write(homeStr)
    term.setBackgroundColor(barColor)
    
    -- Print Time and Day
    local day = os.day()
    local rawDateString = "Day " .. day .. " " .. textutils.formatTime(os.time())
    local dateStr = string.sub(util.centerText(rawDateString, w), string.len(homeStr))
    term.write(dateStr)
    
    -- Print Username
    local usernameStr = util.alignTextRight(username .. " ", w - string.len(dateStr) - string.len(homeStr))
    term.write(usernameStr)
    
    -- Reset colors for further drawings
    term.setBackgroundColor(colors.black)
end

-- Return Module table
return M
