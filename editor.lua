package.cpath = "./?.dll;./?53.dll"
require "iuplua"

local drawarea = require "drawarea"
local schedule = require "schedule"
local hierarchy = require "hierarchy"
local event = require "ejoy2d.event"

local gui

-- ============================================
-- #### select element from bar and create ####
-- ============================================

local createitem = { }

function createitem:start(desc)
    local area = drawarea

    area.canvas.motion_cb = function(_, x, y, status)
        -- make sure motion in canvas to draw current created
        area.create = area.create or desc

        assert(desc == area.create)
        desc.x = x
        desc.y = y
    end

    area.canvas.button_cb = function(_, button, pressed, x, y, status)
        area.create = nil

        if pressed==0 then
            if iup.isbutton1(status) then
                local ctrl = area:additem(desc)
                area.selected = ctrl
            end

            -- default process
            schedule:next(schedule.MOVED)
        end
    end
end

function createitem:stop()
    drawarea.canvas.motion_cb = nil
    drawarea.canvas.button_cb = nil
end

-- ===============================================
-- #### select element from drawarea and move ####
-- ===============================================

local moveitem = { }

function moveitem:start()
    local area = drawarea
    local hit
    local sx, sy

    area.canvas.motion_cb = function(_, x, y, status)
        if iup.isbutton1(status) and hit then
            assert(hit==area.selected)
            hit.x = hit.x+x-sx
            hit.y = hit.y+y-sy
            sx,sy = x,y
        end
    end

    area.canvas.button_cb = function(_, button, pressed, x, y, status)
        hit = nil
        if pressed==1 and iup.isbutton1(status) then
            hit = event.test(area.dialog, x, y)
            if hit then
                area.selected = hit
                sx,sy = x,y
            end
        end
    end
end

function moveitem:stop()
    drawarea.canvas.motion_cb = nil
    drawarea.canvas.button_cb = nil
end

-- ============================================
-- ####        editor dialog create        ####
-- ============================================

local descriptor = { }

function descriptor.label()
    return {
        type="label",
        size="40x18",
        id="label",
        title="label",
        font=15,
        message=true
    }
end

function descriptor.button()
    return {
        type="button",
        size="55x20",
        id="button",
        title="button",
        font=15,
        message=true
    }
end

function descriptor.text()
    return {
        type="label",
        size="50x25",
        id="text",
        title="text",
        font=15,
        message=true
    }
end

local function onelement(element)
    local desc = descriptor[element.title]()
    schedule:next(schedule.CREATE, desc)
end

-- =====================================================
-- ######                top menu                 ######
-- =====================================================

local fileitem_open = iup.item { title="Open" }
local fileitem_save = iup.item { title="Save" }
local fileitem_exit = iup.item { title="Exit" }
local menufile = iup.menu {
    fileitem_open,
    fileitem_save,
    iup.separator {},
    fileitem_exit
}

function fileitem_open:action()
    local open = iup.filedlg {
        dialogtype="OPEN",
        filter="*.lua",
        filterinfo="lua files"
    }
    open:popup(iup.CENTER, iup.CENTER)
end

function fileitem_save:action()
end

function fileitem_exit:action()
end

-- ============================================
-- ######            dialog              ######
-- ============================================

local function frommeta(meta)
    local C = {}
    for k,v in pairs(meta) do
        if k~="children" then
            C[k] = v
        end
    end
    if meta.children then
        for k,v in ipairs(meta.children) do
            local child = frommeta(v)
            C[k] = child
        end
    end
    return gui.layout[meta.type](C)
end

local function tometa(root)
    local meta = {}
    meta.attribs = gui.attributes(root)
    meta.style = root.style
    if root.children then
        meta.children = {}
        for k,v in ipairs(root.children) do
            meta.children[k] = tometa(v)
        end
    end
    return meta
end

local dlg = iup.dialog {
	iup.vbox {
		iup.hbox {
			iup.button { size="30x10", title="label",  action=onelement },
			iup.button { size="30x10", title="text",   action=onelement },
			iup.button { size="30x10", title="button", action=onelement },
			alignment="ACENTER"
		};
		iup.hbox { hierarchy.tree, drawarea.canvas };
	},
	title="ejoy2d-editor",
    menu=iup.menu {
        iup.submenu { menufile, title="File" }
    }
}

function dlg:resize_cb(w, h)
	 drawarea:resize(w, h)
end

local function main()
    dlg:show()

    gui = require "ejoy2d.gui"

    -- todo: 1)read meta from config;
    --       2)construct hierarchy tree from meta.

    local meta --= require "meta.lua"
    meta = {
        title="canvas", type="cbox", x=0, y=0, size="500x500", x=10, y=10, font=15,
        children={
           { type="label", title="I am Jackie", size=100, x=20, y=40 }
        }
    }
    local C = frommeta(meta)
    local dialog = gui.dialog({C})
    dialog.__layout:dump()

    drawarea:start(dialog)
    hierarchy.start(drawarea) 

    schedule:attach(schedule.CREATE, createitem)
    schedule:attach(schedule.MOVED,  moveitem)
    schedule:start(schedule.MOVED)

    if (iup.MainLoopLevel()==0) then
        iup.MainLoop()
    end
end

main()
