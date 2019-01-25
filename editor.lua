package.cpath = "./?.dll;./?53.dll"
require "iuplua"

local drawarea = require "drawarea"
local schedule = require "schedule"
local hierarchy = require "hierarchy"
local event = require "ejoy2d.event"

local gui
local bigmap

-- get iup error stack message
function iup._TRACEBACK(errmsg)
	print(errmsg)
end

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

	-- button: IUP_BUTTON1(mouse left) | IUP_BUTTON2(mouse middle) | IUP_BUTTON3(mouse right)
	-- pressed: 0 - mouse button was released;
	--          1 - mouse button was pressed.
    area.canvas.button_cb = function(_, button, pressed, x, y, status)
		print("button press event")
		if pressed == 0 and iup.isbutton1(status) then
			bigmap.touch("END", x, y)
		end
	--[[
		area.create = nil

        if pressed==0 then
            if iup.isbutton1(status) then
                local ctrl = area:additem(desc)
                area.selected = ctrl
            end

            -- default process
            schedule:next(schedule.MOVED)
        end
	]]
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

	-- button: IUP_BUTTON1(mouse left) | IUP_BUTTON2(mouse middle) | IUP_BUTTON3(mouse right)
	-- pressed: 0 - mouse button was released;
	--          1 - mouse button was pressed.
    area.canvas.button_cb = function(_, button, pressed, x, y, status)
		if pressed == 0 and iup.isbutton1(status) then
			bigmap.click(x, y)
		end
    end

--[[	
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
]]
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

local dlg = iup.dialog {
--[[
	iup.vbox {
		iup.hbox {
			iup.button { size="30x10", title="label",  action=onelement },
			iup.button { size="30x10", title="text",   action=onelement },
			iup.button { size="30x10", title="button", action=onelement },
			alignment="ACENTER"
		};
		iup.hbox { hierarchy.tree, drawarea.canvas };
	},
]]
	drawarea.canvas,
	title="ejoy2d-editor",
    menu=iup.menu {
        iup.submenu { menufile, title="File" }
    }
}

function dlg:resize_cb(w, h)
	 drawarea:resize(w, h)
end

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

local function main()
    dlg:show()
    gui = require "ejoy2d.gui"
	bigmap = require "game.bigmap"

--[[
    local meta
    meta = {
        -- title="canvas", type="cbox", size="400x500", x=10, y=10, font=30,
        title="canvas", type="vbox", x=10, y=10, font=20,		
        children={
            { type="button", x=30, y=40, size="100x30", font=15, title="IamJack" }
        }
    }
]]

	local cbox = gui.layout.cbox {
		x=0,
		y=0,
		font=20,
		size="1200x900", -- see [VW, VH] in drawarea
		title="canvas"
	}

    local dialog = gui.dialog { cbox }
    dialog.__layout:dump()
	bigmap.init(dialog)
	
    drawarea:start(dialog)
    -- hierarchy.start(drawarea)

    schedule:attach(schedule.CREATE, createitem)
    schedule:attach(schedule.MOVED,  moveitem)
    schedule:start(schedule.MOVED)
	
	assert(iup.MainLoopLevel() == 0)
	iup.MainLoop()
	iup.Close()
end

main()
