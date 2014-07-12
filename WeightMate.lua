require "Window"

local Builder = {} 

local tPrimaryStats =
{
  [Unit.CodeEnumProperties.Dexterity]           = Apollo.GetString("CRB_Finesse"),
  [Unit.CodeEnumProperties.Technology]          = Apollo.GetString("CRB_Tech_Attribute"),
  [Unit.CodeEnumProperties.Magic]             = Apollo.GetString("CRB_Moxie"),
  [Unit.CodeEnumProperties.Wisdom]            = Apollo.GetString("UnitPropertyInsight"),
  [Unit.CodeEnumProperties.Stamina]             = Apollo.GetString("CRB_Grit"),
  [Unit.CodeEnumProperties.Strength]            = Apollo.GetString("CRB_Brutality"),
}

local tRunes =
{
  [Item.CodeEnumSigilType.Air] = Apollo.GetString("CRB_Air"),
  [Item.CodeEnumSigilType.Earth] = Apollo.GetString("CRB_Earth"),
  [Item.CodeEnumSigilType.Fire] = Apollo.GetString("CRB_Fire"),
  [Item.CodeEnumSigilType.Fusion] = Apollo.GetString("CRB_Fusion"),
  [Item.CodeEnumSigilType.Life] = Apollo.GetString("CRB_Life"),
  [Item.CodeEnumSigilType.Logic] = Apollo.GetString("CRB_Logic"),
  [Item.CodeEnumSigilType.Omni] = Apollo.GetString("CRB_Omni"),
  [Item.CodeEnumSigilType.Water] = Apollo.GetString("CRB_Water"),
}

local tUntrackableStats = {
  [127] = 1,[183]=1, [21]=1, [176]=1, [113]=1, [167]=1, [174]=1, [24]=1, [186]=1, [162]=1, [17]=1, [108]=1, [106]=1, [122]=1, [142]=1, [30]=1, [126]=1, [160]=1, [147]=1, [116]=1, [19]=1, [145]=1, [100]=1, [146]=1, [111]=1, [39]=1, [168]=1, [12]=1, [143]=1, [182]=1, [187]=1, [38]=1, [136]=1, [140]=1, [149]=1, [133]=1, [103]=1, [109]=1, [45]=1, [15]=1, [171]=1, [14]=1, [13]=1, [10]=1, [8]=1, [179]=1, [9]=1, [153]=1, [124]=1, [166]=1, [163]=1, [131]=1, [18]=1, [181]=1, [177]=1, [125]=1, [110]=1, [135]=1, [119]=1, [134]=1, [118]=1, [23]=1, [115]=1, [139]=1, [164]=1, [121]=1, [150]=1, [130]=1, [114]=1, [188]=1, [190]=1, [128]=1, [189]=1, [185]=1, [172]=1, [132]=1, [112]=1, [184]=1, [138]=1, [11]=1, [180]=1, [148]=1, [20]=1, [46]=1, [152]=1, [170]=1, [169]=1, [141]=1, [165]=1, [173]=1, [161]=1, [159]=1, [123]=1, [144]=1, [151]=1, [191]=1, [22]=1, [120]=1, [29]=1, [44]=1, [16]=1, [117]=1
}

local tTrackableStats = {}

for k,v in pairs(Unit.CodeEnumProperties) do
  if not tUntrackableStats[v] and not tPrimaryStats[v] then
    tTrackableStats[v] = Item.GetPropertyName(v)
  end 
end 

function Builder:new(id)
  local o = {}
  setmetatable(o, {__index = Builder})
  o.WeightMate = Apollo.GetAddon("WeightMate")

  o.btools = {}
  o.btools.util = Apollo.GetPackage('indigotock.btools.util').tPackage
  o.btools.gui = {}
  o.btools.gui.drop_button =
  Apollo.GetPackage('indigotock.btools.gui.drop_button').tPackage
  o.btools.gui.number_ticker =
  Apollo.GetPackage('indigotock.btools.gui.number_ticker').tPackage
  o.btools.gui.search_list =
  Apollo.GetPackage('indigotock.btools.gui.search_list').tPackage

  o.wndMain = Apollo.LoadForm(o.WeightMate.xmlDoc, "BuildBuilder", nil, o)
  o.tBaseBuild = o.btools.util.merge_table(o.WeightMate:GetCleanBuild(),o.WeightMate.tBuilds[id])
  o.tBuild = o.btools.util.clone_table(o.tBaseBuild)
  o.nBuildId = id
  o:BuildWindow()
  return o
