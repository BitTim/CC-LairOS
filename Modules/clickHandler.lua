local M = {}

function M.checkClicked(zone, x, y)
      local wx, wy = zone.window.getPosition()
      local ww, wh = zone.window.getSize()

      

      if x >= wx and x < wx + ww and y >= wy and y < wy + wh then
            if x >= zone.x + wx - 1 and x < zone.x + zone.w + wx - 1 and y >= zone.y + wy - 1 and y < zone.y + zone.h + wy - 1 then
                  return true
            end
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