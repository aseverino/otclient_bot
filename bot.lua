Bot = extends(UIWidget)
Bot.options = {}

dofile('consts.lua')
Bot.defaultOptions = options

local botWindow
local botButton

local botTabBar
local pnProtection

local ProtectionModule

function Bot.init()
  botWindow = g_ui.displayUI('bot.otui')
  botWindow:setVisible(false)

  botButton = TopMenu.addGameButton('botButton', 'Bot (Ctrl+Shift+B)', '/kilouco_bot/bot.png', Bot.toggle)
  g_keyboard.bindKeyDown('Ctrl+Shift+B', Bot.toggle)

  connect(g_game, { onGameStart = Bot.online,
    onGameEnd = Bot.offline})

  Bot.options = g_settings.getNode('Bot') or {}
  
  if g_game.isOnline() then
    Bot.online()
  end

  botTabBar = botWindow:getChildById('botTabBar')
  botTabBar:setContentWidget(botWindow:getChildById('botTabContent'))

  ProtectionModule = dofile('protection/protection.lua')
  pnProtection = ProtectionModule.init()
  botTabBar:addTab(tr('Protection'), pnProtection)
end

function Bot.terminate()
  disconnect(g_game, { onGameStart = Bot.online,
  onGameEnd = Bot.offline})

  if g_game.isOnline() then
    Bot.offline()
  end

  g_keyboard.unbindKeyDown('Ctrl+Shift+B')

  botWindow:destroy()
  botButton:destroy()
  botWindow = nil
  botButton = nil

  ProtectionModule.terminate()

  g_settings.setNode('Bot', Bot.options)
end

function Bot.online()
  addEvent(Bot.loadOptions)
end

function Bot.offline()
  removeEvent(autoHealEvent)
  removeEvent(autoHealthItemEvent)
  removeEvent(autoManaItemEvent)
  removeEvent(autoHasteEvent)
  removeEvent(autoParalyzeHealEvent)
  removeEvent(autoManaShieldEvent)
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

function Bot.changeOption(key, status, loading)
  loading = loading or false

  if Bot.defaultOptions[key] == nil then
    Bot.options[key] = nil
    return
  end

  if g_game.isOnline() then
    ProtectionModule.setEvents(key, status, Loading)

    -- g_game.talk(key)

    local tab

    if loading then

      if pnProtection:getChildById(key) ~= nil then
        tab = pnProtection
      else
        tab = nil
      end

      local widget = tab:getChildById(key)

      if not widget then
        return
      end

      local style = widget:getStyle().__class
      
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