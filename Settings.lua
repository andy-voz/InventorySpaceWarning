function InventorySpaceWarning.InitializeSettings()
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
      default = InventorySpaceWarning.Constants.spaceLimit,
      getFunc = function() return InventorySpaceWarning.savedVariables.spaceLimit end,
      setFunc = function(value) InventorySpaceWarning.UpdateSpaceLimit(value) end,
    },
    [2] = {
      type = "slider",
      name = "Icon size",
      min = 20,
      max = 100,
      step = 1,
      default = InventorySpaceWarning.Constants.iconSize,
      getFunc = function() return InventorySpaceWarning.savedVariables.iconSize end,
      setFunc = function(value) InventorySpaceWarning.UpdateIconSize(value) end,
    },
    [3] = {
      type = "checkbox",
      name = "Show Label",
      getFunc = function() return InventorySpaceWarning.savedVariables.labelVisibility end,
      setFunc = function(value) InventorySpaceWarning.UpdateLabelVisibility(value) end,
      width = "full"
    }
  }
  LAM:RegisterAddonPanel(panelName, panelData)
  LAM:RegisterOptionControls(panelName, optionsTable)
end
