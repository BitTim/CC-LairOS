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

-- ================================
--  Image utility
-- ================================

function M.drawImage(x, y, imgPath)
    local imgFile = fs.open(imgPath, "r")
    local imgData = textutils.unserialize(imgFile.readAll())
    imgFile.close()

    for j = 1, imgData.h do
        for i = 1, imgData.w do
            term.setTextColor(imgData.data[j][i].fg)
            term.setBackgroundColor(imgData.data[j][i].bg)

            term.setCursorPos(x + i, y + j)
            term.write(imgData.data[j][i].c)
        end
    end

    term.setTextColor(colors.white)
    term.setBackgroundColor(colors.black)
end

return M
