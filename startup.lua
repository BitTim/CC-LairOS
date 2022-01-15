local processes = require("/Modules/processes")
local log = require("/Modules/log")
local overlay = require("/Modules/overlay")

local parentTerm = term.current()
local w, h = term.getSize()

log.init()

parentTerm.clear()
overlay.UI_drawOverlay(parentTerm)

while true do
    local eventData = table.pack(os.pullEventRaw())
    local e = eventData[1]
    
    overlay.UI_drawOverlay(parentTerm)
    processes.checkAllProcessesRunning()

    if e == "char" or e == "key" or e == "key_up" or e == "paste" or e == "terminate" then
        processes.resumeProcess(processes.activeProcess, table.unpack(eventData, 1, eventData.n))

    elseif e == "mouse_click" then
        local button, x, y = eventData[2], eventData[3], eventData[4]

        local process = processes.startProcess(parentTerm, {["shell"] = shell}, "/rom/programs/fun/advanced/paint.lua", "image")
        if process then processes.selectProcess(process) end

        -- ToDo: Mouse Click event handles

        processes.resumeProcess(processes.activeProcess, e, button, x, y - 1)

    elseif e == "mouse_drag" or e == "mouse_up" or e == "mouse_scroll" then
        local p1, x, y = eventData[2], eventData[3], eventData[4]
        processes.resumeProcess(processes.activeProcess, e, p1, x, y -1)

    else
        processes.resumeAllProcesses(table.unpack(eventData, 1, eventData.n ) )
    end
end

-- Shutdown
log.close()
term.redirect(parentTerm)