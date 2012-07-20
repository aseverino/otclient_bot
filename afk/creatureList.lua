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

function CreatureList.addBlack()
  local text = creatureListWindow:getChildById('TextField'):getText()
  local list = creatureListWindow:getChildById('BlackList')

  local item = g_ui.createWidget('ListRow', list)
  item:setText(text)
end

function CreatureList.addWhite()
  local text = creatureListWindow:getChildById('TextField'):getText()
  local list = creatureListWindow:getChildById('WhiteList')

  local item = g_ui.createWidget('ListRow', list)
  item:setText(text)
end

function CreatureList.remBlack()
  local selected = creatureListWindow:getChildById('BlackList'):getFocusedChild()

  if selected then
    selected:destroy()
    selected = nil
  end
end

function CreatureList.remWhite()
  local selected = creatureListWindow:getChildById('WhiteList'):getFocusedChild()

  if selected then
    selected:destroy()
    selected = nil
  end
end

return CreatureList