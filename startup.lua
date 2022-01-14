local processes = require("/Modules/processes")
local overlay = require("/Modules/overlay")
local homescreen = require("/Modules/homescreen")

local parentTerm = term.current()
local w, h = term.getSize()
local mainWindow = window.create(parentTerm, 1, 2, w, h - 1)
local process = nil

overlay.UI_drawOverlay(parentTerm)

while true do
    local eventData = table.pack(os.pullEventRaw())
    local e = eventData[1]
    
    overlay.UI_drawOverlay(parentTerm)

    if not processes.checkProcessRunning(process) then
        processes.startProcess(mainWindow,  {["shell"] = shell}, "/Modules/homescreen.lua") -- ToDo: This starts before overlay is drawn and window gets shifted down on every event
    end

    if e == "char" or e == "key" or e == "key_up" or e == "paste" or e == "terminate" then
        processes.resumeProcess(process, table.unpack(eventData, 1, eventData.n))

    elseif e == "mouse_click" then
        local button, x, y = eventData[2], eventData[3], eventData[4]

        -- ToDo: Mouse Click event handles

        processes.resumeProcess(process, e, button, x, y - 1)

    elseif e == "mouse_drag" or e == "mouse_up" or e == "mouse_scroll" then
        local p1, x, y = eventData[2], eventData[3], eventData[4]
        processes.resumeProcess(process, e, p1, x, y -1)

    else
        processes.resumeProcess(process, table.unpack(eventData, 1, eventData.n ) )
    end

    sleep(0.1)
end

-- Shutdown
term.redirect(parentTerm)