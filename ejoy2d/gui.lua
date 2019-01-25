local geo = require "ejoy2d.geometry"
local event  = require "ejoy2d.event"
local layout = require "ejoy2d.layout"
local widget = require "ejoy2d.widget"

local gui = { layout = layout, event = event }

local dialog_meta = {} ; dialog_meta.__index = dialog_meta

function dialog_meta:draw(x,y)
	for t, dx, dy, style in self.__layout:draw() do
		widget[t](x + dx, y + dy, style)
	end
end

function dialog_meta:root_container()
    return self.__layout.__dialog
end

function gui.dialog(desc)
	local dialog = layout.dialog(desc)
	dialog:refresh()
	return setmetatable({ __layout = dialog }, dialog_meta)
end

function gui.touch(what, x, y)
end

function gui.iterate(rt, f)
    assert(f)

    local function _iter(root, x, y)
        x = x+root.x
        y = y+root.y
        f(root, x, y)

        -- root may not be container
        if root.children then
            for _, v in ipairs(root.children) do
                _iter(v, x, y)
            end
        end
    end

    _iter(rt, 0, 0)
end

function gui.mount(parent, child)
    assert(parent ~= child.parent, "mount same parent")

    if child.parent then
        for i, c in ipairs(child.parent.children) do
            if c == child then
                table.remove(child.parent.children, i)
                break
            end
        end
    end

    if not parent.children then
        parent.children = { }
    end
    table.insert(parent.children, child)
    child.parent = parent
end

function gui.unmount(node)
	assert(node.parent)
	for i, c in ipairs(node.parent.children) do
		if c == node then
			table.remove(node.parent.children, i)
			break
		end
	end
end

function gui.attributes(root)
    local attribs = {}
    for k,v in pairs(root) do
        local att = tostring(k)
        if string.find(att, "__", 1, true)==1 then
            att = string.sub(att, 3)
            attribs[att] = v
        end
    end
    return attribs
end

return gui
