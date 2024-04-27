function getIdStrings(typeTable, itemsToGet)
  local idStrings = {}
  for i = 1, #itemsToGet do
    idStrings[i] = typeTable[itemsToGet[i]].id
  end
  return table.concat(idStrings, ",")
end

local humanUnits = {}

local h001 = UnitDefinition:new('h001', 'hdhw')
h001:setBuildTime(14)
humanUnits['hdhw'] = { self = h001, id = 'h001' }

local h002 = UnitDefinition:new('h002', 'hfoo')
h002:setBuildTime(10)
humanUnits['hfoo'] = { self = h002, id = 'h002' }

local h003 = UnitDefinition:new('h003', 'hkni')
h003:setBuildTime(20)
humanUnits['hkni'] = { self = h003, id = 'h003' }

local h004 = UnitDefinition:new('h004', 'hmpr')
h004:setBuildTime(14)
humanUnits['hmpr'] = { self = h004, id = 'h004' }

local h005 = UnitDefinition:new('h005', 'hmtm')
h005:setBuildTime(16)
humanUnits['hmtm'] = { self = h005, id = 'h005' }

local h006 = UnitDefinition:new('h006', 'hmtt')
h006:setBuildTime(27)
humanUnits['hmtt'] = { self = h006, id = 'h006' }

local h007 = UnitDefinition:new('h007', 'hpea')
h007:setBuildTime(5)
humanUnits['hpea'] = { self = h007, id = 'h007' }

local h008 = UnitDefinition:new('h008', 'hrif')
h008:setBuildTime(13)
humanUnits['hrif'] = { self = h008, id = 'h008' }

local h009 = UnitDefinition:new('h009', 'hsor')
h009:setBuildTime(15)
humanUnits['hsor'] = { self = h009, id = 'h009' }

local h011 = UnitDefinition:new('h011', 'hgyr')
h011:setBuildTime(6)
humanUnits['hgyr'] = { self = h011, id = 'h011' }

local h012 = UnitDefinition:new('h012', 'hgry')
h012:setBuildTime(22)
humanUnits['hgry'] = { self = h012, id = 'h012' }

local h013 = UnitDefinition:new('h013', 'hspt')
h013:setBuildTime(14)
humanUnits['hspt'] = { self = h013, id = 'h013' }

local humanHeroes = {}

local H001 = UnitDefinition:new('H001', 'Hpal')
H001:setBuildTime(27)
humanHeroes['Hpal'] = { self = H001, id = 'H001'}

local H002 = UnitDefinition:new('H002', 'Hblm')
H002:setBuildTime(27)
humanHeroes['Hblm'] = { self = H002, id = 'H002'}

local H003 = UnitDefinition:new('H003', 'Hmkg')
H003:setBuildTime(27)
humanHeroes['Hmkg'] = { self = H003, id = 'H003'}

local H004 = UnitDefinition:new('H004', 'Hamg')
H004:setBuildTime(27)
humanHeroes['Hamg'] = { self = H004, id = 'H004'}

local humanBuildings = {}

local b001 = BuildingDefinition:new('b001', 'halt')
b001:setBuildTime(30)
local idStrings = getIdStrings(humanHeroes, 
  {'Hpal', 'Hblm', 'Hmkg', 'Hamg'}) 
b001:setUnitsTrained(idStrings)
humanBuildings['halt'] = { self = b001, id = 'b001'}

local b002 = BuildingDefinition:new('b002', 'hars')
b002:setBuildTime(35)
idStrings = getIdStrings(humanUnits, 
  {'hmpr', 'hsor', 'hspt'})
b002:setUnitsTrained(idStrings)
humanBuildings['hars'] = { self = b002, id = 'b002'}

local b003 = BuildingDefinition:new('b003', 'hatw')
b003:setBuildTime(25)
humanBuildings['hatw'] = { self = b003, id = 'b003'}

local b004 = BuildingDefinition:new('b004', 'hvlt')
b004:setBuildTime(30)
humanBuildings['hvlt'] = { self = b004, id = 'b004'}

local b005 = BuildingDefinition:new('b005', 'hbar')
b005:setBuildTime(30)
idStrings = getIdStrings(humanUnits, 
  {'hfoo', 'hrif', 'hkni'})
b005:setUnitsTrained(idStrings)
humanBuildings['hbar'] = { self = b005, id = 'b005'}

local b006 = BuildingDefinition:new('b006', 'hbla')
b006:setBuildTime(35)
humanBuildings['hbla'] = { self = b006, id = 'b006'}

local b007 = BuildingDefinition:new('b007', 'hctw')
b007:setBuildTime(32)
humanBuildings['hctw'] = { self = b007, id = 'b007'}

local b008 = BuildingDefinition:new('b008', 'hcas')
b008:setBuildTime(70)
b008:setUnitsTrained('h007')
humanBuildings['hcas'] = { self = b008, id = 'b008'}

local b009 = BuildingDefinition:new('b009', 'hhou')
b009:setBuildTime(17)
humanBuildings['hhou'] = { self = b009, id = 'b009'}

local b010 = BuildingDefinition:new('b010', 'hgra')
b010:setBuildTime(35)
idStrings = getIdStrings(humanUnits, 
  {'hgry', 'hdhw'})
b010:setUnitsTrained(idStrings)
humanBuildings['hgra'] = { self = b010, id = 'b010'}

local b011 = BuildingDefinition:new('b011', 'hgtw')
b011:setBuildTime(25)
humanBuildings['hgtw'] = { self = b011, id = 'b011'}

local b012 = BuildingDefinition:new('b012', 'hkee')
b012:setBuildTime(70)
idStrings = getIdStrings(humanUnits, 
  {'hpea'})
b012:setUnitsTrained(idStrings)
humanBuildings['hkee'] = { self = b012, id = 'b012'}

local b013 = BuildingDefinition:new('b013', 'hlum')
b013:setBuildTime(30)
humanBuildings['hlum'] = { self = b013, id = 'b013'}

local b014 = BuildingDefinition:new('b014', 'hwtw')
b014:setBuildTime(12)
humanBuildings['hwtw'] = { self = b014, id = 'b014'}

local b015 = BuildingDefinition:new('b015', 'htow')
b015:setBuildTime(90)
idStrings = getIdStrings(humanUnits, 
  {'hpea'})
b015:setUnitsTrained(idStrings)
humanBuildings['htow'] = { self = b015, id = 'b015'}

local b016 = BuildingDefinition:new('b016', 'harm')
b016:setBuildTime(30)
idStrings = getIdStrings(humanUnits, 
  {'hgyr', 'hmtm', 'hmtt'})
b016:setUnitsTrained(idStrings)
humanBuildings['harm'] = { self = b016, id = 'b016'}

idStrings = getIdStrings(humanBuildings, 
  {'htow', 'hhou', 'hbar', 'hbla', 'hwtw', 'halt',
  'harm', 'hars', 'hlum', 'hgra', 'hvlt'})
humanUnits['hpea']:setStructuresBuilt(idStrings)

local humanUpgrades = {}

