dofile('enemyWaves.lua')

local function printTable(tbl, indent)
  if not indent then indent = 0 end
  for k, v in pairs(tbl) do
      local formatting = string.rep("  ", indent) .. k .. ": "
      if type(v) == "table" then
          print(formatting)
          printTable(v, indent+1)
      else
          print(formatting .. tostring(v))
      end
  end
end

print('Hello warcraft-vscode !')

for i = 0, 20 do
  CreateUnit(Player(0), FourCC('u000'), 219.4, -90.4, 293.630)
end
SetPlayerState(Player(0), PLAYER_STATE_RESOURCE_LUMBER, 10000)
SetPlayerState(Player(0), PLAYER_STATE_RESOURCE_GOLD, 10000)

local townHallOldToNewIdsMap = {
  hkee = 'xkee',
  hcas = 'xcas',
  ostr = 'xstr',
  ofrt = 'xfrt',
  unp1 = 'xnp1',
  unp2 = 'xnp2',
  etoa = 'xtoa',
  etoe = 'xtoe',
}
local townHallNewToOldCodes = {}
for k, v in pairs(townHallOldToNewIdsMap) do
  townHallNewToOldCodes[FourCC(v)] = FourCC(k)
end
local createUpgradedTownHallsT = CreateTrigger()
for i = 0, bj_MAX_PLAYERS - 1 do
  TriggerRegisterPlayerUnitEvent(createUpgradedTownHallsT, Player(i), EVENT_PLAYER_UNIT_UPGRADE_FINISH, nil)
end
TriggerAddAction(createUpgradedTownHallsT, function()
  local building = GetTriggerUnit()
  local buildingType = GetUnitTypeId(building)
  if townHallNewToOldCodes[buildingType] then
    local x = GetRectMaxX(GetWorldBounds())
    local y = GetRectMaxY(GetWorldBounds())
    local u = CreateUnit(GetOwningPlayer(building), townHallNewToOldCodes[buildingType], x, y, 0)
    print ('Created upgraded town hall', GetUnitName(u), 'at', x, y)
    UnitAddAbility(u, FourCC('Aloc'))
  end
end)

local heroIds = {
  Hamg = 'Hamg',
  Hpal = 'Hpal',
  Hblm = 'Hblm',
  Hmkg = 'Hmkg',
  Obla = 'Obla',
  Oshd = 'Oshd',
  Otch = 'Otch',
  Ofar = 'Ofar',
  Udea = 'Udea',
  Ulic = 'Ulic',
  Ucrl = 'Ucrl',
  Udre = 'Udre',
  Edem = 'Edem',
  Ekee = 'Ekee',
  Emoo = 'Emoo',
  Ewar = 'Ewar',
}
local heroCodes = {}
for k, v in pairs(heroIds) do
  heroCodes[FourCC(v)] = FourCC(k)
end

local playerHeroCount = {}
local restrictPlayerHeroCountOnTrainFinishT = CreateTrigger()
for i = 0, bj_MAX_PLAYERS - 1 do
  TriggerRegisterPlayerUnitEvent(restrictPlayerHeroCountOnTrainFinishT, Player(i), EVENT_PLAYER_UNIT_TRAIN_FINISH, nil)
  playerHeroCount[i] = 0
end
TriggerAddAction(restrictPlayerHeroCountOnTrainFinishT, function()
  local p = GetTriggerPlayer()
  local pId = GetPlayerId(p)
  local u = GetTrainedUnit()
  local uType = GetUnitTypeId(u)
  if heroCodes[uType] then
    print('Hero trained', GetUnitName(u))
    playerHeroCount[pId] = playerHeroCount[pId] + 1
    print('Player hero count', playerHeroCount[pId])
    if playerHeroCount[pId] >= 1 then
      DisplayTimedTextToPlayer(p, 0, 0, 60, "You can only have 1 heroes at a time.")
      RemoveUnit(u)
      SetPlayerState(p, PLAYER_STATE_RESOURCE_GOLD, GetPlayerState(p, PLAYER_STATE_RESOURCE_GOLD) + GetUnitGoldCost(uType))
      SetPlayerState(p, PLAYER_STATE_RESOURCE_LUMBER, GetPlayerState(p, PLAYER_STATE_RESOURCE_LUMBER) + GetUnitWoodCost(uType))
    end
  end
end)

