local util = require("/Modules/util")
local log = nil

local defaultIconPath = "/Modules/res/default.ico"
local iconSize = {w = 8, h = 6}
local iconMargin = {top = 1, right = 1, bottom = 1, left = 1}
local iconTextHeight = 1

local pageSelectorHeight = 1

local iconsPerRow = 2
local iconsPerColumn = 2
local iconsPerPage = 1

local wallpaperColor = colors.lightBlue
local textColor = colors.white
local inactiveTextColor = colors.lightGray

-- Create module table
local M = {}

M.pages = 1
M.currentPage = 1
M.appPath = ""
M.apps = {}

M.window = nil
M.parentTerm = nil
M.processes = nil

M.clickZones = {}

function M.init(iLog, parentTerm, window, appPath, processes)
    log = iLog
    
    log.log("HSINIT", "Initializing homescreen")
    
    M.window = window
    M.parentTerm = parentTerm

    M.appPath = appPath
    M.processes = processes
    
    log.log("HSINIT", "Finished")
end

function M.indexApps()
    log.log("HSIDX", "Starting indexing apps")

    local rawApps = fs.list(M.appPath)
    M.apps = {}
    log.log("HSIDX", "Fetched list of possible apps")

    for i = 1, #rawApps do
        local appID = #M.apps + 1

        log.log("HSIDX", "Checking if app " .. rawApps[i] .. " is a valid app")

        -- Check if it is a valid app, if yes add
        local entryPointPath = M.appPath .. "/" .. rawApps[i] .. "/entry.lua"
        if fs.exists(entryPointPath) then
            log.log("HSIDX", "App is valid, creating entry with id: " .. appID)
            M.apps[appID] = {}
            M.apps[appID].entry = entryPointPath
            M.apps[appID].name = rawApps[i]

            log.log("HSIDX", "Checking if app includes icon")

            -- Check if icon file exists, if yes, assign, if no, use default icon
            local iconPath = M.appPath .. "/" .. rawApps[i] .. "/icon.ico"
            if fs.exists(iconPath) then
                log.log("HSIDX", "App includes icon, using it")
                M.apps[appID].icon = iconPath
            else
                log.log("HSIDX", "App does not include icon, falling back to default icon")
                M.apps[appID].icon = defaultIconPath
            end
            
            log.log("HSIDX", "Complete entry: " .. textutils.serialize(M.apps[appID]))
        end
    end
    
    log.log("HSIDX", "Finished filtering apps, calculating number of icons per page")

    -- Calculate number of icons per page
    local w, h = M.window.getSize()
    iconsPerRow = math.floor(w / (iconSize.w + iconMargin.left + iconMargin.right))
    iconsPerColumn = math.ceil((h - pageSelectorHeight) / (iconSize.h + iconMargin.top + iconMargin.bottom + iconTextHeight))

    iconsPerPage = iconsPerRow * iconsPerColumn
    
    log.log("HSIDX", "Calculated " .. iconsPerPage .. " icons per page, calculating number of pages")

    -- Calculate number of pages
    M.pages = math.ceil(#M.apps / iconsPerPage)
    if M.currentPage > M.pages then M.currentPage = M.pages end
    
    log.log("HSIDX", "Calculated " .. M.pages .. " pages")
    log.log("HSIDX", "FInished")
end

function M.UI_drawWallpaper()
    log.log("HSDWAL", "Drawing wallpaper")

    local w, h = M.window.getSize()

    term.setBackgroundColor(wallpaperColor)

    for j = 1, h do
        term.setCursorPos(1, j)
        term.write(string.rep(" ", w))
    end

    term.setBackgroundColor(colors.black)
    
    log.log("HSDWAL", "Finished")
end

function M.UI_drawPageSelector()
    log.log("HSDPS", "Drawing page selector")
    
    local w, h = M.window.getSize()

    local selStrWidth = M.pages + 4
    local startPos = math.floor(w / 2 - selStrWidth / 2) + 1

    term.setCursorPos(startPos, h)

    log.log("HSDPS", "Adding click zone, x: " .. startPos .. ", y: " .. h .. ", w: 1, h: 1")
    log.log("HSDPS", "Adding click zone, x: " .. startPos + selStrWidth - 1 .. ", y: " .. h .. ", w: 1, h: 1")

    M.clickZones[#M.clickZones + 1] = {x = startPos, y = h, w = 1, h = 1, action = M.prevPage}
    M.clickZones[#M.clickZones + 1] = {x = startPos + selStrWidth - 1, y = h, w = 1, h = 1, action = M.nextPage}

    term.setTextColor(textColor)
    term.setBackgroundColor(wallpaperColor)

    log.log("HSDPS", "Printing indicators")

    term.write("\17 ")

    for i = 1, M.pages do
        if i == M.currentPage then
            term.setTextColor(textColor)
        else
            term.setTextColor(inactiveTextColor)
        end

        term.write("\7")
    end

    term.setTextColor(textColor)
    term.write(" \16")

    term.setTextColor(colors.white)
    term.setBackgroundColor(colors.black)
    
    log.log("HSDPS", "Finished")
end

function M.UI_drawIcons()
    log.log("HSDICO", "Drawing Icons")

    local page = M.currentPage
    local lastAppOnPrevPage = (page - 1) * iconsPerPage -- Use math to accomodate for luas "array starts on 1 instead of 0" concept

    log.log("HSDICO", "Iterating over apps on page " .. M.currentPage)
    
    for j = 1, iconsPerColumn do
        for i = 1, iconsPerRow do
            local appID = (j - 1) * iconsPerRow + i + lastAppOnPrevPage -- Use math to accomodate for luas "array starts on 1 instead of 0" concept
            if appID > #M.apps then break end

            log.log("HSDICO", "Calculating coordinates of icon")

            local w, h = M.window.getSize()
            local freeSpaceX = w - (iconsPerRow * iconSize.w)
            local freeSpaceY = h - (iconsPerColumn * (iconSize.h + iconTextHeight)) - pageSelectorHeight

            local spacingX = math.ceil(freeSpaceX / (iconsPerRow + 1))
            local spacingY = math.ceil(freeSpaceY / (iconsPerColumn + 1))

            local additionalSpacingX = freeSpaceX - spacingX * (iconsPerRow + 1)
            local additionalSpacingY = freeSpaceY - spacingY * (iconsPerColumn + 1)

            local x = i * spacingX + (i - 1) * iconSize.w
            local y = j * spacingY + (j - 1) * (iconSize.h + iconTextHeight)

            if math.ceil(iconsPerRow / 2) + 1 == i then x = x + additionalSpacingX end
            if math.ceil(iconsPerColumn / 2) + 1 == j then y = y + additionalSpacingY end

            log.log("HSDICO", "Placing icon at x: " .. x .. ", y: " .. y)
            util.drawImage(x, y, M.apps[appID].icon)
            
            log.log("HSDICO", "Adding click zone at x: " .. x .. ", y: " .. y .. ", w: " .. iconSize.w .. ", h: " .. iconSize.h + iconTextHeight)
            M.clickZones[#M.clickZones + 1] = {x = x, y = y, w = iconSize.w, h = iconSize.h + iconTextHeight, action = M.startApp, actionArg = appID}
            
            log.log("HSDICO", "Printing name of app under icon")
            
            local name = M.apps[appID].name
            if string.len(name) > iconSize.w then name = string.sub(name, 1, iconSize.w - 1) .. "\26" end

            term.setTextColor(textColor)
            term.setBackgroundColor(wallpaperColor)
            term.setCursorPos(x + 1, y + iconSize.h + 1)

            local title = util.centerText(name, iconSize.w)
            term.write(title)
            
            if string.len(title) < iconSize.w then
                term.write(string.rep(" ", iconSize.w - string.len(title)))
            end

            term.setTextColor(colors.white)
            term.setBackgroundColor(colors.black)
        end
    end
    
    log.log("HSDICO", "Finished")
end

function M.UI_drawHomescreen()
    term.redirect(M.window)
    term.clear()

    M.clickZones = {}

    M.indexApps()
    M.UI_drawWallpaper()
    M.UI_drawPageSelector()
    M.UI_drawIcons()

    term.redirect(M.parentTerm)
end

function M.nextPage()
    M.currentPage = M.currentPage + 1
    if M.currentPage > M.pages then M.currentPage = M.pages
    else M.UI_drawHomescreen() end
end

function M.prevPage()
    M.currentPage = M.currentPage - 1
    if M.currentPage < 1 then M.currentPage = 1
    else M.UI_drawHomescreen() end
end

function M.startApp(appID)
    M.window.setVisible(false)
    
    local pid = M.processes.startProcess(M.parentTerm, {["shell"] = shell}, M.apps[appID].entry)
    M.processes.selectProcess(pid)
end

function M.open()
    M.processes[M.processes.activeProcess].window.setVisible(false)
    M.window.setVisible(true)
end

-- Return module table
return M