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

local function rootnode(dialog)
	return dialog.__layout.__dialog
end

function event.test(dialog, x, y)
	local function test(node, parent_x, parent_y, tx, ty)
		local x = parent_x + node.x
		local y = parent_y + node.y
		local w, h = node.style.width, node.style.height

		if tx >= x and tx < x + w and ty >= y and ty < y + h then
			if not node.children then
				return node
			end
			for i=#node.children, 1, -1 do
				local hit = test(node.children[i], x, y, tx, ty, check)
				if hit then return hit end
			end
		end
	end

	return test(rootnode(dialog), 0, 0, x, y)
end

function event.motion(dialog, what, x, y)
	local root = rootnode(dialog)
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
