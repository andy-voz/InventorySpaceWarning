-- Addon namespace
InventoryWarning = {}

InventoryWarning.name = "InventoryWarning"

local logger = LibDebugLogger(InventoryWarning.name)

function InventoryWarning.OnIndicatorMoveStop()
    InventoryWarning.savedVariables.left = InventoryWarningIndicator:GetLeft()
    InventoryWarning.savedVariables.top = InventoryWarningIndicator:GetTop()
end

function InventoryWarning.CheckFreeSlots()
    InventoryWarning.freeSlots = GetNumBagFreeSlots(BAG_BACKPACK)

    logger:Debug("Free backpack slots count: %d", InventoryWarning.freeSlots)
    InventoryWarningIndicatorLabel:SetText(InventoryWarning.freeSlots)
    InventoryWarningIndicator:SetHidden(InventoryWarning.hudShown ~= true or InventoryWarning.freeSlots > 10)
end

local function _onInventoryChanged(_eventCode, _bagId, slotIndex, _isNewItem, _itemSoundCategory, updateReason, _stackCountChange)
    logger:Debug("Inventory changed. slotIndex: %s, updateReason: %s", slotIndex, updateReason)
    InventoryWarning.CheckFreeSlots()
end

local function _restorePosition()
    local left = InventoryWarning.savedVariables.left
    local top = InventoryWarning.savedVariables.top

    if (left ~= nil and top ~= nil) then
        InventoryWarningIndicator:ClearAnchors()
        InventoryWarningIndicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
    end
end

local function _onfragmentChange(oldState, newState)
    logger:Debug("HUD Visibility changed: %s", newState)
    if (newState == SCENE_FRAGMENT_SHOWN ) then
        InventoryWarning.hudShown = true
        InventoryWarning.CheckFreeSlots()
    elseif (newState == SCENE_FRAGMENT_HIDDEN ) then
        InventoryWarning.hudShown = false
        InventoryWarning.CheckFreeSlots()
    end
end

local function _initialize()
    EVENT_MANAGER:RegisterForEvent(InventoryWarning.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, _onInventoryChanged)
    EVENT_MANAGER:AddFilterForEvent(InventoryWarning.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_BACKPACK)

    InventoryWarning.savedVariables = ZO_SavedVars:NewCharacterIdSettings("InventoryWarningSavedVariables", 1, nil, {})
    _restorePosition()

    local fragment = HUD_FRAGMENT
    fragment:RegisterCallback("StateChange", _onfragmentChange)

    InventoryWarning.hudShown = fragment:IsShowing()
    InventoryWarning.CheckFreeSlots()
end

function InventoryWarning.OnAddOnLoaded(event, addonName)
    if addonName == InventoryWarning.name then
        _initialize()
        EVENT_MANAGER:UnregisterForEvent(InventoryWarning.name, EVENT_ADD_ON_LOADED)
    end
end

EVENT_MANAGER:RegisterForEvent(InventoryWarning.name, EVENT_ADD_ON_LOADED, InventoryWarning.OnAddOnLoaded)
