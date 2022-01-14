overlay = require("/Modules/overlay")

while true do
    overlay.UI_drawOverlay()
    
    local e, key, isHeld = os.pullEvent("key")
    if key == keys.enter then break end
end
