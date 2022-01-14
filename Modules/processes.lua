-- Create Modeul table 
local M = {}

function M.resumeProcess(process, e, ...)
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

function M.startProcess(window, envPath, progPath, ...)
    local args = table.pack(...)
    local process = {}

    process.title = fs.getName(progPath)
    process.window = window

    process.co = coroutine.create( function()
        os.run(envPath, progPath, table.unpack(args, 1, args.n))
    end )

    process.filter = nil
    M.resumeProcess(process)
    return process
end

function M.checkProcessRunning(process)
    if process == nil then return false end
    if coroutine.status(process.co) == "dead" then return false end
    return true
end

-- Return Module table
return M