local log = nil

local M = {}

M.window = nil
M.parentTerm = nil

M.clickZones = {}

function M.init(iLog, window, parentTerm)
    log = iLog
    M.window = window
end

function M.indexProcesses()

end

function M.UI_drawTasklist()

end

function M.UI_drawPageSelector()

end

function M.UI_drawTaskmanager()
    log.log("TMDRAW", "Drawing taskmanager")
    
    term.redirect(M.window)
    term.clear()
    
    M.clickZones = {}
    
    M.indexProcesses()
    M.UI_drawTasklist()
    M.UI_drawPageSelector()
    
    term.redirect(M.parentTerm)
end

function M.open()

end

return M