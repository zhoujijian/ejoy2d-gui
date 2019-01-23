local nsize = {}	-- natural size functions

local DEFAULT_FONT = 20
local BUTTON_MARGIN = 6
local LABEL_MARGIN = 4

local function get_size(size)
	if size then
		local x, y = tostring(size):match "(%d*)x?(%d*)"
		if not x then
			error( "Invalid size " .. size)
		end
		x = (x == "") and 0 or (tonumber(x))
		y = (y == "") and 0 or (tonumber(y))
		return x,y
	end
	return 0, 0
end

local function get_attrib(root, attrib)
	if root then
		if root[attrib] ~= nil then
			return root[attrib]
		else
			return get_attrib(root.parent, attrib)
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

function nsize.panel(root)
	local ux,uy = get_size(root.__size)
	local margin = get_attrib(root, "__margin") or 0
	margin = margin * 2
	local nx,ny = calc_nsize(root.children[1])
	nx = nx + margin
	ny = ny + margin
	ux = (ux > nx) and ux or nx
	uy = (uy > ny) and uy or ny
	return ux , uy
end

function nsize.fill(root)
	return 0,0
end

function nsize.button(root)
	local ux,uy = get_size(root.__size)
	local font = get_attrib(root, "__font") or DEFAULT_FONT
	root.style.font = font
	if uy == 0 then
		uy = font
		uy = uy + BUTTON_MARGIN
	end
	return ux, uy
end

function nsize.label(root)
	local ux,uy = get_size(root.__size)
	local font = get_attrib(root, "__font") or DEFAULT_FONT
	root.style.font = font
	if uy == 0 then
		uy = font
		uy = uy + LABEL_MARGIN
	end
	return ux, uy
end

function nsize.hbox(root)
	local ux, uy = get_size(root.__size)
	local c = root.children
	local n = #c
	local nx = 0
	local ny = 0
	for i=1,n do
		local w,h = calc_nsize(c[i])
		nx = nx + w
		if h > ny then
			ny = h
		end
	end
	if n > 1 then
		nx = nx + (get_attrib(root, "__gap") or 0) * (n-1)
	end
	ux = (ux > nx) and ux or nx
	uy = (uy > ny) and uy or ny
	return ux, uy
end

function nsize.vbox(root)
	local ux, uy = get_size(root.__size)
	local c = root.children
	local n = #c
	local nx = 0
	local ny = 0
	for i=1,n do
		local w,h = calc_nsize(c[i])
		ny = ny + h
		if w > nx then
			nx = w
		end
	end
	if n > 1 then
		ny = ny + (get_attrib(root, "__gap") or 0) * (n-1)
	end
	ux = (ux > nx) and ux or nx
	uy = (uy > ny) and uy or ny
	return ux, uy
end

function nsize.cbox(root)
	local ux, uy = get_size(root.__size)
	local c = root.children
	local n = #c
    local nx = 0
    local ny = 0

    if n > 0 then
        local w, h = calc_nsize(c[1])
        nx = c[1].x+w
        ny = c[1].y+h
        for i=2,n do
            w, h = calc_nsize(c[i])
            if nx < c[i].x+w then nx = c[i].x+w end
            if ny < c[i].y+h then ny = c[i].y+h end
        end
    end

	ux = (ux > nx) and ux or nx
	uy = (uy > ny) and uy or ny
	return ux, uy
end

return nsize
