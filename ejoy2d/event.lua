local layout = require "ejoy2d.layout"

local event = { }
local current_hit

function event._sortdepth(root)
    local children = { }
    for _, child in ipairs(root.children) do
        table.insert(children, child)
    end
    table.sort(children,
        function(a, b)
            local da = a.__depth or 0
            local db = b.__depth or 0
            return da>db
        end
    )
    return children
end

function event._dispatch(root, what, x, y)
    while root do
        local func = root.__handler[what]
        if func then
            func(root, x, y)
        end
        event[root.type](root, what, x, y)

        root = root.parent
    end
end

function event._test(root, dx, dy, tx, ty, check)
    local w = root.style.width
    local h = root.style.height
    dx = dx+root.x
    dy = dy+root.y

    if (tx>=dx and tx<dx+w) and (ty>=dy and ty<dy+h) then
        print(string.format("in ui area:%q-(%q,%q)(%q,%q)", root.type, dx, dy, tx, ty))
        if root.container and root.children then
            local children = root.children
            for i=#children, 1, -1 do
                local child = children[i]
                local hit = event._test(child, dx, dy, tx, ty, check)
                if hit then
                    return hit
                end
            end
        end

        if (not check) or check(root) then
            return root
        end
    end
end

function event.test(dialog, x, y, check)
    local root = dialog:root_container()
    return event._test(root, 0, 0, x, y, check)
end

function event.motion(dialog, what, x, y)
    local root = dialog:root_container()
    local check = function(hit)
        -- todo: check visible and enabled
        if hit.__message then
            return true
        end
    end

    if what == "BEGAN" then
        current_hit = event._test(root, 0, 0, x, y, check)
    end

    if current_hit then
        event._dispatch(current_hit, what, x, y)
    end
end

function event.button(root, what, x, y)
    local handler = root.__handler
    if what == "END" and handler.click then
        handler.click(root, x, y)
    end
end

function event.panel(root, what, x, y)
    local handler = root.__handler
    if what == "MOVED" then
        root.x = root.x+x-handler.x
        root.y = root.y+y-handler.y
    end
    handler.x = x
    handler.y = y
end

return event
