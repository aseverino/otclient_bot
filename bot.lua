Bot = extends(UIWidget)
Bot.options = {}

dofile('consts.lua')
Bot.defaultOptions = options

local botWindow
local botButton

local botTabBar

local pnProtection
local pnAfk

local ProtectionModule
local AfkModule

function Bot.init()
  botWindow = g_ui.displayUI('bot.otui')
  botWindow:setVisible(false)

  botButton = TopMenu.addRightGameToggleButton('botButton', 'Bot (Ctrl+Shift+B)', '/kilouco_bot/bot.png', Bot.toggle)
  g_keyboard.bindKeyDown('Ctrl+Shift+B', Bot.toggle)

  botTabBar = botWindow:getChildById('botTabBar')
  botTabBar:setContentWidget(botWindow:getChildById('botTabContent'))

  ProtectionModule = dofile('protection/protection.lua')
  pnProtection = ProtectionModule.init(Bot)
  botTabBar:addTab(tr('Protection'), pnProtection)

  AfkModule = dofile('afk/afk.lua')
  pnAfk = AfkModule.init(Bot)
  botTabBar:addTab(tr('AFK'), pnAfk)

  connect(g_game, { onGameStart = Bot.online,
    onGameEnd = Bot.offline})

  Bot.options = g_settings.getNode('Bot') or {}
  
  if g_game.isOnline() then
    Bot.online()
  end
end

function Bot.terminate()
  Bot.hide()
  disconnect(g_game, { onGameStart = Bot.online,
  onGameEnd = Bot.offline})

  if g_game.isOnline() then
    Bot.offline()
  end

  g_keyboard.unbindKeyDown('Ctrl+Shift+B')

  ProtectionModule.terminate()
  AfkModule.terminate()

  botButton:destroy()
  botButton = nil

  g_settings.setNode('Bot', Bot.options)

  -- botWindow:destroy() -- was destroying twice (gotta take a look at this).
end

function Bot.online()
  addEvent(Bot.loadOptions)
end

function Bot.offline()
  ProtectionModule.removeEvents()
  AfkModule.removeEvents()
  -- do not remove autoReconnectEvent since it must be running even on offline state
end

function Bot.toggle()
  if botWindow:isVisible() then
    Bot.hide()
  else
    Bot.show()
    botWindow:focus()
  end
end

function Bot.show()
  if g_game.isOnline() then
    botWindow:show()
  end
end

function Bot.hide()
  botWindow:hide()
end

function Bot.getUi()
  return botWindow
end

function Bot.getParent()
  return botWindow:getParent()
end

function Bot.changeOption(key, status, loading)
  loading = loading or false
  
  if Bot.defaultOptions[key] == nil then
    Bot.options[key] = nil
    return
  end

  if g_game.isOnline() then
    ProtectionModule.setEvents(key, status, Loading)
    AfkModule.setEvents(key, status, Loading)

    local tab

    if loading then

      if pnProtection:getChildById(key) ~= nil then
        tab = pnProtection
      elseif pnAfk:getChildById(key) ~= nil then
        tab = pnAfk
      elseif pnAfk.getCreatureListUI().getChildById(key) ~= nil then
        tab = pnAfk.getCreatureListUI()
      end

      local widget = tab:getChildById(key)

      if not widget then
        return
      end

      local style = widget:getStyle().__class
      
      -- g_game.talk(style)

      if style == 'UITextEdit' or style == 'UIComboBox' then
        tab:getChildById(key):setText(status)
      elseif style == 'UICheckBox' then
        tab:getChildById(key):setChecked(status)
      elseif style == 'UIItem' then
        tab:getChildById(key):setItemId(status)
      end
    end

    if Bot.options[g_game.getCharacterName()] == nil then
      Bot.options[g_game.getCharacterName()] = {}
    end

    Bot.options[g_game.getCharacterName()][key] = status
  end
end

function Bot.loadOptions()
  if Bot.options[g_game.getCharacterName()] ~= nil then
    for i, v in pairs(Bot.options[g_game.getCharacterName()]) do
      addEvent(function() Bot.changeOption(i, v, true) end)
    end
  else
    for i, v in pairs(Bot.defaultOptions) do
      addEvent(function() Bot.changeOption(i, v, true) end)
    end
  end
end