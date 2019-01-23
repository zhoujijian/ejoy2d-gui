require "iuplua"
require "iupluagl"
local ejoy2d
local core
local shader
local sprite
local geometry
local gui
local bigmap

-- =========================================
-- ####           iup canvas            ####
-- =========================================

local VW, VH = 1200, 900
local canvas = iup.glcanvas { buffer="DOUBLE", rastersize="1200x900" }

function canvas:map_cb()
    iup.GLMakeCurrent(self)
    
    core   = require "ejoy2d.core"
    ejoy2d = require "ejoy2d"
    shader = require "ejoy2d.shader"
    sprite = require "ejoy2d.sprite.c"
    geometry = require "ejoy2d.geometry"
    gui = require "ejoy2d.gui"
	bigmap = require "game.bigmap"

    core.viewport(VW, VH)
end

-- ==========================================
-- ####            draw area             ####
-- ==========================================

local drawarea = { canvas=canvas }

function drawarea:start(dialog)
    local timer = iup.timer {
        time=30,
        run="YES",
        action_cb = function()
            self:draw()
        end
    }
    timer.run = "YES"

    self.dialog = dialog
    self.gui = gui
end

function drawarea:additem(desc)
    local cbox = self.dialog:root_container()
    desc.x = desc.x-cbox.x
    desc.y = desc.y-cbox.y

    local ctrl = gui.layout[desc.type](desc)
    table.insert(cbox.children, ctrl)
    ctrl.parent = cbox
    self.dialog.__layout:refresh()
    self.dialog.__layout:dump()

    return ctrl
end

function drawarea:draw()
    core.beginframe()
    ejoy2d.clear(0xff808080)

--  self:_drawcreate()
--  self:_drawselected()
    self:_drawdialog()
	bigmap.drawframe()

    core.endframe()
    iup.GLSwapBuffers(canvas)
end

function drawarea:resize(w, h)
    core.viewport(w, h)
end

function drawarea:_drawdialog()
    self.dialog:draw(0, 0)
    self.dialog.__layout:iterate(function(root, x, y)
        geometry.frame(x, y, root.style.width, root.style.height, 0xFFFFFFFF, 1)
    end)
end

function drawarea:_drawcreate()
    local c = self.create
    if c then
        local w, h = c.size:match "(%d*)x(%d*)"
        w = tonumber(w)
        h = tonumber(h)
		geometry.frame(c.x, c.y, w, h, 0xffe0e0e0, 1)
        sprite.drawtext(c.title, c.x, c.y, w, c.font, 0xffe0e0e0)
	end
end

function drawarea:_drawselected()
    local s = self.selected
    if s then
        local x,y = s.x,s.y
        local p = s.parent
        while(p) do
            x = x+p.x
            y = y+p.y
            p = p.parent
        end
        geometry.frame(x, y, s.style.width, s.style.height, 0xFF40, 1)
    end
end

return drawarea