end

function Builder:IsValidBuild(build)
  local isGood = true
  isGood = isGood and build                  and build.sName                          and build.eClass                                   and build.eRole
  isGood = isGood and build.tRuneConfig      and build.tRuneConfig.bTrack~=nil        and build.tRuneConfig.bTrackEmpty~=nil             and build.tRuneConfig.tEmptyWeights
  isGood = isGood and build.tImbuementConfig and build.tImbuementConfig.bTrack~=nil   and build.tImbuementConfig.bTrackOnlyUnlocked~=nil
  isGood = isGood and build.tStatConfig      and build.tStatConfig.bTrackPrimary~=nil and build.tStatConfig.tWeights
  return isGood
end

function Builder:BuildWindow()
  self.wndMain:FindChild("BuildNameEntryBox"):SetText(self.tBuild.sName)
  self.wndMain:FindChild("ClassSelectionContainer"):SetRadioSel("ClassSelection",self.tBuild.eClass)
  self.wndMain:FindChild("RoleSelectionContainer"):SetRadioSel("RoleSelection",self.tBuild.eRole)


  self.wndMain:FindChild("TrackRunesButton"):SetCheck(self.tBuild.tRuneConfig.bTrack)
  self.wndMain:FindChild("TrackEmptyRuneSlotsButton"):Enable(self.tBuild.tRuneConfig.bTrack)
  self.wndMain:FindChild("TrackEmptyRuneSlotsButton"):SetCheck(self.tBuild.tRuneConfig.bTrackEmpty)

  self.wndMain:FindChild("EmptyRuneWeightTickers"):DestroyChildren()
  for id,name in pairs(tRunes) do
    local control = self.btools.gui.number_ticker(self.wndMain:FindChild("EmptyRuneWeightTickers"),{tData={['nRuneId']=id}, sHeaderText=name, nDivide=0.5, nDefaultValue=self.tBuild.tRuneConfig.tEmptyWeights[id] or 0, fOnChangeValue = function(ticker, val) self.tBuild.tRuneConfig.tEmptyWeights[ticker.tData['nRuneId']] = val or 0 end})
    control.cControl:SetName(tostring(v).."EmptyRuneTicker")
    control:set_enabled(self.tBuild.tRuneConfig.bTrack and self.tBuild.tRuneConfig.bTrackEmpty)
  end
  self.wndMain:FindChild("EmptyRuneWeightTickers"):ArrangeChildrenVert()


  self.wndMain:FindChild("TrackImbuementsButton"):SetCheck(self.tBuild.tImbuementConfig.bTrack)
  self.wndMain:FindChild("TrackImbuementsUnlockedOnlyButton"):Enable(self.tBuild.tImbuementConfig.bTrack)
  self.wndMain:FindChild("TrackImbuementsUnlockedOnlyButton"):SetCheck(self.tBuild.tImbuementConfig.bTrackOnlyUnlocked)


  self.wndMain:FindChild("TrackPrimaryStatsButton"):SetCheck(self.tBuild.tStatConfig.bTrackPrimary)
  self.wndMain:FindChild("StatWarningButton"):Show(self.tBuild.tStatConfig.bTrackPrimary,false)

  self.wndMain:FindChild("PrimaryStatTickers"):DestroyChildren()
  for id, name in pairs(tPrimaryStats) do
    local control = self.btools.gui.number_ticker(self.wndMain:FindChild("PrimaryStatTickers"),{tData = {['nStatId'] = id}, sHeaderText=name, nDivide=.5, nWidth = self.wndMain:FindChild("PrimaryStatContent"):GetWidth()/2, nDefaultValue = self.tBuild.tStatConfig.tWeights[id] or 0, fOnChangeValue = function(ticker, nVal) self.tBuild.tStatConfig.tWeights[id] = nVal or 0 end})
    control.cControl:SetName(tostring(id).."StatTicker")
    control:set_enabled(self.tBuild.tStatConfig.bTrackPrimary)
  end
  self.wndMain:FindChild("PrimaryStatTickers"):ArrangeChildrenTiles()

  self.wndMain:FindChild("TrackedStatList"):DestroyChildren()
  for id, weight in pairs(self.tBuild.tStatConfig.tWeights) do
    if not tPrimaryStats[id] then
      local name = Item.GetPropertyName(id)
      local control = Apollo.LoadForm(self.WeightMate.xmlDoc, "TrackedStatContainer", self.wndMain:FindChild("TrackedStatList"),self)
      control:SetData(id)
      self.btools.gui.number_ticker(control:FindChild("Container"),{tData = {['nStatId'] = id}, sHeaderText=name, nDivide=.75, nDefaultValue = self.tBuild.tStatConfig.tWeights[id] or 0, fOnChangeValue = function(ticker, nVal) self.tBuild.tStatConfig.tWeights[id] = nVal or 0 end})
    end
  end
  self.wndMain:FindChild("TrackedStatList"):ArrangeChildrenVert()

  if self.wndMain:FindChild("SearchDropButton") then
    self.wndMain:FindChild("SearchDropButton"):Destroy()
  end
  local searchButton = self.btools.gui.drop_button(self.wndMain:FindChild("StatContent"),{sText = "Track new stat", nWindowWidth=225})
  searchButton.cControl:SetName("SearchDropButton")
  self.wndMain:FindChild("StatContent"):ArrangeChildrenVert()
  local searchList = {}
  for id,name in pairs(tTrackableStats) do
    if not self.tBuild.tStatConfig.tWeights[id] then
      table.insert(searchList,id)
    end
  end
  table.sort(searchList,function(i1,i2) return Item.GetPropertyName(i1)<Item.GetPropertyName(i2) end)
  self.btools.gui.search_list(searchButton.cContainer,{aItems = searchList, xItemDoc = self.WeightMate.xmlDoc, sItemForm = "StatSearchItem", 
    fBuildItem = function(c,i) c:SetText(Item.GetPropertyName(i)) end,
    fSearchMatch = function(i,t) return Item.GetPropertyName(i):lower():find(t:lower(),1,true) end,
    tHandler=self})
