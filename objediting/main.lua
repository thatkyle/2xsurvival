local function stringToTable(inputString)
  local result = {}
  for item in string.gmatch(inputString, '([^,]+)') do
      table.insert(result, item)
  end
  return result
end

local function parseCsvLine(line)
    local res = {}
    local pos = 1
    while true do
        local c = string.sub(line, pos, pos)
        if (c == "") then break end -- end of string
        if (c == '"') then
            -- read until the next double quote
            local txt = ""
            repeat
                local startp, endp = string.find(line, '^%b""', pos)
                txt = txt .. string.sub(line, startp + 1, endp - 1)
                pos = endp + 1
                c = string.sub(line, pos, pos) 
                if (c == '"') then txt = txt .. '"' end 
                -- check for two double quotes
            until (c ~= '"')
            table.insert(res, txt)
            assert(c == ',' or c == "")
            pos = pos + 1
        else    
            local startp, endp = string.find(line, ',', pos)
            if (startp) then 
                table.insert(res, string.sub(line, pos, startp - 1))
                pos = endp + 1
            else
                -- end of line
                table.insert(res, string.sub(line, pos))
                break
            end
        end
    end
    return res
end
  
local function loadCsv(filePath)
    local file = io.open(filePath, "r")
    if not file then
        error("File could not be opened")
    end
    
    local headers = {}
    local basicUnitData = {}
    local line = file:read()
    headers = parseCsvLine(line)
    
    while true do
        line = file:read()
        if line == nil then break end
        local values = parseCsvLine(line)
        local entry = {}
        for i, header in ipairs(headers) do
            entry[header] = values[i]
        end
        basicUnitData[values[1]] = entry
    end
    
    file:close()
    return basicUnitData
end

local function parseFile(filename)
  local file = io.open(filename, "r")
  if not file then
      return nil, "Unable to open file"
  end

  local entries = {}
  local currentEntry
  for line in file:lines() do
      line = line:gsub("%s+$", "") -- Remove trailing whitespace
      local id = line:match("^%[(.-)%]$")
      if id then
          if currentEntry then
              entries[currentEntry.id] = currentEntry
          end
          currentEntry = {id = id}
      elseif line:find("=") then
          local key, value = line:match("^(.-)=(.-)$")
          if key and value then
              currentEntry[key] = value
          end
      end
  end

  if currentEntry then
      entries[currentEntry.id] = currentEntry
  end

  file:close()
  return entries
end

local function parseCSV(filename, mainTable)
  local file = io.open(filename, "r")
  if not file then
      return nil, "Unable to open file"
  end

  local headers = {}
  local firstLine = true

  for line in file:lines() do
      local values = {}
      local index = 1

      -- Process each character in the line
      local inQuotes = false
      local valueStart = 1
      for i = 1, #line do
          local char = line:sub(i, i)
          if char == '"' then
              inQuotes = not inQuotes
          elseif char == ',' and not inQuotes then
              -- Comma outside quotes, end of value
              local value = line:sub(valueStart, i - 1)
              value = value:match('^"?(.-)"?$') -- Remove potential surrounding quotes
              table.insert(values, value)
              valueStart = i + 1 -- Update the start of the next value
          elseif i == #line then
              -- End of line
              local value = line:sub(valueStart, i)
              value = value:match('^"?(.-)"?$') -- Ensure the last value is added without surrounding quotes
              table.insert(values, value)
          end
      end

      if firstLine then
          -- The first line contains headers
          headers = values
          firstLine = false
      else
          local rowID = values[1] -- Assuming the first column is the unitBalanceID
          if mainTable[rowID] then
              for i = 2, #headers do
                  if headers[i] and headers[i] ~= "" then  -- Some columns may be empty and should be ignored
                      mainTable[rowID][headers[i]] = values[i]
                  end
              end
          else
              -- print("No entry found for ID: " .. rowID)
          end
      end
  end

  file:close()
  return mainTable
end

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

