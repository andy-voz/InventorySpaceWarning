local logger = LibDebugLogger(InventorySpaceWarning.name)

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
  InventorySpaceIndicatorIcon:SetDimensions(size, size)
end

local function _restoreLabelVisibility()
  local visible = InventorySpaceWarning.savedVariables.labelVisibility
  InventorySpaceIndicatorLabel:SetHidden(not visible)
end

local function _onfragmentChange(_, newState)
    logger:Debug("HUD Visibility changed: %s", newState)
    if (newState == SCENE_FRAGMENT_SHOWN ) then
        InventorySpaceWarning.showingHud = true
        _updateVisibility()
    elseif (newState == SCENE_FRAGMENT_HIDDEN ) then
        InventorySpaceWarning.showingHud = false
        _updateVisibility()
    end
end

local function _initSavedDataVars()
  if not InventorySpaceWarning.savedVariables.spaceLimit then
    InventorySpaceWarning.savedVariables.spaceLimit = InventorySpaceWarning.Constants.spaceLimit
  end
  if not InventorySpaceWarning.savedVariables.iconSize then
    InventorySpaceWarning.savedVariables.iconSize = InventorySpaceWarning.Constants.iconSize
  end
  if InventorySpaceWarning.savedVariables.labelVisibility == nil then
    InventorySpaceWarning.savedVariables.labelVisibility = true
  end
end

local function _registerUpdateEvents()
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
end

function InventorySpaceWarning.Initialize()
  _registerUpdateEvents()

  InventorySpaceWarning.savedVariables =
    ZO_SavedVars:NewCharacterIdSettings("InventorySpaceWarningSavedVariables", 1, nil, {})

  _initSavedDataVars()

  InventorySpaceWarning:InitializeSettings()

  _restoreSavedPosition()
  _restoreIconSize()
  _restoreLabelVisibility()

  local fragment = HUD_FRAGMENT
  fragment:RegisterCallback("StateChange", _onfragmentChange)

  InventorySpaceWarning.showingHud = fragment:IsShowing()
  InventorySpaceWarning.CheckFreeSlots()
end

-- BEGIN: Callbacks for settings
function InventorySpaceWarning.UpdateLabelVisibility(visible)
  InventorySpaceWarning.savedVariables.labelVisibility = visible
  _restoreLabelVisibility()
end

function InventorySpaceWarning.UpdateSpaceLimit(value)
    InventorySpaceWarning.savedVariables.spaceLimit = value
    _updateVisibility()
end

function InventorySpaceWarning.UpdateIconSize(value)
  InventorySpaceWarning.savedVariables.iconSize = value
  _restoreIconSize()
end
-- BEGIN: end