end

-- Basics

function Builder:SetName( wndHandler, wndControl, strText )
  self.tBuild.sName = strText
end

function Builder:SetClass( wndHandler, wndControl, eMouseButton )
  self.tBuild.eClass = self.wndMain:FindChild("ClassSelectionContainer"):GetRadioSel("ClassSelection")
end

function Builder:SetRole( wndHandler, wndControl, eMouseButton )
  self.tBuild.eRole = self.wndMain:FindChild("RoleSelectionContainer"):GetRadioSel("RoleSelection")
end

-- Runes

function Builder:SetTrackRunes( wndHandler, wndControl, eMouseButton )
  self.tBuild.tRuneConfig.bTrack = true
  self:BuildWindow()
end

function Builder:UnsetTrackRunes( wndHandler, wndControl, eMouseButton )
  self.tBuild.tRuneConfig.bTrack = false
  self:BuildWindow()
end

function Builder:SetTrackEmptyRunes( wndHandler, wndControl, eMouseButton )
  self.tBuild.tRuneConfig.bTrackEmpty = true
  self:BuildWindow()
end

function Builder:UnsetTrackEmptyRunes( wndHandler, wndControl, eMouseButton )
  self.tBuild.tRuneConfig.bTrackEmpty = false 
  self:BuildWindow()
end

-- Imbuements

function Builder:SetTrackImbuements( wndHandler, wndControl, eMouseButton )
  self.tBuild.tImbuementConfig.bTrack = true
  self:BuildWindow()
end

function Builder:UnsetTrackImbuements( wndHandler, wndControl, eMouseButton )
  self.tBuild.tImbuementConfig.bTrack = false 
  self:BuildWindow()
end
function Builder:SetTrackUnlockedImbuements( wndHandler, wndControl, eMouseButton )
  self.tBuild.tImbuementConfig.bTrackOnlyUnlocked = true
  self:BuildWindow()
end

function Builder:UnsetTrackUnlockedImbuements( wndHandler, wndControl, eMouseButton )
  self.tBuild.tImbuementConfig.bTrackOnlyUnlocked = false 
  self:BuildWindow()
end

-- Stats

