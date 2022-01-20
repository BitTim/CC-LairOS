local util = require("/Modules/util")
local log = nil

local wallpaperColor = colors.lightBlue
local textColor = colors.white
local entryHeight = 1
local entrySpacing = 1

local M = {}

M.window = nil
M.parentTerm = nil
M.processes = nil

M.clickZones = {}

function M.init(iLog, window, parentTerm, processes)
    log = iLog
    M.window = window
    M.parentTerm = parentTerm
    M.proesses = processes
end

function M.calcPages()
    local _, h = term.getSize()
    
     local usableHeight = h - 1
     -- ToDo Calculate nbumber of entries per page with spacing / margin, whatever
end

function M.UI_drawWallpaper()
    log.log("TMDWAL", "Drawing wallpaper")

    local w, h = M.window.getSize()

    term.setBackgroundColor(wallpaperColor)

    for j = 1, h do
        term.setCursorPos(1, j)
        term.write(string.rep(" ", w))
    end

    term.setBackgroundColor(colors.black)
    
    log.log("TMDWAL", "Finished")
end

function M.UI_drawTasklist()
    local nProc = #M.processes.processes
    
    for i = 1, nProc do
        local task = M.processes.processes[i]
        
        local w, _ = term.getSize()
        
        local title = task.name .. " (" .. i ..")"
        term.setTextColor(textColor)
        term.write(title)
        
        term.setTextColor(colors.red)
        term.write(util.alignTextRight("X", w - string.len(title)))
        term.setTextColor(colors.white)
    end
    
    if nProc < 1 then
        term.write("No tasks running")
    end
end

function M.UI_drawPageSelector()

end

function M.UI_drawTaskmanager()
    log.log("TMDRAW", "Drawing taskmanager")
    
    term.redirect(M.window)
    term.clear()
    
    M.clickZones = {}
    
    M.UI_drawWallpaper()
    M.UI_drawTasklist()
    M.UI_drawPageSelector()
    
    term.redirect(M.parentTerm)
end

function M.open()

end

return M