local function getSpawnPoint()
  local cameraBoundsRect = GetCameraBoundsMapRect()
  local maxX = GetRectMaxX(cameraBoundsRect)
  local maxY = GetRectMaxY(cameraBoundsRect)
  local minX = GetRectMinX(cameraBoundsRect)
  local minY = GetRectMinY(cameraBoundsRect)
  local x = GetRandomReal(0, 1)
  local y = GetRandomReal(0, 1)
  local p = GetRandomInt(0, 3)
  if p == 0 then
    return x * maxX, y * maxY
  elseif p == 1 then
    return x * minX, y * maxY
  elseif p == 2 then
    return x * maxX, y * minY
  else
    return x * minX, y * minY
  end
end

local enemy = Player(PLAYER_NEUTRAL_AGGRESSIVE)

local humanUnitNamesToCodes = {
  footman = 'hfoo',
  rifleman = 'hrif',
  knight = 'hkni',
  priest = 'hmpr',
  sorceress = 'hsor',
  spellBreaker = 'hspt',
  flyingMachine = 'hgyr',
  mortarTeam = 'hmtm',
  siegeEngine = 'hmtt',
  gryphonRider = 'hgry',
  dragonhawkRider = 'hdhw',
}

local spawnedUnits = {}

local function spawnUnits(unitCode, count)
  for i = 1, count do
    local x, y = getSpawnPoint()
    local u = CreateUnit(enemy, FourCC(unitCode), x, y, 0)
    table.insert(spawnedUnits, u)
    IssuePointOrder(u, "attack", -250, -400)
  end
end

local issueEnemyAttackReminderT = CreateTrigger()
TriggerRegisterTimerEvent(issueEnemyAttackReminderT, 1, true)
TriggerAddAction(issueEnemyAttackReminderT, function()
  for _, u in ipairs(spawnedUnits) do
    IssuePointOrder(u, "attack", -250, -400)
  end
end)

local waves = {
  { timer = 60,
    { unit = 'footman', count = 5 },
    { unit = 'rifleman', count = 5 },
    { unit = 'mortarTeam', count = 1 } },
  { timer = 90,
    { unit = 'footman', count = 10 },
    { unit = 'rifleman', count = 10 },
    { unit = 'knight', count = 1 },
    { unit = 'priest', count = 1 },
    { unit = 'mortarTeam', count = 4 }, },
  { timer = 150,
    { unit = 'knight', count = 5 },
    { unit = 'flyingMachine', count = 25}, },
  { timer = 260,
    { unit = 'footman', count = 5 },
    { unit = 'rifleman', count = 5 },
    { unit = 'mortarTeam', count = 1 },
    { unit = 'footman', count = 10 },
    { unit = 'rifleman', count = 10 },
    { unit = 'knight', count = 1 },
    { unit = 'priest', count = 1 },
    { unit = 'mortarTeam', count = 4 }, 
    { unit = 'knight', count = 5 },
    { unit = 'flyingMachine', count = 25}, },
  { timer = 330,
    { unit = 'knight', count = 10 },
    { unit = 'dragonhawkRider', count = 10},
    { unit = 'mortarTeam', count = 10 },
    { unit = 'siegeEngine', count = 5 }, },
}

local gameTime = 0
local function checkWaveTimers()
  print('checking wave timers  ', gameTime)
  gameTime = gameTime + 1
  for _, wave in ipairs(waves) do
    if wave.timer == gameTime then
      for _, unitData in ipairs(wave) do
        spawnUnits(humanUnitNamesToCodes[unitData.unit], unitData.count)
      end
    end
  end
end

local checkWaveTimersT = CreateTrigger()
TriggerRegisterTimerEvent(checkWaveTimersT, 1, true)
TriggerAddAction(checkWaveTimersT, checkWaveTimers)