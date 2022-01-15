local processes = require("/Modules/processes")
local overlay = require("/Modules/overlay")

local parentTerm = term.current()
local w, h = term.getSize()

overlay.UI_drawOverlay(parentTerm)

while true do
    local eventData = table.pack(os.pullEventRaw())
    local e = eventData[1]
    
    overlay.UI_drawOverlay(parentTerm)
    processes.checkAllProcessesRunning()

    if e == "char" or e == "key" or e == "key_up" or e == "paste" or e == "terminate" then
        processes.resumeAllProcesses(table.unpack(eventData, 1, eventData.n))

    elseif e == "mouse_click" then
        local button, x, y = eventData[2], eventData[3], eventData[4]

        -- ToDo: Mouse Click event handles

        processes.resumeAllProcesses(e, button, x, y - 1)

    elseif e == "mouse_drag" or e == "mouse_up" or e == "mouse_scroll" then
        local p1, x, y = eventData[2], eventData[3], eventData[4]
        processes.resumeAllProcesses(e, p1, x, y -1)

    else
        processes.resumeAllProcesses(table.unpack(eventData, 1, eventData.n ) )
    end

    sleep(0.1)
end

-- Shutdown
term.redirect(parentTerm)