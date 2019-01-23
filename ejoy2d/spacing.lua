local spacing = {}	-- spacing functions

local function get_attrib(root, attrib)
	if root then
		if root[attrib] ~= nil then
			return root[attrib]
		else
			return get_attrib(root.parent, attrib)
		end
	end
end

local function expand(root)
	if root.container then
		return get_attrib(root, "__expand") or true
	else
		return root.__expand
	end
end

local function calc_spacing(root)
	if root.children then
		return spacing[root.type](root)
	end
end

function spacing.panel(root)
	local c = root.children[1]
	local margin = get_attrib(root, "__margin") or 0
	local style = c.style
	local root_style = root.style
	if expand(c) then
		style.width = root_style.width - margin * 2
		style.height = root_style.height - margin * 2
	end
	c.x = margin
	c.y = margin
	return calc_spacing(c)
end

local function child_expand(c, e)
	if c.container then
		return e
	else
		return c.__expand
	end
end

function spacing.hbox(root)
	local c = root.children
	local n = #c
	local expand_n = 0
	local e = expand(root)
	local w = 0
	local height = root.style.height
	for i=1,n do
		local child = c[i]
		if child_expand(child, e) then
			expand_n = expand_n + 1
		end
		w = w + child.style.width
	end
	local gap = get_attrib(root, "__gap") or 0
	if expand_n > 0 then
		local spacing = root.style.width - w - gap * (n-1)
		for i=1,n do
			local child = c[i]
			if child_expand(child, e) then
				local expand_spacing = spacing // expand_n
				spacing = spacing - expand_spacing
				expand_n = expand_n - 1
				local style = child.style
				style.width = style.width + expand_spacing
				style.height = height
			end
		end
	end
	w = 0
	for i=1, n do
		local child = c[i]
		local style = child.style
		child.x = w
		child.y = 0
		calc_spacing(child)
		w = w + style.width + gap
	end
end

function spacing.vbox(root)
	local c = root.children
	local n = #c
	local expand_n = 0
	local e = expand(root)
	local h = 0
	local width = root.style.width
	for i=1,n do
		local child = c[i]
		if child_expand(child, e) then
			expand_n = expand_n + 1
		end
		h = h + child.style.height
	end
	local gap = get_attrib(root, "__gap") or 0
	if expand_n > 0 then
		local spacing = root.style.height - h - gap * (n-1)
		for i=1,n do
			local child = c[i]
			if child_expand(child, e) then
				local expand_spacing = spacing // expand_n
				spacing = spacing - expand_spacing
				expand_n = expand_n - 1
				local style = child.style
				style.height = style.height + expand_spacing
				style.width = width
			end
		end
	end
	h = 0
	for i=1, n do
        local child = c[i]
        local style = child.style
        child.x = 0
        child.y = h
        calc_spacing(child)
        h = h + style.height + gap
	end
end

function spacing.cbox(root)
    for _, child in ipairs(root.children) do
        calc_spacing(child)
    end
end

return spacing
