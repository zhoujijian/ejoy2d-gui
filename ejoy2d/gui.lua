local geo = require "ejoy2d.geometry"
local spr = require "ejoy2d.sprite.c"
local layout = require "ejoy2d.layout"
local event = require "ejoy2d.event"

local gui = { layout = layout }

local widget = {}
local dialog = {} ; dialog.__index = dialog

function dialog:draw(x,y)
	for t,dx,dy,style in self.__layout:draw() do
		widget[t](x+dx,y+dy,style)
	end
end

function dialog:root_container()
    return self.__layout.__dialog
end

function widget.panel(x,y,style)
	geo.box(x,y,style.width,style.height,0xe0404040)	-- todo: color
end

function widget.button(x,y,style)
	local w,h = style.width, style.height
	local color = 0xffe0e0e0	-- todo: color
	local bgcolor = 0x80808080
	local border = 1
	local margin = (h - style.font) // 2
	geo.frame(x,y,w,h, color, border)
	geo.box(x+border,y+border,w-border*2, h-border*2, bgcolor)
	geo.scissor(x+border,y+border,w-border*2, h-border*2)
	spr.drawtext(style.title,x,y+margin,w,style.font,color)
	geo.scissor()
end

function widget.label(x,y,style)
	geo.scissor(x,y,style.width, style.height)
	spr.drawtext(style.title,x,y,style.width,style.font,0xffffffff,false,"l")	-- todo: alignment
	geo.scissor()
end

function gui.dialog(desc)
	local tree = layout.dialog(desc)
	tree:refresh()
	return setmetatable({ __layout = tree}, dialog)
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
        local children = child.parent.children
        for i, c in ipairs(children) do
            if c == child then
                table.remove(children, i)
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
