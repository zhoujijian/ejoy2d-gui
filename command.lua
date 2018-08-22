local stack = {}
local command = {}

function command.run(cmd)
    assert(cmd)
    local ok = cmd:run()
    if ok then
        table.insert(stack, cmd)
    end
end

function command.cancel()
    local count = #stack
    if count>0 then
        local cmd = stack[count]
        local ok = cmd:cancel()
        if ok then
            table.remove(stack, count)
        end
    end
end

return command
