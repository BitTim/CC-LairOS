-- Create Modeul table 
local M = {}

M.processes = {}
M.activeProcess = nil

function M.getProcessTitle(pid)
    return M.processes[pid].title
end

function M.getProcessByTitle(title)
    for i = 1, #M.processes do
        if M.getProcessTitle(i) == title then return i end
    end

    return nil
end

function M.selectProcess(pid)
    if M.activeProcess == pid then return end

    if M.activeProcess then
        local oldProcess = M.processes[M.activeProcess]
        oldProcess.window.setVisible(false)
    end

    M.activeProcess = pid

    if M.activeProcess then
        local newProcess = M.processes[M.activeProcess]
        newProcess.window.setVisible(true)
    end
end

function M.resumeProcess(pid, e, ...)
    if idx == nil or pid < 1 then return end

    local process = M.processes[pid]
    if process == nil then return end

    local filter = process.filter
    if filter == nil or filter == e or e == "terminate" then
        term.redirect(process.window)
        local ok, result = coroutine.resume(process.co, e, ...)
        process.window = term.current()

        if ok then
            process.filter = result
        else
            printError(result)
        end
    end
end

function M.resumeAllProcesses(e, ...)
    for i = 1, #M.processes do
        M.resumeProcess(i, e, ...)
    end
end

function M.startProcess(envPath, progPath, ...)
    local args = table.pack(...)
    local pid = #M.processes + 1
    local process = {}

    process.title = fs.getName(progPath)

    -- Check if same process is running already
    local rpid = M.getProcessByTitle(process.title)
    if not rpid == nil then
        M.selectProcess(ripd)
        return
    end

    process.window = window.create(parentTerm, 1, 2, w, h - 1)

    process.co = coroutine.create( function()
        os.run(envPath, progPath, table.unpack(args, 1, args.n))
    end )

    process.filter = nil
    M.processes[pid] = process
    M.resumeProcess(pid)
    return pid
end

function M.killProcess(pid)
    if pid == nil or pid < 1 then return end

    local process = M.processes[pid]
    if process == nil then return end

    if pid > 1 then
        M.selectProcess(pid - 1)
    elseif #M.processes > 0 then
        M.selectProcess(1)
    else
        M.selectProcess(nil)
    end
end

function M.checkProcessRunning(pid)
    if pid == nil or pid < 1 then return false end

    local process = M.processes[pid]
    if process == nil then return false end

    if coroutine.status(process.co) == "dead" then
        M.killProcess(pid)
        return false
    end

    return true
end

function M.checkAllProcessesRunning()
    for i = 1, #M.processes do
        M.checkProcessRunning(i)
    end
end

-- Return Module table
return M