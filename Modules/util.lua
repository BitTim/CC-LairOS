local M = {}

-- ================================
--  Text utility
-- ================================

function M.centerText(str, len)
    local centeredStr = ""
    local offset = (len - string.len(str)) / 2
    for i = 1, offset, 1 do
        centeredStr = centeredStr .. " "
    end

    centeredStr  = centeredStr .. str
    return centeredStr
end

function M.alignTextRight(str, len)
    local alignedStr = ""
    local offset = len - string.len(str)
    for i = 1, offset, 1 do
        alignedStr = alignedStr .. " "
    end
    
    alignedStr = alignedStr .. str
    return alignedStr    
end

return M