local filePathPrefix = '..\\dataFiles\\war3.w3mod\\_balance\\custom_v1.w3mod\\units\\'
local humanAbilities = parseFile(filePathPrefix .. "humanabilityfunc.txt")
local humanUnitsHeroesBuildings = parseFile(filePathPrefix .. "humanunitfunc.txt")
local humanUpgrades = parseFile(filePathPrefix .. "humanupgradefunc.txt")

local nightElfAbilities = parseFile(filePathPrefix .. "nightelfabilityfunc.txt")
local nightElfUnitsHeroesBuildings = parseFile(filePathPrefix .. "nightelfunitfunc.txt")
local nightElfUpgrades = parseFile(filePathPrefix .. "nightelfupgradefunc.txt")

local orcAbilities = parseFile(filePathPrefix .. "orcabilityfunc.txt")
local orcUnitsHeroesBuildings = parseFile(filePathPrefix .. "orcunitfunc.txt")
local orcUpgrades = parseFile(filePathPrefix .. "orcupgradefunc.txt")

local undeadAbilities = parseFile(filePathPrefix .. "undeadabilityfunc.txt")
local undeadUnitsHeroesBuildings = parseFile(filePathPrefix .. "undeadunitfunc.txt")
local undeadUpgrades = parseFile(filePathPrefix .. "undeadupgradefunc.txt")

local basicUnitData = loadCsv("..\\dataFiles\\basicUnitData.csv")
local basicBuildingData = loadCsv("..\\dataFiles\\basicBuildingData.csv")

local meleeData = {
  human = {
      abilities = humanAbilities,
      units = humanUnitsHeroesBuildings,
      upgrades = humanUpgrades
  },
  nightElf = {
      abilities = nightElfAbilities,
      units = nightElfUnitsHeroesBuildings,
      upgrades = nightElfUpgrades
  },
  orc = {
      abilities = orcAbilities,
      units = orcUnitsHeroesBuildings,
      upgrades = orcUpgrades
  },
  undead = {
      abilities = undeadAbilities,
      units = undeadUnitsHeroesBuildings,
      upgrades = undeadUpgrades
  }
}

for race, itemTypes in pairs(meleeData) do
  for itemTypeName, itemTypeData in pairs(itemTypes) do
      meleeData[race][itemTypeName] = parseCSV(filePathPrefix .. "unitbalance.csv", itemTypeData)
  end
end

