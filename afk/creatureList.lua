CreatureList = extends(UIWidget)

local creatureListWindow

local parent

function CreatureList.init(_parent)
  parent = _parent
  creatureListWindow = g_ui.loadUI('creatureList.otui', parent.getParent())

  creatureListWindow:setVisible(false)
end

function CreatureList.terminate()
  creatureListWindow:destroy()
  creatureListWindow = nil
end

function CreatureList.toggle()
  if creatureListWindow:isVisible() then
    CreatureList.hide()
  else
    CreatureList.show()
    creatureListWindow:focus()
  end
end

function CreatureList.show()
  if g_game.isOnline() then
    creatureListWindow:show()
    parent.getUi():setEnabled(false)
  end
end

function CreatureList.hide()
  creatureListWindow:hide()
  parent.getUi():setEnabled(true)
end

return CreatureList