#!/bin/bash
rm -rf .pack
mkdir -p .pack/InventorySpaceWarning
cp InventorySpaceWarning.* .pack/InventorySpaceWarning/
cp res/*.dds .pack/InventorySpaceWarning/res/
cd .pack
zip -r InventorySpaceWarning.zip InventorySpaceWarning
cd -