function Builder:ShowPrimaryStatWarning( wndHandler, wndControl, eMouseButton )
  self.wndMain:FindChild("PrimaryStatWarning"):Show(true,false)
end

function Builder:HidePrimaryStatWarning( wndHandler, wndControl, eMouseButton )
  self.wndMain:FindChild("PrimaryStatWarning"):Show(false,false)
end

function Builder:SetTrackPrimaryStats( wndHandler, wndControl, eMouseButton )
  self.tBuild.tStatConfig.bTrackPrimary = true
  self:BuildWindow()
end

function Builder:UnsetTrackPrimaryStats( wndHandler, wndControl, eMouseButton )
  self.tBuild.tStatConfig.bTrackPrimary = false
  self:BuildWindow()
end

function Builder:OnSelectStatToTrack( wndHandler, wndControl, eMouseButton )
  self.tBuild.tStatConfig.tWeights[wndControl:GetData()] = 0
  self:BuildWindow()
end

function Builder:UntrackStat( wndHandler, wndControl, eMouseButton )
  self.tBuild.tStatConfig.tWeights[wndControl:GetParent():GetData()] = nil
  self:BuildWindow()
end

-- General

function Builder:SaveBuild( wndHandler, wndControl, eMouseButton)
  self.WeightMate.tBuilds[self.nBuildId] = self.btools.util.clone_table(self.tBuild)
  self.WeightMate:UpdateBuildList()
  self.wndMain:Close()
end

function Builder:DeleteBuild( wndHandler, wndControl, eMouseButton)
  self.WeightMate.tBuilds[self.nBuildId] = nil
  self.WeightMate:UpdateBuildList()
  self.wndMain:Close()
end

function Builder:CloseBuilder( wndHandler, wndControl, eMouseButton)
  self.wndMain:Close()
end

-- Sharing

function Builder:HideImportExportBox( wndHandler, wndControl, eMouseButton)
  self.wndMain:FindChild("ImportExportWindow"):Show(false,false)
end

function Builder:ShowImportExportBox( wndHandler, wndControl, eMouseButton)
  self.wndMain:FindChild("ImportExportWindow"):Show(true,false)
  self.wndMain:FindChild("ExportEditBox"):SetText(
    self.btools.util.encode_base64(self.btools.util.serialise_table(self.tBuild),
      'qQwWeErRtTyYuUiIoOpPaAsSdDfFgGhHjJkKlLzZxXcCvVbBnNmM9876543210/*'))
  self.wndMain:FindChild("ImportEditBox"):SetText("")
  self.wndMain:FindChild("ImportError"):Show(false,false)
end

function Builder:GetBuildFromB64(b64)
  if (not b64) or (b64 == "") then
    return false, nil
  end
  
  local converted = self.btools.util.decode_base64(b64, 'qQwWeErRtTyYuUiIoOpPaAsSdDfFgGhHjJkKlLzZxXcCvVbBnNmM9876543210/*')

  local importedFunc = loadstring("return "..converted)
  if not importedFunc then
    return false, nil
  end

  local isGood, build = pcall(importedFunc)

  if (not isGood) or (build == nil) then
    return false, nil
  end
  if not self:IsValidBuild(build) then return false, nil end
  return true, build
end

function Builder:OnImportBuild( wndHandler, wndControl, eMouseButton )
  local pass, build = self:GetBuildFromB64(
    self.wndMain:FindChild("ImportEditBox"):GetText())
  self.wndMain:FindChild("ImportError"):Show(not pass,false) 
  if not pass then return end
  self.tBuild = build
  self:HideImportExportBox()
  self:BuildWindow()
end


















local WeightMate = {} 

function WeightMate:new(o)
  local o = o or {}

  o.btools = {}
  o.btools.util = Apollo.GetPackage('indigotock.btools.util').tPackage
  o.btools.gui = {}
  o.btools.gui.drop_button =
  Apollo.GetPackage('indigotock.btools.gui.drop_button').tPackage
  o.btools.gui.number_ticker =
  Apollo.GetPackage('indigotock.btools.gui.number_ticker').tPackage
  o.btools.gui.search_list =
  Apollo.GetPackage('indigotock.btools.gui.search_list').tPackage

  setmetatable(o, {__index = WeightMate})
  o.nAddonVersion = 12000
  o.tSettings = {}
  o.tBuilds = {}
  o.buildListBox = {}
  o.sTooltipAddon = nil
  o.tTooltipAddons = {
    ["ToolTips"] = 1,
    ["VikingTooltips"] = 1
  }
  return o
