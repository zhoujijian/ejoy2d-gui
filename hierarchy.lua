require "iuplua"
local draw

-- #### menu item ####
local menuitem_add = iup.item { title="add" }
local menuitem_del = iup.item { title="del" }
local contextmenu = iup.menu {
	menuitem_add,
	menuitem_del
}

-- #### tree ####
local tree = iup.tree { name="root", size="150x200", showdragdrop="YES" }

function tree:_find(id)
    local ud = self["userdata"..id]
    local child = guid.find(draw.dialog, ud.guid)
    assert(child, "node"..id)
    return child
end

function tree:_addchild(parentid, childid)
    local parent = self:_find(parentid)
    local child  = self:_find(childid)
    gui.mount(parent, child)
    draw.dialog.__layout:refresh()

    self["movenode"..childid] = parentid
end

function tree:rightclick_cb(id)
    tree.value = id
    contextmenu:popup(iup.MOUSEPOS,iup.MOUSEPOS)
end

function tree:selection_cb(id, status)
    local c = self:_find(id)
    -- todo: 1)display attribute according to element kind
end

function tree:dragdrop_cb(dragid, dropid, isshift, isctrl)
    local parentid = (isctrl and self["parent"..dropid]) or dropid
    self:_addchild(parentid, dragid)
end

-- #### hierarchy ####
local i = 0
local hierarchy = { tree=tree }

local function nextid()
    i = i+1
    return i
end

local function setid(root)
    draw.gui.iterate(root, function(rt)
        root.__guid = nextid()
    end)
end

local function nodeinfo(root)
    local node = { guid=root.__guid }
    if root.children then
        node.branchname = root.name or "XXX"
        for k, child in ipairs(root.children) do
            node[k] = nodeinfo(child)
        end
    else
        node.leafname = root.name or "YYY"
    end
    return node
end

function hierarchy.start(drawarea)
    draw = drawarea

    -- must after (dlg:show), otherwise it would not work
    tree.addexpanded = "YES"
--[[
    tree.addbranch = "panel0"
    tree.addbranch = "panel1"
    tree.addleaf1 = "panel1-leaf"
]]

    local root = draw.dialog:root_container()
    setid(root)
    local info = nodeinfo(root)
    tree:AddNodes(info)
end

return hierarchy
