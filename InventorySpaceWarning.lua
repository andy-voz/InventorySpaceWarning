-- Addon namespace
InventorySpaceWarning = {}

InventorySpaceWarning.name = "InventorySpaceWarning"

local logger = LibDebugLogger(InventorySpaceWarning.name)

function InventorySpaceWarning.OnIndicatorMoveStop()
    InventorySpaceWarning.savedVariables.left = InventorySpaceIndicator:GetLeft()
    InventorySpaceWarning.savedVariables.top = InventorySpaceIndicator:GetTop()
end

local function _updateVisibility()
    InventorySpaceIndicator:SetHidden(not InventorySpaceWarning.showingHud or InventorySpaceWarning.freeSlots > 10)
end

function InventorySpaceWarning.CheckFreeSlots()
    InventorySpaceWarning.freeSlots = GetNumBagFreeSlots(BAG_BACKPACK)

    logger:Debug("Free backpack slots count: %d", InventorySpaceWarning.freeSlots)
    InventorySpaceIndicatorLabel:SetText(InventorySpaceWarning.freeSlots)
    _updateVisibility()
end

local function _onInventoryChanged(_eventCode, _bagId, slotIndex, _isNewItem, _itemSoundCategory, updateReason, _stackCountChange)
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

local function _onfragmentChange(oldState, newState)
    logger:Debug("HUD Visibility changed: %s", newState)
    if (newState == SCENE_FRAGMENT_SHOWN ) then
        InventorySpaceWarning.showingHud = true
        _updateVisibility()
    elseif (newState == SCENE_FRAGMENT_HIDDEN ) then
        InventorySpaceWarning.showingHud = false
        _updateVisibility()
    end
end

local function _initialize()
    EVENT_MANAGER:RegisterForEvent(InventorySpaceWarning.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, _onInventoryChanged)
    EVENT_MANAGER:AddFilterForEvent(InventorySpaceWarning.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_BACKPACK)

    InventorySpaceWarning.savedVariables = ZO_SavedVars:NewCharacterIdSettings("InventorySpaceWarningSavedVariables", 1, nil, {})
    _restoreSavedPosition()

    local fragment = HUD_FRAGMENT
    fragment:RegisterCallback("StateChange", _onfragmentChange)

    InventorySpaceWarning.showingHud = fragment:IsShowing()
    InventorySpaceWarning.CheckFreeSlots()
end

function InventorySpaceWarning.OnAddOnLoaded(event, addonName)
    if addonName == InventorySpaceWarning.name then
        _initialize()
        EVENT_MANAGER:UnregisterForEvent(InventorySpaceWarning.name, EVENT_ADD_ON_LOADED)
    end
end

EVENT_MANAGER:RegisterForEvent(InventorySpaceWarning.name, EVENT_ADD_ON_LOADED, InventorySpaceWarning.OnAddOnLoaded)
