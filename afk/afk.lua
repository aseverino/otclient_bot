AfkModule = {}

local Panel = {}

local Events = {
  autoHealEvent,
  autoHealthItemEvent,
  autoManaItemEvent,
  autoHasteEvent,
  autoParalyzeHealEvent
}

local parent

local uiCreatureList

local CreatureListModule

function AfkModule.init(_parent)
  parent = _parent
  Panel = g_ui.loadUI('afk.otui')

  CreatureListModule = dofile('creatureList.lua')
  uiCreatureList = CreatureListModule.init(parent)

  return Panel
end

function AfkModule.terminate()
  CreatureListModule.terminate()

  Panel:destroy()
  Panel = nil
end

function AfkModule.setEvents(key, status, loading)
  
end

function AfkModule.creatureListDialog()
  if g_game.isOnline() then
    CreatureListModule:toggle()
    CreatureListModule:focus()
  end
end

function AfkModule.autoHealthItem()
  if g_game.isOnline() then

      local item = Panel:getChildById('CurrentHealthItem'):getItem()
      local potion = item:getId()
      local count = item:getCount()

      local healthText = Panel:getChildById('ItemHealthText'):getText():match('(%d+)%%')
      local percent = healthText and true or false
      local healthText = healthText or tonumber(Panel:getChildById('ItemHealthText'):getText())

    if healthText ~= nil then
      if percent then
        if (g_game.getLocalPlayer():getHealth()/g_game.getLocalPlayer():getMaxHealth())*100 < tonumber(healthText) then
          g_game.useInventoryItemWith(potion, g_game.getLocalPlayer())
        end
      else
        if g_game.getLocalPlayer():getHealth() < healthText then
          g_game.useInventoryItemWith(potion, g_game.getLocalPlayer())
        end
      end
    
      Events.autoHealthItemEvent = scheduleEvent(AfkModule.autoHealthItem, 100)
    else
      Panel:getChildById('AutoHealthItem'):setChecked(false)
    end
  else
    Events.autoHealthItemEvent = scheduleEvent(AfkModule.autoHealthItem, 100)
  end
end

function AfkModule.autoManaItem()
  if g_game.isOnline() then

      local item = Panel:getChildById('CurrentManaItem'):getItem()
      local potion = item:getId()
      local count = item:getCount()

      local manaText = Panel:getChildById('ItemManaText'):getText():match('(%d+)%%')
      local percent = manaText and true or false
      local manaText = manaText or tonumber(Panel:getChildById('ItemManaText'):getText())

    if manaText ~= nil then
      if percent then
        if (g_game.getLocalPlayer():getMana()/g_game.getLocalPlayer():getMaxMana())*100 < tonumber(manaText) then
          g_game.useInventoryItemWith(potion, g_game.getLocalPlayer())
        end
      else
        if g_game.getLocalPlayer():getMana() < manaText then
          g_game.useInventoryItemWith(potion, g_game.getLocalPlayer())
        end
      end
      
      Events.autoHealthItemEvent = scheduleEvent(AfkModule.autoManaItem, 100)
    else
      Panel:getChildById('AutoManaItem'):setChecked(false)
    end
  else
    Events.autoHealthItemEvent = scheduleEvent(AfkModule.autoManaItem, 100)
  end
end

function AfkModule.startChooseHealthItem()
  local mouseGrabberWidget = g_ui.createWidget('UIWidget')
  mouseGrabberWidget:setVisible(false)
  mouseGrabberWidget:setFocusable(false)

  connect(mouseGrabberWidget, { onMouseRelease = AfkModule.onChooseHealthItemMouseRelease })
  
  mouseGrabberWidget:grabMouse()
  g_mouse.setTargetCursor()

  hide()
end

