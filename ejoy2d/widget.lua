local geo = require "ejoy2d.geometry"
local spr = require "ejoy2d.sprite.c"

local widget = {}

function widget.panel(x, y, style)
	geo.box(x, y, style.width, style.height, 0xe0404040)
end

function widget.button(x, y, style)
	local w, h = style.width, style.height
	local color = 0xffe0e0e0
	local bgcolor = 0x80808080
	local border = 1
	local margin = (h - style.font) // 2
	geo.frame(x, y, w, h, color, border)
	geo.box(x+border, y+border, w-border*2, h-border*2, bgcolor)
	geo.scissor(x+border, y+border, w-border*2, h-border*2)
	spr.drawtext(style.title, x, y+margin, w, style.font, color)
	geo.scissor()
end

function widget.label(x, y, style)
	local margin = (style.height - style.font) // 2
	geo.scissor(x, y, style.width, style.height)
	spr.drawtext(style.title, x, y + margin, style.width, style.font, 0xFFFFFFFF) -- todo: alignment
	geo.scissor()
end

function widget.hbox(x, y, style)
end

function widget.vbox(x, y, style)
end

return widget
