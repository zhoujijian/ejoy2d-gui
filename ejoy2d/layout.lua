local nsize = require "ejoy2d.nsize"
local spacing = require "ejoy2d.spacing"
local dialog = require "ejoy2d.dialog"
local layout = {}

local function collect_id(root)
	local id = {}
	local function collect(obj)
		local name = obj.style.id
		if name then
			if id[name] then
				error ("Duplicate id : " .. name)
			end
			id[name] = obj
		end
		if obj.children then
			for _,v in ipairs(obj.children) do
				collect(v)
			end
		end
	end
	collect(root)
	return id
end

local function copy_children(from, to)
	local children = to.children
	for k, v in ipairs(from) do
		assert(v.type)
		children[k] = v
		v.parent = to
	end
end

local function copy_attrib(from, to, attrib, ...)
	if attrib then
		to["__" .. attrib] = from[attrib]
		return copy_attrib(from, to, ...)
	end
end

local function attribs()
	return "font", "margin", "gap", "size", "expand", "depth"
end

local function copy_style(from, to, s, ...)
	if s then
		to[s] = from[s]
		return copy_style(from, to, ...)
	else
		return to
	end
end

local function copy_styles(C, ...)
	return copy_style(C, {}, ...)
end

local function copyxy(C, obj)
    obj.x = C.x
    obj.y = C.y
end

function layout.panel(C)
	assert(C[1].type)
	local obj = { type="panel", children={ C[1] }, widget=true, container=true, style=copy_styles(C, "id") }
	C[1].parent = obj
    copyxy(C, obj)
	copy_attrib(C, obj, attribs(), "message")
	return obj
end

function layout.button(C)
	local obj = { type="button", widget=true, style=copy_styles(C, "id", "title") }
    copyxy(C, obj)
	copy_attrib(C, obj, "font", "size", "expand", "depth", "message")
	return obj
end

function layout.label(C)
	local obj = { type="label", widget=true, style=copy_styles(C, "id", "title") }
    copyxy(C, obj)
	copy_attrib(C, obj, "font", "size", "expand", "depth", "message")
	return obj
end

function layout.fill(C)
	return { type = "fill", container = true, style = {} }
end

function layout.hbox(C)
	local obj = { type="hbox", children={}, container=true, style={} }
    copyxy(C, obj)
	copy_children(C, obj)
	copy_attrib(C, obj, attribs())
	return obj
end

function layout.vbox(C)
	local obj = { type="vbox", children={}, container=true, style = {} }
    copyxy(C, obj)
	copy_children(C, obj)
	copy_attrib(C, obj, attribs())
	return obj
end

function layout.cbox(C)
	local box = { type="cbox", children={}, container=true, style={} }
    copyxy(C, box)
	copy_children(C, box)
	copy_attrib(C, box, attribs())
	return box
end

function layout.dialog(C)
    -- local root = layout.cbox(C)
    local root = C[1]
	return setmetatable ({
		__id = collect_id(root),
		__dialog = root
	}, dialog)
end

return layout