function AfkModule.onChooseHealthItemMouseRelease(self, mousePosition, mouseButton)
  local item = nil
  
  if mouseButton == MouseLeftButton then
  
    local clickedWidget = GameInterface.getRootPanel():recursiveGetChildByPos(mousePosition, false)
  
    if clickedWidget then
      if clickedWidget:getClassName() == 'UIMap' then
        local tile = clickedWidget:getTile(mousePosition)
        
        if tile then
          local thing = tile:getTopMoveThing()
          if thing then
            item = thing:asItem()
          end
        end
        
      elseif clickedWidget:getClassName() == 'UIItem' and not clickedWidget:isVirtual() then
        item = clickedWidget:getItem()
      end
    end
  end

  if item then
    CurrentHealthItem:setItemId(item:getId())
    changeOption('CurrentHealthItem', item:getId())
    show()
  end

  g_mouse.restoreCursor()
  self:ungrabMouse()
  self:destroy()
end

function AfkModule.startChooseManaItem()
  local mouseGrabberWidget = g_ui.createWidget('UIWidget')
  mouseGrabberWidget:setVisible(false)
  mouseGrabberWidget:setFocusable(false)

  connect(mouseGrabberWidget, { onMouseRelease = AfkModule.onChooseManaItemMouseRelease })
  
  mouseGrabberWidget:grabMouse()
  g_mouse.setTargetCursor()

  hide()
end

function AfkModule.onChooseManaItemMouseRelease(self, mousePosition, mouseButton)
  local item = nil
  
  if mouseButton == MouseLeftButton then
  
    local clickedWidget = GameInterface.getRootPanel():recursiveGetChildByPos(mousePosition, false)
  
    if clickedWidget then
      if clickedWidget:getClassName() == 'UIMap' then
        local tile = clickedWidget:getTile(mousePosition)
        
        if tile then
          local thing = tile:getTopMoveThing()
          if thing then
            item = thing:asItem()
          end
        end
        
      elseif clickedWidget:getClassName() == 'UIItem' and not clickedWidget:isVirtual() then
        item = clickedWidget:getItem()
      end
    end
  end

  if item then
    CurrentHealthItem:setItemId(item:getId())
    changeOption('CurrentManaItem', item:getId())
    show()
  end

  g_mouse.restoreCursor()
  self:ungrabMouse()
  self:destroy()
end

function AfkModule.autoHaste()
  if g_game.isOnline() then

    local spellText = Panel:getChildById('HasteSpellText'):getText()
    local hasteText = Panel:getChildById('HasteText'):getText():match('(%d+)%%')
    local percent = hasteText and true or false
    local hasteText = hasteText or tonumber(Panel:getChildById('HasteText'):getText())
    
    if hasteText ~= nil then
      if percent then
        if (g_game.getLocalPlayer():getHealth()/g_game.getLocalPlayer():getMaxHealth())*100 < tonumber(hasteText) then
          Events.autoHasteEvent = scheduleEvent(AfkModule.autoHaste, 100)
          return
        end
      else
        if g_game.getLocalPlayer():getHealth() < hasteText then
          Events.autoHasteEvent = scheduleEvent(AfkModule.autoHaste, 100)
          return
        end
      end
    end

    if not AfkModule.hasState(64) then
      g_game.talk(spellText)
    end
  end

  Events.autoHasteEvent = scheduleEvent(AfkModule.autoHaste, 100)
end

function AfkModule.autoParalyzeHeal()
  if g_game.isOnline() then

    local spellText = Panel:getChildById('ParalyzeHealText'):getText()
    
    if AfkModule.hasState(32) then
      g_game.talk(spellText)
    end
  end
  
  Events.autoParalyzeHealEvent = scheduleEvent(AfkModule.autoParalyzeHeal, 100)
end

function AfkModule.autoManaShield()
  if g_game.isOnline() and not AfkModule.hasState(16) then
    g_game.talk('utamo vita')
  end

  Events.autoParalyzeHealEvent = scheduleEvent(AfkModule.autoParalyzeHeal, 100)
end

function AfkModule.hasState(_state)

  local localPlayer = g_game.getLocalPlayer()
  local states = localPlayer:getStates()

  for i = 1, 32 do
    local pow = math.pow(2, i-1)
    if pow > states then break end
    
    local states = bit32.band(states, pow)
    if states == _state then
      return true
    end
  end

  return false
end

return AfkModule

--g_game.talk(spellText)