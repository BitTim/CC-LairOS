local util = require("/Modules/util")
local log = nil

local wallpaperColor = colors.blue
local textColor = colors.white
local entryHeight = 1
local entryMargin = {top = 1, right = 1, bottom = 0, left = 1}
local pageSelectorHeight = 1

local M = {}

M.window = nil
M.parentTerm = nil
M.processes = nil

M.entriesPerPage = 1
M.pages = 1
M.currentPage = 1

M.clickZones = {}

function M.init(iLog, parentTerm, window, processes)
    log = iLog
    M.window = window
    M.parentTerm = parentTerm
    M.processes = processes
    
    M.window.setVisible(false)
end

function M.calcPages()
    local _, h = term.getSize()
    
     local usableHeight = h - pageSelectorHeight
     M.entriesPerPage = math.floor(usableHeight / (entryHeight + entryMargin.top + entryMargin.bottom))
     
     M.pages = math.ceil(#M.processes.processes / M.entriesPerPage)
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
    term.setBackgroundColor(wallpaperColor)

    for i = 1, M.entriesPerPage do
        local pid = (M.currentPage - 1) * M.entriesPerPage + i
        local task = M.processes.processes[pid]
        local w, _ = term.getSize()
        w = w - entryMargin.left - entryMargin.right
        
        if task == nil then break end
        
        local x = entryMargin.left + 1
        local y = i * (entryMargin.bottom + entryHeight) + entryMargin.top
        
        local title = task.title .. " (" .. i ..")"
        local spacing = w - string.len(title) - 3
        
        term.setCursorPos(x, y)
        M.clickZones[#M.clickZones + 1] = {window = M.window, x = x, y = y, w = spacing + string.len(title), h = entryHeight, action = M.selectTask, actionArg = pid}
        
        term.setTextColor(textColor)
        term.write(title)
        
        term.write(string.rep(" ", spacing))
        
        M.clickZones[#M.clickZones + 1] = {window = M.window, x = x + string.len(title) + string.len(spacing), y = y, w = 3, h = 1, action = M.endTask, actionArg = pid}
        
        term.setBackgroundColor(colors.red)
        term.setTextColor(colors.white)
        term.write(" X ")
        term.setBackgroundColor(wallpaperColor)
    end
    
    if #M.processes.processes < 1 then
        term.setCursorPos(entryMargin.left + 1, entryMargin.top + 1)
        term.write("No tasks running")
    end
    
    term.setBackgroundColor(colors.black)
end

function M.UI_drawPageSelector()
    log.log("TMDPS", "Drawing page selector")
    
    local w, h = M.window.getSize()

    local selStrWidth = M.pages + 4
    local startPos = math.floor(w / 2 - selStrWidth / 2) + 1

    term.setCursorPos(startPos, h)

    log.log("TMDPS", "Adding click zone, x: " .. startPos .. ", y: " .. h .. ", w: 1, h: 1")
    log.log("TMDPS", "Adding click zone, x: " .. startPos + selStrWidth - 1 .. ", y: " .. h .. ", w: 1, h: 1")

    M.clickZones[#M.clickZones + 1] = {window = M.window, x = startPos, y = h, w = 1, h = 1, action = M.prevPage}
    M.clickZones[#M.clickZones + 1] = {window = M.window, x = startPos + selStrWidth - 1, y = h, w = 1, h = 1, action = M.nextPage}

    term.setTextColor(textColor)
    term.setBackgroundColor(wallpaperColor)

    log.log("TMDPS", "Printing indicators")

    term.write("\17 ")

    for i = 1, M.pages do
        if i == M.currentPage then
            term.setTextColor(textColor)
        else
            term.setTextColor(inactiveTextColor)
        end

        term.write("\7")
    end

    term.setTextColor(textColor)
    term.write(" \16")

    term.setTextColor(colors.white)
    term.setBackgroundColor(colors.black)
    
    log.log("TMDPS", "Finished")
end

function M.UI_drawTaskmanager()
    log.log("TMDRAW", "Drawing taskmanager")
    
    term.redirect(M.window)
    term.clear()
    
    M.clickZones = {}
    
    M.UI_drawWallpaper()
    M.UI_drawPageSelector()
    M.UI_drawTasklist()
    
    term.redirect(M.parentTerm)
    
    log.log("TMDRAW", "Finished")
end

function M.nextPage()
    log.log("TMNP", "Switching to next page")
    
    M.currentPage = M.currentPage + 1
    if M.currentPage > M.pages then M.currentPage = M.pages
    else M.UI_drawTaskmanager() end

    log.log("TMNP", "Finished")
end

function M.prevPage()
    log.log("TMPP", "Switching to previous page")

    M.currentPage = M.currentPage - 1
    if M.currentPage < 1 then M.currentPage = 1
    else M.UI_drawTaskmanager() end

    log.log("TMPP", "Finished")
end

function M.selectTask(pid)
    log.log("TMSELTASK", "Selecting process " .. pid .. " (" .. M.processes.processes[pid].title .. ")")

    M.window.setVisible(false)
    os.queueEvent("process_select", pid)

    log.log("TMSELTASK", "Finished")
end

function M.endTask(pid)
    log.log("TMENDTASK", "Ending task " .. pid .. " (" .. M.processes.processes[pid].title .. ")")
    
    os.queueEvent("process_kill", pid)
    
    log.log("TMENDTASK", "Finished")
end

function M.close()
    log.log("TMCLOSE", "Closing taskmanager")
    
    M.window.setVisible(false)
    
    log.log("TMCLOSE", "Finished")
end

function M.open()
    log.log("TMOPEN", "Opening taskmanager")

    M.window.setVisible(true)

    log.log("TMOPEN", "Finished")
end

return M