local restrictPlayerHeroCountOnTrainStartT = CreateTrigger()
for i = 0, bj_MAX_PLAYERS - 1 do
  TriggerRegisterPlayerUnitEvent(restrictPlayerHeroCountOnTrainStartT, Player(i), EVENT_PLAYER_UNIT_TRAIN_START, nil)
end
TriggerAddAction(restrictPlayerHeroCountOnTrainStartT, function()
  local p = GetTriggerPlayer()
  local pId = GetPlayerId(p)
  local uType = GetTrainedUnitType()
  TriggerSleepAction(0)
  if heroCodes[uType] then
    if playerHeroCount[pId] >= 4 then
      -- I think I'm going to have to do this using abilities, because issuing an order to cancel the training doesn't work
      -- Or, remove and recreate the altar, select the altar, and refund the resources
      DisplayTimedTextToPlayer(p, 0, 0, 60, "You can only have 1 heroes at a time.")
      for i = 1, 7 do
        IssueImmediateOrderById(GetTriggerUnit(), 851976)
      end
    end
  end
end)

local playerHeroesTrainingAndTrained = {}
local restrictDuplicateHeroTypesOnTrainStartT = CreateTrigger()
for i = 0, bj_MAX_PLAYERS - 1 do
  TriggerRegisterPlayerUnitEvent(restrictDuplicateHeroTypesOnTrainStartT, Player(i), EVENT_PLAYER_UNIT_TRAIN_START, nil)
  playerHeroesTrainingAndTrained[i] = {}
end
TriggerAddAction(restrictDuplicateHeroTypesOnTrainStartT, function()
  local p = GetTriggerPlayer()
  local pId = GetPlayerId(p)
  local uType = GetTrainedUnitType()
  TriggerSleepAction(0)
  print('Training', GetUnitName(GetTriggerUnit()))
  print('isTraining', playerHeroesTrainingAndTrained[pId][uType].isTraining)
  print('isTrained', playerHeroesTrainingAndTrained[pId][uType].isTrained)
  if playerHeroesTrainingAndTrained[pId][uType].isTraining == true or playerHeroesTrainingAndTrained[pId][uType].isTrained == true then
    DisplayTimedTextToPlayer(p, 0, 0, 60, "You're already training or have a hero of this type.")
    for i = 1, 7 do
      IssueImmediateOrderById(GetTriggerUnit(), 851976)
    end
  end
  if not playerHeroesTrainingAndTrained[pId][uType] then
    playerHeroesTrainingAndTrained[pId][uType] = { isTraining = true}
  end
end)

local restrictDuplicateHeroTypesOnTrainCancelT = CreateTrigger()
for i = 0, bj_MAX_PLAYERS - 1 do
  TriggerRegisterPlayerUnitEvent(restrictDuplicateHeroTypesOnTrainCancelT, Player(i), EVENT_PLAYER_UNIT_TRAIN_CANCEL, nil)
end
TriggerAddAction(restrictDuplicateHeroTypesOnTrainCancelT, function()
  local p = GetTriggerPlayer()
  local pId = GetPlayerId(p)
  local uType = GetTrainedUnitType()
  if playerHeroesTrainingAndTrained[pId][uType] then
    playerHeroesTrainingAndTrained[pId][uType].isTraining = false
  end
end)

local restrictDuplicateHeroTypesOnTrainFinishT = CreateTrigger()
for i = 0, bj_MAX_PLAYERS - 1 do
  TriggerRegisterPlayerUnitEvent(restrictDuplicateHeroTypesOnTrainFinishT, Player(i), EVENT_PLAYER_UNIT_TRAIN_FINISH, nil)
end
TriggerAddAction(restrictDuplicateHeroTypesOnTrainFinishT, function()
  local p = GetTriggerPlayer()
  local pId = GetPlayerId(p)
  local u = GetTrainedUnit()
  local uType = GetUnitTypeId(u)
  if playerHeroesTrainingAndTrained[pId][uType].isTrained then
    DisplayTimedTextToPlayer(p, 0, 0, 60, "You're already training or have a hero of this type.")
    RemoveUnit(u)
    SetPlayerState(p, PLAYER_STATE_RESOURCE_GOLD, GetPlayerState(p, PLAYER_STATE_RESOURCE_GOLD) + GetUnitGoldCost(uType))
    SetPlayerState(p, PLAYER_STATE_RESOURCE_LUMBER, GetPlayerState(p, PLAYER_STATE_RESOURCE_LUMBER) + GetUnitWoodCost(uType))
  end
  if heroCodes[uType] then
    playerHeroesTrainingAndTrained[pId][uType].isTraining = false
    playerHeroesTrainingAndTrained[pId][uType].isTrained = true
  end
end)

