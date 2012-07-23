AfkModule = {}

local Panel = {}

local Events = {
  creatureAlertEvent,
  autoEatEvent,
  antiKickEvent,
  autoFishingEvent
}

local parent

local uiCreatureList

local CreatureListModule = {}

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
  elseif key == 'AutoEat' then
    removeEvent(Events.autoEatEvent)
    if status then
      Events.autoEatEvent = addEvent(AfkModule.autoEat)
    end
  elseif key == 'AntiKick' then
    removeEvent(Events.antiKickEvent)
    if status then
      Events.antiKickEvent = addEvent(AfkModule.antiKick)
    end
  elseif key == 'AutoFishing' then
    removeEvent(Events.autoFishingEvent)
    if status then
      Events.autoFishingEvent = addEvent(AfkModule.autoFishing)
    end   
  end
end

function AfkModule.removeEvents()
  removeEvent(Events.creatureAlertEvent)
  removeEvent(Events.autoEatEvent)
  removeEvent(Events.antiKickEvent)
  removeEvent(Events.autoFishingEvent)
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

  Events.creatureAlertEvent = scheduleEvent(AfkModule.creatureAlert, 200)
end

function AfkModule.autoEat()
  if g_game.isOnline() then
    local food = foods[Panel:getChildById('AutoEatSelect'):getText()]
    for i, container in pairs(g_game.getContainers()) do
      for _i, item in pairs(container:getItems()) do
        if item:getId() == food then
          g_game.useInventoryItem(food)
        end
      end
    end
  end
  Events.autoEatEvent = scheduleEvent(AfkModule.autoEat, 15000)
end

function AfkModule.antiKick()
  if g_game.isOnline() then
    local direction = g_game.getLocalPlayer():getDirection()
    direction = direction + 1
    if direction > 3 then
      direction = 0
    end

    g_game.turn(direction)
  end

  Events.antiKickEvent = scheduleEvent(AfkModule.antiKick, 5000)
end

function AfkModule.autoFishing()
  if g_game.isOnline() then
    local player = g_game.getLocalPlayer()
    local tiles = AfkModule.getTileArray()
    local waterTiles = {}
    local j = 1

    for i = 1, 165 do
      if tiles[i]:getThing():getId() == 4599 then
        table.insert(waterTiles, j, tiles[i])
        j = j + 1
      end
    end

    rdm = math.random(1, #waterTiles)

    g_game.useInventoryItemWith(fishing['fishing rod'], waterTiles[rdm]:getThing())
  end
  Events.autoFishingEvent = scheduleEvent(AfkModule.autoFishing, 2000)
end

function AfkModule.getTileArray()
  local tiles = {}

  local player = g_game.getLocalPlayer()

  if player == nil then
    return nil
  end

  local firstTile = player:getPosition()
  firstTile.x = firstTile.x - 7
  firstTile.y = firstTile.y - 5

  for i = 1, 165 do
    local position = player:getPosition()
    position.x = firstTile.x + (i % 15)
    position.y = math.floor(firstTile.y + (i / 14))

    tiles[i] = g_map.getTile(position)
  end

  return tiles
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

function AfkModule.getCreatureListUI() return uiCreatureList end

return AfkModule

--g_game.talk(spellText)