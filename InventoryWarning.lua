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
    InventoryWarningIndicator:SetHidden(InventoryWarning.freeSlots > 10)
end

local function _onInventoryChanged(_eventCode, _bagId, slotIndex, _isNewItem, _itemSoundCategory, updateReason, _stackCountChange)
    logger:Debug("Inventory changed. slotIndex: %s, updateReason: %s", slotIndex, updateReason)
    InventoryWarning.CheckFreeSlots()
end

local function _restorePosition()
    local left = InventoryWarning.savedVariables.left
    local top = InventoryWarning.savedVariables.top

    InventoryWarningIndicator:ClearAnchors()
    InventoryWarningIndicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

local function _initialize()
    local fragment = ZO_HUDFadeSceneFragment:New(InventoryWarningIndicator, nil, 0)
    HUD_SCENE:AddFragment(fragment)
    HUD_UI_SCENE:AddFragment(fragment)

    EVENT_MANAGER:RegisterForEvent(InventoryWarning.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, _onInventoryChanged)
    EVENT_MANAGER:AddFilterForEvent(InventoryWarning.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_BACKPACK)

    InventoryWarning.savedVariables = ZO_SavedVars:NewCharacterIdSettings("InventoryWarningSavedVariables", 1, nil, {})
    _restorePosition()
end

function InventoryWarning.OnAddOnLoaded(event, addonName)
    if addonName == InventoryWarning.name then
        _initialize()
        EVENT_MANAGER:UnregisterForEvent(InventoryWarning.name, EVENT_ADD_ON_LOADED)
    end
end

EVENT_MANAGER:RegisterForEvent(InventoryWarning.name, EVENT_ADD_ON_LOADED, InventoryWarning.OnAddOnLoaded)
