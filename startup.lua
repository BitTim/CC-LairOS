local processes = require("/Modules/processes")
local log = require("/Modules/log")
local clickHandler = require("/Modules/clickHandler")
local overlay = require("/Modules/overlay")
local homescreen = require("/Modules/homescreen")
local taskmanager = require("/Modules/taskmanager")

local parentTerm = term.current()
local w, h = term.getSize()
local appPath = "/Apps/"

local topBarWin = window.create(parentTerm, 1, 1, w, 1)
local lowBarWin = window.create(parentTerm, 1, h, w, 1)
local homescreenWin = window.create(parentTerm, 1, 2, w, h - 2)
local taskmanagerWin = window.create(parentTerm, 1, 2, w, h - 2)

log.init()
processes.init(log, 1, 2, w, h - 2)
overlay.init(log, topBarWin, lowBarWin, homescreen, taskmanager)
homescreen.init(log, parentTerm, homescreenWin, appPath, processes)
taskmanager.init(log, taskmanagerWin)

parentTerm.clear()
overlay.UI_drawOverlay("Home")
homescreen.UI_drawHomescreen()

while true do
    local eventData = table.pack(os.pullEventRaw())
    local e = eventData[1]
    
    local activeProcessTitle = processes.getActiveProcessTitle()
    if activeProcessTitle == "" then activeProcessTitle = "Home" end

    if processes.activeProcess == nil then
        homescreen.window.setVisible(true)
        taskmanager.window.setVisible(false)
    else homescreen.window.setVisible(false) end

    overlay.UI_drawOverlay(activeProcessTitle, true)
    processes.checkAllProcessesRunning()

    if e == "char" or e == "key" or e == "key_up" or e == "paste" or e == "terminate" then
        processes.resumeProcess(processes.activeProcess, table.unpack(eventData, 1, eventData.n))

    elseif e == "mouse_click" then
        local button, x, y = eventData[2], eventData[3], eventData[4]

        local clickZones = {}
        
    
        for i = 1, #homescreen.clickZones do
            local zone = homescreen.clickZones[i]

            local _, wy = homescreenWin.getPosition()

            if clickHandler.checkCliked(zone, x, y, wy) then
                clickHandler.execAction(zone)
                break
            end
        end

        processes.resumeProcess(processes.activeProcess, e, button, x, y - 1)

    elseif e == "mouse_drag" or e == "mouse_up" or e == "mouse_scroll" then
        local p1, x, y = eventData[2], eventData[3], eventData[4]
        processes.resumeProcess(processes.activeProcess, e, p1, x, y -1)

    else
        processes.resumeAllProcesses(table.unpack(eventData, 1, eventData.n ) )
    end
end

-- ToDo: Add logs everywhere

-- Shutdown
log.close()
term.redirect(parentTerm)