local log = require("/Modules/log")

-- Create Modeul table 
local M = {}

M.processes = {}
M.activeProcess = nil

function M.getProcessTitle(pid)
    if pid == nil then return "" end
    if M.processes[pid] == nil then return "" end
    return M.processes[pid].title
end

function M.getProcessByTitle(title)
    for i = 1, #M.processes do
        if M.getProcessTitle(i) == title then return i end
    end

    return nil
end

function M.selectProcess(pid)
    log.log("PROCSEL", "Selecting process " .. textutils.serialize(pid) .. " (" .. M.getProcessTitle(pid) .. ")")
    if M.activeProcess == pid then
        log.log("PROCSEL", "Process " .. textutils.serialize(pid) .. " (" .. M.getProcessTitle(pid) .. ") already selected, aborting")
        return
    end

    if M.activeProcess then
        log.log("PROCSEL", "Deactivating old process " .. M.activeProcess .. " (" .. M.getProcessTitle(M.activeProcess) .. ")")
        local oldProcess = M.processes[M.activeProcess]

        if M.processes[pid] then
            oldProcess.window.setVisible(false)
        end
    end

    M.activeProcess = pid
    log.log("PROCSEL", "Changed active process to " .. textutils.serialize(pid) .. " (" .. M.getProcessTitle(pid) .. ")")

    if M.activeProcess then
        log.log("PROCSEL", "Activating new process " .. pid .. " (" .. M.getProcessTitle(pid) .. ")")
        local newProcess = M.processes[M.activeProcess]
        newProcess.window.setVisible(true)
    else
        log.log("PROCSEL", "New process is nil, clearing screen")
        term.clear()
    end
    log.log("PROCSEL", "Finished")
end

function M.resumeProcess(pid, e, ...)
    if pid == nil or pid < 1 then return end
    log.log("PROCRES", "Resuming process " .. pid .. " (" .. M.getProcessTitle(pid) .. ")")
    
    local process = M.processes[pid]
    if process == nil then return end

    local filter = process.filter
    if filter == nil or filter == e or e == "terminate" then
        if M.checkProcessRunning(pid) == false then return end

        log.log("PROCRES", "Redirecting terminal to window")
        term.redirect(process.term)
        local ok, result = coroutine.resume(process.co, e, ...)
        process.term = term.current()

        if ok then
            process.filter = result
        else
            printError(result)
        end
    else
        log.log("PROCRES", "Cancelled resume of " .. pid .. " (" .. M.getProcessTitle(pid) .. "), event filter")
    end

    log.log("PROCRES", "Finished")
end

function M.resumeAllProcesses(e, ...)
    for i = 1, #M.processes do
        M.resumeProcess(i, e, ...)
    end
end

function M.startProcess(parentTerm, envVars, progPath, ...)
    log.log("PROCSTART", "Starting process " .. progPath)

    local args = table.pack(...)
    local pid = #M.processes + 1
    local process = {}
    
    process.title = fs.getName(progPath)

    log.log("PROCSTART", "Created pID: " .. pid .. " and title: " .. process.title)

    -- Check if same process is running already
    local rpid = M.getProcessByTitle(process.title)
    if rpid then
        log.log("PROCSTART", "Process with title " .. process.title .. " (" .. rpid .. ") already running, selecting process")
        M.selectProcess(rpid)
        return
    end

    log.log("PROCSTART", "Creating window for " .. pid .. " (" .. process.title .. ")")
    local w, h = parentTerm.getSize()
    process.window = window.create(parentTerm, 1, 2, w, h - 1)

    process.term = process.window

    log.log("PROCSTART", "Creating coroutine for " .. pid .. " (" .. process.title .. ")")
    process.co = coroutine.create( function()
        os.run(envVars, progPath, table.unpack(args, 1, args.n))
    end )

    process.filter = nil

    log.log("PROCSTART", "Adding process " .. pid .. " (" .. process.title .. ") to global process table")
    M.processes[pid] = process

    log.log("PROCSTART", "Finished")
    M.resumeProcess(pid)
    return pid
end

function M.killProcess(pid)
    if pid == nil or pid < 1 then return end

    log.log("PROCKILL", "Killing process " .. pid .. " (" .. M.getProcessTitle(pid) .. ")")

    local process = M.processes[pid]
    if process == nil then return end

    M.processes[pid] = M.processes[#M.processes]
    M.processes[#M.processes] = nil

    log.log("PROCKILL", "Removed from global process table")

    if #M.processes > 0 then
        log.log("PROCKILL", "Selecting process 1 (" .. M.getProcessTitle(1) .. ")")
        M.selectProcess(1)
    else
        log.log("PROCKILL", "No processes available to select")
        M.selectProcess(nil)
    end

    log.log("PROCKILL", "Finished")
end

function M.checkProcessRunning(pid)
    if pid == nil or pid < 1 then return false end
    log.log("PROCCHECK", "Checking if process " .. pid .. " (" .. M.getProcessTitle(pid) .. ") exists")
    
    local process = M.processes[pid]
    if process == nil then return false end

    log.log("PROCCHECK", "Checking if process " .. pid .. " (" .. M.getProcessTitle(pid) .. ") is running")

    if coroutine.status(process.co) == "dead" then
        log.log("PROCCHECK", "Process " .. pid .. " (" .. M.getProcessTitle(pid) .. ") has stopped, killing process")
        M.killProcess(pid)

        log.log("PROCCHECK", "Finished")
        return false
    end

    log.log("PROCCHECK", "Finished, process is running")
    return true
end

function M.checkAllProcessesRunning()
    for i = 1, #M.processes do
        M.checkProcessRunning(i)
    end
end

-- Return Module table
return M