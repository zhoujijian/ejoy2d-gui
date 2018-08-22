local schedule = {
    CREATE = 1,
    MOVED  = 2,
    MODIFY = 3
}

local processes = { }

function schedule:attach(id, proc)
    assert(id)
    assert(not processes[id], id)
    processes[id] = proc
end

function schedule:start(id, ...)
    self:next(id, ...)
end

function schedule:next(id, ...)
    -- stop current process even if _curproc == proc
    if self._curproc then
        self._curproc:stop()
        self._curproc = nil
    end

    local nextproc = processes[id]
    assert(nextproc, id)
    self._curproc = nextproc

    nextproc:start(...)
end

return schedule
