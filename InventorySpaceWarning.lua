-- Addon namespace
local InventorySpaceWarning = {}

InventorySpaceWarning.name = "InventorySpaceWarning"

local logger = LibDebugLogger(InventorySpaceWarning.name)
local defaultSpaceLimit = 10
local defaultIconSize = 50

-- TODO switch between icons option.
local iconsMap = {
  Custom = "InventorySpaceWarning/res/sack-icon.dds",
  ESO = "/esoui/art/mainmenu/menubar_inventory_down.dds"
}

function InventorySpaceWarning.OnIndicatorMoveStop()
    InventorySpaceWarning.savedVariables.left = InventorySpaceIndicator:GetLeft()
    InventorySpaceWarning.savedVariables.top = InventorySpaceIndicator:GetTop()
end

local function _updateVisibility()
    InventorySpaceIndicator:SetHidden(not InventorySpaceWarning.showingHud or InventorySpaceWarning.freeSlots > InventorySpaceWarning.savedVariables.spaceLimit)
end

function InventorySpaceWarning.CheckFreeSlots()
    InventorySpaceWarning.freeSlots = GetNumBagFreeSlots(BAG_BACKPACK)

    logger:Debug("Free backpack slots count: %d", InventorySpaceWarning.freeSlots)
    InventorySpaceIndicatorLabel:SetText(InventorySpaceWarning.freeSlots)
    _updateVisibility()
end

local function _onInventoryChanged(_eventCode, _bagId, slotIndex, _isNewItem, _itemSoundCategory,
                                   updateReason, _stackCountChange)
    logger:Debug("Inventory changed. slotIndex: %s, updateReason: %s", slotIndex, updateReason)
    InventorySpaceWarning.CheckFreeSlots()
end

local function _restoreSavedPosition()
    local left = InventorySpaceWarning.savedVariables.left
    local top = InventorySpaceWarning.savedVariables.top

    -- Checking if we have saved positions.
    if (left and top) then
        InventorySpaceIndicator:ClearAnchors()
        InventorySpaceIndicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
    end
end

local function _restoreIconSize()
  local size = InventorySpaceWarning.savedVariables.iconSize

  if (size) then
      InventorySpaceIndicatorIcon:SetDimensions(size, size)
  end
end

local function _onfragmentChange(_oldState, newState)
    logger:Debug("HUD Visibility changed: %s", newState)
    if (newState == SCENE_FRAGMENT_SHOWN ) then
        InventorySpaceWarning.showingHud = true
        _updateVisibility()
    elseif (newState == SCENE_FRAGMENT_HIDDEN ) then
        InventorySpaceWarning.showingHud = false
        _updateVisibility()
    end
end

local function _updateSpaceLimit(value)
    InventorySpaceWarning.savedVariables.spaceLimit = value
    _updateVisibility()
end

local function _updateIconSize(value)
  InventorySpaceWarning.savedVariables.iconSize = value
  _restoreIconSize()
end

local function _initializeSettings()
    local LAM = LibAddonMenu2
    local panelName = "InventorySpaceWarningSettingsPanel"

    local panelData = {
        type = "panel",
        name = "Inventory Space Warning",
        author = "Pachvara",
        slashCommand = "/inventorySpaceWarning"
    }

    local optionsTable = {
        [1] = {
            type = "slider",
            name = "Warn at",
            tooltip = "Indicator will be shown when this amount of the inventory space is left",
            min = 1,
            max = 100,
            step = 1,
            default = defaultSpaceLimit,
            getFunc = function () return InventorySpaceWarning.savedVariables.spaceLimit end,
            setFunc = function (value) _updateSpaceLimit(value) end,
        },
        [2] = {
            type = "slider",
            name = "Icon size",
            min = 20,
            max = 100,
            step = 1,
            default = defaultIconSize,
            getFunc = function () return InventorySpaceWarning.savedVariables.iconSize end,
            setFunc = function (value) _updateIconSize(value) end,
        }
    }
    LAM:RegisterAddonPanel(panelName, panelData)
    LAM:RegisterOptionControls(panelName, optionsTable)
end

local function _initialize()
    EVENT_MANAGER:RegisterForEvent(
      InventorySpaceWarning.name,
      EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
      _onInventoryChanged
    )
    EVENT_MANAGER:AddFilterForEvent(
      InventorySpaceWarning.name,
      EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
      REGISTER_FILTER_BAG_ID,
      BAG_BACKPACK
    )

    EVENT_MANAGER:RegisterForEvent(
      InventorySpaceWarning.name,
      EVENT_INVENTORY_BAG_CAPACITY_CHANGED,
      _onInventoryChanged
    )

    InventorySpaceWarning.savedVariables =
      ZO_SavedVars:NewCharacterIdSettings("InventorySpaceWarningSavedVariables", 1, nil, {})
    if not InventorySpaceWarning.savedVariables.spaceLimit then
        InventorySpaceWarning.savedVariables.spaceLimit = defaultSpaceLimit
    end
    if not InventorySpaceWarning.savedVariables.iconSize then
      InventorySpaceWarning.savedVariables.iconSize = defaultIconSize
    end
    if not InventorySpaceWarning.savedVariables.labelSize then
      InventorySpaceWarning.savedVariables.labelSize = defaultLabelSize
    end

    _restoreSavedPosition()
    _restoreIconSize()
    _initializeSettings()

    local fragment = HUD_FRAGMENT
    fragment:RegisterCallback("StateChange", _onfragmentChange)

    InventorySpaceWarning.showingHud = fragment:IsShowing()
    InventorySpaceWarning.CheckFreeSlots()
end

function InventorySpaceWarning.OnAddOnLoaded(_event, addonName)
    if addonName == InventorySpaceWarning.name then
        _initialize()
        EVENT_MANAGER:UnregisterForEvent(InventorySpaceWarning.name, EVENT_ADD_ON_LOADED)
    end
end

EVENT_MANAGER:RegisterForEvent(InventorySpaceWarning.name, EVENT_ADD_ON_LOADED, InventorySpaceWarning.OnAddOnLoaded)
