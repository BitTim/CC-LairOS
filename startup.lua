local processes = require("/Modules/processes")
local log = require("/Modules/log")
local overlay = require("/Modules/overlay")
local homescreen = require("Modules/homescreen")

local parentTerm = term.current()
local w, h = term.getSize()
local appPath = "/Apps/"

local topBarWin = window.create(parentTerm, 1, 1, w, 1)
local lowBarWin = window.create(parentTerm, 1, h, w, 1)
local homescreenWin = window.create(parentTerm, 1, 2, w, h - 2)

log.init()
processes.init(1, 2, w, h - 2)
overlay.init(topBarWin, lowBarWin)
homescreen.init(parentTerm, homescreenWin, appPath, processes)

parentTerm.clear()
overlay.UI_drawOverlay("Home")
homescreen.UI_drawHomescreen()

while true do
    local eventData = table.pack(os.pullEventRaw())
    local e = eventData[1]
    
    local activeProcessTitle = processes.getActiveProcessTitle()
    if activeProcessTitle == "" then activeProcessTitle = "Home" end

    if processes.activeProcess == nil then homescreen.window.setVisible(true)
    else homescreen.window.setVisible(false) end

    overlay.UI_drawOverlay(activeProcessTitle, true)
    processes.checkAllProcessesRunning()

    if e == "char" or e == "key" or e == "key_up" or e == "paste" or e == "terminate" then
        processes.resumeProcess(processes.activeProcess, table.unpack(eventData, 1, eventData.n))

    elseif e == "mouse_click" then
        local button, x, y = eventData[2], eventData[3], eventData[4]

        for i = 1, #homescreen.clickZones do
            local zone = homescreen.clickZones[i]

            if x >= zone.x and x <= zone.x + zone.w - 1 and y - 1 >= zone.y and y - 1 <= zone.y + zone.h then -- y - 1 because homescreen is shifted 1 px down
                if zone.actionArg then
                    zone.action(zone.actionArg)
                else
                    zone.action()
                end

                break
            end
        end

        -- ToDO: Add Home Button action

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