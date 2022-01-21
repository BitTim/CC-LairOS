local processes = require("/Modules/processes")
local log = require("/Modules/log")
local util = require("/Modules/util")
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

local sysUI = "Home"

log.init()
log.log("INIT", "Initializing everything")
processes.init(log, 1, 2, w, h - 2)
overlay.init(log, topBarWin, lowBarWin, homescreen, taskmanager)
homescreen.init(log, parentTerm, homescreenWin, appPath, processes)
taskmanager.init(log, parentTerm, taskmanagerWin, processes)

homescreen.open()

parentTerm.clear()
overlay.UI_drawOverlay(sysUI)
homescreen.UI_drawHomescreen()

log.log("INIT", "Finished")

while true do
    log.log("MAIN", "Loop start")
    local eventData = table.pack(os.pullEventRaw())
    local e = eventData[1]
    
    log.log("MAIN", "Get Active Process Title")
    local activeProcessTitle = processes.getActiveProcessTitle()
    if activeProcessTitle == "" then activeProcessTitle = sysUI end

    log.log("MAIN", "Draw Overlay")

    overlay.UI_drawOverlay(activeProcessTitle, true)
    processes.checkAllProcessesRunning()

    log.log("MAIN", "Match event and resume process")
    if e == "char" or e == "key" or e == "key_up" or e == "paste" or e == "terminate" then
        processes.resumeProcess(processes.activeProcess, table.unpack(eventData, 1, eventData.n))

    elseif e == "mouse_click" then
        local button, x, y = eventData[2], eventData[3], eventData[4]

        log.log("MAIN", "Mouse event, iterating over click zones")

        local clickZones = {}
        
        util.appendTable(clickZones, overlay.clickZones)
        
        if homescreen.window.isVisible() then util.appendTable(clickZones, homescreen.clickZones) end
        if taskmanager.window.isVisible() then util.appendTable(clickZones, taskmanager.clickZones) end
    
        for i = 1, #clickZones do
            local zone = clickZones[i]

            local _, wy = zone.window.getPosition()

            if clickHandler.checkClicked(zone, x, y, wy - 1) then
                clickHandler.execAction(zone)
                break
            end
        end

        processes.resumeProcess(processes.activeProcess, e, button, x, y - 1)

    elseif e == "mouse_drag" or e == "mouse_up" or e == "mouse_scroll" then
        local p1, x, y = eventData[2], eventData[3], eventData[4]
        processes.resumeProcess(processes.activeProcess, e, p1, x, y -1)

    elseif e == "process_kill" then
        processes.killProcess(eventData[2])
        processes.resumeAllProcesses(table.unpack(eventData, 1, eventData.n ) )

    elseif e == "process_select" then
        processes.selectProcess(eventData[2])
        processes.resumeAllProcesses(table.unpack(eventData, 1, eventData.n ) )

    elseif e == "process_start" then
        local appID = eventData[2]
        local pid = processes.startProcess(parentTerm, {["shell"] = shell}, homescreen.apps[appID].entry, homescreen.apps[appID].name)
        processes.selectProcess(pid)
        processes.resumeAllProcesses(table.unpack(eventData, 1, eventData.n ) )

    elseif e == "sysui_open" then
        if not processes.activeProcess == nil then processes.processes[processes.activeProcess].window.setVisible(false) end
        processes.selectProcess(nil)
        
        sysUI = eventData[2]
        
        homescreen.close()
        taskmanager.close()
        
        if sysUI == "Home" then homescreen.open() end
        if sysUI == "Tasks" then taskmanager.open() end
        
        homescreen.UI_drawHomescreen()
        taskmanager.UI_drawTaskmanager()
        
        processes.resumeAllProcesses(table.unpack(eventData, 1, eventData.n ) )

    else
        processes.resumeAllProcesses(table.unpack(eventData, 1, eventData.n ) )
    end

    log.log("MAIN", "Loop end")
end

-- Shutdown
log.close()
term.redirect(parentTerm)