end

function WeightMate:Init()
  Apollo.RegisterAddon(self, true, "WeightMate", {"ToolTips", "VikingTooltips"})
end

function WeightMate:OnSave(kind)
  if kind == GameLib.CodeEnumAddonSaveLevel.Account then
    local ret = {}
    ret.tBuilds = self.tBuilds
    ret.nVersion = self.nAddonVersion
    ret.nDefaultWeight = self.tSettings.nDefaultWeight
    ret.tBuilds=self.tBuilds
    return ret
  end
end

function WeightMate:OnRestore(kind,settings)
  if kind==GameLib.CodeEnumAddonSaveLevel.Account then
    if not settings then
      self.tSettings.nVersion.nDefaultWeight = 0
      self.tBuilds = {}

    elseif not settings.nVersion then --Old version
      self.tSettings.nDefaultWeight = settings.defaultWeight or 0
      self.tBuilds = {}
      for timestamp, build in pairs(settings['builds'] or {}) do
        local newBuild = self:GetCleanBuild()

        newBuild.sName = build['name'] or "New build"
        newBuild.eRole = build['role'] or 1
        newBuild.eClass = build['class'] or 1

        newBuild.tStatConfig.tWeights = build['stats'] or {}
        self.tBuilds[timestamp] = newBuild
      end

    else -- Version 1.2 and above (less bad code!)
      self.tSettings.nDefaultWeight = settings.nDefaultWeight or 0
      self.tBuilds = settings.tBuilds or {}
      for _,build in pairs(self.tBuilds) do
        build = self.btools.util.merge_table(self:GetCleanBuild(), build)
      end
    end
  end

  self:UpdateBuildList()
end
function WeightMate:ShowWindow()
  self.wndMain:Show(true)
end

function WeightMate:InjectTooltip(wndControl, item, tFlags, nCount)
  local this = Apollo.GetAddon("WeightMate")
  local currentItem = Item.GetEquippedItemForItemType(item)
  wndControl:SetTooltipDoc(nil)
  local wndTooltip, wndTooltipComp = this.oldItemForm(this, wndControl, item, tFlags, nCount)

  this:DoTooltip(wndTooltip,item,tFlags,nCount)
  this:DoTooltip(wndTooltipComp,currentItem ,tFlags,nCount)
  
  return wndTooltip, wndTooltipComp
end

function WeightMate:DoTooltip(control,item,tFlags,nCount)


  local tSource = { item, tFlags.itemModData, tFlags.tGlyphData, tFlags.arGlyphIds, tFlags.strMaker }
  local tItemInfo = Item.GetDetailedInfo(tSource)
  
  local currentItem = Item.GetEquippedItemForItemType(item)
  if control then
    if self.btools.util.table_size(self.tBuilds)>0 and  Item.IsEquippable(item) and tItemInfo.tPrimary then
      local baseform = {}
        baseform = Apollo.LoadForm(self.xmlDoc,"TooltipContainer",control:FindChild("Items"))
      for k,v in pairs(self.tBuilds) do
        local weight = self:CalculateItemWeight(tItemInfo.tPrimary, v)
        local cWeight = 0
        if currentItem then
          cWeight = self:CalculateItemWeight(currentItem:GetDetailedInfo().tPrimary,v)
        end
        local f = Apollo.LoadForm(self.xmlDoc,"TooltipItem",baseform:FindChild("BuildListContainer"))
        f:FindChild("namebox"):SetText(v.sName)
        f:FindChild("weightbox"):SetText(tostring(weight))
        local diffs = self.btools.util.round_number(weight-cWeight, 2)
        if diffs > 0 then
          f:FindChild("diffbox"):SetText("+"..diffs)
          f:FindChild("diffbox"):SetTextColor(ApolloColor.new("ff42da00"))
        elseif diffs == 0 then
          f:FindChild("diffbox"):SetText(diffs)
          f:FindChild("diffbox"):SetTextColor(ApolloColor.new("ItemQuality_Average"))
        else
          f:FindChild("diffbox"):SetText(diffs)
          f:FindChild("diffbox"):SetTextColor(ApolloColor.new("ffda2a00"))
        end
        local roles = { "CRB_Raid:sprRaid_Icon_RoleDPS", "CRB_Raid:sprRaid_Icon_RoleTank", "CRB_Raid:sprRaid_Icon_RoleHealer"}
        local classes = { "CRB_Raid:sprRaid_Icon_Class_Warrior", "CRB_Raid:sprRaid_Icon_Class_Engineer", "CRB_Raid:sprRaid_Icon_Class_Esper","CRB_Raid:sprRaid_Icon_Class_Medic","CRB_Raid:sprRaid_Icon_Class_Stalker","CRB_Raid:sprRaid_Icon_Class_Spellslinger" }
        f:FindChild("RoleIcon"):SetSprite(roles[v.eRole])
        f:FindChild("ClassIcon"):SetSprite(classes[v.eClass])
      end
      local numitems = self.btools.util.table_size(self.tBuilds)

      baseform:FindChild("BuildListContainer"):ArrangeChildrenVert()
      baseform:Move(0,0,baseform:GetWidth(),baseform:GetHeight()+(numitems*20))

      control:Move(0,0,control:GetWidth(),control:GetHeight()+baseform:GetHeight())
    end
    control:FindChild("Items"):ArrangeChildrenVert()
  end
