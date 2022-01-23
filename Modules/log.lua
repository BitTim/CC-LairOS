local M = {}

local latestLogFilePath = "/logs/latest.log"
local oldLogFilePath = "/logs/log"
local logFile = nil

M.logging = true

function M.init()
    if fs.exists(latestLogFilePath) then
        if fs.exists(oldLogFilePath .. os.day() .. os.time() .. ".log") then
            fs.delete(oldLogFilePath .. os.day() .. os.time() .. ".log")
        end

        fs.move(latestLogFilePath, oldLogFilePath .. os.day() .. os.time() .. ".log")
    end

    logFile = fs.open(latestLogFilePath, "w")
    logFile.write("-- Start of log --\n")
    logFile.close()
end

function M.setLogging(logging)
    M.logging = logging
end

function M.log(tag, str)
    if not logging then return end

    logFile = fs.open(latestLogFilePath, "a")
    logFile.write("[" .. os.day() .. " " .. textutils.formatTime(os.time()) .. "] <" .. tag .. "> " .. str .. "\n")
    logFile.close()
end

function M.close()
    logFile.close()
end

return M