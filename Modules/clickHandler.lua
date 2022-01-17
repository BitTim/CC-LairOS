local M = {}

function M.checkClicked(zone, x, y, yOff)
      if x >= zone.x and x <= zone.x + zone.w - 1 and y - (yOff - 1) >= zone.y and y - (yOff - 1) <= zone.y + zone.h then
            return true
      end
      
      return false
end

function M.execAction(zone)
      if zone.actionArg then
            zone.action(zone.actionArg)
      else
            zone.action()
      end
end

return M