end

function WeightMate:CalculateItemWeight(item, build)
  local  tally=0
  if item.arBudgetBasedProperties then
    tally = tally + self:GetWeightFromPropSet(build,item.arBudgetBasedProperties)
  end

  if item.arInnateProperties then
    tally = tally + self:GetWeightFromPropSet(build,item.arInnateProperties)
  end
  if item.tSigils and item.tSigils.arSigils and build.tRuneConfig and build.tRuneConfig.bTrack then
    tally = tally + self:GetWeightFromPropSet(build,item.tSigils.arSigils)
    for _,rune in pairs(item.tSigils.arSigils) do
      if (not rune.eProperty) and build.tRuneConfig.bTrackEmpty and build.tRuneConfig.tEmptyWeights[rune.eElement] then 
        tally = tally + build.tRuneConfig.tEmptyWeights[rune.eElement] * 1
      end
    end
  end

  if item.arImbuements and build.tImbuementConfig.bTrack then
    for _,imb in pairs(item.arImbuements) do
      if imb.eProperty then
        if build.tImbuementConfig.bTrackOnlyUnlocked then
          if imb.bComplete and imb.bActive then
            tally = tally + self.GetWeightFromPropSet(imb)
          end
        else
          tally = tally + self.GetWeightFromPropSet(imb)
        end
      end
    end
  end

  return self.btools.util.round_number(tally, 2)
end
function WeightMate:GetWeightFromPropSet(build,props)
  local ret = 0
  props = props or {}
  for _,prop in pairs(props) do
    if prop['arDerived'] then
      ret = ret + self:GetWeightFromPropSet(build,prop['arDerived'])
    end
    if prop['nValue'] and (not tPrimaryStats[prop['eProperty']] or build.tStatConfig.bTrackPrimary) then
      ret = ret + (prop['nValue']*((build.tStatConfig.tWeights[prop['eProperty']]) or self.tSettings.nDefaultWeight))
    end
  end
  return ret
end

function WeightMate:OnConfigure()
  self.wndMain:Show(true,false)
end

function WeightMate:MainTabSelect( wndHandler, wndControl, eMouseButton )
  local container = self.wndMain:FindChild("Content")
  
  for k,v in pairs(container:GetChildren()) do
    v:Show(false,true)
  end
  
  local name = wndControl:GetName()
  name = (string.sub(name,0,-4).."Content")
  local control = self.wndMain:FindChild(name)
  if control == nil then return end
  control:Show(true,true)
  if name == 'ConfigContent' then
    self.wndMain:FindChild("DefaultWeightTicker"):DestroyChildren()
    self.btools.gui.number_ticker(self.wndMain:FindChild("DefaultWeightTicker"),{nDefaultValue=self.tSettings.nDefaultWeight, nDivide=0, sHeaderText="", fOnChangeValue = function(ticker, val) self.tSettings.nDefaultWeight = val end})
  elseif name == 'WeightsContent' then
    self:UpdateBuildList()
  elseif name == 'AboutContent' then

  end
end

