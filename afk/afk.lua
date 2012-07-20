AfkModule = {}

local Panel = {}

local Events = {
  creatureAlertEvent
}

local parent

local uiCreatureList

local CreatureListModule

function AfkModule.init(_parent)
  parent = _parent
  Panel = g_ui.loadUI('afk.otui')
  g_sounds.preload('alert.ogg')

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
  if key == 'CreatureAlert' then
    removeEvent(Events.creatureAlertEvent)
    if status then
      Events.creatureAlertEvent = addEvent(AfkModule.creatureAlert)
    end
  end
end

function AfkModule.creatureAlert()
  local blackList = CreatureListModule.getBlackList()
  local whiteList = CreatureListModule.getWhiteList()

  local player = g_game.getLocalPlayer()
  local creatures = {}

  local alert = false

  creatures = g_map.getSpectators(player:getPosition(), false)

  if not player then
    return
  end

  if CreatureListModule.getBlackOrWhite() then -- black
    for k, v in pairs (creatures) do
      if v ~= player and CreatureListModule.isBlackListed(v:asCreature():getName()) then
        alert = true
      end
    end
  else -- white
    for k, v in pairs (creatures) do
      if v ~= player and not CreatureListModule.isWhiteListed(v:asCreature():getName()) then
        alert = true
      end
    end
  end

  if alert then
    AfkModule.alert()
  else
    AfkModule.stopAlert()
  end

  creatureAlertEvent = scheduleEvent(AfkModule.creatureAlert, 200)
end

function AfkModule.alert()
  g_sounds.playMusic('alert.ogg', 0)
end

function AfkModule.stopAlert()
  g_sounds.stopMusic(0)
end

function AfkModule.creatureListDialog()
  if g_game.isOnline() then
    CreatureListModule:toggle()
    CreatureListModule:focus()
  end
end

return AfkModule

--g_game.talk(spellText)