local altarIds = {
  halt = 'halt',
  oalt = 'oalt',
  uaod = 'uaod',
  eate = 'eate',
}
local altarCodes = {}
for k, v in pairs(altarIds) do
  altarCodes[FourCC(v)] = FourCC(k)
end
local shortenAltarConstructionT = CreateTrigger()
for i = 0, bj_MAX_PLAYERS - 1 do
  TriggerRegisterPlayerUnitEvent(shortenAltarConstructionT, Player(i), EVENT_PLAYER_UNIT_CONSTRUCT_START, nil)
end
TriggerAddAction(shortenAltarConstructionT, function()
  local building = GetConstructingStructure()
  local buildingType = GetUnitTypeId(building)
  if altarCodes[buildingType] then
    TriggerSleepAction(0)
    UnitSetConstructionProgress(building, 50)
  end
end)


-- local finishAltarFastT = CreateTrigger()
-- for i = 0, bj_MAX_PLAYERS - 1 do
--   TriggerRegisterPlayerUnitEvent(finishAltarFastT, Player(i), EVENT_PLAYER_UNIT_CONSTRUCT_START, nil)
-- end
-- TriggerAddAction(finishAltarFastT, function()
--   print('Constructing structure')
--   local unit = GetTriggerUnit()
--   local building = GetConstructingStructure()
--   local buildingType = GetUnitTypeId(building)
--   if altarCodes[buildingType] then
--     print('Found altar')
--     UnitSetConstructionProgress(building, 90)
--     UnitSetConstructionProgress(unit, 90)
--   end
-- end)
-- local playerHeroesCount = {}
-- local startTrainHeroT = CreateTrigger()
-- for i = 0, bj_MAX_PLAYERS - 1 do
--   TriggerRegisterPlayerUnitEvent(startTrainHeroT, Player(i), EVENT_PLAYER_UNIT_TRAIN_START, nil)
--   playerHeroesCount[i] = 4
-- end
-- TriggerAddAction(startTrainHeroT, function()
--   local p = GetTriggerPlayer()
--   local pId = GetPlayerId(p)
--   local u = GetTriggerUnit()
  
--   if playerHeroesCount[pId] >= 3 then
--     DisplayTimedTextToPlayer(p, 0, 0, 60, "You can only have 3 heroes at a time.")
--     IssueImmediateOrder(GetTriggerUnit(), "cancel")
--     IssueImmediateOrder(GetTriggerUnit(), "stop")
--   end
  -- print("TRAINING")
  -- local p = GetTriggerPlayer()
  -- local altar = GetTriggerUnit()
  -- local pId = GetPlayerId(p)
  -- local uType = GetTrainedUnitType()
  -- if doesPlayerHaveHero[pId] and doesPlayerHaveHero[pId][uType] then
  --   DisplayTimedTextToPlayer(p, 0, 0, 60, "You can only have one hero of a type at a time.")
  --   IssueImmediateOrder(altar, "cancel")
  -- end
  -- if isPlayerTrainingHero[pId] == nil then
  --   isPlayerTrainingHero[pId] = { uType = true }
  -- elseif isPlayerTrainingHero[pId][uType] == false then
  --   isPlayerTrainingHero[pId][uType] = true
  -- end
  -- TriggerSleepAction(27)
  -- if isPlayerTrainingHero[pId][uType] == true and UnitAlive(altar) then
  --   CreateUnit(p, uType, GetUnitX(altar), GetUnitY(altar), GetUnitFacing(altar))
  --   IssueImmediateOrder(altar, "cancel")
  --   if doesPlayerHaveHero[pId] == nil then
  --     doesPlayerHaveHero[pId] = { uType = true }
  --   elseif doesPlayerHaveHero[pId][uType] == nil then
  --     doesPlayerHaveHero[pId][uType] = true
  --   end
  -- end
-- end)