function WeightMate:UpdateBuildList()
  for _,item in pairs(self.buildListBox:GetChildren()) do
    item:Destroy()
  end

  local classes = {'Warrior','Engineer','Esper','Medic','Stalker','Spellslinger'}
  local roleIcons = { "IconSprites:Icon_ArchetypeUI_CRB_Bruiser", "IconSprites:Icon_ArchetypeUI_CRB_Guard", "IconSprites:Icon_ArchetypeUI_CRB_DefensiveHealer" }

  
  for k,build in pairs(self.tBuilds) do
    local form = Apollo.LoadForm(self.xmlDoc, "BuildListItem", self.buildListBox , self)
    form:FindChild("BuildName"):SetText(build.sName)
    form:FindChild("RoleIcon"):SetSprite(roleIcons[build.eRole])
    form:FindChild("ClassIcon"):SetSprite("IconSprites:Icon_Windows_UI_CRB_"..(classes[build.eClass or 1] or "Warrior"))
    form:FindChild("buildid"):SetText(tostring(k))

  end
  
  
  Apollo.LoadForm(self.xmlDoc,"NewBuildButton",self.buildListBox,self)
  self.buildListBox:ArrangeChildrenVert()
end


function WeightMate:OnClose( wndHandler, wndControl, eMouseButton )
  self.wndMain:Close()
end

function WeightMate:StartNewBuild( wndHandler, wndControl, eMouseButton )
  local id = math.floor(GameLib.GetGameTime()*100)
  Builder:new(id)
  self:UpdateBuildList()
end

function WeightMate:EditBuild( wndHandler, wndControl, eMouseButton )
  local id = tonumber(wndControl:FindChild("buildid"):GetText())
  Builder:new(id)
  self:UpdateBuildList()
end

-- Other

function WeightMate:GetCleanBuild()
  local build = {}
  build = {}
  build.sName = "New Build"
  build.eClass = 1
  if GameLib and GameLib.GetPlayerUnit() then
    build.eClass = GameLib.GetPlayerUnit():GetClassId()
  end
  build.eRole = 2
  
  build.tRuneConfig = {}
  build.tRuneConfig.bTrack = true
  build.tRuneConfig.bTrackEmpty = false
  build.tRuneConfig.tEmptyWeights = {}

  build.tImbuementConfig = {}
  build.tImbuementConfig.bTrack = true
  build.tImbuementConfig.bTrackOnlyUnlocked = true

  build.tStatConfig = {}
  build.tStatConfig.bTrackPrimary = false
  build.tStatConfig.tWeights = {}
  return build
end


function WeightMate:OnLoad()
  for key,val in pairs(self.tTooltipAddons) do
    if val == 1 then
      self.sTooltipAddon = key
      break
    end
  end
    -- load our form file
    self.xmlDoc = XmlDoc.CreateFromFile("WeightMate.xml")
    self.wndMain = Apollo.LoadForm(self.xmlDoc, "WeightMateForm", nil, self)
    Apollo.RegisterSlashCommand("weight","ShowWindow",self)
    Apollo.RegisterSlashCommand("weightmate","ShowWindow",self)
    Apollo.RegisterSlashCommand("wm","ShowWindow",self)
    self.buildListBox = self.wndMain:FindChild("BuildListBox")
    self.wndMain:FindChild("HeaderNav"):SetRadioSel("WMNavGroup",1)
    self:MainTabSelect(self.wndMain,self.wndMain:FindChild("WeightsBtn"),nil)
    self:UpdateBuildList()

    local addon = Apollo.GetAddon(self.sTooltipAddon)
    if not addon then return end
    local generateFunc = addon.CreateCallNames
    local function createFunc(caller)
      generateFunc(caller)
      local function getForm(caller, control, item, flags, num)
        return self.InjectTooltip(caller,control,item,flags,num)
      end
      self.oldItemForm = Tooltip.GetItemTooltipForm
      Tooltip.GetItemTooltipForm = getForm
    end
    addon.CreateCallNames = createFunc
  end

  function WeightMate:OnDependencyError(sDep, sError)
  if sDep == "ToolTips" or sDep == "VikingTooltips" then
    self.tTooltipAddons[sDep] = nil
    return true
  end
end


local WeightMateInst = WeightMate:new()
WeightMateInst:Init()