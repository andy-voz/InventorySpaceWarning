-- Addon namespace
InventoryWarning = {}

InventoryWarning.name = "InventoryWarning"

local logger = LibDebugLogger(InventoryWarning.name)

local function _checkFreeSlots()
    InventoryWarning.freeSlots = GetNumBagFreeSlots(BAG_BACKPACK)

    logger:Debug("Free backpack slots count: %d", InventoryWarning.freeSlots)
    InventoryWarningIndicatorLabel:SetText(InventoryWarning.freeSlots)
    InventoryWarningIndicator:SetHidden(InventoryWarning.freeSlots > 10)
end

local function _onInventoryChanged(_eventCode, _bagId, slotIndex, _isNewItem, _itemSoundCategory, updateReason, _stackCountChange)
    logger:Debug("Inventory changed. slotIndex: %s, updateReason: %s", slotIndex, updateReason)
    _checkFreeSlots()
end

function InventoryWarning.Initialize()
    _checkFreeSlots()

    local fragment = ZO_HUDFadeSceneFragment:New(InventoryWarningIndicator, nil, 0)
    HUD_SCENE:AddFragment(fragment)
    HUD_UI_SCENE:AddFragment(fragment)

    EVENT_MANAGER:RegisterForEvent(InventoryWarning.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, _onInventoryChanged)
    EVENT_MANAGER:AddFilterForEvent(InventoryWarning.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_BACKPACK)
end

function InventoryWarning.OnAddOnLoaded(event, addonName)
    if addonName == InventoryWarning.name then
        InventoryWarning.Initialize()
        EVENT_MANAGER:UnregisterForEvent(InventoryWarning.name, EVENT_ADD_ON_LOADED)
    end
end

EVENT_MANAGER:RegisterForEvent(InventoryWarning.name, EVENT_ADD_ON_LOADED, InventoryWarning.OnAddOnLoaded)
