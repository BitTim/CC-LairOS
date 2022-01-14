print("This is the Home Screen")

while true do
    local e, key, isHolding = os.pullEvent("key")
    if key == keys.enter then
        break
    end
end