local allIdsToNewIds = {}
local staticIds = {
  hpea = 'u000',
  hkee = 'xkee',
  hcas = 'xcas',
  ostr = 'xstr',
  ofrt = 'xfrt',
  unp1 = 'xnp1',
  unp2 = 'xnp2',
  etoa = 'xtoa',
  etoe = 'xtoe',
}
local dontCreateNewIds = {
  halt = 'halt',
  oalt = 'oalt',
  uaod = 'uaod',
  eate = 'eate',
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

-- print(meleeData["human"]["units"]["Hamg"].id)
local count = 0
local prefix = "c"
for race, itemTypes in pairs(meleeData) do
  for itemTypeName, itemTypeData in pairs(itemTypes) do
    for itemType, items in pairs(itemTypes) do
      for item, itemData in pairs(items) do
        if count == 999 then
          count = 0
          prefix = "x"
        end
        count = count + 1
        local newId = string.format(prefix .. "%03d", count)
        if staticIds[itemData.id] then
          newId = staticIds[itemData.id]
        end
        if dontCreateNewIds[itemData.id] then
          newId = itemData.id
        end
        itemData.newId = newId
        allIdsToNewIds[itemData.id] = newId
      end
    end
  end
end

for race, itemTypes in pairs(meleeData) do
  for itemTypeName, itemTypeData in pairs(itemTypes) do
    for itemType, items in pairs(itemTypes) do
      for item, itemData in pairs(items) do
        local id = itemData.id
        local fieldsThatReferenceOtherIds = { "Requires", "Requires1", "Requires2", "Trains", "Researches", "Builds", "Upgrade", "upgrades" }
        local fieldsToUpdate = {}
        for _, field in ipairs(fieldsThatReferenceOtherIds) do
          if itemData[field] and itemData[field] ~= "" then
            table.insert(fieldsToUpdate, field)
          end
        end
        for _, field in ipairs(fieldsToUpdate) do
          local oldIds = stringToTable(itemData[field])
          local newIds = {}
          for _, oldId in ipairs(oldIds) do
            if allIdsToNewIds[oldId] then
              table.insert(newIds, allIdsToNewIds[oldId])
            else
              if oldId ~= "Ronv" and oldId ~= "Rewh" then
                -- print("No new id found for " .. oldId)
              end
            end
          end
          itemData['new' .. field] = table.concat(newIds, ",")

          -- Special cases - Ronv and Rewh don't have duplicated equivalents, so I THINK they can use the old id
          -- If this is not the case I will need to create duplicates as special cases above
          -- For reference, Rewh is wisp renew ability in nightelfabilityfunc.txt and Ronv is Tracking ability in orcabilityfunc.txt
          if oldIds[1] == "Ronv" or oldIds[1] == "Rewh" then
            newIds = {oldIds[1]}
            itemData['newRequires'] = oldIds[1]
          end
        end
      end
    end
  end
end

local usedIds = {}

for race, itemTypes in pairs(meleeData) do
  for itemTypeName, itemTypeData in pairs(itemTypes) do
    for itemType, items in pairs(itemTypes) do
      for item, itemData in pairs(items) do
        local newItem
        if not usedIds[itemData.newId] and not dontCreateNewIds[itemData.newId] then
          if itemType == 'units' then
            if      itemData.isbldg == "1"  then newItem = BuildingDefinition:new(itemData.newId, itemData.id)
            elseif  itemData.STR ~= " - "   then newItem = HeroDefinition:new(itemData.newId, itemData.id) --; newItem:setBuildTime(27) -- special setup step for heroes, there unit data is not included in basicUnitData.csv
            else                                 newItem = UnitDefinition:new(itemData.newId, itemData.id) end
          elseif    itemType == 'abilities' then newItem = AbilityDefinition:new(itemData.newId, itemData.id)
          elseif    itemType == 'upgrades'  then newItem = UpgradeDefinition:new(itemData.newId, itemData.id) end
          usedIds[itemData.newId] = true
        end

        if not newItem then goto continue end

        -- need to check "newRequires", "newRequires1", "newRequires2", "newTrains", "newResearches", "newBuilds", "newUpgrade", "newupgrades"
        if itemType == 'units' or itemType == 'abilities' then
          if itemData.newRequires   then newItem:setRequirements(itemData.newRequires) end
          if itemData.newRequires1  then newItem:setRequierementsForTier(2, itemData.newRequires1) end
          if itemData.newRequires2  then newItem:setRequierementsForTier(3, itemData.newRequires2) end
          if itemData.newTrains     then newItem:setUnitsTrained(itemData.newTrains) end
          if itemData.newResearches then newItem:setResearchesAvailable(itemData.newResearches) end
          if itemData.newBuilds     then newItem:setStructuresBuilt(itemData.newBuilds) end
          if itemData.newUpgrade    then newItem:setUpgradesTo(itemData.newUpgrade) end
          if itemData.newupgrades   then newItem:setUpgradesUsed(itemData.newupgrades) end
        end
        if itemType == 'upgrades' then
          if itemData.newRequires   then newItem:setRequirements(1, itemData.newRequires) end
          if itemData.newRequires1  then newItem:setRequirements(1, itemData.newRequires1) end
          if itemData.newRequires2  then newItem:setRequirements(2, itemData.newRequires2) end
          if itemData.newUpgrade    then newItem:setUpgradesTo(itemData.newUpgrade) end
        end
        -- for testing
        if itemType == 'units' then
          newItem:setBuildTime(1)
        end
        
        ::continue::
      end
    end
  end
end

-- print(meleeData["human"]["units"]["hpea"].newId)

-- for oldId, newId in pairs(allIdsToNewIds) do
--   if newId == "c301" then
--     print(oldId .. " -> " .. newId)
--   end
--   if oldId == "c301" then
--     print(oldId .. " -> " .. newId)
--   end
-- end