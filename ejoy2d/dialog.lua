local nsize = require "ejoy2d.nsize"
local spacing = require "ejoy2d.spacing"

local dialog = {}; dialog.__index = dialog

local function sortdepth(root)
    if root.container and root.children then
        local children = root.children
        if root.type == "cbox" then
            table.sort(children, function(a, b)
                local da = a.__depth or 0
				local db = b.__depth or 0
				return da>db
            end)
        end

        for _, child in ipairs(children) do
            sortdepth(child)
        end
    end
end

local function calc_nsize(root)
	local w, h = nsize[root.type](root)
	local style = root.style
	style.width = w
	style.height = h
	return w, h
end

local function calc_spacing(root)
	if root.children then
		return spacing[root.type](root)
	end
end

function dialog:refresh()
    local root = self.__dialog
    calc_nsize(root)
    calc_spacing(root)
    sortdepth(root)
    root.x = root.x or 0
    root.y = root.y or 0
end

function dialog:iterate(f)
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

    _iter(self.__dialog, 0, 0)
end

function dialog:draw()
	local function iter(root, x, y)
		x = x + root.x
		y = y + root.y
		if root.widget then
			coroutine.yield(root.type, x, y, root.style)
		end
		if root.children then
			for _,v in ipairs(root.children) do
				iter(v, x, y)
			end
		end
	end

	return coroutine.wrap(function()
		return iter(self.__dialog, 0, 0)
	end)
end

function dialog:dump()
	print("ID:")
	local temp = {}
	for k in pairs(self.__id) do
		table.insert(temp, k)
	end
	print(table.concat(temp, ","))
	local function dump_tree(root, level)
		local name
		local indent = string.rep("  ", level)
		local attrib = {}
		for k, v in pairs(root) do
			if k:sub(1,2) == "__" then
				table.insert(attrib, string.format("%s:%s", k:sub(3), v))
			end
		end
		local function attribs()
			return table.concat(attrib, ", "),
				root.x, root.y,
				root.style.width,
				root.style.height
		end
		if root.style.id then
			name = string.format("%s%s(%s) %s (%d:%d-%dx%d)", indent,root.type, root.style.id, attribs())
		else
			name = string.format("%s%s %s (%d:%d-%dx%d)", indent,root.type, attribs())
		end
		print(name)
		if root.children then
			level = level + 1
			for _, v in ipairs(root.children) do
				dump_tree(v, level)
			end
		end
	end
	dump_tree(self.__dialog,0)
end

return dialog
