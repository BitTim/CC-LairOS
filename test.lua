local color = 1

while true do
    term.clear()
    term.setCursorPos(1, 1)
    term.setTextColor(color)
    term.write("Test")
    term.setTextColor(colors.white)

    local e, key = os.pullEvent("key")
    if key == keys.enter then break end

    color = color * 2
    if color > 16384 then color = 1 end
end